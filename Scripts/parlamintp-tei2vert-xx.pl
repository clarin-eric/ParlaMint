#!/usr/bin/env perl
# A spin-off of parlamintp-tei2vert.pl to produce vertical files with en metadata
use warnings;
use utf8;
use open ':utf8';
use FindBin qw($Bin);
use File::Spec;
use File::Temp qw/ tempfile tempdir /;  #creation of tmp files and directory
my $tempdirroot = "$Bin/tmp";
my $DIR = tempdir(DIR => $tempdirroot, CLEANUP => 1);

$inDir = File::Spec->rel2abs(shift);
$outDir = File::Spec->rel2abs(shift);

binmode(STDERR, 'utf8');

$Para  = 'parallel --gnu --halt 2 --jobs 10';
$Saxon   = "java -jar $Bin/bin/saxon.jar";

$TEI2VERT  = "$Bin/parlamint2xmlvert.xsl";
$POLISH = "$Bin/parlamint-xml2vert.pl";

binmode(STDERR,'utf8');

print STDERR "INFO: Converting directory $inDir\n";
my $rootAnaFile = '';
my @compAnaFiles = ();
$inDir =~ s|[^/]+\.xml$||; # If a specific filename is given, get rid of it
$corpusFiles = "$inDir/*.ana.xml $inDir/*/*.ana.xml";
foreach $inFile (glob($corpusFiles)) {
    if ($inFile =~ m|ParlaMint-[A-Z]{2}(?:-[A-Z0-9]{1,3})?(?:-[a-z]{2,3})?\.ana\.xml|) {
	$rootAnaFile = $inFile
    }
    elsif ($inFile =~ m|ParlaMint-[A-Z]{2}(?:-[A-Z0-9]{1,3})?(?:-[a-z]{2,3})?_.+\.ana\.xml|) {
	push(@compAnaFiles, $inFile)
    }
}

die "Cannot find root file in $inDir!\n"
    unless $rootAnaFile;
die "Cannot find component files in $inDir!\n"
    unless @compAnaFiles;

`mkdir $outDir` unless -e "$outDir";
`rm -f $outDir/*.vert`;

#Store all files to be processed in $fileFile
$fileFile = "$DIR/files.lst";
open(TMP, '>:utf8', $fileFile);
foreach $inFile (@compAnaFiles) {
    print TMP "$inFile\n"
}
close TMP;

$command = "$Saxon meta=$rootAnaFile out-lang=en " .
    "-xsl:$TEI2VERT {} | $POLISH > $outDir/{/.}.vert";
`cat $fileFile | $Para '$command'`;
`rename 's/\.ana//' $outDir/*.vert`;

&dirify($outDir);

#If a directory has more than $MAX files, store them in year directories
sub dirify {
    my $MAX = 1;  #In ParlaMint II we always put them in year directories
    my $inDir = shift;
    my @files = glob("$inDir/*");
    if (scalar @files > $MAX) {
	foreach my $file (@files) {
	    if (my ($year) = $file =~ m|ParlaMint-.+?_(\d\d\d\d)|) {
		my $newDir = "$inDir/$year";
		mkdir($newDir) unless -d $newDir;
		`mv $file $newDir`;
	    }
	}
    }
}
