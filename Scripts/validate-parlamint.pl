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

my $procThreads = 1;

GetOptions
    (
     'procThreads=i'=> \$procThreads,
);

$schemaDir = File::Spec->rel2abs(shift);
$inDirs = File::Spec->rel2abs(shift);

$Parallel = "parallel --keep-order --gnu --halt 2 --jobs $procThreads";
$Jing    = "java -jar $Bin/bin/jing.jar";
$Saxon   = "java -jar $Bin/bin/saxon.jar";

$Compose = "$Bin/parlamint-composite-teiHeader.xsl";
$Links   = "$Bin/check-links.xsl";
$Chars   = "$Bin/check-chars.pl";
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
    &run($Chars, $rootFile, 1);
    &run("$Jing $schemaDir/ParlaMint-teiCorpus$interfix.rng", $rootFile, 1);
    &run("$Saxon outDir=$tmpDir -xsl:$Compose", $rootFile, 1);
    &run("$Jing $schemaDir/ParlaMint.odd.rng", "$tmpDir/$fileName", 1);
    &run("$Saxon -xsl:$Valid", $rootFile, 1);
    &run("$Saxon -xsl:$Valid_particDesc", $rootFile, 1);
    &run("$Saxon -xsl:$Links", $rootFile, 1);
    @includes = split(/\n/, `$Saxon -xsl:$Includes $rootFile`);
    open(TASKS, '>:utf8', "$tmpDir/$fileName.validate-included.lst") if $procThreads > 1;
    my $runNow = !($procThreads > 1);
    while (my $f = shift @includes) {
        $file = "$inDir/$f";
        my $fileTasks = '';
        if (-e $file) {
            if($file =~ m/ParlaMint-(?:[A-Z]{2}(?:-[A-Z0-9]{1,3})?(?:-[a-z]{2,3})?)?.?(taxonomy|listPerson|listOrg).*\.xml/){
                $fileTasks .= &printMsg("INFO: Validating file included in teiHeader $file",$runNow);
                $fileTasks .= &run($Chars, $file, $runNow);
                $fileTasks .= &run("$Jing $schemaDir/ParlaMint-$1.rng", $file, $runNow);
                $fileTasks .= &run("$Saxon meta=$rootFile -xsl:$Links", $file, $runNow);
            } else {
                $fileTasks .= &printMsg("INFO: Validating component $type file $file",$runNow);
                $fileTasks .= &run($Chars, $file, $runNow);
                $fileTasks .= &run("$Jing $schemaDir/ParlaMint-TEI$interfix.rng", $file, $runNow);
                $fileTasks .= &run("$Jing $schemaDir/ParlaMint.odd.rng", $file, $runNow);
                $fileTasks .= &run("$Saxon -xsl:$Valid", $file, $runNow);
                $fileTasks .= &run("$Saxon meta=$rootFile -xsl:$Links", $file, $runNow);
            }
        }
        else {$fileTasks .= &printMsg("ERROR: $rootFile XIncluded file $file does not exist!",$runNow)}
        print TASKS "$fileTasks\n" unless $runNow ;
    }
    close TASKS if $procThreads > 1;
	`cat "$tmpDir/$fileName.validate-included.lst"| $Parallel "{}"` unless $runNow;
}

sub printMsg {
    my $msg = shift;
    my $runNow = shift;
    my $cmd = "echo -n \"$msg\\n\" 1>&2";
    `$cmd` if $runNow;
    return "$cmd ;";
}

sub run {
    my $command = shift;
    my $file = shift;
    my $runNow = shift;
    my ($fName) = $file =~ m|([^/]+)$|
        or die "FATAL ERROR: Bad file '$file'\n";
    my $msg = '';
    my $cmd = '';
    if ($command =~ /$Jing/) {
        $msg = "INFO: XML validation for $fName\\n"
    }
    elsif ($command =~ /$Compose/) {
    }
    elsif ($command =~ /$Chars/) {
    }
    elsif ($command =~ /$Valid/) {
        $msg = "INFO: Content validaton for $fName\\n"
    }
    elsif ($command =~ /$Valid_particDesc/) {
        $msg = "INFO: particDesc content validaton for $fName\\n"
    }
    elsif ($command =~ /$Links/) {
        $msg = "INFO: Link checking for $fName\\n"
    }
    else {die "FATAL ERROR: Weird command $command!\n"}
    $cmd .= "echo -n \"$msg\" 1>&2;" if $msg;
    $cmd .= "$command $file 1>&2";
    #print STDERR "### $cmd ###\n";
    `$cmd` if $runNow;
    return "$cmd ;";
}
