#!/usr/bin/perl -w
# Copy prepared CHES TSV files to the Sources-TSV country directories
use utf8;
@inFiles = glob(shift);
@outDirs = glob(shift);
$outFileName = "OrientationCHES-XX.edited.tsv";
binmode(STDOUT,'utf8');
binmode(STDERR,'utf8');

foreach my $outDir (@outDirs) {
    next unless -d $outDir;
    ($country) = $outDir =~ /-([A-Z-]+)/;
    $outFile = "$outDir/$outFileName";
    $outFile =~ s/XX/$country/;
    $inFile = '';
    foreach $File (@inFiles) {
        ($thisCountry) = $File =~ /-([A-Z]{2})\.tsv/ or die;
        #print STDERR "$country\t$thisCountry\t$File\n";
        if ($thisCountry eq $country) {$inFile = $File}
    }
    if ($inFile) {
        print STDERR "INFO: copying $inFile to $outFile\n";
        `cp $inFile $outFile`;
    }
    else {print STDERR "WARN: can't find input file for $outFile\n"}
}
