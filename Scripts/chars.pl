#!/usr/bin/perl -w
#Give a list of all characters for input files
use utf8;
#Ignore XML tags? (if they are in one line)
$XML = 1;

my @INFILES = glob(shift);
my $OUTDIR = shift;

binmode(STDOUT,'utf8');
binmode(STDERR,'utf8');
foreach $file (@INFILES) {
    #($fName)=$file=~m|([^/]+)\.txt|;
    $fName=$file;
    open(TBL,$file);
    binmode(TBL,'utf8');
    undef %c;
    while (<TBL>) {
	if ($XML) {
	    s|<[^>]+>||gso;
	    s|&lt;|<|g;
	    s|&gt;|>|g;
	    s|&apos;|'|g;
	    s|&quot;|"|g;
	    s|&amp;|&|g;
	}
	for $c (split(//)) {
	    #$code = sprintf("%04X", ord($c));
	    if    (ord($c) < 33) {$c="&#".ord($c).';'}
	    elsif ($c eq "&")  {$c = '&#38;'}
	    elsif ($c eq ":")  {$c = '&#58;'}
	    $c{$c}++;
	}
    }
    close TBL;
    $n=0;
    @chars=();
    for $c (sort keys %c) {
	push(@chars,"$c:$c{$c}");
	$n+=$c{$c};
    }
    print "$fName\t$n\t".join(" ",@chars)."\n";
}
