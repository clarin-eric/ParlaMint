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
$MAX = 1023;
foreach my $inDir (glob "$inDirs") {
    print STDERR "INFO: Doing directory $inDir\n";
    @files = glob "$inDir/*";
    if (scalar @files > $MAX) {
	foreach $file (@files) {
	    if (($year) = $file =~ m|ParlaMint-.._(\d\d\d\d)|) {
		$newDir = "$inDir/$year";
		mkdir($newDir) unless -d $newDir;
		move($file, $newDir);
	    }
	}
    }
    else {print STDERR "INFO: Nothing to do\n"}
}
