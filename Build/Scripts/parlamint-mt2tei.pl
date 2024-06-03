#!/usr/bin/env perl
# Convert one MTed and semantically annotated corpus to TEI given
# - ParlaMint-XX.ana.xml corpus root of original-language corpus
# - ParlaMint-XX-en-notes.tsv notes with translations
# - ParlaMint-XX-en.conllu CoNLL-U of translated speeches and semantic tags
# and
# - ParlaMint-XX-en.TEI.ana/ output directory
#
use warnings;
use utf8;
use FindBin qw($Bin);
use File::Spec;
use File::Copy;
use File::Copy::Recursive qw(dircopy);
use File::Temp qw/ tempfile tempdir /;  #creation of tmp files and directory
my $tempdirroot = "$Bin/tmp";
my $tmpDir = tempdir(DIR => $tempdirroot, CLEANUP => 1);

binmode STDERR, 'utf8';
$inDir = shift;
$notesFile = shift;
$conllDir = shift;
$outDir = shift;

($country) = $inDir =~ m|-([A-Z]{2}(-[A-Z]{2})?)\.| or
    die "FATAL ERROR: Strange input directory $inDir!\n";

$notesFile = File::Spec->rel2abs($notesFile);
$inTEI     = File::Spec->rel2abs($inDir);
$conllDir  = File::Spec->rel2abs($conllDir);
$outDir    = File::Spec->rel2abs($outDir);

# Location of the USAS taxonomy to be copied
# This probably should be done with the standard taxonomy copying scripts, this is a bit of a hack!
$USAStaxonomy = "$Bin/../Taxonomies/ParlaMint-taxonomy-USAS.ana.xml";

# We give 240g heap to Saxon because of large corpora!
$Saxon   = "java -jar -Xmx240g $Bin/bin/saxon.jar";

$scriptStripSents  = "$Bin/mt-prepare4mt.xsl";
$scriptConllu2Tei  = "$Bin/conllu2tei.pl";
$scriptInsertNotes = "$Bin/mt-insert-notes.xsl";
$scriptInsertSents = "$Bin/mt-insert-s.pl";
$scriptPolish      = "$Bin/polish-xml.pl";

# logger variable stores info how long takes certain parts of code, used by logger subrutine
my $logger = {
    code => $country,
    time => undef,
    message => undef
};

my $parallel = {
    handle => undef,
    scriptPath => undef,
    currentJobNumber => undef
};

logger('Converting MTed and semantically annotated corpus to TEI');

print STDERR "INFO: Preparing data for $country\n";
$tmpTEI = "$tmpDir/ParlaMint-XX.tmp";
mkdir $tmpTEI unless -d $tmpTEI;
# In $tmpTEI/ make corpus with empty sentences
`$Saxon outDir=$tmpTEI -xsl:$scriptStripSents $inTEI`;
`mkdir -p $outDir` unless -d $outDir;
`rm -r $outDir/*`;
`cp $tmpTEI/*.xml $outDir`;

print STDERR "INFO: Copying factorised $USAStaxonomy\n";
`cp $USAStaxonomy $outDir`;

foreach $yearDir (glob "$tmpTEI/*") {
    next unless -d $yearDir;
    ($year) = $yearDir =~ m|/(\d\d\d\d)$| or die "FATAL ERROR: Strange $yearDir\n";
    print STDERR "INFO: Processing $country $year\n";
    `mkdir $outDir/$year` unless -d "$outDir/$year";
    parallel_start("$tmpDir/$year.sh");
    foreach $inFile (glob "$tmpTEI/$year/*.xml") {
        ($fName) = $inFile =~ m|/([^/]+)\.ana\.xml|;
        $tmpFile1 = "$tmpDir/$fName.body.xml";
        $tmpFile2 = "$tmpDir/$fName.note.xml";
        $conllFile = "$conllDir/$year/$fName.conllu";
        die "FATAL ERROR: Cant find ConLL-U file $conllFile\n" unless -e $conllFile;
        $outFile = "$outDir/$year/$fName.ana.xml";
        parallel_insert_command("echo 'INFO: Processing $year/$fName'");
        parallel_insert_command("$scriptConllu2Tei < $conllFile 2>&1 > $tmpFile1");
        parallel_insert_command("$Saxon notesFile=$notesFile -xsl:$scriptInsertNotes $inFile 2>&1 > $tmpFile2");
        parallel_insert_command("$scriptInsertSents $tmpFile1 < $tmpFile2 | $scriptPolish 2>&1 > $outFile");
        parallel_end_job();
    }
    parallel_run();
    parallel_end();
}
logger();

sub logger {
    my $message = shift;
    my $time = time();
    if($logger->{time} && $logger->{message}) {
        logger_print($logger->{code},$time,"DONE",$logger->{message},$time - $logger->{time});
        $logger->{message} = undef;
        $logger->{time} = undef;
    }
    if($message){
        logger_print($logger->{code},$time,"START",$message);
        $logger->{message} = $message;
        $logger->{time} = $time;
    }
}
sub logger_print {
    my ($countryCode, $time, $status, $message, $duration) = @_;

    print STDERR "INFO: $countryCode-en (",scalar(localtime($time)),") ### $status",(defined($duration) ? "($duration s)": ""),": $message","\n";
}


sub parallel_start {
    my $file = shift;
    $parallel->{scriptPath} = $file;
    $parallel->{currentJobNumber} = 1;
    open($parallel->{handle},'>',$parallel->{scriptPath});
}

sub parallel_end {
    $parallel->{scriptPath} = undef;
    $parallel->{currentJobNumber} = undef;
    close $parallel->{handle};
}

sub parallel_insert_command {
    my $command = shift;
    my $n = $parallel->{currentJobNumber};
    my $h = $parallel->{handle};
    print $h "$command | sed \"s/^/$n\\t/\";";
}

sub parallel_end_job {
    $parallel->{currentJobNumber} += 1;
    my $h = $parallel->{handle};
    print $h "\n";
}
sub parallel_run {
    my $script = $parallel->{scriptPath};
    `cat $script | parallel --gnu --halt 0 --jobs 20 | sort -snk1|sed "s/^[0-9]*\t//" 1>&2`;
}
