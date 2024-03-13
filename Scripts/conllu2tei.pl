#!/usr/bin/env perl
# Convert CoNLL-U file to TEI <body>
# Also encodes USAS semantic information if present
# This is a somewhat modified script for ParlaMint from
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
# Not needed anymore, as we map directly from DATA
# $sem_prefix   = 'sem';      # Prefix for semantic annotation

# ID prefixes
$doc_prefix  = 'doc';    # Prefix for document IDs, if they are numeric in source
$p_prefix    = 'p';      # Prefix for paragraph IDs, if they are numeric in source
$s_prefix    = 's';      # Prefix for sentence IDs, if they  are numeric or do not exist in source

#All USAS phrases encountered and how many skipped
$phr_all = 0;
$phr_skipped = 0;

while (<DATA>) {
    next unless /\t/;
    chomp;
    my ($usas, $ana) = split(/\t/);
    $usas2ana{$usas} = $ana
}

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
        $doc_id = $1;
	print STDERR "ERROR: empty doc id: $_\n" unless $doc_id;
        if (m|# newpar id|) {$has_p = 1}
        $has_div = 1;
        $s_n = 0;
        if ($has_s != -1) {
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
		($usas_tags) = $local =~ /SEM=([^|]+)/;
		$usas_first = $usas_tags;
		$usas_first =~ s/,.+//;  # Take first tag only
		die "FATAL ERROR: No mapping for USAS tag $usas_first in $usas_tags\n"
		    unless exists $usas2ana{$usas_first};
		$usas_anas = $usas2ana{$usas_first};
		push(@toks, "<phr type=\"sem\" function=\"$usas_tags\" ana=\"$usas_anas\">");
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
                die "FATAL ERROR: Found NER=O with open NER, but no name found in open_elements for $line\n"
                    unless @open_elements;
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
                ## Too verbose: print STDERR "WARN: changing empty lemma to $token for $line\n";
		$lemma = $token
	    }
	    $element =~ s|>| lemma=\"$lemma\">|
	}
	if ($local =~ /SEM=([^|]+)/) {$usas_tags = $1}
	else {$usas_tags = ''}
	if ($usas_tags) {
	    $usas_first = $usas_tags;
	    $usas_first =~ s/,.+//;  # Take first tag only
	    die "FATAL ERROR: No mapping for USAS tag $usas_first in $usas_tags\n"
		unless exists $usas2ana{$usas_first};
	    $usas_anas = $usas2ana{$usas_first};
	    $element =~ s|>| function="$usas_tags" ana="$usas_anas">|;
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

#Mapping from (first) USAS tag to ParlaMint USAS categories
__DATA__
A10+	sem:A10p
A10-	sem:A10n
A10---	sem:A10n
A10+/A5.2-	sem:A10p sem:A5.2n
A10+/G2.2-	sem:A10p sem:G2.2n
A10-/G2.2-	sem:A10n sem:G2.2n
A10+/H2	sem:A10p sem:H2
A10+/I1.1+	sem:A10p sem:I1.1p
A10-/I1.2	sem:A10n sem:I1.2
A10-/M1/S2mf	sem:A10n sem:M1 sem:S2
A10-/M7	sem:A10n sem:M7
A10+/N4	sem:A10p sem:N4
A10-/N5++	sem:A10n sem:N5p
A10+/N6+	sem:A10p sem:N6p
A10-/O2	sem:A10n sem:O2
A10-/Q1.1	sem:A10n sem:Q1.1
A10-/Q1.2	sem:A10n sem:Q1.2
A10+/Q2.1	sem:A10p sem:Q2.1
A10-/Q2.1	sem:A10n sem:Q2.1
A10-/Q2.2	sem:A10n sem:Q2.2
A10-/Q4.1	sem:A10n sem:Q4.1
A10+/S1.1.3+	sem:A10p sem:S1.1.3p
A10+/S1.2	sem:A10p sem:S1.2
A10+/S2mf	sem:A10p sem:S2
A10-/S2mf	sem:A10n sem:S2
A10-/S3.2	sem:A10n sem:S3.2
A10+/T1.3	sem:A10p sem:T1.3
A10+/X2.1	sem:A10p sem:X2.1
A1.1.1	sem:A1.1.1
A1.1.1-	sem:A1.1.1n
A11.1	sem:A11.1
A11.1+	sem:A11.1p
A11.1++	sem:A11.1p
A11.1+++	sem:A11.1p
A11.1-	sem:A11.1n
A11.1--	sem:A11.1n
A11.1---	sem:A11.1n
A1.1.1/A10-	sem:A1.1.1 sem:A10n
A1.1.1/A12-	sem:A1.1.1 sem:A12n
A1.1.1/A15+	sem:A1.1.1 sem:A15p
A1.1.1/A1.5.2+	sem:A1.1.1 sem:A1.5.2p
A1.1.1/A1.7+	sem:A1.1.1 sem:A1.7p
A11.1+/A1.8+	sem:A11.1p sem:A1.8p
A11.1+/A2.1	sem:A11.1p sem:A2.1
A11.1+/A2.1+	sem:A11.1p sem:A2.1p
A11.1-/A2.1	sem:A11.1n sem:A2.1
A11.1-/A8	sem:A11.1n sem:A8
A1.1.1/A9-	sem:A1.1.1 sem:A9n
A1.1.1c	sem:A1.1.1
A1.1.1/E2-	sem:A1.1.1 sem:E2n
A1.1.1/E3+	sem:A1.1.1 sem:E3p
A11.1+/E6-	sem:A11.1p sem:E6n
A1.1.1/F4	sem:A1.1.1 sem:F4
A1.1.1/G2.2-	sem:A1.1.1 sem:G2.2n
A1.1.1/H1	sem:A1.1.1 sem:H1
A1.1.1/H3	sem:A1.1.1 sem:H3
A1.1.1/I3.1	sem:A1.1.1 sem:I3.1
A1.1.1/L2	sem:A1.1.1 sem:L2
A1.1.1/M1	sem:A1.1.1 sem:M1
A1.1.1/M7	sem:A1.1.1 sem:M7
A1.1.1/M8	sem:A1.1.1 sem:M8
A1.1.1/N4	sem:A1.1.1 sem:N4
A1.1.1/N5+	sem:A1.1.1 sem:N5p
A1.1.1/N5++	sem:A1.1.1 sem:N5p
A1.1.1/N5+++	sem:A1.1.1 sem:N5p
A1.1.1/N5-	sem:A1.1.1 sem:N5n
A1.1.1/N5.2+	sem:A1.1.1 sem:N5.2p
A1.1.1/N5.2-	sem:A1.1.1 sem:N5.2
A11.1+/N5.2+	sem:A11.1p sem:N5.2p
A1.1.1/N5.2+mfn	sem:A1.1.1 sem:N5.2p
A1.1.1/N5+mf	sem:A1.1.1 sem:N5p
A1.1.1/N6+	sem:A1.1.1 sem:N6p
A11.1+/N6+	sem:A11.1p sem:N6p
A1.1.1/O1.2	sem:A1.1.1 sem:O1.2
A1.1.1/O2	sem:A1.1.1 sem:O2
A1.1.1/O4.5	sem:A1.1.1 sem:O4.5
A11.1+/P1	sem:A11.1p sem:P1
A11.1+/Q1.1	sem:A11.1p sem:Q1.1
A11.1-/Q1.1	sem:A11.1n sem:Q1.1
A11.1-/Q2.2	sem:A11.1n sem:Q2.2
A11.1++/Q2.2/S2mf	sem:A11.1p sem:Q2.2 sem:S2
A11.1+/S1.1.1	sem:A11.1p sem:S1.1.1
A11.1-/S2.1m	sem:A11.1n sem:S2.1
A1.1.1/S2mf	sem:A1.1.1 sem:S2
A1.1.1-/S2mf	sem:A1.1.1n sem:S2
A11.1+/S2mf	sem:A11.1p sem:S2
A11.1-/S2mf	sem:A11.1n sem:S2
A1.1.1/S2mfc	sem:A1.1.1 sem:S2
A1.1.1/S5+	sem:A1.1.1 sem:S5p
A1.1.1/S5-	sem:A1.1.1 sem:S5n
A1.1.1/S5+c	sem:A1.1.1 sem:S5p
A11.1+/S5+c	sem:A11.1p sem:S5p
A1.1.1/S7.1+	sem:A1.1.1 sem:S7.1p
A1.1.1/S7.2+	sem:A1.1.1 sem:S7.2p
A1.1.1/S7.4+	sem:A1.1.1 sem:S7.4p
A1.1.1/T1.1.2	sem:A1.1.1 sem:T1.1.2
A1.1.1/T1.3+	sem:A1.1.1 sem:T1.3p
A1.1.1/W4	sem:A1.1.1 sem:W4
A1.1.1/X2.1	sem:A1.1.1 sem:X2.1
A11.1+/X2.1	sem:A11.1p sem:X2.1
A1.1.1/X4.2	sem:A1.1.1 sem:X4.2
A1.1.1/X7-	sem:A1.1.1 sem:X7n
A1.1.1/X9.2-	sem:A1.1.1 sem:X9.2n
A1.1.1/Z6	sem:A1.1.1 sem:Z6
A1.1.2	sem:A1.1.2
A1.1.2-	sem:A1.1.2n
A11.2+	sem:A11.2p
A11.2-	sem:A11.2n
A1.1.2/A2.1	sem:A1.1.2 sem:A2.1
A11.2+/A2.1	sem:A11.2p sem:A2.1
A11.2+/A4.2+	sem:A11.2p sem:A4.2p
A1.1.2/A9-	sem:A1.1.2 sem:A9n
A1.1.2/B2-	sem:A1.1.2 sem:B2n
A1.1.2/E3-	sem:A1.1.2 sem:E3n
A1.1.2/G2.1/S2mf	sem:A1.1.2 sem:G2.1 sem:S2
A1.1.2/L1-	sem:A1.1.2 sem:L1n
A11.2+mfn	sem:A11.2p
A1.1.2/O2	sem:A1.1.2 sem:O2
A1.1.2/O4.4	sem:A1.1.2 sem:O4.4
A1.1.2/S2mf	sem:A1.1.2 sem:S2
A1.1.2/S9	sem:A1.1.2 sem:S9
A1.2	sem:A1.2
A1.2+	sem:A1.2p
A1.2-	sem:A1.2n
A12+	sem:A12p
A12++	sem:A12p
A12+++	sem:A12p
A12-	sem:A12n
A12--	sem:A12n
A12---	sem:A12n
A1.2.4-/Q2.2	sem:A1.2 sem:Q2.2
A12+/A2.1	sem:A12p sem:A2.1
A1.2+/I3.2+	sem:A1.2p sem:I3.2p
A1.2-/I3.2	sem:A1.2n sem:I3.2
A12-/M7	sem:A12n sem:M7
A1.2/N5.1+	sem:A1.2 sem:N5.1p
A12-/N5.1+	sem:A12n sem:N5.1p
A12+/N5.2+	sem:A12p sem:N5.2p
A12+/P1	sem:A12p sem:P1
A12+/Q2.2	sem:A12p sem:Q2.2
A12-/S2mf	sem:A12n sem:S2
A1.2/S5-	sem:A1.2 sem:S5n
A12+/X4.2	sem:A12p sem:X4.2
A1.3	sem:A1.3
A1.3+	sem:A1.3p
A1.3-	sem:A1.3n
A13	sem:A13
A13.1	sem:A13.1
A13.2	sem:A13.2
A13.3	sem:A13.3
A13.4	sem:A13.4
A13.5	sem:A13.5
A13.6	sem:A13.6
A13.7	sem:A13.7
A13/A6	sem:A13 sem:A6
A1.3+/I1	sem:A1.3p sem:I1
A1.4	sem:A1.4
A1.4+	sem:A1.4p
A1.4-	sem:A1.4n
A14	sem:A14
A1.4-/A1.1.1	sem:A1.4n sem:A1.1.1
A1.4/A1.5.1	sem:A1.4 sem:A1.5.1
A1.4/Df	sem:A1.4
A1.4/I1/A15-	sem:A1.4 sem:I1 sem:A15n
A14/Q4.2	sem:A14 sem:Q4.2
A1.4/S2mf	sem:A1.4 sem:S2
A1.4-/S2mf	sem:A1.4n sem:S2
A1.4/S8-	sem:A1.4 sem:S8n
A1.5	sem:A1.5
A15	sem:A15
A15+	sem:A15p
A15++	sem:A15p
A15+++	sem:A15p
A15-	sem:A15n
A1.5.1	sem:A1.5.1
A1.5.1+	sem:A1.5.1p
A1.5.1-	sem:A1.5.1n
A1.5.1/A1.3+	sem:A1.5.1 sem:A1.3p
A1.5.1/A9+/S2mf	sem:A1.5.1 sem:A9p sem:S2
A1.5.1/F4	sem:A1.5.1 sem:F4
A1.5.1/M7	sem:A1.5.1 sem:M7
A1.5.1/N5+	sem:A1.5.1 sem:N5p
A1.5.1/N5-	sem:A1.5.1 sem:N5n
A1.5.1/N5.2+	sem:A1.5.1 sem:N5.2p
A1.5.1/N6	sem:A1.5.1 sem:N6
A1.5.1/N6+	sem:A1.5.1 sem:N6p
A1.5.1/S2mf	sem:A1.5.1 sem:S2
A1.5.1/S5+	sem:A1.5.1 sem:S5p
A1.5.1/S6+	sem:A1.5.1 sem:S6p
A1.5.2	sem:A1.5.2
A1.5.2+	sem:A1.5.2p
A1.5.2-	sem:A1.5.2n
A1.5.2+/O4.2+	sem:A1.5.2p sem:O4.2p
A1.5.2-/S2mf	sem:A1.5.2n sem:S2
A15-/A1.1.1	sem:A15n sem:A1.1.1
A15+/B5	sem:A15p sem:B5
A15+/E1	sem:A15p sem:E1
A15+/G3	sem:A15p sem:G3
A15+/I3.2/S2mf	sem:A15p sem:I3.2 sem:S2
A15-/K5.1	sem:A15n sem:K5.1
A15+/M3	sem:A15p sem:M3
A15+/M7	sem:A15p sem:M7
A15+/O2	sem:A15p sem:O2
A15/S2mf	sem:A15 sem:S2
A15/X2.4	sem:A15 sem:X2.4
A15-/X9.2+	sem:A15n sem:X9.2p
A1.6	sem:A1.6
A1.6/S2mf	sem:A1.6 sem:S2
A1.7+	sem:A1.7p
A1.7+++	sem:A1.7p
A1.7-	sem:A1.7n
A1.7+/A2.1	sem:A1.7p sem:A2.1
A1.7-/A2.1	sem:A1.7n sem:A2.1
A1.7++/G1.1	sem:A1.7p sem:G1.1
A1.7+/G1.1	sem:A1.7p sem:G1.1
A1.7-/G1.1	sem:A1.7n sem:G1.1
A1.7+/G2.1	sem:A1.7p sem:G2.1
A1.7+/L1-	sem:A1.7p sem:L1n
A1.7+/L2	sem:A1.7p sem:L2
A1.7-/M1	sem:A1.7n sem:M1
A1.7-/M4	sem:A1.7n sem:M4
A1.7+/N4	sem:A1.7p sem:N4
A1.7-/O1.2	sem:A1.7n sem:O1.2
A1.7+/O2	sem:A1.7p sem:O2
A1.7+/S2mf	sem:A1.7p sem:S2
A1.7-/S2mf	sem:A1.7n sem:S2
A1.7-/S9	sem:A1.7n sem:S9
A1.7+/X2.1	sem:A1.7p sem:X2.1
A1.8+	sem:A1.8p
A1.8-	sem:A1.8n
A1.8-/B2-	sem:A1.8n sem:B2n
A1.8+/G1.1	sem:A1.8p sem:G1.1
A1.8-/G1.2@	sem:A1.8n sem:G1.2
A1.8-/G2.1	sem:A1.8n sem:G2.1
A1.8-/I3.2	sem:A1.8n sem:I3.2
A1.8+/N4	sem:A1.8p sem:N4
A1.8-/S2mf	sem:A1.8n sem:S2
A1.8+/T1.3	sem:A1.8p sem:T1.3
A1.8+/X2.2+/S2mf	sem:A1.8p sem:X2.2p sem:S2
A1.9	sem:A1.9
A1.9-	sem:A1.9n
A1.9/A11.2+	sem:A1.9 sem:A11.2p
A1.9/G2.1	sem:A1.9 sem:G2.1
A1.9/I3.1	sem:A1.9 sem:I3.1
A1.9/S1.2.3+	sem:A1.9 sem:S1.2.3p
A1.9/S2mf	sem:A1.9 sem:S2
A2.1	sem:A2.1
A2.1+	sem:A2.1p
A2.1-	sem:A2.1n
A2.1--	sem:A2.1n
A2.1+/A3+	sem:A2.1p sem:A3p
A2.1+/A5.1+	sem:A2.1p sem:A5.1p
A2.1+/A5.1-	sem:A2.1p sem:A5.1n
A2.1+/A5.1+/M7	sem:A2.1p sem:A5.1p sem:M7
A2.1+/A6.1-	sem:A2.1p sem:A6.1n
A2.1+/A7---	sem:A2.1p sem:A7n
A2.1+/G2.2-	sem:A2.1p sem:G2.2n
A2.1+/I1.3	sem:A2.1p sem:I1.3
A2.1/M7	sem:A2.1 sem:M7
A2.1+/M7	sem:A2.1p sem:M7
A2.1+/N3.8+	sem:A2.1p sem:N3.8p
A2.1+/N6+	sem:A2.1p sem:N6p
A2.1-/O1	sem:A2.1n sem:O1
A2.1/Q2.2	sem:A2.1 sem:Q2.2
A2.1+/S2mf	sem:A2.1p sem:S2
A2.1-/S2mf	sem:A2.1n sem:S2
A2.1+/S6-	sem:A2.1p sem:S6n
A2.1+/S9	sem:A2.1p sem:S9
A2.1/X2.1	sem:A2.1 sem:X2.1
A2.1-/X2.1	sem:A2.1n sem:X2.1
A2.1-/X2.1/S2mf	sem:A2.1n sem:X2.1 sem:S2
A2.1+/Y2	sem:A2.1p sem:Y2
A2.1/Z2	sem:A2.1 sem:Z2
A2.2	sem:A2.2
A2.2+	sem:A2.2p
A2.2-	sem:A2.2n
A2.2/A12+	sem:A2.2 sem:A12p
A2.2/A12-	sem:A2.2 sem:A12n
A2.2/A5.4-/S2.2m	sem:A2.2 sem:A5.4n sem:S2.2
A2.2/E1	sem:A2.2 sem:E1
A2.2/E2++	sem:A2.2 sem:E2p
A2.2/E4.1-	sem:A2.2 sem:E4.1n
A2.2/G2.2-	sem:A2.2 sem:G2.2n
A2.2/L3	sem:A2.2 sem:L3
A2.2mfn	sem:A2.2
A2.2/N3.2	sem:A2.2 sem:N3.2
A2.2/Q2.2	sem:A2.2 sem:Q2.2
A2.2/S1.2.4+	sem:A2.2 sem:S1.2.4p
A2.2/S2mf	sem:A2.2 sem:S2
A2.2/X2.1	sem:A2.2 sem:X2.1
A3	sem:A3
A3+	sem:A3p
A3-	sem:A3n
A3+/A11.1+	sem:A3p sem:A11.1p
A3+/A1.6	sem:A3p sem:A1.6
A3+/A5.1-	sem:A3p sem:A5.1n
A3+/S2mf	sem:A3p sem:S2
A3/T1.3	sem:A3 sem:T1.3
A3+/T2++	sem:A3p sem:T2p
A4.1	sem:A4.1
A4.1-	sem:A4.1n
A4.1/A2.1	sem:A4.1 sem:A2.1
A4.1/A6.2+	sem:A4.1 sem:A6.2p
A4.1c	sem:A4.1
A4.1/I1	sem:A4.1 sem:I1
A4.1/L2	sem:A4.1 sem:L2
A4.1/L3	sem:A4.1 sem:L3
A4.1/N6+	sem:A4.1 sem:N6p
A4.1/S2mf	sem:A4.1 sem:S2
A4.1/X2.4	sem:A4.1 sem:X2.4
A4.2+	sem:A4.2p
A4.2++	sem:A4.2p
A4.2-	sem:A4.2n
A4.2--	sem:A4.2n
A4.2---	sem:A4.2n
A4.2+/I3.1	sem:A4.2p sem:I3.1
A4.2/N5.2+	sem:A4.2 sem:N5.2p
A4.2+/P1	sem:A4.2p sem:P1
A4.2+/Q2.2	sem:A4.2p sem:Q2.2
A4.2+/S2mf	sem:A4.2p sem:S2
A5.1	sem:A5.1
A5.1+	sem:A5.1p
A5.1++	sem:A5.1p
A5.1+++	sem:A5.1p
A5.1-	sem:A5.1n
A5.1--	sem:A5.1n
A5.1---	sem:A5.1n
A5.1+/A13.4	sem:A5.1p sem:A13.4
A5.1+++/A2.1	sem:A5.1p sem:A2.1
A5.1+++/A2.1+	sem:A5.1p sem:A2.1p
A5.1+/A2.1	sem:A5.1p sem:A2.1
A5.1+/A2.1+	sem:A5.1p sem:A2.1p
A5.1--/A2.1	sem:A5.1n sem:A2.1
A5.1-/A2.1	sem:A5.1n sem:A2.1
A5.1+/A2.1/H1	sem:A5.1p sem:A2.1 sem:H1
A5.1+/A2.1/S2mf	sem:A5.1p sem:A2.1 sem:S2
A5.1+/A2.2	sem:A5.1p sem:A2.2
A5.1--/A2.2	sem:A5.1n sem:A2.2
A5.1-/A2.2	sem:A5.1n sem:A2.2
A5.1+++/A4.1	sem:A5.1p sem:A4.1
A5.1++/A4.1	sem:A5.1p sem:A4.1
A5.1-/A5.1+	sem:A5.1n sem:A5.1p
A5.1/A6.1-	sem:A5.1 sem:A6.1n
A5.1-/A6.1-	sem:A5.1n sem:A6.1n
A5.1+/A9-	sem:A5.1p sem:A9n
A5.1+/F1	sem:A5.1p sem:F1
A5.1/G1.1	sem:A5.1 sem:G1.1
A5.1/I2.1	sem:A5.1 sem:I2.1
A5.1/L1	sem:A5.1 sem:L1
A5.1-/M7	sem:A5.1n sem:M7
A5.1/N6+	sem:A5.1 sem:N6p
A5.1/Q1.2	sem:A5.1 sem:Q1.2
A5.1+/Q1.2	sem:A5.1p sem:Q1.2
A5.1+/Q2.2	sem:A5.1p sem:Q2.2
A5.1-/S2.1f	sem:A5.1n sem:S2.1
A5.1-/S2.2m	sem:A5.1n sem:S2.2
A5.1/S2mf	sem:A5.1 sem:S2
A5.1+++/S2mf	sem:A5.1p sem:S2
A5.1++/S2mf	sem:A5.1p sem:S2
A5.1+/S2mf	sem:A5.1p sem:S2
A5.1-/S2mf	sem:A5.1n sem:S2
A5.1-/S2mf/T3-	sem:A5.1n sem:S2 sem:T3n
A5.1+++/S5+c	sem:A5.1p sem:S5p
A5.1+++/T1.2	sem:A5.1p sem:T1.2
A5.1+/X2.1	sem:A5.1p sem:X2.1
A5.1-/X2.1	sem:A5.1n sem:X2.1
A5.1/X2.4	sem:A5.1 sem:X2.4
A5.1+/X2.6+	sem:A5.1p sem:X2.6p
A5.1-/X2.6	sem:A5.1n sem:X2.6
A5.1+++/X4.1	sem:A5.1p sem:X4.1
A5.1+/X7+	sem:A5.1p sem:X7p
A5.1+++/X9.2+	sem:A5.1p sem:X9.2p
A5.2+	sem:A5.2p
A5.2++	sem:A5.2p
A5.2+++	sem:A5.2p
A5.2-	sem:A5.2n
A5.2/A7	sem:A5.2 sem:A7
A5.2+/A8	sem:A5.2p sem:A8
A5.2-/A8	sem:A5.2n sem:A8
A5.2-/E4.1+	sem:A5.2n sem:E4.1p
A5.2-/G2.1-	sem:A5.2n sem:G2.1n
A5.2-/Q2.2	sem:A5.2n sem:Q2.2
A5.2-/S2mf	sem:A5.2n sem:S2
A5.2-/X2.1	sem:A5.2n sem:X2.1
A5.2-/X2.2	sem:A5.2n sem:X2.2
A5.2-/X4.1	sem:A5.2n sem:X4.1
A5.3+	sem:A5.3p
A5.3++	sem:A5.3p
A5.3-	sem:A5.3n
A5.3+/A2.1	sem:A5.3p sem:A2.1
A5.3+++/S2mf	sem:A5.3p sem:S2
A5.4+	sem:A5.4p
A5.4+++	sem:A5.4p
A5.4-	sem:A5.4n
A5.4-/A1.1.1	sem:A5.4n sem:A1.1.1
A5.4-/A2.2	sem:A5.4n sem:A2.2
A5.4-/A8	sem:A5.4n sem:A8
A5.4-/O2	sem:A5.4n sem:O2
A5.4-/S2mf	sem:A5.4n sem:S2
A5.4-/S7.1+	sem:A5.4n sem:S7.1p
A5.4-/T1.3	sem:A5.4n sem:T1.3
A5/N6	sem:A5 sem:N6
A6	sem:A6
A6.1	sem:A6.1
A6.1+	sem:A6.1p
A6.1+++	sem:A6.1p
A6.1-	sem:A6.1n
A6.1-/A15+	sem:A6.1n sem:A15p
A6.1+/A2.1	sem:A6.1p sem:A2.1
A6.1-/A2.1	sem:A6.1n sem:A2.1
A6.1-/A2.1+	sem:A6.1n sem:A2.1p
A6.1+/A5.4-	sem:A6.1p sem:A5.4n
A6.1-/E2-	sem:A6.1n sem:E2n
A6.1-/E3-	sem:A6.1n sem:E3n
A6.1+mfn	sem:A6.1p
A6.1+/N3.5	sem:A6.1p sem:N3.5
A6.1-/O2	sem:A6.1n sem:O2
A6.1-/Q2.2	sem:A6.1n sem:Q2.2
A6.1-/S1.1.1	sem:A6.1n sem:S1.1.1
A6.1+/S1.1.2+	sem:A6.1p sem:S1.1.2p
A6.1+/S2mf	sem:A6.1p sem:S2
A6.1+/S5+c	sem:A6.1p sem:S5p
A6.1+/S8+	sem:A6.1p sem:S8p
A6.1+/X2.1	sem:A6.1p sem:X2.1
A6.1-/X2.1	sem:A6.1n sem:X2.1
A6.1-/X2.1mf	sem:A6.1n sem:X2.1
A6.1-/X2.2	sem:A6.1n sem:X2.2
A6.1-/X2.6	sem:A6.1n sem:X2.6
A6.1-/Z8	sem:A6.1n sem:Z8
A6.2+	sem:A6.2p
A6.2++	sem:A6.2p
A6.2+++	sem:A6.2p
A6.2-	sem:A6.2n
A6.2--	sem:A6.2n
A6.2---	sem:A6.2n
A6.2+/A2.1	sem:A6.2p sem:A2.1
A6.2-/A2.1	sem:A6.2n sem:A2.1
A6.2-/K2	sem:A6.2n sem:K2
A6.2-/Q2.2	sem:A6.2n sem:Q2.2
A6.2+/S2mf	sem:A6.2p sem:S2
A6.2-/S2mf	sem:A6.2n sem:S2
A6.2+/X2.1	sem:A6.2p sem:X2.1
A6.3+	sem:A6.3p
A6.3++	sem:A6.3p
A6.3-	sem:A6.3n
A6.3+/G1.2	sem:A6.3p sem:G1.2
A6.3+/S5	sem:A6.3p sem:S5
A6.3+/S5+c	sem:A6.3p sem:S5p
A6/A5.1	sem:A6 sem:A5.1
A7	sem:A7
A7+	sem:A7p
A7++	sem:A7p
A7+++	sem:A7p
A7-	sem:A7n
A7+/A1.1.1	sem:A7p sem:A1.1.1
A7+/A2.1	sem:A7p sem:A2.1
A7+/A2.1-	sem:A7p sem:A2.1n
A7+/Q2.2	sem:A7p sem:Q2.2
A7+/Q3	sem:A7p sem:Q3
A7+/S2mf	sem:A7p sem:S2
A7-/S2mf	sem:A7n sem:S2
A7+++/S7.1-	sem:A7p sem:S7.1n
A7-/X2.1	sem:A7n sem:X2.1
A7+/X9	sem:A7p sem:X9
A7+/Z6	sem:A7p sem:Z6
A8	sem:A8
A8/A5.2+	sem:A8 sem:A5.2p
A8/S5	sem:A8 sem:S5
A9	sem:A9
A9+	sem:A9p
A9++	sem:A9p
A9-	sem:A9n
A9.1+++	sem:A9
A9+/A10-	sem:A9p sem:A10n
A9+/G2.1	sem:A9p sem:G2.1
A9+/G2.1-	sem:A9p sem:G2.1n
A9-/G2.1	sem:A9n sem:G2.1
A9-/G2.1-	sem:A9n sem:G2.1n
A9+/G2.2-	sem:A9p sem:G2.2n
A9-/G2.2+	sem:A9n sem:G2.2p
A9+/H1	sem:A9p sem:H1
A9+/I1	sem:A9p sem:I1
A9+/I1.1	sem:A9p sem:I1.1
A9-/I1.1	sem:A9n sem:I1.1
A9-/I1.1/S2mf	sem:A9n sem:I1.1 sem:S2
A9+/I1.3-	sem:A9p sem:I1.3n
A9+/I1/S2mf	sem:A9p sem:I1 sem:S2
A9-/M5	sem:A9n sem:M5
A9+/M7	sem:A9p sem:M7
A9+/N3.8+	sem:A9p sem:N3.8p
A9+/N5+	sem:A9p sem:N5p
A9-/N5.2+	sem:A9n sem:N5.2p
A9+/N6+	sem:A9p sem:N6p
A9-/N6	sem:A9n sem:N6
A9-/N6+	sem:A9n sem:N6p
A9-/O1.2	sem:A9n sem:O1.2
A9+/O1.3	sem:A9p sem:O1.3
A9+/Q1.2	sem:A9p sem:Q1.2
A9+/Q1.2/S2mf	sem:A9p sem:Q1.2 sem:S2
A9+/Q2.2	sem:A9p sem:Q2.2
A9+/Q2.2/H1	sem:A9p sem:Q2.2 sem:H1
A9+/Q2.2/I1.3	sem:A9p sem:Q2.2 sem:I1.3
A9+/Q2.2/N5.2+	sem:A9p sem:Q2.2 sem:N5.2p
A9+/Q2.2/Q1.2	sem:A9p sem:Q2.2 sem:Q1.2
A9+/Q2.2/S2mf	sem:A9p sem:Q2.2 sem:S2
A9+/S1.1.1	sem:A9p sem:S1.1.1
A9/S1.1.2+	sem:A9 sem:S1.1.2p
A9+/S2mf	sem:A9p sem:S2
A9-/S2mf	sem:A9n sem:S2
A9+/S4	sem:A9p sem:S4
A9-/S4	sem:A9n sem:S4
A9+/S5+	sem:A9p sem:S5p
A9/S7.1	sem:A9 sem:S7.1
A9+/S7.1+	sem:A9p sem:S7.1p
A9+/T1.3+	sem:A9p sem:T1.3p
A9+/X2.1	sem:A9p sem:X2.1
A9-/X7+	sem:A9n sem:X7p
A9+/Z6	sem:A9p sem:Z6
A9-/Z6	sem:A9n sem:Z6
A9+/Z8	sem:A9p sem:Z8
B1	sem:B1
B1/A1.1.2	sem:B1 sem:A1.1.2
B1/A12-	sem:B1 sem:A12n
B1/A2.1	sem:B1 sem:A2.1
B1/A9-	sem:B1 sem:A9n
B1/B3	sem:B1 sem:B3
B1/E2-	sem:B1 sem:E2n
B1/E4.1-	sem:B1 sem:E4.1n
B1/F1	sem:B1 sem:F1
B1/F2	sem:B1 sem:F2
B1/H4	sem:B1 sem:H4
B1/L1-	sem:B1 sem:L1n
B1/L2	sem:B1 sem:L2
B1/N5.2+	sem:B1 sem:N5.2p
B1/N6+	sem:B1 sem:N6p
B1/O1	sem:B1 sem:O1
B1/O2	sem:B1 sem:O2
B1/O4.3	sem:B1 sem:O4.3
B1/O4.4	sem:B1 sem:O4.4
B1/Q1.2	sem:B1 sem:Q1.2
B1/S2	sem:B1 sem:S2
B1/S2mf	sem:B1 sem:S2
B1/S3.2	sem:B1 sem:S3.2
B1/S4	sem:B1 sem:S4
B1/S9	sem:B1 sem:S9
B1/T1.3	sem:B1 sem:T1.3
B1/T1.3+	sem:B1 sem:T1.3p
B1/W4	sem:B1 sem:W4
B1/X3.2	sem:B1 sem:X3.2
B1/Y2/S9	sem:B1 sem:Y2 sem:S9
B2	sem:B2
B2+	sem:B2p
B2++	sem:B2p
B2+++	sem:B2p
B2-	sem:B2n
B2+/A2.1	sem:B2p sem:A2.1
B2-/B1	sem:B2n sem:B1
B2-/B3	sem:B2n sem:B3
B2-/E2+	sem:B2n sem:E2p
B2-/E3-	sem:B2n sem:E3n
B2-/E6-	sem:B2n sem:E6n
B2+/F1	sem:B2p sem:F1
B2-/F1	sem:B2n sem:F1
B2-/F1-	sem:B2n sem:F1n
B2-/F3	sem:B2n sem:F3
B2-/G2.1-/S2mf	sem:B2n sem:G2.1n sem:S2
B2-/I3.1-	sem:B2n sem:I3.1n
B2-/L2	sem:B2n sem:L2
B2-/M3	sem:B2n sem:M3
B2-/M4	sem:B2n sem:M4
B2-/M5	sem:B2n sem:M5
B2+/N6+	sem:B2p sem:N6p
B2-/O4.6+	sem:B2n sem:O4.6p
B2-/Q1.2	sem:B2n sem:Q1.2
B2-/Q2.1	sem:B2n sem:Q2.1
B2-/Q3/S2mf	sem:B2n sem:Q3 sem:S2
B2-/S1.1.1	sem:B2n sem:S1.1.1
B2-/S1.2	sem:B2n sem:S1.2
B2-/S1.2.6-	sem:B2n sem:S1.2.6n
B2-/S2mf	sem:B2n sem:S2
B2-/S3.2	sem:B2n sem:S3.2
B2-/S3.2-	sem:B2n sem:S3.2n
B2-/S4	sem:B2n sem:S4
B2-/S5+	sem:B2n sem:S5p
B2-/W4	sem:B2n sem:W4
B2/X1	sem:B2 sem:X1
B2+/X1	sem:B2p sem:X1
B2-/X1	sem:B2n sem:X1
B2-/X1c	sem:B2n sem:X1
B2-/X1mf	sem:B2n sem:X1
B2-/X2.2-	sem:B2n sem:X2.2n
B2-/X2/Q2	sem:B2n sem:X2 sem:Q2
B2/X3.4	sem:B2 sem:X3.4
B2-/X3.4	sem:B2n sem:X3.4
B2-/X3.4-	sem:B2n sem:X3.4n
B2-/X5.1	sem:B2n sem:X5.1
B2-/X5.1-	sem:B2n sem:X5.1n
B2+/X5.2+++mf	sem:B2p sem:X5.2p
B2-/Z6	sem:B2n sem:Z6
B3	sem:B3
B3/A4.2-	sem:B3 sem:A4.2n
B3/A9+	sem:B3 sem:A9p
B3/B1	sem:B3 sem:B1
B3c	sem:B3
B3/C1	sem:B3 sem:C1
B3/E3+	sem:B3 sem:E3p
B3/F1	sem:B3 sem:F1
B3/F3	sem:B3 sem:F3
B3/G1.1	sem:B3 sem:G1.1
B3/G1.1c	sem:B3 sem:G1.1
B3/G2.1	sem:B3 sem:G2.1
B3/G2.1-/S2mf	sem:B3 sem:G2.1n sem:S2
B3/H1	sem:B3 sem:H1
B3/H1c	sem:B3 sem:H1
B3/H2	sem:B3 sem:H2
B3/H2c	sem:B3 sem:H2
B3/H5	sem:B3 sem:H5
B3/I2.2	sem:B3 sem:I2.2
B3/I2.2c	sem:B3 sem:I2.2
B3/I3.1	sem:B3 sem:I3.1
B3/I3.1c	sem:B3 sem:I3.1
B3/I3.2/S2.1f	sem:B3 sem:I3.2 sem:S2.1
B3/I3.2/S2mf	sem:B3 sem:I3.2 sem:S2
B3/K2	sem:B3 sem:K2
B3/K5.1mf	sem:B3 sem:K5.1
B3/L3	sem:B3 sem:L3
B3/M3	sem:B3 sem:M3
B3/M3fn	sem:B3 sem:M3
B3/M3/S2.2m	sem:B3 sem:M3 sem:S2.2
B3/M5fn	sem:B3 sem:M5
B3/M6	sem:B3 sem:M6
B3/N5.2+	sem:B3 sem:N5.2p
B3/O1.1	sem:B3 sem:O1.1
B3/O2	sem:B3 sem:O2
B3/O3	sem:B3 sem:O3
B3/P1	sem:B3 sem:P1
B3/P1c	sem:B3 sem:P1
B3/Q1.2	sem:B3 sem:Q1.2
B3/Q3	sem:B3 sem:Q3
B3/S1.1.1	sem:B3 sem:S1.1.1
B3/S1.2	sem:B3 sem:S1.2
B3/S2	sem:B3 sem:S2
B3/S2.1f	sem:B3 sem:S2.1
B3/S2.2m	sem:B3 sem:S2.2
B3/S2c	sem:B3 sem:S2
B3/S2mf	sem:B3 sem:S2
B3/S3.2	sem:B3 sem:S3.2
B3/S4	sem:B3 sem:S4
B3/S5+c	sem:B3 sem:S5p
B3/W3	sem:B3 sem:W3
B3/X1	sem:B3 sem:X1
B3/X1c	sem:B3 sem:X1
B3/X2.4	sem:B3 sem:X2.4
B3/X3.2	sem:B3 sem:X3.2
B3/X3.4	sem:B3 sem:X3.4
B3/Y1	sem:B3 sem:Y1
B3/Z6	sem:B3 sem:Z6
B4	sem:B4
B4-	sem:B4n
B4/B1	sem:B4 sem:B1
B4/B5	sem:B4 sem:B5
B4/H1	sem:B4 sem:H1
B4/H1c	sem:B4 sem:H1
B4/H2	sem:B4 sem:H2
B4/H5	sem:B4 sem:H5
B4/I2.1	sem:B4 sem:I2.1
B4/I2.1c	sem:B4 sem:I2.1
B4/I2.2	sem:B4 sem:I2.2
B4/I3.2/S2.2m	sem:B4 sem:I3.2 sem:S2.2
B4/I3.2/S2mf	sem:B4 sem:I3.2 sem:S2
B4/L2	sem:B4 sem:L2
B4/M4	sem:B4 sem:M4
B4/M7	sem:B4 sem:M7
B4/O1	sem:B4 sem:O1
B4/O1.1	sem:B4 sem:O1.1
B4/O1.2	sem:B4 sem:O1.2
B4/O2	sem:B4 sem:O2
B4/O3	sem:B4 sem:O3
B4/O4.2+	sem:B4 sem:O4.2p
B4/S2.1f	sem:B4 sem:S2.1
B4/S2mf	sem:B4 sem:S2
B4/S5+	sem:B4 sem:S5p
B5	sem:B5
B5-	sem:B5n
B5/A10-/S9	sem:B5 sem:A10n sem:S9
B5/A1.1.1	sem:B5 sem:A1.1.1
B5/A1.1.2	sem:B5 sem:A1.1.2
B5/A1.7+	sem:B5 sem:A1.7p
B5/A5.1+	sem:B5 sem:A5.1p
B5/B4	sem:B5 sem:B4
B5/Df	sem:B5
B5/G2.1	sem:B5 sem:G2.1
B5/I1	sem:B5 sem:I1
B5/I1.1	sem:B5 sem:I1.1
B5/I2.2	sem:B5 sem:I2.2
B5/I2.2/H1	sem:B5 sem:I2.2 sem:H1
B5/I3.2/T1.1.1mf	sem:B5 sem:I3.2 sem:T1.1.1
B5/I4	sem:B5 sem:I4
B5/K1	sem:B5 sem:K1
B5/K4	sem:B5 sem:K4
B5/K5.1	sem:B5 sem:K5.1
B5/L1-	sem:B5 sem:L1n
B5/L2	sem:B5 sem:L2
B5/L2/S2mf	sem:B5 sem:L2 sem:S2
B5/M3	sem:B5 sem:M3
B5/M4	sem:B5 sem:M4
B5/N3.2	sem:B5 sem:N3.2
B5/N5.1-	sem:B5 sem:N5.1n
B5/O1.1	sem:B5 sem:O1.1
B5/O1.2-	sem:B5 sem:O1.2n
B5/O2	sem:B5 sem:O2
B5/O3	sem:B5 sem:O3
B5/O4.1	sem:B5 sem:O4.1
B5/O4.2	sem:B5 sem:O4.2
B5/O4.3	sem:B5 sem:O4.3
B5/P1	sem:B5 sem:P1
B5/Q1.2	sem:B5 sem:Q1.2
B5/Q4.2	sem:B5 sem:Q4.2
B5/S2	sem:B5 sem:S2
B5/S2.1f	sem:B5 sem:S2.1
B5/S2mf	sem:B5 sem:S2
B5-/S2mf	sem:B5n sem:S2
B5/S4	sem:B5 sem:S4
B5/S7.1+	sem:B5 sem:S7.1p
B5/S9	sem:B5 sem:S9
B5/T1	sem:B5 sem:T1
B5/T1.3	sem:B5 sem:T1.3
B5/T3-	sem:B5 sem:T3n
B5/W4	sem:B5 sem:W4
B5/X3.4	sem:B5 sem:X3.4
B5/Y1	sem:B5 sem:Y1
B5/Z2	sem:B5 sem:Z2
B5/Z3	sem:B5 sem:Z3
B5/Z3c	sem:B5 sem:Z3
C1	sem:C1
C1/A10+/S1.1.3+	sem:C1 sem:A10p sem:S1.1.3p
C1/A9+	sem:C1 sem:A9p
C1/B1	sem:C1 sem:B1
C1/H1	sem:C1 sem:H1
C1/H1c	sem:C1 sem:H1
C1/H1/S2mf	sem:C1 sem:H1 sem:S2
C1/H2	sem:C1 sem:H2
C1/I2.1	sem:C1 sem:I2.1
C1/I2.1/S2mf	sem:C1 sem:I2.1 sem:S2
C1/I3.2/S2.2m	sem:C1 sem:I3.2 sem:S2.2
C1/M7	sem:C1 sem:M7
C1/N3.2++	sem:C1 sem:N3.2p
C1/N5---	sem:C1 sem:N5n
C1/N6+	sem:C1 sem:N6p
C1/O1	sem:C1 sem:O1
C1/O2	sem:C1 sem:O2
C1/O4.2-	sem:C1 sem:O4.2n
C1/P1/H1	sem:C1 sem:P1 sem:H1
C1/Q1.1	sem:C1 sem:Q1.1
C1/Q1.2	sem:C1 sem:Q1.2
C1/Q4.1	sem:C1 sem:Q4.1
C1/Q4.3	sem:C1 sem:Q4.3
C1/S1.1.3+c	sem:C1 sem:S1.1.3p
C1/S2.2m	sem:C1 sem:S2.2
C1/S2mf	sem:C1 sem:S2
C1/S4	sem:C1 sem:S4
C1/S9	sem:C1 sem:S9
C1/T1.1.1	sem:C1 sem:T1.1.1
C1/T3+	sem:C1 sem:T3p
C1/T3-	sem:C1 sem:T3n
C1/Y1	sem:C1 sem:Y1
C1/Y2	sem:C1 sem:Y2
Df	sem:Z9
Df+++	sem:Z9
Df/A2.2	sem:A2.2
Df/A5.1+++mfnc	sem:A5.1p
Df/A8	sem:A8
Dfc	sem:Z9
Df/C1	sem:C1
Df/E2+	sem:E2p
Df/E2+mf	sem:E2p
Df/E4.1+mfn	sem:E4.1p
Df/E6-	sem:E6n
Df/H1c	sem:H1
Df/H2	sem:H2
Df/I2.1c	sem:I2.1
Df/I2.2	sem:I2.2
Df/I3.1	sem:I3.1
Df/I3.1c	sem:I3.1
Df/N5	sem:N5
Df/N5-	sem:N5n
Df/O2	sem:O2
Df/P1	sem:P1
Df/P1c	sem:P1
Df/Q4.1mf	sem:Q4.1
Df/S2m	sem:S2
Df/S5+	sem:S5p
Df/S5+c	sem:S5p
Df/X5.2+	sem:X5.2p
Df/X5.2+mf	sem:X5.2p
Df/X5.2++mfn	sem:X5.2p
Df/X7+	sem:X7p
Df/Z6	sem:Z6
E1	sem:E1
E1-	sem:E1n
E1/A1.7-	sem:E1 sem:A1.7n
E1/A2.1	sem:E1 sem:A2.1
E1/B1	sem:E1 sem:B1
E1/G2.2-	sem:E1 sem:G2.2n
E1/N5.2+	sem:E1 sem:N5.2p
E1/N5.2+/S2mf	sem:E1 sem:N5.2p sem:S2
E1/S1.2.5+	sem:E1 sem:S1.2.5p
E1/T1.1.1	sem:E1 sem:T1.1.1
E2	sem:E2
E2+	sem:E2p
E2++	sem:E2p
E2+++	sem:E2p
E2-	sem:E2n
E2--	sem:E2n
E2+/A1.1.1	sem:E2p sem:A1.1.1
E2+/A2.1	sem:E2p sem:A2.1
E2+/A5.4-	sem:E2p sem:A5.4n
E2+/I1.1	sem:E2p sem:I1.1
E2--/M7	sem:E2n sem:M7
E2-/Q2.2	sem:E2n sem:Q2.2
E2+/S2mf	sem:E2p sem:S2
E2-/S2mf	sem:E2n sem:S2
E2+/S2mF	sem:E2p sem:S2
E2-/S3.2	sem:E2n sem:S3.2
E2-/S3.2/S2m	sem:E2n sem:S3.2 sem:S2
E2+/T1.2	sem:E2p sem:T1.2
E2+/X3.2+	sem:E2p sem:X3.2p
E2-/X3.2	sem:E2n sem:X3.2
E2+/Z2	sem:E2p sem:Z2
E3+	sem:E3p
E3++	sem:E3p
E3-	sem:E3n
E3--	sem:E3n
E3---	sem:E3n
E3+/A1.1.1	sem:E3p sem:A1.1.1
E3-/A1.1.1	sem:E3n sem:A1.1.1
E3-/A1.1.2	sem:E3n sem:A1.1.2
E3+/A2.1	sem:E3p sem:A2.1
E3-/A2.1	sem:E3n sem:A2.1
E3+/G3	sem:E3p sem:G3
E3-/H2	sem:E3n sem:H2
E3/L1-	sem:E3 sem:L1n
E3+/L2	sem:E3p sem:L2
E3-/L2	sem:E3n sem:L2
E3+/N5.2+	sem:E3p sem:N5.2p
E3-/O1	sem:E3n sem:O1
E3-/O2	sem:E3n sem:O2
E3-/Q2.2	sem:E3n sem:Q2.2
E3-/S1.2	sem:E3n sem:S1.2
E3-/S2.2m	sem:E3n sem:S2.2
E3+/S2mf	sem:E3p sem:S2
E3-/S2mf	sem:E3n sem:S2
E3-/S4	sem:E3n sem:S4
E3+/S7.1+	sem:E3p sem:S7.1p
E3-/S7.1	sem:E3n sem:S7.1
E3-/X3.2+	sem:E3n sem:X3.2p
E3-/X3.4	sem:E3n sem:X3.4
E4.1+	sem:E4.1p
E4.1++	sem:E4.1p
E4.1+++	sem:E4.1p
E4.1-	sem:E4.1n
E4.1--	sem:E4.1n
E4.1---	sem:E4.1n
E4.1+/A2.2	sem:E4.1p sem:A2.2
E4.1-/A5.4-	sem:E4.1n sem:A5.4n
E4.1-/E2	sem:E4.1n sem:E2
E4.1-/E2/S2mf	sem:E4.1n sem:E2 sem:S2
E4.1-/G2.1-	sem:E4.1n sem:G2.1n
E4.1+/K5/S2mf	sem:E4.1p sem:K5 sem:S2
E4.1-/L1-	sem:E4.1n sem:L1n
E4.1+/S1.2.6-	sem:E4.1p sem:S1.2.6n
E4.1+/S2.2m	sem:E4.1p sem:S2.2
E4.1+/S2mf	sem:E4.1p sem:S2
E4.1-/S2mf	sem:E4.1n sem:S2
E4.1-/S3.2	sem:E4.1n sem:S3.2
E4.1-/T1.3	sem:E4.1n sem:T1.3
E4.1+/X3.2	sem:E4.1p sem:X3.2
E4.1+/X3.2++	sem:E4.1p sem:X3.2p
E4.2+	sem:E4.2p
E4.2++	sem:E4.2p
E4.2-	sem:E4.2n
E4.2-/A2.1	sem:E4.2n sem:A2.1
E4.2+/S1.2	sem:E4.2p sem:S1.2
E5+	sem:E5p
E5++	sem:E5p
E5+++	sem:E5p
E5-	sem:E5n
E5--	sem:E5n
E5-/A1.3+++	sem:E5n sem:A1.3p
E5-/A1.3+++/S2mf	sem:E5n sem:A1.3p sem:S2
E5-/B1	sem:E5n sem:B1
E5-/N3.7	sem:E5n sem:N3.7
E5-/Q2.1	sem:E5n sem:Q2.1
E5-/S1.1.1	sem:E5n sem:S1.1.1
E5+/S1.2	sem:E5p sem:S1.2
E5-/S1.2	sem:E5n sem:S1.2
E5-/S2mf	sem:E5n sem:S2
E6	sem:E6
E6+	sem:E6p
E6-	sem:E6n
E6--	sem:E6n
E6+/E4.2-	sem:E6p sem:E4.2n
E6-/G2.2	sem:E6n sem:G2.2
E6-/N5	sem:E6n sem:N5
E6+/N5.2+	sem:E6p sem:N5.2p
E6-/P1	sem:E6n sem:P1
E6+/Q2.2	sem:E6p sem:Q2.2
E6-/S2mf	sem:E6n sem:S2
E6+/S8+	sem:E6p sem:S8p
F1	sem:F1
F1-	sem:F1n
F1/A1.1.1	sem:F1 sem:A1.1.1
F1/A5.1+	sem:F1 sem:A5.1p
F1/B1	sem:F1 sem:B1
F1-/B1	sem:F1n sem:B1
F1/B2+	sem:F1 sem:B2p
F1/B2-	sem:F1 sem:B2n
F1/B5	sem:F1 sem:B5
F1c	sem:F1
F1/E1	sem:F1 sem:E1
F1/E2+	sem:F1 sem:E2p
F1/F2	sem:F1 sem:F2
F1/H1	sem:F1 sem:H1
F1/H1c	sem:F1 sem:H1
F1/H2	sem:F1 sem:H2
F1/I1	sem:F1 sem:I1
F1/I2.1/S5+	sem:F1 sem:I2.1 sem:S5p
F1/I2.2	sem:F1 sem:I2.2
F1/I2.2c	sem:F1 sem:I2.2
F1/I2.2/H1	sem:F1 sem:I2.2 sem:H1
F1/I4	sem:F1 sem:I4
F1/L2	sem:F1 sem:L2
F1/L3	sem:F1 sem:L3
F1/M3	sem:F1 sem:M3
F1/N3.1	sem:F1 sem:N3.1
F1/N3.2-	sem:F1 sem:N3.2n
F1/N4	sem:F1 sem:N4
F1/N5	sem:F1 sem:N5
F1/N5+	sem:F1 sem:N5p
F1/N5-	sem:F1 sem:N5n
F1/N5.1-	sem:F1 sem:N5.1n
F1/N5.2+	sem:F1 sem:N5.2p
F1/O2	sem:F1 sem:O2
F1/O3	sem:F1 sem:O3
F1/O4.1	sem:F1 sem:O4.1
F1/P1	sem:F1 sem:P1
F1/Q1.2	sem:F1 sem:Q1.2
F1/Q4.1	sem:F1 sem:Q4.1
F1/S1.1.3	sem:F1 sem:S1.1.3
F1/S1.1.3+c	sem:F1 sem:S1.1.3p
F1/S2	sem:F1 sem:S2
F1/S2.1f	sem:F1 sem:S2.1
F1/S2.2m	sem:F1 sem:S2.2
F1/S2c	sem:F1 sem:S2
F1/S2mf	sem:F1 sem:S2
F1/S2/S2mf	sem:F1 sem:S2 sem:S2
F1/S4	sem:F1 sem:S4
F1/S9	sem:F1 sem:S9
F1/T1.3	sem:F1 sem:T1.3
F1/T3-	sem:F1 sem:T3n
F1/X2.2+	sem:F1 sem:X2.2p
F1/Z3c	sem:F1 sem:Z3
F2	sem:F2
F2++	sem:F2p
F2-	sem:F2n
F2/A1.1.1	sem:F2 sem:A1.1.1
F2/A1.1.1/H1c	sem:F2 sem:A1.1.1 sem:H1
F2/A1.1.1/S2mf	sem:F2 sem:A1.1.1 sem:S2
F2/B1	sem:F2 sem:B1
F2+++/B1	sem:F2p sem:B1
F2/B2-	sem:F2 sem:B2n
F2++/B2-	sem:F2p sem:B2n
F2+++/B2-/S2mf	sem:F2p sem:B2n sem:S2
F2/G2.1	sem:F2 sem:G2.1
F2/H1	sem:F2 sem:H1
F2/H1c	sem:F2 sem:H1
F2/H2	sem:F2 sem:H2
F2/H3	sem:F2 sem:H3
F2/I2.1	sem:F2 sem:I2.1
F2/I2.2c	sem:F2 sem:I2.2
F2/I3.2/S2.2m	sem:F2 sem:I3.2 sem:S2.2
F2/I3.2/S2mf	sem:F2 sem:I3.2 sem:S2
F2/L2	sem:F2 sem:L2
F2/M3/S2mf	sem:F2 sem:M3 sem:S2
F2/N5+	sem:F2 sem:N5p
F2/N5.2+	sem:F2 sem:N5.2p
F2/O1.1	sem:F2 sem:O1.1
F2/O2	sem:F2 sem:O2
F2/O3	sem:F2 sem:O3
F2/O4.5	sem:F2 sem:O4.5
F2/S1.1.3+	sem:F2 sem:S1.1.3p
F2/S2.2m	sem:F2 sem:S2.2
F2/S2mf	sem:F2 sem:S2
F2+++/S2mf	sem:F2p sem:S2
F2/S5+c	sem:F2 sem:S5p
F2/T1.3	sem:F2 sem:T1.3
F2/Z3c	sem:F2 sem:Z3
F3	sem:F3
F3-	sem:F3n
F3/A6.2+	sem:F3 sem:A6.2p
F3/B3	sem:F3 sem:B3
F3/E3-	sem:F3 sem:E3n
F3/G2.1	sem:F3 sem:G2.1
F3/G2.1-	sem:F3 sem:G2.1n
F3/G2.2-	sem:F3 sem:G2.2n
F3/H1	sem:F3 sem:H1
F3/I2	sem:F3 sem:I2
F3/N5.2+	sem:F3 sem:N5.2p
F3/N6+/S2mf	sem:F3 sem:N6p sem:S2
F3/O2	sem:F3 sem:O2
F3/S2mf	sem:F3 sem:S2
F3-/S2mf	sem:F3n sem:S2
F3/S6+	sem:F3 sem:S6p
F4	sem:F4
F4/A1.1.1	sem:F4 sem:A1.1.1
F4/A2.1+	sem:F4 sem:A2.1p
F4/F2	sem:F4 sem:F2
F4/H1	sem:F4 sem:H1
F4/H1c	sem:F4 sem:H1
F4/H3	sem:F4 sem:H3
F4/H3c	sem:F4 sem:H3
F4/I1.1	sem:F4 sem:I1.1
F4/I2.2	sem:F4 sem:I2.2
F4/I4	sem:F4 sem:I4
F4/K1	sem:F4 sem:K1
F4/L2	sem:F4 sem:L2
F4/L2/S2mf	sem:F4 sem:L2 sem:S2
F4/L3	sem:F4 sem:L3
F4/M3	sem:F4 sem:M3
F4/M4	sem:F4 sem:M4
F4/M4/S2.2m	sem:F4 sem:M4 sem:S2.2
F4/M7	sem:F4 sem:M7
F4/M7c	sem:F4 sem:M7
F4/N6+	sem:F4 sem:N6p
F4/O1	sem:F4 sem:O1
F4/O2	sem:F4 sem:O2
F4/S2	sem:F4 sem:S2
F4/S2.1f	sem:F4 sem:S2.1
F4/S2.2m	sem:F4 sem:S2.2
F4/S2mf	sem:F4 sem:S2
F4/S4	sem:F4 sem:S4
F4/S4c	sem:F4 sem:S4
F4/S5+	sem:F4 sem:S5p
F4/T1.3	sem:F4 sem:T1.3
F4/Y1	sem:F4 sem:Y1
G1.1	sem:G1.1
G1.1-	sem:G1.1n
G1.1.1/A1.8-	sem:G1.1 sem:A1.8n
G1.1/A2.1	sem:G1.1 sem:A2.1
G1.1-/A2.1	sem:G1.1n sem:A2.1
G1.1/A6.2+	sem:G1.1 sem:A6.2p
G1.1/A9+	sem:G1.1 sem:A9p
G1.1-c	sem:G1.1n
G1.1c	sem:G1.1
G1.1c/E2-	sem:G1.1 sem:E2n
G1.1c/T1.1.1	sem:G1.1 sem:T1.1.1
G1.1/G1.1-	sem:G1.1 sem:G1.1n
G1.1/G2.1	sem:G1.1 sem:G2.1
G1.1/G3	sem:G1.1 sem:G3
G1.1/H1	sem:G1.1 sem:H1
G1.1/H1c	sem:G1.1 sem:H1
G1.1/H4c	sem:G1.1 sem:H4
G1.1/H4/S2mf	sem:G1.1 sem:H4 sem:S2
G1.1/I1	sem:G1.1 sem:I1
G1.1/I1-	sem:G1.1 sem:I1
G1.1/I1.1	sem:G1.1 sem:I1.1
G1.1/I1.1c	sem:G1.1 sem:I1.1
G1.1/I1.1/S2mf	sem:G1.1 sem:I1.1 sem:S2
G1.1/I1.2	sem:G1.1 sem:I1.2
G1.1/I1.3	sem:G1.1 sem:I1.3
G1.1/I1c	sem:G1.1 sem:I1
G1.1/I1/Q2.1	sem:G1.1 sem:I1 sem:Q2.1
G1.1/I2.1	sem:G1.1 sem:I2.1
G1.1/M7	sem:G1.1 sem:M7
G1.1/N5.1-	sem:G1.1 sem:N5.1n
G1.1/O1.2c	sem:G1.1 sem:O1.2
G1.1/O2	sem:G1.1 sem:O2
G1.1/Q1.2	sem:G1.1 sem:Q1.2
G1.1/Q1.2/S2mf	sem:G1.1 sem:Q1.2 sem:S2
G1.1/Q2.2	sem:G1.1 sem:Q2.2
G1.1/S1.1.1	sem:G1.1 sem:S1.1.1
G1.1/S1.1.3+	sem:G1.1 sem:S1.1.3p
G1.1/S2	sem:G1.1 sem:S2
G1.1/S2.1f	sem:G1.1 sem:S2.1
G1.1/S2.2m	sem:G1.1 sem:S2.2
G1.1/S2m	sem:G1.1 sem:S2
G1.1/S2mf	sem:G1.1 sem:S2
G1.1/S2mn	sem:G1.1 sem:S2
G1.1/S5+	sem:G1.1 sem:S5p
G1.1-/S5+	sem:G1.1n sem:S5p
G1.1/S5+c	sem:G1.1 sem:S5p
G1.1/S7.1+	sem:G1.1 sem:S7.1p
G1.1/S7.1+/S2mf	sem:G1.1 sem:S7.1p sem:S2
G1.1/S7.1+/S5+	sem:G1.1 sem:S7.1p sem:S5p
G1.1/S7.4+	sem:G1.1 sem:S7.4p
G1.1/S7.4+/S2mf	sem:G1.1 sem:S7.4p sem:S2
G1.1/S8+	sem:G1.1 sem:S8p
G1.1/T3+/S2mf	sem:G1.1 sem:T3p sem:S2
G1.1/X2.1	sem:G1.1 sem:X2.1
G1.1/X4.2c	sem:G1.1 sem:X4.2
G1.1/X7	sem:G1.1 sem:X7
G1.1/Y2	sem:G1.1 sem:Y2
G1.2	sem:G1.2
G1.2-	sem:G1.2n
G1.2/A1.7-	sem:G1.2 sem:A1.7n
G1.2/A6.1-	sem:G1.2 sem:A6.1n
G1.2/A7-	sem:G1.2 sem:A7n
G1.2c	sem:G1.2
G1.2/E3+	sem:G1.2 sem:E3p
G1.2/G2.2-	sem:G1.2 sem:G2.2n
G1.2/H1c	sem:G1.2 sem:H1
G1.2/I2.1	sem:G1.2 sem:I2.1
G1.2/M7	sem:G1.2 sem:M7
G1.2/M7/S2mf	sem:G1.2 sem:M7 sem:S2
G1.2/Q1.1	sem:G1.2 sem:Q1.1
G1.2/Q1.2	sem:G1.2 sem:Q1.2
G1.2/Q2.2	sem:G1.2 sem:Q2.2
G1.2/S2.2m	sem:G1.2 sem:S2.2
G1.2/S2mf	sem:G1.2 sem:S2
G1.2/S5+	sem:G1.2 sem:S5p
G1.2/S5-	sem:G1.2 sem:S5n
G1.2/S5+c	sem:G1.2 sem:S5p
G1.2/S5-/S2mf	sem:G1.2 sem:S5n sem:S2
G1.2/S7.1+	sem:G1.2 sem:S7.1p
G1.2/S9/E2-	sem:G1.2 sem:S9 sem:E2n
G1.2/T1.3	sem:G1.2 sem:T1.3
G1.2/W3	sem:G1.2 sem:W3
G1.2/X2.1	sem:G1.2 sem:X2.1
G1.2/X2.4	sem:G1.2 sem:X2.4
G1.2/X4.2	sem:G1.2 sem:X4.2
G1.2/X7+	sem:G1.2 sem:X7p
G1.2/X7-	sem:G1.2 sem:X7n
G1.2/X7/A2.1	sem:G1.2 sem:X7 sem:A2.1
G1.2/X7+/N6+	sem:G1.2 sem:X7p sem:N6p
G1.2/X7+/S2mf	sem:G1.2 sem:X7p sem:S2
G1.2/X7+/Z2	sem:G1.2 sem:X7p sem:Z2
G1.2/Z3	sem:G1.2 sem:Z3
G1.2/Z3c	sem:G1.2 sem:Z3
G2.1	sem:G2.1
G2.1+	sem:G2.1p
G2.1-	sem:G2.1n
G2.1-/A1.1.2	sem:G2.1n sem:A1.1.2
G2.1/A15+	sem:G2.1 sem:A15p
G2.1/A1.7+	sem:G2.1 sem:A1.7p
G2.1-/A1.9	sem:G2.1n sem:A1.9
G2.1+/A2.2	sem:G2.1p sem:A2.2
G2.1/A5.2-	sem:G2.1 sem:A5.2n
G2.1/A9+	sem:G2.1 sem:A9p
G2.1-/A9+	sem:G2.1n sem:A9p
G2.1/A9+/S4	sem:G2.1 sem:A9p sem:S4
G2.1/B1	sem:G2.1 sem:B1
G2.1-/B3	sem:G2.1n sem:B3
G2.1-c	sem:G2.1n
G2.1c	sem:G2.1
G2.1-/Df	sem:G2.1n
G2.1/E3-	sem:G2.1 sem:E3n
G2.1-/E3-	sem:G2.1n sem:E3n
G2.1/F2	sem:G2.1 sem:F2
G2.1/F3-	sem:G2.1 sem:F3n
G2.1-/G1.2	sem:G2.1n sem:G1.2
G2.1-/G1.2/S2mf	sem:G2.1n sem:G1.2 sem:S2
G2.1/G2.2	sem:G2.1 sem:G2.2
G2.1-/G3/S2mf	sem:G2.1n sem:G3 sem:S2
G2.1/H1	sem:G2.1 sem:H1
G2.1/H1c	sem:G2.1 sem:H1
G2.1/H2	sem:G2.1 sem:H2
G2.1/H4	sem:G2.1 sem:H4
G2.1/H5	sem:G2.1 sem:H5
G2.1/I1	sem:G2.1 sem:I1
G2.1/I1.3	sem:G2.1 sem:I1.3
G2.1/I2.1	sem:G2.1 sem:I2.1
G2.1-/I2.2	sem:G2.1n sem:I2.2
G2.1/I3.1/S2mf	sem:G2.1 sem:I3.1 sem:S2
G2.1/I3.2/S2.2m	sem:G2.1 sem:I3.2 sem:S2.2
G2.1/I3.2/S2mf	sem:G2.1 sem:I3.2 sem:S2
G2.1-/K5.1	sem:G2.1n sem:K5.1
G2.1/L1-	sem:G2.1 sem:L1n
G2.1/M1	sem:G2.1 sem:M1
G2.1/M2	sem:G2.1 sem:M2
G2.1/M3	sem:G2.1 sem:M3
G2.1-/M3	sem:G2.1n sem:M3
G2.1-/M4	sem:G2.1n sem:M4
G2.1/M7	sem:G2.1 sem:M7
G2.1/M7c	sem:G2.1 sem:M7
G2.1/M8	sem:G2.1 sem:M8
G2.1-/N5	sem:G2.1n sem:N5
G2.1/N6+	sem:G2.1 sem:N6p
G2.1-/N6+	sem:G2.1n sem:N6p
G2.1-/N6+/S2mf	sem:G2.1n sem:N6p sem:S2
G2.1/O2	sem:G2.1 sem:O2
G2.1-/O2	sem:G2.1n sem:O2
G2.1-/O4.6+	sem:G2.1n sem:O4.6p
G2.1-/O4.6+/S2mf	sem:G2.1n sem:O4.6p sem:S2
G2.1/P1	sem:G2.1 sem:P1
G2.1/P1%	sem:G2.1 sem:P1
G2.1/P1c	sem:G2.1 sem:P1
G2.1/P1mf	sem:G2.1 sem:P1
G2.1/Q1.1	sem:G2.1 sem:Q1.1
G2.1/Q1.2	sem:G2.1 sem:Q1.2
G2.1/Q2.2	sem:G2.1 sem:Q2.2
G2.1-/Q2.2	sem:G2.1n sem:Q2.2
G2.1/Q4.1	sem:G2.1 sem:Q4.1
G2.1/S1.1.1	sem:G2.1 sem:S1.1.1
G2.1/S2	sem:G2.1 sem:S2
G2.1/S2.1f	sem:G2.1 sem:S2.1
G2.1/S2.2m	sem:G2.1 sem:S2.2
G2.1-/S2.2m	sem:G2.1n sem:S2.2
G2.1/S2f	sem:G2.1 sem:S2
G2.1/S2mf	sem:G2.1 sem:S2
G2.1+/S2mf	sem:G2.1p sem:S2
G2.1-/S2mf	sem:G2.1n sem:S2
G2.1-/S3.2	sem:G2.1n sem:S3.2
G2.1-/S3.2/S2.2m	sem:G2.1n sem:S3.2 sem:S2.2
G2.1-/S4	sem:G2.1n sem:S4
G2.1/S4c	sem:G2.1 sem:S4
G2.1/S5	sem:G2.1 sem:S5
G2.1/S5+	sem:G2.1 sem:S5p
G2.1/S5+c	sem:G2.1 sem:S5p
G2.1/S7.1-	sem:G2.1 sem:S7.1n
G2.1/S7.4+	sem:G2.1 sem:S7.4p
G2.1/S9	sem:G2.1 sem:S9
G2.1/T1.1.1	sem:G2.1 sem:T1.1.1
G2.1/T1.1.1m	sem:G2.1 sem:T1.1.1
G2.1-/T1.1.1mf	sem:G2.1n sem:T1.1.1
G2.1/T1.3	sem:G2.1 sem:T1.3
G2.1/T2-	sem:G2.1 sem:T2n
G2.1/T2-/S2mf	sem:G2.1 sem:T2n sem:S2
G2.1/T3-c	sem:G2.1 sem:T3n
G2.1/X2.4	sem:G2.1 sem:X2.4
G2.1/X6	sem:G2.1 sem:X6
G2.1/X6/S2mf	sem:G2.1 sem:X6 sem:S2
G2.1-/Y1	sem:G2.1n sem:Y1
G2.1/Y2	sem:G2.1 sem:Y2
G2.1/Z6	sem:G2.1 sem:Z6
G2.2	sem:G2.2
G2.2+	sem:G2.2p
G2.2++	sem:G2.2p
G2.2-	sem:G2.2n
G2.2-/A11.1+	sem:G2.2n sem:A11.1p
G2.2-/A1.5.1	sem:G2.2n sem:A1.5.1
G2.2+/A2.1	sem:G2.2p sem:A2.1
G2.2-/A2.1	sem:G2.2n sem:A2.1
G2.2-/A5.2-	sem:G2.2n sem:A5.2n
G2.2c	sem:G2.2
G2.2/E2	sem:G2.2 sem:E2
G2.2+/E2	sem:G2.2p sem:E2
G2.2/F2	sem:G2.2 sem:F2
G2.2-/G3	sem:G2.2n sem:G3
G2.2+/G3/S2mf	sem:G2.2p sem:G3 sem:S2
G2.2-/G3/S2mf	sem:G2.2n sem:G3 sem:S2
G2.2-/I1	sem:G2.2n sem:I1
G2.2-/I1.1	sem:G2.2n sem:I1.1
G2.2-/I1.1/S2mf	sem:G2.2n sem:I1.1 sem:S2
G2.2-/I1.2	sem:G2.2n sem:I1.2
G2.2/I3.1	sem:G2.2 sem:I3.1
G2.2/L2	sem:G2.2 sem:L2
G2.2/L2/S2mf	sem:G2.2 sem:L2 sem:S2
G2.2/Q2.2	sem:G2.2 sem:Q2.2
G2.2-/Q2.2	sem:G2.2n sem:Q2.2
G2.2+/S1.2	sem:G2.2p sem:S1.2
G2.2-/S1.2	sem:G2.2n sem:S1.2
G2.2-/S2.1f	sem:G2.2n sem:S2.1
G2.2-/S2.2m	sem:G2.2n sem:S2.2
G2.2/S2mf	sem:G2.2 sem:S2
G2.2+/S2mf	sem:G2.2p sem:S2
G2.2-/S2mf	sem:G2.2n sem:S2
G2.2-/S3.2	sem:G2.2n sem:S3.2
G2.2-/S3.2/S2.1f	sem:G2.2n sem:S3.2 sem:S2.1
G2.2-/S4/E2++	sem:G2.2n sem:S4 sem:E2p
G2.2/S5-	sem:G2.2 sem:S5n
G2.2-/S9	sem:G2.2n sem:S9
G3	sem:G3
G3-	sem:G3n
G3@	sem:G3
G3/A10-/H1	sem:G3 sem:A10n sem:H1
G3/B2-	sem:G3 sem:B2n
G3/B3/S2mf	sem:G3 sem:B3 sem:S2
G3/B5	sem:G3 sem:B5
G3c	sem:G3
G3/G2.1	sem:G3 sem:G2.1
G3/G2.1-	sem:G3 sem:G2.1n
G3/G2.1-mf	sem:G3 sem:G2.1n
G3/H1	sem:G3 sem:H1
G3/H1c	sem:G3 sem:H1
G3/H2	sem:G3 sem:H2
G3/H4	sem:G3 sem:H4
G3/I2	sem:G3 sem:I2
G3/I2.2	sem:G3 sem:I2.2
G3/I3.2/S2mf	sem:G3 sem:I3.2 sem:S2
G3/I4	sem:G3 sem:I4
G3/I4/H1	sem:G3 sem:I4 sem:H1
G3/I4/S2mf	sem:G3 sem:I4 sem:S2
G3/K1	sem:G3 sem:K1
G3/K4	sem:G3 sem:K4
G3/K5.2	sem:G3 sem:K5.2
G3/L1	sem:G3 sem:L1
G3/M2	sem:G3 sem:M2
G3/M3fn	sem:G3 sem:M3
G3/M4	sem:G3 sem:M4
G3/M4c	sem:G3 sem:M4
G3/M4/S2mf	sem:G3 sem:M4 sem:S2
G3/M5	sem:G3 sem:M5
G3/M5/S2mf	sem:G3 sem:M5 sem:S2
G3/M7	sem:G3 sem:M7
G3/M7c	sem:G3 sem:M7
G3/N3.8+	sem:G3 sem:N3.8p
G3/O1.1	sem:G3 sem:O1.1
G3/O1.3	sem:G3 sem:O1.3
G3/O2	sem:G3 sem:O2
G3/O4.6+	sem:G3 sem:O4.6p
G3/P1	sem:G3 sem:P1
G3/P1/S2mf	sem:G3 sem:P1 sem:S2
G3/Q2.2	sem:G3 sem:Q2.2
G3/S2.2m	sem:G3 sem:S2.2
G3/S2m	sem:G3 sem:S2
G3/S2mf	sem:G3 sem:S2
G3-/S2mf	sem:G3n sem:S2
G3/S5	sem:G3 sem:S5
G3/S5+	sem:G3 sem:S5p
G3/S5+c	sem:G3 sem:S5p
G3/S7.1+	sem:G3 sem:S7.1p
G3/S7.1-	sem:G3 sem:S7.1n
G3/S7.1+/S2.2m	sem:G3 sem:S7.1p sem:S2.2
G3/S7.1-/S2.2m	sem:G3 sem:S7.1n sem:S2.2
G3/S7.1+/S2mf	sem:G3 sem:S7.1p sem:S2
G3/S7.3+	sem:G3 sem:S7.3p
G3/S7.4-	sem:G3 sem:S7.4n
G3/T1.1.1	sem:G3 sem:T1.1.1
G3/T1.3	sem:G3 sem:T1.3
G3/Y2	sem:G3 sem:Y2
G3/Z2	sem:G3 sem:Z2
H1	sem:H1
H1/A10+	sem:H1 sem:A10p
H1/A10-	sem:H1 sem:A10n
H1/A1.7+	sem:H1 sem:A1.7p
H1/B3c	sem:H1 sem:B3
H1/B4	sem:H1 sem:B4
H1c	sem:H1
H1/E3+c	sem:H1 sem:E3p
H1/F4	sem:H1 sem:F4
H1/G1.1	sem:H1 sem:G1.1
H1/G1.1c	sem:H1 sem:G1.1
H1/G2.1	sem:H1 sem:G2.1
H1/G3	sem:H1 sem:G3
H1/H4	sem:H1 sem:H4
H1/H4c	sem:H1 sem:H4
H1/I1	sem:H1 sem:I1
H1/I1.1	sem:H1 sem:I1.1
H1/I1.1-c	sem:H1 sem:I1.1n
H1/I2.1	sem:H1 sem:I2.1
H1/I2.1c	sem:H1 sem:I2.1
H1/I2.2	sem:H1 sem:I2.2
H1/I3.1	sem:H1 sem:I3.1
H1/I3.2/S2mf	sem:H1 sem:I3.2 sem:S2
H1/I4c	sem:H1 sem:I4
H1/K1	sem:H1 sem:K1
H1/L1-	sem:H1 sem:L1n
H1/L2	sem:H1 sem:L2
H1/L3	sem:H1 sem:L3
H1/M3	sem:H1 sem:M3
H1/M4	sem:H1 sem:M4
H1/M4fn	sem:H1 sem:M4
H1/M7	sem:H1 sem:M7
H1/N3.7	sem:H1 sem:N3.7
H1/N6+	sem:H1 sem:N6p
H1/O4.2+	sem:H1 sem:O4.2p
H1/P1	sem:H1 sem:P1
H1/P1c	sem:H1 sem:P1
H1/S1.1.1c	sem:H1 sem:S1.1.1
H1/S1.1.2+	sem:H1 sem:S1.1.2p
H1/S1.1.3+c	sem:H1 sem:S1.1.3p
H1/S1.2.3+	sem:H1 sem:S1.2.3p
H1/S2	sem:H1 sem:S2
H1/S2mf	sem:H1 sem:S2
H1/S4	sem:H1 sem:S4
H1/S4c	sem:H1 sem:S4
H1/S5+c	sem:H1 sem:S5p
H1/S7.1+	sem:H1 sem:S7.1p
H1/S7.4+	sem:H1 sem:S7.4p
H1/S8+	sem:H1 sem:S8p
H1/S8+c	sem:H1 sem:S8p
H1/S9	sem:H1 sem:S9
H1/T3+c	sem:H1 sem:T3p
H1/T3-c	sem:H1 sem:T3n
H1/X2.4	sem:H1 sem:X2.4
H1/Y1/B1	sem:H1 sem:Y1 sem:B1
H2	sem:H2
H2/A15-	sem:H2 sem:A15n
H2/A9+	sem:H2 sem:A9p
H2/B4	sem:H2 sem:B4
H2/B5	sem:H2 sem:B5
H2/F1	sem:H2 sem:F1
H2/H4	sem:H2 sem:H4
H2/I3.1	sem:H2 sem:I3.1
H2/K1	sem:H2 sem:K1
H2/K2	sem:H2 sem:K2
H2/M1	sem:H2 sem:M1
H2/M2	sem:H2 sem:M2
H2/M4	sem:H2 sem:M4
H2/O1	sem:H2 sem:O1
H2/O1.2	sem:H2 sem:O1.2
H2/O2	sem:H2 sem:O2
H2/P1	sem:H2 sem:P1
H2/Q2.2	sem:H2 sem:Q2.2
H2/S1.1.1	sem:H2 sem:S1.1.1
H2/S2.1f	sem:H2 sem:S2.1
H2/S2mf	sem:H2 sem:S2
H2/S5+	sem:H2 sem:S5p
H2/S5+c	sem:H2 sem:S5p
H2/S7.1+	sem:H2 sem:S7.1p
H2/S9	sem:H2 sem:S9
H3	sem:H3
H3/H1	sem:H3 sem:H1
H3/O4.2-	sem:H3 sem:O4.2n
H3/P1	sem:H3 sem:P1
H3/S2mf	sem:H3 sem:S2
H3/S9	sem:H3 sem:S9
H4	sem:H4
H4-	sem:H4n
H4/A1.1.1	sem:H4 sem:A1.1.1
H4/A2.1	sem:H4 sem:A2.1
H4/A2.1+	sem:H4 sem:A2.1p
H4/F1	sem:H4 sem:F1
H4/G1.1	sem:H4 sem:G1.1
H4/G2.1	sem:H4 sem:G2.1
H4/H1	sem:H4 sem:H1
H4/H1-	sem:H4 sem:H1
H4/H1c	sem:H4 sem:H1
H4/I1.1	sem:H4 sem:I1.1
H4/I2.1	sem:H4 sem:I2.1
H4/L2	sem:H4 sem:L2
H4/M7	sem:H4 sem:M7
H4/M7c	sem:H4 sem:M7
H4/N6+	sem:H4 sem:N6p
H4/P1	sem:H4 sem:P1
H4/Q1.2	sem:H4 sem:Q1.2
H4/S2.1f	sem:H4 sem:S2.1
H4-/S2c	sem:H4n sem:S2
H4/S2m	sem:H4 sem:S2
H4/S2mf	sem:H4 sem:S2
H4-/S2mf	sem:H4n sem:S2
H4/S5+c	sem:H4 sem:S5p
H4/S9	sem:H4 sem:S9
H4/T1.3	sem:H4 sem:T1.3
H4-/T3-/S2mf	sem:H4n sem:T3n sem:S2
H4/Y1	sem:H4 sem:Y1
H5	sem:H5
H5-	sem:H5n
H5/A2.1	sem:H5 sem:A2.1
H5/B3	sem:H5 sem:B3
H5/B4	sem:H5 sem:B4
H5/F1	sem:H5 sem:F1
H5/G2.1	sem:H5 sem:G2.1
H5/I2.2	sem:H5 sem:I2.2
H5/K1	sem:H5 sem:K1
H5/L3	sem:H5 sem:L3
H5/M3	sem:H5 sem:M3
H5/N5	sem:H5 sem:N5
H5/N5.1-	sem:H5 sem:N5.1n
H5/N6+	sem:H5 sem:N6p
H5/O2	sem:H5 sem:O2
H5/O4.6+	sem:H5 sem:O4.6p
H5/Q1.2	sem:H5 sem:Q1.2
H5/S2mf	sem:H5 sem:S2
H5/S7.1+	sem:H5 sem:S7.1p
H5/S9	sem:H5 sem:S9
I1	sem:I1
I1-	sem:I1
I1.1	sem:I1.1
I1.1+	sem:I1.1p
I1.1++	sem:I1.1p
I1.1+++	sem:I1.1p
I1.1-	sem:I1.1n
I1.1--	sem:I1.1n
I1.1---	sem:I1.1n
I1.1/A2.1+	sem:I1.1 sem:A2.1p
I1.1-/A2.1	sem:I1.1n sem:A2.1
I1.1/A2.2	sem:I1.1 sem:A2.2
I1.1/A9+	sem:I1.1 sem:A9p
I1.1/A9-	sem:I1.1 sem:A9n
I1.1+/A9+	sem:I1.1p sem:A9p
I1.1+/A9-	sem:I1.1p sem:A9n
I1.1/B2-	sem:I1.1 sem:B2n
I1.1/G1.1	sem:I1.1 sem:G1.1
I1.1/G1.1/N5.2+	sem:I1.1 sem:G1.1 sem:N5.2p
I1.1/G1.2	sem:I1.1 sem:G1.2
I1.1+/G2.1	sem:I1.1p sem:G2.1
I1.1/G2.2-	sem:I1.1 sem:G2.2n
I1.1/H4	sem:I1.1 sem:H4
I1.1/I2.1	sem:I1.1 sem:I2.1
I1.1/I2.1c	sem:I1.1 sem:I2.1
I1.1/I2.2	sem:I1.1 sem:I2.2
I1.1/I3.1	sem:I1.1 sem:I3.1
I1.1/I3.1-	sem:I1.1 sem:I3.1n
I1.1/I3.1/S2mf	sem:I1.1 sem:I3.1 sem:S2
I1.1/M1	sem:I1.1 sem:M1
I1.1+mfn	sem:I1.1p
I1.1/N5++	sem:I1.1 sem:N5p
I1.1/N5-	sem:I1.1 sem:N5n
I1.1/N5.2+	sem:I1.1 sem:N5.2p
I1.1/N6+	sem:I1.1 sem:N6p
I1.1/O2	sem:I1.1 sem:O2
I1.1/O2/Q1.1	sem:I1.1 sem:O2 sem:Q1.1
I1.1/P1	sem:I1.1 sem:P1
I1.1/S1.1.1	sem:I1.1 sem:S1.1.1
I1.1/S2.2m	sem:I1.1 sem:S2.2
I1.1/S2mf	sem:I1.1 sem:S2
I1.1+++/S2mf	sem:I1.1p sem:S2
I1.1++/S2mf	sem:I1.1p sem:S2
I1.1-/S2mf	sem:I1.1n sem:S2
I1.1/S4	sem:I1.1 sem:S4
I1.1/S8+c	sem:I1.1 sem:S8p
I1.1/T1.1.1mf	sem:I1.1 sem:T1.1.1
I1.1/T3+	sem:I1.1 sem:T3p
I1.1/T4+	sem:I1.1 sem:T4p
I1.1/X2.4	sem:I1.1 sem:X2.4
I1.2	sem:I1.2
I1.2+	sem:I1.2p
I1.2-	sem:I1.2n
I1.2/A1.1.1	sem:I1.2 sem:A1.1.1
I1.2/A1.3+	sem:I1.2 sem:A1.3p
I1.2/A15-	sem:I1.2 sem:A15n
I1.2/Df	sem:I1.2
I1.2/G1.1	sem:I1.2 sem:G1.1
I1.2/G2.1	sem:I1.2 sem:G2.1
I1.2/G2.1/H1	sem:I1.2 sem:G2.1 sem:H1
I1.2/H1	sem:I1.2 sem:H1
I1.2/H4	sem:I1.2 sem:H4
I1.2/I3.1	sem:I1.2 sem:I3.1
I1.2/L1	sem:I1.2 sem:L1
I1.2/M3	sem:I1.2 sem:M3
I1.2/M5	sem:I1.2 sem:M5
I1.2/N5+	sem:I1.2 sem:N5p
I1.2/N5.2+	sem:I1.2 sem:N5.2p
I1.2/Q1.2	sem:I1.2 sem:Q1.2
I1.2/S2mf	sem:I1.2 sem:S2
I1.2+/S2mf	sem:I1.2p sem:S2
I1.3	sem:I1.3
I1.3+	sem:I1.3p
I1.3+++	sem:I1.3p
I1.3-	sem:I1.3n
I1.3--	sem:I1.3n
I1.3---	sem:I1.3n
I1.3/A10-	sem:I1.3 sem:A10n
I1.3/A1.7+	sem:I1.3 sem:A1.7p
I1.3+/A2.1	sem:I1.3p sem:A2.1
I1.3+/A8	sem:I1.3p sem:A8
I1.3/A9-	sem:I1.3 sem:A9n
I1.3+/A9+	sem:I1.3p sem:A9p
I1.3/H1	sem:I1.3 sem:H1
I1.3/M3	sem:I1.3 sem:M3
I1.3/M5	sem:I1.3 sem:M5
I1.3/M7	sem:I1.3 sem:M7
I1.3/N5-	sem:I1.3 sem:N5n
I1.3/N5.2+	sem:I1.3 sem:N5.2p
I1.3+/N5.2+	sem:I1.3p sem:N5.2p
I1.3/N6	sem:I1.3 sem:N6
I1.3/O1.2	sem:I1.3 sem:O1.2
I1.3/S2mf	sem:I1.3 sem:S2
I1.3-/S2mf	sem:I1.3n sem:S2
I1.3/S5+	sem:I1.3 sem:S5p
I1.3/S7.1+	sem:I1.3 sem:S7.1p
I1.3/T1.1.2	sem:I1.3 sem:T1.1.2
I1.3-/X2.4	sem:I1.3n sem:X2.4
I1.3-/X2.4/S2mf	sem:I1.3n sem:X2.4 sem:S2
I1/A1.4	sem:I1 sem:A1.4
I1/A1.4/Q1.2	sem:I1 sem:A1.4 sem:Q1.2
I1/A15-	sem:I1 sem:A15n
I1/A2.1	sem:I1 sem:A2.1
I1/A5.4-	sem:I1 sem:A5.4n
I1/A9+	sem:I1 sem:A9p
I1/A9-	sem:I1 sem:A9n
I1/B2-	sem:I1 sem:B2n
I1c	sem:I1
I1/G1.1	sem:I1 sem:G1.1
I1/G2.2-	sem:I1 sem:G2.2n
I1/H1	sem:I1 sem:H1
I1/H1c	sem:I1 sem:H1
I1/H2	sem:I1 sem:H2
I1/I2.1	sem:I1 sem:I2.1
I1/I2.1c	sem:I1 sem:I2.1
I1/I2.2	sem:I1 sem:I2.2
I1/I3.1	sem:I1 sem:I3.1
I1/I3.1-	sem:I1 sem:I3.1n
I1/K1	sem:I1 sem:K1
I1/M3	sem:I1 sem:M3
I1/N5	sem:I1 sem:N5
I1/N5-	sem:I1 sem:N5n
I1/N5--	sem:I1 sem:N5n
I1/N5-/A2.1	sem:I1 sem:N5n sem:A2.1
I1/O2	sem:I1 sem:O2
I1/O3	sem:I1 sem:O3
I1/Q1.2	sem:I1 sem:Q1.2
I1/S2mf	sem:I1 sem:S2
I1/S8+	sem:I1 sem:S8p
I1/S9	sem:I1 sem:S9
I1/T1.3	sem:I1 sem:T1.3
I1/X7+	sem:I1 sem:X7p
I1/Y2	sem:I1 sem:Y2
I1/Z2	sem:I1 sem:Z2
I1/Z6	sem:I1 sem:Z6
I2.1	sem:I2.1
I2.1-	sem:I2.1n
I2.1/A10+	sem:I2.1 sem:A10p
I2.1/A1.4	sem:I2.1 sem:A1.4
I2.1c	sem:I2.1
I2.1/F1	sem:I2.1 sem:F1
I2.1/G2.1	sem:I2.1 sem:G2.1
I2.1/G2.1-	sem:I2.1 sem:G2.1n
I2.1/G2.2-	sem:I2.1 sem:G2.2n
I2.1/H1	sem:I2.1 sem:H1
I2.1/H1c	sem:I2.1 sem:H1
I2.1/H4	sem:I2.1 sem:H4
I2.1/I1	sem:I2.1 sem:I1
I2.1/I1.1	sem:I2.1 sem:I1.1
I2.1/I1.1-	sem:I2.1 sem:I1.1n
I2.1/I1.1c	sem:I2.1 sem:I1.1
I2.1/I1.2	sem:I2.1 sem:I1.2
I2.1/I1.3	sem:I2.1 sem:I1.3
I2.1/M1	sem:I2.1 sem:M1
I2.1/M3	sem:I2.1 sem:M3
I2.1/M7	sem:I2.1 sem:M7
I2.1/N3.2+c	sem:I2.1 sem:N3.2p
I2.1/N5+	sem:I2.1 sem:N5p
I2.1/N5++	sem:I2.1 sem:N5p
I2.1/N5-	sem:I2.1 sem:N5n
I2.1/P1	sem:I2.1 sem:P1
I2.1/Q1.2	sem:I2.1 sem:Q1.2
I2.1/Q2.1/S8+	sem:I2.1 sem:Q2.1 sem:S8p
I2.1/Q2.2	sem:I2.1 sem:Q2.2
I2.1/Q3	sem:I2.1 sem:Q3
I2.1/S1.1.1	sem:I2.1 sem:S1.1.1
I2.1/S1.1.3+c	sem:I2.1 sem:S1.1.3p
I2.1/S2	sem:I2.1 sem:S2
I2.1/S2.2m	sem:I2.1 sem:S2.2
I2.1/S2m	sem:I2.1 sem:S2
I2.1/S2mf	sem:I2.1 sem:S2
I2.1/S4	sem:I2.1 sem:S4
I2.1/S5	sem:I2.1 sem:S5
I2.1/S5+	sem:I2.1 sem:S5p
I2.1/S5+c	sem:I2.1 sem:S5p
I2.1/S5c	sem:I2.1 sem:S5
I2.1/S7.3	sem:I2.1 sem:S7.3
I2.1/S8+	sem:I2.1 sem:S8p
I2.1/S8+/S2mf	sem:I2.1 sem:S8p sem:S2
I2.1/T1.2	sem:I2.1 sem:T1.2
I2.1/X2.4	sem:I2.1 sem:X2.4
I2.1/X7+	sem:I2.1 sem:X7p
I2.1/Y2	sem:I2.1 sem:Y2
I2.2	sem:I2.2
I2.2/A5.1+	sem:I2.2 sem:A5.1p
I2.2/A6.3+	sem:I2.2 sem:A6.3p
I2.2/A9+	sem:I2.2 sem:A9p
I2.2/A9-	sem:I2.2 sem:A9n
I2.2/B5c	sem:I2.2 sem:B5
I2.2/B5/H1	sem:I2.2 sem:B5 sem:H1
I2.2/B5/S2mf	sem:I2.2 sem:B5 sem:S2
I2.2c	sem:I2.2
I2.2/Df	sem:I2.2
I2.2/F2/S2mf	sem:I2.2 sem:F2 sem:S2
I2.2/G2.2-	sem:I2.2 sem:G2.2n
I2.2/H1	sem:I2.2 sem:H1
I2.2/H1c	sem:I2.2 sem:H1
I2.2/H2	sem:I2.2 sem:H2
I2.2/H4	sem:I2.2 sem:H4
I2.2/H5	sem:I2.2 sem:H5
I2.2/I1.1+	sem:I2.2 sem:I1.1p
I2.2/I1.3	sem:I2.2 sem:I1.3
I2.2/I1.3/S2mf	sem:I2.2 sem:I1.3 sem:S2
I2.2/K3c	sem:I2.2 sem:K3
I2.2/K6	sem:I2.2 sem:K6
I2.2/L2c	sem:I2.2 sem:L2
I2.2/M2	sem:I2.2 sem:M2
I2.2/M3	sem:I2.2 sem:M3
I2.2/M4	sem:I2.2 sem:M4
I2.2/M7	sem:I2.2 sem:M7
I2.2mf/N6+	sem:I2.2 sem:N6p
I2.2/N4	sem:I2.2 sem:N4
I2.2/N5	sem:I2.2 sem:N5
I2.2/N5.2+	sem:I2.2 sem:N5.2p
I2.2/N6+	sem:I2.2 sem:N6p
I2.2/O2	sem:I2.2 sem:O2
I2.2/O3	sem:I2.2 sem:O3
I2.2/O4.2-c	sem:I2.2 sem:O4.2n
I2.2/Q1.2	sem:I2.2 sem:Q1.2
I2.2/Q1.3	sem:I2.2 sem:Q1.3
I2.2/Q1.3/S2mf	sem:I2.2 sem:Q1.3 sem:S2
I2.2/Q2.1	sem:I2.2 sem:Q2.1
I2.2/Q2.1/Q4	sem:I2.2 sem:Q2.1 sem:Q4
I2.2/Q2.1/S2mf	sem:I2.2 sem:Q2.1 sem:S2
I2.2/Q2.1/Y2	sem:I2.2 sem:Q2.1 sem:Y2
I2.2/Q2.2	sem:I2.2 sem:Q2.2
I2.2/Q2.2c	sem:I2.2 sem:Q2.2
I2.2/Q2.2/S2.2m	sem:I2.2 sem:Q2.2 sem:S2.2
I2.2/Q4.1c	sem:I2.2 sem:Q4.1
I2.2/S1.1.1	sem:I2.2 sem:S1.1.1
I2.2/S2	sem:I2.2 sem:S2
I2.2/S2.1	sem:I2.2 sem:S2.1
I2.2/S2.1f	sem:I2.2 sem:S2.1
I2.2/S2.2m	sem:I2.2 sem:S2.2
I2.2/S2.2mf	sem:I2.2 sem:S2.2
I2.2/S2c	sem:I2.2 sem:S2
I2.2/S2mf	sem:I2.2 sem:S2
I2.2/S2mfc	sem:I2.2 sem:S2
I2.2/S5	sem:I2.2 sem:S5
I2.2/S5+	sem:I2.2 sem:S5p
I2.2/S5-	sem:I2.2 sem:S5n
I2.2/S5+c	sem:I2.2 sem:S5p
I2.2/S5c	sem:I2.2 sem:S5
I2.2/S7.1+	sem:I2.2 sem:S7.1p
I2.2/S7.3+	sem:I2.2 sem:S7.3p
I2.2/S8+	sem:I2.2 sem:S8p
I2.2/T1.3	sem:I2.2 sem:T1.3
I2.2/T3+c	sem:I2.2 sem:T3p
I2.2/X2.2+c	sem:I2.2 sem:X2.2p
I2.2/X2.4-	sem:I2.2 sem:X2.4n
I2.2/X4.1	sem:I2.2 sem:X4.1
I2.2/X5.2+mf	sem:I2.2 sem:X5.2p
I2.2/X9.2+	sem:I2.2 sem:X9.2p
I2.2/Y2	sem:I2.2 sem:Y2
I2.2/Y2/S2mf	sem:I2.2 sem:Y2 sem:S2
I2.2/Y2/S5+	sem:I2.2 sem:Y2 sem:S5p
I2.2/Z6	sem:I2.2 sem:Z6
I3.1	sem:I3.1
I3.1-	sem:I3.1n
I3.1/A1.1.1	sem:I3.1 sem:A1.1.1
I3.1/A2.1+	sem:I3.1 sem:A2.1p
I3.1/A4.2-mfn	sem:I3.1 sem:A4.2n
I3.1/A5.1-	sem:I3.1 sem:A5.1n
I3.1/A9+	sem:I3.1 sem:A9p
I3.1/B4/S2.1f	sem:I3.1 sem:B4 sem:S2.1
I3.1/E4.2+	sem:I3.1 sem:E4.2p
I3.1/F1/S2.1f	sem:I3.1 sem:F1 sem:S2.1
I3.1/F1/S2.2m	sem:I3.1 sem:F1 sem:S2.2
I3.1/F2/S2.1f	sem:I3.1 sem:F2 sem:S2.1
I3.1/F4/S2mf	sem:I3.1 sem:F4 sem:S2
I3.1/H1	sem:I3.1 sem:H1
I3.1/H1c	sem:I3.1 sem:H1
I3.1/H2	sem:I3.1 sem:H2
I3.1/I1-	sem:I3.1 sem:I1
I3.1-/I1	sem:I3.1n sem:I1
I3.1/I1.1-	sem:I3.1 sem:I1.1n
I3.1/I1.1-/S2mf	sem:I3.1 sem:I1.1n sem:S2
I3.1/I2.1	sem:I3.1 sem:I2.1
I3.1/I2.1c	sem:I3.1 sem:I2.1
I3.1/M7	sem:I3.1 sem:M7
I3.1-/N4	sem:I3.1n sem:N4
I3.1/N5+	sem:I3.1 sem:N5p
I3.1/N5-	sem:I3.1 sem:N5n
I3.1-/N5	sem:I3.1n sem:N5
I3.1/N5.2+	sem:I3.1 sem:N5.2p
I3.1/N5.2-	sem:I3.1 sem:N5.2
I3.1/N6+	sem:I3.1 sem:N6p
I3.1/N6-	sem:I3.1 sem:N6n
I3.1/P1	sem:I3.1 sem:P1
I3.1/P1m	sem:I3.1 sem:P1
I3.1/P1/S2mf	sem:I3.1 sem:P1 sem:S2
I3.1/Q1.2	sem:I3.1 sem:Q1.2
I3.1-/Q1.2	sem:I3.1n sem:Q1.2
I3.1/S1.1.2+	sem:I3.1 sem:S1.1.2p
I3.1/S2	sem:I3.1 sem:S2
I3.1/S2-	sem:I3.1 sem:S2n
I3.1/S2.2m	sem:I3.1 sem:S2.2
I3.1/S2c	sem:I3.1 sem:S2
I3.1/S2mf	sem:I3.1 sem:S2
I3.1-/S2mf	sem:I3.1n sem:S2
I3.1/S2mfc	sem:I3.1 sem:S2
I3.1/S4	sem:I3.1 sem:S4
I3.1-/S4	sem:I3.1n sem:S4
I3.1/S4/S2.1f	sem:I3.1 sem:S4 sem:S2.1
I3.1/S5	sem:I3.1 sem:S5
I3.1/S5+	sem:I3.1 sem:S5p
I3.1/S5-	sem:I3.1 sem:S5n
I3.1/S5+c	sem:I3.1 sem:S5p
I3.1/S5c	sem:I3.1 sem:S5
I3.1-/S6+	sem:I3.1n sem:S6p
I3.1/S8+	sem:I3.1 sem:S8p
I3.1/S8+/S2mf	sem:I3.1 sem:S8p sem:S2
I3.1/T1.1.1	sem:I3.1 sem:T1.1.1
I3.1/T1.3	sem:I3.1 sem:T1.3
I3.1/T1.3+	sem:I3.1 sem:T1.3p
I3.1/T1.3-	sem:I3.1 sem:T1.3n
I3.1/T1.3mf	sem:I3.1 sem:T1.3
I3.1/T2-	sem:I3.1 sem:T2n
I3.1/T2--	sem:I3.1 sem:T2n
I3.1/X2.6+	sem:I3.1 sem:X2.6p
I3.1/X5.2+++	sem:I3.1 sem:X5.2p
I3.1-/X5.2+	sem:I3.1n sem:X5.2p
I3.1/Z6	sem:I3.1 sem:Z6
I3.2	sem:I3.2
I3.2+	sem:I3.2p
I3.2-	sem:I3.2n
I3.2/G2.1-	sem:I3.2 sem:G2.1n
I3.2/H1/S2mf	sem:I3.2 sem:H1 sem:S2
I3.2/H2/S2.2m	sem:I3.2 sem:H2 sem:S2.2
I3.2/H2/S2mf	sem:I3.2 sem:H2 sem:S2
I3.2/H4/S2mf	sem:I3.2 sem:H4 sem:S2
I3.2/I1.1/S2mf	sem:I3.2 sem:I1.1 sem:S2
I3.2/M3/S2mf	sem:I3.2 sem:M3 sem:S2
I3.2+/N4	sem:I3.2p sem:N4
I3.2+/N5+	sem:I3.2p sem:N5p
I3.2/P1	sem:I3.2 sem:P1
I3.2/S2mf	sem:I3.2 sem:S2
I3.2+/S2mf	sem:I3.2p sem:S2
I3.2-/S2mf	sem:I3.2n sem:S2
I3.2/S8+/S2mf	sem:I3.2 sem:S8p sem:S2
I3.2/T1.1.1mf	sem:I3.2 sem:T1.1.1
I3.2+/X4.2	sem:I3.2p sem:X4.2
I4	sem:I4
I4/A4.1	sem:I4 sem:A4.1
I4c	sem:I4
I4/Df	sem:I4
I4/Dfc	sem:I4
I4/G2.1c	sem:I4 sem:G2.1
I4/H1	sem:I4 sem:H1
I4/H1c	sem:I4 sem:H1
I4/H2	sem:I4 sem:H2
I4/I2.1	sem:I4 sem:I2.1
I4/M3	sem:I4 sem:M3
I4/M4	sem:I4 sem:M4
I4/M7	sem:I4 sem:M7
I4/M7c	sem:I4 sem:M7
I4/N4	sem:I4 sem:N4
I4/N5+	sem:I4 sem:N5p
I4/S2mf	sem:I4 sem:S2
I4/S8+	sem:I4 sem:S8p
I4/T1.1.1mf	sem:I4 sem:T1.1.1
K1	sem:K1
K1/A1.4	sem:K1 sem:A1.4
K1/B2-	sem:K1 sem:B2n
K1c	sem:K1
K1/E4.1+/S2mf	sem:K1 sem:E4.1p sem:S2
K1/G1.1	sem:K1 sem:G1.1
K1/H1	sem:K1 sem:H1
K1/H1c	sem:K1 sem:H1
K1/H2	sem:K1 sem:H2
K1/H4	sem:K1 sem:H4
K1/I1.1	sem:K1 sem:I1.1
K1/I2.2	sem:K1 sem:I2.2
K1/L2	sem:K1 sem:L2
K1/L2/S2mf	sem:K1 sem:L2 sem:S2
K1/M1	sem:K1 sem:M1
K1/M1/S5+	sem:K1 sem:M1 sem:S5p
K1/M3	sem:K1 sem:M3
K1/M4	sem:K1 sem:M4
K1/M7	sem:K1 sem:M7
K1/M7c	sem:K1 sem:M7
K1/P1	sem:K1 sem:P1
K1/P1c	sem:K1 sem:P1
K1/Q4.1	sem:K1 sem:Q4.1
K1/Q4.2	sem:K1 sem:Q4.2
K1/S1.1.1	sem:K1 sem:S1.1.1
K1/S1.1.3+	sem:K1 sem:S1.1.3p
K1/S1.1.3+c	sem:K1 sem:S1.1.3p
K1/S2.1f	sem:K1 sem:S2.1
K1/S2.2m	sem:K1 sem:S2.2
K1/S2f	sem:K1 sem:S2
K1/S2mf	sem:K1 sem:S2
K1/S2mfc	sem:K1 sem:S2
K1/S3.2	sem:K1 sem:S3.2
K1/S4	sem:K1 sem:S4
K1/S5+	sem:K1 sem:S5p
K1/S5+c	sem:K1 sem:S5p
K1/T1.3	sem:K1 sem:T1.3
K1/T1.3/S2mf	sem:K1 sem:T1.3 sem:S2
K1/W3	sem:K1 sem:W3
K1/W4	sem:K1 sem:W4
K1/X9.2+	sem:K1 sem:X9.2p
K2	sem:K2
K2/A2.1	sem:K2 sem:A2.1
K2c	sem:K2
K2/G3c	sem:K2 sem:G3
K2/H1	sem:K2 sem:H1
K2/H2c	sem:K2 sem:H2
K2/K4	sem:K2 sem:K4
K2/N3.2-	sem:K2 sem:N3.2n
K2/N3.8-	sem:K2 sem:N3.8n
K2/O2	sem:K2 sem:O2
K2/O3	sem:K2 sem:O3
K2/P1	sem:K2 sem:P1
K2/Q4.1c	sem:K2 sem:Q4.1
K2/Q4.3	sem:K2 sem:Q4.3
K2/S1.1.3+	sem:K2 sem:S1.1.3p
K2/S1.1.3+c	sem:K2 sem:S1.1.3p
K2/S2.1f	sem:K2 sem:S2.1
K2/S2.2m	sem:K2 sem:S2.2
K2/S2m	sem:K2 sem:S2
K2/S2mf	sem:K2 sem:S2
K2/S3.2	sem:K2 sem:S3.2
K2/S3mf	sem:K2 sem:S3
K2/S5	sem:K2 sem:S5
K2/S5+	sem:K2 sem:S5p
K2/S5+c	sem:K2 sem:S5p
K2/S5c	sem:K2 sem:S5
K2/S5mf	sem:K2 sem:S5
K2/S7.3+c	sem:K2 sem:S7.3p
K2/S9	sem:K2 sem:S9
K2/T3+	sem:K2 sem:T3p
K3	sem:K3
K3/A5.1	sem:K3 sem:A5.1
K3/H1c	sem:K3 sem:H1
K3/M3	sem:K3 sem:M3
K3/N4	sem:K3 sem:N4
K3/N5+	sem:K3 sem:N5p
K3/N6+	sem:K3 sem:N6p
K3/O2	sem:K3 sem:O2
K3/O3	sem:K3 sem:O3
K3/Q1.2	sem:K3 sem:Q1.2
K3/S2mf	sem:K3 sem:S2
K3/Y2	sem:K3 sem:Y2
K4	sem:K4
K4/A5.3-	sem:K4 sem:A5.3n
K4/B5	sem:K4 sem:B5
K4c	sem:K4
K4/C1	sem:K4 sem:C1
K4/E5-	sem:K4 sem:E5n
K4/H1	sem:K4 sem:H1
K4/H2	sem:K4 sem:H2
K4/K2	sem:K4 sem:K2
K4/M7	sem:K4 sem:M7
K4/P1	sem:K4 sem:P1
K4/P1c	sem:K4 sem:P1
K4/Q2.2	sem:K4 sem:Q2.2
K4/Q2.2/S2mf	sem:K4 sem:Q2.2 sem:S2
K4/Q4.1	sem:K4 sem:Q4.1
K4/S2	sem:K4 sem:S2
K4/S2.1f	sem:K4 sem:S2.1
K4/S2.2m	sem:K4 sem:S2.2
K4/S2mf	sem:K4 sem:S2
K4/S5+	sem:K4 sem:S5p
K4/S5+c	sem:K4 sem:S5p
K4/S7.1+/S2mf	sem:K4 sem:S7.1p sem:S2
K4/T1.3	sem:K4 sem:T1.3
K4/T2-	sem:K4 sem:T2n
K4/X7+	sem:K4 sem:X7p
K5	sem:K5
K5.1	sem:K5.1
K5.1/A5.1++	sem:K5.1 sem:A5.1p
K5.1/A5.1+++mf	sem:K5.1 sem:A5.1p
K5.1/B5	sem:K5.1 sem:B5
K5.1c	sem:K5.1
K5.1/F1	sem:K5.1 sem:F1
K5.1/G2.2-	sem:K5.1 sem:G2.2n
K5.1/H1	sem:K5.1 sem:H1
K5.1/H1c	sem:K5.1 sem:H1
K5.1/H2	sem:K5.1 sem:H2
K5.1/H5	sem:K5.1 sem:H5
K5.1/I1	sem:K5.1 sem:I1
K5.1/I3.2/S2mf	sem:K5.1 sem:I3.2 sem:S2
K5.1/K1	sem:K5.1 sem:K1
K5.1/L2	sem:K5.1 sem:L2
K5.1/M3	sem:K5.1 sem:M3
K5.1/M4	sem:K5.1 sem:M4
K5.1/M5	sem:K5.1 sem:M5
K5.1/M7	sem:K5.1 sem:M7
K5.1/M7c	sem:K5.1 sem:M7
K5.1/N3.8	sem:K5.1 sem:N3.8
K5.1/N6+	sem:K5.1 sem:N6p
K5.1/O2	sem:K5.1 sem:O2
K5.1/P1	sem:K5.1 sem:P1
K5.1/P1c	sem:K5.1 sem:P1
K5.1/Q1.1	sem:K5.1 sem:Q1.1
K5.1/Q4.2	sem:K5.1 sem:Q4.2
K5.1/S2.1c	sem:K5.1 sem:S2.1
K5.1/S2.2m	sem:K5.1 sem:S2.2
K5.1/S2mf	sem:K5.1 sem:S2
K5.1/S5+	sem:K5.1 sem:S5p
K5.1/S5+c	sem:K5.1 sem:S5p
K5.1+/S5c	sem:K5.1 sem:S5
K5.1/S7.1+/S2	sem:K5.1 sem:S7.1p sem:S2
K5.1/S7.3+	sem:K5.1 sem:S7.3p
K5.1/S7.4-	sem:K5.1 sem:S7.4n
K5.1/T1.1.1	sem:K5.1 sem:T1.1.1
K5.1/X9.1+	sem:K5.1 sem:X9.1p
K5.1/X9.2+	sem:K5.1 sem:X9.2p
K5.2	sem:K5.2
K5.2c	sem:K5.2
K5.2/H1c	sem:K5.2 sem:H1
K5.2/H5	sem:K5.2 sem:H5
K5.2/I1/S2mf	sem:K5.2 sem:I1 sem:S2
K5.2/Q2.2	sem:K5.2 sem:Q2.2
K5.2/Q3	sem:K5.2 sem:Q3
K5.2/S2.2m	sem:K5.2 sem:S2.2
K5.2/S2mf	sem:K5.2 sem:S2
K5.2/S7.3+	sem:K5.2 sem:S7.3p
K5.2/T1.1.1	sem:K5.2 sem:T1.1.1
K5.2/X4.1	sem:K5.2 sem:X4.1
K5.2/Y2	sem:K5.2 sem:Y2
K5/O2/Q1.1	sem:K5 sem:O2 sem:Q1.1
K5/S7.3+	sem:K5 sem:S7.3p
K6	sem:K6
K6/G2.2-	sem:K6 sem:G2.2n
K6/H2	sem:K6 sem:H2
K6/H3	sem:K6 sem:H3
K6/M1	sem:K6 sem:M1
K6/M3	sem:K6 sem:M3
K6/M7	sem:K6 sem:M7
K6mfn	sem:K6
K6/S2mf	sem:K6 sem:S2
L1	sem:L1
L1+	sem:L1p
L1-	sem:L1n
L1-/A1.1.1	sem:L1n sem:A1.1.1
L1-/A1.1.2	sem:L1n sem:A1.1.2
L1/A12-	sem:L1 sem:A12n
L1+/A6.1+	sem:L1p sem:A6.1p
L1/A6.3+	sem:L1 sem:A6.3p
L1-/E3-	sem:L1n sem:E3n
L1-/F1/H1c	sem:L1n sem:F1 sem:H1
L1-/G2.1-	sem:L1n sem:G2.1n
L1-/G2.1-/S2.1f	sem:L1n sem:G2.1n sem:S2.1
L1-/G2.1-/S2mf	sem:L1n sem:G2.1n sem:S2
L1+/G3	sem:L1p sem:G3
L1-/H1	sem:L1n sem:H1
L1-/H1c	sem:L1n sem:H1
L1-/H2	sem:L1n sem:H2
L1-/H5	sem:L1n sem:H5
L1-/M3fn	sem:L1n sem:M3
L1-/M7	sem:L1n sem:M7
L1-/N5	sem:L1n sem:N5
L1-/O1.2	sem:L1n sem:O1.2
L1-/O2	sem:L1n sem:O2
L1-/Q1.2	sem:L1n sem:Q1.2
L1-/Q4.2	sem:L1n sem:Q4.2
L1-/S1.1.1	sem:L1n sem:S1.1.1
L1-/S2.2m	sem:L1n sem:S2.2
L1/S2mf	sem:L1 sem:S2
L1-/S2mf	sem:L1n sem:S2
L1-/S2mfc	sem:L1n sem:S2
L1-/S5+	sem:L1n sem:S5p
L1/S7.4+	sem:L1 sem:S7.4p
L1-/S9	sem:L1n sem:S9
L1/T1.2	sem:L1 sem:T1.2
L1/T1.3+	sem:L1 sem:T1.3p
L1+/T2+++	sem:L1p sem:T2p
L1/T3+	sem:L1 sem:T3p
L1-/X3.2	sem:L1n sem:X3.2
L2	sem:L2
L2/A10+	sem:L2 sem:A10p
L2/A1.1.1	sem:L2 sem:A1.1.1
L2/A4.1	sem:L2 sem:A4.1
L2/A6.3+	sem:L2 sem:A6.3p
L2/B1	sem:L2 sem:B1
L2/B2-	sem:L2 sem:B2n
L2/B3	sem:L2 sem:B3
L2-/B3	sem:L2n sem:B3
L2c	sem:L2
L2/E2+	sem:L2 sem:E2p
L2/E3-	sem:L2 sem:E3n
L2f	sem:L2
L2/F1	sem:L2 sem:F1
L2/F2	sem:L2 sem:F2
L2fn	sem:L2
L2/G2.1mfn	sem:L2 sem:G2.1
L2/H1	sem:L2 sem:H1
L2/H1c	sem:L2 sem:H1
L2/H4	sem:L2 sem:H4
L2/H4mfn	sem:L2 sem:H4
L2/H5	sem:L2 sem:H5
L2/K1	sem:L2 sem:K1
L2/K5.1mfn	sem:L2 sem:K5.1
L2/L1-	sem:L2 sem:L1n
L2m	sem:L2
L2/M1	sem:L2 sem:M1
L2/M5	sem:L2 sem:M5
L2/M7c	sem:L2 sem:M7
L2mf	sem:L2
L2mfn	sem:L2
L2mfnc	sem:L2
L2mf/T3-	sem:L2 sem:T3n
L2mn	sem:L2
L2/N5+	sem:L2 sem:N5p
L2/O2	sem:L2 sem:O2
L2/O4.3	sem:L2 sem:O4.3
L2/Q2.1	sem:L2 sem:Q2.1
L2/S2mf	sem:L2 sem:S2
L2/S5+c	sem:L2 sem:S5p
L2/S8+	sem:L2 sem:S8p
L2/S8+/H1	sem:L2 sem:S8p sem:H1
L2/S9mfn	sem:L2 sem:S9
L2/T3-	sem:L2 sem:T3n
L2/X3.2	sem:L2 sem:X3.2
L2/X3.2+	sem:L2 sem:X3.2p
L2/Z6	sem:L2 sem:Z6
L3	sem:L3
L3/A1.1.1	sem:L3 sem:A1.1.1
L3/B5	sem:L3 sem:B5
L3c	sem:L3
L3/F1	sem:L3 sem:F1
L3/F2	sem:L3 sem:F2
L3-/F4	sem:L3n sem:F4
L3/H2	sem:L3 sem:H2
L3/H3	sem:L3 sem:H3
L3/M7	sem:L3 sem:M7
L3/O2	sem:L3 sem:O2
L3/Q4.1	sem:L3 sem:Q4.1
L3/S2.1f	sem:L3 sem:S2.1
L3/S2mf	sem:L3 sem:S2
L3/S2mfn	sem:L3 sem:S2
M1	sem:M1
M1/A10-	sem:M1 sem:A10n
M1/A10-/S2mf	sem:M1 sem:A10n sem:S2
M1/A10-/S2mff	sem:M1 sem:A10n sem:S2
M1/A1.1.2	sem:M1 sem:A1.1.2
M1/A12-	sem:M1 sem:A12n
M1/A2.1	sem:M1 sem:A2.1
M1/B1	sem:M1 sem:B1
M1/E2-	sem:M1 sem:E2n
M1/E3-	sem:M1 sem:E3n
M1/E4.1+	sem:M1 sem:E4.1p
M1/E5-	sem:M1 sem:E5n
M1/F4	sem:M1 sem:F4
M1/G1.1c	sem:M1 sem:G1.1
M1/I1.1+	sem:M1 sem:I1.1p
M1/I1.3	sem:M1 sem:I1.3
M1/I2.1	sem:M1 sem:I2.1
M1/K1	sem:M1 sem:K1
M1/L2	sem:M1 sem:L2
M1/M3	sem:M1 sem:M3
M1/M4	sem:M1 sem:M4
M1/M5	sem:M1 sem:M5
M1/M6	sem:M1 sem:M6
M1/M7	sem:M1 sem:M7
M1/M7/E2-	sem:M1 sem:M7 sem:E2n
M1/M7/S2mf	sem:M1 sem:M7 sem:S2
M1/N3.3-	sem:M1 sem:N3.3n
M1/N3.8+	sem:M1 sem:N3.8p
M1/N3.8-	sem:M1 sem:N3.8n
M1/N3.8---	sem:M1 sem:N3.8n
M1/N3.8+/L2	sem:M1 sem:N3.8p sem:L2
M1/N3.8+/S2mf	sem:M1 sem:N3.8p sem:S2
M1/N4	sem:M1 sem:N4
M1/N5+	sem:M1 sem:N5p
M1/N5.1+	sem:M1 sem:N5.1p
M1/N6	sem:M1 sem:N6
M1/N6+	sem:M1 sem:N6p
M1/O1.2	sem:M1 sem:O1.2
M1/P1	sem:M1 sem:P1
M1/Q1.1	sem:M1 sem:Q1.1
M1/Q1.2	sem:M1 sem:Q1.2
M1/S1.1.2+	sem:M1 sem:S1.1.2p
M1/S1.2.3+	sem:M1 sem:S1.2.3p
M1/S2	sem:M1 sem:S2
M1/S2mf	sem:M1 sem:S2
M1/S5+	sem:M1 sem:S5p
M1/S7.1-	sem:M1 sem:S7.1n
M1/S8+c	sem:M1 sem:S8p
M1/S9	sem:M1 sem:S9
M1/T1.3	sem:M1 sem:T1.3
M1/T3-/S2mf	sem:M1 sem:T3n sem:S2
M1/W1	sem:M1 sem:W1
M1/X2.4	sem:M1 sem:X2.4
M1/X3.2	sem:M1 sem:X3.2
M1/X3.2-	sem:M1 sem:X3.2n
M1/X5.1-	sem:M1 sem:X5.1n
M1/X5.2+/S2mf	sem:M1 sem:X5.2p sem:S2
M1/X7-/S2mf	sem:M1 sem:X7n sem:S2
M1/X9.1+	sem:M1 sem:X9.1p
M2	sem:M2
M2/A1.7-	sem:M2 sem:A1.7n
M2/A6.1-	sem:M2 sem:A6.1n
M2/B1	sem:M2 sem:B1
M2/G1.1	sem:M2 sem:G1.1
M2/G1.2	sem:M2 sem:G1.2
M2/G1.2/S5	sem:M2 sem:G1.2 sem:S5
M2/G2.1-	sem:M2 sem:G2.1n
M2/I2.1	sem:M2 sem:I2.1
M2/I3.1	sem:M2 sem:I3.1
M2/M5	sem:M2 sem:M5
M2/M7	sem:M2 sem:M7
M2/N3.5+	sem:M2 sem:N3.5p
M2/N5.1-	sem:M2 sem:N5.1n
M2/N6+	sem:M2 sem:N6p
M2/O1	sem:M2 sem:O1
M2/S2mf	sem:M2 sem:S2
M2/X7-	sem:M2 sem:X7n
M2/Z6	sem:M2 sem:Z6
M3	sem:M3
M3/A10-	sem:M3 sem:A10n
M3/A1.1.2	sem:M3 sem:A1.1.2
M3/A1.1.2fn	sem:M3 sem:A1.1.2
M3/A1.4	sem:M3 sem:A1.4
M3/A4.1	sem:M3 sem:A4.1
M3/A5.1+	sem:M3 sem:A5.1p
M3/B2-	sem:M3 sem:B2n
M3/B3/S2mf	sem:M3 sem:B3 sem:S2
M3/B4	sem:M3 sem:B4
M3c	sem:M3
M3/F1	sem:M3 sem:F1
M3/F2	sem:M3 sem:F2
M3fn	sem:M3
M3/G2.1	sem:M3 sem:G2.1
M3/G2.1-	sem:M3 sem:G2.1n
M3/G2.1fn	sem:M3 sem:G2.1
M3/H1	sem:M3 sem:H1
M3/H1c	sem:M3 sem:H1
M3/H3	sem:M3 sem:H3
M3/H4	sem:M3 sem:H4
M3/I1.2	sem:M3 sem:I1.2
M3/I1/A15-	sem:M3 sem:I1 sem:A15n
M3/I2.1fn	sem:M3 sem:I2.1
M3/K1	sem:M3 sem:K1
M3/K5.1	sem:M3 sem:K5.1
M3/K5.1fn	sem:M3 sem:K5.1
M3/L2	sem:M3 sem:L2
M3/M1	sem:M3 sem:M1
M3/M4	sem:M3 sem:M4
M3/M6	sem:M3 sem:M6
M3/M7	sem:M3 sem:M7
M3/M7c	sem:M3 sem:M7
M3/N1	sem:M3 sem:N1
M3/N3.1	sem:M3 sem:N3.1
M3/N3.8	sem:M3 sem:N3.8
M3/N3.8+	sem:M3 sem:N3.8p
M3/N3.8-	sem:M3 sem:N3.8n
M3/N3.8+fn	sem:M3 sem:N3.8p
M3/N5+	sem:M3 sem:N5p
M3/N5fn	sem:M3 sem:N5
M3nf	sem:M3
M3/O1	sem:M3 sem:O1
M3/O1.3	sem:M3 sem:O1.3
M3/O2	sem:M3 sem:O2
M3/O3	sem:M3 sem:O3
M3/O3/A15+	sem:M3 sem:O3 sem:A15p
M3/P1	sem:M3 sem:P1
M3/P1c	sem:M3 sem:P1
M3/P1fn	sem:M3 sem:P1
M3/Q1.1	sem:M3 sem:Q1.1
M3/Q1.2	sem:M3 sem:Q1.2
M3/S1.1.3+	sem:M3 sem:S1.1.3p
M3/S2	sem:M3 sem:S2
M3/S2.2m	sem:M3 sem:S2.2
M3/S2mf	sem:M3 sem:S2
M3/S2mfn	sem:M3 sem:S2
M3/S4	sem:M3 sem:S4
M3/S7.1+	sem:M3 sem:S7.1p
M3/S8+	sem:M3 sem:S8p
M3/S8+/S2mf	sem:M3 sem:S8p sem:S2
M3/T1.2	sem:M3 sem:T1.2
M3/T3	sem:M3 sem:T3
M3/T3+fn	sem:M3 sem:T3p
M3/W4	sem:M3 sem:W4
M3/Z2	sem:M3 sem:Z2
M4	sem:M4
M4/A1.1.2	sem:M4 sem:A1.1.2
M4/A15+/I3.2/S2mf	sem:M4 sem:A15p sem:I3.2 sem:S2
M4/B2-	sem:M4 sem:B2n
M4/B5	sem:M4 sem:B5
M4c	sem:M4
M4/F1	sem:M4 sem:F1
M4/F4	sem:M4 sem:F4
M4fn	sem:M4
M4fnc	sem:M4
M4/G2.1-fn	sem:M4 sem:G2.1n
M4/G3	sem:M4 sem:G3
M4/G3fn	sem:M4 sem:G3
M4/H1	sem:M4 sem:H1
M4/H1c	sem:M4 sem:H1
M4/H2	sem:M4 sem:H2
M4/I2.1c	sem:M4 sem:I2.1
M4/I3.2/S2.2m	sem:M4 sem:I3.2 sem:S2.2
M4/I4	sem:M4 sem:I4
M4/K1	sem:M4 sem:K1
M4/K1/T1.3	sem:M4 sem:K1 sem:T1.3
M4/K5.1	sem:M4 sem:K5.1
M4/M7	sem:M4 sem:M7
M4/M7c	sem:M4 sem:M7
M4/M8	sem:M4 sem:M8
M4/O1.2fn	sem:M4 sem:O1.2
M4/O2	sem:M4 sem:O2
M4/S2.2m	sem:M4 sem:S2.2
M4/S2m	sem:M4 sem:S2
M4/S2mf	sem:M4 sem:S2
M4-/S2mf	sem:M4n sem:S2
M4/S5+c	sem:M4 sem:S5p
M4/S7.3+	sem:M4 sem:S7.3p
M4/S8+fn	sem:M4 sem:S8p
M4/X3.4/S2mf	sem:M4 sem:X3.4 sem:S2
M4/Y1	sem:M4 sem:Y1
M5	sem:M5
M5/A1.1.1	sem:M5 sem:A1.1.1
M5/A1.4	sem:M5 sem:A1.4
M5/B2-	sem:M5 sem:B2n
M5fn	sem:M5
M5fnc	sem:M5
M5/G3	sem:M5 sem:G3
M5/G3c	sem:M5 sem:G3
M5/G3fn	sem:M5 sem:G3
M5/H1	sem:M5 sem:H1
M5/I3.2/S2mf	sem:M5 sem:I3.2 sem:S2
M5/K1	sem:M5 sem:K1
M5/K6	sem:M5 sem:K6
M5/M7	sem:M5 sem:M7
M5/M7c	sem:M5 sem:M7
M5/N3.8+	sem:M5 sem:N3.8p
M5/P1	sem:M5 sem:P1
M5/Q1.2	sem:M5 sem:Q1.2
M5/S1.1.3+c	sem:M5 sem:S1.1.3p
M5/S2.1f	sem:M5 sem:S2.1
M5/S2.2m	sem:M5 sem:S2.2
M5/S2c	sem:M5 sem:S2
M5/S2mf	sem:M5 sem:S2
M5/S5+c	sem:M5 sem:S5p
M5/S5c	sem:M5 sem:S5
M5/S7.4+	sem:M5 sem:S7.4p
M5/W1	sem:M5 sem:W1
M5/W1fn	sem:M5 sem:W1
M5/X2.4+	sem:M5 sem:X2.4p
M6	sem:M6
M6/A1.7+	sem:M6 sem:A1.7p
M6/A2.1	sem:M6 sem:A2.1
M6/A2.1+	sem:M6 sem:A2.1p
M6/A5.3+	sem:M6 sem:A5.3p
M6/A5.3-	sem:M6 sem:A5.3n
M6/A6.1-	sem:M6 sem:A6.1n
M6/B1	sem:M6 sem:B1
M6/K4	sem:M6 sem:K4
M6/M4	sem:M6 sem:M4
M6/N5.1+	sem:M6 sem:N5.1p
M6/O2	sem:M6 sem:O2
M6/S2mf	sem:M6 sem:S2
M6/S4	sem:M6 sem:S4
M6/S7.1+/H1	sem:M6 sem:S7.1p sem:H1
M6/S7.4+	sem:M6 sem:S7.4p
M6/Z6	sem:M6 sem:Z6
M7	sem:M7
M7/A10-	sem:M7 sem:A10n
M7/A11.1+	sem:M7 sem:A11.1p
M7/A11.1-	sem:M7 sem:A11.1n
M7/A11.2+	sem:M7 sem:A11.2p
M7/A12-	sem:M7 sem:A12n
M7/A15+	sem:M7 sem:A15p
M7/A15-	sem:M7 sem:A15n
M7/A2.1+	sem:M7 sem:A2.1p
M7/A4.2+	sem:M7 sem:A4.2p
M7/A5.1-	sem:M7 sem:A5.1n
M7/B2-	sem:M7 sem:B2n
M7/B5	sem:M7 sem:B5
M7c	sem:M7
M7/F4	sem:M7 sem:F4
M7/G1.1	sem:M7 sem:G1.1
M7/G3	sem:M7 sem:G3
M7/G3/A15-	sem:M7 sem:G3 sem:A15n
M7/H3	sem:M7 sem:H3
M7/H4	sem:M7 sem:H4
M7/H4c	sem:M7 sem:H4
M7/I2.1c	sem:M7 sem:I2.1
M7/I4	sem:M7 sem:I4
M7/K1	sem:M7 sem:K1
M7/K5.1	sem:M7 sem:K5.1
M7/L1-	sem:M7 sem:L1n
M7/L2	sem:M7 sem:L2
M7/L3	sem:M7 sem:L3
M7/M1	sem:M7 sem:M1
M7/M3	sem:M7 sem:M3
M7/M4	sem:M7 sem:M4
M7/M5	sem:M7 sem:M5
M7/N3.3+	sem:M7 sem:N3.3p
M7/N3.3+++	sem:M7 sem:N3.3p
M7/N3.7+	sem:M7 sem:N3.7p
M7/N4	sem:M7 sem:N4
M7/N5++	sem:M7 sem:N5p
M7/N5-	sem:M7 sem:N5n
M7/N5.1+	sem:M7 sem:N5.1p
M7/O1.1c	sem:M7 sem:O1.1
M7/O1.2	sem:M7 sem:O1.2
M7/O1.2/W3	sem:M7 sem:O1.2 sem:W3
M7/O1.3	sem:M7 sem:O1.3
M7/O2/X7-	sem:M7 sem:O2 sem:X7n
M7/O4.2+	sem:M7 sem:O4.2p
M7/O4.2-	sem:M7 sem:O4.2n
M7/O4.2-c	sem:M7 sem:O4.2n
M7/P1	sem:M7 sem:P1
M7/S2.2m	sem:M7 sem:S2.2
M7/S2mf	sem:M7 sem:S2
M7/S4	sem:M7 sem:S4
M7/S5	sem:M7 sem:S5
M7/S5+	sem:M7 sem:S5p
M7/S5+c	sem:M7 sem:S5p
M7/S7.1	sem:M7 sem:S7.1
M7/S7.1+	sem:M7 sem:S7.1p
M7/S7.1-	sem:M7 sem:S7.1n
M7/S7.1+/S2mf	sem:M7 sem:S7.1p sem:S2
M7/T1.1.1	sem:M7 sem:T1.1.1
M7/W1	sem:M7 sem:W1
M7/W3	sem:M7 sem:W3
M7/W3c	sem:M7 sem:W3
M7/X5.2+/Z6	sem:M7 sem:X5.2p sem:Z6
M7/X7+	sem:M7 sem:X7p
M7/Y1	sem:M7 sem:Y1
M7/Y1c	sem:M7 sem:Y1
M7/Y2	sem:M7 sem:Y2
M8	sem:M8
M8/M5	sem:M8 sem:M5
M8/T2++	sem:M8 sem:T2p
M8/T2-	sem:M8 sem:T2n
M8/T2++/S2mf	sem:M8 sem:T2p sem:S2
N1	sem:N1
N1/A4.1	sem:N1 sem:A4.1
N1/G2.1	sem:N1 sem:G2.1
N1/I1	sem:N1 sem:I1
N1/M3	sem:N1 sem:M3
N1/N2	sem:N1 sem:N2
N1/N4	sem:N1 sem:N4
N1/N6+	sem:N1 sem:N6p
N1/O2	sem:N1 sem:O2
N1/Q4.1	sem:N1 sem:Q4.1
N1/S5	sem:N1 sem:S5
N2	sem:N2
N2/S2mf	sem:N2 sem:S2
N3	sem:N3
N3.1	sem:N3.1
N3.1c	sem:N3.1
N3.1/O2	sem:N3.1 sem:O2
N3.1/O3	sem:N3.1 sem:O3
N3.1/T3+	sem:N3.1 sem:T3p
N3.1/Y1	sem:N3.1 sem:Y1
N3.2	sem:N3.2
N3.2+	sem:N3.2p
N3.2++	sem:N3.2p
N3.2+++	sem:N3.2p
N3.2-	sem:N3.2n
N3.2--	sem:N3.2n
N3.2---	sem:N3.2n
N3.2/A2.1	sem:N3.2 sem:A2.1
N3.2/A2.1-	sem:N3.2 sem:A2.1n
N3.2+/A2.1	sem:N3.2p sem:A2.1
N3.2+/A2.1+	sem:N3.2p sem:A2.1p
N3.2-/A2.1	sem:N3.2n sem:A2.1
N3.2/A5.1+	sem:N3.2 sem:A5.1p
N3.2/A6.2+	sem:N3.2 sem:A6.2p
N3.2--/B1	sem:N3.2n sem:B1
N3.2+/M6	sem:N3.2p sem:M6
N3.2+/N3.6+	sem:N3.2p sem:N3.6p
N3.2/N5.2+	sem:N3.2 sem:N5.2p
N3.2+/O2	sem:N3.2p sem:O2
N3.2-/S2mf	sem:N3.2n sem:S2
N3.2+/S5	sem:N3.2p sem:S5
N3.3	sem:N3.3
N3.3+	sem:N3.3p
N3.3++	sem:N3.3p
N3.3+++	sem:N3.3p
N3.3-	sem:N3.3n
N3.3--	sem:N3.3n
N3.3---	sem:N3.3n
N3.3+/A2.1	sem:N3.3p sem:A2.1
N3.3+/E5+	sem:N3.3p sem:E5p
N3.3-/H3c	sem:N3.3n sem:H3
N3.3/O2	sem:N3.3 sem:O2
N3.3+/O2	sem:N3.3p sem:O2
N3.4	sem:N3.4
N3.4+	sem:N3.4p
N3.4-	sem:N3.4n
N3.5	sem:N3.5
N3.5+	sem:N3.5p
N3.5-	sem:N3.5n
N3.5--	sem:N3.5n
N3.5-/A2.1	sem:N3.5n sem:A2.1
N3.5-/A2.1/S2mf	sem:N3.5n sem:A2.1 sem:S2
N3.5/B1	sem:N3.5 sem:B1
N3.5/N5.2+	sem:N3.5 sem:N5.2p
N3.5/O2	sem:N3.5 sem:O2
N3.6	sem:N3.6
N3.6+	sem:N3.6p
N3.7	sem:N3.7
N3.7+	sem:N3.7p
N3.7++	sem:N3.7p
N3.7+++	sem:N3.7p
N3.7-	sem:N3.7n
N3.7--	sem:N3.7n
N3.7---	sem:N3.7n
N3.7+/A2.1	sem:N3.7p sem:A2.1
N3.7+/A2.1+	sem:N3.7p sem:A2.1p
N3.7-/A2.1	sem:N3.7n sem:A2.1
N3.7-/S2mf	sem:N3.7n sem:S2
N3.8	sem:N3.8
N3.8+	sem:N3.8p
N3.8++	sem:N3.8p
N3.8+++	sem:N3.8p
N3.8-	sem:N3.8n
N3.8+/A2.1	sem:N3.8p sem:A2.1
N3.8-/A2.1	sem:N3.8n sem:A2.1
N3.8+/N3.2+	sem:N3.8p sem:N3.2p
N3.8/O2	sem:N3.8 sem:O2
N3.8-/S2mf	sem:N3.8n sem:S2
N3/F1	sem:N3 sem:F1
N4	sem:N4
N4-	sem:N4n
N4/A1.1.1	sem:N4 sem:A1.1.1
N4/A2.2	sem:N4 sem:A2.2
N4c	sem:N4
N4/G1.1	sem:N4 sem:G1.1
N4/L1-	sem:N4 sem:L1n
N4/M7	sem:N4 sem:M7
N4/O4.6+	sem:N4 sem:O4.6p
N4/P1/S2mf	sem:N4 sem:P1 sem:S2
N4/P1/S5+	sem:N4 sem:P1 sem:S5p
N4/Q1.1	sem:N4 sem:Q1.1
N4/Q3	sem:N4 sem:Q3
N4/S2mf	sem:N4 sem:S2
N4/S7.3	sem:N4 sem:S7.3
N4/T1.1.1	sem:N4 sem:T1.1.1
N4/T1.3	sem:N4 sem:T1.3
N4/X3.4	sem:N4 sem:X3.4
N4/X9.2+	sem:N4 sem:X9.2p
N4/Z2/G1.1	sem:N4 sem:Z2 sem:G1.1
N5	sem:N5
N5+	sem:N5p
N5++	sem:N5p
N5+++	sem:N5p
N5-	sem:N5n
N5--	sem:N5n
N5---	sem:N5n
N5.1	sem:N5.1
N5.1+	sem:N5.1p
N5.1++	sem:N5.1p
N5.1+++	sem:N5.1p
N5.1-	sem:N5.1n
N5.1+/F1	sem:N5.1p sem:F1
N5.1-/I3.1	sem:N5.1n sem:I3.1
N5.1+/N5.2+	sem:N5.1p sem:N5.2p
N5.1-/Q2.2	sem:N5.1n sem:Q2.2
N5.1+/S2mf	sem:N5.1p sem:S2
N5.1+/S5+	sem:N5.1p sem:S5p
N5.1+/T1.1.2	sem:N5.1p sem:T1.1.2
N5.2+	sem:N5.2p
N5.2++	sem:N5.2p
N5.2+/A1.1.1	sem:N5.2p sem:A1.1.1
N5.2+/A1.5.1-	sem:N5.2p sem:A1.5.1n
N5.2+c	sem:N5.2p
N5.2+/F2	sem:N5.2p sem:F2
N5.2+/N5	sem:N5.2p sem:N5
N5.2+/O1.2	sem:N5.2p sem:O1.2
N5.2+/Q2.1	sem:N5.2p sem:Q2.1
N5.2+/Q2.2	sem:N5.2p sem:Q2.2
N5.2+/X7-	sem:N5.2p sem:X7n
N5/A1.7+	sem:N5 sem:A1.7p
N5/A2.1-	sem:N5 sem:A2.1n
N5+++/A2.1	sem:N5p sem:A2.1
N5++/A2.1	sem:N5p sem:A2.1
N5+/A2.1	sem:N5p sem:A2.1
N5-/A2.1	sem:N5n sem:A2.1
N5+/A2.1/B5	sem:N5p sem:A2.1 sem:B5
N5+/A2.1/T3	sem:N5p sem:A2.1 sem:T3
N5-/A2.2	sem:N5n sem:A2.2
N5+++c	sem:N5p
N5c	sem:N5
N5/I1.3	sem:N5 sem:I1.3
N5/I2.1	sem:N5 sem:I2.1
N5+/I2.2	sem:N5p sem:I2.2
N5---/M4/S2mf	sem:N5n sem:M4 sem:S2
N5+/M7	sem:N5p sem:M7
N5+/O2	sem:N5p sem:O2
N5+/P1	sem:N5p sem:P1
N5-/S1.2.5	sem:N5n sem:S1.2.5
N5+/S2	sem:N5p sem:S2
N5-/S2	sem:N5n sem:S2
N5-/S5+	sem:N5n sem:S5p
N5/X9.1+	sem:N5 sem:X9.1p
N6	sem:N6
N6+	sem:N6p
N6+++	sem:N6p
N6-	sem:N6n
N6---	sem:N6n
N6/A2.1	sem:N6 sem:A2.1
N6+/A2.1	sem:N6p sem:A2.1
N6+/I1.1	sem:N6p sem:I1.1
N6+/N3.2+/A2.1	sem:N6p sem:N3.2p sem:A2.1
N6/N5.1+	sem:N6 sem:N5.1p
N6+/Q2.2	sem:N6p sem:Q2.2
N6+/Q4.2	sem:N6p sem:Q4.2
N6+/S2mf	sem:N6p sem:S2
N6+/T1.3	sem:N6p sem:T1.3
N6+/X2.1	sem:N6p sem:X2.1
N6/Y2	sem:N6 sem:Y2
N6/Z6	sem:N6 sem:Z6
O1	sem:O1
O1.1	sem:O1.1
O1.1/A2.1	sem:O1.1 sem:A2.1
O1.1/C1	sem:O1.1 sem:C1
O1.1/I4	sem:O1.1 sem:I4
O1.1/I4c	sem:O1.1 sem:I4
O1.1/K5.1	sem:O1.1 sem:K5.1
O1.1/L2	sem:O1.1 sem:L2
O1.1/S2m	sem:O1.1 sem:S2
O1.1/S2mf	sem:O1.1 sem:S2
O1.1/W3	sem:O1.1 sem:W3
O1.2	sem:O1.2
O1.2-	sem:O1.2n
O1.2--	sem:O1.2n
O1.2-/A2.1	sem:O1.2n sem:A2.1
O1.2/B4	sem:O1.2 sem:B4
O1.2/F1	sem:O1.2 sem:F1
O1.2/G1.1	sem:O1.2 sem:G1.1
O1.2/G1.1c	sem:O1.2 sem:G1.1
O1.2/H1c	sem:O1.2 sem:H1
O1.2/M1	sem:O1.2 sem:M1
O1.2/M2	sem:O1.2 sem:M2
O1.2/M4	sem:O1.2 sem:M4
O1.2/N5	sem:O1.2 sem:N5
O1.2/O2	sem:O1.2 sem:O2
O1.2/O4.2-	sem:O1.2 sem:O4.2n
O1.2/O4.3	sem:O1.2 sem:O4.3
O1.2/W3	sem:O1.2 sem:W3
O1.2/W4	sem:O1.2 sem:W4
O1.2/X3.5	sem:O1.2 sem:X3.5
O1.3	sem:O1.3
O1.3-	sem:O1.3n
O1.3/A15-	sem:O1.3 sem:A15n
O1.3/G1.1c	sem:O1.3 sem:G1.1
O1.3/H1c	sem:O1.3 sem:H1
O1.3/M3	sem:O1.3 sem:M3
O1.3/M7	sem:O1.3 sem:M7
O1.3/N5	sem:O1.3 sem:N5
O1.3/O4.3	sem:O1.3 sem:O4.3
O1.3/S2.2m	sem:O1.3 sem:S2.2
O1.3/S2mf	sem:O1.3 sem:S2
O1/A1.1.2-	sem:O1 sem:A1.1.2n
O1/A2.2	sem:O1 sem:A2.2
O1/B1	sem:O1 sem:B1
O1/F1	sem:O1 sem:F1
O1/H1	sem:O1 sem:H1
O1/I4c	sem:O1 sem:I4
O1/L1	sem:O1 sem:L1
O1/M6	sem:O1 sem:M6
O1/N5	sem:O1 sem:N5
O1/P1	sem:O1 sem:P1
O1/S3.2	sem:O1 sem:S3.2
O1/W4	sem:O1 sem:W4
O1/W5	sem:O1 sem:W5
O1/X3.1	sem:O1 sem:X3.1
O1/Z6	sem:O1 sem:Z6
O2	sem:O2
O2/A10+	sem:O2 sem:A10p
O2/A10-	sem:O2 sem:A10n
O2/A1.1.2	sem:O2 sem:A1.1.2
O2/A1.3+	sem:O2 sem:A1.3p
O2/A1.7+	sem:O2 sem:A1.7p
O2/A1.7+/G2.1	sem:O2 sem:A1.7p sem:G2.1
O2/A1.8+	sem:O2 sem:A1.8p
O2/A5.4-	sem:O2 sem:A5.4n
O2/A6.1-	sem:O2 sem:A6.1n
O2/A9-	sem:O2 sem:A9n
O2/B3	sem:O2 sem:B3
O2/B4	sem:O2 sem:B4
O2/B5	sem:O2 sem:B5
O2c	sem:O2
O2/C1	sem:O2 sem:C1
O2/C1/I1.3+++	sem:O2 sem:C1 sem:I1.3p
O2/E2-	sem:O2 sem:E2n
O2/E3-	sem:O2 sem:E3n
O2/F1	sem:O2 sem:F1
O2/F2	sem:O2 sem:F2
O2/F4	sem:O2 sem:F4
O2/G2.1	sem:O2 sem:G2.1
O2/G3	sem:O2 sem:G3
O2/H1	sem:O2 sem:H1
O2/H2	sem:O2 sem:H2
O2/H4	sem:O2 sem:H4
O2/H5	sem:O2 sem:H5
O2/I1	sem:O2 sem:I1
O2/I1.3-	sem:O2 sem:I1.3n
O2/I2.2	sem:O2 sem:I2.2
O2/I4	sem:O2 sem:I4
O2/K5.1	sem:O2 sem:K5.1
O2/K5.2	sem:O2 sem:K5.2
O2/L1-	sem:O2 sem:L1n
O2/L2	sem:O2 sem:L2
O2/M1	sem:O2 sem:M1
O2/M2	sem:O2 sem:M2
O2/M3	sem:O2 sem:M3
O2/M4	sem:O2 sem:M4
O2/M6	sem:O2 sem:M6
O2/N3.2+	sem:O2 sem:N3.2p
O2/N3.4+	sem:O2 sem:N3.4p
O2/N3.5+	sem:O2 sem:N3.5p
O2/N3.7	sem:O2 sem:N3.7
O2/N4	sem:O2 sem:N4
O2/N5-	sem:O2 sem:N5n
O2/N5---	sem:O2 sem:N5n
O2/N6+	sem:O2 sem:N6p
O2/O1.1	sem:O2 sem:O1.1
O2/O1.3	sem:O2 sem:O1.3
O2/O3	sem:O2 sem:O3
O2/O4.3	sem:O2 sem:O4.3
O2/O4.4	sem:O2 sem:O4.4
O2/O4.5	sem:O2 sem:O4.5
O2/O4.6+	sem:O2 sem:O4.6p
O2/O4.6-	sem:O2 sem:O4.6n
O2/Q1.2	sem:O2 sem:Q1.2
O2/Q1.3	sem:O2 sem:Q1.3
O2/Q2.2-	sem:O2 sem:Q2.2n
O2/Q4.1	sem:O2 sem:Q4.1
O2/S2mf	sem:O2 sem:S2
O2/S4	sem:O2 sem:S4
O2/S5-	sem:O2 sem:S5n
O2/S6+	sem:O2 sem:S6p
O2/S7.1+	sem:O2 sem:S7.1p
O2/S9	sem:O2 sem:S9
O2/T1	sem:O2 sem:T1
O2/T1.3	sem:O2 sem:T1.3
O2/T3++	sem:O2 sem:T3p
O2/W2	sem:O2 sem:W2
O2/W2/M3	sem:O2 sem:W2 sem:M3
O2/X2.2+	sem:O2 sem:X2.2p
O2/X3.2	sem:O2 sem:X3.2
O2/X3.4	sem:O2 sem:X3.4
O2/X3.4-	sem:O2 sem:X3.4n
O2/Y1	sem:O2 sem:Y1
O3	sem:O3
O3/A15+	sem:O3 sem:A15p
O3/A15-	sem:O3 sem:A15n
O3/A2.1	sem:O3 sem:A2.1
O3/B2-	sem:O3 sem:B2n
O3/B3	sem:O3 sem:B3
O3/F1	sem:O3 sem:F1
O3/G1.1c	sem:O3 sem:G1.1
O3/H1c	sem:O3 sem:H1
O3/I4c	sem:O3 sem:I4
O3/M3	sem:O3 sem:M3
O3/M5	sem:O3 sem:M5
O3/N6+	sem:O3 sem:N6p
O3/O1.2	sem:O3 sem:O1.2
O3/O1.2-	sem:O3 sem:O1.2n
O3/O2	sem:O3 sem:O2
O3/O4.3	sem:O3 sem:O4.3
O3/Q1.1	sem:O3 sem:Q1.1
O3/S2mf	sem:O3 sem:S2
O3/W2	sem:O3 sem:W2
O3/X2.4	sem:O3 sem:X2.4
O3/X9.2-	sem:O3 sem:X9.2n
O4.1	sem:O4.1
O4.1/A2.1	sem:O4.1 sem:A2.1
O4.1/A3+	sem:O4.1 sem:A3p
O4.1/B1	sem:O4.1 sem:B1
O4.1/B1/S7.2+	sem:O4.1 sem:B1 sem:S7.2p
O4.1/F2	sem:O4.1 sem:F2
O4.1/H1	sem:O4.1 sem:H1
O4.1/L2	sem:O4.1 sem:L2
O4.1/L3/F1	sem:O4.1 sem:L3 sem:F1
O4.1/M3	sem:O4.1 sem:M3
O4.1/N3.5	sem:O4.1 sem:N3.5
O4.1/N4	sem:O4.1 sem:N4
O4.1/O1.2	sem:O4.1 sem:O1.2
O4.1/O1.2-	sem:O4.1 sem:O1.2n
O4.1/O1.3	sem:O4.1 sem:O1.3
O4.1/O2	sem:O4.1 sem:O2
O4.1/O3	sem:O4.1 sem:O3
O4.1/O4.5	sem:O4.1 sem:O4.5
O4.1/S1.2.5+	sem:O4.1 sem:S1.2.5p
O4.1/S2f	sem:O4.1 sem:S2
O4.1/S2mf	sem:O4.1 sem:S2
O4.1/W4	sem:O4.1 sem:W4
O4.2	sem:O4.2
O4.2+	sem:O4.2p
O4.2++	sem:O4.2p
O4.2+++	sem:O4.2p
O4.2-	sem:O4.2n
O4.2---	sem:O4.2n
O4.2+/A2.1	sem:O4.2p sem:A2.1
O4.2-/A2.1	sem:O4.2n sem:A2.1
O4.2+/A8	sem:O4.2p sem:A8
O4.2+/C1	sem:O4.2p sem:C1
O4.2-/G2.2-	sem:O4.2n sem:G2.2n
O4.2+/H5	sem:O4.2p sem:H5
O4.2+/M7	sem:O4.2p sem:M7
O4.2/Q1.2/S2mf	sem:O4.2 sem:Q1.2 sem:S2
O4.2/S2.1f	sem:O4.2 sem:S2.1
O4.2+/S2.1f	sem:O4.2p sem:S2.1
O4.2+/S2.1m	sem:O4.2p sem:S2.1
O4.2+/S2.2m	sem:O4.2p sem:S2.2
O4.2-/S2.2m	sem:O4.2n sem:S2.2
O4.2+/S2mf	sem:O4.2p sem:S2
O4.2-/S2mf	sem:O4.2n sem:S2
O4.2/S7.3+	sem:O4.2 sem:S7.3p
O4.2/T3-	sem:O4.2 sem:T3n
O4.2+/X2.1	sem:O4.2p sem:X2.1
O4.2+/X3.2	sem:O4.2p sem:X3.2
O4.2-/Z4	sem:O4.2n sem:Z4
O4.3	sem:O4.3
O4.3-	sem:O4.3
O4.3/A2.1	sem:O4.3 sem:A2.1
O4.3/A4.1	sem:O4.3 sem:A4.1
O4.3/B5	sem:O4.3 sem:B5
O4.3/F1	sem:O4.3 sem:F1
O4.3/H3	sem:O4.3 sem:H3
O4.3/N6	sem:O4.3 sem:N6
O4.3/O3	sem:O4.3 sem:O3
O4.3/O3/W2	sem:O4.3 sem:O3 sem:W2
O4.3/S2.1f	sem:O4.3 sem:S2.1
O4.3/S2mf	sem:O4.3 sem:S2
O4.4	sem:O4.4
O4.4/A2.1	sem:O4.4 sem:A2.1
O4.4/A2.1+	sem:O4.4 sem:A2.1p
O4.4/A6.2-	sem:O4.4 sem:A6.2n
O4.4/B1	sem:O4.4 sem:B1
O4.4/H1	sem:O4.4 sem:H1
O4.4/O2	sem:O4.4 sem:O2
O4.4/O4.1	sem:O4.4 sem:O4.1
O4.4/S2mf	sem:O4.4 sem:S2
O4.5	sem:O4.5
O4.5/A2.1	sem:O4.5 sem:A2.1
O4.5/O4.1	sem:O4.5 sem:O4.1
O4.5/O4.6+	sem:O4.5 sem:O4.6p
O4.6	sem:O4.6
O4.6+	sem:O4.6p
O4.6++	sem:O4.6p
O4.6+++	sem:O4.6p
O4.6-	sem:O4.6n
O4.6--	sem:O4.6n
O4.6---	sem:O4.6n
O4.6/A1.1.1	sem:O4.6 sem:A1.1.1
O4.6+/A1.1.2	sem:O4.6p sem:A1.1.2
O4.6+/A15-	sem:O4.6p sem:A15n
O4.6+/A2.1	sem:O4.6p sem:A2.1
O4.6-/A2.1	sem:O4.6n sem:A2.1
O4.6/B1	sem:O4.6 sem:B1
O4.6+/G1.1c	sem:O4.6p sem:G1.1
O4.6+/H1c	sem:O4.6p sem:H1
O4.6+/H2	sem:O4.6p sem:H2
O4.6/N6+	sem:O4.6 sem:N6p
O4.6+/N6+	sem:O4.6p sem:N6p
O4.6/O1.3	sem:O4.6 sem:O1.3
O4.6+/O2	sem:O4.6p sem:O2
O4.6-/O2	sem:O4.6n sem:O2
O4.6/O3	sem:O4.6 sem:O3
O4.6+/O3	sem:O4.6p sem:O3
O4.6-/O3	sem:O4.6n sem:O3
O4.6+/S2.2m	sem:O4.6p sem:S2.2
O4.6+/S2mf	sem:O4.6p sem:S2
O4.6-/W4	sem:O4.6n sem:W4
P1	sem:P1
P1-	sem:P1n
P1/A1.1.1	sem:P1 sem:A1.1.1
P1/A2.1+	sem:P1 sem:A2.1p
P1/A4.1	sem:P1 sem:A4.1
P1/A5	sem:P1 sem:A5
P1/A5.1+	sem:P1 sem:A5.1p
P1/A5.1-	sem:P1 sem:A5.1n
P1/B1/T3	sem:P1 sem:B1 sem:T3
P1/B2-c	sem:P1 sem:B2n
P1/B3	sem:P1 sem:B3
P1/B3c	sem:P1 sem:B3
P1/B5	sem:P1 sem:B5
P1c	sem:P1
P1/C1c	sem:P1 sem:C1
P1/Df	sem:P1
P1/F4	sem:P1 sem:F4
P1/G1.1c	sem:P1 sem:G1.1
P1/G1.2	sem:P1 sem:G1.2
P1/G2.1	sem:P1 sem:G2.1
P1/G2.1-	sem:P1 sem:G2.1n
P1/G3	sem:P1 sem:G3
P1/G3c	sem:P1 sem:G3
P1/H1	sem:P1 sem:H1
P1/H1c	sem:P1 sem:H1
P1/H2	sem:P1 sem:H2
P1/H4c	sem:P1 sem:H4
P1/I1.2	sem:P1 sem:I1.2
P1/I2.1	sem:P1 sem:I2.1
P1/I2.1c	sem:P1 sem:I2.1
P1/I3.1	sem:P1 sem:I3.1
P1/I3.2	sem:P1 sem:I3.2
P1/I3.2/S2.2m	sem:P1 sem:I3.2 sem:S2.2
P1/I3.2/S2mf	sem:P1 sem:I3.2 sem:S2
P1/K5.1	sem:P1 sem:K5.1
P1/L1	sem:P1 sem:L1
P1/L2	sem:P1 sem:L2
P1/M4c	sem:P1 sem:M4
P1/M7	sem:P1 sem:M7
P1mfn	sem:P1
P1/N4	sem:P1 sem:N4
P1/N5	sem:P1 sem:N5
P1/N5.2+	sem:P1 sem:N5.2p
P1/N6	sem:P1 sem:N6
P1/N6+	sem:P1 sem:N6p
P1/Q1.2	sem:P1 sem:Q1.2
P1/Q3	sem:P1 sem:Q3
P1/Q3c	sem:P1 sem:Q3
P1/S1.1.1	sem:P1 sem:S1.1.1
P1/S2.1	sem:P1 sem:S2.1
P1/S2.1f	sem:P1 sem:S2.1
P1/S2.2f	sem:P1 sem:S2.2
P1/S2.2m	sem:P1 sem:S2.2
P1/S2c	sem:P1 sem:S2
P1/S2m	sem:P1 sem:S2
P1/S2mf	sem:P1 sem:S2
P1/S2mf/T1.1.1	sem:P1 sem:S2 sem:T1.1.1
P1/S4	sem:P1 sem:S4
P1/S5+c	sem:P1 sem:S5p
P1/S7.1+/S2mf	sem:P1 sem:S7.1p sem:S2
P1/S7.1+/S5+	sem:P1 sem:S7.1p sem:S5p
P1/S8+	sem:P1 sem:S8p
P1/S9c	sem:P1 sem:S9
P1/T1.1.1	sem:P1 sem:T1.1.1
P1/T1.1.1mf	sem:P1 sem:T1.1.1
P1/T1.1.1/S2mf	sem:P1 sem:T1.1.1 sem:S2
P1/T1.3	sem:P1 sem:T1.3
P1/T1.3c	sem:P1 sem:T1.3
P1/T3-c	sem:P1 sem:T3n
P1/W1	sem:P1 sem:W1
P1/W1/S2mf	sem:P1 sem:W1 sem:S2
P1/W3	sem:P1 sem:W3
P1/X2.3+	sem:P1 sem:X2.3p
P1/X2.4	sem:P1 sem:X2.4
P1/X7+	sem:P1 sem:X7p
P1/Y1c	sem:P1 sem:Y1
P1/Y2	sem:P1 sem:Y2
P1/Z2c	sem:P1 sem:Z2
P1/Z3c	sem:P1 sem:Z3
P1/Z6	sem:P1 sem:Z6
Q1.1	sem:Q1.1
Q1.1/A15-	sem:Q1.1 sem:A15n
Q1.1/A1.6	sem:Q1.1 sem:A1.6
Q1.1/B1	sem:Q1.1 sem:B1
Q1.1/I2.2	sem:Q1.1 sem:I2.2
Q1.1/N6+	sem:Q1.1 sem:N6p
Q1.1/Q1.2	sem:Q1.1 sem:Q1.2
Q1.1/S2mf	sem:Q1.1 sem:S2
Q1.1/S8+	sem:Q1.1 sem:S8p
Q1.1/X5.1+	sem:Q1.1 sem:X5.1p
Q1.1/X9.1	sem:Q1.1 sem:X9.1
Q1.2	sem:Q1.2
Q1.2-	sem:Q1.2n
Q1.2/A10-	sem:Q1.2 sem:A10n
Q1.2/A1.1.1	sem:Q1.2 sem:A1.1.1
Q1.2/A4.2+	sem:Q1.2 sem:A4.2p
Q1.2/A5.2-	sem:Q1.2 sem:A5.2n
Q1.2/A5.3	sem:Q1.2 sem:A5.3
Q1.2/A5.3-	sem:Q1.2 sem:A5.3n
Q1.2/A5.4-	sem:Q1.2 sem:A5.4n
Q1.2/A9+	sem:Q1.2 sem:A9p
Q1.2/B2-	sem:Q1.2 sem:B2n
Q1.2c	sem:Q1.2
Q1.2/C1	sem:Q1.2 sem:C1
Q1.2/E2-	sem:Q1.2 sem:E2n
Q1.2/G1.1	sem:Q1.2 sem:G1.1
Q1.2/G1.2	sem:Q1.2 sem:G1.2
Q1.2/H2	sem:Q1.2 sem:H2
Q1.2/H3	sem:Q1.2 sem:H3
Q1.2/H5	sem:Q1.2 sem:H5
Q1.2/I1	sem:Q1.2 sem:I1
Q1.2/I1.1	sem:Q1.2 sem:I1.1
Q1.2/I1.3	sem:Q1.2 sem:I1.3
Q1.2/I2.1	sem:Q1.2 sem:I2.1
Q1.2/I3.1	sem:Q1.2 sem:I3.1
Q1.2/I3.1-	sem:Q1.2 sem:I3.1n
Q1.2/I3.1/S2.2m	sem:Q1.2 sem:I3.1 sem:S2.2
Q1.2/I3.2/S2.2m	sem:Q1.2 sem:I3.2 sem:S2.2
Q1.2/M1	sem:Q1.2 sem:M1
Q1.2/M3	sem:Q1.2 sem:M3
Q1.2/M4	sem:Q1.2 sem:M4
Q1.2/M6	sem:Q1.2 sem:M6
Q1.2/N1	sem:Q1.2 sem:N1
Q1.2/N2	sem:Q1.2 sem:N2
Q1.2/N3.2	sem:Q1.2 sem:N3.2
Q1.2/N4	sem:Q1.2 sem:N4
Q1.2/N5+	sem:Q1.2 sem:N5p
Q1.2/N6	sem:Q1.2 sem:N6
Q1.2/N6+	sem:Q1.2 sem:N6p
Q1.2/O2	sem:Q1.2 sem:O2
Q1.2/O3	sem:Q1.2 sem:O3
Q1.2/P1	sem:Q1.2 sem:P1
Q1.2/Q2.2	sem:Q1.2 sem:Q2.2
Q1.2/S1.1.2+	sem:Q1.2 sem:S1.1.2p
Q1.2/S2	sem:Q1.2 sem:S2
Q1.2/S2.2m	sem:Q1.2 sem:S2.2
Q1.2/S2mf	sem:Q1.2 sem:S2
Q1.2/S2mf/T1.1.1	sem:Q1.2 sem:S2 sem:T1.1.1
Q1.2/S3.1mf	sem:Q1.2 sem:S3.1
Q1.2/S4	sem:Q1.2 sem:S4
Q1.2/S5+	sem:Q1.2 sem:S5p
Q1.2/S9	sem:Q1.2 sem:S9
Q1.2/T1.1.1c	sem:Q1.2 sem:T1.1.1
Q1.2/T1.3	sem:Q1.2 sem:T1.3
Q1.2/T3	sem:Q1.2 sem:T3
Q1.2/W3	sem:Q1.2 sem:W3
Q1.2/X7+	sem:Q1.2 sem:X7p
Q1.2/X7-	sem:Q1.2 sem:X7n
Q1.2/Y2	sem:Q1.2 sem:Y2
Q1.2/Z6	sem:Q1.2 sem:Z6
Q1.3	sem:Q1.3
Q1.3/H1	sem:Q1.3 sem:H1
Q1.3/H1c	sem:Q1.3 sem:H1
Q1.3/H2c	sem:Q1.3 sem:H2
Q1.3/I1.3-	sem:Q1.3 sem:I1.3n
Q1.3/Q4.1	sem:Q1.3 sem:Q4.1
Q1.3/S1.1.3+c	sem:Q1.3 sem:S1.1.3p
Q1.3/S2mf	sem:Q1.3 sem:S2
Q1.3/S8+	sem:Q1.3 sem:S8p
Q1.3/Y2	sem:Q1.3 sem:Y2
Q2.1	sem:Q2.1
Q2.1+	sem:Q2.1p
Q2.1++	sem:Q2.1p
Q2.1-	sem:Q2.1n
Q2.1/A10-	sem:Q2.1 sem:A10n
Q2.1/A1.2-	sem:Q2.1 sem:A1.2n
Q2.1/A4.2+	sem:Q2.1 sem:A4.2p
Q2.1/A5	sem:Q2.1 sem:A5
Q2.1/A5.1-	sem:Q2.1 sem:A5.1n
Q2.1/A5.1-/S2mf	sem:Q2.1 sem:A5.1n sem:S2
Q2.1/A5.2-	sem:Q2.1 sem:A5.2n
Q2.1/A6.1-	sem:Q2.1 sem:A6.1n
Q2.1/B2-	sem:Q2.1 sem:B2n
Q2.1/E3-	sem:Q2.1 sem:E3n
Q2.1/N4	sem:Q2.1 sem:N4
Q2.1/N5+	sem:Q2.1 sem:N5p
Q2.1/N5-	sem:Q2.1 sem:N5n
Q2.1/N5.2+	sem:Q2.1 sem:N5.2p
Q2.1/N5+mf	sem:Q2.1 sem:N5p
Q2.1/N6	sem:Q2.1 sem:N6
Q2.1/N6+	sem:Q2.1 sem:N6p
Q2.1/O3	sem:Q2.1 sem:O3
Q2.1/P1	sem:Q2.1 sem:P1
Q2.1/S1.2.6-	sem:Q2.1 sem:S1.2.6n
Q2.1/S2mf	sem:Q2.1 sem:S2
Q2.1/S8+	sem:Q2.1 sem:S8p
Q2.1/T1.2	sem:Q2.1 sem:T1.2
Q2.1/T2+	sem:Q2.1 sem:T2p
Q2.1/T2++	sem:Q2.1 sem:T2p
Q2.1/X2.1	sem:Q2.1 sem:X2.1
Q2.1/X3.2-	sem:Q2.1 sem:X3.2n
Q2.1/X4.2	sem:Q2.1 sem:X4.2
Q2.1/Y2	sem:Q2.1 sem:Y2
Q2.2	sem:Q2.2
Q2.2-	sem:Q2.2n
Q2.2/A10+	sem:Q2.2 sem:A10p
Q2.2/A2.1-	sem:Q2.2 sem:A2.1n
Q2.2/A5.1+	sem:Q2.2 sem:A5.1p
Q2.2/A5.2	sem:Q2.2 sem:A5.2
Q2.2/A5.2+	sem:Q2.2 sem:A5.2p
Q2.2/A5.2-	sem:Q2.2 sem:A5.2n
Q2.2/A5.2-/S2mf	sem:Q2.2 sem:A5.2n sem:S2
Q2.2/A5.3-	sem:Q2.2 sem:A5.3n
Q2.2/A5.4-	sem:Q2.2 sem:A5.4n
Q2.2/A6.1-	sem:Q2.2 sem:A6.1n
Q2.2/A7+	sem:Q2.2 sem:A7p
Q2.2/B2-	sem:Q2.2 sem:B2n
Q2.2/E2+	sem:Q2.2 sem:E2p
Q2.2/E2-	sem:Q2.2 sem:E2n
Q2.2/E2-/X4.2	sem:Q2.2 sem:E2n sem:X4.2
Q2.2/E3-	sem:Q2.2 sem:E3n
Q2.2/E4.1+	sem:Q2.2 sem:E4.1p
Q2.2/E4.1-	sem:Q2.2 sem:E4.1n
Q2.2/E4.2-	sem:Q2.2 sem:E4.2n
Q2.2/E6-	sem:Q2.2 sem:E6n
Q2.2/G2.1	sem:Q2.2 sem:G2.1
Q2.2/G2.1-	sem:Q2.2 sem:G2.1n
Q2.2/G2.2	sem:Q2.2 sem:G2.2
Q2.2/G2.2-	sem:Q2.2 sem:G2.2n
Q2.2/I2.2	sem:Q2.2 sem:I2.2
Q2.2/I3.1	sem:Q2.2 sem:I3.1
Q2.2/I3.2	sem:Q2.2 sem:I3.2
Q2.2/M4	sem:Q2.2 sem:M4
Q2.2/N3.7-%	sem:Q2.2 sem:N3.7n
Q2.2/N4	sem:Q2.2 sem:N4
Q2.2/N5.2+	sem:Q2.2 sem:N5.2p
Q2.2/N6+	sem:Q2.2 sem:N6p
Q2.2/Q2.1	sem:Q2.2 sem:Q2.1
Q2.2/S1.2.4+	sem:Q2.2 sem:S1.2.4p
Q2.2/S1.2.4-	sem:Q2.2 sem:S1.2.4n
Q2.2/S2.1f	sem:Q2.2 sem:S2.1
Q2.2/S2.2m	sem:Q2.2 sem:S2.2
Q2.2/S2mf	sem:Q2.2 sem:S2
Q2.2/S2mfnc	sem:Q2.2 sem:S2
Q2.2/S4	sem:Q2.2 sem:S4
Q2.2/S4-	sem:Q2.2 sem:S4n
Q2.2/S6+	sem:Q2.2 sem:S6p
Q2.2/S7.2-/S9	sem:Q2.2 sem:S7.2n sem:S9
Q2.2/S7.2-/S9/S2mf	sem:Q2.2 sem:S7.2n sem:S9 sem:S2
Q2.2/S8+	sem:Q2.2 sem:S8p
Q2.2/S9	sem:Q2.2 sem:S9
Q2.2/T1.1.3	sem:Q2.2 sem:T1.1.3
Q2.2/T1.1.3/S9	sem:Q2.2 sem:T1.1.3 sem:S9
Q2.2/X2.5-	sem:Q2.2 sem:X2.5n
Q2.2/X3.2	sem:Q2.2 sem:X3.2
Q2.2/X3.2+	sem:Q2.2 sem:X3.2p
Q2.2/X3.2++	sem:Q2.2 sem:X3.2p
Q2.2/X3.2+++	sem:Q2.2 sem:X3.2p
Q2.2/X3.2-	sem:Q2.2 sem:X3.2n
Q2.2/X5.2+	sem:Q2.2 sem:X5.2p
Q2.2/X7+	sem:Q2.2 sem:X7p
Q2.2/X7-	sem:Q2.2 sem:X7n
Q2.2/X9.1+	sem:Q2.2 sem:X9.1p
Q2.2/Z6	sem:Q2.2 sem:Z6
Q3	sem:Q3
Q3/A10-	sem:Q3 sem:A10n
Q3/A12+	sem:Q3 sem:A12p
Q3/A2.1	sem:Q3 sem:A2.1
Q3/A6.1-	sem:Q3 sem:A6.1n
Q3/B1	sem:Q3 sem:B1
Q3/B2-	sem:Q3 sem:B2n
Q3/I3.2-	sem:Q3 sem:I3.2n
Q3/I3.2/S2mf	sem:Q3 sem:I3.2 sem:S2
Q3/K2	sem:Q3 sem:K2
Q3/M7	sem:Q3 sem:M7
Q3/N4-	sem:Q3 sem:N4n
Q3/P1	sem:Q3 sem:P1
Q3/Q1.2	sem:Q3 sem:Q1.2
Q3/S1.1.1	sem:Q3 sem:S1.1.1
Q3/S1.1.1/S2mf	sem:Q3 sem:S1.1.1 sem:S2
Q3/S1.2.4-	sem:Q3 sem:S1.2.4n
Q3/S2mf	sem:Q3 sem:S2
Q3/S8+	sem:Q3 sem:S8p
Q3/X4.1	sem:Q3 sem:X4.1
Q3/X9.1+	sem:Q3 sem:X9.1p
Q3/Y2	sem:Q3 sem:Y2
Q3/Z2/S3mf	sem:Q3 sem:Z2 sem:S3
Q4	sem:Q4
Q4.1	sem:Q4.1
Q4.1/A1.1.1	sem:Q4.1 sem:A1.1.1
Q4.1/Df	sem:Q4.1
Q4.1/F1	sem:Q4.1 sem:F1
Q4.1/H1c	sem:Q4.1 sem:H1
Q4.1/I2.1c	sem:Q4.1 sem:I2.1
Q4.1/I2.2	sem:Q4.1 sem:I2.2
Q4.1/I2.2/H1	sem:Q4.1 sem:I2.2 sem:H1
Q4.1/I2.2/S2mf	sem:Q4.1 sem:I2.2 sem:S2
Q4.1/M1	sem:Q4.1 sem:M1
Q4.1/M6	sem:Q4.1 sem:M6
Q4.1/M7	sem:Q4.1 sem:M7
Q4.1/N1	sem:Q4.1 sem:N1
Q4.1/N5	sem:Q4.1 sem:N5
Q4.1/P1	sem:Q4.1 sem:P1
Q4.1/Q1.2/I1	sem:Q4.1 sem:Q1.2 sem:I1
Q4.1/Q3	sem:Q4.1 sem:Q3
Q4.1/S1.1.3+	sem:Q4.1 sem:S1.1.3p
Q4.1/S2.1f	sem:Q4.1 sem:S2.1
Q4.1/S2.2m	sem:Q4.1 sem:S2.2
Q4.1/S2c	sem:Q4.1 sem:S2
Q4.1/S2f	sem:Q4.1 sem:S2
Q4.1/S2mf	sem:Q4.1 sem:S2
Q4.1/S3.2	sem:Q4.1 sem:S3.2
Q4.1/S8+	sem:Q4.1 sem:S8p
Q4.1/W3	sem:Q4.1 sem:W3
Q4.1/X2.4	sem:Q4.1 sem:X2.4
Q4.1/X5.2+++	sem:Q4.1 sem:X5.2p
Q4.1/X9.2++	sem:Q4.1 sem:X9.2p
Q4.1/Y2	sem:Q4.1 sem:Y2
Q4.2	sem:Q4.2
Q4.2c	sem:Q4.2
Q4.2/H2	sem:Q4.2 sem:H2
Q4.2/I2.1c	sem:Q4.2 sem:I2.1
Q4.2/I2.2	sem:Q4.2 sem:I2.2
Q4.2/I2.2/S2mf	sem:Q4.2 sem:I2.2 sem:S2
Q4.2/I3.2/S2mf	sem:Q4.2 sem:I3.2 sem:S2
Q4.2/N4	sem:Q4.2 sem:N4
Q4.2/Q2.1c	sem:Q4.2 sem:Q2.1
Q4.2/S1.1.3+c	sem:Q4.2 sem:S1.1.3p
Q4.2/S2.1	sem:Q4.2 sem:S2.1
Q4.2/S2.2m	sem:Q4.2 sem:S2.2
Q4.2/S2m	sem:Q4.2 sem:S2
Q4.2/S2mf	sem:Q4.2 sem:S2
Q4.2/S5+c	sem:Q4.2 sem:S5p
Q4.2/Y2	sem:Q4.2 sem:Y2
Q4.3	sem:Q4.3
Q4.3/A1.1.1	sem:Q4.3 sem:A1.1.1
Q4.3/A5.1+	sem:Q4.3 sem:A5.1p
Q4.3/B3	sem:Q4.3 sem:B3
Q4.3c	sem:Q4.3
Q4.3/E4.1+	sem:Q4.3 sem:E4.1p
Q4.3/E5-	sem:Q4.3 sem:E5n
Q4.3/G3	sem:Q4.3 sem:G3
Q4.3/H1	sem:Q4.3 sem:H1
Q4.3/H1c	sem:Q4.3 sem:H1
Q4.3/I3.2/S2.2m	sem:Q4.3 sem:I3.2 sem:S2.2
Q4.3/K4	sem:Q4.3 sem:K4
Q4.3/K5.1	sem:Q4.3 sem:K5.1
Q4.3/K5.2	sem:Q4.3 sem:K5.2
Q4.3/M1	sem:Q4.3 sem:M1
Q4.3/M3	sem:Q4.3 sem:M3
Q4.3mfc	sem:Q4.3
Q4.3/N4	sem:Q4.3 sem:N4
Q4.3/N6+	sem:Q4.3 sem:N6p
Q4.3/O3	sem:Q4.3 sem:O3
Q4.3/O4.3	sem:Q4.3 sem:O4.3
Q4.3/P1	sem:Q4.3 sem:P1
Q4.3/Q1.2	sem:Q4.3 sem:Q1.2
Q4.3/Q3	sem:Q4.3 sem:Q3
Q4.3/Q4.2	sem:Q4.3 sem:Q4.2
Q4.3/S2c	sem:Q4.3 sem:S2
Q4.3/S2mf	sem:Q4.3 sem:S2
Q4.3/S5+	sem:Q4.3 sem:S5p
Q4.3/S5+c	sem:Q4.3 sem:S5p
Q4.3/S5c	sem:Q4.3 sem:S5
Q4.3/T1.1.1	sem:Q4.3 sem:T1.1.1
Q4.3/T1.3	sem:Q4.3 sem:T1.3
Q4/A4.1	sem:Q4 sem:A4.1
Q4c	sem:Q4
Q4/I3.2/S2mf	sem:Q4 sem:I3.2 sem:S2
Q4/N5	sem:Q4 sem:N5
Q4/P1	sem:Q4 sem:P1
Q4/S2mf	sem:Q4 sem:S2
Q4/S3.2	sem:Q4 sem:S3.2
Q4/S5+	sem:Q4 sem:S5p
Q4/S7.4-	sem:Q4 sem:S7.4n
Q4/Y1	sem:Q4 sem:Y1
Q4/Y2	sem:Q4 sem:Y2
S1.1.1	sem:S1.1.1
S1.1.1-	sem:S1.1.1
S1.1.1/A11.1+	sem:S1.1.1 sem:A11.1p
S1.1.1c	sem:S1.1.1
S1.1.1/C1/A2.1+	sem:S1.1.1 sem:C1 sem:A2.1p
S1.1.1/G1.1	sem:S1.1.1 sem:G1.1
S1.1.1/H1c	sem:S1.1.1 sem:H1
S1.1.1/H4	sem:S1.1.1 sem:H4
S1.1.1/I2.1	sem:S1.1.1 sem:I2.1
S1.1.1/M1	sem:S1.1.1 sem:M1
S1.1.1/N6	sem:S1.1.1 sem:N6
S1.1.1/N6+	sem:S1.1.1 sem:N6p
S1.1.1/P1	sem:S1.1.1 sem:P1
S1.1.1/Q2.1	sem:S1.1.1 sem:Q2.1
S1.1.1/S2	sem:S1.1.1 sem:S2
S1.1.1/S2mf	sem:S1.1.1 sem:S2
S1.1.1/T3-	sem:S1.1.1 sem:T3n
S1.1.1/X2.1/G1.2	sem:S1.1.1 sem:X2.1 sem:G1.2
S1.1.1/Y1	sem:S1.1.1 sem:Y1
S1.1.2+	sem:S1.1.2p
S1.1.2-	sem:S1.1.2n
S1.1.2+/S9	sem:S1.1.2p sem:S9
S1.1.3	sem:S1.1.3
S1.1.3+	sem:S1.1.3p
S1.1.3+++	sem:S1.1.3p
S1.1.3-	sem:S1.1.3n
S1.1.3+/A10-	sem:S1.1.3p sem:A10n
S1.1.3+c	sem:S1.1.3p
S1.1.3+/F2	sem:S1.1.3p sem:F2
S1.1.3+/G3	sem:S1.1.3p sem:G3
S1.1.3+mfn	sem:S1.1.3p
S1.1.3/N5.2+	sem:S1.1.3 sem:N5.2p
S1.1.3-/P1	sem:S1.1.3n sem:P1
S1.1.3+/S2	sem:S1.1.3p sem:S2
S1.1.3+++/S2mf	sem:S1.1.3p sem:S2
S1.1.3+/S2mf	sem:S1.1.3p sem:S2
S1.1.3-/S2mf	sem:S1.1.3n sem:S2
S1.1.3/S4	sem:S1.1.3 sem:S4
S1.1.3+/S5+	sem:S1.1.3p sem:S5p
S1.1.3+/W3	sem:S1.1.3p sem:W3
S1.1.3+++/X7-	sem:S1.1.3p sem:X7n
S1.1.4	sem:S1.1.4
S1.1.4+	sem:S1.1.4p
S1.1.4-	sem:S1.1.4n
S1.2	sem:S1.2
S1.2.1	sem:S1.2.1
S1.2.1+	sem:S1.2.1p
S1.2.1+++	sem:S1.2.1p
S1.2.1-	sem:S1.2.1n
S1.2.1+/E3+	sem:S1.2.1p sem:E3p
S1.2.1+/S2mf	sem:S1.2.1p sem:S2
S1.2.1-/S2mfc	sem:S1.2.1n sem:S2
S1.2.2+	sem:S1.2.2p
S1.2.2++	sem:S1.2.2p
S1.2.2-	sem:S1.2.2n
S1.2.2+/S2mf	sem:S1.2.2p sem:S2
S1.2.2-/S2mf	sem:S1.2.2n sem:S2
S.1.2.3-	sem:S1.2.3
S1.2.3+	sem:S1.2.3p
S1.2.3+++	sem:S1.2.3p
S1.2.3-	sem:S1.2.3n
S1.2.3-/A2.2	sem:S1.2.3n sem:A2.2
S1.2.3+/Q2.2	sem:S1.2.3p sem:Q2.2
S1.2.3+/S2mf	sem:S1.2.3p sem:S2
S1.2.3-/S2mf	sem:S1.2.3n sem:S2
S1.2.4	sem:S1.2.4
S1.2.4+	sem:S1.2.4p
S1.2.4-	sem:S1.2.4n
S1.2.4-/B1	sem:S1.2.4n sem:B1
S1.2.4-/Q2.2	sem:S1.2.4n sem:Q2.2
S1.2.4-/Q3	sem:S1.2.4n sem:Q3
S1.2.4-/S2mf	sem:S1.2.4n sem:S2
S1.2.5+	sem:S1.2.5p
S1.2.5++	sem:S1.2.5p
S1.2.5+++	sem:S1.2.5p
S1.2.5-	sem:S1.2.5n
S1.2.5--	sem:S1.2.5n
S1.2.5---	sem:S1.2.5n
S1.2.5+/A2.1	sem:S1.2.5p sem:A2.1
S1.2.5-/A2.1	sem:S1.2.5n sem:A2.1
S1.2.5-/O4.1	sem:S1.2.5n sem:O4.1
S1.2.5+/S2.1f	sem:S1.2.5p sem:S2.1
S1.2.5+/S2mf	sem:S1.2.5p sem:S2
S1.2.5-/S2mf	sem:S1.2.5n sem:S2
S1.2.5-/X1	sem:S1.2.5n sem:X1
S1.2.6+	sem:S1.2.6p
S1.2.6-	sem:S1.2.6n
S1.2.6---	sem:S1.2.6n
S1.2.6-/S2	sem:S1.2.6n sem:S2
S1.2.6-/S2.2m	sem:S1.2.6n sem:S2.2
S1.2.6-/S2mf	sem:S1.2.6n sem:S2
S1.2.6-/S2mfn	sem:S1.2.6n sem:S2
S1.2/A5.1-	sem:S1.2 sem:A5.1n
S1.2/A6.2+	sem:S1.2 sem:A6.2p
S1.2/Df	sem:S1.2
S1.2/S8+	sem:S1.2 sem:S8p
S1.2/S8++	sem:S1.2 sem:S8p
S1.2/S8+++	sem:S1.2 sem:S8p
S1.2/S8-	sem:S1.2 sem:S8n
S1.2/T3-	sem:S1.2 sem:T3n
S2	sem:S2
S2.1	sem:S2.1
S2.1/A5.1+f	sem:S2.1 sem:A5.1p
S2.1/A8	sem:S2.1 sem:A8
S2.1/E2-	sem:S2.1 sem:E2n
S2.1/E2-m	sem:S2.1 sem:E2n
S2.1f	sem:S2.1
S2.1f/G1.2	sem:S2.1 sem:G1.2
S2.1f/O4.2-	sem:S2.1 sem:O4.2n
S2.1f/T3-/T1.3	sem:S2.1 sem:T3n sem:T1.3
S2.1f/X9.1-	sem:S2.1 sem:X9.1n
S2.1/G1.2	sem:S2.1 sem:G1.2
S2.1/G1.2f	sem:S2.1 sem:G1.2
S2.1/H1f	sem:S2.1 sem:H1
S2.1/O4.3f	sem:S2.1 sem:O4.3
S2.1/S1.2.5+f	sem:S2.1 sem:S1.2.5p
S2.1/X2.2-	sem:S2.1 sem:X2.2n
S2.2	sem:S2.2
S2.2/A1.1.1m	sem:S2.2 sem:A1.1.1
S2.2/A5.1+m	sem:S2.2 sem:A5.1p
S2.2/A6.2+m	sem:S2.2 sem:A6.2p
S2.2m	sem:S2.2
S2.2/O4.2	sem:S2.2 sem:O4.2
S2.2/O4.3	sem:S2.2 sem:O4.3
S2.2/S1.2.3+	sem:S2.2 sem:S1.2.3p
S2.2/S2.1f	sem:S2.2 sem:S2.1
S2.2/S7.1+	sem:S2.2 sem:S7.1p
S2.2/T3++m	sem:S2.2 sem:T3p
S2/A11.1+	sem:S2 sem:A11.1p
S2/E2+mf	sem:S2 sem:E2p
S2-/H4	sem:S2n sem:H4
S2/I3.1mf	sem:S2 sem:I3.1
S2mf	sem:S2
S2mf/A6.1-	sem:S2 sem:A6.1n
S2mfc	sem:S2
S2mfn	sem:S2
S2mf/P1	sem:S2 sem:P1
S2mf/T3-	sem:S2 sem:T3n
S2n	sem:S2
S2/N3.2+mf	sem:S2 sem:N3.2p
S2/N5+	sem:S2 sem:N5p
S2/N5++	sem:S2 sem:N5p
S2/N5-	sem:S2 sem:N5n
S2/N5.2+	sem:S2 sem:N5.2p
S2/N5c	sem:S2 sem:N5
S2/O2mf	sem:S2 sem:O2
S2/O4.3mf	sem:S2 sem:O4.3
S2/S1.2.3+	sem:S2 sem:S1.2.3p
S2/S7.2+	sem:S2 sem:S7.2p
S2/T1.3mf	sem:S2 sem:T1.3
S2/T3+	sem:S2 sem:T3p
S2/T3+mf	sem:S2 sem:T3p
S2/T3+++mf	sem:S2 sem:T3p
S2/T3++mf	sem:S2 sem:T3p
S2/X2.1mf	sem:S2 sem:X2.1
S2/Z6	sem:S2 sem:Z6
S3.1	sem:S3.1
S3.1-	sem:S3.1n
S3.1/A2.2	sem:S3.1 sem:A2.2
S3.1-/A6.1-	sem:S3.1n sem:A6.1n
S3.1mf	sem:S3.1
S3.1/P1mf	sem:S3.1 sem:P1
S3.1/Q1.2mf	sem:S3.1 sem:Q1.2
S3.1/S2.2m	sem:S3.1 sem:S2.2
S3.1/S2mf	sem:S3.1 sem:S2
S3.1-/S4	sem:S3.1n sem:S4
S3.1/T1.1	sem:S3.1 sem:T1.1
S3.2	sem:S3.2
S3.2+	sem:S3.2p
S3.2-	sem:S3.2n
S3.2/A10-/S2m	sem:S3.2 sem:A10n sem:S2
S3.2/A5.1-	sem:S3.2 sem:A5.1n
S3.2/B1	sem:S3.2 sem:B1
S3.2/B5	sem:S3.2 sem:B5
S3.2/G2.2+	sem:S3.2 sem:G2.2p
S3.2/G2.2-	sem:S3.2 sem:G2.2n
S3.2+/G2.2-	sem:S3.2p sem:G2.2n
S3.2+/G2.2-/S2.1f	sem:S3.2p sem:G2.2n sem:S2.1
S3.2/G2.2-/S2mf	sem:S3.2 sem:G2.2n sem:S2
S3.2/H1	sem:S3.2 sem:H1
S3.2/H1c	sem:S3.2 sem:H1
S3.2/H4	sem:S3.2 sem:H4
S3.2/I2.1	sem:S3.2 sem:I2.1
S3.2/I2.2	sem:S3.2 sem:I2.2
S3.2+/I3.1/S2mf	sem:S3.2p sem:I3.1 sem:S2
S3.2/K4	sem:S3.2 sem:K4
S3.2/M7	sem:S3.2 sem:M7
S3.2mf	sem:S3.2
S3.2/N5+	sem:S3.2 sem:N5p
S3.2/Q2.2	sem:S3.2 sem:Q2.2
S3.2/Q4	sem:S3.2 sem:Q4
S3.2/Q4/S2mf	sem:S3.2 sem:Q4 sem:S2
S3.2/S2	sem:S3.2 sem:S2
S3.2/S2.1	sem:S3.2 sem:S2.1
S3.2/S2.1f	sem:S3.2 sem:S2.1
S3.2+/S2.1f	sem:S3.2p sem:S2.1
S3.2-/S2.1f	sem:S3.2n sem:S2.1
S3.2/S2.2m	sem:S3.2 sem:S2.2
S3.2/S2mf	sem:S3.2 sem:S2
S3.2-/S2mf	sem:S3.2n sem:S2
S3.2/S5+c	sem:S3.2 sem:S5p
S3.2/T1.1.1m	sem:S3.2 sem:T1.1.1
S3.2/T2+	sem:S3.2 sem:T2p
S3.2/T3	sem:S3.2 sem:T3
S3.2/T3-	sem:S3.2 sem:T3n
S3.2/X1	sem:S3.2 sem:X1
S3.2/X3.3	sem:S3.2 sem:X3.3
S4	sem:S4
S4-	sem:S4n
S4/A12-	sem:S4 sem:A12n
S4/A12-c	sem:S4 sem:A12n
S4/B1	sem:S4 sem:B1
S4c	sem:S4
S4/E1	sem:S4 sem:E1
S4f	sem:S4
S4/G2.1-	sem:S4 sem:G2.1n
S4/G2.2-	sem:S4 sem:G2.2n
S4/G2.2-/S2.1f	sem:S4 sem:G2.2n sem:S2.1
S4/G2.2-/S2mf	sem:S4 sem:G2.2n sem:S2
S4/I1	sem:S4 sem:I1
S4/I1.1	sem:S4 sem:I1.1
S4/I1/A9-	sem:S4 sem:I1 sem:A9n
S4/I2.2	sem:S4 sem:I2.2
S4/K1	sem:S4 sem:K1
S4/L2	sem:S4 sem:L2
S4m	sem:S4
S4/M1/O2	sem:S4 sem:M1 sem:O2
S4/M3/O2	sem:S4 sem:M3 sem:O2
S4mf	sem:S4
S4mfn	sem:S4
S4/N4/H1	sem:S4 sem:N4 sem:H1
S4/N5	sem:S4 sem:N5
S4/N5+	sem:S4 sem:N5p
S4/N6+	sem:S4 sem:N6p
S4/Q1.2	sem:S4 sem:Q1.2
S4/S2.1	sem:S4 sem:S2.1
S4/S2.1f	sem:S4 sem:S2.1
S4/S2.2	sem:S4 sem:S2.2
S4/S2.2m	sem:S4 sem:S2.2
S4/S2mf	sem:S4 sem:S2
S4-/S2mf	sem:S4n sem:S2
S4/S5+	sem:S4 sem:S5p
S4/S5+c	sem:S4 sem:S5p
S4/S6+	sem:S4 sem:S6p
S4/S9	sem:S4 sem:S9
S4/T1.1.1	sem:S4 sem:T1.1.1
S4T1.1.1	sem:S4 T1.1.1
S4/T1.1.1f	sem:S4 sem:T1.1.1
S4/T1.1.1m	sem:S4 sem:T1.1.1
S4/T1.1.1mf	sem:S4 sem:T1.1.1
S4/T1.2	sem:S4 sem:T1.2
S4/T1.3	sem:S4 sem:T1.3
S4/T3-/S2mf	sem:S4 sem:T3n sem:S2
S5	sem:S5
S5+	sem:S5p
S5+++	sem:S5p
S5-	sem:S5n
S5+/A11.2+	sem:S5p sem:A11.2p
S5+/A6.1-	sem:S5p sem:A6.1n
S5+/B2	sem:S5p sem:B2
S5+/B2+/H1	sem:S5p sem:B2p sem:H1
S5+c	sem:S5p
S5+c/X5.2+	sem:S5p sem:X5.2p
S5+/G3	sem:S5p sem:G3
S5+/G3c	sem:S5p sem:G3
S5/I1.1	sem:S5 sem:I1.1
S5+/I2.1c	sem:S5p sem:I2.1
S5-/I3.1	sem:S5n sem:I3.1
S5+/K1c	sem:S5p sem:K1
S5+/M7	sem:S5p sem:M7
S5+/M7c	sem:S5p sem:M7
S5+mfn	sem:S5p
S5/N5+	sem:S5 sem:N5p
S5+/N5+	sem:S5p sem:N5p
S5+/N5-	sem:S5p sem:N5n
S5/N5.1-	sem:S5 sem:N5.1n
S5+/N5-c	sem:S5p sem:N5n
S5+/N6+	sem:S5p sem:N6p
S5+/O4.2-c	sem:S5p sem:O4.2n
S5+/O4.3c	sem:S5p sem:O4.3
S5+/P1	sem:S5p sem:P1
S5+/Q2.2	sem:S5p sem:Q2.2
S5+/S2.2m	sem:S5p sem:S2.2
S5+/S2m	sem:S5p sem:S2
S5+/S2mf	sem:S5p sem:S2
S5-/S2mf	sem:S5n sem:S2
S5+/S7.1-	sem:S5p sem:S7.1n
S5+/S9c	sem:S5p sem:S9
S5/T1.3+	sem:S5 sem:T1.3p
S5+/T3-c	sem:S5p sem:T3n
S5/X2.1c	sem:S5 sem:X2.1
S5+/X7+	sem:S5p sem:X7p
S5/X7+c	sem:S5 sem:X7p
S5+/Z2	sem:S5p sem:Z2
S5+/Z2/S2mf	sem:S5p sem:Z2 sem:S2
S6	sem:S6
S6+	sem:S6p
S6-	sem:S6n
S6+/G2.1	sem:S6p sem:G2.1
S6+/I2.1	sem:S6p sem:I2.1
S6+/N6	sem:S6p sem:N6
S6-/Q1.2	sem:S6n sem:Q1.2
S6-/Q2.2	sem:S6n sem:Q2.2
S6+/S1.2	sem:S6p sem:S1.2
S6++/S2mf	sem:S6p sem:S2
S6+/S2mf	sem:S6p sem:S2
S6-/S2mf	sem:S6n sem:S2
S6+/T1.1	sem:S6p sem:T1.1
S7.1	sem:S7.1
S7.1+	sem:S7.1p
S7.1++	sem:S7.1p
S7.1-	sem:S7.1n
S7.1--	sem:S7.1n
S7.1+/A11.1+	sem:S7.1p sem:A11.1p
S7.1/A2.1	sem:S7.1 sem:A2.1
S7.1+/A2.1	sem:S7.1p sem:A2.1
S7.1-/A2.1	sem:S7.1n sem:A2.1
S7.1+/A5.1-	sem:S7.1p sem:A5.1n
S7.1+/A6.1+	sem:S7.1p sem:A6.1p
S7.1+/A9-	sem:S7.1p sem:A9n
S7.1+c	sem:S7.1p
S7.1+/C1	sem:S7.1p sem:C1
S7.1+/C1/S2mf	sem:S7.1p sem:C1 sem:S2
S7.1-/E1	sem:S7.1n sem:E1
S7.1-/E1/S2mf	sem:S7.1n sem:E1 sem:S2
S7.1+/E2-	sem:S7.1p sem:E2n
S7.1-/E2-	sem:S7.1n sem:E2n
S7.1+f	sem:S7.1p
S7.1/G2.2-	sem:S7.1 sem:G2.2n
S7.1+/G2.2-	sem:S7.1p sem:G2.2n
S7.1+/G3/S2.2m	sem:S7.1p sem:G3 sem:S2.2
S7.1+/H1c	sem:S7.1p sem:H1
S7.1+/H4/S2.2m	sem:S7.1p sem:H4 sem:S2.2
S7.1/I1.3+	sem:S7.1 sem:I1.3p
S7.1+/I2.1	sem:S7.1p sem:I2.1
S7.1+/I3.1/S2.2m	sem:S7.1p sem:I3.1 sem:S2.2
S7.1+/I3.2/S2mf	sem:S7.1p sem:I3.2 sem:S2
S7.1+/M7	sem:S7.1p sem:M7
S7.1-/M7	sem:S7.1n sem:M7
S7.1+/M7c	sem:S7.1p sem:M7
S7.1+/O2	sem:S7.1p sem:O2
S7.1+/Q2.2	sem:S7.1p sem:Q2.2
S7.1+/S1.1.3+	sem:S7.1p sem:S1.1.3p
S7.1+/S2	sem:S7.1p sem:S2
S7.1+/S2.1f	sem:S7.1p sem:S2.1
S7.1-/S2.1f	sem:S7.1n sem:S2.1
S7.1+++/S2.2m	sem:S7.1p sem:S2.2
S7.1+/S2.2m	sem:S7.1p sem:S2.2
S7.1-/S2.2m	sem:S7.1n sem:S2.2
S7.1-/S2c	sem:S7.1n sem:S2
S7.1+/S2m	sem:S7.1p sem:S2
S7.1++/S2mf	sem:S7.1p sem:S2
S7.1+/S2mf	sem:S7.1p sem:S2
S7.1--/S2mf	sem:S7.1n sem:S2
S7.1-/S2mf	sem:S7.1n sem:S2
S7.1+/S4c	sem:S7.1p sem:S4
S7.1+/S5+	sem:S7.1p sem:S5p
S7.1-/S5	sem:S7.1n sem:S5
S7.1-/S5-	sem:S7.1n sem:S5n
S7.1+/S5+c	sem:S7.1p sem:S5p
S7.1+/S5-/S2mf	sem:S7.1p sem:S5n sem:S2
S7.1+/S5+/X2.4	sem:S7.1p sem:S5p sem:X2.4
S7.1+/S9m	sem:S7.1p sem:S9
S7.1+/S9/S2mf	sem:S7.1p sem:S9 sem:S2
S7.1+/S9/Z1m	sem:S7.1p sem:S9 sem:Z1
S7.1+/T1.1.1mf	sem:S7.1p sem:T1.1.1
S7.1+/X7-	sem:S7.1p sem:X7n
S7.1+/Z6	sem:S7.1p sem:Z6
S7.2+	sem:S7.2p
S7.2-	sem:S7.2n
S7.2+/A11.1+	sem:S7.2p sem:A11.1p
S7.2-/A2.1	sem:S7.2n sem:A2.1
S7.2+/N5.2+	sem:S7.2p sem:N5.2p
S7.2+/N5.2+/S2mf	sem:S7.2p sem:N5.2p sem:S2
S7.2-/Q1.2	sem:S7.2n sem:Q1.2
S7.2-/Q2.1	sem:S7.2n sem:Q2.1
S7.2+/Q2.2	sem:S7.2p sem:Q2.2
S7.2+/Q2.2/S2mf	sem:S7.2p sem:Q2.2 sem:S2
S7.2+/S2.1f	sem:S7.2p sem:S2.1
S7.2+/S2mf	sem:S7.2p sem:S2
S7.2+/S9	sem:S7.2p sem:S9
S7.2-/S9	sem:S7.2n sem:S9
S7.3	sem:S7.3
S7.3+	sem:S7.3p
S7.3++	sem:S7.3p
S7.3-	sem:S7.3n
S7.3+/E3-	sem:S7.3p sem:E3n
S7.3+/E3-/S2mf	sem:S7.3p sem:E3n sem:S2
S7.3+/O4.2	sem:S7.3p sem:O4.2
S7.3/S2mf	sem:S7.3 sem:S2
S7.3+/S2mf	sem:S7.3p sem:S2
S7.3+/S7.1	sem:S7.3p sem:S7.1
S7.4	sem:S7.4
S7.4+	sem:S7.4p
S7.4-	sem:S7.4n
S7.4+/A1.7-	sem:S7.4p sem:A1.7n
S7.4+/M1	sem:S7.4p sem:M1
S7.4/M1+/H1	sem:S7.4 sem:M1 sem:H1
S7.4/M1+/I1.3	sem:S7.4 sem:M1 sem:I1.3
S8+	sem:S8p
S8+++	sem:S8p
S8-	sem:S8n
S8+/A10-	sem:S8p sem:A10n
S8+/A11.1+	sem:S8p sem:A11.1p
S8+/A1.1.2-	sem:S8p sem:A1.1.2n
S8+/A15+	sem:S8p sem:A15p
S8-/A15-	sem:S8n sem:A15n
S8+/A15+/I3.2/S2mf	sem:S8p sem:A15p sem:I3.2 sem:S2
S8+/A15+/S2mf	sem:S8p sem:A15p sem:S2
S8+/A5.1+	sem:S8p sem:A5.1p
S8-/B1	sem:S8n sem:B1
S8+/B3	sem:S8p sem:B3
S8+c	sem:S8p
S8-/E2-	sem:S8n sem:E2n
S8-/G2.1	sem:S8n sem:G2.1
S8+/G2.2-	sem:S8p sem:G2.2n
S8+/H1	sem:S8p sem:H1
S8+/H1c	sem:S8p sem:H1
S8+/H4	sem:S8p sem:H4
S8+/I1	sem:S8p sem:I1
S8+/I1-	sem:S8p sem:I1
S8+/I1.1	sem:S8p sem:I1.1
S8+/I1.2	sem:S8p sem:I1.2
S8+/I2.2/H1	sem:S8p sem:I2.2 sem:H1
S8+/M4	sem:S8p sem:M4
S8+/N5-	sem:S8p sem:N5n
S8+/Q1.2	sem:S8p sem:Q1.2
S8+/Q1.3	sem:S8p sem:Q1.3
S8+/Q2.1	sem:S8p sem:Q2.1
S8+/Q2.1/S2mf	sem:S8p sem:Q2.1 sem:S2
S8+/Q2.2	sem:S8p sem:Q2.2
S8+/Q2.2/S2mf	sem:S8p sem:Q2.2 sem:S2
S8+/S1.1.2+	sem:S8p sem:S1.1.2p
S8+/S2m	sem:S8p sem:S2
S8+/S2mf	sem:S8p sem:S2
S8-/S2mf	sem:S8n sem:S2
S8+/S3.2	sem:S8p sem:S3.2
S8+/S4	sem:S8p sem:S4
S8+/S4/S2mf	sem:S8p sem:S4 sem:S2
S8+/S5	sem:S8p sem:S5
S8+/S5+	sem:S8p sem:S5p
S8+/S5-	sem:S8p sem:S5n
S8-/S5	sem:S8n sem:S5
S8+/S5+c	sem:S8p sem:S5p
S8+/S5c	sem:S8p sem:S5
S8+/S7.1+/S5+	sem:S8p sem:S7.1p sem:S5p
S8-/X1	sem:S8n sem:X1
S8+/X9.2+	sem:S8p sem:X9.2p
S8+/Y2	sem:S8p sem:Y2
S8-/Z6	sem:S8n sem:Z6
S9	sem:S9
S9-	sem:S9n
S9/A1.1.1	sem:S9 sem:A1.1.1
S9/A11.1+	sem:S9 sem:A11.1p
S9/A5.1-	sem:S9 sem:A5.1n
S9/A6.1-	sem:S9 sem:A6.1n
S9/A9-	sem:S9 sem:A9n
S9/B3	sem:S9 sem:B3
S9c	sem:S9
S9/E2-	sem:S9 sem:E2n
S9f	sem:S9
S9fn	sem:S9
S9/G1.1	sem:S9 sem:G1.1
S9/G1.1c	sem:S9 sem:G1.1
S9/G2.1	sem:S9 sem:G2.1
S9/G2.2-	sem:S9 sem:G2.2n
S9/H1	sem:S9 sem:H1
S9/H1c	sem:S9 sem:H1
S9/H2	sem:S9 sem:H2
S9/H5	sem:S9 sem:H5
S9/K2	sem:S9 sem:K2
S9/L2	sem:S9 sem:L2
S9/L2mfn	sem:S9 sem:L2
S9/L2mnc	sem:S9 sem:L2
S9m	sem:S9
S9/M7	sem:S9 sem:M7
S9mf	sem:S9
S9mfn	sem:S9
S9mn	sem:S9
S9/P1	sem:S9 sem:P1
S9/P1c	sem:S9 sem:P1
S9/Q1.1	sem:S9 sem:Q1.1
S9/Q1.2	sem:S9 sem:Q1.2
S9/Q2.1	sem:S9 sem:Q2.1
S9/Q2.2	sem:S9 sem:Q2.2
S9/Q4.1	sem:S9 sem:Q4.1
S9/S2	sem:S9 sem:S2
S9/S2.1f	sem:S9 sem:S2.1
S9/S2.2m	sem:S9 sem:S2.2
S9/S2c	sem:S9 sem:S2
S9/S2f	sem:S9 sem:S2
S9/S2m	sem:S9 sem:S2
S9/S2mf	sem:S9 sem:S2
S9-/S2mf	sem:S9n sem:S2
S9/S2mfn	sem:S9 sem:S2
S9/S4	sem:S9 sem:S4
S9/S5+	sem:S9 sem:S5p
S9/S5+c	sem:S9 sem:S5p
S9/S7.1+	sem:S9 sem:S7.1p
S9/S7.1+/S2.1f	sem:S9 sem:S7.1p sem:S2.1
S9/S7.1+/S2.2m	sem:S9 sem:S7.1p sem:S2.2
S9/S7.1+/S2mf	sem:S9 sem:S7.1p sem:S2
S9/S7.2-	sem:S9 sem:S7.2n
S9/S7.4+	sem:S9 sem:S7.4p
S9/T1.1.1	sem:S9 sem:T1.1.1
S9/T1.1.3	sem:S9 sem:T1.1.3
S9/T1.3	sem:S9 sem:T1.3
S9/T1.3/N4	sem:S9 sem:T1.3 sem:N4
S9/T2+	sem:S9 sem:T2p
S9/X2	sem:S9 sem:X2
S9/Z1f	sem:S9 sem:Z1
T1	sem:T1
T1.1	sem:T1.1
T1.1.1	sem:T1.1.1
T1.1.1/H1c	sem:T1.1.1 sem:H1
T1.1.1/O2	sem:T1.1.1 sem:O2
T1.1.1/S2.2m	sem:T1.1.1 sem:S2.2
T1.1.1/S2mf	sem:T1.1.1 sem:S2
T1.1.2	sem:T1.1.2
T1.1.2-	sem:T1.1.2n
T1.1.2/A2.1	sem:T1.1.2 sem:A2.1
T1.1.2/N4	sem:T1.1.2 sem:N4
T1.1.2/Q1.1	sem:T1.1.2 sem:Q1.1
T1.1.2/S2.2m	sem:T1.1.2 sem:S2.2
T1.1.2/S2mf	sem:T1.1.2 sem:S2
T1.1.3	sem:T1.1.3
T1.1.3/N3.8+	sem:T1.1.3 sem:N3.8p
T1.1.3/N3.8++	sem:T1.1.3 sem:N3.8p
T1.1.3/N3.8+++	sem:T1.1.3 sem:N3.8p
T1.1.3/S2mf	sem:T1.1.3 sem:S2
T1.1.3/S9/S2mf	sem:T1.1.3 sem:S9 sem:S2
T1.1.3/T1.3	sem:T1.1.3 sem:T1.3
T1.1/A2.1	sem:T1.1 sem:A2.1
T1.2	sem:T1.2
T1.2/A1.2+	sem:T1.2 sem:A1.2p
T1.2/A1.2-	sem:T1.2 sem:A1.2n
T1.2/F1	sem:T1.2 sem:F1
T1.2/N5+	sem:T1.2 sem:N5p
T1.2/P1	sem:T1.2 sem:P1
T1.2/T2-	sem:T1.2 sem:T2n
T1.2/T3	sem:T1.2 sem:T3
T1.3	sem:T1.3
T1.3+	sem:T1.3p
T1.3++	sem:T1.3p
T1.3+++	sem:T1.3p
T1.3-	sem:T1.3n
T1.3--	sem:T1.3n
T1.3-/A1.8+	sem:T1.3n sem:A1.8p
T1.3/A5.1-	sem:T1.3 sem:A5.1n
T1.3/E3+	sem:T1.3 sem:E3p
T1.3/F1	sem:T1.3 sem:F1
T1.3/G1.1	sem:T1.3 sem:G1.1
T1.3/G1.2	sem:T1.3 sem:G1.2
T1.3/I1	sem:T1.3 sem:I1
T1.3/I1.3-/F2	sem:T1.3 sem:I1.3n sem:F2
T1.3/I3.1	sem:T1.3 sem:I3.1
T1.3/I4	sem:T1.3 sem:I4
T1.3/K1	sem:T1.3 sem:K1
T1.3-/N4	sem:T1.3n sem:N4
T1.3/N5.1+	sem:T1.3 sem:N5.1p
T1.3/O4.6-	sem:T1.3 sem:O4.6n
T1.3/P1	sem:T1.3 sem:P1
T1.3/P1-	sem:T1.3 sem:P1n
T1.3/Q1.2	sem:T1.3 sem:Q1.2
T1.3+/Q1.2	sem:T1.3p sem:Q1.2
T1.3/Q4.3	sem:T1.3 sem:Q4.3
T1.3/S4	sem:T1.3 sem:S4
T1.3/S9	sem:T1.3 sem:S9
T1.3/T3-	sem:T1.3 sem:T3n
T1.3/X9.2+	sem:T1.3 sem:X9.2p
T1.3/Y1	sem:T1.3 sem:Y1
T1/A7-	sem:T1 sem:A7n
T1/H1	sem:T1 sem:H1
T1/N4	sem:T1 sem:N4
T1/N4-	sem:T1 sem:N4n
T1/O2	sem:T1 sem:O2
T1/O3	sem:T1 sem:O3
T1/Q1.2	sem:T1 sem:Q1.2
T1/Q4.3/O2	sem:T1 sem:Q4.3 sem:O2
T1/S2mf	sem:T1 sem:S2
T1/S7.1+	sem:T1 sem:S7.1p
T1/Z6	sem:T1 sem:Z6
T2+	sem:T2p
T2++	sem:T2p
T2+++	sem:T2p
T2++@	sem:T2p
T2-	sem:T2n
T2+/A1.1.1	sem:T2p sem:A1.1.1
T2-/A1.1.1	sem:T2n sem:A1.1.1
T2+/A2.1	sem:T2p sem:A2.1
T2-/F3-	sem:T2n sem:F3n
T2-/G2.1	sem:T2n sem:G2.1
T2-/I1.3	sem:T2n sem:I1.3
T2++/N4	sem:T2p sem:N4
T2+/N6+	sem:T2p sem:N6p
T2+/S2mf	sem:T2p sem:S2
T2+/S7.1+	sem:T2p sem:S7.1p
T2-/S7.1+	sem:T2n sem:S7.1p
T2-/T1.2	sem:T2n sem:T1.2
T2++/T1.3+	sem:T2p sem:T1.3p
T2+/T1.3	sem:T2p sem:T1.3
T2-/T1.3	sem:T2n sem:T1.3
T2+++/X5.2-	sem:T2p sem:X5.2n
T3	sem:T3
T3+	sem:T3p
T3++	sem:T3p
T3+++	sem:T3p
T3-	sem:T3n
T3--	sem:T3n
T3---	sem:T3n
T3+/A2.1	sem:T3p sem:A2.1
T3---/A2.1	sem:T3n sem:A2.1
T3-/A2.1	sem:T3n sem:A2.1
T3+/A2.1mfn	sem:T3p sem:A2.1
T3/A6.1-	sem:T3 sem:A6.1n
T3--/B4	sem:T3n sem:B4
T3-/G2.1/H1	sem:T3n sem:G2.1 sem:H1
T3-/H1c	sem:T3n sem:H1
T3-/I1.1	sem:T3n sem:I1.1
T3+/I2.1/S2mf	sem:T3p sem:I2.1 sem:S2
T3-/I3.1	sem:T3n sem:I3.1
T3--/L1-	sem:T3n sem:L1n
T3--/N3.5	sem:T3n sem:N3.5
T3/N5.1	sem:T3 sem:N5.1
T3+/N6+	sem:T3p sem:N6p
T3+++/O2	sem:T3p sem:O2
T3/P1	sem:T3 sem:P1
T3-/Q4.1	sem:T3n sem:Q4.1
T3+/S1.1.1	sem:T3p sem:S1.1.1
T3+/S2	sem:T3p sem:S2
T3+/S2.1f	sem:T3p sem:S2.1
T3--/S2.1f	sem:T3n sem:S2.1
T3-/S2.1f	sem:T3n sem:S2.1
T3-/S2.2	sem:T3n sem:S2.2
T3++/S2.2m	sem:T3p sem:S2.2
T3+/S2.2m	sem:T3p sem:S2.2
T3--/S2.2m	sem:T3n sem:S2.2
T3/S2mf	sem:T3 sem:S2
T3+++/S2mf	sem:T3p sem:S2
T3++/S2mf	sem:T3p sem:S2
T3+/S2mf	sem:T3p sem:S2
T3--/S2mf	sem:T3n sem:S2
T3-/S2mf	sem:T3n sem:S2
T3-/S5+c	sem:T3n sem:S5p
T3-/T2+	sem:T3n sem:T2p
T3++/X2.1	sem:T3p sem:X2.1
T3/X2.4	sem:T3 sem:X2.4
T3/X2.4/S2mf	sem:T3 sem:X2.4 sem:S2
T3/X2.6	sem:T3 sem:X2.6
T4	sem:T4
T4+	sem:T4p
T4-	sem:T4n
T4--	sem:T4n
T4---	sem:T4n
T4+/A10+	sem:T4p sem:A10p
T4+/I1.2	sem:T4p sem:I1.2
T4+/Q2.2	sem:T4p sem:Q2.2
T4+/S2mf	sem:T4p sem:S2
T4-/S2mf	sem:T4n sem:S2
T4+/T1.2	sem:T4p sem:T1.2
W1	sem:W1
W1/G1.2	sem:W1 sem:G1.2
W1/L1	sem:W1 sem:L1
W1/S2mf	sem:W1 sem:S2
W2	sem:W2
W2-	sem:W2n
W2--	sem:W2n
W2---	sem:W2n
W2/H1/M4	sem:W2 sem:H1 sem:M4
W2/W1	sem:W2 sem:W1
W2/W4	sem:W2 sem:W4
W3	sem:W3
W3/I3.2/S2mf	sem:W3 sem:I3.2 sem:S2
W3/I4	sem:W3 sem:I4
W3/K5.1	sem:W3 sem:K5.1
W3/L1	sem:W3 sem:L1
W3/L2	sem:W3 sem:L2
W3/L3	sem:W3 sem:L3
W3/M4	sem:W3 sem:M4
W3/M4/S2mf	sem:W3 sem:M4 sem:S2
W3/O2	sem:W3 sem:O2
W3/P1	sem:W3 sem:P1
W3/Q1.2	sem:W3 sem:Q1.2
W3/S2mf	sem:W3 sem:S2
W3/S9	sem:W3 sem:S9
W3/Y1	sem:W3 sem:Y1
W4	sem:W4
W4/N3.1	sem:W4 sem:N3.1
W4/O2	sem:W4 sem:O2
W4/O4.6+	sem:W4 sem:O4.6p
W4/T1.3	sem:W4 sem:T1.3
W4/X2.6+	sem:W4 sem:X2.6p
W5	sem:W5
W5/A1.1.2	sem:W5 sem:A1.1.2
W5/M7	sem:W5 sem:M7
W5/O3	sem:W5 sem:O3
W5/S2mf	sem:W5 sem:S2
W5/S7.1+	sem:W5 sem:S7.1p
X1	sem:X1
X1/A6.2+	sem:X1 sem:A6.2p
X1/B2+	sem:X1 sem:B2p
X1/L2	sem:X1 sem:L2
X1/M1	sem:X1 sem:M1
X1/S1.1.1	sem:X1 sem:S1.1.1
X1/T3	sem:X1 sem:T3
X2	sem:X2
X2.1	sem:X2.1
X2.1+	sem:X2.1
X2.1-	sem:X2.1n
X2.1/A10-	sem:X2.1 sem:A10n
X2.1/A1.3+	sem:X2.1 sem:A1.3p
X2.1/A2.1	sem:X2.1 sem:A2.1
X2.1/A2.1+	sem:X2.1 sem:A2.1p
X2.1/A2.1-	sem:X2.1 sem:A2.1n
X2.1/A3	sem:X2.1 sem:A3
X2.1/A5	sem:X2.1 sem:A5
X2.1/A5.1+++	sem:X2.1 sem:A5.1p
X2.1/A5.1-	sem:X2.1 sem:A5.1n
X2.1/A5.1+++/S2mf	sem:X2.1 sem:A5.1p sem:S2
X2.1/A6.1+	sem:X2.1 sem:A6.1p
X2.1/A6.2+	sem:X2.1 sem:A6.2p
X2.1/A6.2-	sem:X2.1 sem:A6.2n
X2.1/A7-	sem:X2.1 sem:A7n
X2.1/E1	sem:X2.1 sem:E1
X2.1/E4.1-	sem:X2.1 sem:E4.1n
X2.1/G1.2	sem:X2.1 sem:G1.2
X2.1/G2.2	sem:X2.1 sem:G2.2
X2.1/M7	sem:X2.1 sem:M7
X2.1/N6+	sem:X2.1 sem:N6p
X2.1/S2mf	sem:X2.1 sem:S2
X2.1/T1.1.1	sem:X2.1 sem:T1.1.1
X2.1/X5.1+	sem:X2.1 sem:X5.1p
X2.1/X5.1-	sem:X2.1 sem:X5.1n
X2.2	sem:X2.2
X2.2+	sem:X2.2p
X2.2+++	sem:X2.2p
X2.2-	sem:X2.2n
X2.2+/A15-	sem:X2.2p sem:A15n
X2.2/A2.2	sem:X2.2 sem:A2.2
X2.2/A2.2-	sem:X2.2 sem:A2.2n
X2.2+/A9-	sem:X2.2p sem:A9n
X2.2+/G2.2-	sem:X2.2p sem:G2.2n
X2.2/S1.1.1	sem:X2.2 sem:S1.1.1
X2.2/S2mf	sem:X2.2 sem:S2
X2.2+/S2mf	sem:X2.2p sem:S2
X2.2-/S2mf	sem:X2.2n sem:S2
X2.2+/S5+	sem:X2.2p sem:S5p
X2.2+/S5+c	sem:X2.2p sem:S5p
X2.2+/S7.2+	sem:X2.2p sem:S7.2p
X2.2+/T1.1.1	sem:X2.2p sem:T1.1.1
X2.2+/T3-	sem:X2.2p sem:T3n
X2.2/X2.4	sem:X2.2 sem:X2.4
X2.2/Y2	sem:X2.2 sem:Y2
X2.3	sem:X2.3
X2.3+	sem:X2.3p
X2.3+/N6+	sem:X2.3p sem:N6p
X2.3+/P1	sem:X2.3p sem:P1
X2.3+/Y2	sem:X2.3p sem:Y2
X2.4	sem:X2.4
X2.4+	sem:X2.4p
X2.4-	sem:X2.4n
X2.4/A5	sem:X2.4 sem:A5
X2.4-/A5	sem:X2.4n sem:A5
X2.4/A5.2+	sem:X2.4 sem:A5.2p
X2.4/A5.3	sem:X2.4 sem:A5.3
X2.4/A5.3/N6+	sem:X2.4 sem:A5.3 sem:N6p
X2.4/A5.3/S5+c	sem:X2.4 sem:A5.3 sem:S5p
X2.4/A5/P1	sem:X2.4 sem:A5 sem:P1
X2.4/B3/L2	sem:X2.4 sem:B3 sem:L2
X2.4/G2.1	sem:X2.4 sem:G2.1
X2.4+/H1c	sem:X2.4p sem:H1
X2.4/I2.2mf	sem:X2.4 sem:I2.2
X2.4/N4	sem:X2.4 sem:N4
X2.4/N5.2+	sem:X2.4 sem:N5.2p
X2.4/N6+	sem:X2.4 sem:N6p
X2.4/P1	sem:X2.4 sem:P1
X2.4/Q1.2	sem:X2.4 sem:Q1.2
X2.4/S1.1.1	sem:X2.4 sem:S1.1.1
X2.4/S2	sem:X2.4 sem:S2
X2.4/S2mf	sem:X2.4 sem:S2
X2.4/S5+	sem:X2.4 sem:S5p
X2.4/S5-	sem:X2.4 sem:S5n
X2.4/S5+c	sem:X2.4 sem:S5p
X2.4/T2++	sem:X2.4 sem:T2p
X2.4/X2.2	sem:X2.4 sem:X2.2
X2.4/X6+	sem:X2.4 sem:X6p
X2.4/X7-	sem:X2.4 sem:X7n
X2.4/Y1	sem:X2.4 sem:Y1
X2.4/Z6	sem:X2.4 sem:Z6
X2.5+	sem:X2.5p
X2.5-	sem:X2.5n
X2.5+/E1	sem:X2.5p sem:E1
X2.5+/E1/N5.2+	sem:X2.5p sem:E1 sem:N5.2p
X2.5+/E1/S2mf	sem:X2.5p sem:E1 sem:S2
X2.5-/Q1.1	sem:X2.5n sem:Q1.1
X2.5/Q1.2	sem:X2.5 sem:Q1.2
X2.5-/Q2.1	sem:X2.5n sem:Q2.1
X2.5+/S1.2	sem:X2.5p sem:S1.2
X2.5+/T4-	sem:X2.5p sem:T4n
X2.6	sem:X2.6
X2.6+	sem:X2.6p
X2.6-	sem:X2.6n
X2.6/A1.1.1	sem:X2.6 sem:A1.1.1
X2.6+/A15-	sem:X2.6p sem:A15n
X2.6/A5.1-	sem:X2.6 sem:A5.1n
X2.6+/A5.1+	sem:X2.6p sem:A5.1p
X2.6/A5.1+mf	sem:X2.6 sem:A5.1p
X2.6+/A5.1+mf	sem:X2.6p sem:A5.1p
X2.6+/A5.1+/N5.2+	sem:X2.6p sem:A5.1p sem:N5.2p
X2.6/A5.1+/S1.2	sem:X2.6 sem:A5.1p sem:S1.2
X2.6+/T1.1.3/S9	sem:X2.6p sem:T1.1.3 sem:S9
X2/A5.2-	sem:X2 sem:A5.2n
X2/S2mf	sem:X2 sem:S2
X2/S9	sem:X2 sem:S9
X3	sem:X3
X3-	sem:X3
X3.1	sem:X3.1
X3.1+	sem:X3.1p
X3.1/F1	sem:X3.1 sem:F1
X3.1+/F1	sem:X3.1p sem:F1
X3.1/F2	sem:X3.1 sem:F2
X3.1/S2mf	sem:X3.1 sem:S2
X3.2	sem:X3.2
X3.2+	sem:X3.2p
X3.2++	sem:X3.2p
X3.2+++	sem:X3.2p
X3.2-	sem:X3.2n
X3.2--	sem:X3.2n
X3.2/A10-	sem:X3.2 sem:A10n
X3.2+/A2.1	sem:X3.2p sem:A2.1
X3.2-/A2.1	sem:X3.2n sem:A2.1
X3.2/A5.1-	sem:X3.2 sem:A5.1n
X3.2++/A5.1-	sem:X3.2p sem:A5.1n
X3.2/A5.2-	sem:X3.2 sem:A5.2n
X3.2/A5.3-	sem:X3.2 sem:A5.3n
X3.2/B2-	sem:X3.2 sem:B2n
X3.2/E2-	sem:X3.2 sem:E2n
X3.2/E4.2-	sem:X3.2 sem:E4.2n
X3.2/K4	sem:X3.2 sem:K4
X3.2/L2	sem:X3.2 sem:L2
X3.2/M1	sem:X3.2 sem:M1
X3.2/N3.1	sem:X3.2 sem:N3.1
X3.2/O1.2	sem:X3.2 sem:O1.2
X3.2/O2	sem:X3.2 sem:O2
X3.2/O3	sem:X3.2 sem:O3
X3.2+/Q4.1	sem:X3.2p sem:Q4.1
X3.2/S2mf	sem:X3.2 sem:S2
X3.2/X3.4	sem:X3.2 sem:X3.4
X3.3	sem:X3.3
X3.3/E2+	sem:X3.3 sem:E2p
X3.4	sem:X3.4
X3.4+	sem:X3.4p
X3.4-	sem:X3.4n
X3.4/A1.3+	sem:X3.4 sem:A1.3p
X3.4/A15+/S2.2m	sem:X3.4 sem:A15p sem:S2.2
X3.4-/B2-	sem:X3.4n sem:B2n
X3.4/E2-	sem:X3.4 sem:E2n
X3.4/E3-	sem:X3.4 sem:E3n
X3.4-/H1c	sem:X3.4n sem:H1
X3.4/L2	sem:X3.4 sem:L2
X3.4/M7	sem:X3.4 sem:M7
X3.4/N3.8+	sem:X3.4 sem:N3.8p
X3.4/N4	sem:X3.4 sem:N4
X3.4/N6+	sem:X3.4 sem:N6p
X3.4/O2	sem:X3.4 sem:O2
X3.4/S1.1.1	sem:X3.4 sem:S1.1.1
X3.4/S2mf	sem:X3.4 sem:S2
X3.4-/S2mf	sem:X3.4n sem:S2
X3.4/W4	sem:X3.4 sem:W4
X3.5	sem:X3.5
X3.5+	sem:X3.5
X3.5/A5.1-	sem:X3.5 sem:A5.1n
X4.1	sem:X4.1
X4.1/A12	sem:X4.1 sem:A12
X4.1/A2.1+	sem:X4.1 sem:A2.1p
X4.1/A5.1+++	sem:X4.1 sem:A5.1p
X4.1/A5.1-	sem:X4.1 sem:A5.1n
X4.1/A5.2-	sem:X4.1 sem:A5.2n
X4.1/S2mf	sem:X4.1 sem:S2
X4.1+/S5+/S1.1.3+	sem:X4.1 sem:S5p sem:S1.1.3p
X4.2	sem:X4.2
X4.2/P1	sem:X4.2 sem:P1
X4.2/X2.4	sem:X4.2 sem:X2.4
X4.2/Y2	sem:X4.2 sem:Y2
X5.1	sem:X5.1
X5.1+	sem:X5.1p
X5.1++	sem:X5.1p
X5.1-	sem:X5.1n
X5.1+/A2.1+	sem:X5.1p sem:A2.1p
X5.1+/S1.2	sem:X5.1p sem:S1.2
X5.1+/S2mf	sem:X5.1p sem:S2
X5.1-/S2mf	sem:X5.1n sem:S2
X5.2+	sem:X5.2p
X5.2++	sem:X5.2p
X5.2+++	sem:X5.2p
X5.2-	sem:X5.2n
X5.2-/A1.1.1	sem:X5.2n sem:A1.1.1
X5.2+/A2.1	sem:X5.2p sem:A2.1
X5.2+/A2.1+	sem:X5.2p sem:A2.1p
X5.2-/A2.1-	sem:X5.2n sem:A2.1n
X5.2+/A2.2	sem:X5.2p sem:A2.2
X5.2-/A2.2	sem:X5.2n sem:A2.2
X5.2+/C1	sem:X5.2p sem:C1
X5.2++/E3-	sem:X5.2p sem:E3n
X5.2-/E4.1-	sem:X5.2n sem:E4.1n
X5.2+/N5.2+	sem:X5.2p sem:N5.2p
X5.2+/Q2.1	sem:X5.2p sem:Q2.1
X5.2+/S1.2	sem:X5.2p sem:S1.2
X5.2-/S1.2	sem:X5.2n sem:S1.2
X5.2+++/S2mf	sem:X5.2p sem:S2
X5.2++/S2mf	sem:X5.2p sem:S2
X5.2+/S2mf	sem:X5.2p sem:S2
X5.2-/S2mf	sem:X5.2n sem:S2
X5.2+/S3.2	sem:X5.2p sem:S3.2
X5.2+/Z4	sem:X5.2p sem:Z4
X6	sem:X6
X6+	sem:X6p
X6-	sem:X6n
X6/A7-	sem:X6 sem:A7n
X6+/N4	sem:X6p sem:N4
X6/S2mf	sem:X6 sem:S2
X6/T1.1.3	sem:X6 sem:T1.1.3
X7	sem:X7
X7+	sem:X7p
X7++	sem:X7p
X7-	sem:X7n
X7.2+	sem:X7
X7+/A1.6	sem:X7p sem:A1.6
X7+/A5.1+++	sem:X7p sem:A5.1p
X7++/G2.2-	sem:X7p sem:G2.2n
X7+/G2.2-	sem:X7p sem:G2.2n
X7-/M2	sem:X7n sem:M2
X7+/N3.2+	sem:X7p sem:N3.2p
X7+/N4	sem:X7p sem:N4
X7/N5+	sem:X7 sem:N5p
X7/N5++	sem:X7 sem:N5p
X7-/O2	sem:X7n sem:O2
X7+/Q1.2	sem:X7p sem:Q1.2
X7-/Q1.2	sem:X7n sem:Q1.2
X7+/Q2.2	sem:X7p sem:Q2.2
X7+/Q2.2/S2mf	sem:X7p sem:Q2.2 sem:S2
X7-/S1.1.3+	sem:X7n sem:S1.1.3p
X7-/S1.1.3+/S2mf	sem:X7n sem:S1.1.3p sem:S2
X7+/S2mf	sem:X7p sem:S2
X7-/S2mf	sem:X7n sem:S2
X7+/S5c	sem:X7p sem:S5
X7+/S6-	sem:X7p sem:S6n
X7+/S7.1+	sem:X7p sem:S7.1p
X7+/T1	sem:X7p sem:T1
X7+/T1.1.3	sem:X7p sem:T1.1.3
X7+/T1/S2mf	sem:X7p sem:T1 sem:S2
X7-/X2.4+mf	sem:X7n sem:X2.4p
X7/Z3	sem:X7 sem:Z3
X8+	sem:X8p
X8++	sem:X8p
X8+++	sem:X8p
X8-	sem:X8n
X8+/A12-	sem:X8p sem:A12n
X8+/A1.8+	sem:X8p sem:A1.8p
X8+/S2mf	sem:X8p sem:S2
X9.1	sem:X9.1
X9.1+	sem:X9.1p
X9.1++	sem:X9.1p
X9.1+++	sem:X9.1p
X9.1-	sem:X9.1n
X9.1+/A2.1	sem:X9.1p sem:A2.1
X9.1-/A2.1	sem:X9.1n sem:A2.1
X9.1+/A6.2-	sem:X9.1p sem:A6.2n
X9.1/A6.3	sem:X9.1 sem:A6.3
X9.1+/E4.1+	sem:X9.1p sem:E4.1p
X9.1+/I3.2	sem:X9.1p sem:I3.2
X9.1-/I3.2	sem:X9.1n sem:I3.2
X9.1+/M7	sem:X9.1p sem:M7
X9.1/N1	sem:X9.1 sem:N1
X9.1+/N5.2+	sem:X9.1p sem:N5.2p
X9.1-/S1.2	sem:X9.1n sem:S1.2
X9.1+/S2.2m	sem:X9.1p sem:S2.2
X9.1++/S2mf	sem:X9.1p sem:S2
X9.1+/S2mf	sem:X9.1p sem:S2
X9.1-/S2mf	sem:X9.1n sem:S2
X9.1+/S5+c	sem:X9.1p sem:S5p
X9.1+/S7.1+	sem:X9.1p sem:S7.1p
X9.1+/T2++	sem:X9.1p sem:T2p
X9.1+/T3+	sem:X9.1p sem:T3p
X9.1/X2.4	sem:X9.1 sem:X2.4
X9.1+/Y2	sem:X9.1p sem:Y2
X9.2	sem:X9.2
X9.2+	sem:X9.2p
X9.2++	sem:X9.2p
X9.2-	sem:X9.2n
X9.2+/G2.2-	sem:X9.2p sem:G2.2n
X9.2+/G2.2-/S2mf	sem:X9.2p sem:G2.2n sem:S2
X9.2+/G3	sem:X9.2p sem:G3
X9.2+/G3/S2mf	sem:X9.2p sem:G3 sem:S2
X9.2+/I2.1/S2.2m	sem:X9.2p sem:I2.1 sem:S2.2
X9.2+/K5.1	sem:X9.2p sem:K5.1
X9.2+/N5	sem:X9.2p sem:N5
X9.2-/N5	sem:X9.2n sem:N5
X9.2-/N5.1-	sem:X9.2n sem:N5.1n
X9.2+/S2mf	sem:X9.2p sem:S2
X9.2-/S2mf	sem:X9.2n sem:S2
X9.2+++/S7.3	sem:X9.2p sem:S7.3
X9.2+/S7.3	sem:X9.2p sem:S7.3
X9.2-/S7.3	sem:X9.2n sem:S7.3
X9.2+/S7.3/S2mf	sem:X9.2p sem:S7.3 sem:S2
X9.2+/T1.1.1	sem:X9.2p sem:T1.1.1
X9.2+/T1.3	sem:X9.2p sem:T1.3
Y1	sem:Y1
Y1-	sem:Y1n
Y1/A2.1+	sem:Y1 sem:A2.1p
Y1/A2.1-	sem:Y1 sem:A2.1n
Y1/A5.1+++	sem:Y1 sem:A5.1p
Y1/A9-	sem:Y1 sem:A9n
Y1/B1	sem:Y1 sem:B1
Y1/B1/S2mf	sem:Y1 sem:B1 sem:S2
Y1/B2-	sem:Y1 sem:B2n
Y1/B3	sem:Y1 sem:B3
Y1/G1.1c	sem:Y1 sem:G1.1
Y1/G2.1	sem:Y1 sem:G2.1
Y1/G3	sem:Y1 sem:G3
Y1/H1	sem:Y1 sem:H1
Y1/H1c	sem:Y1 sem:H1
Y1/I3.2/S2mf	sem:Y1 sem:I3.2 sem:S2
Y1/K6	sem:Y1 sem:K6
Y1/L1	sem:Y1 sem:L1
Y1/L1/S2mf	sem:Y1 sem:L1 sem:S2
Y1/L2	sem:Y1 sem:L2
Y1/L3	sem:Y1 sem:L3
Y1/M5	sem:Y1 sem:M5
Y1/M5/W1	sem:Y1 sem:M5 sem:W1
Y1/N1	sem:Y1 sem:N1
Y1/O1.1	sem:Y1 sem:O1.1
Y1/O1.1/S2mf	sem:Y1 sem:O1.1 sem:S2
Y1/O1.2	sem:Y1 sem:O1.2
Y1/O2	sem:Y1 sem:O2
Y1/O4.3	sem:Y1 sem:O4.3
Y1/P1	sem:Y1 sem:P1
Y1/P1mf	sem:Y1 sem:P1
Y1/S2mf	sem:Y1 sem:S2
Y1/T1.1.1	sem:Y1 sem:T1.1.1
Y1/W1	sem:Y1 sem:W1
Y1/W1c	sem:Y1 sem:W1
Y1/W1fn	sem:Y1 sem:W1
Y1/W1/S2.2m	sem:Y1 sem:W1 sem:S2.2
Y1/W1/S2mf	sem:Y1 sem:W1 sem:S2
Y1/W3	sem:Y1 sem:W3
Y1/W4	sem:Y1 sem:W4
Y1/W5/S2mf	sem:Y1 sem:W5 sem:S2
Y1/X1	sem:Y1 sem:X1
Y1/X2.1	sem:Y1 sem:X2.1
Y1/X2.4	sem:Y1 sem:X2.4
Y1/Z6	sem:Y1 sem:Z6
Y2	sem:Y2
Y2/A6.1+	sem:Y2 sem:A6.1p
Y2/B1	sem:Y2 sem:B1
Y2/C1	sem:Y2 sem:C1
Y2/G2.1	sem:Y2 sem:G2.1
Y2/K5.2/S2mf	sem:Y2 sem:K5.2 sem:S2
Y2/M1	sem:Y2 sem:M1
Y2/N2	sem:Y2 sem:N2
Y2/N2/S2mf	sem:Y2 sem:N2 sem:S2
Y2/N6+	sem:Y2 sem:N6p
Y2/P1	sem:Y2 sem:P1
Y2/Q1.2	sem:Y2 sem:Q1.2
Y2/Q3	sem:Y2 sem:Q3
Y2/S2	sem:Y2 sem:S2
Y2/S2mf	sem:Y2 sem:S2
Y2/W3	sem:Y2 sem:W3
Y2/X2.2+	sem:Y2 sem:X2.2p
Y2/X2.2/B1	sem:Y2 sem:X2.2 sem:B1
Y2/X2.2/S2mf	sem:Y2 sem:X2.2 sem:S2
Y2/X9.1+	sem:Y2 sem:X9.1p
Y2/X9.1+/S2mf	sem:Y2 sem:X9.1p sem:S2
Z1	sem:Z1
Z1c	sem:Z1
Z1f	sem:Z1
Z1fm	sem:Z1
Z1f/T1.1.1	sem:Z1 sem:T1.1.1
Z1m	sem:Z1
Z1m/E2-	sem:Z1 sem:E2n
Z1mf	sem:Z1
Z1mfc	sem:Z1
Z1mfn	sem:Z1
Z1m/K2	sem:Z1 sem:K2
Z1m/K4	sem:Z1 sem:K4
Z1m/S3.2	sem:Z1 sem:S3.2
Z1m/S7.1+	sem:Z1 sem:S7.1p
Z1m/S9	sem:Z1 sem:S9
Z1m/T1.1.1	sem:Z1 sem:T1.1.1
Z1nf	sem:Z1
Z1/S5+	sem:Z1 sem:S5p
Z1/S9	sem:Z1 sem:S9
Z1/W1	sem:Z1 sem:W1
Z2	sem:Z2
Z2/A6.1+	sem:Z2 sem:A6.1p
Z2c	sem:Z2
Z2/E2+	sem:Z2 sem:E2p
Z2/G3	sem:Z2 sem:G3
Z2/I1.1-/A15-	sem:Z2 sem:I1.1n sem:A15n
Z2/I2.2c	sem:Z2 sem:I2.2
Z2/K5.1	sem:Z2 sem:K5.1
Z2mfn	sem:Z2
Z2/O4.3mf	sem:Z2 sem:O4.3
Z2/Q3	sem:Z2 sem:Q3
Z2/S1.2	sem:Z2 sem:S1.2
Z2/S2	sem:Z2 sem:S2
Z2/S2.1f	sem:Z2 sem:S2.1
Z2/S2.2m	sem:Z2 sem:S2.2
Z2/S2.2mf	sem:Z2 sem:S2.2
Z2/S2c	sem:Z2 sem:S2
Z2/S2mf	sem:Z2 sem:S2
Z2/S2mfc	sem:Z2 sem:S2
Z2/S2mfnc	sem:Z2 sem:S2
Z2/S3mf	sem:Z2 sem:S3
Z2/S5+	sem:Z2 sem:S5p
Z2/S5+c	sem:Z2 sem:S5p
Z2/S9	sem:Z2 sem:S9
Z2/T1.1.1	sem:Z2 sem:T1.1.1
Z3	sem:Z3
Z3/A5.1+	sem:Z3 sem:A5.1p
Z3c	sem:Z3
Z3/C1	sem:Z3 sem:C1
Z3c/B4	sem:Z3 sem:B4
Z3c/B5/O1.1	sem:Z3 sem:B5 sem:O1.1
Z3c/C1	sem:Z3 sem:C1
Z3cfn	sem:Z3
Z3c/G3	sem:Z3 sem:G3
Z3c/K2	sem:Z3 sem:K2
Z3c/M3	sem:Z3 sem:M3
Z3c/M5	sem:Z3 sem:M5
Z3c/O2	sem:Z3 sem:O2
Z3c/P1c	sem:Z3 sem:P1
Z3c/Q1.3	sem:Z3 sem:Q1.3
Z3c/Q4.1	sem:Z3 sem:Q4.1
Z3c/Q4.3	sem:Z3 sem:Q4.3
Z3c/X2.4	sem:Z3 sem:X2.4
Z3c/Y2	sem:Z3 sem:Y2
Z3f	sem:Z3
Z3/F1	sem:Z3 sem:F1
Z3/F2	sem:Z3 sem:F2
Z3fn	sem:Z3
Z3fnc	sem:Z3
Z3/G1.1c/Y1/B1	sem:Z3 sem:G1.1 sem:Y1 sem:B1
Z3/G1.2	sem:Z3 sem:G1.2
Z3/G2	sem:Z3 sem:G2
Z3/G3	sem:Z3 sem:G3
Z3/I1.1	sem:Z3 sem:I1.1
Z3/I2.2	sem:Z3 sem:I2.2
Z3m	sem:Z3
Z3/M3	sem:Z3 sem:M3
Z3mf	sem:Z3
Z3mfn	sem:Z3
Z3mn	sem:Z3
Z3/P1	sem:Z3 sem:P1
Z3/Q1.3	sem:Z3 sem:Q1.3
Z3/Q4.2	sem:Z3 sem:Q4.2
Z3/Q4.3	sem:Z3 sem:Q4.3
Z3/S2mf	sem:Z3 sem:S2
Z3/T1	sem:Z3 sem:T1
Z3/Y2	sem:Z3 sem:Y2
Z3/Y2/X2.2+/B3	sem:Z3 sem:Y2 sem:X2.2p sem:B3
Z4	sem:Z4
Z4/E2-	sem:Z4 sem:E2n
Z5	sem:Z5
Z5/A2.2	sem:Z5 sem:A2.2
Z5/A6	sem:Z5 sem:A6
Z5/Q1.2	sem:Z5 sem:Q1.2
Z5/Z6	sem:Z5 sem:Z6
Z6	sem:Z6
Z6/Z8	sem:Z6 sem:Z8
Z6/Z8c	sem:Z6 sem:Z8
Z6/Z8m	sem:Z6 sem:Z8
Z7	sem:Z7
Z7-	sem:Z7n
Z8	sem:Z8
Z8/A6.1+	sem:Z8 sem:A6.1p
Z8f	sem:Z8
Z8m	sem:Z8
Z8mf	sem:Z8
Z8mfc	sem:Z8
Z8mfn	sem:Z8
Z8/N5.1+	sem:Z8 sem:N5.1p
Z8/N5.1+c	sem:Z8 sem:N5.1p
Z8/X2.2-	sem:Z8 sem:X2.2n
Z8/Z6	sem:Z8 sem:Z6
Z8/Z6cmf	sem:Z8 sem:Z6
Z9	sem:Z9
Z99	sem:Z99
