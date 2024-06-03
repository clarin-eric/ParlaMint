#!/usr/bin/env perl
use warnings;
use utf8;
use FindBin qw($Bin);
use File::Spec;

$inFiles = File::Spec->rel2abs(shift);
$outDir = File::Spec->rel2abs(shift);

binmode(STDERR, 'utf8');

my $Saxon = "java -jar $Bin/../../saxon.jar -l ";
my $CNV = "$Bin/v1tov2.xsl";
my $POLISH = "$Bin/../../polish-xml.pl";

foreach $inFile (glob $inFiles) {
    my ($thisDir, $fName) = $inFile =~ m|([^/]+)/([^/]+)$|
	or die "Weird input file $inFile\n";
    $outputDir = "$outDir/$thisDir";
    `mkdir $outputDir` unless -e "$outputDir";
    my $outFile = "$outputDir/$fName";
    print STDERR "INFO: Converting $fName\n";
    $command = "$Saxon -xsl:$CNV $inFile | $POLISH > $outFile";
    #print STDERR "\$ $command\n";
    `$command`;
}
