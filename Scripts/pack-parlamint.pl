#!/usr/bin/perl
# Pack ParlaMint corpora
# Tomaž Erjavec <tomaz.erjavec@ijs.si>
# License: GNU GPL

use warnings;
use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

sub usage {
    print STDERR ("Usage:\n");
    print STDERR ("pack-parlamint.pl -help\n");
    print STDERR ("pack-parlamint.pl -codes '<Codes>' -in <Input> -out <Output>\n");
    print STDERR ("    Packs ParlaMint corpora into .tgz.\n");
    print STDERR ("    <Codes> is the list of country codes of the corpora to be processed.\n");
    print STDERR ("    <Input> is the directory where ParlaMint.TEI-XX/ and ParlaMint.TEI.ana-XX/ are.\n");
    print STDERR ("    <Output> is the directory where output .tgz are written.\n");
}

use Getopt::Long;
use FindBin qw($Bin);
use File::Spec;
use File::Copy;

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
    print STDERR "INFO: ***Packing $countryCode\n";
    
    $XX = $XX_template;
    $XX =~ s|XX|$countryCode|g;
    
    $teiDir  = "$XX.TEI";
    $anaDir  = "$XX.TEI.ana";
    $TxtDir  = "$XX.txt";
    $ConlDir = "$XX.conllu";
    $VertDir = "$XX.vert";

    $outTxt = "$XX.tgz";
    $outAna = "$XX.ana.tgz";
    
    print STDERR "INFO: *Packing $teiDir, $TxtDir\n";
    `rm -fr $outDir/$outTxt`;
    die "Can't find $inDir/$teiDir\n" unless -e "$inDir/$teiDir"; 
    die "Can't find $inDir/$TxtDir\n" unless -e "$inDir/$TxtDir";
    `cd $inDir; tar -czf $outTxt --mode='a+rwX' $teiDir $TxtDir`;
    move("$inDir/$outTxt", $outDir);
    
    print STDERR "INFO: *Packing $anaDir, $ConlDir, $VertDir\n";
    if (-e "$inDir/$anaDir/$XX.ana.xml") {
        `rm -fr $outDir/$outAna`;
        die "Can't find $inDir/$anaDir\n" unless -e "$inDir/$anaDir"; 
        die "Can't find $inDir/$ConlDir\n" unless -e "$inDir/$ConlDir";
        die "Can't find $inDir/$VertDir\n" unless -e "$inDir/$VertDir";
        `cd $inDir; tar -czf $outAna --mode='a+rwX' $anaDir $ConlDir $VertDir`;
        move("$inDir/$outAna", $outDir);
    }
    else {
        print STDERR "WARN: No ana root file, skipping\n";
    }
}
