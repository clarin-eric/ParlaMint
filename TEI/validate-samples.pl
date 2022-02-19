#!/usr/bin/perl
# Validate the samples with the ParlaMint ODD derived schema
# Tomaž Erjavec <tomaz.erjavec@ijs.si>
# License: GNU GPL

use warnings;
use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

use FindBin qw($Bin);

$inDir = shift;
$tmpDir = "$Bin/tmp";
$maskTxt = 'ParlaMint-??/ParlaMint-??.xml';
$maskAna = 'ParlaMint-??/ParlaMint-??.ana.xml';

#Execution
$Jing   = "java -jar /usr/share/java/jing.jar";
$Saxon  = "java -jar /usr/share/java/saxon.jar";
# Problem with Out of heap space with TR, NL, GB for ana
$Saxon  = "java -Xmx120g -jar /usr/share/java/saxon.jar";
$Copy   = "$Bin/copy-odd.xsl";
$Schema = "$Bin/ParlaMint.rng";

foreach my $file (glob "$inDir/$maskTxt $inDir/$maskAna") {
    ($fName) = $file =~ m|([^/]+\.xml)|;
    print STDERR "INFO: Validating $fName\n";
    $tmpFile = "$tmpDir/$fName";
    `$Saxon -xi -xsl:$Copy $file > $tmpFile`;
    `$Jing $Schema $tmpFile`;
}
