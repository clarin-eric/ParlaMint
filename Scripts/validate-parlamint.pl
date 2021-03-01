#!/usr/bin/perl
use warnings;
use utf8;
use FindBin qw($Bin);
use File::Spec;

$schemaDir = File::Spec->rel2abs(shift);
$inDirs = File::Spec->rel2abs(shift);

binmode(STDOUT, 'utf8');
binmode(STDERR, 'utf8');

$Jing  = 'java -jar /usr/share/java/jing.jar';
$Saxon = 'java -jar /usr/share/java/saxon.jar';
$Links = "$Bin/check-links.xsl";
$Val   = "$Bin/validate-parlamint.xsl";

foreach my $inDir (glob "$inDirs") {
    next unless -d $inDir;
    print STDERR "INFO: Validating directory $inDir\n";
    my $rootFile = '';
    my $rootAnaFile = '';
    my @compFiles = ();
    my @compAnaFiles = ();
    foreach $inFile (glob "$inDir/*.xml") {
	if    ($inFile =~ m|ParlaMint-..\.xml|) {$rootFile = $inFile}
	elsif ($inFile =~ m|ParlaMint-..\.ana\.xml|) {$rootAnaFile = $inFile}
    }
    $/ = '>';
    if ($rootFile) {
	&run("$Jing $schemaDir/ParlaMint-teiCorpus.rng", $rootFile);
	&run("$Saxon -xsl:$Val", $rootFile);
	&run("$Saxon -xsl:$Links", $rootFile);
	open(IN, '<:utf8', $rootFile);
	while (<IN>) {
	    if (m|<xi:include |) {
		m| href="(.+?)"|;
		$file = "$inDir/$1";
		if (-e $file) {
		    &run("$Jing $schemaDir/ParlaMint-TEI.rng", $file);
		    &run("$Saxon -xsl:$Val", $file);
		    &run("$Saxon meta=$rootFile -xsl:$Links", $file);
		}
		else {print STDERR "ERROR: $rootFile XIncluded file $file does not exist!\n"}
	    }
	}
	close IN;
    }
    else {print STDERR "WARN: No text root file found in $inDir\n"}
    if ($rootAnaFile) {
	&run("$Jing $schemaDir/ParlaMint-teiCorpus.ana.rng", $rootAnaFile);
	&run("$Saxon -xsl:$Val", $rootAnaFile);
	&run("$Saxon -xsl:$Links", $rootAnaFile);
	open(IN, '<:utf8', $rootAnaFile);
	while (<IN>) {
	    if (m|<xi:include |) {
		m| href="(.+?)"|;
		$file = "$inDir/$1";
		if (-e $file) {
		    &run("$Jing $schemaDir/ParlaMint-TEI.ana.rng", $file);
		    &run("$Saxon -xsl:$Val", $file);
		    &run("$Saxon meta=$rootAnaFile -xsl:$Links", $file);
		}
		else {print STDERR "ERROR: $rootFile XIncluded file $file does not exist!\n"}
	    }
	}
	close IN;
    }
    else {print STDERR "WARN: No root .ana. file found in $inDir\n"}
}

sub run {
    my $command = shift;
    my $file = shift;
    my ($fName) = $file =~ m|([^/]+)$|
	or die "Bad file '$file'\n";
    if ($command =~ /$Jing/) {
	print STDERR "INFO: XML validation for $fName\n"
    }
    elsif ($command =~ /$Val/) {
	print STDERR "INFO: Content validaton for $fName\n"
    }
    elsif ($command =~ /$Links/) {
	print STDERR "INFO: Link checking for $fName\n"
    }
    else {die "Weird command!\n"}
    `$command $file 1>&2`;
}
