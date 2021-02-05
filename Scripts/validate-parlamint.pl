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

foreach my $inDir (glob "$inDirs") {
    next unless -d $inDir;
    print STDERR "INFO: Validating directory $inDir\n";
    my $rootFile = '';
    my $rootAnaFile = '';
    my @compFiles = ();
    my @compAnaFiles = ();
    foreach $inFile (glob "$inDir/*.xml") {
	my ($fName) = $inFile =~ m|([^/]+)$|
	    or die "Bad file '$inFile'!\n";
	if    ($fName =~ m|ParlaMint-..\.xml|) {$rootFile = $inFile}
	elsif ($fName =~ m|ParlaMint-..\.ana\.xml|) {$rootAnaFile = $inFile}
	elsif ($fName =~ m|ParlaMint-.._.+\.ana\.xml|) {push(@compAnaFiles, $inFile)}
	elsif ($fName =~ m|ParlaMint-.._.+\.xml|) {push(@compFiles, $inFile)}
	else {die "Bad file '$fName' in '$inFile'!\n"}
    }
    if ($rootFile) {
	&run("$Jing $schemaDir/ParlaMint-teiCorpus.rng", $rootFile);
	foreach my $file (@compFiles) {
	    &run("$Jing $schemaDir/ParlaMint-TEI.rng", $file);
	}
	foreach my $file (@compFiles) {
	    &run("$Saxon meta=$rootFile -xsl:$Links", $file);
	}
    }
    else {
	print STDERR "WARN: Couldn't find root file in $inDir/*.xml\n"
    }
    if ($rootAnaFile) {
	&run("$Jing $schemaDir/ParlaMint-teiCorpus.ana.rng", $rootAnaFile);
	foreach my $file (@compAnaFiles) {
	    &run("$Saxon meta=$rootAnaFile -xsl:$Links $file", $file);
	}
	foreach my $file (@compAnaFiles) {
	    &run("$Jing $schemaDir/ParlaMint-TEI.ana.rng", $file);
	}
    }
    else {
	print STDERR "WARN: Couldn't find ana root file in $inDir/*.xml\n"
    }
}

sub run {
    my $command = shift;
    my $file = shift;
    my ($fName) = $file =~ m|([^/]+)$|
	or die "Bad file '$file'\n";
    if ($command =~ /$Jing/) {
	print STDERR "INFO: Validating $fName\n"
    }
    elsif ($command =~ /$Links/) {
	print STDERR "INFO: Link checking $fName\n"
    }
    else {die "Weird command!\n"}
    #print STDERR "INFO: Command\n$command $file\n";
    `$command $file 1>&2`;
}
