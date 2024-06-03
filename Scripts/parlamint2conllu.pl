#!/usr/bin/env perl
# Convert ParlaMint .ana files to CoNLL-U and validate them
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
    print STDERR ("       .conllu files in the <OutputDirectory>\n");
    print STDERR ("       Also validates the .conllu agains UD validations script\n");
    print STDERR ("       Note that the processing is specific to the current set of ParlaMint corpora.\n");
}
use FindBin qw($Bin);
use File::Spec;

$inDir = File::Spec->rel2abs(shift);
$outDir = File::Spec->rel2abs(shift);

#$Para  = 'parallel --gnu --halt 2 --jobs 10';
$Saxon   = "java -jar $Bin/bin/saxon.jar";
$Convert = "$Bin/parlamint2conllu.xsl";
$scriptValid = "$Bin/bin/tools/validate.py";

$country2lang{'AT'} = 'de';
$country2lang{'BA'} = 'bs';
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
$inDir =~ s|[^/]+\.xml$||; # If specific (hopefully root) filename give, get rid of it
$corpusFiles = "$inDir/*.ana.xml $inDir/*/*.ana.xml";
foreach $inFile (glob($corpusFiles)) {
    if ($inFile =~ m|ParlaMint-[A-Z]{2}(?:-[A-Z0-9]{1,3})?(?:-[a-z]{2,3})?\.ana\.xml|) {$rootAnaFile = $inFile}
    elsif ($inFile =~ m|ParlaMint-[A-Z]{2}(?:-[A-Z0-9]{1,3})?(?:-[a-z]{2,3})?_.+\.ana\.xml|) {push(@compAnaFiles, $inFile)}
}
`rm -f $inDir/*.conllu`;
foreach $inFile (@compAnaFiles) {
    my ($fName) = $inFile =~ m|([^/]+)\.ana\.xml|;
    # if the language is present in filename, then use that language otherwise language from country2lang is used
    my ($country, $langs) = $inFile =~ /.*ParlaMint-([A-Z]{2}(?:-[A-Z0-9]{1,3})?)(?:-([a-z]{2,3}))?/
        or die "FATAL ERROR: Wrong filename $inFile";
    $langs = $country2lang{$country} unless defined $langs;
    die "FATAL ERROR: Language is not defined for $country" unless defined $langs;
    #One corpus, one language
    if ($langs !~ /,/) {$checkLang = $langs}
    else {($checkLang) = $langs =~ /(.+?),/}
    my $outFile = "$outDir/$fName.conllu";
    &run("$Saxon meta=$rootAnaFile -xsl:$Convert $inFile > $outFile", $fName);
    &run("python3 $scriptValid --lang $checkLang --level 1 $outFile", "level 1: $fName");
    &run("python3 $scriptValid --lang $checkLang --level 2 $outFile", "level 2: $fName");
    #&run("python3 $scriptValid --lang $checkLang --level 3 $outFile", "level 3: $fName");

    #One corpus, several languages, several files (BE = nl, fr)
    if ($langs =~ /,/) {
        foreach $lang (split(/,\s*/, $langs)) {
            my $outFile = "$outDir/$fName-$lang.conllu";
            &run("$Saxon meta=$rootAnaFile seg-lang=$lang -xsl:$Convert $inFile > $outFile", $fName);
            &run("python3 $scriptValid --lang $lang --level 1 $outFile", "level 1: $fName");
            &run("python3 $scriptValid --lang $lang --level 2 $outFile", "level 2: $fName");
            #&run("python3 $scriptValid --lang $lang --level 3 $outFile", "level 3: $fName");
        }
    }
}

sub run {
    my $command = shift;
    my $info = shift;
    if ($command =~ /$Convert/) {
        print STDERR "INFO: Converting $info\n"
    }
    elsif ($command =~ /$scriptValid/) {
        print STDERR "INFO: Validating $info\n"
    }
    else {die "FATAL ERROR: Weird command!\n"}
    #`$command 1>&2`;
    `$command`;
}
