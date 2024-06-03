#!/usr/bin/env perl
use warnings;
use utf8;
binmode STDIN, 'utf8';
binmode STDOUT, 'utf8';
binmode STDERR, 'utf8';
while (<>) {
    s|||g;
    s| +| |g;
    s|­||g;
    s|‑|-|g;
    s|_segmented"|"|;
    print;
}
