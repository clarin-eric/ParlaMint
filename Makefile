#Now that we have plain text, would be better to compute char counts from those!
chars:
	rm -f ParlaMint-BG/chars-files-BG.tbl
	ls ParlaMint-BG/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'Scripts/chars.pl {} >> ParlaMint-BG/chars-files-BG.tbl'
	Scripts/chars-summ.pl < ParlaMint-BG/chars-files-BG.tbl > ParlaMint-BG/chars-BG.tbl

	rm -f ParlaMint-CZ/chars-files-CZ.tbl
	ls ParlaMint-CZ/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'Scripts/chars.pl {} >> ParlaMint-CZ/chars-files-CZ.tbl'
	Scripts/chars-summ.pl < ParlaMint-CZ/chars-files-CZ.tbl > ParlaMint-CZ/chars-CZ.tbl

	rm -f ParlaMint-HR/chars-files-HR.tbl
	ls ParlaMint-HR/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'Scripts/chars.pl {} >> ParlaMint-HR/chars-files-HR.tbl'
	Scripts/chars-summ.pl < ParlaMint-HR/chars-files-HR.tbl > ParlaMint-HR/chars-HR.tbl

	rm -f ParlaMint-IS/chars-files-IS.tbl
	ls ParlaMint-IS/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'Scripts/chars.pl {} >> ParlaMint-IS/chars-files-IS.tbl'
	Scripts/chars-summ.pl < ParlaMint-IS/chars-files-IS.tbl > ParlaMint-IS/chars-IS.tbl

	rm -f ParlaMint-PL/chars-files-PL.tbl
	ls ParlaMint-PL/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'Scripts/chars.pl {} >> ParlaMint-PL/chars-files-PL.tbl'
	Scripts/chars-summ.pl < ParlaMint-PL/chars-files-PL.tbl > ParlaMint-PL/chars-PL.tbl

	rm -f ParlaMint-SI/chars-files-SI.tbl
	ls ParlaMint-SI/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'Scripts/chars.pl {} >> ParlaMint-SI/chars-files-SI.tbl'
	Scripts/chars-summ.pl < ParlaMint-SI/chars-files-SI.tbl > ParlaMint-SI/chars-SI.tbl
texts:
	ls ParlaMint-BG/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s -xsl:Scripts/parlamint-tei2text.xsl {} > ParlaMint-BG/{/.}.txt'
	ls ParlaMint-CZ/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s -xsl:Scripts/parlamint-tei2text.xsl {} > ParlaMint-CZ/{/.}.txt'
	ls ParlaMint-HR/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s -xsl:Scripts/parlamint-tei2text.xsl {} > ParlaMint-HR/{/.}.txt'
	ls ParlaMint-IS/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s -xsl:Scripts/parlamint-tei2text.xsl {} > ParlaMint-IS/{/.}.txt'
	ls ParlaMint-PL/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s -xsl:Scripts/parlamint-tei2text.xsl {} > ParlaMint-PL/{/.}.txt'
	ls ParlaMint-SI/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s -xsl:Scripts/parlamint-tei2text.xsl {} > ParlaMint-SI/{/.}.txt'
verts:
	Scripts/parlamint-tei2vert.pl ParlaMint-BG/ParlaMint-BG.ana.xml \
	'ParlaMint-BG/*_*.ana.xml' ParlaMint-BG
	Scripts/parlamint-tei2vert.pl ParlaMint-CZ/ParlaMint-CZ.ana.xml \
	'ParlaMint-CZ/*_*.ana.xml' ParlaMint-CZ
	Scripts/parlamint-tei2vert.pl ParlaMint-HR/ParlaMint-HR.ana.xml \
	'ParlaMint-HR/*_*.ana.xml' ParlaMint-HR
	Scripts/parlamint-tei2vert.pl ParlaMint-IS/ParlaMint-IS.ana.xml \
	'ParlaMint-IS/*_*.ana.xml' ParlaMint-IS
	Scripts/parlamint-tei2vert.pl ParlaMint-PL/ParlaMint-PL.ana.xml \
	'ParlaMint-PL/*_*.ana.xml' ParlaMint-PL
	Scripts/parlamint-tei2vert.pl ParlaMint-SI/ParlaMint-SI.ana.xml \
	'ParlaMint-SI/*_*.ana.xml' ParlaMint-SI

#Make ParlaMint corpus root
root:
	$s -xsl:Scripts/parlamint2root.xsl Scripts/ParlaMint-template.xml > ParlaMint.xml

#Make HTML, not yet operative
H = /project/corpora/Parla/ParlaMint/ParlaMint/
htm:	val-all
	Scripts/Stylesheets/bin/teitohtml --profiledir=$H --profile=profile \
	docs/ParlaMint-summary.xml docs/index.html

test-val:
	$s -xsl:Scripts/validate-parlamint.xsl ParlaMint-SI/ParlaMint-SI.xml
	$s -xsl:Scripts/validate-parlamint.xsl ParlaMint-SI/ParlaMint-SI.ana.xml
	$s -xsl:Scripts/validate-parlamint.xsl ParlaMint-SI/ParlaMint-SI_2014-08-25_SDZ7-Izredna-01.xml
	$s -xsl:Scripts/validate-parlamint.xsl ParlaMint-SI/ParlaMint-SI_2014-08-25_SDZ7-Izredna-01.ana.xml

# Validate and produce char counts for 1 language
LANG = HR
PREF = /project/corpora/Parla/ParlaMint/ParlaMint
all-lang:	val-pc-lang val-lang vertana-lang text-lang chars-lang
xall-lang:	val-pc-lang val-lang vert-lang vertana-lang text-lang chars-lang
chars-lang:
	rm -f ParlaMint-${LANG}/chars-files-${LANG}.txt
	rm -f ParlaMint-${LANG}/*.tmp
	nice find ParlaMint-${LANG}/ -name '*.txt' | \
	$P --jobs 20 'cut -f2 {} > {.}.tmp'
	nice find ParlaMint-${LANG}/ -name '*.tmp' | \
	$P --jobs 20 'Scripts/chars.pl {} >> ParlaMint-${LANG}/chars-files-${LANG}.tbl'
	Scripts/chars-summ.pl < ParlaMint-${LANG}/chars-files-${LANG}.tbl \
	> ParlaMint-${LANG}/chars-${LANG}.tbl
	rm -f ParlaMint-${LANG}/*.tmp
text-lang:
	ls ParlaMint-${LANG}/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s -xsl:Scripts/parlamint-tei2text.xsl {} > ParlaMint-${LANG}/{/.}.txt'
vertana-lang:
	Scripts/parlamint-tei2vert.pl ParlaMint-${LANG}/ParlaMint-${LANG}.ana.xml \
	'ParlaMint-${LANG}/*_*.ana.xml' ParlaMint-${LANG}
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
nohup:
	nohup time make all > nohup.val &
all:	val-all

# ParlaMint validation
val-all:
	Scripts/validate-parlamint.pl Schema 'ParlaMint-*'

# ParlaMint validation with Jing only
val-jing:
	ls ParlaMint-*/ParlaMint-*.xml | grep -v '.ana.' | grep -v '_' | xargs ${pc}
	ls ParlaMint-*/ParlaMint-*.xml | grep    '.ana.' | grep -v '_' | xargs ${pc}
	ls ParlaMint-*/ParlaMint-*.xml | grep -v '.ana.' | grep -v '_' | xargs ${vrt}
	ls ParlaMint-*/ParlaMint-*.xml | grep -v '.ana.' | grep    '_' | xargs ${vct}
	ls ParlaMint-*/ParlaMint-*.xml | grep    '.ana.' | grep -v '_' | xargs ${vra}
	ls ParlaMint-*/ParlaMint-*.xml | grep    '.ana.' | grep    '_' | xargs ${vca}
clean:
	rm -f ParlaMint-*/*.xml

################################################
s = java -jar /usr/share/java/saxon.jar
P = parallel --gnu --halt 2
j = java -jar /usr/share/java/jing.jar 
pc = -I % $s -xi -xsl:Scripts/copy.xsl % | $j Schema/parla-clarin.rng
vrt = $j Schema/ParlaMint-teiCorpus.rng 	# Corpus root / text
vct = $j Schema/ParlaMint-TEI.rng		# Corpus component / text
vra = $j Schema/ParlaMint-teiCorpus.ana.rng	# Corpus root / analysed
vca = $j Schema/ParlaMint-TEI.ana.rng		# Corpus component / analysed
