#!/usr/bin/perl
# Copy CoNLL-U files to official distribution directories
# and shorten too long translations
use warnings;
use utf8;
use open ':utf8';
use FindBin qw($Bin);
binmode(STDERR, ':utf8');
$validate = shift;
$inDirs = shift;
$outDir = shift;
    
# How much longer the English text can be before we shorten it:
$min_length = 20;
$cut_ratio = 3;

# Change to where tools is installed on local system
# Source: https://github.com/universaldependencies/tools
$Valid = "/usr/local/tools/validate.py";

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
	    &fix($inFile, $outFile)
	}
    }
}
sub fix {
    my $inFile = shift;
    my $outFile = shift;
    my $src;
    my $trg;
    open(IN, '<:utf8', $inFile) or die;
    open(OUT, '>:utf8', $outFile) or die;
    $/ = "\n\n";
    while (<IN>) {
	($src) = /# source = (.+)/;
	($trg) = /# text = (.+)/;
	$trg_str = substr($trg, 0, length($src) * $cut_ratio);
	$trg_str =~ s/(.+) .+/$1/;
	if ($trg_str !~ / /) {print OUT}
	elsif (length($trg) < $min_length) {print OUT}
	elsif (length($trg) < length($src) * $cut_ratio) {print OUT}
	elsif (($tail) = $trg =~ /\Q$trg_str\E(.+)/) {
	    print STDERR "WARN: In $inFile\nSOURCE:\t$src\nLEAVING\t$trg_str\nCUTTING\t$tail\n\n";
	    my $skip = 0;
	    foreach my $line (split(/\n/, $_)) {
		if    ($line =~ /^# text = /) {
		    print OUT "# text = $trg_str\n";
		    $trg_str =~ s/ //g;
		}
		elsif ($line =~ /^#/) {print OUT "$line\n"}
		elsif (($word) = $line =~ /^\d+\t(.+?)\t/) {
		    $word =~ s/ //g;
		    if (not $trg_str) {$skip = 1}
		    elsif ($trg_str =~ s/^\Q$word\E//) {
			$line =~ s/\|?SpaceAfter=No//;
			print OUT "$line\n"
		    }
		    elsif ($word =~ /^\Q$trg_str\E/) {
			$skip = 1
		    }
		    else {die "FATAL: out of synch\nTARGET:\t$trg_str\nWORD:\t$word\nLINE:\t$line\n"}
		}
	    }
	    print OUT "\n"
	}
	else {print OUT}
    }
    close IN;
    close OUT;
    if ($validate eq 'validate') {
	print STDERR "INFO: Validating $outFile\n";
	# lang doesn't really matter here I think
	$error = `python3 $Valid --lang en --level 1 $outFile`;
	print STDERR "INFO: tools validation says $error\n";
	    
    }
}
