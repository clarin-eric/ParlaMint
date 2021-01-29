#!/usr/bin/perl
# Finalise ParlaMint file
use warnings;
use utf8;
undef $/;
$txt = <>;
$txt =~ s|([^>]) *\n\s*|$1 |g; #join lines
$txt =~ s|(<p [^>]*>)\s+|$1|g;
$txt =~ s|(<p>)\s+|$1|g;
#$txt =~ s|\n\s*<desc>|<desc>|g;
#$txt =~ s|</desc>\n\s*|</desc>|g;
$txt =~ s|\n\s*<term|<term|g;
$txt =~ s|</term>\n\s*|</term>|g;
$txt =~ s|</gap> (\S)|</gap>$1|g;
print $txt;
print "\n";
