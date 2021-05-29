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
    print STDERR ("$0 -help\n");
    print STDERR ("$0 [<procFlags>] -codes '<Codes>' -schema [<Schema>] -docs [<Docs>]");
    print STDERR (" -in <Input> -out <Output>\n");
    print STDERR ("    Finalizes ParlaMint corpora and produces derived encodings.\n");
    print STDERR ("    <Codes> is the list of country codes of the corpora to be processed.\n");
    print STDERR ("    <Schema> is the directory where ParlaMint RNG schemas are.\n");
    print STDERR ("    <Docs> is the directory where ParlaMint README files are.\n");
    print STDERR ("    <Input> is the directory where ParlaMint-XX.TEI/ and ParlaMint-XX.TEI.ana/ are.\n");
    print STDERR ("    <Output> is the directory where output directories are written.\n");
    
    print STDERR ("    <procFlags> are process flags that set which operations are carried out:\n");
    print STDERR ("    * -ana: finalizes the TEI.ana directory\n");
    print STDERR ("    * -tei: finalizes the TEI directory (needs TEI.ana output)\n");
    print STDERR ("    * -sample: produces samples (from TEI.ana and TEI output)\n");
    print STDERR ("    * -valid: validates TEI, TEI.ana and samples\n");
    print STDERR ("    * -vert: produces vertical files (from TEI.ana output)\n");
    print STDERR ("    * -txt: produces plain text files with metadata files (from TEI output)\n");
    print STDERR ("    * -conll: produces conllu files with metadata files (from TEI.ana output)\n");
    print STDERR ("    * -all: do all of the above.\n");
    print STDERR ("    The flags can be also negated, e.g. \"-all -novalid\".\n");
    print STDERR ("    Example: \n");
    print STDERR ("    ./finalize-parlamint.pl -all -novalid -codes 'BE ES' \\\n");
    print STDERR ("      -schema ../Schema -docs My/Docs/ -in Originals/ -out Final/  \\\n");
    print STDERR ("      2> ParlaMint.ana.log\n");
}

use Getopt::Long;
use FindBin qw($Bin);
use File::Spec;
use File::Copy;
use File::Copy::Recursive qw(dircopy);

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
     'docs=s'   => \$docsDir,
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
$docsDir = File::Spec->rel2abs($docsDir);
$inDir = File::Spec->rel2abs($inDir);
$outDir = File::Spec->rel2abs($outDir);

#Execution
#$Parallel = "parallel --gnu --halt 2 --jobs 15";
$Saxon   = "java -jar /usr/share/java/saxon.jar";
# Problem with Out of heap space with TR, NL, GB for ana
$SaxonX  = "java -Xmx120g -jar /usr/share/java/saxon.jar";

$Final   = "$Bin/parlamint2final.xsl";
$Polish  = "$Bin/polish-xml.pl";
$Valid   = "$Bin/validate-parlamint.pl";
$Sample  = "$Bin/corpus2sample.xsl";
$Texts   = "$Bin/parlamintp-tei2text.pl";
$Verts   = "$Bin/parlamintp-tei2vert.pl";
$Conls   = "$Bin/parlamintp2conllu.pl";

$XX_template = "ParlaMint-XX";

unless ($countryCodes) {
    print STDERR "Need some country codes.\n";
    print STDERR "For help: finalize-parlamint.pl -h\n";
    exit
}
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
    $outConlDir = "$outDir/$XX.conllu";
    $outVertDir = "$outDir/$XX.vert";
    #$vertRegi   = lc "parlamint20_$countryCode.regi";
    $vertRegi   = lc "parlamint21_$countryCode.regi";
	
    if (($procAll and $procAna) or (!$procAll and $procAna == 1)) {
	print STDERR "INFO: *Finalizing $countryCode TEI.ana\n";
	die "Can't find $inAnaRoot\n" unless -e $inAnaRoot;
	`rm -fr $outAnaDir; mkdir $outAnaDir`;
	&cp_readme($countryCode, "$docsDir/README.TEI.ana.txt", "$outAnaDir/00README.txt");
	dircopy($schemaDir, "$outAnaDir/Schema");
	`rm -f $outAnaDir/Schema/.gitignore`;
	`rm -f $outAnaDir/Schema/nohup.*`;
	`$SaxonX outDir=$outDir -xsl:$Final $inAnaRoot`;
    	&polish($outAnaDir);
    }
    if (($procAll and $procTei) or (!$procAll and $procTei == 1)) {
	print STDERR "INFO: *Finalizing $countryCode TEI\n";
	die "Can't find $inTeiRoot\n" unless -e $inTeiRoot; 
	`rm -fr $outTeiDir; mkdir $outTeiDir`;
	&cp_readme($countryCode, "$docsDir/README.TEI.txt", "$outTeiDir/00README.txt");
	dircopy($schemaDir, "$outTeiDir//Schema");
	`$SaxonX anaDir=$outAnaDir outDir=$outDir -xsl:$Final $inTeiRoot`;
	&polish($outTeiDir);
    }
    if (($procAll and $procSample) or (!$procAll and $procSample == 1)) {
	print STDERR "INFO: *Making $countryCode samples\n";
	die "Can't find $outTeiRoot\n" unless -e $outTeiRoot; 
	`rm -fr $outSmpDir`;
	`$Saxon outDir=$outSmpDir -xsl:$Sample $outTeiRoot`;
	if (-e $outAnaRoot) {
	    `$Saxon outDir=$outSmpDir -xsl:$Sample $outAnaRoot`;
	    #Make also derived files
	    `$Verts $outSmpDir $outSmpDir`;
	    `$Conls $outSmpDir $outSmpDir`
	}
	else {
	    print STDERR "WARN: No .ana files for $countryCode samples\n";
	}
	`$Texts $outSmpDir $outSmpDir`;
    }
    if (($procAll and $procValid) or (!$procAll and $procValid == 1)) {
	print STDERR "INFO: *Validating $countryCode TEI\n";
	die "Can't find schema directory $schemaDir\n" unless -e $schemaDir;
	`$Valid $schemaDir $outSmpDir`;
	`$Valid $schemaDir $outTeiDir`;
	`$Valid $schemaDir $outAnaDir`;
    }
    if (($procAll and $procTxt) or (!$procAll and $procTxt == 1)) {
	print STDERR "INFO: *Making $countryCode text\n";
	die "Can't find $outTeiDir\n" unless -e $outTeiDir; 
	`rm -fr $outTxtDir; mkdir $outTxtDir`;
	&cp_readme($countryCode, "$docsDir/README.txt.txt", "$outTxtDir/00README.txt");
	`$Texts $outTeiDir $outTxtDir`;
	&dirify($outTxtDir);
    }
    if (($procAll and $procConll) or (!$procAll and $procConll == 1)) {
	print STDERR "INFO: *Making $countryCode CoNLL-U\n";
	die "Can't find $outAnaDir\n" unless -e $outAnaDir; 
	`rm -fr $outConlDir; mkdir $outConlDir`;
	&cp_readme($countryCode, "$docsDir/README.conll.txt", "$outConlDir/00README.txt");
	`$Conls $outAnaDir $outConlDir`;
	&dirify($outConlDir);
    }
    if (($procAll and $procVert) or (!$procAll and $procVert == 1)) {
	print STDERR "INFO: *Making $countryCode vert\n";
	die "Can't find $outAnaDir\n" unless -e $outAnaDir; 
	`rm -fr $outVertDir; mkdir $outVertDir`;
	&cp_readme($countryCode, "$docsDir/README.vert.txt", "$outVertDir/00README.txt");
	`cp "$docsDir/$vertRegi" $outVertDir`;
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

#Read in the appropriate README and output it to appropriate directory
sub cp_readme {
    my $country = shift;
    my $inFile = shift;
    my $outFile = shift;
    open IN, '<:utf8', $inFile or die "Can't open input README $inFile\n";
    open OUT,'>:utf8', $outFile or die "Can't open output README $outFile\n";
    while (<IN>) {
	s/XX/$country/g;
	print OUT
    }
    close IN;
    close OUT;
}
