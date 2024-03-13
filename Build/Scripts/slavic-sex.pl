#!/usr/bin/env perl
# Output previously unknown sex
use warnings;
use utf8;
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');
# WARN: In BA forename Gordanal assuming sex M
# WARN: In HR forename onja assuming sex F
# WARN: In RS forename An assuming sex M
# WARN: In RS forename Žan Klod assuming sex M
# WARN: In RS forename Naidu M. assuming sex M

#These are sometimes wrong in the source, we will correct them
$correct{'Aleksandra'}='F';
$correct{'Andrija'}='M';
$correct{'Branislava'}='F';
$correct{'Dragan'}='M';
$correct{'Jovica'}='M';
$correct{'Milija'}='F';
$correct{'Milka'}='F';
$correct{'Miroslava'}='F';
$correct{'Nermina'}='F';

# Exceptions to the -a = F rule
$except{'Ester'} = 'F';
$except{'Evelin'} = 'F';
$except{'Kori'} = 'F';
$except{'Nives'} = 'F';

$except{'Aljoša'} = 'M';
$except{'Andrija'} = 'M';
$except{'Boriša'} = 'M';
$except{'Dragiša'} = 'M';
$except{'Grga'} = 'M';
$except{'Ivica'} = 'M';
$except{'Jovica'} = 'M';
$except{'Jurica'} = 'M';
$except{'Nikola'} = 'M';
$except{'Sabrija'} = 'M';
$except{'Tomica'} = 'M';

while (<>) {
    if (/^country/i) {
        print;
        next
    }
    chomp;
    my ($country, $id, $forename, $surename, $sex) = split /\t/;
    s/\t.$//;
    if ($sex eq 'U') {push(@output, $_)}
    elsif (exists($correct{$forename}) and $correct{$forename} ne $sex) {
        print STDERR "WARN: In $country correcting forename $forename sex $correct{$forename}\n";
        push(@output, $_)
    }
    else {
        if (exists $sex{$forename} and $sex{$forename} ne $sex) {
            print STDERR "WARN: In $country forename $forename is sex ambiguous\n";
            $sex{$forename} = 'A!'
        }
        else {$sex{$forename} = $sex}
    }
}
foreach $person (@output) {
    print "$person\t";
    my ($country, $id, $forename, $surename) = split(/\t/, $person);
    if (exists $except{$forename}) {
        print $except{$forename}
    }
    elsif (exists $sex{$forename}) {
        print $sex{$forename};
    }
    else {
        if ($forename =~ /a$/) {$sex = 'F'} else {$sex = 'M'}
        print $sex;
    }
    print "\n"
}
