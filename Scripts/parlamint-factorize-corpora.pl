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

$taxonomies_TEI = 'parla.legislature speaker_types subcorpus politicalOrientation CHES';
$taxonomies_ana = 'NER.ana UD-SYN.ana';

# Mapping of countries to languages, we need it for mapping of common taxonomies
# Note we don't always (for UA, ES-XX) choose all the languages that the transcripts are in but only the local one
$country2lang{'AT'} = 'de';
$country2lang{'BA'} = 'bs';
$country2lang{'BE'} = 'fr nl';
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

foreach $corpDir (sort glob "$inDir/ParlaMint-*.TEI*") {
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
        my $teiRoot = "$inDir/ParlaMint-$country.TEI/ParlaMint-$country.xml";
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
    if ($anaSuffix) {$taxonomies = "$taxonomies_TEI $taxonomies_ana"}
    else {$taxonomies = $taxonomies_TEI}
    foreach $taxonomy (split(/ /, $taxonomies)) {
	$taxonomyFName = "ParlaMint-taxonomy-$taxonomy.xml";
	$InTaxonomyFile = "$taxonomyDir/$taxonomyFName";
	$taxonomyFile = "$corpDir/$taxonomyFName";
	die "FATAL: Cant find base taxonomy file $InTaxonomyFile\n" unless -e $InTaxonomyFile;
	unless (-e $taxonomyFile) {
	    print STDERR "WARN: Inserting missing taxonomy file $taxonomyFName\n";
	    push(@missing_taxonomies, $taxonomyFName);
	    my $command = "$Saxon if-lang-missing=skip langs='$country2lang{$country}' -xsl:$scriptTaxonomy";
	    `$command $InTaxonomyFile > $taxonomyFile`;
	}
    }
    if (@missing_taxonomies) {
	$rootFile = "$corpDir/ParlaMint-$country$anaSuffix.xml";
	die "FATAL: Cant find corpus root file $rootFile\n" unless -e $rootFile;
	$tmpRootFile = "$rootFile" . '.tmp';
	open(IN,  '<:utf8', $rootFile);
	open(OUT, '>:utf8', $tmpRootFile) or die "FATAL: Can't open tmp root file $tmpRootFile\n";
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
