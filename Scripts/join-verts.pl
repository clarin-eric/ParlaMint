#!/usr/bin/perl
# Join vert files into one, reversing the chrono order
# Tomaž Erjavec <tomaz.erjavec@ijs.si>
# License: GNU GPL

use warnings;
use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

#Version number, will be embedded in vertical file name, e.g. ParlaMint-CZ.3.0.vert.gz
$VER = '3.0'; 

sub usage {
    print STDERR ("Usage:\n");
    print STDERR ("$0 -help\n");
    print STDERR ("$0 -codes '<Codes>'");
    print STDERR (" -in <Input> -out <Output>\n");
    print STDERR ("    Joins .vert files in reverse order.\n");
    print STDERR ("    <Codes> is the list of country codes of the corpora to be processed.\n");
    print STDERR ("    <Input> is the directory where ParlaMint-XX.vert/ is.\n");
    print STDERR ("    <Output> is the directory where output files are written.\n");
}

use Getopt::Long;
use FindBin qw($Bin);
use File::Spec;
use File::Copy;
use File::Copy::Recursive qw(dircopy);

GetOptions
    (
     'help'     => \$help,
     'codes=s'  => \$countryCodes,
     'in=s'     => \$inDir,
     'out=s'    => \$outDir,
);

if ($help) {
    &usage;
    exit;
}

$inDir = File::Spec->rel2abs($inDir);
$outDir = File::Spec->rel2abs($outDir);

$XX_template = "ParlaMint-XX";

foreach my $countryCode (split(/[, ]+/, $countryCodes)) {
    print STDERR "INFO: ***Joining $countryCode\n";
    $XX = $XX_template;
    $XX =~ s|XX|$countryCode|g;
    $inVertDir  = "$inDir/$XX.vert";
    $outVert    = "$outDir/$XX.$VER.vert";
    `find $inVertDir -type f -name '*.vert' -print | sort -r | xargs cat | gzip > $outVert.gz`;
    $copyRegi = "cp $inVertDir/*_" . lc($countryCode) . ".regi $outDir/";
    `$copyRegi`
}
