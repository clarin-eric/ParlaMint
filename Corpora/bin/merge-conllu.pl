#!/usr/bin/perl
# Merge per-language translated CoNLL-Us to joint CoNLL-Us
use warnings;
use utf8;
use open ':utf8';
$inJointDir = shift;
$inMTDir = shift;
binmode(STDERR, ':utf8');
foreach $jointFile (glob "$inJointDir/*/*.conllu") {
    next if $jointFile =~ /-[a-z]+\.conllu$/; #Skip over per-language files
    ($year, $fileName) = $jointFile =~ m|/(\d\d\d\d)/(.+)\.conllu|;
    @langFiles = glob("$inMTDir/$year/$fileName-*\.conllu");
    ($lang1) = $langFiles[0] =~ m|$fileName-(..)\.conllu|;
    ($lang2) = $langFiles[1] =~ m|$fileName-(..)\.conllu|;
    die "Huh: ". scalar(@langFiles) . "\n" unless scalar(@langFiles) == 2;
    $outFile = "$inMTDir/$year/$fileName.conllu";
    print STDERR "INFO: processing $year/$fileName\n";
    # die "InFile: $jointFile\nMT1: $langFiles[0]\nMT2: $langFiles[1]\nOut: $outFile\n";
    $/ = "\n\n";
    @ids = ();
    open(TBL, '<:utf8', $jointFile);
    while (<TBL>) {
	if (($id) = m|# sent_id = (.+)\n|) {
	    $orig{$id} = $_; # Store original sentence
	    push(@ids, $id);
	}
    }
    close TBL;
    open(IN1, '<:utf8', $langFiles[0]);
    while (<IN1>) {push(@in1, $_)}
    close IN1;
    open(IN2, '<:utf8', $langFiles[1]);
    while (<IN2>) {push(@in2, $_)}
    close IN2;
    open(OUT, '>:utf8', $outFile);
    $sent1 = shift(@in1);
    $sent2 = shift(@in2);
    foreach $id (@ids) {
	# The ID is neither in one CoNLL-U nor the other 
	# an error in source data, e.g. ES-CT has some <p xml:lang="en">
	if ((not($sent1) or $sent1 !~ m|# sent_id = $id\n|) and
	    (not($sent2) or $sent2 !~ m|# sent_id = $id\n|)) {
	    print STDERR "ERROR: can't find $id in MTed CoNLL-U!\n";
	    $sent = $orig{$id};
	    $sent =~ s|# newdoc .+\n||;
	    $sent =~ s|# newpar .+\n||;
	    $sent =~ s|(# sent_id = .+\n)|$1# source_lang = xx\n|;
	    $sent =~ s|# text = (.+)\n|# source = $1\n# text = $1\n|;
	    $sent =~ s|# lang = .+\n||;
	    # Need to get rid of syntactic annotations
	    my $sent_nosyn = '';
	    my $i = 0;
	    foreach my $line (split /\n/, $sent) {
		if ($line =~ /\t/) {
	            my ($n, $token, $lemma, $upos, $xpos, $ufeats, $link, $role, $extra, $local) 
			= split /\t/, $line;
		    $link = $i++; #This is how taja has it, don't know why
		    $role = '_';
		    $line = join("\t", ($n, $token, $lemma, $upos, $xpos, $ufeats, $link, $role, $extra, $local));
		}
		$sent_nosyn .= "$line\n"
	    }
	    print OUT "$sent_nosyn\n";
	}
	elsif ($sent1 and $sent1 =~ m|# sent_id = $id\n|) {
	    $sent1 =~ s|# source = |# source_lang = $lang1\n# source = |;
	    print OUT $sent1;
	    $sent1 = shift(@in1) if @in1;
	}
	elsif ($sent2 and $sent2 =~ m|# sent_id = $id\n|) {
	    $sent2 =~ s|# source = |# source_lang = $lang2\n# source = |;
	    print OUT $sent2;
	    $sent2 = shift(@in2) if @in2;
	}
	elsif (not $sent1) {die "FATAL: no more sentences for $langFiles[0]\n"}
	elsif (not $sent2) {die "FATAL: no more sentences for $langFiles[1]\n"}
	else {die "WHAT!?!?\n"}
    }
    close OUT;
    die "FATAL: Left over sentences in $langFiles[0]\n" if @in1;
    die "FATAL: Left over sentences in $langFiles[1]\n" if @in2;
}

