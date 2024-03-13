#!/usr/bin/env perl
# Copy README files to outputDir
use warnings;
use utf8;
use open ':utf8';
use FindBin qw($Bin);

binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

use Getopt::Long;
use FindBin qw($Bin);
use File::Spec;
use File::Copy;
use File::Copy::Recursive qw(dircopy);

GetOptions
    (
     'codes=s'    => \$countryCodes,
     'docs=s'     => \$docsDir,
     'version=s'  => \$Version,
     'teihandle=s'=> \$handleTEI,
     'anahandle=s'=> \$handleAna,
     'out=s'      => \$outDir,
);

$docsDir = File::Spec->rel2abs($docsDir) if $docsDir;
$outDir = File::Spec->rel2abs($outDir) if $outDir;

$XX_template = "ParlaMint-XX";

unless ($countryCodes) {
    print STDERR "Need some country codes.\n";
    print STDERR "For help: parlamint2distro.pl -h\n";
    exit
}
foreach my $countryCode (split(/[, ]+/, $countryCodes)) {
    print STDERR "INFO: *****Converting $countryCode\n";

    # Is this an MTed corpus?
    if ($countryCode =~ m/-([a-z]{2,3})$/) {$MT = $1}
    else {$MT = 0}

    my $XX = $XX_template;
    $XX =~ s|XX|$countryCode|g;

    my $teiDir  = "$XX.TEI";
    my $anaDir = "$XX.TEI.ana";
    
    my $teiRoot = "$teiDir/$XX.xml";
    my $anaRoot = "$anaDir/$XX.ana.xml";

    my $outTeiDir  = "$outDir/$teiDir";
    my $outTeiRoot = "$outDir/$teiRoot";
    my $outAnaDir  = "$outDir/$anaDir";
    my $outAnaRoot = "$outDir/$anaRoot";
    my $outSmpDir  = "$outDir/Sample-$XX";
    my $outTxtDir  = "$outDir/$XX.txt";
    my $outConlDir = "$outDir/$XX.conllu";
    my $outVertDir = "$outDir/$XX.vert";
	
    print STDERR "INFO: ***Finalizing $countryCode TEI.ana\n";
    die "FATAL: Need version\n" unless $Version;
    die "FATAL: No handle given for ana distribution\n" unless $handleAna;
    if ($MT) {$inReadme = "$docsDir/README-$MT.TEI.ana.txt"}
    else {$inReadme = "$docsDir/README.TEI.ana.txt"}
    die "FATAL: No handle given for TEI.ana distribution\n" unless $handleAna;
    &cp_readme($countryCode, $handleAna, $Version, $inReadme, "$outAnaDir/00README.txt");
    
    print STDERR "INFO: ***Finalizing $countryCode TEI\n";
    die "FATAL: Need version\n" unless $Version;
    die "FATAL: No handle given for TEI distribution\n" unless $handleTEI;
    if ($MT) {$inReadme = "$docsDir/README-$MT.TEI.txt"}
    else {$inReadme = "$docsDir/README.TEI.txt"}
    &cp_readme($countryCode, $handleTEI, $Version, $inReadme, "$outTeiDir/00README.txt");
    
    print STDERR "INFO: ***Making $countryCode text\n";
    if    ($handleTEI) {$handleTxt = $handleTEI}
    elsif ($handleAna) {$handleTxt = $handleAna}
    else {die "FATAL: No handle given for TEI or .ana distribution\n"}
    if ($MT) {$inReadme = "$docsDir/README-$MT.text.txt"}
    else {$inReadme = "$docsDir/README.text.txt"}
    &cp_readme($countryCode, $handleTxt, $Version, $inReadme, "$outTxtDir/00README.txt");
    
    print STDERR "INFO: ***Making $countryCode CoNLL-U\n";
    die "FATAL: Can't find input ana dir $outAnaDir\n" unless -e $outAnaDir; 
    die "FATAL: No handle given for ana distribution\n" unless $handleAna;
    if ($MT) {$inReadme = "$docsDir/README-$MT.conll.txt"}
    else {$inReadme = "$docsDir/README.conll.txt"}
    &cp_readme($countryCode, $handleAna, $Version, $inReadme, "$outConlDir/00README.txt");
    
    print STDERR "INFO: ***Making $countryCode vert\n";
    die "FATAL: Can't find input ana dir $outAnaDir\n" unless -e $outAnaDir; 
    die "FATAL: No handle given for ana distribution\n" unless $handleAna;
    if ($MT) {$inReadme = "$docsDir/README-$MT.vert.txt"}
    else {$inReadme = "$docsDir/README.vert.txt"}
    &cp_readme($countryCode, $handleAna, $Version, $inReadme, "$outVertDir/00README.txt");
}

#Read in the appropriate $inFile README, change XX in it to country code, and output it $outFile
sub cp_readme {
    my $country = shift;
    my $handle  = shift;
    my $version = shift;
    my $inFile  = shift;
    my $outFile = shift;
    die "FATAL: No country for cp_readme\n" unless $country;
    die "FATAL: No handle for cp_readme\n" unless $handle;
    die "FATAL: No version for cp_readme\n" unless $version;
    open IN, '<:utf8', $inFile or die "FATAL: Can't open input README $inFile\n";
    open OUT,'>:utf8', $outFile or die "FATAL: Can't open output README $outFile\n";
    while (<IN>) {
	s/XX/$country/g;
	s/YY/$handle/g;
	s/ZZ/$version/g;
	print OUT
    }
    close IN;
    close OUT;
}
