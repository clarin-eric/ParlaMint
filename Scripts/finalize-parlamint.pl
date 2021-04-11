#!/usr/bin/perl
# Finalize ParlaMint files
# Tomaž Erjavec <tomaz.erjavec@ijs.si>
# License: GNU GPL

use warnings;
use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

sub usage
{
    print STDERR ("Usage: finalize-parlamint.pl '<COUNTRYCODES>' <InputDirectory> <OutputDirectory>\n");
    print STDERR ("       Finalizes ParlaMint corpora and produces derived encodings.\n");
    print STDERR ("       <COUNTRYCODES> is the list of country codes of the corpora to be processed.\n");
    print STDERR ("       <InputDirectory> is where ParlaMint.TEI-XX/ and ParlaMint.TEI.ana-XX/ are.\n");
    print STDERR ("       <OutputDirectory> is where output directories are written.\n");
    print STDERR ("       The script does the following:\n");
    print STDERR ("       * finalizes the TEI and TEI.ana directories\n");
    print STDERR ("       * produces the plain text, meta, conllu and vertical files.\n");
}
use Getopt::Long;
use FindBin qw($Bin);
use File::Spec;

$countryCodes = shift;
$schemaDir = File::Spec->rel2abs(shift);
$inDir = File::Spec->rel2abs(shift);
$outDir = File::Spec->rel2abs(shift);

$Paralel = "parallel --gnu --halt 2 --jobs 15";
$Saxon   = "java -jar /usr/share/java/saxon.jar";
$Final   = "$Bin/parlamint2final.xsl";
$Polish  = "$Bin/polish.pl";
$Valid   = "$Bin/validate-parlamint.pl";
$Sample  = "$Bin/corpus2sample.xsl";
$Metas   = "$Bin/parlamint2meta.xsl";
$Texts   = "$Bin/parlamint-tei2text.xsl";
$Verts   = "$Bin/parlamintp-tei2vert.pl";
$Conls   = "$Bin/parlamintp2conllu.pl";

$XX_template = "ParlaMint-XX";

foreach my $countryCode (split(/[, ]+/, $countryCodes)) {
    print STDERR "INFO: ***Converting $countryCode\n";
    
    $XX = $XX_template;
    $XX =~ s|XX|$countryCode|g;
    
    $teiDir  = "$XX.TEI";
    $teiRoot = "$teiDir/$XX.xml";
    $anaDir  = "$XX.TEI.ana";
    $anaRoot = "$anaDir/$XX.ana.xml";

    $inTeiRoot = "$inDir/$teiRoot";
    $inAnaRoot = "$inDir/$anaRoot";

    $outTeiDir  = "$outDir/$teiDir";
    $outTeiRoot = "$outDir/$teiRoot";
    $outAnaDir  = "$outDir/$anaDir";
    $outAnaRoot = "$outDir/$anaRoot";
    $outSmpDir  = "$outDir/$XX-Sample";
    $outMetaDir = "$outDir/$XX-Meta";
    $outTxtDir  = "$outDir/$XX.txt";
    $outVertDir = "$outDir/$XX.vert";
    $outConlDir = "$outDir/$XX.conllu";
    
    print STDERR "INFO: *Finalizing TEI.ana\n";
    `rm -fr $outAnaDir`;
    `$Saxon outDir=$outDir -xsl:$Final $inAnaRoot`;
    &polish($outAnaDir);
    `$Valid $schemaDir $outAnaDir`;
    
    print STDERR "INFO: *Finalizing TEI\n";
    `rm -fr $outTeiDir`;
    `$Saxon anaDir=$outAnaDir outDir=$outDir -xsl:$Final $inTeiRoot`;
    &polish($outTeiDir);
    `$Valid $schemaDir $outTeiDir`;

    print STDERR "INFO: *Making samples\n";
    `rm -fr $Sample`;
    `$Saxon outDir=$outSmpDir -xsl:$Sample $outTeiRoot`;
    `$Saxon outDir=$outSmpDir -xsl:$Sample $outAnaRoot`;
    `$Valid $schemaDir $outSmpDir`;
    
    print STDERR "INFO: *Making txt\n";
    `rm -fr $outTxtDir; mkdir $outTxtDir`;
    `ls -R $outTeiDir | grep '_' | $Paralel '$Saxon -xsl:$Texts {} > $outTxtDir/{/.}.txt'`;
    `cp $outMetaDir/* $outTxtDir`;
    $files = "ls -R $outTeiDir | grep '_'";
    `$files | $Paralel '$Saxon hdr=$outTeiRoot -xsl:$Metas {} > $outTxtDir/{/.}-meta.tsv`;
    
    print STDERR "INFO: *Making CoNLL-U\n";
    `rm -fr $outConlDir; mkdir $outConlDir`;
    `$Conls $outAnaDir $outConlDir`;
    $files = "ls -R $outAnaDir | grep '_'";
    `$files | $Paralel '$Saxon hdr=$outTeiRoot -xsl:$Metas {} > $outConlDir/{/.}-meta.tsv`;
    
    print STDERR "INFO: *Making vert\n";
    `rm -fr $outVertDir; mkdir $outVertDir`;
    `$Verts $outAnaDir $outVertDir`;
}

#Format XML file to be a bit nicer & smaller
sub polish {
    my $dir = shift;
    foreach my $file (glob("$dir/*.xml $dir/*/*.xml")) {
	$command = "$Polish < $file > $file.tmp";
	`$command`;
	rename("$file.tmp", $file); 
    }
}
