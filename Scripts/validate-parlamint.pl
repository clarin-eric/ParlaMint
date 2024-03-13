#!/usr/bin/env perl
# Validate ParlaMint files
# Tomaž Erjavec <tomaz.erjavec@ijs.si>
# License: GNU GPL

use warnings;
use utf8;
use open ':utf8';

use File::Temp qw/ tempfile tempdir /;  #creation of tmp files and directory
my $tempdirroot = "$Bin/tmp";

mkdir($tempdirroot) unless(-d $tempdirroot);
my $tmpDir = tempdir(DIR => $tempdirroot, CLEANUP => 1);

binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

sub usage
{
    print STDERR ("Usage: validate-parlamint.pl <SchemaDirectory> '<InputDirectories>'\n");
    print STDERR ("       Produces a validation report on ParlaMint XML files in the <InputDirectories>:\n");
    print STDERR ("       * validation for illegal characters (like soft hyphen, PUA)\n");
    print STDERR ("       * validation against ParlaMint RNG schemas in <SchemaDirectory> (with jing)\n");
    print STDERR ("       * validation against ParlaMint ODD schema in <SchemaDirectory> (with jing)\n");
    print STDERR ("       * link (IDREF) checking (with saxon, check-links.xsl)\n");
    print STDERR ("       * content checking (with saxon, validate-parlamint.xsl)\n");
    print STDERR ("       - still separately, Dan's UD validation of CoNLL-U files (cf. Makefile)\n");
}
use Getopt::Long;
use FindBin qw($Bin);
use File::Spec;

$schemaDir = File::Spec->rel2abs(shift);
$inDirs = File::Spec->rel2abs(shift);

$Jing    = "java -jar $Bin/bin/jing.jar";
$Saxon   = "java -jar $Bin/bin/saxon.jar";

$Compose = "$Bin/parlamint-composite-teiHeader.xsl";
$Links   = "$Bin/check-links.xsl";
$Valid   = "$Bin/validate-parlamint.xsl";
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
        if ($inFile =~ m|(ParlaMint-[A-Z]{2}(?:-[A-Z0-9]{1,3})?(?:-[a-z]{2,3})?\.xml)|) {
            $fileName = $1;
            $rootFile = $inFile;
        }
        elsif ($inFile =~ m|(ParlaMint-[A-Z]{2}(?:-[A-Z0-9]{1,3})?(?:-[a-z]{2,3})?\.ana\.xml)|) {
            $fileNameAna = $1;
            $rootAnaFile = $inFile
        }
    }
    $/ = '>';
    if (not $rootFile and not $rootAnaFile) {
        die "FATAL ERROR: Cannot find root file in $inDir!\n"
    }
    if ($rootFile) {
        validate($inDir,$rootFile,$fileName,'TEI');
    }
    else {
        # print STDERR "WARN: No text root file found in $inDir\n"
    }
    if ($rootAnaFile) {
        validate($inDir,$rootAnaFile,$fileNameAna,'TEI.ana');
    }
    else {
        # print STDERR "WARN: No root .ana. file found in $inDir\n"
    }
}

sub validate {
    my $inDir = shift;
    my $rootFile = shift;
    my $fileName = shift;
    my $type = shift;
    my $interfix = $type;
    $interfix =~ s/^TEI//;
    print STDERR "INFO: Validating $type root $rootFile\n";
    &chars($rootFile);
    &run("$Jing $schemaDir/ParlaMint-teiCorpus$interfix.rng", $rootFile);
    &run("$Saxon outDir=$tmpDir -xsl:$Compose", $rootFile);
    &run("$Jing $schemaDir/ParlaMint.odd.rng", "$tmpDir/$fileName");
    &run("$Saxon -xsl:$Valid", $rootFile);
    &run("$Saxon -xsl:$Valid_particDesc", $rootFile);
    &run("$Saxon -xsl:$Links", $rootFile);
    @includes = split(/\n/, `$Saxon -xsl:$Includes $rootFile`);
    while (my $f = shift @includes) {
        $file = "$inDir/$f";
        if (-e $file) {
            if($file =~ m/ParlaMint-(?:[A-Z]{2}(?:-[A-Z0-9]{1,3})?(?:-[a-z]{2,3})?)?.?(taxonomy|listPerson|listOrg).*\.xml/){
                print STDERR "INFO: Validating file included in teiHeader $file\n";
                &chars($file);
                &run("$Jing $schemaDir/ParlaMint-$1.rng", $file);
                &run("$Saxon meta=$rootFile -xsl:$Links", $file);
            } else {
                print STDERR "INFO: Validating component $type file $file\n";
                &chars($file);
                &run("$Jing $schemaDir/ParlaMint-TEI$interfix.rng", $file);
                &run("$Jing $schemaDir/ParlaMint.odd.rng", $file);
                &run("$Saxon -xsl:$Valid", $file);
                &run("$Saxon meta=$rootFile -xsl:$Links", $file);
            }
        }
        else {print STDERR "ERROR: $rootFile XIncluded file $file does not exist!\n"}
    }
}

# Check if $file contains bad characters
sub chars {
    my $file = shift;
    my %c;
    my @bad = ();
    my ($fName) = $file =~ m|([^/]+)$|
        or die "Bad file '$file'\n";
    print STDERR "INFO: Char validation for $fName\n";
    open(IN, '<:utf8', $file);
    undef $/;
    my $txt = <IN>;
    undef %c;
    for $c (split(//, $txt)) {$c{$c}++}
    for $c (sort keys %c) {
      if (ord($c) == hex('00A0') or  #NO-BREAK SPACE
          ord($c) == hex('2011') or  #NON-BREAKING HYPHEN
          ord($c) == hex('00AD') or  #SOFT HYPHEN
          ord($c) == hex('FFFD') or  #REPLACEMENT CHAR
          (ord($c) >= hex('2000') and ord($c) <= hex('200A')) or #NON-STANDARD SPACES
          (ord($c) >= hex('E000') and ord($c) <= hex('F8FF'))    #PUA
          ) {
          $message = sprintf("U+%X (%dx)", ord($c), $c{$c});
          push(@bad, $message)
      }
    }
    print STDERR "WARN: File $fName contains bad chars: " . join('; ', @bad) . "\n"
      if @bad
}
   
sub run {
    my $command = shift;
    my $file = shift;
    my ($fName) = $file =~ m|([^/]+)$|
        or die "Bad file '$file'\n";
    if ($command =~ /$Jing/) {
        print STDERR "INFO: XML validation for $fName\n"
    }
    elsif ($command =~ /$Compose/) {
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
    else {die "Weird command $command!\n"}
    `$command $file 1>&2`;
}
