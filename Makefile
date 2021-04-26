#Dump all parties in TSV file
parties:
	$s -xsl:Scripts/parlamint-parties.xsl ParlaMint.xml > Metadata/ParlaMint-parties.tsv
	$s -xsl:Scripts/parlamint-coaloppo.xsl ParlaMint.xml > Metadata/ParlaMint-coaloppo.tsv
#Make ParlaMint corpus root
root:
	$s -xsl:Scripts/parlamint2root.xsl Scripts/ParlaMint-template.xml > ParlaMint.xml
	$s -xsl:Scripts/parlamint2root.xsl Scripts/ParlaMint-template.ana.xml > ParlaMint.ana.xml

# Validate and derive formats for 1 language
LANG = CZ
PREF = /project/corpora/Parla/ParlaMint/ParlaMint
all-lang:	all-lang-tei all-lang-ana
all-lang-tei:	val-pc-lang val-lang text-lang meta-lang chars-lang
all-lang-ana:	vertana-lang conllu-lang
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
meta-lang:
	ls ParlaMint-${LANG}/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s hdr=../ParlaMint-${LANG}/ParlaMint-${LANG}.xml -xsl:Scripts/parlamint2meta.xsl \
	{} > ParlaMint-${LANG}/{/.}-meta.tsv'
conllu-lang:
	Scripts/parlamint2conllu.pl ParlaMint-${LANG} ParlaMint-${LANG}

vertana-lang:
	Scripts/parlamint-tei2vert.pl ParlaMint-${LANG}/ParlaMint-${LANG}.ana.xml ParlaMint-${LANG}
val-lang:
	Scripts/validate-parlamint.pl Schema 'ParlaMint-${LANG}'
val-pc-lang:
	ls ParlaMint-${LANG}/ParlaMint-${LANG}.xml | xargs ${pc} 
	ls ParlaMint-${LANG}/ParlaMint-${LANG}.ana.xml | xargs ${pc}


#Generation and validation of all CoNLL-U files
#If you want to use, first do:
#$ cd Scripts; git clone git@github.com:UniversalDependencies/tools.git
nohup-conllu:
	nohup time make conllu &
conllu:
	rm -f ParlaMint-??/*.conllu
	Scripts/parlamint2conllu.pl ParlaMint-BE ParlaMint-BE 2> ParlaMint-BE/ParlaMint-BE.conllu.log
	Scripts/parlamint2conllu.pl ParlaMint-BG ParlaMint-BG 2> ParlaMint-BG/ParlaMint-BG.conllu.log
	Scripts/parlamint2conllu.pl ParlaMint-CZ ParlaMint-CZ 2> ParlaMint-CZ/ParlaMint-CZ.conllu.log
	Scripts/parlamint2conllu.pl ParlaMint-DK ParlaMint-DK 2> ParlaMint-DK/ParlaMint-DK.conllu.log
	Scripts/parlamint2conllu.pl ParlaMint-ES ParlaMint-ES 2> ParlaMint-ES/ParlaMint-ES.conllu.log
	#Scripts/parlamint2conllu.pl ParlaMint-FR ParlaMint-FR 2> ParlaMint-FR/ParlaMint-FR.conllu.log
	Scripts/parlamint2conllu.pl ParlaMint-GB ParlaMint-GB 2> ParlaMint-GB/ParlaMint-GB.conllu.log
	Scripts/parlamint2conllu.pl ParlaMint-HR ParlaMint-HR 2> ParlaMint-HR/ParlaMint-HR.conllu.log
	Scripts/parlamint2conllu.pl ParlaMint-HU ParlaMint-HU 2> ParlaMint-HU/ParlaMint-HU.conllu.log
	Scripts/parlamint2conllu.pl ParlaMint-IS ParlaMint-IS 2> ParlaMint-IS/ParlaMint-IS.conllu.log
	Scripts/parlamint2conllu.pl ParlaMint-IT ParlaMint-IT 2> ParlaMint-IT/ParlaMint-IT.conllu.log
	#Scripts/parlamint2conllu.pl ParlaMint-LT ParlaMint-LT 2> ParlaMint-LT/ParlaMint-LT.conllu.log
	#Scripts/parlamint2conllu.pl ParlaMint-LV ParlaMint-LV 2> ParlaMint-LV/ParlaMint-LV.conllu.log
	Scripts/parlamint2conllu.pl ParlaMint-NL ParlaMint-NL 2> ParlaMint-NL/ParlaMint-NL.conllu.log
	Scripts/parlamint2conllu.pl ParlaMint-PL ParlaMint-PL 2> ParlaMint-PL/ParlaMint-PL.conllu.log
	#Scripts/parlamint2conllu.pl ParlaMint-RO ParlaMint-RO 2> ParlaMint-RO/ParlaMint-RO.conllu.log
	Scripts/parlamint2conllu.pl ParlaMint-SI ParlaMint-SI 2> ParlaMint-SI/ParlaMint-SI.conllu.log
	Scripts/parlamint2conllu.pl ParlaMint-TR ParlaMint-TR 2> ParlaMint-TR/ParlaMint-TR.conllu.log

conllu-six:
	rm -f ParlaMint-SI/*.conllu
	ls ParlaMint-SI/*_*.ana.xml | $P --jobs 10 \
	'$s meta=../ParlaMint-SI/ParlaMint-SI.ana.xml -xsl:Scripts/parlamint2conllu.xsl {} > {.}.conllu'
	rename 's/\.ana\.conllu/.conllu/' ParlaMint-SI/*.ana.conllu
	python3 Scripts/tools/validate.py --lang sl --level 1 ParlaMint-SI/*.conllu
	python3 Scripts/tools/validate.py --lang sl --level 2 ParlaMint-SI/*.conllu
	python3 Scripts/tools/validate.py --lang sl --level 3 ParlaMint-SI/*.conllu

SI = ParlaMint-SI_2018-04-13-SDZ7-Izredna-59
test-conllu-si:
	$s meta=../ParlaMint-SI/ParlaMint-SI.ana.xml -xsl:Scripts/parlamint2conllu.xsl \
	ParlaMint-SI/${SI}.ana.xml > ParlaMint-SI/${SI}.conllu
	python3 Scripts/tools/validate.py --lang sl --level 1 ParlaMint-SI/${SI}.conllu
	python3 Scripts/tools/validate.py --lang sl --level 2 ParlaMint-SI/${SI}.conllu
	python3 Scripts/tools/validate.py --lang sl --level 3 ParlaMint-SI/${SI}.conllu

CZ = ParlaMint-CZ_2013-11-25-ps2013-001-01-001-001
test-conllu-cz:
	$s meta=../ParlaMint-CZ/ParlaMint-CZ.ana.xml -xsl:Scripts/parlamint2conllu.xsl \
	ParlaMint-CZ/${CZ}.ana.xml > ParlaMint-CZ/${CZ}.conllu
	python3 Scripts/tools/validate.py --lang cs --level 1 ParlaMint-CZ/${CZ}.conllu
	python3 Scripts/tools/validate.py --lang cs --level 2 ParlaMint-CZ/${CZ}.conllu
	python3 Scripts/tools/validate.py --lang cs --level 3 ParlaMint-CZ/${CZ}.conllu

DK = ParlaMint-DK_2018-11-22-20181-M24
test-conllu-dk:
	$s meta=../ParlaMint-DK/ParlaMint-DK.ana.xml -xsl:Scripts/parlamint2conllu.xsl \
	ParlaMint-DK/${DK}.ana.xml > ParlaMint-DK/${DK}.conllu
	python3 Scripts/tools/validate.py --lang dk --level 1 ParlaMint-DK/${DK}.conllu
	python3 Scripts/tools/validate.py --lang dk --level 2 ParlaMint-DK/${DK}.conllu
	python3 Scripts/tools/validate.py --lang dk --level 3 ParlaMint-DK/${DK}.conllu

BE = ParlaMint-BE_2015-06-10-54-commissie-ic189x
test-conllu-be:	test-conllu-be-nl test-conllu-be-fr
test-conllu-be-nl:
	$s seg-lang=nl meta=../ParlaMint-BE/ParlaMint-BE.ana.xml -xsl:Scripts/parlamint2conllu.xsl \
	ParlaMint-BE/${BE}.ana.xml > ParlaMint-BE/${BE}-nl.conllu
	python3 Scripts/tools/validate.py --lang nl --level 1 ParlaMint-BE/${BE}-nl.conllu
	-python3 Scripts/tools/validate.py --lang nl --level 2 ParlaMint-BE/${BE}-nl.conllu
test-conllu-be-fr:
	$s seg-lang=fr meta=../ParlaMint-BE/ParlaMint-BE.ana.xml -xsl:Scripts/parlamint2conllu.xsl \
	ParlaMint-BE/${BE}.ana.xml > ParlaMint-BE/${BE}-fr.conllu
	python3 Scripts/tools/validate.py --lang fr --level 1 ParlaMint-BE/${BE}-fr.conllu
	-python3 Scripts/tools/validate.py --lang fr --level 2 ParlaMint-BE/${BE}-fr.conllu

meta:
	rm -f ParlaMint-??/*-meta.tsv

	ls ParlaMint-BE/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s hdr=../ParlaMint-BE/ParlaMint-BE.xml -xsl:Scripts/parlamint2meta.xsl \
	{} > ParlaMint-BE/{/.}-meta.tsv'

	ls ParlaMint-BG/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s hdr=../ParlaMint-BG/ParlaMint-BG.xml -xsl:Scripts/parlamint2meta.xsl \
	{} > ParlaMint-BG/{/.}-meta.tsv'

	ls ParlaMint-CZ/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s hdr=../ParlaMint-CZ/ParlaMint-CZ.xml -xsl:Scripts/parlamint2meta.xsl \
	{} > ParlaMint-CZ/{/.}-meta.tsv'

	ls ParlaMint-DK/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s hdr=../ParlaMint-DK/ParlaMint-DK.xml -xsl:Scripts/parlamint2meta.xsl \
	{} > ParlaMint-DK/{/.}-meta.tsv'

	ls ParlaMint-ES/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s hdr=../ParlaMint-ES/ParlaMint-ES.xml -xsl:Scripts/parlamint2meta.xsl \
	{} > ParlaMint-ES/{/.}-meta.tsv'

	ls ParlaMint-FR/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s hdr=../ParlaMint-FR/ParlaMint-FR.xml -xsl:Scripts/parlamint2meta.xsl \
	{} > ParlaMint-FR/{/.}-meta.tsv'

	ls ParlaMint-GB/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s hdr=../ParlaMint-GB/ParlaMint-GB.xml -xsl:Scripts/parlamint2meta.xsl \
	{} > ParlaMint-GB/{/.}-meta.tsv'

	ls ParlaMint-HR/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s hdr=../ParlaMint-HR/ParlaMint-HR.xml -xsl:Scripts/parlamint2meta.xsl \
	{} > ParlaMint-HR/{/.}-meta.tsv'

	ls ParlaMint-HU/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s hdr=../ParlaMint-HU/ParlaMint-HU.xml -xsl:Scripts/parlamint2meta.xsl \
	{} > ParlaMint-HU/{/.}-meta.tsv'

	ls ParlaMint-IS/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s hdr=../ParlaMint-IS/ParlaMint-IS.xml -xsl:Scripts/parlamint2meta.xsl \
	{} > ParlaMint-IS/{/.}-meta.tsv'

	ls ParlaMint-IT/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s hdr=../ParlaMint-IT/ParlaMint-IT.xml -xsl:Scripts/parlamint2meta.xsl \
	{} > ParlaMint-IT/{/.}-meta.tsv'

	ls ParlaMint-LT/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s hdr=../ParlaMint-LT/ParlaMint-LT.xml -xsl:Scripts/parlamint2meta.xsl \
	{} > ParlaMint-LT/{/.}-meta.tsv'

	ls ParlaMint-LV/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s hdr=../ParlaMint-LV/ParlaMint-LV.xml -xsl:Scripts/parlamint2meta.xsl \
	{} > ParlaMint-LV/{/.}-meta.tsv'

	ls ParlaMint-NL/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s hdr=../ParlaMint-NL/ParlaMint-NL.xml -xsl:Scripts/parlamint2meta.xsl \
	{} > ParlaMint-NL/{/.}-meta.tsv'

	ls ParlaMint-PL/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s hdr=../ParlaMint-PL/ParlaMint-PL.xml -xsl:Scripts/parlamint2meta.xsl \
	{} > ParlaMint-PL/{/.}-meta.tsv'

	# ls ParlaMint-RO/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	# '$s hdr=../ParlaMint-RO/ParlaMint-RO.xml -xsl:Scripts/parlamint2meta.xsl \
	# {} > ParlaMint-RO/{/.}-meta.tsv'

	ls ParlaMint-SI/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s hdr=../ParlaMint-SI/ParlaMint-SI.xml -xsl:Scripts/parlamint2meta.xsl \
	{} > ParlaMint-SI/{/.}-meta.tsv'

	ls ParlaMint-TR/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s hdr=../ParlaMint-TR/ParlaMint-TR.xml -xsl:Scripts/parlamint2meta.xsl \
	{} > ParlaMint-TR/{/.}-meta.tsv'

#Now that we have plain text, would be better to compute char counts from those!
chars-xml:
	rm -f ParlaMint-??/chars-*.tbl

	ls ParlaMint-BG/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'Scripts/chars.pl {} >> ParlaMint-BG/chars-files-BG.tbl'
	Scripts/chars-summ.pl < ParlaMint-BG/chars-files-BG.tbl > ParlaMint-BG/chars-BG.tbl

	ls ParlaMint-CZ/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'Scripts/chars.pl {} >> ParlaMint-CZ/chars-files-CZ.tbl'
	Scripts/chars-summ.pl < ParlaMint-CZ/chars-files-CZ.tbl > ParlaMint-CZ/chars-CZ.tbl

	ls ParlaMint-HR/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'Scripts/chars.pl {} >> ParlaMint-HR/chars-files-HR.tbl'
	Scripts/chars-summ.pl < ParlaMint-HR/chars-files-HR.tbl > ParlaMint-HR/chars-HR.tbl

	ls ParlaMint-IS/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'Scripts/chars.pl {} >> ParlaMint-IS/chars-files-IS.tbl'
	Scripts/chars-summ.pl < ParlaMint-IS/chars-files-IS.tbl > ParlaMint-IS/chars-IS.tbl

	ls ParlaMint-PL/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'Scripts/chars.pl {} >> ParlaMint-PL/chars-files-PL.tbl'
	Scripts/chars-summ.pl < ParlaMint-PL/chars-files-PL.tbl > ParlaMint-PL/chars-PL.tbl

	ls ParlaMint-SI/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'Scripts/chars.pl {} >> ParlaMint-SI/chars-files-SI.tbl'
	Scripts/chars-summ.pl < ParlaMint-SI/chars-files-SI.tbl > ParlaMint-SI/chars-SI.tbl

texts:
	rm -f ParlaMint-??/*.txt

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
	rm -f ParlaMint-??/*.vert
	Scripts/parlamint-tei2vert.pl ParlaMint-BE/ParlaMint-BE.ana.xml ParlaMint-BE
	Scripts/parlamint-tei2vert.pl ParlaMint-BG/ParlaMint-BG.ana.xml ParlaMint-BG
	Scripts/parlamint-tei2vert.pl ParlaMint-CZ/ParlaMint-CZ.ana.xml ParlaMint-CZ
	Scripts/parlamint-tei2vert.pl ParlaMint-DK/ParlaMint-DK.ana.xml ParlaMint-DK
	#Scripts/parlamint-tei2vert.pl ParlaMint-ES/ParlaMint-ES.ana.xml ParlaMint-ES
	#Scripts/parlamint-tei2vert.pl ParlaMint-FR/ParlaMint-FR.ana.xml ParlaMint-FR
	Scripts/parlamint-tei2vert.pl ParlaMint-GB/ParlaMint-GB.ana.xml ParlaMint-GB
	Scripts/parlamint-tei2vert.pl ParlaMint-HR/ParlaMint-HR.ana.xml ParlaMint-HR
	#Scripts/parlamint-tei2vert.pl ParlaMint-HU/ParlaMint-HU.ana.xml ParlaMint-HU
	Scripts/parlamint-tei2vert.pl ParlaMint-IS/ParlaMint-IS.ana.xml ParlaMint-IS
	#Scripts/parlamint-tei2vert.pl ParlaMint-IT/ParlaMint-IT.ana.xml ParlaMint-IT
	#Scripts/parlamint-tei2vert.pl ParlaMint-LT/ParlaMint-LT.ana.xml ParlaMint-LT
	#Scripts/parlamint-tei2vert.pl ParlaMint-LV/ParlaMint-LV.ana.xml ParlaMint-LV
	Scripts/parlamint-tei2vert.pl ParlaMint-NL/ParlaMint-NL.ana.xml ParlaMint-NL
	Scripts/parlamint-tei2vert.pl ParlaMint-PL/ParlaMint-PL.ana.xml ParlaMint-PL
	#Scripts/parlamint-tei2vert.pl ParlaMint-RO/ParlaMint-RO.ana.xml ParlaMint-RO
	Scripts/parlamint-tei2vert.pl ParlaMint-SI/ParlaMint-SI.ana.xml ParlaMint-SI
	#Scripts/parlamint-tei2vert.pl ParlaMint-TR/ParlaMint-TR.ana.xml ParlaMint-TR

#Make HTML, not yet operative
H = /project/corpora/Parla/ParlaMint/ParlaMint/
htm:	val-all
	Scripts/Stylesheets/bin/teitohtml --profiledir=$H --profile=profile \
	docs/ParlaMint-summary.xml docs/index.html

test-val:
	$s -xsl:Scripts/validate-parlamint.xsl ParlaMint-BE/ParlaMint-BE.ana.xml
	$s -xsl:Scripts/validate-parlamint.xsl ParlaMint-BE/ParlaMint-BE_2015-06-10-54-commissie-ic189x.ana.xml
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
