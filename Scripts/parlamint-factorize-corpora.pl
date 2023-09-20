#!/usr/bin/perl
# Factorise all corpora given in inDir parameter
# 1. If not already present, make backup directories for all corpora and copy into them the original root files
# 2. Taking backup files as input overwrite original root files with factorised files
# 3. If a taxonomy is missing, add it from the pool of common taxonomies
use warnings;
use utf8;
use FindBin qw($Bin);
use File::Spec;

$taxonomyDir = shift;
$inDir = File::Spec->rel2abs(shift);

# Force overwriting of submitted taxonomies with common ones:
$taxonomies_TEI_force = 'parla.legislature speaker_types politicalOrientation subcorpus'; 
# Copy these from common taxonomies only of missing:
$taxonomies_TEI = 'CHES';
#Ditto for ana
$taxonomies_ana_force = 'UD-SYN.ana'; 
$taxonomies_ana = 'NER.ana';

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

$bkpName = "BKP";
$Saxon = 'java -jar /usr/share/java/saxon.jar';
$scriptFactorise  = "$Bin/parlamint-factorize-teiHeader.xsl";
$scriptTaxonomy= "$Bin/parlamint-init-taxonomy.xsl";

binmode(STDERR, 'utf8');

if ($inDir =~ /ParlaMint-[A-Z-]+\.TEI/) {$corpDirs = $inDir}
else {$corpDirs = "$inDir/ParlaMint-*.TEI*"}
foreach $corpDir (sort glob($corpDirs)) {
    my $param = '';
    ($country, $anaSuffix) = $corpDir =~ /ParlaMint-([A-Z-]+)\.TEI(\..+)?/ or die;
    $anaSuffix = '' unless $anaSuffix;
    print STDERR "INFO: Doing $country TEI$anaSuffix\n";
    $bkpDir = "$corpDir/$bkpName";
    
    # Make backup dir if necessary
    unless (-e $bkpDir) {
	print STDERR "INFO: Creating backup in $bkpDir\n";
	`mkdir $bkpDir`;
	`cp $corpDir/*.xml $bkpDir`
    }
    
    # Factorise
    if ($anaSuffix) {
	#For .ana we will also need the .TEI root file
        my $teiRoot = "$corpDir/ParlaMint-$country.xml";
	$teiRoot =~ s|\Q$anaSuffix\E||;
        if (-e $teiRoot){$param = " teiRoot=$teiRoot "}
	else {print STDERR "WARN: $teiRoot not found\n"}
    }
    $Prefix = "ParlaMint-$country-";
    `rm $corpDir/*.xml`;
    $command = "$Saxon outDir=$corpDir prefix=$Prefix $param -xsl:$scriptFactorise $bkpDir/ParlaMint-$country$anaSuffix.xml";
    # print STDERR "INFO: running $command\n";
    `$command`;

    # Insert common taxonomies, if any missing XInclude them
    @missing_taxonomies = ();
    if ($anaSuffix) {$taxonomies = "$taxonomies_TEI $taxonomies_TEI_force $taxonomies_ana $taxonomies_ana_force"}
    else {$taxonomies = "$taxonomies_TEI $taxonomies_TEI_force"}
    foreach $taxonomy (split(/ /, $taxonomies)) {
	$taxonomyFName = "ParlaMint-taxonomy-$taxonomy.xml";
	$CommonTaxonomyFile = "$taxonomyDir/$taxonomyFName";
	$taxonomyFile = "$corpDir/$taxonomyFName";
	die "FATAL ERROR: Cant find base taxonomy file $CommonTaxonomyFile\n" unless -e $CommonTaxonomyFile;
	if (not -e $taxonomyFile or
	    $taxonomies_TEI_force =~ /\Q$taxonomy\E/ or $taxonomies_ana_force =~ /\Q$taxonomy\E/) {
	    unless (-e $taxonomyFile) {
		print STDERR "WARN: Inserting missing taxonomy file $taxonomyFName\n";
		push(@missing_taxonomies, $taxonomyFName)
	    }
	    else {print STDERR "WARN: Inserting forced taxonomy file $taxonomyFName\n"}
	    my $command = "$Saxon if-lang-missing=skip langs='$country2lang{$country}' -xsl:$scriptTaxonomy";
	    `$command $CommonTaxonomyFile > $taxonomyFile`;
	}
    }
    if (@missing_taxonomies) {
	$rootFile = "$corpDir/ParlaMint-$country$anaSuffix.xml";
	die "FATAL ERROR: Cant find corpus root file $rootFile\n" unless -e $rootFile;
	$tmpRootFile = "$rootFile" . '.tmp';
	open(IN,  '<:utf8', $rootFile);
	open(OUT, '>:utf8', $tmpRootFile) or die "FATAL ERROR: Can't open tmp root file $tmpRootFile\n";
	while (<IN>) {
	    if (m|</classDecl>|) {
		foreach my $taxonomyFile (@missing_taxonomies) {
		    print OUT "           <xi:include xmlns:xi=\"http://www.w3.org/2001/XInclude\" ";
		    print OUT "href=\"$taxonomyFile\"/>\n"
		}
	    }
	    print OUT;
	}
	close IN;
	close OUT;
	`mv $tmpRootFile $rootFile`;
    }
}
