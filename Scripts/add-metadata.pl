#!/usr/bin/perl
# Add metadata to TEI corpora:
# - transliterate listOrg.xml
# - add encoder political orientations to listOrg.xml
# - add CHES political orientations to listOrg.xml
# - add Wiki political orientations to listOrg.xml
# - transliterate listPerson.xml
# - add minster affiliations to listPerson.xml
use warnings;
use utf8;
use FindBin qw($Bin);
use File::Spec;
use File::Temp qw/ tempfile tempdir /;  #creation of tmp files and directory
my $tempdirroot = "$Bin/tmp";
my $tmpDir = tempdir(DIR => $tempdirroot, CLEANUP => 1);

binmode(STDERR, 'utf8');

$orieDir = File::Spec->rel2abs(shift);
$miniDir = File::Spec->rel2abs(shift);
$inDirs  = File::Spec->rel2abs(shift);
$outDir  = File::Spec->rel2abs(shift);

$Saxon   = "java -jar $Bin/bin/saxon.jar";

# Transliteration script for listOrg and listPerson
$transScript = "$Bin/trans-execute.pl";

# Scripts that add info to listOrg
$encoScript  = "$Bin/enco-tsv2tei.xsl";
$chesScript  = "$Bin/ches-tsv2tei.xsl";
$wikiScript  = "$Bin/wiki-tsv2tei.xsl";

# Scripts that add info to listPerson
$miniScript = "$Bin/ministers-tsv2tei.xsl";

# Scripts that remove/merge affiliation overlaps in listPerson
$affiliationScript = "$Bin/affiliations-remove-overlaps.xsl";

# Script that makes XML prettier
$poliScript = "$Bin/polish-xml.pl";

# Prefix and suffixes of orientation related TSV files
$oriePrefix  = 'Orientation-';
$encoSuffix = '.enco.tsv';
$chesSuffix = '.CHES.tsv';
$wikiSuffix = '.Wiki.tsv';

# Prefix and suffixes of ministers related TSV files
$miniPrefix  = 'Ministers-';
$miniSuffix  = '.edited.tsv';

foreach $inCorpDir (sort glob $inDirs) {
    ($country, $anaSuffix) = $inCorpDir =~ /ParlaMint-([A-Z-]+)\.TEI(\..+)?/ or die;
    $anaSuffix = '' unless $anaSuffix;
    print STDERR "INFO: Doing $country TEI$anaSuffix\n";
    $outCorpDir = "$outDir/ParlaMint-$country.TEI$anaSuffix";
    die "FATAL ERROR: Can't find output directory $outCorpDir\n" unless -e $outCorpDir;

    # Copy all XML files, will overwrite the relevant listOrg and listPerson in &process
    foreach $xmlFile (glob "$inCorpDir/*.xml") {
	($fName) = $xmlFile =~ m|([^/]+)$|;
	`$poliScript < $xmlFile > $outCorpDir/$fName`;
    }

    &process('Transliteration',
	     "$inCorpDir/ParlaMint-$country-listOrg.xml",
	     '',
	     '',
	     $transScript,
	     "$tmpDir/ParlaMint-$country-listOrg.trans.xml"
	     );
    &process('Encoder orientations',
	     "$tmpDir/ParlaMint-$country-listOrg.trans.xml",
	     "$orieDir/$oriePrefix$country$encoSuffix",
	     '',
	     $encoScript,
	     "$tmpDir/ParlaMint-$country-listOrg.enco.xml"
	     );
    &process('CHES orientations',
	     "$tmpDir/ParlaMint-$country-listOrg.enco.xml",
	     "$orieDir/$oriePrefix$country$chesSuffix",
	     '',
	     $chesScript,
	     "$tmpDir/ParlaMint-$country-listOrg.ches.xml");
    &process('Wiki orientations',
	     "$tmpDir/ParlaMint-$country-listOrg.ches.xml",
	     "$orieDir/$oriePrefix$country$wikiSuffix",
	     '',
	     $wikiScript,
	     "$tmpDir/ParlaMint-$country-listOrg.wiki.xml");
    `$poliScript < $tmpDir/ParlaMint-$country-listOrg.wiki.xml > $outCorpDir/ParlaMint-$country-listOrg.xml`;

    &process('Transliteration',
	     "$inCorpDir/ParlaMint-$country-listPerson.xml",
	     '',
	     '',
	     $transScript,
	     "$tmpDir/ParlaMint-$country-listPerson.trans.xml"
	     );
    &process('Encoder ministers',
	     "$tmpDir/ParlaMint-$country-listPerson.trans.xml",
	     "$miniDir/$miniPrefix$country$miniSuffix",
             "$outCorpDir/ParlaMint-$country-listOrg.xml",
	     $miniScript,
	     "$tmpDir/ParlaMint-$country-listPerson.mini.xml");

    `$poliScript < $tmpDir/ParlaMint-$country-listPerson.mini.xml > $outCorpDir/ParlaMint-$country-listPerson.xml`;
}

sub process {
    my $type = shift;
    my $inListFile = shift;
    my $tsvFile  = shift;
    my $xmlFile  = shift;
    my $script  = shift;
    my $outListFile  = shift;
    my $command;
    die "FATAL ERROR: For $type can't find input file $inListFile\n" unless -e $inListFile;
    if ($tsvFile and -e $tsvFile) {
	print STDERR "INFO: Adding TSV metadata for $type\n";
        if ($xmlFile) {
            die "FATAL ERROR: For $type can't support XML file $xmlFile\n" unless -e $xmlFile;
            $command = "$Saxon tsv=$tsvFile xml=$xmlFile -xsl:$script $inListFile > $outListFile";
        }
        else {
            $command = "$Saxon tsv=$tsvFile -xsl:$script $inListFile > $outListFile";
        }
        `$command`;
    }
    elsif ($tsvFile) {
	print STDERR "INFO: No TSV metadata for $type, skipping\n";
	`cp $inListFile $outListFile`
    }
    else {
	print STDERR "INFO: $type\n";
	$command = "$script $inListFile $outListFile";
	`$command`;
    }
    return 1;
}
