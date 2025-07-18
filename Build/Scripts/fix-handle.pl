#!/usr/bin/env perl
# Fix wrong handle in input files
use warnings;
use utf8;
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');
$oldHandle = shift;
$newHandle = shift;
$inFiles = shift;
foreach $inFile (glob $inFiles)  {
    ($inDir, $fName) = $inFile =~ m|(.+)/([^/]+)\.xml|;
    $tmpFile = "$inDir/$fName.tmp";
    #$bkpFile = "$inDir/$fName.bkp.xml";
    print STDERR "Doing $fName\n";
    #`cp $inFile $bkpFile`;
    open(IN, '<:utf8', $inFile);
    open(OUT, '>:utf8', $tmpFile);
    while (<IN>) {
	s|$oldHandle|$newHandle|;
	print OUT
    }
    close IN;
    close OUT;
    `mv $tmpFile $inFile`;
}
