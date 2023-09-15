#!/usr/bin/perl
# Convert CoNLL-U file to TEI <body>
# This is a slightly modified script for ParlaMint from
# https://github.com/clarinsi/TEI-conversions/blob/645dfbece8f52b45a51f159f5874e1038f9f1c12/Scripts/conllu2tei.pl
# Also encodes USAS semantic information

use warnings;
use utf8;
binmode STDERR, 'utf8';
binmode STDIN,  'utf8';
binmode STDOUT, 'utf8';

# Extended TEI prefixes to use on annotation of syntactic annotations
$ud_prefix   = 'ud-syn'; # Prefix for syntactic roles
$ud_type     = 'UD-SYN'; # Type of syntatic dependencies

# Extended TEI prefixes to use on annotation for USAS semantic labels
$sem_prefix   = 'sem';      # Prefix for semantic annotation

# ID prefixes
$doc_prefix  = 'doc';    # Prefix for document IDs, if they are numeric in source
$p_prefix    = 'p';      # Prefix for paragraph IDs, if they are numeric in source
$s_prefix    = 's';      # Prefix for sentence IDs, if they  are numeric or do not exist in source

print "<body xmlns=\"http://www.tei-c.org/ns/1.0\" xml:lang=\"en\">\n";
$has_div = 0;
$has_p   = 0;
$has_s   = -1; #Means this is the first sentence
$doc_n   = 0;
$p_n     = 0;
$s_n     = 0;

$/ = "\n\n";
while (<>) {
    if (m|# newdoc id = (.+)|) {
        if (m|# newpar id|) {$has_p = 1}
        $doc_id = $1;
        $has_div = 1;
        $s_n = 0;
        if ($has_div) {
            if ($has_p) {print "</p>\n"}
            else {print "</ab>\n"}
            print "</div>\n";
        }
        if ($doc_id =~ /^\d/) {
            $doc_n = $doc_id;
            $doc_id = $doc_prefix . $doc_n
        }
        else {$doc_n++}
        print "<div xml:id=\"$doc_id\" n=\"$doc_n\">\n";
        unless ($has_p) {print "<ab>\n"}
        $has_p = 0;
    }
    if (m|# newpar id = (.+)|) {
        $p_id = $1;
        if ($has_p) {print "</p>\n"}
        $has_p = 1;
	$p_n++;
        $s_n = 0;
        if ($p_id =~ /^\d/) {
            $p_id = $p_prefix . $p_n
        }
        print "<p xml:id=\"$p_id\" n=\"$p_n\">\n";
    }
    if (m|# sent_id = (.+)|) {
        $has_s = 1;
        $s_id = $1;
        $s_n++;
        if ($s_id =~ /^\d/) {
            $s_id = "$p_id.$s_prefix$s_n";
        }
	print STDERR "ERROR: sentence $s_id has bad language code!\n"
	    if m|# source_lang = xx|
    }
    else {
        print "<ab>\n" if $has_s == -1;
        $has_s = 0;
        $s_n++;
        $s_id = "$s_prefix$s_n";
    }
    print conllu2tei($s_id, $s_n, $_);
}
if ($has_p) {print "</p>\n"}
if ($has_div) {print "</div>\n"}
print "</body>\n";

#Convert one sentence into TEI
sub conllu2tei {
    my $id = shift;
    my $n  = shift;
    my $conllu = shift;
    my $tei;
    my $tag;
    my $element;
    my $space;
    my $ner;
    my $ner_prev = 'O';
    my $sem;
    my $sem_prev = 'O';
    my @ids = ();
    my @toks = ();
    my @deps = ();
    $tei = "<s xml:id=\"$id\" n=\"$n\">\n";
    @open_elements = ();
    foreach my $line (split(/\n/, $conllu)) {
        next unless $line =~ /^\d+\t/;
        chomp;
        my ($n, $token, $lemma, $upos, $xpos, $ufeats, $link, $role, $extra, $local) 
            = split /\t/, $line;
        # Don't know how to do syntactic words yet
        # if ($n =~ m|(\d+)-(\d+)|) {
        #     $from = $1;
        #     $to = $2
        # }
        $xpos =~ s/-+$//;   # Get rid of trailing dashes sometimes introduced by Stanford NLP
        
        if ($token =~ /^[[:punct:]]+$/) {
            $tag = 'pc';
            if ($upos ne '_') {
                # print STDERR "WARN: changing PoS to punctuation for\n$line\n"
                #     unless ($xpos eq '_' or $xpos eq 'Z')
                #     and ($upos eq 'PUNCT' or $upos eq 'SYM');
                if ($token =~ /[$%§©+−×÷=<>]/) {$upos = 'SYM'}
                else {$upos = 'PUNCT'}
                $ufeats = '_';
            }
            $xpos = 'Z' unless $xpos eq '_';
        }
        else {$tag = 'w'}
        
        if ($upos !~ /_/) {
            $feats = "UPosTag=$upos";
            $feats .= "|$ufeats" if $ufeats ne '_';
        }
        
        #Bug in STANZA:
        if ($role eq '<PAD>') {$role = 'dep'}
        
	#Encoding semantic <phr>
        if (($sem) = $local =~ /SEMMWE=(.)/) {
	    if ($sem ne 'I' and $sem_prev ne 'O') {
		push(@toks, "</phr>");
		pop(@open_elements);
	    }
	    if ($sem eq 'B') {
		($semtype) = $local =~ /SEM=([^|]+)/;
		$semtype =~ s/,/ $sem_prefix:/g;
		push(@toks, "<phr type=\"sem\" ana=\"$sem_prefix:$semtype\">");
		push(@open_elements, 'phr');
	    }
	    $sem_prev = $sem
        }
        #Encoding <name>
        if (($ner) = $local =~ /NER=([A-Z-]+)/) {
            if (($type) = $ner =~ /^B-(.+)/) {
                if ($ner_prev ne 'O') {
                    push(@toks, "</name>");
		    pop(@open_elements);
                }
                push(@toks, "<name type=\"$type\">");
		push(@open_elements, 'name');
            }
	    #Sometimes NER begins with I! (bug in CLASSLA)
            elsif (($type) = $ner =~ /^I-(.+)/) {
                if ($ner_prev eq 'O') {
		    push(@toks, "<name type=\"$type\">");
		    push(@open_elements, 'name');
                }
            }
            elsif ($ner eq 'O' and $ner_prev ne 'O') {
		push(@toks, "</name>");
		pop(@open_elements);
            }
            $ner_prev = $ner
        }
        
        $space = $local !~ s/SpaceAfter=No//;
        $token = &xml_encode($token);
        $xpos  = &xml_encode($xpos);
	$xpos  =~ s/"/&quot;/g; 
        $lemma = &xml_encode($lemma);
	$lemma =~ s/"/&quot;/g; 
        if ($tag eq 'w') {$element = "<$tag>$token</$tag>"}
        elsif ($tag eq 'pc') {$element = "<$tag>$token</$tag>"}
        if ($xpos ne '_') {$element =~ s|>| pos=\"$xpos\">|}
        if ($feats and $feats ne '_') {$element =~ s|>| msd=\"$feats\">|}
        if ($tag eq 'w') {
	    if ($lemma eq '_') {
                print STDERR "WARN: changing empty lemma to $token for $line\n";
		$lemma = $token
	    }
	    $element =~ s|>| lemma=\"$lemma\">|
	}
	if ($local =~ /SEM=([^|]+)/) {$semtype = $1}
	else {$semtype = ''}
	if ($semtype) {
	    $semtype =~ s/,/ $sem_prefix:/g;
	    $element =~ s|>| ana="$sem_prefix:$semtype">|;
	}
        $element =~ s|>| join="right">| unless $space;
        push @ids, $id . '.t' . $n;
        push @toks, $element;
        push @deps, "$link\t$n\t$role" #Only if we have a parse
            if $role ne '_';
}

    # If we haven't closed the last semantic phrase or name
    while (@open_elements) {
	$element = pop(@open_elements);
        push(@toks, '</' . $element . '>')
    }
    #Give IDs to tokens
    foreach my $id (@ids) {
	$element = '';
	#We can have a <name> tags here, skip them for IDs
	while ($element !~ m|<w | and $element !~ m|<pc | and @toks) {
	    $tei .= "$element\n";
	    if (@toks) {$element = shift @toks}
	    else {$element = ''}
	}
	$element =~ s| | xml:id="$id" |;
	$tei .= "$element" if $element;
    }
    # If tags left over, e.g. </name>
    while (@toks) {$tei .= shift @toks}
    if (@deps) {
        $tei .= "<linkGrp type=\"$ud_type\" targFunc=\"head argument\" corresp=\"#$id\">\n";
        foreach $dep (@deps) {
            my ($head, $arg, $role) = split /\t/, $dep;
            $head_id = $id;  #if 0 points to sentence id
            $head_id .= '.t' . $head if $head; 
            $arg_id = $id . '.t' . $arg;
            $tei .= "  <link ana=\"$ud_prefix:$role\" target=\"#$head_id #$arg_id\"/>\n";
        }
        $tei .=  "</linkGrp>";
    }
    $tei .= "\n</s>\n";
    return $tei
}

sub xml_encode {
    my $str = shift;
    $str =~ s|&|&amp;|g;
    $str =~ s|<|&lt;|g;
    $str =~ s|>|&gt;|g;
    #Don't really want to do it for content
    #$str =~ s|"|&quot;|g;
    return $str
}
