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
foreach $corpDir (sort glob "$inDir/ParlaMint-*.TEI*") {
    next if $corpDir =~ /$bkpSuffix/;
    my $param = '';
    ($Corpus, $dirSuffix) = $corpDir =~ /ParlaMint-([A-Z-]+)\.TEI(\..+)?/ or die;
    $dirSuffix = '' unless $dirSuffix;
    print STDERR "INFO: Doing $Corpus TEI$dirSuffix\n";
    $bkpDir = "$corpDir$bkpSuffix";
    if ($dirSuffix) {
        print STDERR "INFO: processing TEI$dirSuffix\n";
        my $teiRoot = "$inDir/ParlaMint-$Corpus.TEI/ParlaMint-$Corpus.xml";
        if (-e $teiRoot){
            $param = " teiRoot=$teiRoot ";
        } else {
            print STDERR "WARN: ParlaMint-$Corpus.TEI/ParlaMint-$Corpus.xml is expected\n";
        }
    }
    unless (-e $bkpDir) {
	print STDERR "INFO: Creating backup in $bkpDir\n";
	`mkdir $bkpDir`;
	`cp $corpDir/*.xml $bkpDir`
    }
    $Prefix = "ParlaMint-$Corpus-";
    `rm $corpDir/*.xml`;
    $command = "$Saxon outDir=$corpDir prefix=$Prefix $param -xsl:$Factorise $bkpDir/ParlaMint-$Corpus$dirSuffix.xml";
    print STDERR "INFO: running $command\n";
    `$command`;
}
