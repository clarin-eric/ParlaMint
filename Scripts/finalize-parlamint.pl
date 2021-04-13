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

sub usage {
    print STDERR ("Usage:\n");
    print STDERR ("finalize-parlamint.pl -help\n");
    print STDERR ("finalize-parlamint.pl [<procFlags>] -codes '<Codes>' -schema [<Schema>] -in <Input> -out <Output>\n");
    print STDERR ("    Finalizes ParlaMint corpora and produces derived encodings.\n");
    print STDERR ("    <Codes> is the list of country codes of the corpora to be processed.\n");
    print STDERR ("    <Input> is the directory where ParlaMint.TEI-XX/ and ParlaMint.TEI.ana-XX/ are.\n");
    print STDERR ("    <Output> is the directory where output directories are written.\n");
    print STDERR ("    <procFlags> are process flags that set which operations are carried out:\n");
    print STDERR ("    * -ana: finalizes the TEI.ana directory\n");
    print STDERR ("    * -tei: finalizes the TEI directory (needs TEI.ana output)\n");
    print STDERR ("    * -sample: prodeced samples (from TEI.ana and TEI output)\n");
    print STDERR ("    * -valid: validates TEI, TEI.ana and samples\n");
    print STDERR ("    * -txt: produces plain text files with metadata files (from TEI output)\n");
    print STDERR ("    * -conll: produces conllu files with metadata files (from TEI.ana output)\n");
    print STDERR ("    * -vert: produces vertical files (from TEI.ana output)\n");
    print STDERR ("    * -all: do all of the above.\n");
    print STDERR ("    The flags can be also negated, e.g. \"-all -novalid\".\n");
}

use Getopt::Long;
use FindBin qw($Bin);
use File::Spec;
use File::Copy;

my $procAll    = 0;
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
     'all'      => \$procAll,
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

#Execution
$Paralel = "parallel --gnu --halt 2 --jobs 15";
$Saxon   = "java -jar /usr/share/java/saxon.jar";
# Problem with Out of heap space with TR, NL, GB for ana
$SaxonX  = "java -Xmx90g -jar /usr/share/java/saxon.jar";

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

    if (($procAll and $procAna) or (!$procAll and $procAna == 1)) {
	print STDERR "INFO: *Finalizing $countryCode TEI.ana\n";
	`rm -fr $outAnaDir`;
	die "Can't find $inAnaRoot\n" unless -e $inAnaRoot; 
	`$SaxonX outDir=$outDir -xsl:$Final $inAnaRoot`;
    }
    if (($procAll and $procTei) or (!$procAll and $procTei == 1)) {
	print STDERR "INFO: *Finalizing $countryCode TEI\n";
	die "Can't find $inTeiRoot\n" unless -e $inTeiRoot; 
	`rm -fr $outTeiDir`;
	`$Saxon anaDir=$outAnaDir outDir=$outDir -xsl:$Final $inTeiRoot`;
    }
    if (($procAll and $procSample) or (!$procAll and $procSample == 1)) {
	print STDERR "INFO: *Making $countryCode samples\n";
	die "Can't find $outTeiRoot\n" unless -e $outTeiRoot; 
	`rm -fr $outSmpDir`;
	`$Saxon outDir=$outSmpDir -xsl:$Sample $outTeiRoot`;
	`$Saxon outDir=$outSmpDir -xsl:$Sample $outAnaRoot`;
    }
    if (($procAll and $procAna) or (!$procAll and $procAna == 1)) {
    	&polish($outAnaDir);
    }
    if (($procAll and $procTei) or (!$procAll and $procTei == 1)) {
	&polish($outTeiDir);
    }
    if (($procAll and $procValid) or (!$procAll and $procValid == 1)) {
	print STDERR "INFO: *Validating $countryCode TEI\n";
	`$Valid $schemaDir $outSmpDir`;
	`$Valid $schemaDir $outTeiDir`;
	`$Valid $schemaDir $outAnaDir`;
    }
    if (($procAll and $procTxt) or (!$procAll and $procTxt == 1)) {
	print STDERR "INFO: *Making $countryCode text\n";
	die "Can't find $outTeiDir\n" unless -e $outTeiDir; 
	`rm -fr $outTxtDir; mkdir $outTxtDir`;
	`ls -R $outTeiDir | grep '_' | $Paralel '$Saxon -xsl:$Texts $outTeiDir/{} > $outTxtDir/{/.}.txt'`;
	$files = "ls -R $outTeiDir | grep '_'";
	`$files | $Paralel '$Saxon hdr=$outTeiRoot -xsl:$Metas $outTeiDir/{} > $outTxtDir/{/.}-meta.tsv'`;
	&dirify($outTxtDir);
    }
    if (($procAll and $procConll) or (!$procAll and $procConll == 1)) {
	print STDERR "INFO: *Making $countryCode CoNLL-U\n";
	die "Can't find $outAnaDir\n" unless -e $outAnaDir; 
	`rm -fr $outConlDir; mkdir $outConlDir`;
	`$Conls $outAnaDir $outConlDir`;
	# Meta already produced by Conls!
	# my $command = "$Saxon hdr=$outTeiRoot -xsl:$Metas $outAnaDir/{} > $outConlDir/{/.}-meta.tsv";
	# `ls -R $outAnaDir | grep '_' | $Paralel '$command'`;
	#`rename 's/\.ana//' $outConlDir/*.ana-meta.tsv`;
	&dirify($outConlDir);
    }
    if (($procAll and $procVert) or (!$procAll and $procVert == 1)) {
	print STDERR "INFO: *Making $countryCode vert\n";
	die "Can't find $outAnaDir\n" unless -e $outAnaDir; 
	`rm -fr $outVertDir; mkdir $outVertDir`;
	`$Verts $outAnaDir $outVertDir`;
	&dirify($outVertDir);
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
#If a directory has more than $MAX files, store them in year directories
sub dirify {
    my $MAX = 1023;
    my $inDir = shift;
    my @files = glob("$inDir/*");
    if (scalar @files > $MAX) {
	foreach my $file (@files) {
	    if (my ($year) = $file =~ m|ParlaMint-.+?_(\d\d\d\d)|) {
		my $newDir = "$inDir/$year";
		mkdir($newDir) unless -d $newDir;
		move($file, $newDir);
	    }
	}
    }
}
