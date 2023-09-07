#!/usr/bin/perl
# Fix MTed CoNLL-U files:
# shorten too long sentences vis a vis orignal
# sort features and take care of SpaceAfter
#
use warnings;
use utf8;
use open ':utf8';
use FindBin qw($Bin);
binmode(STDERR, ':utf8');
$validate = shift;
$inDirs = shift;
$outDir = shift;
    
# Change to where tools is installed on local system
# Source: https://github.com/universaldependencies/tools
$Valid = "/usr/local/tools/validate.py";

# What is the mininal length of the English text and how much longer than the original it has to be before we shorten it:
$min_length = 20;
$cut_ratio = 3;

foreach $inDir (glob $inDirs) {
    ($corpus) = $inDir =~ m|(ParlaMint-[A-Z-]+)[\.-]|
	or die "Strange directory $inDir\n";
    $outCDir = "$outDir/$corpus-en.conllu";
    print STDERR "INFO: Doing $corpus ($inDir -> $outCDir)\n";
    unless (-e $outCDir) {
	print STDERR "INFO: Creating $outCDir\n";
	`mkdir $outCDir`
    }
    die "Can't find $outCDir\n" unless -e $outCDir;
    foreach $inYDir (glob "$inDir/*") {
	next unless ($year) = $inYDir =~ m|(\d\d\d\d)$|;
	# print STDERR "INFO: Doing $year\n";
	$outYDir = "$outCDir/$year";
	if (-e $outYDir) {`rm -f $outYDir/*.conllu`}
	else {
	    print STDERR "INFO: Creating $outYDir\n";
	    `mkdir $outYDir`
	}
	die "Can't find $outYDir\n" unless -e $outYDir;
	foreach $inFile (glob "$inYDir/*.conllu") {
	    ($fName) = $inFile =~ m|/([^/]+\.conllu)$|;
	    $fName =~ s|_|-en_| unless $fName =~ m|-en_|;
	    $outFile = "$outYDir/$fName";
	    print STDERR "INFO: Processing $inFile\n";
	    &cp($inFile, $outFile);
	    &validate($outFile) if $validate eq 'validate'
	}
    }
}

sub cp {
    my $inFile = shift;
    my $outFile = shift;
    my $src;
    my $trg;
    open(IN, '<:utf8', $inFile) or die;
    open(OUT, '>:utf8', $outFile) or die;
    $/ = "\n\n";
    while (<IN>) {
	$cut_text = &cut($_);
	$fixed_text = &fix($cut_text);
	print OUT $fixed_text;
    }
    close IN;
    close OUT;
}

sub cut {
    my $sent = shift;
    my $out;
    ($src) = $sent =~ /# source = (.+)/;
    ($trg) = $sent =~ /# text = (.+)/;
    #$src = &fix_usas($src);
    #$trg = &fix_usas($trg);
    $trg_str = substr($trg, 0, length($src) * $cut_ratio);
    $trg_str =~ s/(.+) .+/$1/;
    if ($trg_str !~ / /) {$out = $sent}
    elsif (length($trg) < $min_length) {$out = $sent}
    elsif (length($trg) < length($src) * $cut_ratio) {$out = $sent}
    elsif (($tail) = $trg =~ /\Q$trg_str\E(.+)/) {
	print STDERR "WARN: In $inFile\nSOURCE:\t$src\nLEAVING\t$trg_str\nCUTTING\t$tail\n\n";
	my $skip = 0;
	foreach my $line (split(/\n/, $sent)) {
	    if    ($line =~ /^# text = /) {
		$out .= "# text = $trg_str\n";
		$trg_str =~ s/ //g;
	    }
	    elsif ($line =~ /^#/) {$out .= "$line\n"}
	    elsif (($word) = $line =~ /^\d+\t(.+?)\t/) {
		$word =~ s/ //g;
		#$word = &fix_usas($word);
		if (not $trg_str) {$skip = 1}
		elsif ($trg_str =~ s/^\Q$word\E//) {
		    $line =~ s/\|?SpaceAfter=No//;
		    $out .= "$line\n"
		}
		elsif ($word =~ /^\Q$trg_str\E/) {
		    $skip = 1
		}
		else {die "FATAL: Out of synch on cut in \nTARGET:\t$trg_str\nWORD:\t$word\nLINE:\t$line\n"}
	    }
	}
	$out .= "\n"
    }
    else {$out = $sent}
    return $out;
}

sub fix {
    my $sent = shift;
    my @out = ();
    my ($id) = $sent =~ /# sent_id = (.+)/;
    my ($source) = $sent =~ /# source = (.+)/;
    my ($text) = $sent =~ /# text = (.+)/;
    # Fix PyUSAS bugs;
    #$id = &fix_usas($id);
    #$source = &fix_usas($source);
    #$text = &fix_usas($text);
    
    foreach my $line (split(/\n/, $sent)) {
	if ($line =~ /^#/) {
	    if    ($line =~ /# sent_id /) {push(@out, "# sent_id = $id")}
	    elsif ($line =~ /# source /)  {push(@out, "# source = $source")}
	    elsif ($line =~ /# text /)    {push(@out, "# text = $text")}
	    else {
		push(@out, $line);
		die "FATAL: unexpected metadata line $line\n"
	    }
	}
	elsif ($line =~ /\t/) {
            my ($n, $token, $lemma, $upos, $xpos, $ufeats, $link, $role, $extra, $local) 
		= split /\t/, $line;
	    #$token = &fix_usas($token);
	    #$lemma = &fix_usas($lemma);
	    die "FATAL: Out of synch in fix on $id / $n:$token in $text\n"
		unless $text =~ s/^\Q$token\E//;
	    $space = $text =~ s/^\s+//;
	    if (not $space and $local !~ /SpaceAfter=No/) {
		# print STDERR "WARN: fixing SpaceAfter for $id / $n:$token\n";
		$local .= '|SpaceAfter=No';
	    }
	    if ($ufeats ne '_') {
		my %feats;
		my @sorted_feats = ();
		foreach my $ufeat (split(/\|/, $ufeats)) {$feats{$ufeat}++}
		foreach my $ufeat (sort {lc($a) cmp lc($b)} keys %feats) {push(@sorted_feats, $ufeat)}
		$new_ufeats = join("|", @sorted_feats);
		if ($new_ufeats ne $ufeats) {
		    # print STDERR "WARN: sorting feats form '$ufeats' to '$new_ufeats'\n";
		    $ufeats = $new_ufeats
		}
	    }
	    push(@out, join("\t", ($n, $token, $lemma, $upos, $xpos, $ufeats, $link, $role, $extra, $local)));
	}
    }
    return join("\n", @out) . "\n\n";
}

sub validate {
    my $file = shift;
    # lang doesn't really matter here I think
    $error = `python3 $Valid --lang en --level 2 $file 2>&1`;
    @errors = ();
    foreach $e (split(/\n/, $error)) {
	next unless $e;
	#Get rid of expected errros and useless lines
	next if $e =~ /DEPREL/;
	next if $e =~ /^The following /;
	next if $e =~ /^acl, advcl, advmod, /;
	next if $e =~ /^If a language /;
	next if $e =~ /^must have a /;
	next if $e =~ /^See https:\/\/universaldependencies.org/;
	next if $e =~ /^Documented dependency relations /;
	next if $e =~ /^See https:\/\/quest.ms.mff.cuni.cz/;
	next if $e =~ /^...suppressing further errors /;
	next if $e =~ /^Syntax errors: /;
	next if $e =~ /^\*\*\* FAILED \*\*\*/;
	next if $e =~ /^\*\*\* PASSED \*\*\*/;
	push(@errors, $e);
    }
    if (@errors) {
	print STDERR "ERROR: CoNLL-U validation:\n" . join("\n", @errors) . "\n";
	return 1;
    }
    else {
	# print STDERR "INFO: CoNLL-U validation OK\n";
	return 0;
    }
}

sub fix_usas {
    my $str = shift;
    $str =~ s/\t//;
    if ($str eq '""""') {$str = '"'}
    elsif ($str =~ /""/) {
	$str =~ s/""/"/g;
	$str =~ s/^"//;
	$str =~ s/"$//;
    }
    return $str
}
