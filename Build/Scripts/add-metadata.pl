#!/usr/bin/env perl
# Add metadata to TEI corpora:
# - transliterate listOrg.xml
# - add encoder political orientations to listOrg.xml
# - add CHES political orientations to listOrg.xml
# - add Wiki political orientations to listOrg.xml
# - transliterate listPerson.xml
# - add minister affiliations to listPerson.xml
# - add sex information on listPerson.xml
use warnings;
use utf8;
use FindBin qw($Bin);
use File::Spec;
use File::Temp qw/ tempfile tempdir /;  #creation of tmp files and directory
my $tempdirroot = "$Bin/tmp";
mkdir($tempdirroot) unless(-d $tempdirroot);
my $tmpDir = tempdir(DIR => $tempdirroot, CLEANUP => 0);

binmode(STDERR, 'utf8');

$inDir = File::Spec->rel2abs(shift);
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
$sexScript  = "$Bin/sex-tsv2tei.xsl";
# Script that makes XML prettier
$poliScript = "$Bin/polish-xml.pl";

# Prefix and suffixes of ministers related TSV files
$miniPrefix  = 'Ministers-';
$miniSuffix  = '.edited.tsv';

# Prefix and suffixes of orientation related TSV files
$encoPrefix = 'OrientationEnco-';
$encoSuffix = '.edited.tsv';

$wikiPrefix = 'OrientationWiki-';
$wikiSuffix = '.edited.tsv';

$chesPrefix = 'OrientationCHES-';
$chesSuffix = '.edited.tsv';

# Prefix and suffixes of sex related TSV files
$sexPrefix  = 'Sex-';
$sexSuffix  = '.edited.tsv';

die "FATAL: Can't find output directory $outDir\n"
    unless -e $outDir;

($country) = $inDir =~ /ParlaMint-([A-Z-]+)/
    or die "FATAL: Cant find country in $inDir\n";

$listPerson = "ParlaMint-$country-listPerson";
die "FATAL: Can't find $inDir/$listPerson.xml!\n"
    unless -e "$inDir/$listPerson.xml";

$listOrg = "ParlaMint-$country-listOrg";
die "FATAL: Can't find $inDir/$listOrg.xml!\n"
    unless -e "$inDir/$listOrg.xml";

print STDERR "INFO: Doing $inDir\n";

#Run pipeline

# listOrg processing
&process('Transliteration',
         "$inDir/$listOrg\.xml", 0, 0,
         $transScript,
         "$tmpDir/$listOrg\.trans.xml"
    );
&process('Encoder orientations',
         "$tmpDir/$listOrg.trans.xml", "$inDir/$encoPrefix$country$encoSuffix", 0,
         $encoScript,
         "$tmpDir/$listOrg\.enco.xml"
    );
&process('CHES orientations',
         "$tmpDir/$listOrg\.enco.xml", "$inDir/$chesPrefix$country$chesSuffix", 0,
         $chesScript,
         "$tmpDir/$listOrg.ches.xml");
&process('Wiki orientations',
         "$tmpDir/$listOrg\.ches.xml", "$inDir/$wikiPrefix$country$wikiSuffix", 0,
         $wikiScript,
         "$tmpDir/$listOrg\.wiki.xml");
# Polish the result
`$poliScript < $tmpDir/$listOrg\.wiki.xml > $outDir/$listOrg\.xml`;

# listPerson processing
&process('Transliteration',
         "$inDir/ParlaMint-$country-listPerson.xml", 0, 0,
         $transScript,
         "$tmpDir/$listPerson\.trans.xml"
    );
#We take the output listOrg, does it matter?
&process('Encoder ministers',
         "$tmpDir/$listPerson\.trans.xml", "$inDir/$miniPrefix$country$miniSuffix", "$outDir/$listOrg\.xml",
         $miniScript,
         "$tmpDir/$listPerson\.mini.xml");
&process('Sex info',
         "$tmpDir/$listPerson\.mini.xml", "$inDir/$sexPrefix$country$sexSuffix", 0,
         $sexScript,
         "$tmpDir/$listPerson\.sex.xml");

# Polish the result
`$poliScript < $tmpDir/$listPerson\.sex.xml > $outDir/$listPerson\.xml`;

# Add TSV metadata to a listPerson or listOrg file, if required TSV file exists
sub process {
    my $type = shift;           #Message, what it is doing
    my $inListFile = shift;     #Input listPerson or listOrg XML
    my $tsvFile  = shift;       #TSV file with new metadata
    my $xmlFile  = shift;       #Support XML file (e.g. listOrg for lisPerson, to insert references to #GOV
    my $script  = shift;        #The script to be run
    my $outListFile  = shift;   #Output modified listPerson or listOrg XML

    my $command;
    die "FATAL ERROR: For $type can't find input file $inListFile\n" unless -e $inListFile;
    if ($tsvFile and -e $tsvFile) {
	print STDERR "INFO: Adding TSV metadata for $type\n";
        if ($xmlFile) {
            die "FATAL ERROR: For $type can't find support XML file $xmlFile\n" unless -e $xmlFile;
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
