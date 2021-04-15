#!/usr/bin/perl
# Finalise ParlaMint file
use warnings;
use utf8;
use Unicode::Normalize;
#use feature 'unicode_strings';
binmode(STDIN,'utf8');
binmode(STDOUT,'utf8');
binmode(STDERR,'utf8');
undef $/;
$txt = NFKC(<>);
$txt =~ s| | |g;
$txt =~ s|­||g;
$txt =~ s|([^>])[ \t]*\n\s*|$1 |g; #join lines
$txt =~ s|(<p [^>]*>)\s+|$1|g;
$txt =~ s|(<p>)\s+|$1|g;
$txt =~ s|\n\s*<term|<term|g;
$txt =~ s|</term>\n\s*|</term>|g;
$txt =~ s|</gap> (\S)|</gap>$1|g;
$txt =~ s|\n\s*<w |\n<w |g;
$txt =~ s|\n\s*<pc |\n<pc |g;
$txt =~ s|\n\s*<link |\n<link |g;
print $txt;
print "\n";
