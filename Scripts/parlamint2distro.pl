#!/usr/bin/env perl
# Make ParlaMint corpora ready for distribution:
# 1. Finalize input corpora (version, date, handle, extent)
# 2. Validate corpora
# 3. Produce derived formats
# For help on parameters do
# $ parlamint2distro.pl -h
# 
use warnings;
use utf8;
use open ':utf8';
use FindBin qw($Bin);
use File::Temp qw/ tempfile tempdir /;  #creation of tmp files and directory
my $tempdirroot = "$Bin/tmp";

mkdir($tempdirroot) unless(-d $tempdirroot);
my $tmpDir = tempdir(DIR => $tempdirroot, CLEANUP => 1);

binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

sub usage {
    print STDERR ("Usage:\n");
    print STDERR ("$0 -help\n");
    print STDERR ("$0 [<procFlags>] -codes '<Codes>' -version <Version> -teihandle <TeiHandle> -anahandle <AnaHandle>");
    print STDERR (" -schema [<Schema>] -docs [<Docs>] -in <Input> -out <Output>\n");
    print STDERR ("    Prepares ParlaMint corpora for distribution.\n");
    print STDERR ("    <Codes> is the list of country codes of the corpora to be processed.\n");
    print STDERR ("    <Schema> is the directory where ParlaMint RNG schemas are.\n");
    print STDERR ("    <Docs> is the directory where ParlaMint README files are.\n");
    print STDERR ("    <TeiHandle> is the handle of the plain text corpus.\n");
    print STDERR ("    <AnaHandle> is the handle of the linguistically annotated (.ana) corpus.\n");
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
    print STDERR ("    ./parlamint2distro.pl -all -novalid -codes 'BE ES' \\\n");
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
     'help'       => \$help,
     'codes=s'    => \$countryCodes,
     'schema=s'   => \$schemaDir,
     'docs=s'     => \$docsDir,
     'version=s'  => \$Version,
     'teihandle=s'=> \$handleTEI,
     'anahandle=s'=> \$handleAna,
     'in=s'       => \$inDir,
     'out=s'      => \$outDir,
     'all'        => \$procAll,
     'ana!'       => \$procAna,
     'tei!'       => \$procTei,
     'sample!'    => \$procSample,
     'valid!'     => \$procValid,
     'txt!'       => \$procTxt,
     'conll!'     => \$procConll,
     'vert!'      => \$procVert,
);

if ($help) {
    &usage;
    exit;
}

$schemaDir = File::Spec->rel2abs($schemaDir) if $schemaDir;
$docsDir = File::Spec->rel2abs($docsDir) if $docsDir;
$inDir = File::Spec->rel2abs($inDir) if $inDir;
$outDir = File::Spec->rel2abs($outDir) if $outDir;

#Execution
#$Parallel = "parallel --gnu --halt 2 --jobs 15";
$Saxon   = "java -jar $Bin/bin/saxon.jar";
# Problem with Out of heap space with TR, NL, GB for ana
$SaxonX  = "java -Xmx240g -jar $Bin/bin/saxon.jar";

# For the following taxonomies we substitute the local taxonomy with common one,
# reduced to the relevant langauges
# We are assuming taxonomies are relative to the Scripts/ (i.e. $Bin/) directory
$taxonomyDir = "$Bin/../Build/Taxonomies";
$taxonomy{'ParlaMint-taxonomy-parla.legislature'}    = "$taxonomyDir/ParlaMint-taxonomy-parla.legislature.xml";
$taxonomy{'ParlaMint-taxonomy-politicalOrientation'} = "$taxonomyDir/ParlaMint-taxonomy-politicalOrientation.xml";
$taxonomy{'ParlaMint-taxonomy-speaker_types'}        = "$taxonomyDir/ParlaMint-taxonomy-speaker_types.xml";
$taxonomy{'ParlaMint-taxonomy-subcorpus'}            = "$taxonomyDir/ParlaMint-taxonomy-subcorpus.xml";
$taxonomy{'ParlaMint-taxonomy-NER.ana'}              = "$taxonomyDir/ParlaMint-taxonomy-NER.ana.xml";
#We do not translate these two:
#$taxonomy{'ParlaMint-taxonomy-CHES'}                 = "$taxonomyDir/ParlaMint-taxonomy-CHES.xml";
#$taxonomy{'ParlaMint-taxonomy-UD-SYN.ana'}           = "$taxonomyDir/ParlaMint-taxonomy-UD-SYN.ana.xml";
  
# Mapping of countries to languages, we need it for mapping of common taxonomies
$country2lang{'AT'} = 'de';
$country2lang{'BA'} = 'bs';
$country2lang{'BE'} = 'nl';
$country2lang{'BG'} = 'bg';
$country2lang{'CZ'} = 'cs';
$country2lang{'DK'} = 'da';
$country2lang{'EE'} = 'et';
$country2lang{'ES'} = 'es';
$country2lang{'ES-CT'} = 'ca';
$country2lang{'ES-GA'} = 'gl';
$country2lang{'ES-PV'} = 'eu';
$country2lang{'FI'} = 'fi';
$country2lang{'FR'} = 'fr';
$country2lang{'GB'} = 'en';
$country2lang{'GR'} = 'el';
$country2lang{'HR'} = 'hr';
$country2lang{'HU'} = 'hu';
$country2lang{'IS'} = 'is';
$country2lang{'IT'} = 'it';
$country2lang{'LT'} = 'lt';
$country2lang{'LV'} = 'lv';
$country2lang{'NL'} = 'nl';
$country2lang{'NO'} = 'no';
$country2lang{'PL'} = 'pl';
$country2lang{'PT'} = 'pt';
$country2lang{'RO'} = 'ro';
$country2lang{'RS'} = 'sr';
$country2lang{'SE'} = 'sv';
$country2lang{'SI'} = 'sl';
$country2lang{'TR'} = 'tr';
$country2lang{'UA'} = 'uk'; 
# Fake country for testing:
$country2lang{'XX'} = 'hr'; 

$scriptRelease = "$Bin/parlamint2release.xsl";
$scriptCommon  = "$Bin/parlamint-add-common-content.xsl";
$scriptTaxonomy= "$Bin/parlamint-init-taxonomy.xsl";
$scriptPolish  = "$Bin/polish-xml.pl";
$scriptValid   = "$Bin/validate-parlamint.pl";
$scriptSample  = "$Bin/corpus2sample.xsl";
$scriptTexts   = "$Bin/parlamintp-tei2text.pl";
$scriptVerts   = "$Bin/parlamintp-tei2vert.pl";
$scriptConls   = "$Bin/parlamintp2conllu.pl";

$XX_template = "ParlaMint-XX";

my $cmd;

unless ($countryCodes) {
    print STDERR "Need some country codes.\n";
    print STDERR "For help: parlamint2distro.pl -h\n";
    exit
}
foreach my $countryCode (split(/[, ]+/, $countryCodes)) {
    print STDERR "INFO: *****Converting $countryCode (" . localtime(). ")\n";

    # Is this an MTed corpus?
    if ($countryCode =~ m/-([a-z]{2,3})$/) {$MT = $1}
    else {$MT = 0}

    my $XX = $XX_template;
    $XX =~ s|XX|$countryCode|g;

    my $teiDir  = "$XX.TEI";
    my $anaDir  = "$XX.TEI.ana";
    
    my $teiRoot = "$teiDir/$XX.xml";
    my $anaRoot = "$anaDir/$XX.ana.xml";

    my $inTeiDir = "$inDir/$teiDir" if $inDir;
    my $inAnaDir = "$inDir/$anaDir" if $inDir;

    my $listOrg    = "$XX-listOrg.xml";
    my $listPerson = "$XX-listPerson.xml";
    my $taxonomies = "*-taxonomy-*.xml";
    
    my $inTeiRoot = "$inDir/$teiRoot" if $inDir;
    my $inAnaRoot = "$inDir/$anaRoot" if $inDir;

    #In case input dir is for samples remove .TEI(.ana)
    if ($inTeiRoot) {
        unless (-e $inTeiRoot) {
            my $altTeiRoot = $inTeiRoot;
            $altTeiRoot =~ s/\.TEI// ;
            print STDERR "WARN: Can't find input TEI root $inTeiRoot, trying sample $altTeiRoot\n";
            unless (-e $altTeiRoot) {die "FATAL: Can't find $altTeiRoot\n"}
            else {$inTeiRoot = $altTeiRoot}
        }
    }
    if ($inAnaRoot) {
        unless (-e $inAnaRoot) {
            my $altAnaRoot = $inAnaRoot;
            $altAnaRoot =~ s/\.TEI\.ana// ;
            print STDERR "WARN: Can't find input TEI root $inAnaRoot, trying sample $altAnaRoot\n";
            unless (-e $altAnaRoot) {die "FATAL: Can't find $altAnaRoot\n"}
            else {$inAnaRoot = $altAnaRoot}
        }
    }
    
    my $outTeiDir  = "$outDir/$teiDir";      # $outTeiDir   =~ s/$XX/-$MT/ if $MT;
    my $outTeiRoot = "$outDir/$teiRoot";     # $outTeiRoot  =~ s/$XX/-$MT/ if $MT;
    my $outAnaDir  = "$outDir/$anaDir";      # $outAnaDir   =~ s/$XX/-$MT/ if $MT;
    my $outAnaRoot = "$outDir/$anaRoot";     # $outAnaRoot  =~ s/$XX/-$MT/ if $MT;
    my $outSmpDir  = "$outDir/$XX";          # $outSmpDir   =~ s/$XX/-$MT/ if $MT;
    my $outTxtDir  = "$outDir/$XX.txt";      # $outTxtDir   =~ s/$XX/-$MT/ if $MT;
    my $outConlDir = "$outDir/$XX.conllu";   # $outConlDir  =~ s/$XX/-$MT/ if $MT;
    my $outVertDir = "$outDir/$XX.vert";     # $outVertDir  =~ s/$XX/-$MT/ if $MT;

    # Location, name and extention of registry files, need $Version to compute it!
    if ($Version) {
	$regiDir = $docsDir . '/registry';
	$vertRegi = 'parlamint' . $Version . '_' . lc $countryCode;
	$vertRegi =~ s/\.//g;   #e.g. 3.1 -> 31, so we will get e.g. parlamint31_at
	$vertRegi =~ s/-/_/g;  #e.g. parlamint31_es-ct.regi to parlamint31_es_ct
	$regiExt = 'regi'
    }
    
    if (($procAll and $procAna) or (!$procAll and $procAna == 1)) {
	print STDERR "INFO: ***Finalizing $countryCode TEI.ana\n";
	die "FATAL ERROR: Need version\n" unless $Version;
	die "FATAL ERROR: Can't find input ana root $inAnaRoot\n" unless -e $inAnaRoot;
	die "FATAL ERROR: No handle given for ana distribution\n" unless $handleAna;
	# Output top level readme
	&cp_readme_top($countryCode, $MT, 'ana', $handleAna, $Version, $docsDir, $outDir);
	`rm -fr $outAnaDir; mkdir $outAnaDir`;
	if ($MT) {$inReadme = "$docsDir/README-$MT.TEI.ana.txt"}
	else {$inReadme = "$docsDir/README.TEI.ana.txt"}
	die "FATAL ERROR: No handle given for TEI.ana distribution\n" unless $handleAna;
	&cp_readme($countryCode, $handleAna, $Version, $inReadme, "$outAnaDir/00README.txt");
	die "FATAL ERROR: Can't find schema directory\n" unless $schemaDir and -e $schemaDir;
	dircopy($schemaDir, "$outAnaDir/Schema");
	# Remove unwanted files
	`rm -fr $outAnaDir/Schema/.git*`;
	`rm -f $outAnaDir/Schema/nohup.*`;
	`rm -f $outAnaDir/Schema/*.log`;
	`rm -f $outAnaDir/Schema/Makefile`;
	my $tmpOutDir = "$tmpDir/release.ana";
	my $tmpOutAnaDir = "$tmpDir/$anaDir";
	my $tmpAnaRoot = "$tmpOutDir/$anaRoot";
	print STDERR "INFO: ***Fixing TEI.ana corpus for release\n";
    $cmd = "$SaxonX outDir=$tmpOutDir -xsl:$scriptRelease $inAnaRoot";
    `$cmd`;
    print STDERR "FATAL ERROR: $cmd exited with $?\n" if $?;
	print STDERR "INFO: ***Adding common content to TEI.ana corpus\n";
	$cmd = "$SaxonX version=$Version handle-ana=$handleAna anaDir=$outAnaDir outDir=$outDir -xsl:$scriptCommon $tmpAnaRoot";
    `$cmd`;
    print STDERR "FATAL ERROR: $cmd exited with $?\n" if $?;
    &commonTaxonomies($countryCode, $outAnaDir);
    	&polish($outAnaDir);
    }
    if (($procAll and $procTei) or (!$procAll and $procTei == 1)) {
	print STDERR "INFO: ***Finalizing $countryCode TEI\n";
	die "FATAL ERROR: Need version\n" unless $Version;
	die "FATAL ERROR: Can't find input tei root $inTeiRoot\n" unless -e $inTeiRoot; 
	die "FATAL ERROR: No handle given for TEI distribution\n" unless $handleTEI;
	# Output top level readme
	&cp_readme_top($countryCode, $MT, 'tei', $handleTEI, $Version, $docsDir, $outDir);
	`rm -fr $outTeiDir; mkdir $outTeiDir`;
	if ($MT) {$inReadme = "$docsDir/README-$MT.TEI.txt"}
	else {$inReadme = "$docsDir/README.TEI.txt"}
	&cp_readme($countryCode, $handleTEI, $Version, $inReadme, "$outTeiDir/00README.txt");
	die "FATAL ERROR: Can't find schema directory\n" unless $schemaDir and -e $schemaDir;
	dircopy($schemaDir, "$outTeiDir/Schema");
	`rm -f $outTeiDir/Schema/.*`;
	`rm -f $outTeiDir/Schema/nohup.*`;
	`rm -f $outTeiDir/Schema/*.log`;
	`rm -f $outTeiDir/Schema/Makefile`;
	my $tmpOutDir = "$tmpDir/release.tei";
	my $tmpOutTeiDir = "$tmpDir/$teiDir";
	my $tmpTeiRoot = "$tmpOutDir/$teiRoot";
	print STDERR "INFO: ***Fixing TEI corpus for release\n";
	$cmd = "$SaxonX anaDir=$outAnaDir outDir=$tmpOutDir -xsl:$scriptRelease $inTeiRoot";
	`$cmd`;
        print STDERR "FATAL ERROR: $cmd exited with $?\n" if $?;
        print STDERR "INFO: ***Adding common content to TEI corpus\n";
	$cmd = "$SaxonX version=$Version handle-txt=$handleTEI anaDir=$outAnaDir outDir=$outDir -xsl:$scriptCommon $tmpTeiRoot";
	`$cmd`;
        print STDERR "FATAL ERROR: $cmd exited with $?\n" if $?;
        &commonTaxonomies($countryCode, $outTeiDir);
	&polish($outTeiDir);
    }
    if (($procAll and $procSample) or (!$procAll and $procSample == 1)) {
	print STDERR "INFO: ***Making $countryCode samples\n";
	`rm -fr $outSmpDir; mkdir $outSmpDir`;
	if (-e $outTeiRoot) {
	    `$Saxon outDir=$outSmpDir -xsl:$scriptSample $outTeiRoot`;
	    `$scriptTexts $outSmpDir $outSmpDir`;
	}
	else {print STDERR "WARN: No TEI files for $countryCode samples (needed root file is $outTeiRoot)\n"}
	if (-e $outAnaRoot) {
	    `$Saxon outDir=$outSmpDir -xsl:$scriptSample $outAnaRoot`;
	    #Make also derived files
	    `$scriptTexts $outSmpDir $outSmpDir` unless $outTeiRoot;
	    `$scriptVerts $outSmpDir $outSmpDir`;
	    if (-e "$regiDir/$vertRegi") {`cp $regiDir/$vertRegi $outSmpDir/$vertRegi.$regiExt`}
	    else {print STDERR "WARN: registry file $vertRegi not found\n"}
	    `$scriptConls $outSmpDir $outSmpDir`
	}
	else {print STDERR "ERROR: No .ana files for $countryCode samples (needed root file is $outAnaRoot)\n"}
	#For some reason both ParlaMint-XX_YYY-MM-DD-meta-en.tsv and ParlaMint-XX_YYY-MM-DD.ana-meta-en.tsv
	#are present in Sample directory, remove the .ana variant:
	`rm -f $outSmpDir/*.ana-meta-en.tsv`;
	# Output top level readme but not for $MTed version, as it would overwrite the original
	# The Sample readme does not have handle or version, as the sample can change irrespective of them
	&commonTaxonomies($countryCode, $outSmpDir);
	&cp_readme_top($countryCode, '', 'sample', '', '', $docsDir, $outSmpDir)
	    unless $MT;
	&polish($outSmpDir);
        &dirify($outSmpDir);
    }
    if (($procAll and $procValid) or (!$procAll and $procValid == 1)) {
	print STDERR "INFO: ***Validating $countryCode TEI\n";
	die "FATAL ERROR: Can't find schema directory\n" unless $schemaDir and -e $schemaDir;
	`$scriptValid $schemaDir $outSmpDir` if -e $outSmpDir; 
	`$scriptValid $schemaDir $outTeiDir` if -e $outTeiDir;
	`$scriptValid $schemaDir $outAnaDir` if -e $outAnaDir;
    }
    if (($procAll and $procTxt) or (!$procAll and $procTxt == 1)) {
	print STDERR "INFO: ***Making $countryCode text\n";
	# We have an oportunistic handle, could be $handleTEI or $handleAna, depending on which one exists
	if    ($handleTEI) {$handleTxt = $handleTEI}
	elsif ($handleAna) {$handleTxt = $handleAna}
	else {die "FATAL ERROR: No handle given for TEI or .ana distribution\n"}
	`rm -fr $outTxtDir; mkdir $outTxtDir`;
	if ($MT) {$inReadme = "$docsDir/README-$MT.text.txt"}
	else {$inReadme = "$docsDir/README.text.txt"}
	&cp_readme($countryCode, $handleTxt, $Version, $inReadme, "$outTxtDir/00README.txt");
	if    (-e $outTeiDir) {`$scriptTexts $outTeiDir $outTxtDir`}
	elsif (-e $outAnaDir) {`$scriptTexts $outAnaDir $outTxtDir`}
	else {die "FATAL ERROR: Neither $outTeiDir nor $outAnaDir exits\n"}
	&dirify($outTxtDir);
    }
    if (($procAll and $procConll) or (!$procAll and $procConll == 1)) {
	print STDERR "INFO: ***Making $countryCode CoNLL-U\n";
	die "FATAL ERROR: Can't find input ana dir $outAnaDir\n" unless -e $outAnaDir; 
	die "FATAL ERROR: No handle given for ana distribution\n" unless $handleAna;
	`rm -fr $outConlDir; mkdir $outConlDir`;
	if ($MT) {$inReadme = "$docsDir/README-$MT.conll.txt"}
	else {$inReadme = "$docsDir/README.conll.txt"}
	&cp_readme($countryCode, $handleAna, $Version, $inReadme, "$outConlDir/00README.txt");
	`$scriptConls $outAnaDir $outConlDir`;
	&dirify($outConlDir);
    }
    if (($procAll and $procVert) or (!$procAll and $procVert == 1)) {
	print STDERR "INFO: ***Making $countryCode vert\n";
	die "FATAL ERROR: Can't find input ana dir $outAnaDir\n" unless -e $outAnaDir; 
	die "FATAL ERROR: No handle given for ana distribution\n" unless $handleAna;
	`rm -fr $outVertDir; mkdir $outVertDir`;
	if ($MT) {$inReadme = "$docsDir/README-$MT.vert.txt"}
	else {$inReadme = "$docsDir/README.vert.txt"}
	&cp_readme($countryCode, $handleAna, $Version, $inReadme, "$outVertDir/00README.txt");
	if (-e "$regiDir/$vertRegi") {`cp $regiDir/$vertRegi $outVertDir/$vertRegi.$regiExt`}
	else {print STDERR "WARN: registry file $vertRegi not found\n"}
	`$scriptVerts $outAnaDir $outVertDir`;
	&dirify($outVertDir);
    }
    print STDERR "INFO: ***Finished processing $countryCode corpus.\n";
}

# Substitute local with common taxonomies & reduce languages to en + corpus one(s)
sub commonTaxonomies {
    my $Country = shift;
    my $outDir = shift;
    # If this is an MTed corpus then fix Country to be without langauge suffix
    $Country =~ s/-[a-z]{2}$//;
    foreach my $taxonomy (sort keys %taxonomy) {
	if ($taxonomy !~ /\.ana/ or
	    ($taxonomy =~ /\.ana/ and ($outDir =~ /\.ana/ or $outDir !~ /\.TEI/))) {
	    if (-e $taxonomy{$taxonomy}) {
                if (exists($country2lang{$Country})) { 
                    my $command = "$Saxon if-lang-missing=skip langs='$country2lang{$Country}' -xsl:$scriptTaxonomy";
                    `$command $taxonomy{$taxonomy} > $outDir/$taxonomy.xml`;
                }
                else {
                    die "FATAL: Can't find mapping between country code and language: ".
                        "pls. add \$country2lang{'$Country'} to parlamint2distro.pl!\n"
                }
	    }
	    else {print STDERR "ERROR: Can't find common taxonomy $taxonomy at $taxonomy{$taxonomy}\n"}
	}
    }
    return 1;
}

#Format XML file to be a bit nicer & smaller
sub polish {
    my $dir = shift;
    foreach my $file (glob("$dir/*.xml $dir/*/*.xml")) {
	`$scriptPolish < $file > $file.tmp`;
	rename("$file.tmp", $file); 
    }
}

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
		move($file, $newDir);
	    }
	}
    }
}

#Read in the appropriate top level $inFile README, modify it and output it $outFile
sub cp_readme_top {
    my $country = shift;
    my $mt = shift;
    my $type = shift;
    my $handle  = shift;
    my $version = shift;
    my $inDir  = shift;
    my $outDir = shift;
    my $countryName; # Country name obtained from existing README
    my $countryCode; # Country code obtained from existing README
    my $RegionalSuffix; #Not used
    die "FATAL ERROR: No country for cp_readme_top\n" unless $country;
    die "FATAL ERROR: No handle for cp_readme_top\n" unless $handle or $type eq 'sample';
    die "FATAL ERROR: No version for cp_readme_top\n" unless $version or $type eq 'sample';
    my $inFile = "$inDir/README.md/README-$country.md";
    $inFile =~ s|-$mt|| if $mt; #Need to remove e.g. '-en' from input readme, as we don't have such input files

    # Construct output filename: in sample it is just README.md, other types add on a suffix
    my $outFile = "$outDir/README";
    if ($type eq 'sample') {}
    elsif ($type eq 'ana' or $type eq 'tei') {$outFile .= "-" . $country }
    if ($type eq 'ana') {$outFile .= ".ana"}
    $outFile .= ".md";
    
    open IN, '<:utf8', $inFile or die "FATAL ERROR: Can't open input top README $inFile\n";
    open OUT,'>:utf8', $outFile or die "FATAL ERROR: Can't open output top README $outFile\n";
    # Input:  # ParlaMint directory for samples of country AT (Austria)
    # Output depends on $type, $MT, and $country:
    # sample: # Samples of the ParlaMint-AT corpus
    # en-smp: # Samples of the ParlaMint-AT corpus (translation to English)
    # TEI:    # Corpus of parliamentary debates ParlaMint-AT
    # ana:    # Linguistically annotated corpus of parliamentary debates ParlaMint-AT.ana
    # en-TEI: # Corpus of parliamentary debates, ParlaMint-AT-en (translation to English)
    # en-ana: # Linguistically annotated corpus of parliamentary debates ParlaMint-AT-en.ana (translation to English)

    while (<IN>) {
	if (m|# ParlaMint|) {
	    ($countryCode, $RegionalSuffix, $countryName) = m| ([A-Z]{2}(-[A-Z]{2})?) \((.+)\)$|
	       or die "FATAL ERROR: Bad line in README.md file: $_";
	    die "FATAL ERROR: Bad code $countryCode (!= $country) in $inFile\n" unless $country =~ /$countryCode/;
	    if    ($type =~ /sample/i) {print OUT "# Samples of the ParlaMint-$countryCode corpus"}
	    elsif ($type =~ /tei/i)    {print OUT "# Corpus of parliamentary debates ParlaMint-$countryCode"}
	    elsif ($type =~ /ana/i)    {print OUT "# Linguistically annotated corpus of parliamentary debates ParlaMint-$countryCode"}
	    else {die "Strange type $type for cp_readme_top\n"}
	    if ($MT) {print OUT "-en (translation to English)"}
	    print OUT "\n";
	}
	elsif (m|- +Language|) {
	    if    ($countryCode =~ /^..-..$/) {print OUT "- Autonomous region: "}
	    elsif ($countryCode =~ /^..$/)    {print OUT "- Country: "}
	    else {die "Strange country code $countryCode for cp_readme_top\n"}
	    print OUT "$countryCode ($countryName)\n";
            # Language
	    if ($MT) {print OUT "en (English) from "}
	    print OUT; 
	    unless ($type eq 'sample') {
		print OUT "- Version: $version\n";
		print OUT "- Handle: [$handle]($handle)\n";
	    }
	}
	else {print OUT}
    }
    close IN;
    close OUT;
}

#Read in the appropriate $inFile README, change XX in it to country code, and output it $outFile
sub cp_readme {
    my $country = shift;
    my $handle  = shift;
    my $version = shift;
    my $inFile  = shift;
    my $outFile = shift;
    die "FATAL ERROR: No country for cp_readme\n" unless $country;
    die "FATAL ERROR: No handle for cp_readme\n" unless $handle;
    die "FATAL ERROR: No version for cp_readme\n" unless $version;
    open IN, '<:utf8', $inFile or die "FATAL ERROR: Can't open input README $inFile\n";
    open OUT,'>:utf8', $outFile or die "FATAL ERROR: Can't open output README $outFile\n";
    while (<IN>) {
	s/XX/$country/g;
	s/YY/$handle/g;
	s/ZZ/$version/g;
	print OUT
    }
    close IN;
    close OUT;
}
