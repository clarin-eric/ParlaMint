#!/usr/bin/env perl

use warnings;
use strict;
use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');
use Getopt::Long;
use XML::LibXML;
use XML::LibXML::PrettyPrint;
use File::Spec;


sub usage {
  print STDERR ("Usage:\n");
  print STDERR ("create-taxonomy-UD-SYN.pl -help\n");
  print STDERR ("create-taxonomy.pl [--lang-codes '<langCodes>'] --in <Input> --out <Output>\n");
  print STDERR ("  creates a common ParlaMint UD-SYN taxonomy.\n");
  print STDERR ("  <langCodes> is the list of language codes from which should be included \n"
               ."              specific relations. If empty, then all languege specific relations \n"
               ."              are included.\n");
  print STDERR ("  <Input> is the directory with UD documentation.\n");
  print STDERR ("  <Output> is output taxonomy file path.\n");
}



my ($help, $langCodes, %processLangs, $inDir, $outFile);
GetOptions
  (
   'help'   => \$help,
   'codes=s'  => \$langCodes,
   'in=s'   => \$inDir,
   'out=s'  => \$outFile
);

if ($help) {
  &usage;
  exit;
}


my $dom = XML::LibXML::Document->new("1.0", "utf-8");
my $root_node =  XML::LibXML::Element->new('taxonomy');
$dom->setDocumentElement($root_node);
my ($TEINS,$XMLNS) = ('http://www.tei-c.org/ns/1.0', 'http://www.w3.org/XML/1998/namespace');
$root_node->setNamespace($TEINS,'',1);
$root_node->setNamespace($XMLNS,'xml',0);
add_desc_node($root_node,'desc','en','UD syntactic relations');

$inDir = File::Spec->rel2abs($inDir);
$outFile = File::Spec->rel2abs($outFile);


if($langCodes){
  %processLangs = map {$_ => 1} split(/[, ]+/,$langCodes);
} else {
  %processLangs = map {$_ => 1} map {m/.*_([^\/]*)\/dep$/;$1} glob "$inDir/_*/dep";
}


my @commonRelFiles = glob "$inDir/_u-dep/*.md";
my @countryRelFiles = map {glob "$inDir/_$_/dep/*.md"} keys %processLangs;


my %relationList;

insert_relations(\%relationList, 1, @commonRelFiles);
insert_relations(\%relationList, 0, @countryRelFiles);

fill_xml_taxonomy($root_node,\%relationList);

open FILE, ">$outFile"  or die "Can't open file $!";
binmode FILE;
print FILE to_string($dom);
close FILE;


sub insert_relations {
  my ($rels, $is_common) = (shift,shift);
  while(my $file = shift){
    my ($full_rel) = $file =~ m/([^\/]*?)_?\.md$/; # aux contains _ in filename: aux_
    my @rel = split(/-/,$full_rel);
    insert_relation($rels, $is_common, $file,@rel);
  }
}

sub insert_relation {
  my ($rels, $is_common, $file) = (shift,shift,shift);
  my $rel_part = shift;
  # test if relation exists
  $rels->{$rel_part} //= {};
  if(@_){
    $rels->{$rel_part}->{subrel} //= {};
    insert_relation($rels->{$rel_part}->{subrel}, $is_common, $file, @_);
  } else {
    if($is_common or $rels->{$rel_part}->{is_common}){
      $rels->{$rel_part}->{is_common} //= 1;
    } else {
      $rels->{$rel_part}->{is_common} //= 0;
      $rels->{$rel_part}->{langs} //= [];
      my ($lang) = $file =~  /_([^_]*)\/dep\/.*.md/;
      push @{$rels->{$rel_part}->{langs}}, $lang;
    }
    my ($term,$desc) = get_relation_from_file($file);
    $rels->{$rel_part}->{term} //= $term;
    $rels->{$rel_part}->{desc} //= $desc;
    ## TODO test if term and desc are equal in various files and corresponds to filename
  }
}

#use Data::Dumper;print STDERR Dumper \%relationList;

sub get_relation_from_file {
  my $file = shift;
  open my $fh, '<', $file or die "Can't open file $!";
  my $content = do { local $/; <$fh>};
  close $fh;
  my ($table) = $content =~ m/^\s*(?:.*?---)?(.*?title.*?)---.*$/s;
  my ($term) = $table =~ m/title\s*:\s*'?([^']*)'?\s*\n/s;
  my ($desc) = $table =~ m/shortdef\s*:\s*'?([^']*)'?\s*\n/s;
  $term =~ tr/\x{0435}\x{0445}/ex/; # fixing obscure characters in hy/dep/aux-ex.md and hyw/dep/aux-ex.md
  return ($term,$desc);
}

sub add_desc_node {
  my ($node,$elName,$lang,$term,$desc) = @_;
  my $elem = $node->addNewChild(undef,$elName);
  $elem->setAttributeNS($XMLNS,'lang',$lang);
  #print "'$term'\t$desc\t\t>>";
  #foreach my $char (split //, $term) { print sprintf(" %s:%d(0x%X)",$char,ord($char),ord($char));}
  #print "<<\n";
  $term =~ s/\s\s*/ /g;
  $term =~ s/^\s*|\s*$//g;
  $desc //='';
  $desc =~ s/\s\s*/ /g;
  $desc =~ s/^\s*|\s*$//g;
  $elem->appendTextChild('term',$term);
  if($desc){
    $elem->appendText(": $desc");
  }
  return $elem;
}

sub fill_xml_taxonomy {
  my ($node,$rels) = @_;
  for my $rel (sort keys %{$rels//{}}){
    my $category = $node->addNewChild(undef,'category');
    $category->appendChild(XML::LibXML::Comment->new(' languages: '.join(' ',@{$rels->{$rel}->{langs}}).' ')) unless $rels->{$rel}->{is_common};
    my $term = $rels->{$rel}->{term};
    my $desc = $rels->{$rel}->{desc};
    my $id = $term;
    $id =~ tr/:/_/;
    $category->setAttributeNS($XMLNS,'id',$id);
    add_desc_node($category,'catDesc','en',$term,$desc);
    fill_xml_taxonomy($category,$rels->{$rel}->{subrel});
  }
}

sub to_string {
  my $doc = shift;
  my $pp = XML::LibXML::PrettyPrint->new(
    indent_string => "   ",
    element => {
        inline   => [qw//], # note
        block    => [qw/category taxonomy/],
        compact  => [qw/catDesc term desc/],
        preserves_whitespace => [qw//],
        }
    );
  $pp->pretty_print($doc);
  return $doc->toString();
}

