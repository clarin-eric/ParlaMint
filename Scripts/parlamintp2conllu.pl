#!/usr/bin/perl
# Convert ParlaMint .ana files to CoNLL-U and validate them
# Also produces meta-data .tsv files
# Tomaž Erjavec <tomaz.erjavec@ijs.si>
# License: GNU GPL

use warnings;
use utf8;
use open ':utf8';

binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

sub usage
{
    print STDERR ("Usage: parlamint2conllu.pl <InputDirectory> <OutputDirectory>\n");
    print STDERR ("       Converts ParlaMint .ana files in the <InputDirectory> to\n");
    print STDERR ("       .conllu and -meta.tsv files in the <OutputDirectory>\n");
    print STDERR ("       Also validates the .conllu agains UD validations script\n");
}
use FindBin qw($Bin);
use File::Spec;
use File::Temp qw/ tempfile tempdir /;  #creation of tmp files and directory
my $tempdirroot = "$Bin/tmp";
my $DIR = tempdir(DIR => $tempdirroot, CLEANUP => 1);

$inDir = File::Spec->rel2abs(shift);
$outDir = File::Spec->rel2abs(shift);

$Para  = 'parallel --gnu --halt 0 --jobs 8';
$Saxon = 'java -jar /usr/share/java/saxon.jar';
$Convert = "$Bin/parlamint2conllu.xsl";
$Meta = "$Bin/parlamint2meta.xsl";
$Valid = "$Bin/tools/validate.py";

$country2lang{'BG'} = 'bg';
$country2lang{'BE'} = 'fr, nl';
$country2lang{'CZ'} = 'cs';
$country2lang{'DK'} = 'da';
$country2lang{'ES'} = 'es';
$country2lang{'FR'} = 'fr';
$country2lang{'GB'} = 'en';
$country2lang{'HR'} = 'hr';
$country2lang{'HU'} = 'hu';
$country2lang{'IS'} = 'is';
$country2lang{'IT'} = 'it';
$country2lang{'LT'} = 'lt';
$country2lang{'LV'} = 'lv';
$country2lang{'NL'} = 'nl';
$country2lang{'PL'} = 'pl';
$country2lang{'RO'} = 'ro';
$country2lang{'SI'} = 'sl';
$country2lang{'TR'} = 'tr';

print STDERR "INFO: Converting directory $inDir\n";
my $rootAnaFile = '';
my @compAnaFiles = ();
$inDir =~ s|[^/]+\.xml$||; # If a specific filename is given, get rid of it
$corpusFiles = "$inDir/*.ana.xml $inDir/*/*.ana.xml";
foreach $inFile (glob($corpusFiles)) {
    if ($inFile =~ m|ParlaMint-..\.ana\.xml|) {$rootAnaFile = $inFile}
    elsif ($inFile =~ m|ParlaMint-.._.+\.ana\.xml|) {push(@compAnaFiles, $inFile)}
}
my ($country) = $rootAnaFile =~ /ParlaMint-(..)\.ana\.xml/
    or die "Can't find country code in root file $rootAnaFile!\n";
my ($langs) = $country2lang{$country};

#Store all files to be processed in $fileFile
$fileFile = "$DIR/files.lst";
open(TMP, '>:utf8', $fileFile);
foreach $inFile (@compAnaFiles) {
    print TMP "$inFile\n"
}
close TMP;

`mkdir $outDir` unless -e "$outDir";
`rm -f $outDir/*-meta.tsv`;
`rm -f $outDir/*.conllu`;

$command = "$Saxon hdr=$rootAnaFile -xsl:$Meta {} > $outDir/{/.}-meta.tsv";
`cat $fileFile | $Para '$command'`;
`rename 's/\.ana//' $outDir/*-meta.tsv`;

if ($langs !~ /,/) {
    $command = "$Saxon meta=$rootAnaFile -xsl:$Convert {} > $outDir/{/.}.conllu";
    `cat $fileFile | $Para '$command'`;
    `rename 's/\.ana//' $outDir/*.conllu`;
    $command = "python3 $Valid --lang $langs --level 1 {}";
    `ls $outDir/*.conllu | $Para '$command'`;
    $command = "python3 $Valid --lang $langs --level 2 {}";
    `ls $outDir/*.conllu | $Para '$command'`;
}
else {
    foreach $lang (split(/,\s*/, $langs)) {
	$command = "$Saxon meta=$rootAnaFile seg-lang=$lang -xsl:$Convert {} > $outDir/{/.}-$lang.conllu";
	`cat $fileFile | $Para '$command'`;
	`rename 's/\.ana//' $outDir/*.conllu`;
	$command = "python3 $Valid --lang $lang --level 1 {}";
	`ls $outDir/*.conllu | $Para '$command'`;
	$command = "python3 $Valid --lang $lang --level 2 {}";
	`ls $outDir/*.conllu | $Para '$command'`;
    }
}
