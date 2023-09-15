#!/usr/bin/perl
use warnings;
use utf8;
use FindBin qw($Bin);
use File::Spec;
use File::Temp qw/ tempfile tempdir /;  #creation of tmp files and directory
use File::Temp qw/ tempfile tempdir /;  #creation of tmp files and directory
my $tempdirroot = "$Bin/tmp";
my $DIR = tempdir(DIR => $tempdirroot, CLEANUP => 1);

$inDir = File::Spec->rel2abs(shift);
$outDir = File::Spec->rel2abs(shift);

binmode(STDERR, 'utf8');

$Para  = 'parallel --gnu --halt 2 --jobs 10';
$Saxon = 'java -jar /usr/share/java/saxon.jar';
$scriptMeta = "$Bin/parlamint2meta.xsl";
$scriptText = "$Bin/parlamint-tei2text.xsl";

print STDERR "INFO: Converting directory $inDir\n";

#Store all files to be processed in $fileFile
$fileFile = "$DIR/files.lst";
$corpusFiles = "$inDir/*_*.xml $inDir/*/*_*.xml";
#Is this an MTed corpus?
$MT = $inDir =~ m/-en/;

#We can convert either plain files or .ana files
open(TMP, '>:utf8', $fileFile);
@corpusFiles = glob($corpusFiles);
foreach $inFile (@corpusFiles) {
    # Skipping teiHeader files, they can match '/*_*.xml' when _ is present in xml:id
    next if $inFile =~ /^.*\/ParlaMint(?:-[A-Z]{2}(?:-[A-Z0-9]{1,3})?(?:-[a-z]{2,3})?)?-(taxonomy|listPerson|listOrg).*\.xml/;
    # Skip .ana files if equivalent tei file is present
    $ok = 1;
    if ($inFile =~ /(.+)\.ana\./) {
	my $teiFile = "$1.xml";
	foreach my $f (@corpusFiles) {$ok = 0 if $f eq $teiFile}
    }
    print TMP "$inFile\n" if $ok;
}
close TMP;

print STDERR "INFO: Making text files\n";
$command = "$Saxon -xsl:$scriptText {} > $outDir/{/.}.txt";
`cat $fileFile | $Para '$command'`;
`rename 's/\.ana//' $outDir/*.txt`;

print STDERR "INFO: Making metadata files\n";
opendir(CORPUSDIR, $inDir);
@rootFile = grep {/ParlaMint-[A-Z]{2}(?:-[A-Z0-9]{1,3})?(?:-[a-z]{2,3})?(\.ana)?\.xml$/} readdir(CORPUSDIR);
closedir(CORPUSDIR);
#For MTed corpora output only en metadata, for native, both xx and en
if ($MT) {@outLangs = ('en')} else {@outLangs = ('xx', 'en')}
# For orig corpora make ParlaMint-XX-meta.tsv in corpus language and ParlaMint-XX-meta-en.tsv in English
# For MTed corpora we produce ParlaMint-XX-en-meta.tsv in English
foreach my $outLang (@outLangs) {
    my $outSuffix;
    if    ($MT and $outLang eq 'xx') {}
    elsif ($MT and $outLang eq 'en') {$outSuffix = "-meta.tsv"}
    elsif ($outLang eq 'xx') {$outSuffix = "-meta.tsv"}
    elsif ($outLang eq 'en') {$outSuffix = "-meta-en.tsv"}
    if ($outSuffix) {
	$command = "$Saxon" .
	    " meta=" . File::Spec->catfile($inDir,$rootFile[0]) .
	    " out-lang=$outLang" .
	    " -xsl:$scriptMeta {} > $outDir/{/.}$outSuffix";
	`cat $fileFile | $Para '$command'`;
	# The rm following looks like a bug, as no TSV files are left if we are processing only .ana!
	#`rm -f $outDir/*.ana-meta.tsv`;
    }
}
`rename 's/\.ana//' $outDir/*-meta*.tsv`;
