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
    print STDERR ("Usage: finalize-parlamint.pl '<COUNTRYCODES>' <InputDirectory> <OutputDirectory>\n");
    print STDERR ("       Finalizes ParlaMint corpora and produces derived encodings.\n");
    print STDERR ("       <COUNTRYCODES> is the list of country codes of the corpora to be processed.\n");
    print STDERR ("       <InputDirectory> is where ParlaMint.TEI-XX/ and ParlaMint.TEI.ana-XX/ are.\n");
    print STDERR ("       <OutputDirectory> is where output directories are written.\n");
    print STDERR ("       The script does the following:\n");
    print STDERR ("       * finalizes the TEI and TEI.ana directories\n");
    print STDERR ("       * produces the plain text, meta, conllu and vertical files.\n");
}
use Getopt::Long;
use FindBin qw($Bin);
use File::Spec;

$countryCodes = shift;
$schemaDir = File::Spec->rel2abs(shift);
$inDir = File::Spec->rel2abs(shift);
$outDir = File::Spec->rel2abs(shift);

$Saxon = "java -jar /usr/share/java/saxon.jar";
$Final = "$Bin/parlamint2final.xsl";
$Polish = "$Bin/polish.pl";
$Sample = "$Bin/corpus2sample.xsl";
$Valid = "$Bin/validate-parlamint.pl";

$teiDir  = "ParlaMint-XX.TEI";
$teiRoot = "$teiDir/ParlaMint-XX.xml";
$anaDir  = "ParlaMint-XX.TEI.ana";
$anaRoot = "$anaDir/ParlaMint-XX.ana.xml";

$outTeiDir  = "$outDir/$teiDir";
$outTeiRoot = "$outDir/$teiRoot";
$outAnaDir  = "$outDir/$anaDir";
$outAnaRoot = "$outDir/$anaRoot";
$outSampleDir  = "$outDir/ParlaMint-XX-Sample";

foreach my $countryCode (split(/[, ]+/, $countryCodes)) {
    print STDERR "INFO: ***Converting $countryCode\n";
    print STDERR "INFO: *Finalizing TEI.ana\n";
    $CanaRoot = "$inDir/$anaRoot";
    $CanaRoot =~ s|XX|$countryCode|g;
    $CanaDir = $anaDir;
    $CanaDir =~ s|XX|$countryCode|g;
    $CoutAnaDir = $outAnaDir;
    $CoutAnaDir =~ s|XX|$countryCode|g;
    `rm -fr $CoutAnaDir`;
    $command = "$Saxon outDir=$outDir -xsl:$Final $CanaRoot";
    `$command`;
    &polish($CoutAnaDir);
    $command = "$Valid $schemaDir $CoutAnaDir";
    `$command`;
    
    print STDERR "INFO: *Finalizing TEI\n";
    $CteiRoot = "$inDir/$teiRoot";
    $CteiRoot =~ s|XX|$countryCode|g;
    $CoutTeiDir = $outTeiDir;
    $CoutTeiDir =~ s|XX|$countryCode|g;
    `rm -fr $CoutTeiDir`;
    $command = "$Saxon anaDir=$CoutAnaDir outDir=$outDir -xsl:$Final $CteiRoot";
    `$command`;
    &polish($CoutTeiDir);
    $command = "$Valid $schemaDir $CoutTeiDir";
    `$command`;

    print STDERR "INFO: *Making samples\n";
    $CoutSampleDir = $outSampleDir;
    $CoutSampleDir =~ s|XX|$countryCode|g;
    $command = "$Saxon outDir=$CoutSampleDir -xsl:$Sample $outTeiRoot";
    `$command`;
    $command = "$Saxon outDir=$CoutSampleDir -xsl:$Sample $outAnaRoot";
    `$command`;
    $command = "$Valid $schemaDir $CoutSampleDir";
    `$command`;
    
}

#Make XML file a bit smaller
sub polish {
    my $dir = shift;
    foreach my $file (glob("$dir/*.xml $dir/*/*.xml")) {
	$command = "$Polish < $file > $file.tmp";
	`$command`;
	rename("$file.tmp", $file); 
    }
}
