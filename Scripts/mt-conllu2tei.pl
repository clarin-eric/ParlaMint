#!/usr/bin/perl
# Convert CoNLL-U file to TEI <text>
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
    die "Strange input directory $inDir!\n";

$notesFile = File::Spec->rel2abs($notesFile);
$inTEI     = File::Spec->rel2abs($inDir);
$conllDir  = File::Spec->rel2abs($conllDir);
$outDir    = File::Spec->rel2abs($outDir);

$saxon = "java -jar -Xmx240g /usr/share/java/saxon.jar";
$scriptStripSents  = "$Bin/mt-prepare4mt.xsl";
$scriptConllu2Tei   = "$Bin/conllu2tei.pl";
$scriptInsertNotes = "$Bin/mt-insert-notes.xsl";
$scriptInsertSents = "$Bin/mt-insert-s.pl";
$scriptPolish = "$Bin/polish-xml.pl";

print STDERR "INFO: Preparing data for $country\n";
$tmpTEI = "$tmpDir/ParlaMint-XX.tmp";
mkdir $tmpTEI unless -d $tmpTEI;
# In $tmpTEI/ make corpus with empty sentences
`$saxon outDir=$tmpTEI -xsl:$scriptStripSents $inTEI`;
mkdir $outDir unless -d $outDir;
`cp $tmpTEI/*.xml $outDir`;

foreach $yearDir (glob "$tmpTEI/*") {
    next unless -d $yearDir;
    ($year) = $yearDir =~ m|/(\d\d\d\d)$| or die "Strange $yearDir\n";
    print STDERR "INFO: Processing $country $year\n";
    `mkdir $outDir/$year` unless -d "$outDir/$year";
    foreach $inFile (glob "$tmpTEI/$year/*.xml") {
	($fName) = $inFile =~ m|/([^/]+)\.ana\.xml|;
	$tmpFile1 = "$tmpDir/$fName.body.xml";
	$tmpFile2 = "$tmpDir/$fName.note.xml";
	$conllFile = "$conllDir/$year/$fName.conllu";
	$conllFile =~ s|-en_|_|;
	die "Cant find ConLL-U file $conllFile\n" unless -e $conllFile;
	$outFile = "$outDir/$year/$fName.ana.xml";
	print STDERR "INFO: Processing $year/$fName\n";
	`$scriptConllu2Tei < $conllFile > $tmpFile1`;
	`$saxon notesFile=$notesFile -xsl:$scriptInsertNotes $inFile > $tmpFile2`;
	`$scriptInsertSents $tmpFile1 < $tmpFile2 | $scriptPolish > $outFile`;
    }
}
