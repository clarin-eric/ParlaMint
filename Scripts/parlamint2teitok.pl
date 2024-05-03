use XML::LibXML;
use Getopt::Long;
use Data::Dumper;
#use warnings;

$\ = "\n"; $, = "\t";


GetOptions ( ## Command line options
            'debug=i' => \$debug, # debugging mode
            'verbose' => \$verbose, # verbose mode
            'test' => \$test, # test mode (print, do not save)
            'force' => \$force, # force conversion even if target file exists
            'notok' => \$notok, # force conversion even if there are no tokens
            'file=s' => \$file, # input tei file
            'tsv=s' => \$tsv, #
            'tsvdir=s' => \$tsvdir, # >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> !!! TODO
            'out=s' => \$out, # output file file
            'outdir=s' => \$outdir, # output dir
            'prev=s' => \$prev, # previous file in corpus root
            'next=s' => \$next, # next file in corpus root
            'perpage=i' => \$perpage, #
            );

if ( !$file) { $file = shift; };


$sname = get_sname($file);

if ( !$out ) {
  if(!outdir) {
	  $out = "xmlfiles/$sname";
  } else {
  	$out = "$outdir/$sname";
  }
};


if ( -e $out && !$force ) {
  print " - already done: $out";
  exit;
};

( $outf = $out ) =~ s/[^\/]+$//;

if ( !$perpage ) { $perpage = 2000; };

$/ = undef;
open FILE, $file or die "unable to open $file";
binmode FILE, ":utf8";
$raw = <FILE>;
close FILE;

$raw =~ s/xmlns=/xmlnsoff=/g;

$xml = XML::LibXML->load_xml(string => $raw);

@divs = @{$xml->findnodes("//text/body/div")};

@toks = @{$xml->findnodes("//w | //pc")};

if ( $verbose ) { print "$sname: ".scalar @toks." tokens"; };

if ( scalar @toks == 0 && !$notok ) {
  print " - no tokens";
  exit;
};

$txt = $xml->findnodes("/TEI/text")->item(0);

# Try to read PREV and NEXT from teiCorpus if not defined in parameter
unless(defined($prev) || defined($next)) {
  $tcp = $file; $tcp  =~ s/([^\/]+)(\.TEI\.ana\/).*/$1$2$1.ana.xml/;
  if ( -e $tcp ) {
    open FILE, $tcp;
    binmode FILE, ":utf8";
    $tmp = <FILE>;
    close FILE;
    $tmp =~ s/xmlns=/xmlnsoff=/g;
    $crp = XML::LibXML->load_xml(string => $tmp);
    $shortname = $file; $shortname =~ s/.*\.TEI\.ana\///;
    $tmp = $crp->findnodes("//*[\@href=\"$shortname\"]/preceding-sibling::*[1]/\@href");
    if ( $tmp ) {
      $prev = $tmp->item(0)->value."";
    };
    $tmp = $crp->findnodes("//*[\@href=\"$shortname\"]/following-sibling::*/\@href");
    if ( $tmp ) {
      $next = $tmp->item(0)->value."";
    };
  };
}
$txt->setAttribute("prev", get_sname($prev)) if $prev;
$txt->setAttribute("next", get_sname($next)) if $next;



$tcnt = 0;
foreach $tok ( @toks ) {
  $type = $tok->getName();
  $tok->setName("tok");
  $id = $tok->getAttribute("xml:id")."";
  $tok->setAttribute("id", "w-".++$tcnt);
  $tok->setAttribute("type", $type);
  $id2tok{$id} = $tok;
  $id2id{$id} = "w-$tcnt";
  $msd = $tok->getAttribute("msd");
  if ( $msd )  {
    $feats = $msd;
    $feats =~ s/UPosTag=([^|]+)\|?//;
    $upos = $1;
    $msd = $tok->removeAttribute("msd");
    $tok->setAttribute("upos", $upos);
  };
  if ( $feats ne '') { $tok->setAttribute("feats", $feats); };
};

foreach $media ( $xml->findnodes("//media") ) {
  if ( $sname =~ /-CZ/ ) {
    $mbase = "https://lindat.mff.cuni.cz/services/teitok/data/parczech/www.psp.cz/eknih/";
  };
  if ( $mbase ) {
    $media->setAttribute("url", $mbase.$media->getAttribute("url"));
  };
};

foreach $link ( $xml->findnodes("//link") ) {
  $deprel = $link->getAttribute("ana")."";
  $deprel =~ s/ud-syn://;
  ( $source, $target ) = split ( " ", $link->getAttribute("target"));
  $headid = substr($source, 1);
  $chid = substr($target, 1);
  $ch = $id2tok{$chid};
  if ( !$ch ) {
    print "No such token: $chid";
    next;
  };
  if ( $id2id{$headid} ) { $ch->setAttribute("head", $id2id{$headid}); };
  $ch->setAttribute("deprel", $deprel);
  # print $chid, $headid, $deprel, $ch->toString;
};

$scnt = 0;
foreach $s ( $xml->findnodes("//text//s") ) {
  $s->setAttribute("id", "s-".++$scnt);
  foreach $linkgrp ( $s->findnodes("linkGrp") ) {
    $s->removeChild($linkgrp);
  };
};

foreach $gap ( $xml->findnodes("//gap") ) {

  $reason = $gap->findnodes(".//desc")->item(0)->textContent;
  $gap->setAttribute("note", $reason);
  for $ch ( $gap->childNodes() ) {
    $gap->removeChild($ch);
  };
};

if ( $xml->findnodes("//pb") ) {

  # Already pb'd
  if ( $verbose ) { print "Already pb'd - adding atts later"; };
  $dopb = 1;

} else {
  $dcnt = 0; $pbcnt = 0; $scnt = 1;
  foreach $div ( @divs ) {

    $tcnt = 0; $dcnt++;
    @toks = @{$div->findnodes(".//w")};

    $tcnt = 100000000;

    if ( $debug ) { print "DIV $dcnt. ".$div->getAttribute("type"); };

    foreach $s ( $div->findnodes(".//seg") ) {
      $s->setAttribute("id", "s-".++$scnt);
      @toks = @{$s->findnodes(".//tok")};
      if ( $tcnt > $perpage ) {
        $pbcnt++;
        $pb = $xml->createElement("pb");
        $pb->setAttribute("id", "pb-$pbcnt");
        $pb->setAttribute("n", $pbcnt);
        $pb->setAttribute("type", "pagination");
        $utt = $s->findnodes("ancestor::u")->item(0);
        $uttid = $utt->findnodes("\@xml:id")->item(0)->value."";
        if ( $pbcnt == 1 ) {
          $bn = $s->findnodes("ancestor::div")->item(0)->firstChild;
        } elsif ( $utt == $lastutt ) {
          # This is not the first sentence
          $pb->setAttribute("utt", $uttid);
          $pb->setAttribute("who", $utt->getAttribute("who"));
          $pb->setAttribute("ana", $utt->getAttribute("ana"));
          $pb->setAttribute("corresp", $utt->getAttribute("corresp"));
          $nextpag = $pbcnt; ## Why is thid not +1?
          $utt->setAttribute("cont", "pb-$nextpag");
          $bn = $s;
        } else {
          $bn = $utt->findnodes("preceding::u[1]")->item(0)->nextSibling;
        };
        # if ( !$bn ) { $bn = $utt; };
        if ( $debug ) { print " - page $pbcnt before ".$bn->getName(); };
        $bn->parentNode->insertBefore($pb, $bn);
        $tcnt = 0;
        $lasts = $s;
        $lastutt = $utt;
      };
      $tcnt += scalar @toks;
    };

  };
};

%header2fld = (
     "ID" => "uid",
     "Title" => "title",
     "Date" => "date",
     "Body" => "body",
     "Term" => "term",
     "Session" => "session",
     "Meeting" => "meeting",
     "Sitting" => "sitting",
     "Agenda" => "agenda",
     "Subcorpus" => "subcorpus",
     "Speaker_role" => "speaker_role",
     "Speaker_MP" => "speaker_MP",
     "Speaker_Minister" => "speaker_Minister",
     "Speaker_minister" => "speaker_Minister", # This to sort the capitalization error
     "Speaker_party" => "speaker_party",
     "Speaker_party_name" => "speaker_party_name",
     "Party_status" => "party_status",
     "Speaker_ID" => "speaker_ID",
     "Speaker_name" => "speaker_name",
     "Speaker_gender" => "speaker_gender",
     "Speaker_birth" => "speaker_birth",
     "Lang" => "lang",
     "Party_orientation" => "party_orientation"
);

%setflds = (
  "mp" => "speaker_MP",
  "minister" => "speaker_Minister",
  "party" => "speaker_party",
  "party_name" => "speaker_party_name",
  "party_orientation" => "party_orientation",
  "party_status" => "party_status",
  "gender" => "speaker_gender",
  "birth" => "speaker_birth",
);

sub valbyfld ( $$$ ) {
  ( $field, $hfld, $valstr ) = @_;
  if ( !$valstr ) { return 0; };
  @valarr = split("\t", $valstr);
  # $nm->setAttribute("mp", $vals[$fld2num{"speaker_MP"}]);
  $fnum = $fld2num{$hfld};
  if ( $fnum == 0 ) { return 0; };
  $vval = $valarr[$fnum];
  return $vval;
};

# Now add the full speaker data (multilingually)
if ( !$tsv ) {
	if(!tsvdir) {
    $tsv = $file; $tsv  =~ s/\.TEI\.ana/\.meta.tsv/;  $tsv  =~ s/\.ana\././; $tsv  =~ s/\.xml/-meta.tsv/;
    $tsven = $tsv; $tsven =~ s/-meta/-meta-en/;
  } else {
  	my $prefix = "$tsvdir/$sname";
  	$prefix =~ s/\.tt\.xml$//;
    ($tsv,$tsven) = map {"$prefix$_"} qw/-meta.tsv -meta-en.tsv/;
  }
};

if ( !-e $tsv ) {
  print "TSV not found: $tsv";
} else {
  if ( $debug > 1 ) { print $tsv; };

  # ID  Title  Date  Body  Term  Session  Meeting  Sitting  Agenda  Subcorpus  Speaker_role  Speaker_MP  Speaker_Minister  Speaker_party  Speaker_party_name  Party_status  Speaker_name  Speaker_gender  Speaker_birth
  $/ = "\n";
  open FILE, $tsv;
  $header = <FILE>; chop($header); $fc = 0;
  if ( $debug > 1 ) { print "TSV Header: ".$header; };
  foreach $hfld ( split("\t", $header) ) {
    $ff[$fc] = $header2fld{$hfld};
    $fld2num{$header2fld{$hfld}} = $fc;
    if ( $debug > 1 ) {
      print " $fc: $hfld = ".$ff[$fc];
    };
    $fc++;
  };
  while ( <FILE> ) {
    chop; $vals = $_; $fc = 0;
    foreach $fval ( split("\t", $vals) ) {
      ${$ff[$fc]} = $fval;
      $fc++;
    };
    if ( !$txt->getAttribute("body") ) {
      $txt->setAttribute("body", $body);
      $txt->setAttribute("subcorpus", $subcorpus);
    };
    #  ( $uid,  $title, $date, $body, $term, $session, $meeting, $sitting, $agenda, $subcorpus, $speaker_role, $speaker_MP, $speaker_Minister, $speaker_party, $speaker_party_name, $party_status, $speaker_name, $speaker_gender, $speaker_birth ) = split("\t");
    $org{$uid} = $_;
  };
  close FILE;

  open FILE, $tsven;
  $header = <FILE>;
  while ( <FILE> ) {
    chop; $vals = $_; $fc = 0;
    foreach $fval ( split("\t", $vals) ) {
      ${$ff[$fc]} = $fval;
      $fc++;
    };
    #  ( $uid,  $title, $date, $body, $term, $session, $meeting, $sitting, $agenda, $subcorpus, $speaker_role, $speaker_MP, $speaker_Minister, $speaker_party, $speaker_party_name, $party_status, $speaker_name, $speaker_gender, $speaker_birth ) = split("\t");
    $eng{$uid} = $_;
  };
  close FILE;

  $srcd = $xml->findnodes("//teiHeader//sourceDesc")->item(0);
  $listp = $xml->createElement("listPerson");
  $srcd->addChild($listp);

  foreach $utt ( $xml->findnodes("//text//u") ) {
    $uid = $utt->findnodes("\@xml:id")->item(0)->value."";
    $corresp = $utt->getAttribute("who")."";
    $spid = substr($corresp, 1);
    $utt->setAttribute("corresp", $corresp);
    $spn = $sp2name{$spid};
    if ( $debug && $debug > 1 ) { print $uid, $spid; };
    if ( !$spn ) {
      $prs = $xml->createElement("person");
      $prs->setAttribute("id", $spid);

      # print $org{$uid};
      @vals = split("\t", $org{$uid});
      # ( $uid,  $title, $date, $body, $term, $session, $meeting, $sitting, $agenda, $subcorpus, $speaker_role, $speaker_MP, $speaker_Minister, $speaker_party, $speaker_party_name, $party_status, $speaker_name, $speaker_gender, $speaker_birth ) = split("\t", $org{$uid});
      foreach $fval ( split("\t", $vals) ) {
        ${$ff[$fc]} = $fval;
        $fc++;
      };
      $spn = $vals[$fld2num{"speaker_name"}];
      $sp2name{$spid} = $spn;
      $nm = $xml->createElement("persName");
      $nm->setAttribute("lang", "org");
      $nm->appendText($vals[$fld2num{"speaker_name"}]);
      while ( ( $key, $val ) = each ( %setflds ) ) {
        $tmp = valbyfld ( $key, $val, $org{$uid} );
        if ( $tmp ) {
          $nm->setAttribute($key, $tmp);
        };
      };
      $prs->appendText("\n\t\t\t");
      $prs->addChild($nm);

      if ( $eng{$uid} ) {
        $engs = split("\t", $eng{$uid});
        ( $uid,  $title, $date, $body, $term, $session, $meeting, $sitting, $agenda, $subcorpus, $speaker_role, $speaker_MP, $speaker_Minister, $speaker_party, $speaker_party_name, $sarty_status, $speaker_name, $speaker_gender, $speaker_birth ) = split("\t", $eng{$uid});
        $nm = $xml->createElement("persName");
        $nm->setAttribute("lang", "eng");
        $nm->appendText($vals[$fld2num{"speaker_name"}]);
        while ( ( $key, $val ) = each ( %setflds ) ) {
          $tmp = valbyfld ( $key, $val, $eng{$uid} );
          if ( $tmp ) {
            $nm->setAttribute($key, $tmp);
          };
        };
        $prs->appendText("\n\t\t\t");
        $prs->addChild($nm);
      };

      $listp->appendText("\n\t\t");
      $listp->addChild($prs);

    };
    if ( $spn ne '') {
      $utt->setAttribute("who", $spn);
    } else {
      print "Unknown speaker: $spid";
    };
  };

};

if ( $dopb || 1==1 ) {
  if ( $debug ) { print " - doing PB links for pb inside u"; };
  # Check whether we need to add info to any pb
  foreach $pb ( $xml->findnodes("//text//u//pb") ) {
    if ( $debug > 1 ) { print $pb->toString; };
    $pbid = $pb->getAttribute("id");
    $utt = $pb->findnodes("ancestor::u")->item(0);
      $uttid = $utt->findnodes("\@xml:id")->item(0)->value."";
    $utt->setAttribute("cont", $pbid);
    $pb->setAttribute("corresp", $utt->getAttribute("corresp"));
          $pb->setAttribute("utt", $uttid);
          $pb->setAttribute("who", $utt->getAttribute("who"));
          $pb->setAttribute("ana", $utt->getAttribute("ana"));
    if ( $debug ) { print $pb->toString; } ;
  };

  # inline media if pb contain corresp
};

`mkdir -p $outf`;

open OUT, ">$out";
print OUT $xml->toString;
close OUT;

print "saved to $out";


sub get_sname {
  my $sname = shift;
  $sname =~ s/^.*\/(\d{4}\/ParlaMint-.*)/$1/;
  $sname =~ s/.ana.xml/.tt.xml/;
  return $sname;
}