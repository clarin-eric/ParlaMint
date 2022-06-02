#!/usr/bin/perl
use warnings;
use strict;
use utf8;
use FindBin qw($Bin);
use File::Spec;

my $inFiles = File::Spec->rel2abs(shift);
my $outDir = File::Spec->rel2abs(shift);

binmode(STDERR, 'utf8');

my $Saxon = 'java -jar /usr/share/java/saxon.jar -l ';
my $CNV = "$Bin/v2tov3.xsl";
my $POLISH; #"$Bin/../../polish-xml.pl";

foreach my $inFile (glob $inFiles) {
    my ($thisDir, $fName) = $inFile =~ m|([^/]+)/([^/]+)$|
	or die "Weird input file $inFile\n";
    my $outputDir = "$outDir/$thisDir";
    `mkdir -p $outputDir` unless -e "$outputDir";
    my $outFile = "$outputDir/$fName";
    print STDERR "INFO: Converting $fName\n";
    my $command = "awk '{gsub(/(<[a-zA-Z:]+)/,"
                 .'"& LINE=\"" NR "\"",$0);print}'
                 ."' $inFile | $Saxon -xsl:$CNV -s:- " . ($POLISH ? "| $POLISH": "") . " > $outFile";
    print STDERR "\$ $command\n";
    `$command`;
}
