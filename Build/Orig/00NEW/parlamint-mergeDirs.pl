#!/usr/bin/perl
# Given a ParlaMint corpus prefix ParlaMint-XX, creates the directory and
# copies into it the contents of ParlaMint-XX.TEI and ParlaMint-XX.TEI.ana
# It is assumed that all 3 directories are in a common directory

use warnings;
use utf8;
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

use File::Copy::Recursive qw(dircopy);

$outDir = shift;

die "Bad input argument $prefix\n"
    unless ($prefix) = $outDir =~ /(ParlaMint-..(-..)?)$/;

$teiDir = $outDir . ".TEI";
$anaDir = $outDir . ".TEI.ana";

if (-e $teiDir) {
    print STDERR "Copying .TEI to $prefix\n";
    $n = dircopy($teiDir, $outDir);
    print STDERR "Copied $n directories and files\n";
}
else {print STDERR "$teiDir not found, skipping!\n"}

if (-e $anaDir) {
    print STDERR "Copying .TEI.ana to $prefix\n";
    $n = dircopy($anaDir, $outDir);
    print STDERR "Copied $n directories and files\n";
}
else {print STDERR "$anaDir not found, skipping!\n"}

