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
$USAStaxonomy = "$Bin/../Build/Taxonomies/ParlaMint-taxonomy-USAS.ana.xml";

# We give 240g heap to Saxon because of large corpora!
$Saxon   = "java -jar -Xmx240g $Bin/bin/saxon.jar";

$scriptStripSents  = "$Bin/mt-prepare4mt.xsl";
$scriptConllu2Tei  = "$Bin/conllu2tei.pl";
$scriptInsertNotes = "$Bin/mt-insert-notes.xsl";
$scriptInsertSents = "$Bin/mt-insert-s.pl";
$scriptPolish = "$Bin/polish-xml.pl";

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
    foreach $inFile (glob "$tmpTEI/$year/*.xml") {
	($fName) = $inFile =~ m|/([^/]+)\.ana\.xml|;
	$tmpFile1 = "$tmpDir/$fName.body.xml";
	$tmpFile2 = "$tmpDir/$fName.note.xml";
	$conllFile = "$conllDir/$year/$fName.conllu";
	die "FATAL ERROR: Cant find ConLL-U file $conllFile\n" unless -e $conllFile;
	$outFile = "$outDir/$year/$fName.ana.xml";
	print STDERR "INFO: Processing $year/$fName\n";
	`$scriptConllu2Tei < $conllFile > $tmpFile1`;
	`$Saxon notesFile=$notesFile -xsl:$scriptInsertNotes $inFile > $tmpFile2`;
	`$scriptInsertSents $tmpFile1 < $tmpFile2 | $scriptPolish > $outFile`;
    }
}
