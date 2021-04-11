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
$inDir = File::Spec->rel2abs(shift);
$outDir = File::Spec->rel2abs(shift);

$Saxon = "java -jar /usr/share/java/saxon.jar";
$Final = "$Bin/parlamint2final.xsl";
$Polish = "$Bin/polish.pl";

$anaDir  = "ParlaMint-XX.TEI.ana";
$anaRoot = "$anaDir/ParlaMint-XX.ana.xml";
$teiDir  = "ParlaMint-XX.TEI";
$teiRoot = "$teiDir/ParlaMint-XX.xml";
$outAnaDir  = "$outDir/$anaDir";
$outTeiDir  = "$outDir/$teiDir";

foreach my $countryCode (split(/[, ]+/, $countryCodes)) {
    print STDERR "INFO: ***Converting $countryCode\n";
    $CanaRoot = "$inDir/$anaRoot";
    $CanaRoot =~ s|XX|$countryCode|g;
    $CanaDir = $anaDir;
    $CanaDir =~ s|XX|$countryCode|g;
    $command = "$Saxon outDir=$outDir -xsl:$Final $CanaRoot";
    `$command`;
    $CoutAnaDir = $outAnaDir;
    $CoutAnaDir =~ s|XX|$countryCode|g;
    &polish($CoutAnaDir);
    
    $CteiRoot = "$inDir/$teiRoot";
    $CteiRoot =~ s|XX|$countryCode|g;
    $command = "$Saxon anaDir=$CoutAnaDir outDir=$outDir -xsl:$Final $CteiRoot";
    `$command`;
    $CoutTeiDir = $outTeiDir;
    $CoutTeiDir =~ s|XX|$countryCode|g;
    &polish($CoutTeiDir);
}
sub polish {
    my $dir = shift;
    foreach my $file (glob("$dir/*.xml $dir/*/*.xml")) {
	$command = "$POLISH < $file > $file.tmp";
	`$command`;
	rename("$file.tmp", $file); 
    }
}
