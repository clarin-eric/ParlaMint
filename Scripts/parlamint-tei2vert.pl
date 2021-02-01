#!/usr/bin/perl
use warnings;
use utf8;
use FindBin qw($Bin);
use File::Spec;

$rootFile = File::Spec->rel2abs(shift);
$inFiles = shift;
$outDir = shift;

binmode(STDERR, 'utf8');

`mkdir $outDir` unless -e "$outDir";

#Fix noske beta!
#$Saxon = 'java -jar /home/tomaz/bin/saxon.jar';
$Saxon = 'java -jar /usr/share/java/saxon.jar';
$TEI2VERT  = "$Bin/parlamint2xmlvert.xsl";
$POLISH = "$Bin/parlamint-xml2vert.pl";


binmode(STDERR,'utf8');

die "Can't find root TEI file with teiHeader: $rootFile\n"
    unless -e $rootFile;

foreach $inFile (glob $inFiles) {
    if (($fName) = $inFile =~ m|(ParlaMint-.._[^/]+)\.ana\.xml|) {
	print STDERR "INFO: Converting $fName\n";
    }
    elsif (($fName) = $inFile =~ m|(ParlaMint-.._[^/]+)\.xml|) {
	print STDERR "INFO: Debug conversion of $fName\n";
    }
    else {die "Weird input file $inFile\n"}
    my $outFile = "$outDir/$fName.vert";
    $command = "$Saxon hdr=$rootFile -xsl:$TEI2VERT $inFile | $POLISH > $outFile";
    #print STDERR "\$ $command\n";
    my $status = system($command);
    die "ERROR: Conversion to vert for $inFile failed!\n"
	if $status;
}
