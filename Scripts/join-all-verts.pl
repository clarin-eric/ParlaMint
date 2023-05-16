#!/usr/bin/perl
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
    print STDERR (" -in <InputFiles> -out <OutputFile>\n");
    print STDERR ("    Joins .vert files in reverse order.\n");
    print STDERR ("    <InputFiles> is all the files that will be joined.\n");
    print STDERR ("    <OutputFile> is the output vertical gzipped file.\n");
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
     'in=s'     => \$inFiles,
     'out=s'    => \$outVertFile,
);

if ($help) {
    &usage;
    exit;
}

$lastCountry = '';
foreach my $inFile (glob $inFiles) {
    ($fileName) =  $inFile =~ m|([^/]+)$|;
    ($country, $date) = $fileName =~ m|.+?-(.+?)_(\d\d\d\d-\d\d-\d\d)|
	or die "Strange $fileName\n";
    print STDERR "INFO: Doing $country\n" unless $lastCountry eq $country;
    $lastCountry = $country;
    $outDir = "$tmpDir/$date";
    `mkdir -p $outDir`;
    $outFile = "$outDir/$fileName";
    open(IN, '<:utf8', $inFile) or die;
    open(OUT, '>:utf8', $outFile) or die;
    #Add corpus attribute to speech and note
    while (<IN>) {
	if (m|<speech | or m|<note |) {
	    s| | corpus="$country" |;
	}
	print OUT
    }
    close IN;
    close OUT;
}

#Remove old output file, remove gzip extension if there, will be added later
`rm -f $outVertFile`;
$outVertFile =~ s/\.gz//;
`rm -f $outVertFile`;

print STDERR "INFO: Joining verts to $outVertFile\n";
foreach my $dayDir (reverse glob "$tmpDir/*") {
    foreach my $inFile (glob "$dayDir/*") {
	`cat $inFile >> $outVertFile`
    }
}
`gzip $outVertFile`;
