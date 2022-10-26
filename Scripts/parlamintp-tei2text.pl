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
$Meta = "$Bin/parlamint2meta.xsl";
$Convert = "$Bin/parlamint-tei2text.xsl";

print STDERR "INFO: Converting directory $inDir\n";

#Store all files to be processed in $fileFile
$fileFile = "$DIR/files.lst";
$corpusFiles = "$inDir/*_*.xml $inDir/*/*_*.xml";

#We convert only plain files, not .ana!
open(TMP, '>:utf8', $fileFile);
foreach $inFile (glob $corpusFiles) {
  # skipping teiHeader files, they can match '/*_*.xml' when _ is present in xml:id
  next if $inFile =~ /^.*\/ParlaMint(?:-[A-Z]{2}(?:-[A-Z0-9]{1,3})?(?:-[a-z]{2,3})?)?-(taxonomy|listPerson|listOrg).*\.xml/;

  print TMP "$inFile\n" unless $inFile =~ /\.ana/;
}
close TMP;

print STDERR "INFO: Making text files\n";
$command = "$Saxon -xsl:$Convert {} > $outDir/{/.}.txt";
`cat $fileFile | $Para '$command'`;
`rename 's/\.ana//' $outDir/*.txt`;

print STDERR "INFO: Making metadata files\n";
opendir(CORPUSDIR, $inDir);
@rootFile = grep {/ParlaMint-[A-Z]{2}(?:-[A-Z0-9]{1,3})?(?:-[a-z]{2,3})?\.xml$/} readdir(CORPUSDIR);
closedir(CORPUSDIR);
$command = "$Saxon meta=".File::Spec->catfile($inDir,$rootFile[0])." -xsl:$Meta {} > $outDir/{/.}-meta.tsv";
`cat $fileFile | $Para '$command'`;
`rm -f $outDir/*.ana-meta.tsv`;
`rename 's/\.ana//' $outDir/*-meta.tsv`;
