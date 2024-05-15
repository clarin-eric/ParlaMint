use XML::LibXML;
use Cwd qw(cwd);
use POSIX qw(strftime);
use Getopt::Long;
use FindBin qw($Bin);

GetOptions ( ## Command line options
		'debug' => \$debug, # debugging mode
		'test' => \$test, # tokenize to string, do not change the database
		'sub=s' => \$subc, # set which subcorpus to compile 'ParlaMint-XX'
		'name=s' => \$corpusname, # set which subcorpus to compile (not used)
		'setfile=s' => \$setfile, # alternative settings file
		);

$cwd = cwd;


$scriptname = $0;
( $pwd = $scriptname ) =~ s/\/[^\/]+$//;;

my $subcInterfix = $subc ? "-$subc" : "";

open FILE, ">tmp/recqp$subcInterfix.pid";$\ = "\n";

if ( $setfile ) {
	$setopt = " --settings='$setfile'"; 
	print FILE "Using shared $setfile";
} else {
	$setfile = "Resources/settings.xml";
};

if ( $corpusname ) {
	$setopt .= " --name='$corpusname' "; 
};

# Read the parameter set
my $settings = XML::LibXML->load_xml(
	location => $setfile,
); if ( !$settings ) { print FILE "Not able to parse settings.xml"; exit; };

if ( $settings->findnodes("//cqp/\@corpus") ) {
	$cqpcorpus = $settings->findnodes("//cqp/\@corpus")->item(0)->value."";
} else { print FILE "Cannot find corpus name"; exit; };

if ( $settings->findnodes("//cqp/defaults/\@registry") ) {
	$regfolder = $settings->findnodes("//cqp/defaults/\@registry")->item(0)->value."";
} else { $regfolder = "cqp"; };

# See if we should export subcorpora
if ( $settings->findnodes("//cqp/\@subcorpora") ) {
	$sub = $settings->findnodes("//cqp/\@subcorpora")->item(0)->value."";
} else { $sub = 0; };
if ( $settings->findnodes("//cqp/\@searchfolder") ) {
	$search = $settings->findnodes("//cqp/\@searchfolder")->item(0)->value."";
} else { $search = "xmlfiles"; };

if ( $settings->findnodes("//defaults/query/\@skip") ) {
	@skips = split(",",  $settings->findnodes("//defaults/query/\@skip")->item(0)->value."");
	for ( $i=0; $i<scalar @skips; $i++ ) {
		$toskip{$skips[$i]} = 1;
	};
};

$starttime = time(); 
print FILE 'Regeneration started on '.localtime();
print FILE 'Process id: '.$$;
print FILE 'LINDAT recqp settings';

if ( $subc ) {
	print FILE "Main corpus: $cqpcorpus";
	print FILE "Subcorpus: $subc";
	print FILE "CQP Corpus: $cqpcorpus-$subc";
	print FILE 'Removing the old files';
	print FILE "command:\n/bin/rm -f cqp/$subc/*";
	`/bin/rm -Rf cqp/$subc/*`;
} else {
	print FILE "CQP Corpus: $cqpcorpus\n";
	print FILE 'Removing the old files';
	print FILE "command:\n/bin/rm -f cqp/*";
	`/bin/rm -Rf cqp/*`;
};
	print FILE "$skipping";


if ( $sub ) {

	print "Dealing with subcorpora in $search";	

	while ( <$search/*> ) {
	
		$sf = $_; ( $fn = $sf ) =~ s/.*\///;
		if ( $subc && $fn ne $subc ) { next; };
		print "Creating subcorpus $fn";	

		$subcorpus = "$cqpcorpus-$fn";
		`mkdir cqp/$fn`;
		
		print FILE '----------------------';
		print FILE "(1) Encoding subcorpus $fn";
		$cmd = "$Bin/bin/tt-cwb-encode -r $regfolder --folder='$sf' --corpusfolder='cqp/$fn' --corpus='$subcorpus'  $setopt";
		print FILE "command:
		$cmd";
		`$cmd`;

		$cmd = "$Bin/bin/cwb-makeall  -r $regfolder ".uc($subcorpus);
		print FILE '----------------------';
		print FILE "(2) Creating subcorpus $fn";
		print FILE "command:
		$cmd";
		`$cmd`;

		if ( $toskip{'kontext'} ) {
			print FILE ' -- Skipping Kontext (due to settings)';
		} else {
			# Now also make the Manatee files and the Kontext corpus
			print FILE '----------------------';
			print FILE '(3) Creating the kontext/manatee corpus';
			$cmd = "perl $pwd/makemanatee.pl --sub=$fn $setopt ";
			print FILE "command:\n$cmd";
			print `$cmd`;
		};
		
		if ( $toskip{'pmltq'} ) {
			print FILE ' -- Skipping PMLTQ (due to settings)';
		} else {
			# If there is a @head, also make the Postgre files and the PMLTQ corpus
			if ( $settings->findnodes("//cqp/pattributes/item[\@key=\"head\"]") && $settings->findnodes("//cqp/sattributes/item[\@key=\"s\"]") ) {
				print FILE '----------------------';
				print FILE '(4) Creating the postgre/pmltq corpus';
				$cmd = "$Bin/bin/perl $pwd/teitok2pmltq.pl --sub=$fn $setopt";
				print FILE "command:\n$cmd";
				print `$cmd`;
			} else {
				print FILE '----------------------';
				print FILE 'PMLTQ corpus not create because of the corpus is not parsed (no head and/or s)';
			};
		};
		
# This is if we want both the subcorpora and the whole corpus
# 		if ( $sub eq 'both' ) {
# 			print FILE '----------------------';
# 			print FILE '(1) Encoding full corpus$';
# 			$cmd = "$Bin/bin/tt-cwb-encode -r $regfolder --corpusfolder='cqp/full' --corpus='$cqpcorpus'";
# 			print FILE "command:
# 			$cmd";
# 			`$cmd`;
# 
# 			print FILE '----------------------';
# 			print FILE '(2) Creating subcorpus $fn';
# 			print FILE "command:
# 			$Bin/bin/cwb-makeall  -r $regfolder $cqpcorpus";
# 			`$Bin/bin/cwb-makeall  -r $regfolder $cqpcorpus`;
# 		};

		$tmp = `wc -c cqp/$fn/word.corpus`;
		$ssize = $tmp/4; $, = "\t";
		$size += $ssize;

	};

} else {

	print "Creating single corpus";

	print FILE '----------------------';
	print FILE '(1) Encoding the corpus';
	$cmd = "$Bin/bin/tt-cwb-encode -r $regfolder $setopt";
	print FILE "command:\n$cmd";
	print `$cmd`;

	print FILE '----------------------';
	print FILE '(2) Creating the corpus';
	$cmd = "$Bin/bin/cwb-makeall  -r $regfolder $cqpcorpus";
	print FILE "command:\n$cmd";
	print `$cmd`;

	# Now also make the Manatee files and the Kontext corpus
	print FILE '----------------------';
	print FILE '(3) Creating the kontext/manatee corpus';
	$cmd = "perl $pwd/makemanatee.pl $setopt ";
	print FILE "command:\n$cmd";
	print `$cmd`;

	# Check if we are asked to export CoNLL-U
	if ( $settings->findnodes("//defaults/grew") || $settings->findnodes("//defaults/query/conllu") || -d "conllu" ) {
		$tttools = "/home/janssen/Git/teitok-tools";
		print FILE '----------------------';
		print FILE '(3b) Creating the CoNLL-U files';
		$cmd = "rm conllu/*";
		print FILE "command:\n$cmd";
		print `$cmd`;
		$cmd = "find xmlfiles -name '*.xml' -exec $Bin/bin/perl $tttools/Scripts/teitok2conllu.pl --outfolder=conllu {} \\;";
		print FILE "command:\n$cmd";
		print `$cmd`;
	} else {
		print FILE '----------------------';
		print FILE 'CoNLL-U export not specified';
	};

	# If there is a @head, also make the Postgre files and the PMLTQ corpus
	if ( $settings->findnodes("//cqp/pattributes/item[\@key=\"head\"]") ) {
		print FILE '----------------------';
		print FILE '(4) Creating the postgre/pmltq corpus';
		$cmd = "$Bin/bin/nice $Bin/bin/perl $pwd/teitok2pmltq.pl --sub=$fn $setopt ";
		print FILE "command:\n$cmd";
		print `$cmd`;
	} else {
		print FILE '----------------------';
		print FILE 'PMLTQ corpus not create because of the corpus is not parsed (no head)';
	};

	$tmp = `wc -c cqp/word.corpus`;
	$size = $tmp/4; $, = "\t";

};

print FILE '----------------------';
$endtime = time();
print FILE 'Regeneration completed on '.localtime();
close FILE;
`mv tmp/recqp$subcInterfix.pid tmp/recqp$subcInterfix.log`;

$starttxt = strftime("%Y-%m-%d", localtime($starttime));
$timelapse = $endtime - $starttime;
open FILE, ">>tmp/lastupdate.log";
print FILE $starttxt, $timelapse, $size, $subc;
close FILE;

