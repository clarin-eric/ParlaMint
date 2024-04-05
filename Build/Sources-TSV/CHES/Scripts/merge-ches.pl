#!/usr/bin/perl -w
# Prepare CHES TSV files for inclusion into ParlaMint:
# - merge CHES versions 1999-2019 and 2019 variables
# - include in columns which CHES survey version this is
# - insert ParlaMint name of party (from $mapFile), incl. those not in CHES
use utf8;
$mapFile = shift;
$inFiles = shift;
$outDir = shift;
binmode(STDOUT,'utf8');
binmode(STDERR,'utf8');
use Scalar::Util qw(looks_like_number);

# All columns in the order in which they are output
@header = ('ches_survey', 
           'country',
           'parlamint',
           'party_id', 'party', 'year', 
	   'lrgen', 'lrecon', 'lrecon_blur', 'lrecon_dissent', 'lrecon_salience', 'lrecon_sd',
	   'anti_islam_rhetoric', 'antielite_salience',
	   'civlib_laworder', 'civlib_salience', 'cmp_id', 'corrupt_salience',
	   'cosmo', 'cosmo_salience',
	   'dereg_salience', 'deregulation',
	   'eastwest', 'econ_interven', 'electionyear', 'enviro_salience', 'environment', 'epvote',
	   'ethnic_minorities', 'ethnic_salience',
	   'eu_agri', 'eu_asylum', 'eu_benefit', 'eu_blur', 'eu_budgets', 'eu_cohesion', 'eu_dissent',
	   'eu_econ_require', 'eu_employ', 'eu_environ', 'eu_ep', 'eu_fiscal', 'eu_foreign', 'eu_googov_require',
	   'eu_intmark', 'eu_political_require', 'eu_position', 'eu_position_sd', 'eu_salience', 'eu_turkey', 'eumember',
	   'expert',
	   'family',
	   'galtan', 'galtan_blur', 'galtan_dissent', 'galtan_salience', 'galtan_sd', 'govt',
	   'immigrate_dissent', 'immigrate_policy', 'immigrate_salience', 'international_salience', 'international_security',
	   'members_vs_leadership',
	   'mip_one', 'mip_two', 'mip_three',
	   'multicult_dissent', 'multicult_salience', 'multiculturalism',
	   'nationalism',
	   'people_vs_elite', 'protectionism',
	   'redist_salience', 'redistribution', 'region_salience', 'regions',
	   'relig_salience', 'religious_principles', 'russian_interference',
	   'seat', 'social_salience', 'sociallifestyle', 'spendvtax', 'spendvtax_salience',
	   'urban_rural', 'urban_salience', 'us', 'us_salience',
	   'vote',
           'chesversion'
    );

# Slurp party mapping file
open(TBL, '<:utf8', $mapFile) or die "FATAL: can't file map file $mapFile\n";
while (<TBL>) {
    next if /^country/i or not /\t/;
    chomp;
    my ($country, $ches, $year, $pm) = split /\t/;
    # No such party in CHES
    if ($ches eq '-') {$party_white{$country}{$pm}++}
    else {
	die "FATAL: two instances of $country $year $ches!\n"
	    if exists $party_map{$country}{$year}{$ches};
	$party_map{$country}{$year}{$ches} = $pm
    }
}
close TBL;

foreach my $inFile (glob($inFiles)) {
    #e.g. CHES-AT-1999-2019.tsv, CHES-IS-2019.tsv
    ($country, $ches_survey) = $inFile =~ m|CHES-([A-Z]{2})-(.+)\.|
        or die "FATAL: bad inFile $inFile\n";
    $fName = "CHES-$country.tsv";
    print STDERR "INFO: processing $fName\n";
    open(IN, '<:utf8', $inFile);
    $outFile = "$outDir/$fName";
    open(OUT, '>:utf8', $outFile);
    print OUT join("\t", @header) . "\n";
    $first = 1;
    undef %output;
    while (<IN>) {
	next unless /\t/;
	chomp;
	if ($first) {
	    @columns = split(/\t/);
	    $first = 0;
	    next
	}
	@row = split(/\t/);
	$i = 0;
	undef %cell;
	foreach $cell (@row) {
	    $label = $columns[$i++];
	    #print STDERR "$label = $cell\n";
	    $cell{$label} = $cell
	}
	@row = ();
	foreach $label (@header) {
            if ($label eq 'ches_survey') {push(@row, $ches_survey)}
            elsif ($label eq 'parlamint') {
                if (exists $party_map{$country}{$cell{'year'}}{$cell{'party'}}) {
                    $cell{'parlamint'} = $party_map{$country}{$cell{'year'}}{$cell{'party'}};
                }
                else {
                    print STDERR "WARN: Can't find mapping to ParlaMint for ";
                    print STDERR "country $country, party $cell{'party'}, year $cell{'year'}\n";
                    $cell{'parlamint'} = '-'
                }
                push(@row, $cell{'parlamint'});
            }
	    elsif (not(exists $cell{$label} and $cell{$label} ne '')) {push(@row, '-')}
	    elsif (looks_like_number($cell{$label}) and $cell{$label} =~ /\.\d/) {
		push(@row, sprintf('%.1f', $cell{$label}))
	    }
	    else {push(@row, $cell{$label})}
	}
        $key = $cell{'parlamint'} . "\t" . $cell{'year'};
        if (exists $output{$key}) {$output{$key} .= "\n" . join("\t", @row)}
        else {$output{$key} = join("\t", @row)}
    }
    close IN;
    #Output PM parties without CHES equivalent
    foreach my $pm (sort keys %{$party_white{$country}}) {
        @row = ();
        foreach my $label (@header) {
            if ($label eq 'country') {push(@row, $country)}
            elsif ($label eq 'parlamint') {push(@row, $pm)}
            else {push(@row, '-')}
        }
	$output{$pm} = join("\t", @row)
    }
    # Output sorted by parlamint name + year
    foreach $key (sort keys %output) {
        print OUT "$output{$key}\n"
    }
    close OUT;
}
