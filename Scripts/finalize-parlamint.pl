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

my $procAll    = 1;
my $procAna    = 0;
my $procTei    = 0;
my $procSample = 0;
my $procValid  = 0;
my $procTxt    = 0;
my $procConll  = 0;
my $procVert   = 0;

GetOptions
    (
     'codes=s'  => \$countryCodes,
     'schema=s' => \$schemaDir,
     'in=s'     => \$inDir,
     'out=s'    => \$outDir,
     'all!'     => \$procAll,
     'ana!'     => \$procAna,
     'tei!'     => \$procTei,
     'sample!'  => \$procSample,
     'valid!'   => \$procValid,
     'txt!'     => \$procTxt,
     'conll!'   => \$procConll,
     'vert!'    => \$procVert,
);


$schemaDir = File::Spec->rel2abs($schemaDir);
$inDir = File::Spec->rel2abs($inDir);
$outDir = File::Spec->rel2abs($outDir);

#Scripts
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
    $outSmpDir  = "$outDir/Sample-$XX";
    $outTxtDir  = "$outDir/$XX.txt";
    $outVertDir = "$outDir/$XX.vert";
    $outConlDir = "$outDir/$XX.conllu";

    if ($procAll or $procAna) {
	print STDERR "INFO: *Finalizing $countryCode TEI.ana\n";
	`rm -fr $outAnaDir`;
	`$Saxon outDir=$outDir -xsl:$Final $inAnaRoot`;
    }
    if ($procAll or $procTei) {
	print STDERR "INFO: *Finalizing $countryCode TEI\n";
	`rm -fr $outTeiDir`;
	`$Saxon anaDir=$outAnaDir outDir=$outDir -xsl:$Final $inTeiRoot`;
    }
    if ($procAll or $procSample) {
	print STDERR "INFO: *Making $countryCode samples\n";
	`rm -fr $outSmpDir`;
	`$Saxon outDir=$outSmpDir -xsl:$Sample $outTeiRoot`;
	`$Saxon outDir=$outSmpDir -xsl:$Sample $outAnaRoot`;
    }
    if ($procAll or $procAna) {
    	&polish($outAnaDir);
    }
    if ($procAll or $procTei) {
	&polish($outTeiDir);
    }
    if ($procAll or $procValid) {
	print STDERR "INFO: *Validating $countryCode TEI\n";
	`$Valid $schemaDir $outSmpDir`;
	`$Valid $schemaDir $outTeiDir`;
	`$Valid $schemaDir $outAnaDir`;
    }
    if ($procAll or $procTxt) {
	print STDERR "INFO: *Making $countryCode text\n";
	`rm -fr $outTxtDir; mkdir $outTxtDir`;
	`ls -dR $outTeiDir | grep '_' | $Paralel '$Saxon -xsl:$Texts {} > $outTxtDir/{/.}.txt'`;
	$files = "ls -dR $outTeiDir | grep '_'";
	`$files | $Paralel '$Saxon hdr=$outTeiRoot -xsl:$Metas {} > $outTxtDir/{/.}-meta.tsv'`;
    }
    if ($procAll or $procConll) {
	print STDERR "INFO: *Making $countryCode CoNLL-U\n";
	`rm -fr $outConlDir; mkdir $outConlDir`;
	`$Conls $outAnaDir $outConlDir`;
	$files = "ls -dR $outAnaDir | grep '_'";
	`$files | $Paralel '$Saxon hdr=$outTeiRoot -xsl:$Metas {} > $outConlDir/{/.}-meta.tsv'`;
    }
    if ($procAll or $procVert) {
	print STDERR "INFO: *Making $countryCode vert\n";
	`rm -fr $outVertDir; mkdir $outVertDir`;
	`$Verts $outAnaDir $outVertDir`;
    }
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
