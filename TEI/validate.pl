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
    $mask = 'ParlaMint-*/ParlaMint-*.xml';
}
elsif ($what eq 'master') {
    $mask  = 'ParlaMint-*.TEI/ParlaMint-*.xml ';
    $mask .= 'ParlaMint-*.TEI/*/ParlaMint-*.xml ';
    $mask .= 'ParlaMint-*.TEI.ana/ParlaMint-*.xml ';
    $mask .= 'ParlaMint-*.TEI.ana/*/ParlaMint-*.xml';
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
$Schema = "$Bin/ParlaMint.rng";
foreach my $inFile (glob "$inDir/$mask") {
    ($fName) = $inFile =~ m|([^/]+\.xml)|;
    print STDERR "INFO: Validating $fName\n";
    #`$Jing $Schema $inFile`;
    system("$Jing $Schema $inFile") == 0
	or print STDERR "ERROR: Validation of $fName failed!\n";
}
