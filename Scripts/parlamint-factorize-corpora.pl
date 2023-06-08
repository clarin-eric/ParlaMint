#!/usr/bin/perl
# Factorise all corpora given in inDir parameter
# 1. For all corpora make backup directory, if not already present, and copy into it the original root files
# 2. Taking backup files as input overwrite original root files with factorised files

use warnings;
use utf8;
use FindBin qw($Bin);
use File::Spec;

$inDir = File::Spec->rel2abs(shift);

binmode(STDERR, 'utf8');

$Saxon = 'java -jar /usr/share/java/saxon.jar';
$Factorise  = "$Bin/parlamint-factorize-teiHeader.xsl";

$bkpSuffix = ".origRoot";
foreach $corpDir (glob "$inDir/ParlaMint-*.TEI*") {
    next if $corpDir =~ /$bkpSuffix/;
    ($Corpus, $dirSuffix) = $corpDir =~ /ParlaMint-([A-Z-]+)\.TEI(\..+)?/ or die;
    $dirSuffix = '' unless $dirSuffix;
    print STDERR "INFO: Doing $Corpus TEI$dirSuffix\n";
    $bkpDir = "$corpDir$bkpSuffix";
    unless (-e $bkpDir) {
	print STDERR "INFO: Creating backup in $bkpDir\n";
	`mkdir $bkpDir`;
	`cp $corpDir/*.xml $bkpDir`
    }
    $Prefix = "ParlaMint-$Corpus-";
    `rm $corpDir/*.xml`;
    $command = "$Saxon outDir=$corpDir prefix=$Prefix -xsl:$Factorise $bkpDir/ParlaMint-$Corpus$dirSuffix.xml";
    `$command`;
}
