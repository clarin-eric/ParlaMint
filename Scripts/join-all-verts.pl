#!/usr/bin/env perl
# Join all ParlaMint vert files into one, in reverse chronological order

use warnings;
use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

sub usage {
    print STDERR ("Usage:\n");
    print STDERR ("$0 -help\n");
    print STDERR ("$0 ");
    print STDERR (" [<procFlags>] -codes '<Codes>' -in <InputDirectory> -out <OutputFile>\n");
    print STDERR ("    Joins .vert files in reverse order.\n");
    print STDERR ("    <Codes> is the list of country codes of the corpora to be processed.\n");
    print STDERR ("    <InputFiles> is all the files that will be joined.\n");
    print STDERR ("    <OutputFile> is the output vertical gzipped file.\n");
    print STDERR ("    <procFlags> are process flags that set which operations are carried out:\n");
    print STDERR ("    * -en: finalizes the corpora translated to English\n");
}

use Getopt::Long;
#use File::Spec;
use FindBin qw($Bin);
use File::Temp qw/ tempfile tempdir /;  #creation of tmp files and directory
my $tempdirroot = "$Bin/tmp";
my $tmpDir = tempdir(DIR => $tempdirroot, CLEANUP => 1);

GetOptions
    (
     'help'     => \$help,
     'codes=s'  => \$countryCodes,
     'in=s'     => \$inDir,
     'out=s'    => \$outFile,
     'en!'      => \$procEn,
);

if ($help) {
    &usage;
    exit;
}

foreach my $countryCode (split(/[, ]+/, $countryCodes)) {
    if ($procEn) {$countryCode .= '-en'};    
    print STDERR "INFO: Gathering files for $countryCode\n";
    $inVertDir = "$inDir/ParlaMint-$countryCode.vert";
    die "FATAL ERROR: Can't find $inVertDir\n" unless -e $inVertDir;
    foreach $inFile (glob "$inVertDir/*/*.vert") {
	($date) = $inFile =~ m|_(\d\d\d\d-\d\d-\d\d)|
	    or die "FATAL ERROR: Strange $inFile\n";
	$key = $date . "_" . $countryCode;
	if (exists $files{$key}) {$files{$key} .= "\t$inFile"}
	else {$files{$key} = "$inFile"}
    }
}
open(OUT, '>:utf8', $outFile) or die "FATAL ERROR: Can't open $outFile!\n";
$oldYear = '0';
# Sorting in reverse order!
foreach $key (reverse sort keys %files) {
    ($year, $countryCode) = $key =~ /(\d\d\d\d).*_(.+)/;
    if ($oldYear != $year) {
	print STDERR "INFO: Writing $year\n";
	$oldYear = $year
    }
    foreach my $inFile (split(/\t/, $files{$key})) {
	open(IN, '<:utf8', $inFile) or die;
	while (<IN>) {
	    #Add corpus attribute to speech and note
	    if (m|<speech | or m|<note |) {
		s| | corpus="$countryCode" |;
	    }
	    print OUT
	}
	close IN;
    }
}
close OUT;
print STDERR "INFO: Compressing $outFile\n";
`rm -f $outFile.gz`;
`gzip $outFile`;
