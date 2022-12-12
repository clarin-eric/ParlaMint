#!/usr/bin/perl -w
use utf8;
$inDirs = shift;
binmode(STDOUT,'utf8');
binmode(STDERR,'utf8');

foreach $inDir (glob $inDirs) {
    ($country) = $inDir =~ /-([A-Z]+)/;
    $country{$country}++;
    foreach $inFile (glob "$inDir/*.vert") {
        if ($inFile =~ /(20[012]\d-\d\d)-\d\d/) {
            $month = $1;
            $tokens = `grep '\t' $inFile | wc -l`;
            chomp $tokens;
            $words{$month}{$country} += $tokens;
            #print STDERR "$country\t$month\t$tokens\n";
        }
        #For HR, as it does't have dates
        elsif ($inFile =~ /_S\d\d/) {
            open IN, $inFile or die;
            $cont = 1;
            while ($cont) {
                die "Can't find speech in $inFile!\n"
                    if eof(IN);
                $line = <IN>;
                if ($line =~ m|<speech |) {
                    ($from) = $line =~ m| from="(\d\d\d\d-\d\d)-\d\d"|;
                    ($to) = $line =~ m| to="(\d\d\d\d-\d\d)-\d\d"|;
                    $cont = 0;
                }
            }
            close IN;
            $tokens = `grep '\t' $inFile | wc -l`;
            chomp $tokens;
            $interval{$country}{"$from/$to"} += $tokens;
            # print STDERR "INFO: $inFile, block $country $from/$to: $tokens\n";
        }
        else {die "Bad file $inFile!\n"}
    }
}
#Now put the interval into existing dates, in equal portions in months
foreach $country (keys %interval) {
    $country{$country}++;
    foreach $interval (keys %{$interval{$country}}) {
        ($from, $to) = $interval =~ m|(.+)/(.+)|;
        @months = ();
        foreach $month (sort keys %words) {
            if ($month ge $from and $month le $to) {
                push @months, $month
            }
        }
        # print STDERR "INFO: block $country $interval: $interval{$country}{$interval} / ";
        # print STDERR scalar @months . "\n";
        if (scalar @months) {
            $avg = int $interval{$country}{$interval} / scalar @months;
            foreach $month (@months) {
                $words{$month}{$country} = $avg
            }
        }
        elsif (($month) = $interval =~ m|^(.+)/$1$|) { #there are no month to cover this!
            $words{$month}{$country} = $interval{$country}{$interval}
        }
        else {die "Can't handle $interval for $country!\n"}
    }
}
#Output header
print "Month";
foreach $country (sort keys %country) {
    print "\t$country";
}
print "\n";
#Output one month per line
foreach $month (sort keys %words) {
    print "$month";
    foreach $country (sort keys %country) {
        if (exists $words{$month}{$country}) {
            print "\t$words{$month}{$country}"
        }
        else {print "\t0"}
    }
    print "\n"
}
