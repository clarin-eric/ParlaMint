#!/usr/bin/env perl
use warnings;
use utf8;

sub usage
{
    print STDERR ("Usage: parlamintp-tei2text.pl -jobs <Jobs> -in <InputDirectory> -out <OutputDirectory>\n");
    print STDERR ("       Converts ParlaMint .ana files in the <InputDirectory> to\n");
    print STDERR ("       .txt and -meta.tsv files in the <OutputDirectory>\n");
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
     'help'   => \$help,
     'in=s'   => \$inDir,
     'out=s'  => \$outDir,
     'jobs=i' => \$procThreads,
);

if ($help) {
    &usage;
    exit;
}

$inDir = File::Spec->rel2abs($inDir) if $inDir;
$outDir = File::Spec->rel2abs($outDir) if $outDir;
$procThreads = 1 unless $procThreads;

binmode(STDERR, 'utf8');

$Para  = "parallel --gnu --halt 0 --jobs $procThreads";

$Saxon = "java -jar $Bin/bin/saxon.jar";

$scriptText = "$Bin/parlamint-tei2text.xsl";

print STDERR "INFO: Converting directory $inDir\n";

#Store all files to be processed in $fileFile
$fileFile = "$DIR/files.lst";
$corpusFiles = "$inDir/*_*.xml $inDir/*/*_*.xml";

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

