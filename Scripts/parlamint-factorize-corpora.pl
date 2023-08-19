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

$bkpName = "BKP";
$Saxon = 'java -jar /usr/share/java/saxon.jar';
$Factorise  = "$Bin/parlamint-factorize-teiHeader.xsl";

binmode(STDERR, 'utf8');

foreach $corpDir (sort glob "$inDir/ParlaMint-*.TEI*") {
    my $param = '';
    ($Corpus, $anaSuffix) = $corpDir =~ /ParlaMint-([A-Z-]+)\.TEI(\..+)?/ or die;
    $anaSuffix = '' unless $anaSuffix;
    print STDERR "INFO: Doing $Corpus TEI$anaSuffix\n";
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
        my $teiRoot = "$inDir/ParlaMint-$Corpus.TEI/ParlaMint-$Corpus.xml";
        if (-e $teiRoot){$param = " teiRoot=$teiRoot "}
	else {print STDERR "WARN: $teiRoot not found\n"}
    }
    $Prefix = "ParlaMint-$Corpus-";
    `rm $corpDir/*.xml`;
    $command = "$Saxon outDir=$corpDir prefix=$Prefix $param -xsl:$Factorise $bkpDir/ParlaMint-$Corpus$anaSuffix.xml";
    # print STDERR "INFO: running $command\n";
    `$command`;

    # Take care of missing taxonomies
    @missing_taxonomies = ();
    if ($anaSuffix) {$taxonomies = "$taxonomies_TEI $taxonomies_ana"}
    else {$taxonomies = $taxonomies_TEI}
    foreach $taxonomy (split(/ /, $taxonomies)) {
	$taxonomyFName = "ParlaMint-taxonomy-$taxonomy.xml";
	$taxonomyFile = "$corpDir/$taxonomyFName";
	unless (-e $taxonomyFile) {
	    $InTaxonomyFile = "$taxonomyDir/$taxonomyFName";
	    print STDERR "WARN: Inserting missing taxonomy file $taxonomyFName\n";
	    die "FATAL: Cant find base taxonomy file $InTaxonomyFile\n" unless -e $InTaxonomyFile;
	    `cp $InTaxonomyFile $taxonomyFile`;
	    push(@missing_taxonomies, $taxonomyFName)
	}
    }
    next unless @missing_taxonomies;
    $rootFile = "$corpDir/ParlaMint-$Corpus$anaSuffix.xml";
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
