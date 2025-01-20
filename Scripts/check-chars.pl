#!/usr/bin/env perl
use warnings;
use strict;
use utf8;
my @INFILES = glob(shift);
binmode(STDOUT,'utf8');
binmode(STDERR,'utf8');

foreach my $file (@INFILES) {
  chars($file);
}

# Check if $file contains bad characters
sub chars {
  my $file = shift;
  my %c;
  my @bad = ();
  my ($fName) = $file =~ m|([^/]+)$|
    or die "FATAL ERROR: Bad file '$file'\n";
  print STDERR "INFO: Char validation for $fName\n";
  open(IN, '<:utf8', $file);
  undef $/;
  my $txt = <IN>;
  undef %c;
  for my $c (split(//, $txt)) {$c{$c}++}
  for my $c (sort keys %c) {
    if (ord($c) == hex('00A0') or  #NO-BREAK SPACE
      ord($c) == hex('2011') or  #NON-BREAKING HYPHEN
      ord($c) == hex('00AD') or  #SOFT HYPHEN
      ord($c) == hex('FFFD') or  #REPLACEMENT CHAR
      (ord($c) >= hex('2000') and ord($c) <= hex('200A')) or #NON-STANDARD SPACES
      (ord($c) >= hex('E000') and ord($c) <= hex('F8FF'))  #PUA
      ) {
      my $message = sprintf("U+%X (%dx)", ord($c), $c{$c});
      push(@bad, $message)
    }
  }
  print STDERR "WARN: File $fName contains bad chars: " . join('; ', @bad) . "\n"
    if @bad
}