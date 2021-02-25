root:
	$s -xsl:Scripts/parlamint2root.xsl Scripts/ParlaMint-template.xml > ParlaMint.xml

#Make HTML
H = /project/corpora/Parla/ParlaMint/ParlaMint/
htm:	val-all
	Scripts/Stylesheets/bin/teitohtml --profiledir=$H --profile=profile \
	docs/ParlaMint-summary.xml docs/index.html
test-val:
	$s -xsl:Scripts/validate-parlamint.xsl ParlaMint-SI/ParlaMint-SI.xml
	$s -xsl:Scripts/validate-parlamint.xsl ParlaMint-SI/ParlaMint-SI.ana.xml
	$s -xsl:Scripts/validate-parlamint.xsl ParlaMint-SI/ParlaMint-SI_2014-08-25_SDZ7-Izredna-01.xml
	$s -xsl:Scripts/validate-parlamint.xsl ParlaMint-SI/ParlaMint-SI_2014-08-25_SDZ7-Izredna-01.ana.xml

## Testing "validating" tei2vert script
j = java -jar /usr/share/java/jing.jar 
pc = -I % $s -xi -xsl:Scripts/copy.xsl % | $j Schema/parla-clarin.rng
vrt = $j Schema/ParlaMint-teiCorpus.rng 	# Corpus root / text
vct = $j Schema/ParlaMint-TEI.rng		# Corpus component / text
vra = $j Schema/ParlaMint-teiCorpus.ana.rng	# Corpus root / analysed
vca = $j Schema/ParlaMint-TEI.ana.rng		# Corpus component / analysed

# Validate and produce char counts for 1 language
LANG = NL
PREF = /project/corpora/Parla/ParlaMint/ParlaMint
all-lang:	val-pc-lang val-lang chars-lang
xall-lang:	val-pc-lang val-lang vert-lang chars-lang
chars-lang:
	nice find ParlaMint-${LANG}/ -name '*.xml' | \
	$P --jobs 20 Scripts/chars.pl {} >> ParlaMint-${LANG}/chars-files-${LANG}.tbl
	Scripts/chars-summ.pl < ParlaMint-${LANG}/chars-files-${LANG}.tbl \
	> ParlaMint-${LANG}/chars-${LANG}.tbl
vert-lang:
	Scripts/parlamint-tei2vert.pl ParlaMint-${LANG}/ParlaMint-${LANG}.xml \
	'ParlaMint-${LANG}/*_*.xml' ParlaMint-${LANG}
val-lang:
	Scripts/validate-parlamint.pl Schema 'ParlaMint-${LANG}'
val-pc-lang:
	ls ParlaMint-${LANG}/ParlaMint-${LANG}.xml | xargs ${pc} 
	ls ParlaMint-${LANG}/ParlaMint-${LANG}.ana.xml | xargs ${pc}

# Validation for all corpora
# Parla-CLARIN validation
val-pc:
	ls ParlaMint-*/ParlaMint-*.xml | grep -v '.ana.' | grep -v '_' | xargs ${pc}
	ls ParlaMint-*/ParlaMint-*.xml | grep    '.ana.' | grep -v '_' | xargs ${pc}

nohup:
	nohup time make all > nohup.val &
all:	val-all
# ParlaMint validation
val-all:
	Scripts/validate-parlamint.pl Schema 'ParlaMint-*'

# ParlaMint validation with Jing only
val-jing:
	ls ParlaMint-*/ParlaMint-*.xml | grep -v '.ana.' | grep -v '_' | xargs ${vrt}
	ls ParlaMint-*/ParlaMint-*.xml | grep -v '.ana.' | grep    '_' | xargs ${vct}
	ls ParlaMint-*/ParlaMint-*.xml | grep    '.ana.' | grep -v '_' | xargs ${vra}
	ls ParlaMint-*/ParlaMint-*.xml | grep    '.ana.' | grep    '_' | xargs ${vca}

#Generate samples
test-cnv-si:
	$s outDir=ParlaMint-SI -xsl:Scripts/corpus2sample.xsl ../Master/ParlaMint-SI.TEI/ParlaMint-SI.xml
	$s outDir=ParlaMint-SI -xsl:Scripts/corpus2sample.xsl ../Master/ParlaMint-SI.TEI.ana/ParlaMint-SI.ana.xml

samples-v1:	clean-v1
	$s outDir=ParlaMint-BG -xsl:Scripts/corpus2sample.xsl ../Master/ParlaMint-BG.TEI/ParlaMint-BG.xml
	$s outDir=ParlaMint-BG -xsl:Scripts/corpus2sample.xsl ../Master/ParlaMint-BG.TEI.ana/ParlaMint-BG.ana.xml
	$s outDir=ParlaMint-HR -xsl:Scripts/corpus2sample.xsl ../Master/ParlaMint-HR.TEI/ParlaMint-HR.xml
	$s outDir=ParlaMint-HR -xsl:Scripts/corpus2sample.xsl ../Master/ParlaMint-HR.TEI.ana/ParlaMint-HR.ana.xml
	$s outDir=ParlaMint-PL -xsl:Scripts/corpus2sample.xsl ../Master/ParlaMint-PL.TEI/ParlaMint-PL.xml
	$s outDir=ParlaMint-PL -xsl:Scripts/corpus2sample.xsl ../Master/ParlaMint-PL.TEI.ana/ParlaMint-PL.ana.xml
	$s outDir=ParlaMint-SI -xsl:Scripts/corpus2sample.xsl ../Master/ParlaMint-SI.TEI/ParlaMint-SI.xml
	$s outDir=ParlaMint-SI -xsl:Scripts/corpus2sample.xsl ../Master/ParlaMint-SI.TEI.ana/ParlaMint-SI.ana.xml
clean-v1:
	rm -f ParlaMint-BG/*.xml
	rm -f ParlaMint-HR/*.xml
	rm -f ParlaMint-PL/*.xml
	rm -f ParlaMint-SI/*.xml

################################################
s = java -jar /usr/share/java/saxon.jar
P = parallel --gnu --halt 2
