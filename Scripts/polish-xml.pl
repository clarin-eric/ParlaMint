#!/usr/bin/perl
# Finalise ParlaMint file
use warnings;
use utf8;
use Unicode::Normalize;
binmode(STDIN,'utf8');
binmode(STDOUT,'utf8');
binmode(STDERR,'utf8');
undef $/;
$txt = NFC(<>);
#$txt =~ s| | |g;  In .ana this can be a word!
#$txt =~ s|­||g;   In .ana this can be a word!
$txt =~ s|([^>])[ \t]*\n\s*|$1 |g; #join lines
$txt =~ s|(<p [^>]*>)\s+|$1|g;
$txt =~ s|(<p>)\s+|$1|g;
$txt =~ s|\n\s*<term|<term|g;
$txt =~ s|</term>\n\s*|</term>|g;
$txt =~ s|</gap> +(\S)|</gap>$1|g;
$txt =~ s|\n\s*<w |\n<w |g;
$txt =~ s|\n\s*<pc |\n<pc |g;
$txt =~ s|\n\s*<link |\n<link |g;
print $txt;
print "\n";
