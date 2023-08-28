#!/usr/bin/perl
use warnings;
use utf8;
use FindBin qw($Bin);
use File::Spec;

$rootFile = File::Spec->rel2abs(shift);
$outDir = shift;

($rootDir) = $rootFile =~ m|(.+)/|;

binmode(STDERR, 'utf8');

`mkdir $outDir` unless -e "$outDir";

$Saxon = 'java -jar /usr/share/java/saxon.jar';
$TEI2VERT  = "$Bin/parlamint2xmlvert.xsl";
$POLISH = "$Bin/parlamint-xml2vert.pl";
$Includes = "$Bin/get-includes.xsl";

die "Can't find root TEI file with teiHeader: $rootFile\n"
    unless -e $rootFile;

my @inFiles = map {"$rootDir/$_"}
              grep {!/ParlaMint-(?:[A-Z]{2}(?:-[A-Z0-9]{1,3})?(?:-[a-z]{2,3})?)?.?(taxonomy|listPerson|listOrg).*\.xml/}
              split(/\n/, `$Saxon -xsl:$Includes $rootFile`);

die "ERROR: No component files in $rootFile\n" unless @inFiles;

foreach $inFile (@inFiles) {
    if (($fName) = $inFile =~ m|(ParlaMint-[A-Z]{2}(?:-[A-Z0-9]{1,3})?(?:-[a-z]{2,3})?_[^/]+)\.ana\.xml|) {
        print STDERR "INFO: Converting $fName\n";
    }
    elsif (($fName) = $inFile =~ m|(ParlaMint-[A-Z]{2}(?:-[A-Z0-9]{1,3})?(?:-[a-z]{2,3})?_[^/]+)\.xml|) {
        print STDERR "INFO: Debug conversion of $fName\n";
    }
    else {die "Weird input file $inFile\n"}
    my $outFile = "$outDir/$fName.vert";
    $command = "$Saxon meta=$rootFile -xsl:$TEI2VERT $inFile | $POLISH > $outFile";
    #print STDERR "\$ $command\n";
    my $status = system($command);
    die "ERROR: Conversion to vert for $inFile failed!\n"
        if $status;
}
