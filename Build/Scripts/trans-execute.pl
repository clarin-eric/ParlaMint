#!/usr/bin/env perl
use warnings;
use utf8;
use FindBin qw($Bin);
#use File::Spec;
use Lingua::Translit;
use File::Temp qw/ tempfile tempdir /;  #creation of tmp files and directory
my $tempdirroot = "$Bin/tmp";
my $tmpDir = tempdir(DIR => $tempdirroot, CLEANUP => 1);

$inFile = shift;
$outFile = shift;

#$standard{'BG'} = 'DIN 1460 BUL'; #Not ideal, lots of diacritics in transliterated text
$standard{'BG'} = 'Streamlined System BUL';
$standard{'GR'} = 'ISO 843';
$standard{'UA'} = 'DIN 1460 UKR'; #Also possible: GOST 7.79 UKR
# We could also de-deacriticise other langauges:
# use Text::Unidecode;
# print unidecode('ä, ö, ü, é'); # will print 'a, o, u, e'

$Saxon   = "java -jar $Bin/bin/saxon.jar";

# Scripts that transliterate metadata
my $trans2tsvScript = "$Bin/trans-tei2tsv.xsl";
my $trans2teiScript = "$Bin/trans-tsv2tei.xsl";

($country) = $inFile =~ /ParlaMint-([A-Z-]+)/
    or die "FATAL: Cant find country in $inFile\n";

&translit($country, $inFile, $outFile);

sub translit {
    my $country = shift;
    my $inFile = shift;
    my $outFile = shift;
    if ( (($country eq 'BG' or $country eq 'GR' or $country eq 'UA') and $inFile =~ /listPerson/) or
         (($country eq 'BG' or $country eq 'GR' ) and $inFile =~ /listOrg/)
	) {
	my $inTSVFile = "$tmpDir/$country-in.tsv";
	my $outTSVFile = "$tmpDir/$country-out.tsv";
	print STDERR "INFO: transliterating $country with $standard{$country}\n";
	my $command = "$Saxon -xsl:$trans2tsvScript $inFile > $inTSVFile";
	`$command`;
	
	$tr = new Lingua::Translit($standard{$country});
	open(IN,  '<:utf8', $inTSVFile);
	open(OUT, '>:utf8', $outTSVFile);
	while (<IN>) {
	    chomp;
	    $trans = $tr->translit($_);
	    print OUT join("\t", $_, $trans) . "\n";
	}
	close IN;
	close OUT;
	
	$command = "$Saxon tsv=$outTSVFile -xsl:$trans2teiScript $inFile > $outFile";
	`$command`;
    }
    else {
	print STDERR "INFO: copying $country (nothing to transliterate)\n";
	`cp $inFile $outFile`
    }
}
