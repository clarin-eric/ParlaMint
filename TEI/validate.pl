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

$what = shift;
if ($what eq 'samples') {
    $tmpDir = "$Bin/tmp";
    $maskTxt = 'ParlaMint-??/ParlaMint-??.xml';
    $maskAna = 'ParlaMint-??/ParlaMint-??.ana.xml';
}
elsif ($what eq 'master') {
    $maskTxt  = 'ParlaMint-??.TEI/ParlaMint-??.xml ';
    $maskTxt .= 'ParlaMint-??.TEI/ParlaMint-??_*.xml ';
    $maskTxt .= 'ParlaMint-??.TEI/*/ParlaMint-??_*.xml';
    
    $maskAna  = 'ParlaMint-??.TEI.ana/ParlaMint-??.ana.xml ';
    $maskAna .= 'ParlaMint-??.TEI.ana/ParlaMint-??_*.ana.xml ';
    $maskAna .= 'ParlaMint-??.TEI.ana/*/ParlaMint-??_*.ana.xml';
}
else {
    die "First parameter must be 'samples' or 'master'\n"
}
$inDir = shift;
unless (-d $inDir) {
    die "Second parameter must be top level input directory\n"
}
#Execution
$Jing   = "java -jar /usr/share/java/jing.jar";
$Saxon  = "java -jar /usr/share/java/saxon.jar";
# Problem with Out of heap space with TR, NL, GB for ana
$Saxon  = "java -Xmx120g -jar /usr/share/java/saxon.jar";
$Copy   = "$Bin/copy-odd.xsl";
$Schema = "$Bin/ParlaMint.rng";

foreach my $inFile (glob "$inDir/$maskTxt $inDir/$maskAna") {
    ($fName) = $inFile =~ m|([^/]+\.xml)|;
    print STDERR "INFO: Validating $fName\n";
    if ($what eq 'samples') {
	$tmpFile = "$tmpDir/$fName";
	`$Saxon -xi -xsl:$Copy $inFile > $tmpFile`;
	#print STDERR "Doing: $Jing $Schema $tmpFile\n";
	system("$Jing $Schema $tmpFile");
    }
    elsif ($what eq 'master') {
	`$Jing $Schema $inFile`
    }
}
