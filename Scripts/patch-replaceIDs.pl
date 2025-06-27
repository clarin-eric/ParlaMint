#!/usr/bin/env perl
use warnings;
use strict;
use utf8;
use open ':utf8';

binmode(STDIN,'utf8');
binmode(STDOUT,'utf8');
binmode(STDERR,'utf8');

my ($help, $code, $ids_file);

sub usage
{
    print STDERR ("Usage: patch-replaceIDs.pl -prefix <PrefixForIDs> -ids <ListOfIDsForReplacement>\n");
    print STDERR ("       read input from stdin and extend all references and xml:id\n");
    print STDERR ("       that are mentioned in <ListOfIDsForReplacement>\n");
    print STDERR ("       with prefix '<PrefixForIDs>-'\n");
    print STDERR ("warning (known bug): tei prefixes are ignored when replacing references\n");
}

use Getopt::Long;

GetOptions
    (
     'help'   => \$help,
     'prefix=s'   => \$code,
     'ids=s'  => \$ids_file,
);

if ($help || not($code && $ids_file)) {
    &usage;
    exit;
}

open my $fh, '<:utf8', $ids_file or die "Cannot open $ids_file: $!";
chomp(my @keys = <$fh>);
close $fh;

my $input = do { local $/; <STDIN> };


# fixing references
$input =~ s{
  (\s(?:active|adj|adjFrom|adjTo|ana|calendar|change|children|class|code|copyOf|corresp|datcat|datingMethod|datingPoint|decls|domains|edRef|end|exclude|fVal|facs|feats|filter|follow|fromUnit|given|hand|inst|lemmaRef|location|mergedIn|mutual|new|next|nymRef|origin|parent|parts|passive|perf|period|prev|ref|rendition|require|resp|sameAs|scheme|scriptRef|select|since|source|spanTo|start|synch|target|targetEnd|toUnit|toWhom|unitRef|uri|url|valueDatcat|where|who|wit)="[^"]*")
}{
  my $refs = $1;
  foreach my $key (@keys) {
    $refs =~ s/(?<=\s|")#\Q$key\E(?=\s|")/#$code-$key/g;
  }
  $refs;
}gex;

# fixing IDs
foreach my $key (@keys) {
  $input =~ s/(\sxml:id=")(\Q$key\E")/$1$code-$2/;
}

print $input;