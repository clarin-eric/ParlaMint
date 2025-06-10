#!/usr/bin/env perl
use warnings;
use utf8;

sub usage
{
    print STDERR ("Usage: parlamintp-tei2meta.pl -jobs <Jobs> -root <corpusRoot> -out <OutputDirectory>\n");
    print STDERR ("       Converts ParlaMint component files in the <corpusRoot> to\n");
    print STDERR ("       -meta.tsv files in the <OutputDirectory>\n");
    print STDERR ("       using parallel <Jobs> in execution.\n");
}

use Getopt::Long;
use FindBin qw($Bin);
use File::Spec;
use File::Temp qw/ tempfile tempdir /;  #creation of tmp files and directory

my $tempdirroot = "$Bin/tmp";
my $DIR = tempdir(DIR => $tempdirroot, CLEANUP => 1);

GetOptions
    (
     'help'     => \$help,
     'inRoot=s' => \$inRoot,
     'out=s'    => \$outDir,
     'jobs=i'   => \$procThreads,
);

if ($help) {
    &usage;
    exit;
}

$inRoot = File::Spec->rel2abs($inRoot) if $inRoot;
$inDir = (File::Spec->splitpath($inRoot))[1];
$outDir = File::Spec->rel2abs($outDir) if $outDir;
$procThreads = 1 unless $procThreads;

binmode(STDERR, 'utf8');

$Para  = "parallel --gnu --halt 0 --jobs $procThreads";
$Saxon = "java -jar $Bin/bin/saxon.jar";
$scriptMeta = "$Bin/parlamint2meta.xsl";
$scriptMetaAna = "$Bin/parlamint2meta.ana.xsl";
$Includes = "$Bin/get-includes.xsl";

`find $outDir -name '*-meta.tsv' -type f -delete`;

#Store all files to be processed in $fileFile
$fileFile = "$DIR/files.lst";
`$Saxon -xsl:$Includes context-elements="teiCorpus" $inRoot | sed "s#^#$inDir/#" > $fileFile`;

#Is this an MTed corpus?
$MT = $inDir =~ m/-en/;

print STDERR "INFO: Making metadata files from component files in $inRoot\n";
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
	    " meta=$inRoot" .
	    " out-lang=$outLang" .
	    " -xsl:$scriptMeta {} > $outDir/{/.}$outSuffix";
	`cat $fileFile | $Para '$command'`;
        # We produce .ana metadata only for .ana corpus and in English 
        if ($inRoot =~ /\.ana/ and $outLang eq 'en') {
            $command = "$Saxon" .
                " meta=$inRoot" .
                " out-lang=$outLang" .
                " -xsl:$scriptMetaAna {} > $outDir/{/.}-ana$outSuffix";
            `cat $fileFile | $Para '$command'`;
        }
    }
}
`find $outDir -name '*-meta*.tsv' -type f -exec rename 's/\.ana//' {} +`;
