#!/usr/bin/env perl
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
$pattern = 'ParlaMint-[A-Z]{2}(?:-[A-Z0-9]{1,3})?(?:-[a-z]{2,3})?';
foreach my $inDir (glob "$inDirs") {
    print STDERR "INFO: Doing directory $inDir\n";
    @files = glob "$inDir/*";
    if (scalar @files > $MAX) {
        foreach $file (@files) {
            if (($year) = $file =~ m|$pattern\_(\d\d\d\d)|) {
                $newDir = "$inDir/$year";
                mkdir($newDir) unless -d $newDir;
                move($file, $newDir);
            }
	    elsif ($file =~ m|$pattern(\.ana)?\.xml|) {
		$tmpFile = "$inDir/root.xml";
		open(IN, '<:utf8', $file);
		open(OUT, '>:utf8', $tmpFile);
		$/ = '>';
		while (<IN>) {
		    if (m|<(xi:)?include |
			and ($href) = m| href="(.+?)"|
			and ($year) = $href =~ m|$pattern\_(\d\d\d\d)|
			and not $href =~ m|/|) {
			s|href="|href="$year/|;
		    }
		    print OUT
		}
		close IN;
		close OUT;
                move($tmpFile, $file);
	    }

        }
    }
    else {print STDERR "INFO: Nothing to do\n"}
}
