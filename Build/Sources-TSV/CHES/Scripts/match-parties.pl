#!/usr/bin/perl -w
use utf8;
use Text::Unidecode;
$country_list = shift;
$mapFile = shift;
$pmntFiles = shift;
$chesFiles = shift;
$outDir = shift;
binmode(STDIN,'utf8');
binmode(STDOUT,'utf8');
binmode(STDERR,'utf8');


foreach $country (split / /, $country_list) {
    $ok_country{$country}++
}

# Slurp party mapping file; there can be several parlamint parties per ches party!
open(TBL, '<:utf8', $mapFile) or die "FATAL: can't file map file $mapFile\n";
while (<TBL>) {
    next if /^country/i or not /\t/;
    chomp;
    my ($c, $ches, $pm) = split /\t/;
    next unless exists $ok_country{$c};
    if (exists $party_map{$c}{$ches}) {$party_map{$c}{$ches} .= " + $pm"}
    else {$party_map{$c}{$ches} = $pm}
}
close TBL;

# Make hash of country with filename values for ParlaMint party files
foreach my $pmntFile (glob($pmntFiles)) {
    ($country) = $pmntFile =~ /-(.+)\....$/ or die "FATAL: bad filename $pmntFile\n";
    $pmntFile{$country} = $pmntFile;
}

# Make hash of country with filename values for CHES party orientation files
foreach my $chesFile (glob($chesFiles)) {
    ($country) = $chesFile =~ /-([A-Z]{2})-CHES\.tsv/ or die "FATAL: bad filename $chesFile\n";
    $chesFile{$country} = $chesFile
}

$all = 0;
$ok = 0;
foreach $country (sort keys %chesFile) {
    next unless $country_list eq 'all' or exists $ok_country{$country};
    #Not all CHES countries are currently(!) present in ParlaMint
    next unless exists $pmntFile{$country};
    print STDERR "INFO: Processing $country\n";
    $outFile  = "$outDir/Orientation-$country.CHES.tsv";
    $chesFile = $chesFile{$country};
    $pmntFile = $pmntFile{$country};
    #print STDERR "INFO: Processing $country ($chesFile + $pmntFile = $outFile)\n";

    #Gather all party abbreviations for country in abbr_xx hash; more than one party can have same abbrev!
    open(TBL, '<:utf8', $pmntFile) or die "FATAL: can't file $pmntFile\n";
    undef %abbr_xx;
    while (<TBL>) {
	chomp;
	next if /^country/i or not /\t/;
	my ($c, $type, $id, $abbr_xx) = split /\t/;
	die "FATAL: country $c != $country" unless $c eq $country;
	if (not($abbr_xx) or $abbr_xx eq '-') {
	    if ($id =~ /\./) {($abbr_new) = $id =~ /.*\.(.+)/}
	    else {$abbr_new = $id}
	    # print STDERR "WARN: Empty party abbrev of $c party $id, changing to $abbr_new\n";
	    $abbr_xx = $abbr_new
	}
	if (exists $abbr_xx{$abbr_xx}) {
	    $abbr_xx{$abbr_xx} .= " + $id";
	    print STDERR "WARN: Duplicate party abbrev of $c party $abbr_xx = $abbr_xx{$abbr_xx}\n"
	}
	else {
	    $abbr_xx{$abbr_xx} = $id
	}
    }
    close TBL;
    
    open(OUT, '>:utf8', $outFile) or die "Can't find output file $outFile\n";
    undef %found; #ParlaMint parties found in CHES, key is abbr, value is id
    
    open(IN, '<:utf8', $chesFile) or die "Can't find CHES file $chesFile\n";
    while (<IN>) {
	next unless /\t/;
	if (/^country/i) {
	    s/country\tparty/country\tpm_party\tches_party/;
	    print OUT;
	    next
	}
	chomp;
	($c, $ches_id, $rest) = /^(.*?)\t(.*?)\t(.*?)\t(.+)$/;
	die "FATAL: bad country $c instead of $country\n"
	    unless $c eq $country;

	$all++ unless $seen{"$country\t$ches_id"};
	$seen{$ches_id} = $rest;

	#ParlaMint abbrs found for this $ches_id
	#There can be more than one!
	@maps = ();
	foreach $party_abbrs (sort keys %abbr_xx) {
	    foreach $party_abbr (split/ \+ /, $party_abbrs) {
		#Reduced to ASCII very sloppily
		$party_ascii = unidecode($party_abbr);
		$party_uc = uc($party_ascii);
		$party_short = $party_ascii;
		$party_short =~ s/-.$//;
		$party_short =~ s/[[:punct:]]+$//;
		# e.g. politicalGroup.ANO.1108 -> ANO
		$party_id = $abbr_xx{$party_abbr};
		$party_id =~ s/ \+.+//; #If multiple IDs, retain only first
		$party_id =~ s/.+?\.//;
		$party_id =~ s/\..+//;
		
		die "FATAL: can't find CHES ID $ches_id for country $c\n"
		    unless exists $party_map{$c}{$ches_id};
		
		if ($party_map{$c}{$ches_id} eq $party_abbr or
		    $party_map{$c}{$ches_id} =~ /^\Q$party_abbr\E / or
		    $party_map{$c}{$ches_id} =~ / \Q$party_abbr\E$/ or
		    $party_map{$c}{$ches_id} =~ / \Q$party_abbr\E /
		    #or 
		    # $party_map{$c}{$ches_id} eq $party_ascii or
		    # $party_map{$c}{$ches_id} eq $party_uc or
		    # $party_map{$c}{$ches_id} eq $party_short or
		    # $party_map{$c}{$ches_id} eq $party_id
		    ) {
		    #print STDERR "INFO: Mapping $c $ches_id to $party_abbr via mapfile\n";
		    push(@maps, $party_abbrs)
		}
		elsif ($ches_id eq $party_abbr or 
		       $ches_id eq $party_ascii or
		       $ches_id eq $party_uc or
		       $ches_id eq $party_short or
		       $ches_id eq $party_id) {
		    print STDERR "INFO: Mapping $c CHES $ches_id to ParlaMint $party_abbrs via heuristics\n";
		    push(@maps, $party_abbr)
		}
	    }
	}
	
	if (exists($maps[1])) {
	    $pm_abbr = join(" + ", @maps);
	    print STDERR "WARN: Multiple party match on $country CHES $ches_id = ParlaMint $pm_abbr\n";
	    foreach my $abbr (@maps) {
		print OUT join("\t", $country, $pm_abbr, $ches_id, $rest) . "\n";
		$found{$abbr}++;
	    }
	    $ok++;
	}
	elsif (exists($maps[0])) {
	    $pm_abbr = $maps[0];
	    #print STDERR "INFO: match ParlaMint $country $pm_abbr on CHES $ches_id\n";
	    print OUT join("\t", $country, $pm_abbr, $ches_id, $rest) . "\n";
	    $found{$pm_abbr}++;
	    $ok++;
	}
	else {
	    $pm_abbr = 0;
	    print OUT join("\t", $country, $pm_abbr, $ches_id, $rest) . "\n";
	}
	
    }
    foreach $pm_abbr (sort keys %abbr_xx) {
	unless (exists $found{$pm_abbr}) {
	    $rest_n = $rest =~ /\t/g;
	    print OUT join("\t", $country, $pm_abbr, '-');
	    while ($rest_n > -1) {
		print OUT "\t-";
		$rest_n--;
	    }
	    print OUT "\n"
	}
    }
    close IN;
    close OUT;
}
print STDERR "ALL $all, OK $ok\n";
