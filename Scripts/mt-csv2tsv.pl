#!/usr/bin/env perl
# From MTed csv file + CoNLL-U file make TSV with sentence ID and translation
# Tomaž Erjavec <tomaz.erjavec@ijs.si>
# License: GNU GPL

use warnings;
use utf8;
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

$inDirs = shift;
$csv_ext = '.eng.csv';
$conll_ext = '.conllu';
$tsv_ext = '-en.tsv';

foreach my $csv_file (glob "$inDirs/*$csv_ext $inDirs/*/*$csv_ext") {
    print STDERR "INFO: Doing file $csv_file\n";
    ($fName) = $csv_file =~ m|(.+)\Q$csv_ext\E|;
    $conll_file = $fName . $conll_ext;
    die "Cant find $conll_file!\n" unless -e $conll_file;
    $tsv_file = "$fName$tsv_ext";
    open(META, '<:utf8', $conll_file) or die "Cant find $conll_file!\n";
    @sents = ();
    while (<META>) {
	chomp;
	if (m|# sent_id = (.+)|) {
	    push(@sents, $1)
	}
    }
    close META;
    open(OUT, '>:utf8', $tsv_file) or die "Cant open $tsv_file!\n";
    open(IN, '<:utf8', $csv_file) or die "Cant find $csv_file!\n";
    while (<IN>) {
	next if /^file/;
	chomp;
	($text) = /.+?,.+?,(.+)/;
	die "TAB in text $text!\n" if $text =~ /\t/;
	$text =~ s/^"//;
	$text =~ s/"$//;
	$text =~ s/""/"/g;
	die "No more sentence IDs!\n" unless @sents;
	$id = shift @sents;
	print OUT "$id\t$text\n"
    }
    close IN;
    close OUT;
    die "Too many sentence IDs!\n" if @sents;
}
