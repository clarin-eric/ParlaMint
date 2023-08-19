#!/usr/bin/perl
# Add TSV metadata to TEI corpora
use warnings;
use utf8;
use FindBin qw($Bin);
use File::Spec;
use File::Temp qw/ tempfile tempdir /;  #creation of tmp files and directory
my $tempdirroot = "$Bin/tmp";
my $tmpDir = tempdir(DIR => $tempdirroot, CLEANUP => 1);

$orieDir = File::Spec->rel2abs(shift);
$miniDir = File::Spec->rel2abs(shift);
$inDirs  = File::Spec->rel2abs(shift);
$outDir  = File::Spec->rel2abs(shift);

$Saxon = 'java -jar /usr/share/java/saxon.jar';

# Scripts that add info to listOrg
$encoScript = "$Bin/enco-tsv2tei.xsl";
$chesScript = "$Bin/ches-tsv2tei.xsl";
$wikiScript = "$Bin/wiki-tsv2tei.xsl";

# Scripts that add info to listPerson
$miniScript = "$Bin/ministers-tsv2tei.xsl";

# Script that makes XML prettier
$poliScript = "$Bin/polish-xml.pl";

$oriePrefix  = 'Orientation-';
$encoSuffix = '.enco.tsv';
$chesSuffix = '.CHES.tsv';
$wikiSuffix = '.Wiki.tsv';

$miniPrefix  = 'Ministers-';
$miniSuffix  = '.edited.tsv';

binmode(STDERR, 'utf8');

foreach $inCorpDir (sort glob $inDirs) {
    ($country, $anaSuffix) = $inCorpDir =~ /ParlaMint-([A-Z-]+)\.TEI(\..+)?/ or die;
    $anaSuffix = '' unless $anaSuffix;
    print STDERR "INFO: Doing $country TEI$anaSuffix\n";
    $outCorpDir = "$outDir/ParlaMint-$country.TEI$anaSuffix";
    die "FATAL: Can't find output directory $outCorpDir\n" unless -e $outCorpDir;

    # Copy all XML files, will overwrite the relevant listOrg and listPerson in &process
    foreach $xmlFile (glob "$inCorpDir/*.xml") {
	($fName) = $xmlFile =~ m|([^/]+)$|;
	`$poliScript < $xmlFile > $outCorpDir/$fName`;
    }

    &process('encoder', 
	     "$inCorpDir/ParlaMint-$country-listOrg.xml",
	     "$orieDir/$oriePrefix$country$encoSuffix",
	     $encoScript,
	     "$tmpDir/listOrg.enco.xml"
	     );
    &process('CHES',
	     "$tmpDir/listOrg.enco.xml",
	     "$orieDir/$oriePrefix$country$chesSuffix",
	     $chesScript,
	     "$tmpDir/listOrg.ches.xml");
    &process('Wiki',
	     "$tmpDir/listOrg.ches.xml",
	     "$orieDir/$oriePrefix$country$wikiSuffix",
	     $wikiScript,
	     "$tmpDir/listOrg.wiki.xml");
    `$poliScript < $tmpDir/listOrg.wiki.xml > $outCorpDir/ParlaMint-$country-listOrg.xml`;

    &process('Minister',
	     "$inCorpDir/ParlaMint-$country-listPerson.xml",
	     "$miniDir/$miniPrefix$country$miniSuffix",
	     $miniScript,
	     "$tmpDir/listPerson.mini.xml");
    `$poliScript < $tmpDir/listPerson.mini.xml > $outCorpDir/ParlaMint-$country-listPerson.xml`;
}

sub process {
    my $type = shift;
    my $inListFile = shift;
    my $tsvFile  = shift;
    my $script  = shift;
    my $outListFile  = shift;
    die "FATAL: For $type can't find input file $inListFile\n" unless -e $inListFile;
    if (-e $tsvFile) {
	print STDERR "INFO: Adding TSV metadata for $type\n";
	my $command = "$Saxon tsv=$tsvFile -xsl:$script $inListFile > $outListFile";
	`$command`;
    }
    else {
	print STDERR "INFO: No TSV metadata for $type, skipping\n";
	`cp $inListFile $outListFile`
    }
}
