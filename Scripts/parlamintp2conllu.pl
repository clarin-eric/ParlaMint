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

$Para  = 'parallel --gnu --halt 0 --jobs 10';
$Saxon = 'java -jar /usr/share/java/saxon.jar';
$scriptConvert = "$Bin/parlamint2conllu.xsl";
$scriptMeta = "$Bin/parlamint2meta.xsl";
$scriptValid = "$Bin/tools/validate.py";

$country2lang{'AT'} = 'de';
$country2lang{'BA'} = 'sr';  # Should be 'bs', but UD does not support it!
$country2lang{'BE'} = 'fr, nl';
$country2lang{'BG'} = 'bg';
$country2lang{'CZ'} = 'cs';
$country2lang{'DK'} = 'da';
$country2lang{'EE'} = 'et';
$country2lang{'ES'} = 'es';
$country2lang{'ES-CT'} = 'ca, es';
$country2lang{'ES-GA'} = 'gl';
$country2lang{'ES-PV'} = 'eu, es';
$country2lang{'FI'} = 'fi';
$country2lang{'FR'} = 'fr';
$country2lang{'GB'} = 'en';
$country2lang{'GR'} = 'el';
$country2lang{'HR'} = 'hr';
$country2lang{'HU'} = 'hu';
$country2lang{'IS'} = 'is';
$country2lang{'IT'} = 'it';
$country2lang{'LT'} = 'lt';
$country2lang{'LV'} = 'lv';
$country2lang{'NL'} = 'nl';
$country2lang{'NO'} = 'no';
$country2lang{'PL'} = 'pl';
$country2lang{'PT'} = 'pt';
$country2lang{'RO'} = 'ro';
$country2lang{'RS'} = 'sr';
$country2lang{'SE'} = 'sv';
$country2lang{'SI'} = 'sl';
$country2lang{'TR'} = 'tr';
$country2lang{'UA'} = 'uk, ru';


print STDERR "INFO: Converting directory $inDir\n";
my $rootAnaFile = '';
my @compAnaFiles = ();
$inDir =~ s|[^/]+\.xml$||; # If a specific filename is given, get rid of it
$corpusFiles = "$inDir/*.ana.xml $inDir/*/*.ana.xml";
foreach $inFile (glob($corpusFiles)) {
    if ($inFile =~ m|ParlaMint-[A-Z]{2}(?:-[A-Z0-9]{1,3})?(?:-[a-z]{2,3})?\.ana\.xml|) {$rootAnaFile = $inFile}
    elsif ($inFile =~ m|ParlaMint-[A-Z]{2}(?:-[A-Z0-9]{1,3})?(?:-[a-z]{2,3})?_.+\.ana\.xml|) {push(@compAnaFiles, $inFile)}
}
my ($country, $MT) = $rootAnaFile =~ /ParlaMint-([A-Z]{2}(?:-[A-Z0-9]{1,3})?)(?:-([a-z]{2,3}))?\.ana\.xml/
    or die "Can't find country code in root file $rootAnaFile!\n";
if (defined $MT) {$langs = $MT}
else {$langs = $country2lang{$country}}
die "ERROR: Language is not defined for $country" unless defined $langs;

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

#For MTed corpora output only en metadata, for native, both xx and en
if ($MT) {@outLangs = ('en')} else {@outLangs = ('xx', 'en')}
# For orig corpora make ParlaMint-XX-meta.tsv in corpus language and ParlaMint-XX-meta-en.tsv in English
# For MTed corpora we produce ParlaMint-XX-en-meta.tsv in English
foreach my $outLang (@outLangs) {
    my $outSuffix;
    if    ($MT and $outLang eq 'xx') {}
    elsif ($MT and $outLang eq 'en') {$outSuffix = "-meta.tsv"}
    elsif ($outLang eq 'xx') {$outSuffix = "-meta.tsv"}
    elsif ($outLang eq 'en') {$outSuffix = "-meta-en.tsv"}
    if ($outSuffix) {
	$command = "$Saxon meta=$rootAnaFile" .
	    " out-lang=$outLang" .
	    " -xsl:$scriptMeta {} > $outDir/{/.}$outSuffix";
	`cat $fileFile | $Para '$command'`;
    }
}
`rename 's/\.ana//' $outDir/*-meta.tsv`;

# Produce common CoNLL-U, even if we have more languages in a corpus
if ($langs !~ /,/) {$checkLang = $langs}
else {($checkLang) = $langs =~ /(.+?),/}
$command = "$Saxon meta=$rootAnaFile -xsl:$scriptConvert {} > $outDir/{/.}.conllu";
`cat $fileFile | $Para '$command'`;
`rename 's/\.ana//' $outDir/*.conllu`;
$command = "python3 $scriptValid --lang $checkLang --level 1 {}";
`ls $outDir/*.conllu | $Para '$command'`;
$command = "python3 $scriptValid --lang $checkLang --level 2 {}"
    unless defined $MT; #MTed corpora do not have syntactic parses
`ls $outDir/*.conllu | $Para '$command'`;

# Now produce CoNLL-Us for separate langauges, if we have them
if ($langs =~ /,/) {
    foreach $lang (split(/,\s*/, $langs)) {
        $command = "$Saxon meta=$rootAnaFile seg-lang=$lang -xsl:$scriptConvert {} > $outDir/{/.}-$lang.conllu";
        `cat $fileFile | $Para '$command'`;
        `rename 's/\.ana//' $outDir/*.conllu`;
        $command = "python3 $scriptValid --lang $lang --level 1 {}";
        `ls $outDir/*.conllu | $Para '$command'`;
        $command = "python3 $scriptValid --lang $lang --level 2 {}";
        `ls $outDir/*.conllu | $Para '$command'`;
    }
}
