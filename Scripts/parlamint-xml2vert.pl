#!/usr/bin/env perl
# Finalise XSLT produced vertical XML file
# - remove namespaces
# - de escape XML entities
#
use warnings;
use utf8;
binmode STDERR, 'utf8';
binmode STDIN, 'utf8';
binmode STDOUT, 'utf8';
while (<>) {
    s|&apos;|'|g;
    s|&amp;|&|g;
    if (/\t/) {
        s|&lt;|<|g;
        s|&gt;|>|g;
        s|&quot;|"|g;
    }
    elsif (/^</) {
        #Get rid of namespaces
        s| xmlns(:.*?)?=".*?"||;
        #Protect quote in various manifestations
        s|&quot;|\\"|g;
        s|&#34;|\\"|g;
	s|&#x22;|\\"|g;
    }
    print;
}
