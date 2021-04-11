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
    print STDERR ("Usage:\n");
    print STDERR ("finalize-parlamint.pl -help\n");
    print STDERR ("finalize-parlamint.pl -codes '<Codes>' -schema [<Schema>] -in <Input> -out <Output>\n");
    print STDERR ("    Finalizes ParlaMint corpora and produces derived encodings.\n");
    print STDERR ("    <Codes> is the list of country codes of the corpora to be processed.\n");
    print STDERR ("    <Input> is the directory where ParlaMint.TEI-XX/ and ParlaMint.TEI.ana-XX/ are.\n");
    print STDERR ("    <Output> is the directory where output directories are written.\n");
    print STDERR ("    The script does the following:\n");
    print STDERR ("    * finalizes the TEI.ana directory\n");
    print STDERR ("    * finalizes the TEI directory\n");
    print STDERR ("    * prodces samples\n");
    print STDERR ("    * validates TEI, TEI.ana and samples\n");
    print STDERR ("    * produces plain text files with metadata files\n");
    print STDERR ("    * produces conllu files with metadata files\n");
    print STDERR ("    * produces vertical files.\n");
}
use Getopt::Long;
use FindBin qw($Bin);
use File::Spec;

my $procAll    = 1;
my $procAna    = 2;
my $procTei    = 2;
my $procSample = 2;
my $procValid  = 2;
my $procTxt    = 2;
my $procConll  = 2;
my $procVert   = 2;

GetOptions
    (
     'help'     => \$help,
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

if ($help) {
    &usage;
    exit;
}

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

    if ($procAll and $procAna) {
	print STDERR "INFO: *Finalizing $countryCode TEI.ana\n";
	`rm -fr $outAnaDir`;
	`$Saxon outDir=$outDir -xsl:$Final $inAnaRoot`;
    }
    if ($procAll and $procTei) {
	print STDERR "INFO: *Finalizing $countryCode TEI\n";
	`rm -fr $outTeiDir`;
	`$Saxon anaDir=$outAnaDir outDir=$outDir -xsl:$Final $inTeiRoot`;
    }
    if ($procAll and $procSample) {
	print STDERR "INFO: *Making $countryCode samples\n";
	`rm -fr $outSmpDir`;
	`$Saxon outDir=$outSmpDir -xsl:$Sample $outTeiRoot`;
	`$Saxon outDir=$outSmpDir -xsl:$Sample $outAnaRoot`;
    }
    if ($procAll and $procAna) {
    	&polish($outAnaDir);
    }
    if ($procAll and $procTei) {
	&polish($outTeiDir);
    }
    if ($procAll and $procValid) {
	print STDERR "INFO: *Validating $countryCode TEI\n";
	`$Valid $schemaDir $outSmpDir`;
	`$Valid $schemaDir $outTeiDir`;
	`$Valid $schemaDir $outAnaDir`;
    }
    if ($procAll and $procTxt) {
	print STDERR "INFO: *Making $countryCode text\n";
	`rm -fr $outTxtDir; mkdir $outTxtDir`;
	`ls -dR $outTeiDir | grep '_' | $Paralel '$Saxon -xsl:$Texts {} > $outTxtDir/{/.}.txt'`;
	$files = "ls -dR $outTeiDir | grep '_'";
	`$files | $Paralel '$Saxon hdr=$outTeiRoot -xsl:$Metas {} > $outTxtDir/{/.}-meta.tsv'`;
    }
    if ($procAll and $procConll) {
	print STDERR "INFO: *Making $countryCode CoNLL-U\n";
	`rm -fr $outConlDir; mkdir $outConlDir`;
	`$Conls $outAnaDir $outConlDir`;
	$files = "ls -dR $outAnaDir | grep '_'";
	`$files | $Paralel '$Saxon hdr=$outTeiRoot -xsl:$Metas {} > $outConlDir/{/.}-meta.tsv'`;
    }
    if ($procAll and $procVert) {
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
