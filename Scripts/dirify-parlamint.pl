#!/usr/bin/perl
# If a directory has more than $MAX files, store them in year directories
# Tomaž Erjavec <tomaz.erjavec@ijs.si>
# License: GNU GPL

use warnings;
use utf8;
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

use File::Copy;
use File::Spec;
$inDirs = File::Spec->rel2abs(shift);
$MAX = 1; # In ParlaMint II components are always stored in YYYY subdirs!
foreach my $inDir (glob "$inDirs") {
    print STDERR "INFO: Doing directory $inDir\n";
    @files = glob "$inDir/*";
    if (scalar @files > $MAX) {
        foreach $file (@files) {
            if (($year) = $file =~ m|ParlaMint-[A-Z]{2}(?:-[A-Z0-9]{1,3})?(?:-[a-z]{2,3})?_(\d\d\d\d)|) {
                $newDir = "$inDir/$year";
                mkdir($newDir) unless -d $newDir;
                move($file, $newDir);
            }
        }
    }
    else {print STDERR "INFO: Nothing to do\n"}
}
