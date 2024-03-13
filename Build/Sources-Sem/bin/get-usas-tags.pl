#!/usr/bin/env perl
# Return all found USAS tags in CoNLL-U files
#
use warnings;
use utf8;
use open ':utf8';
binmode(STDERR, ':utf8');
$inDirs = shift;
my %usas;

foreach $inDir (glob $inDirs) {
    ($corpus) = $inDir =~ m|(ParlaMint-[A-Z-]+)[\.-]|
	or die "Strange directory $inDir\n";
    print STDERR "INFO: Processing $corpus\n";
    foreach $inYDir (glob "$inDir/*") {
	next unless $inYDir =~ m|\d\d\d\d$|;
	foreach $inFile (glob "$inYDir/*.conllu") {
	    &tei2usas($inFile);
	}
    }
}
foreach $usas (sort keys %usas) {
    print "$usas\n"
}

sub tei2usas {
    my $inFile = shift;
    open(IN, '<:utf8', $inFile) or die;
    while (<IN>) {
	next unless /\t/;
	next if /^#/;
	chomp;
	my ($n, $token, $lemma, $upos, $xpos, $ufeats, $link, $role, $extra, $local) 
	    = split /\t/;
	($usas) = $local =~ /SEM=([^|]+)/ or
	    print STDERR "ERROR: No SEM for $_\n";
	$usas =~ s/,.+//; #retain only first set of tags
	$usas{$usas}++
    }
    close IN;
}
