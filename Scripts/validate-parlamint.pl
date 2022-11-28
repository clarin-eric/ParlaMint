#!/usr/bin/perl
# Validate ParlaMint files
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
    print STDERR ("Usage: validate-parlamint.pl <SchemaDirectory> '<InputDirectories>'\n");
    print STDERR ("       Produces a validation report on ParlaMint XML files in the <InputDirectories>:\n");
    print STDERR ("       * validation against ParlaMint RNG schemas in <SchemaDirectory> (with jing)\n");
    print STDERR ("       * link (IDREF) checking (with saxon, check-links.xsl)\n");
    print STDERR ("       * content checking (with saxon, validate-parlamint.xsl)\n");
    print STDERR ("       - still separately, Dan's UD validation of CoNLL-U files (cf. Makefile)\n");
}
use Getopt::Long;
use FindBin qw($Bin);
use File::Spec;

$schemaDir = File::Spec->rel2abs(shift);
$inDirs = File::Spec->rel2abs(shift);

$Jing  = 'java -jar /usr/share/java/jing.jar';
$Saxon = 'java -jar /usr/share/java/saxon.jar';
$Links = "$Bin/check-links.xsl";
$Valid = "$Bin/validate-parlamint.xsl";
$Valid_particDesc = "$Bin/validate-parlamint-particDesc.xsl";
$Includes = "$Bin/get-includes.xsl";

foreach my $inDir (glob "$inDirs") {
    next unless -d $inDir;
    print STDERR "INFO: Validating directory $inDir\n";
    my $rootFile = '';
    my $rootAnaFile = '';
    my @compFiles = ();
    my @compAnaFiles = ();
    foreach $inFile (glob "$inDir/*.xml") {
        if    ($inFile =~ m|ParlaMint-[A-Z]{2}(?:-[A-Z0-9]{1,3})?(?:-[a-z]{2,3})?\.xml|) {$rootFile = $inFile}
        elsif ($inFile =~ m|ParlaMint-[A-Z]{2}(?:-[A-Z0-9]{1,3})?(?:-[a-z]{2,3})?\.ana\.xml|) {$rootAnaFile = $inFile}
    }
    $/ = '>';
    if (not $rootFile and not $rootAnaFile) {
        die "FATAL: Cannot file root file in $inDir!\n"
    }
    if ($rootFile) {
        print STDERR "INFO: Validating TEI root $rootFile\n";
        &run("$Jing $schemaDir/ParlaMint-teiCorpus.rng", $rootFile);
        &run("$Saxon -xsl:$Valid", $rootFile);
        &run("$Saxon -xsl:$Valid_particDesc", $rootFile);
        &run("$Saxon -xsl:$Links", $rootFile);
        @includes = split(/\n/, `$Saxon -xsl:$Includes $rootFile`);
        while (my $f = shift @includes) {
            $file = "$inDir/$f";
            if (-e $file) {
                if($file =~ m/ParlaMint-(?:[A-Z]{2}(?:-[A-Z0-9]{1,3})?(?:-[a-z]{2,3})?)?.?(taxonomy|listPerson|listOrg).*\.xml/){
                    print STDERR "INFO: Validating file included in teiHeader $file\n";
                    &run("$Jing $schemaDir/ParlaMint-$1.rng", $file);
                } else {
                    print STDERR "INFO: Validating component TEI file $file\n";
                    &run("$Jing $schemaDir/ParlaMint-TEI.rng", $file);
                    &run("$Saxon -xsl:$Valid", $file);
                    &run("$Saxon meta=$rootFile -xsl:$Links", $file);
                }
            }
            else {print STDERR "ERROR: $rootFile XIncluded file $file does not exist!\n"}
        }
    }
    else {
        # print STDERR "WARN: No text root file found in $inDir\n"
    }
    if ($rootAnaFile) {
        print STDERR "INFO: Validating TEI.ana root $rootAnaFile\n";
        &run("$Jing $schemaDir/ParlaMint-teiCorpus.ana.rng", $rootAnaFile);
        &run("$Saxon -xsl:$Valid", $rootAnaFile);
        &run("$Saxon -xsl:$Valid_particDesc", $rootAnaFile);
        &run("$Saxon -xsl:$Links", $rootAnaFile);
        @includes = split(/\n/, `$Saxon -xsl:$Includes $rootAnaFile`);
        while (my $f = shift @includes) {
            $file = "$inDir/$f";
            if (-e $file) {
                if($file =~ m/ParlaMint-(?:[A-Z]{2}(?:-[A-Z0-9]{1,3})?(?:-[a-z]{2,3})?)?.?(taxonomy|listPerson|listOrg).*\.xml/){
                    print STDERR "INFO: Validating file included in teiHeader $file\n";
                    &run("$Jing $schemaDir/ParlaMint-$1.rng", $file);
                    &run("$Saxon meta=$rootAnaFile -xsl:$Links", $file);
                } else {
                    print STDERR "INFO: Validating component TEI.ana file $file\n";
                    &run("$Jing $schemaDir/ParlaMint-TEI.ana.rng", $file);
                    &run("$Saxon -xsl:$Valid", $file);
                    &run("$Saxon meta=$rootAnaFile -xsl:$Links", $file);
                }
            }
            else {print STDERR "ERROR: $rootAnaFile XIncluded file $file does not exist!\n"}
        }
    }
    else {
        # print STDERR "WARN: No root .ana. file found in $inDir\n"
    }
}

sub run {
    my $command = shift;
    my $file = shift;
    my ($fName) = $file =~ m|([^/]+)$|
        or die "Bad file '$file'\n";
    if ($command =~ /$Jing/) {
        print STDERR "INFO: XML validation for $fName\n"
    }
    elsif ($command =~ /$Valid/) {
        print STDERR "INFO: Content validaton for $fName\n"
    }
    elsif ($command =~ /$Valid_particDesc/) {
        print STDERR "INFO: particDesc content validaton for $fName\n"
    }
    elsif ($command =~ /$Links/) {
        print STDERR "INFO: Link checking for $fName\n"
    }
    else {die "Weird command!\n"}
    `$command $file 1>&2`;
}
