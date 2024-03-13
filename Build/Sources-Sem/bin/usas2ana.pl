#!/usr/bin/env perl
# Map pyMusas USAS tags to ParlaMint-taxonomy-USAS.ana.xml category IDs
use warnings;
use utf8;

# Extended TEI prefix for referring to USAS categories
$prefix = 'sem';

# Mapping of @ana categories not present in the taxonomy
while (<DATA>) {
    next if /^#/;
    chomp;
    ($badtag, $backoff) = split(/\t/);
    $exception{$badtag} = $backoff
}

while (<>) {
    chomp;
    $tag = $_;
    $semana = &sem2ana($tag);
    print "$tag\t$semana\n"
}

# Convert USAS tags to values of @ana, cf.
# https://github.com/clarin-eric/ParlaMint/issues/202
sub sem2ana {
    my $tags = shift;
    my @anas;
    # If D.* is part of a slash tag, then remove the D.* and the slash to leave the other semantic tag in place
    $tags =~ s|D[^/]*/||;
    $tags =~ s|/D[^/]*||;
    # if the tag is D.* on its own, then label it as Z9
    $tags =~ s|D[^/]*|Z9|;
    foreach $tag (split(/\//, $tags)) {
	$ana = $tag;
	$ana =~ s/[mfnci%\@]//g; #Remove modifiers
	$ana =~ s/\-+/n/g; #Change -, --, --- to n
	$ana =~ s/\++/p/g; #Change +, ++, +++ to p
	$ana = $exception{$ana} if exists $exception{$ana};
	push(@anas, "$prefix:$ana")
    }
    return join(" ", @anas)
}
__DATA__
### Bad categories or missing gloss
# Bugs, e.g. no A1.2.4 exists
A1.2.4n	A1.2
A9.1p	A9
G1.1.1	G1.1
S.1.2.3n	S1.2.3
S2F	S2
S4T1.1.1	S4 T1.1.1
X7.2p	X7
# Missing antonyms:
H1n	H1
I1n	I1
N5.2n	N5.2
O4.3n	O4.3
S1.1.1n	S1.1.1
X3n	X3
# Missing positives:
K5.1p	K5.1
M1p	M1
X2.1p	X2.1
X3.5p	X3.5
X4.1p	X4.1
