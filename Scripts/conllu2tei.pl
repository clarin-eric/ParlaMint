#!/usr/bin/perl
# Convert CoNLL-U file to TEI <body>
# Also encodes USAS semantic information
# This is a slightly modified script for ParlaMint from
# https://github.com/clarinsi/TEI-conversions/blob/645dfbece8f52b45a51f159f5874e1038f9f1c12/Scripts/conllu2tei.pl

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

#All USAS phrases encountered and how many skipped
$phr_all = 0;
$phr_skipped = 0;

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

print STDERR "INFO: Phrases all: $phr_all, skipped: $phr_skipped\n";

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
    $tei = "<s xml:id=\"$id\" n=\"$n\">";
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
		if ($open_elements[0] eq 'phr') {shift(@open_elements)}
		else {pop(@open_elements)}
	    }
	    if ($sem eq 'B') {
		($semtype) = $local =~ /SEM=([^|]+)/;
		$semana = &sem2ana($semtype);
		push(@toks, "<phr type=\"sem\" function=\"$semtype\" ana=\"$semana\">");
		push(@open_elements, 'phr');
	    }
	    $sem_prev = $sem
        }
        #Encoding <name>
        if (($ner) = $local =~ /NER=([A-Z-]+)/) {
            if (($type) = $ner =~ /^B-(.+)/) {
                if ($ner_prev ne 'O') {
                    push(@toks, "</name>");
		    if ($open_elements[0] eq 'name') {shift(@open_elements)}
		    else {pop(@open_elements)}
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
		if ($open_elements[0] eq 'name') {shift(@open_elements)}
		else {pop(@open_elements)}
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
	    $semana = &sem2ana($semtype);
	    $element =~ s|>| function="$semtype" ana="$semana">|;
	}
        $element =~ s|>| join="right">| unless $space;
        push @ids, $id . '.t' . $n;
        push @toks, $element;
        push @deps, "$link\t$n\t$role" #Only if we have a parse
            if $role ne '_';
    }

    # If we haven't closed the last semantic phr or name, close them.
    # NB: the order can be wrong, e.g. <name> <phr> </name> </phr>
    while (@open_elements) {
	$element = pop(@open_elements);
        push(@toks, '</' . $element . '>')
    }

    # Here we fix the nesting of <name> and <phr>: remove <phr> if crossing but also phr/name or name/phr
    # So, we have no semantically tagged multi-word expressions inside names, or containing names.
    @toks = &fix_elements(@toks);
    
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
    while (@toks) {$tei .= "\n" . shift(@toks)}
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

# Fix the nesting of <name> and <phr> by removing <phr> if crossing with <name>
# Also removes phr/name or name/phr!
# So, we have no semantically tagged multi-word expressions inside names, or containing names.
sub fix_elements {
    my @in = @_; #List of tokens, with badly nested <name> and <tag>
    my $i = 0;   #Counter through in array
    my @tmp;     #Output with empty values for deleted <phr> (and </phr>)
    my @out;     #Clean output without clasing <phr>
    my $open_name;  #At current input we are inside <name>
    my $open_phr;   #At current input we are inside <phr>
    foreach $item (@in) {
	# For debugging in case of unexpected input
	# if ($open_name) {print STDERR "In <name>\n"}
	# if ($open_phr)  {print STDERR "In <phr>\n"}
	# print STDERR "Item is $item\n";
	if ($item =~ m|<phr |) {
	    $phr_all++;
	    if ($open_name) { #skip <phr> inside name
		# print STDERR "Skipping <phr>\n";
		$phr_skipped++;
	    } 
	    elsif (not $open_phr) {
		push(@tmp, $item);
		$open_phr = 1;
	    }
	    else {die "Strange situation: <phr> but phr already open!\n"}
	}
	elsif ($item =~ m|<name |) {
	    if ($open_phr) {  #remove phr containing name
		my $i = -1;
		while (-$i <= $#tmp and $tmp[$i] !~ m|<phr|) {--$i}
		# print STDERR "$i: <phr>...<name>: $tmp[$i]\n";
		$tmp[$i] = '';
		push(@tmp, $item);
		$open_phr = 0;
		$open_name = 1;
		$phr_skipped++;
	    } 
	    elsif (not $open_name) {
		push(@tmp, $item);
		$open_name = 1;
	    }
	    else {die "Strange situation: <name> but name already open!\n"}
	}
	elsif ($item =~ m|</phr>|) {
	    if ($open_name) { # <phr> <name> </phr> -> <name>
		if ($open_phr) {
		    my $i = -1;
		    while (-$i <= $#tmp and $tmp[$i] !~ m|<phr|) {--$i}
		    # print STDERR "$i: <name>...</phr>: $tmp[$i]\n";
		    $tmp[$i] = '';
		    $open_phr = 0;
		    $phr_skipped++;
		}
	    }
	    elsif ($open_phr) {
		push(@tmp, $item);
		$open_phr = 0;
	    }
	    else {} # Closing phrase, but phrase not open, was deleted
	}
	elsif ($item =~ m|</name>|) {
	    if ($open_phr) {
		my $i = -1;
		while (-$i <= $#tmp and $tmp[$i] !~ m|<phr|) {--$i}
		# print STDERR "$i: <phr>...</name>: $tmp[$i]\n";
		$tmp[$i] = '';
		$open_phr = 0;
		$phr_skipped++;
	    }
	    if ($open_name) {
		push(@tmp, $item);
		$open_name = 0;
	    }
	    else {die "Strange situation: </name> but name not open!\n"}
	}
	else {push(@tmp, $item)}
    }
    foreach $item (@tmp) {push(@out, $item) if $item}
    return @out
}

# Convert USAS tags to simplified pointers for @ana, cf.
# https://github.com/clarin-eric/ParlaMint/issues/202
sub sem2ana {
    my $semtypes = shift;
    my @out;
    $semtypes =~ s/,.+//; #Retain only the first tag
    foreach my $semtype (split(m|/|, $semtypes)) {
	$semtype =~ s/[mfnci%\@]//g; #Remove modifiers
	$semtype =~ s/\-/m/g; #Change - to m
	$semtype =~ s/\+/p/g; #Change + to p
	push(@out, "$sem_prefix:$semtype")
    }
    return join(' ', @out)
}
