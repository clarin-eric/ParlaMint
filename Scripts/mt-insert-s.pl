#!/usr/bin/env perl
# For MTed corpora, insert annotated sentences into skeleton TEI
use warnings;
use utf8;
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

$sentFile = shift;

open(TBL, '<:utf8', $sentFile) or die "Cant find $sentFile!\n";
$/ = "</s>\n";
while (<TBL>) {
    next unless m|</s>|;
    s|.+<s |<s |s;
    push(@sents, $_);
}
close TBL;

$/ = "\n";
while (<>) {
    if (m|<s |) {
	($id1) = m|<s xml:id="(.+)"|
	    or die "FATAL ERROR: No sentence ID found in $_";
	$sent = shift(@sents)
	    or die "FATAL ERROR: No more sentences for $_";
	($id2) = $sent =~ m|<s xml:id="(.+?)"|
	    or die "FATAL ERROR: No sentence ID found in $sent\n";
	die "FATAL ERROR: Mismatch in IDs between $id1 and $id2\n" unless $id1 eq $id2;
	$sent =~ s|>| corresp="mt-src:$id1">|;
	print $sent;
    }
    else {
	print;
    }
}
sub clean {
    my $content = shift;
    my $prev_content = shift;
    $content = $prev_content . " " . $content;
    $content =~ s|<.+?>||sg;  #Remove any markup from comment, like <time>
    $content =~ s|\s\S+?=".+?"||; # Remove attributes
    $content =~ s|\s+| |sg;
    $content =~ s|^ ||;
    $content =~ s| $||;
    return $content
}
