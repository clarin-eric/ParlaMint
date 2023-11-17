#!/usr/bin/perl
# Copy samples to official Git directories with samples
use warnings;
use utf8;
use open ':utf8';
use FindBin qw($Bin);
binmode(STDERR, ':utf8');
$inDirs = shift;
$outDirs = shift;

foreach $inDir (glob $inDirs) {
    ($corpus) = $inDir =~ m|(ParlaMint-[A-Z]{2}(-[A-Z]{2})?)|;
    #We currently copy over only MTed files!!
    next unless $inDir =~ m|$corpus-en|;
    $outDir = "$outDirs/$corpus";
    print STDERR "INFO: Doing $corpus ($inDir -> $outDir)\n";
    die "Can't find $outDir\n" unless -e $outDir;
    # Because we are copying MTed files, we don't want to delete all the original ones!
    # `rm -f $outDir/*.xml`;
    # `rm -f $outDir/*.conllu`;
    # `rm -f $outDir/*.tsv`;
    # `rm -f $outDir/*.txt`;
    # `rm -f $outDir/*.vert`;
    # `rm -f $outDir/*.tbl`;   #Chars info, obsolete
    # We don't want to copy everyting, just the MTed files!
    #`cp -f $inDir/* $outDir`;
    `cp $inDir/ParlaMint-taxonomy-USAS.ana.xml $outDir`;
    `cp $inDir/*-en.* $outDir`;
    `cp $inDir/*-en_* $outDir`;
}
