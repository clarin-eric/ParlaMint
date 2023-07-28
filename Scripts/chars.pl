#!/usr/bin/perl -w
#Give a list of all characters for input files
use utf8;
my @INFILES = glob(shift);
my $OUTDIR = shift;
binmode(STDOUT,'utf8');
binmode(STDERR,'utf8');
foreach $file (@INFILES) {
    #($fName) = $file =~ m|([^/]+)\.txt|;
    print STDERR "Processing $file\n";
    if ($file =~ m|\.xml$|) {$format = 'xml'}
    elsif ($file =~ m|\.txt$|) {$format = 'text'}
    else {$format = 'text'}
    $fName=$file;
    open(TBL, '<:utf8', $file) or die;
    undef $/;
    $txt = <TBL>;
    undef %c;
    if ($format eq 'xml') {
        $txt =~ s| +||g; #most spaces are fake spaces
        $txt =~ s|<[^>]+>||g;
        $txt =~ s|&lt;|<|g;
        $txt =~ s|&gt;|>|g;
        $txt =~ s|&apos;|'|g;
        $txt =~ s|&quot;|"|g;
        $txt =~ s|&amp;|&|g;
    }
    for $c (split(//, $txt)) {
        if    (ord($c) < 33) {$c="&#".ord($c).';'}
        elsif ($c eq "&")  {$c = '&#38;'}
        elsif ($c eq ":")  {$c = '&#58;'}
        $c{$c}++;
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
