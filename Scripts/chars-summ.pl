#!/usr/bin/perl -w
use utf8;
use charnames ();
binmode(STDIN,'utf8');
binmode(STDOUT,'utf8');
binmode(STDERR,'utf8');

$UNIFILE = 'UnicodeData.txt';
if (-e $UNIFILE) {
    open(TBL,$UNIFILE);
    while (<TBL>) {
        if (/^([0-9A-F]+);(.+?);/) {
            $uni{$1}=$2;
        }
    }
    close TBL;
    $localUni='1';
}
else {
    $localUni='0';
}

while (<>) {
    next unless /\t/;
    $f_all++;
    next if /\t0\t/;
    my ($fid, $fwc, $chars) = split(/\t/);
    foreach $pair (split(/ /, $chars)) {
        ($char, $i) = $pair =~ /(.+):(\d+)/ or die "Bad line $_";
        if (($ord) = $char =~ /&#(\d+);/) {$c = chr($ord)}
        elsif ($char =~ /^.$/) {$c = $char; $ord = ord($c)}
        else {
            print STDERR "Long char '$char' for $fid!\n";
            next
        }
        $c_all += $i;
        $c{$c} += $i;
        $f{$c}++;
        #$fe{$c}="$fid / $fwc";
    }
}
print "Code\tChar\tOccurs\t\%\tIn docs\t\%\tUnicode name\n";
foreach $chr (sort keys %c) {
    $c_type++;
    #print STDERR "$chr\n";
    $ccnt = sprintf("%10d", $c{$chr});
    $fcnt = sprintf("%8d",  $f{$chr});
    $cpc  = sprintf("%5.2f", 100*($ccnt/$c_all));
    $fpc  = sprintf("%5.2f", 100*($fcnt/$f_all));
    $hex  = sprintf("%04X", ord($chr));
    $ord  = ord($chr);
    if ($localUni) {
        if (exists $uni{$hex}) {
            $name = $uni{$hex}
        } 
        else {$name = '!!!'}
    }
    else {
        $name = charnames::viacode($ord) or $name = '???';
    }
    #if (exists $uni{$hex}) {$name2 = $uni{$hex}} else {$name2='!!!'}
    if ($hex=~/^E/ or $hex=~/^F[0-8]/ ) {$name.=' - PRIVATE USE AREA!'}
    if ($ord < 33) {$c = '<CTRL>'} else {$c = $chr}
    print "U+$hex\t$c\t$ccnt\t$cpc\t$fcnt\t$fpc\t$name\n";
}
print "Σ\t$c_type\t$c_all\t100.00\t$f_all\t100.00\t*\n";
print STDERR "All chars: $c_all, different chars $c_type\n";
