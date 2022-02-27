
DATADIR = Data


# test settings and prerequisites for makefile run
prereq:
	@test -f /usr/share/java/saxon.jar
	@unzip -p /usr/share/java/saxon.jar META-INF/MANIFEST.MF|grep 'Main-Class:'| grep -q 'net.sf.saxon.Transform'
	@echo "Saxon: OK"
	@test -f /usr/share/java/jing.jar
	@unzip -p /usr/share/java/jing.jar META-INF/MANIFEST.MF|grep 'Main-Class:'| grep -q 'relaxng'
	@echo "Jing: OK"
	@test -f Scripts/tools/validate.py
	@python -m re
	@echo "UD tools: OK"
	@echo "INFO: Maximum java heap size (saxon needs 5-times more than the size of processed xml file)"
	@java -XX:+PrintFlagsFinal -version 2>&1| grep " MaxHeapSize"|sed "s/^.*= *//;s/ .*$$//"|awk '{print "\t" $$1/1024/1024/1024 " GB"}'

setup-parliament:
ifndef PARLIAMENT-CODE
	$(error PARLIAMENT-CODE is not set - use "make TARGET PARLIAMENT-CODE='<CODE>'" )
endif
ifndef PARLIAMENT-NAME
	$(error PARLIAMENT-NAME is not set - use "make TARGET PARLIAMENT-NAME='<COUNTRY>'" )
endif
ifndef LANG-LIST
	$(error LANG-LIST is not set - use "make TARGET LANG-LIST='<langcode1> (Language1), <langcode2> (Language2)'" )
endif
	test ! -d ./Data/ParlaMint-$(PARLIAMENT-CODE)
	mkdir ./Data/ParlaMint-$(PARLIAMENT-CODE)
	echo "# ParlaMint directory for samples of country $(PARLIAMENT-CODE) ($(PARLIAMENT-NAME))" > ./Data/ParlaMint-$(PARLIAMENT-CODE)/README.md
	echo "## Languages: $(LANG-LIST)" >> ./Data/ParlaMint-$(PARLIAMENT-CODE)/README.md

setup-parliament-newInParlaMint2:
	make setup-parliament PARLIAMENT-NAME='Austria' PARLIAMENT-CODE='AT' LANG-LIST='de (German)'
	make setup-parliament PARLIAMENT-NAME='Basque Country' PARLIAMENT-CODE='ES-PV' LANG-LIST='eu (Basque)'
	make setup-parliament PARLIAMENT-NAME='Catalonia' PARLIAMENT-CODE='ES-CT' LANG-LIST='ca (Catalan)'
	make setup-parliament PARLIAMENT-NAME='Estonia' PARLIAMENT-CODE='EE' LANG-LIST='et (Estonian)'
	make setup-parliament PARLIAMENT-NAME='Finland' PARLIAMENT-CODE='FI' LANG-LIST='fi (Finnish)'
	make setup-parliament PARLIAMENT-NAME='Greece' PARLIAMENT-CODE='GR' LANG-LIST='el (Greek)'
	make setup-parliament PARLIAMENT-NAME='Norway' PARLIAMENT-CODE='NO' LANG-LIST='no (Norwegian)'
	make setup-parliament PARLIAMENT-NAME='Portugal' PARLIAMENT-CODE='PT' LANG-LIST='pt (Portuguese)'
	make setup-parliament PARLIAMENT-NAME='Romania' PARLIAMENT-CODE='RO' LANG-LIST='ro (Romanian)'
	make setup-parliament PARLIAMENT-NAME='Sweden' PARLIAMENT-CODE='SE' LANG-LIST='sv (Swedish)'


#Table3: Make table with data on corpora
table-data:
	$s mode=tsv -xsl:Scripts/parlamint2tbl-data.xsl ../V2/Master/ParlaMint.xml > ${DATADIR}/Metadata/ParlaMint-data.tsv
	$s mode=tex -xsl:Scripts/parlamint2tbl-data.xsl ../V2/Master//ParlaMint.xml > ${DATADIR}/Metadata/ParlaMint-data.tex
test-table-data:
	$s mode=tsv -xsl:Scripts/parlamint2tbl-data.xsl ParlaMint.xml > ${DATADIR}/Metadata/ParlaMint-data.tsv
	$s mode=tex -xsl:Scripts/parlamint2tbl-data.xsl ParlaMint.xml > ${DATADIR}/Metadata/ParlaMint-data.tex
#Table2: Make table with metadata on corpora
table-meta:
	$s mode=tsv -xsl:Scripts/parlamint2tbl-meta.xsl ParlaMint.xml > ${DATADIR}/Metadata/ParlaMint-meta.tsv
	$s mode=tex -xsl:Scripts/parlamint2tbl-meta.xsl ParlaMint.xml > ${DATADIR}/Metadata/ParlaMint-meta.tex
#Table1: Make table with basic info on corpora
table-overview:
	$s mode=tsv -xsl:Scripts/parlamint2tbl-overview.xsl ParlaMint.xml > ${DATADIR}/Metadata/ParlaMint-overview.tsv
	$s mode=tex -xsl:Scripts/parlamint2tbl-overview.xsl ParlaMint.xml > ${DATADIR}/Metadata/ParlaMint-overview.tex

#Make TSV with dates and sizes for all corpora from vert files
chrono:
	Scripts/vert2chronotsv.pl '${DATADIR}/ParlaMint-??'

#Dump all parties in TSV file
parties:
	$s -xsl:Scripts/parlamint-parties.xsl ParlaMint.xml > ${DATADIR}/Metadata/ParlaMint-parties.tsv
	$s -xsl:Scripts/parlamint-coaloppo.xsl ParlaMint.xml > ${DATADIR}/Metadata/ParlaMint-coaloppo.tsv

#Make ParlaMint corpus root
root:
	$s -xsl:Scripts/parlamint2root.xsl Scripts/ParlaMint-template.xml > ${DATADIR}/ParlaMint.xml
	$s -xsl:Scripts/parlamint2root.xsl Scripts/ParlaMint-template.ana.xml > ${DATADIR}/ParlaMint.ana.xml

# Validate and derive formats for 1 language
LANG = CZ
PREF = /project/corpora/Parla/ParlaMint/ParlaMint
all-lang:	all-lang-tei all-lang-ana
all-lang-tei:	val-pc-lang val-lang text-lang meta-lang chars-lang
all-lang-ana:	vertana-lang conllu-lang
chars-lang:
	rm -f ${DATADIR}/ParlaMint-${LANG}/chars-files-${LANG}.txt
	rm -f ${DATADIR}/ParlaMint-${LANG}/*.tmp
	nice find ${DATADIR}/ParlaMint-${LANG}/ -name '*.txt' | \
	$P --jobs 20 'cut -f2 {} > {.}.tmp'
	nice find ${DATADIR}/ParlaMint-${LANG}/ -name '*.tmp' | \
	$P --jobs 20 'Scripts/chars.pl {} >> ${DATADIR}/ParlaMint-${LANG}/chars-files-${LANG}.tbl'
	Scripts/chars-summ.pl < ${DATADIR}/ParlaMint-${LANG}/chars-files-${LANG}.tbl \
	> ${DATADIR}/ParlaMint-${LANG}/chars-${LANG}.tbl
	rm -f ${DATADIR}/ParlaMint-${LANG}/*.tmp
text-lang:
	ls ${DATADIR}/ParlaMint-${LANG}/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s -xsl:Scripts/parlamint-tei2text.xsl {} > ${DATADIR}/ParlaMint-${LANG}/{/.}.txt'
meta-lang:
	ls ${DATADIR}/ParlaMint-${LANG}/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s hdr=../${DATADIR}/ParlaMint-${LANG}/ParlaMint-${LANG}.xml -xsl:Scripts/parlamint2meta.xsl \
	{} > ${DATADIR}/ParlaMint-${LANG}/{/.}-meta.tsv'
conllu-lang:
	Scripts/parlamint2conllu.pl ${DATADIR}/ParlaMint-${LANG} ${DATADIR}/ParlaMint-${LANG}

vertana-lang:
	Scripts/parlamint-tei2vert.pl ${DATADIR}/ParlaMint-${LANG}/ParlaMint-${LANG}.ana.xml ${DATADIR}/ParlaMint-${LANG}
val-lang:
	Scripts/validate-parlamint.pl Schema '${DATADIR}/ParlaMint-${LANG}'
val-pc-lang:
	ls ${DATADIR}/ParlaMint-${LANG}/ParlaMint-${LANG}.xml | xargs ${pc}
	ls ${DATADIR}/ParlaMint-${LANG}/ParlaMint-${LANG}.ana.xml | xargs ${pc}

conllu-si:
	rm -f ${DATADIR}/ParlaMint-SI/*.conllu
	ls ${DATADIR}/ParlaMint-SI/*_*.ana.xml | $P --jobs 10 \
	'$s meta=../${DATADIR}/ParlaMint-SI/ParlaMint-SI.ana.xml -xsl:Scripts/parlamint2conllu.xsl {} > {.}.conllu'
	rename 's/\.ana\.conllu/.conllu/' ${DATADIR}/ParlaMint-SI/*.ana.conllu
	python3 Scripts/tools/validate.py --lang sl --level 1 ${DATADIR}/ParlaMint-SI/*.conllu
	python3 Scripts/tools/validate.py --lang sl --level 2 ${DATADIR}/ParlaMint-SI/*.conllu
	python3 Scripts/tools/validate.py --lang sl --level 3 ${DATADIR}/ParlaMint-SI/*.conllu

SI = ParlaMint-SI_2018-04-13-SDZ7-Izredna-59
test-conllu-si:
	$s meta=../${DATADIR}/ParlaMint-SI/ParlaMint-SI.ana.xml -xsl:Scripts/parlamint2conllu.xsl \
	${DATADIR}/ParlaMint-SI/${SI}.ana.xml > ${DATADIR}/ParlaMint-SI/${SI}.conllu
	python3 Scripts/tools/validate.py --lang sl --level 1 ${DATADIR}/ParlaMint-SI/${SI}.conllu
	python3 Scripts/tools/validate.py --lang sl --level 2 ${DATADIR}/ParlaMint-SI/${SI}.conllu
	python3 Scripts/tools/validate.py --lang sl --level 3 ${DATADIR}/ParlaMint-SI/${SI}.conllu

CZ = ParlaMint-CZ_2013-11-25-ps2013-001-01-001-001
test-conllu-cz:
	$s meta=../${DATADIR}/ParlaMint-CZ/ParlaMint-CZ.ana.xml -xsl:Scripts/parlamint2conllu.xsl \
	${DATADIR}/ParlaMint-CZ/${CZ}.ana.xml > ${DATADIR}/ParlaMint-CZ/${CZ}.conllu
	python3 Scripts/tools/validate.py --lang cs --level 1 ${DATADIR}/ParlaMint-CZ/${CZ}.conllu
	python3 Scripts/tools/validate.py --lang cs --level 2 ${DATADIR}/ParlaMint-CZ/${CZ}.conllu
	python3 Scripts/tools/validate.py --lang cs --level 3 ${DATADIR}/ParlaMint-CZ/${CZ}.conllu

DK = ParlaMint-DK_2018-11-22-20181-M24
test-conllu-dk:
	$s meta=../${DATADIR}/ParlaMint-DK/ParlaMint-DK.ana.xml -xsl:Scripts/parlamint2conllu.xsl \
	${DATADIR}/ParlaMint-DK/${DK}.ana.xml > ${DATADIR}/ParlaMint-DK/${DK}.conllu
	python3 Scripts/tools/validate.py --lang dk --level 1 ${DATADIR}/ParlaMint-DK/${DK}.conllu
	python3 Scripts/tools/validate.py --lang dk --level 2 ${DATADIR}/ParlaMint-DK/${DK}.conllu
	python3 Scripts/tools/validate.py --lang dk --level 3 ${DATADIR}/ParlaMint-DK/${DK}.conllu

BE = ParlaMint-BE_2015-06-10-54-commissie-ic189x
test-conllu-be:	test-conllu-be-nl test-conllu-be-fr
test-conllu-be-nl:
	$s seg-lang=nl meta=../${DATADIR}/ParlaMint-BE/ParlaMint-BE.ana.xml -xsl:Scripts/parlamint2conllu.xsl \
	${DATADIR}/ParlaMint-BE/${BE}.ana.xml > ${DATADIR}/ParlaMint-BE/${BE}-nl.conllu
	python3 Scripts/tools/validate.py --lang nl --level 1 ${DATADIR}/ParlaMint-BE/${BE}-nl.conllu
	-python3 Scripts/tools/validate.py --lang nl --level 2 ${DATADIR}/ParlaMint-BE/${BE}-nl.conllu
test-conllu-be-fr:
	$s seg-lang=fr meta=../${DATADIR}/ParlaMint-BE/ParlaMint-BE.ana.xml -xsl:Scripts/parlamint2conllu.xsl \
	${DATADIR}/ParlaMint-BE/${BE}.ana.xml > ${DATADIR}/ParlaMint-BE/${BE}-fr.conllu
	python3 Scripts/tools/validate.py --lang fr --level 1 ${DATADIR}/ParlaMint-BE/${BE}-fr.conllu
	-python3 Scripts/tools/validate.py --lang fr --level 2 ${DATADIR}/ParlaMint-BE/${BE}-fr.conllu

#### Validation and generation of various types of files for all V2.1 languages 

# Validation for all corpora
# Parla-CLARIN validation
nohup:
	nohup time make all > nohup.val &
all:	val-all

# ParlaMint validation
val-all:
	Scripts/validate-parlamint.pl Schema '${DATADIR}/ParlaMint-??'

# ParlaMint validation with Jing only, but also with Parla-CLARIN
val-jing: val-jing-parla-clarin val-jing-parlamint

val-jing-parlamint:
	ls ${DATADIR}/ParlaMint-??/ParlaMint-*.xml | grep -v '.ana.' | grep -v '_' | xargs ${vrt}
	ls ${DATADIR}/ParlaMint-??/ParlaMint-*.xml | grep -v '.ana.' | grep    '_' | xargs ${vct}
	ls ${DATADIR}/ParlaMint-??/ParlaMint-*.xml | grep    '.ana.' | grep -v '_' | xargs ${vra}
	ls ${DATADIR}/ParlaMint-??/ParlaMint-*.xml | grep    '.ana.' | grep    '_' | xargs ${vca}

val-jing-parla-clarin: create-all-in-one
	ls ${DATADIR}/ParlaMint-??/ParlaMint-*.xml.all-in-one.xml | grep -v '.ana.' | xargs ${pc}
	ls ${DATADIR}/ParlaMint-??/ParlaMint-*.xml.all-in-one.xml | grep    '.ana.' | xargs ${pc}
	rm -f  ${DATADIR}/ParlaMint-??/*.xml.all-in-one.xml

create-all-in-one:
	rm -f  ${DATADIR}/ParlaMint-??/*.xml.all-in-one.xml
	ls  ${DATADIR}/ParlaMint-??/ParlaMint-*.xml | grep -v '.ana.' | grep -v '_' | xargs ${copy}
	ls  ${DATADIR}/ParlaMint-??/ParlaMint-*.xml | grep    '.ana.' | grep -v '_' | xargs ${copy}

#Generation and validation of CoNLL-U files
#If you want to use, first do:
#$ cd Scripts; git clone git@github.com:UniversalDependencies/tools.git
nohup-conllu:
	nohup time make conllu &
conllu:
	rm -f ${DATADIR}/ParlaMint-??/*.conllu
	Scripts/parlamint2conllu.pl ${DATADIR}/ParlaMint-BE ${DATADIR}/ParlaMint-BE 2> ${DATADIR}/ParlaMint-BE/ParlaMint-BE.conllu.log
	Scripts/parlamint2conllu.pl ${DATADIR}/ParlaMint-BG ${DATADIR}/ParlaMint-BG 2> ${DATADIR}/ParlaMint-BG/ParlaMint-BG.conllu.log
	Scripts/parlamint2conllu.pl ${DATADIR}/ParlaMint-CZ ${DATADIR}/ParlaMint-CZ 2> ${DATADIR}/ParlaMint-CZ/ParlaMint-CZ.conllu.log
	Scripts/parlamint2conllu.pl ${DATADIR}/ParlaMint-DK ${DATADIR}/ParlaMint-DK 2> ${DATADIR}/ParlaMint-DK/ParlaMint-DK.conllu.log
	Scripts/parlamint2conllu.pl ${DATADIR}/ParlaMint-ES ${DATADIR}/ParlaMint-ES 2> ${DATADIR}/ParlaMint-ES/ParlaMint-ES.conllu.log
	Scripts/parlamint2conllu.pl ${DATADIR}/ParlaMint-FR ${DATADIR}/ParlaMint-FR 2> ${DATADIR}/ParlaMint-FR/ParlaMint-FR.conllu.log
	Scripts/parlamint2conllu.pl ${DATADIR}/ParlaMint-GB ${DATADIR}/ParlaMint-GB 2> ${DATADIR}/ParlaMint-GB/ParlaMint-GB.conllu.log
	Scripts/parlamint2conllu.pl ${DATADIR}/ParlaMint-HR ${DATADIR}/ParlaMint-HR 2> ${DATADIR}/ParlaMint-HR/ParlaMint-HR.conllu.log
	Scripts/parlamint2conllu.pl ${DATADIR}/ParlaMint-HU ${DATADIR}/ParlaMint-HU 2> ${DATADIR}/ParlaMint-HU/ParlaMint-HU.conllu.log
	Scripts/parlamint2conllu.pl ${DATADIR}/ParlaMint-IS ${DATADIR}/ParlaMint-IS 2> ${DATADIR}/ParlaMint-IS/ParlaMint-IS.conllu.log
	Scripts/parlamint2conllu.pl ${DATADIR}/ParlaMint-IT ${DATADIR}/ParlaMint-IT 2> ${DATADIR}/ParlaMint-IT/ParlaMint-IT.conllu.log
	Scripts/parlamint2conllu.pl ${DATADIR}/ParlaMint-LT ${DATADIR}/ParlaMint-LT 2> ${DATADIR}/ParlaMint-LT/ParlaMint-LT.conllu.log
	Scripts/parlamint2conllu.pl ${DATADIR}/ParlaMint-LV ${DATADIR}/ParlaMint-LV 2> ${DATADIR}/ParlaMint-LV/ParlaMint-LV.conllu.log
	Scripts/parlamint2conllu.pl ${DATADIR}/ParlaMint-NL ${DATADIR}/ParlaMint-NL 2> ${DATADIR}/ParlaMint-NL/ParlaMint-NL.conllu.log
	Scripts/parlamint2conllu.pl ${DATADIR}/ParlaMint-PL ${DATADIR}/ParlaMint-PL 2> ${DATADIR}/ParlaMint-PL/ParlaMint-PL.conllu.log
	#Scripts/parlamint2conllu.pl ${DATADIR}/ParlaMint-RO ${DATADIR}/ParlaMint-RO 2> ${DATADIR}/ParlaMint-RO/ParlaMint-RO.conllu.log
	Scripts/parlamint2conllu.pl ${DATADIR}/ParlaMint-SI ${DATADIR}/ParlaMint-SI 2> ${DATADIR}/ParlaMint-SI/ParlaMint-SI.conllu.log
	Scripts/parlamint2conllu.pl ${DATADIR}/ParlaMint-TR ${DATADIR}/ParlaMint-TR 2> ${DATADIR}/ParlaMint-TR/ParlaMint-TR.conllu.log

#Generation of meta-data files
meta:
	rm -f ${DATADIR}/ParlaMint-??/*-meta.tsv

	ls ${DATADIR}/ParlaMint-BE/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s hdr=../${DATADIR}/ParlaMint-BE/ParlaMint-BE.xml -xsl:Scripts/parlamint2meta.xsl \
	{} > ${DATADIR}/ParlaMint-BE/{/.}-meta.tsv'

	ls ${DATADIR}/ParlaMint-BG/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s hdr=../${DATADIR}/ParlaMint-BG/ParlaMint-BG.xml -xsl:Scripts/parlamint2meta.xsl \
	{} > ${DATADIR}/ParlaMint-BG/{/.}-meta.tsv'

	ls ${DATADIR}/ParlaMint-CZ/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s hdr=../${DATADIR}/ParlaMint-CZ/ParlaMint-CZ.xml -xsl:Scripts/parlamint2meta.xsl \
	{} > ${DATADIR}/ParlaMint-CZ/{/.}-meta.tsv'

	ls ${DATADIR}/ParlaMint-DK/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s hdr=../${DATADIR}/ParlaMint-DK/ParlaMint-DK.xml -xsl:Scripts/parlamint2meta.xsl \
	{} > ${DATADIR}/ParlaMint-DK/{/.}-meta.tsv'

	ls ${DATADIR}/ParlaMint-ES/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s hdr=../${DATADIR}/ParlaMint-ES/ParlaMint-ES.xml -xsl:Scripts/parlamint2meta.xsl \
	{} > ${DATADIR}/ParlaMint-ES/{/.}-meta.tsv'

	ls ${DATADIR}/ParlaMint-FR/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s hdr=../${DATADIR}/ParlaMint-FR/ParlaMint-FR.xml -xsl:Scripts/parlamint2meta.xsl \
	{} > ${DATADIR}/ParlaMint-FR/{/.}-meta.tsv'

	ls ${DATADIR}/ParlaMint-GB/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s hdr=../${DATADIR}/ParlaMint-GB/ParlaMint-GB.xml -xsl:Scripts/parlamint2meta.xsl \
	{} > ${DATADIR}/ParlaMint-GB/{/.}-meta.tsv'

	ls ${DATADIR}/ParlaMint-HR/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s hdr=../${DATADIR}/ParlaMint-HR/ParlaMint-HR.xml -xsl:Scripts/parlamint2meta.xsl \
	{} > ${DATADIR}/ParlaMint-HR/{/.}-meta.tsv'

	ls ${DATADIR}/ParlaMint-HU/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s hdr=../${DATADIR}/ParlaMint-HU/ParlaMint-HU.xml -xsl:Scripts/parlamint2meta.xsl \
	{} > ${DATADIR}/ParlaMint-HU/{/.}-meta.tsv'

	ls ${DATADIR}/ParlaMint-IS/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s hdr=../${DATADIR}/ParlaMint-IS/ParlaMint-IS.xml -xsl:Scripts/parlamint2meta.xsl \
	{} > ${DATADIR}/ParlaMint-IS/{/.}-meta.tsv'

	ls ${DATADIR}/ParlaMint-IT/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s hdr=../${DATADIR}/ParlaMint-IT/ParlaMint-IT.xml -xsl:Scripts/parlamint2meta.xsl \
	{} > ${DATADIR}/ParlaMint-IT/{/.}-meta.tsv'

	ls ${DATADIR}/ParlaMint-LT/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s hdr=../${DATADIR}/ParlaMint-LT/ParlaMint-LT.xml -xsl:Scripts/parlamint2meta.xsl \
	{} > ${DATADIR}/ParlaMint-LT/{/.}-meta.tsv'

	ls ${DATADIR}/ParlaMint-LV/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s hdr=../${DATADIR}/ParlaMint-LV/ParlaMint-LV.xml -xsl:Scripts/parlamint2meta.xsl \
	{} > ${DATADIR}/ParlaMint-LV/{/.}-meta.tsv'

	ls ${DATADIR}/ParlaMint-NL/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s hdr=../${DATADIR}/ParlaMint-NL/ParlaMint-NL.xml -xsl:Scripts/parlamint2meta.xsl \
	{} > ${DATADIR}/ParlaMint-NL/{/.}-meta.tsv'

	ls ${DATADIR}/ParlaMint-PL/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s hdr=../${DATADIR}/ParlaMint-PL/ParlaMint-PL.xml -xsl:Scripts/parlamint2meta.xsl \
	{} > ${DATADIR}/ParlaMint-PL/{/.}-meta.tsv'

	# ls ${DATADIR}/ParlaMint-RO/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	# '$s hdr=../${DATADIR}/ParlaMint-RO/ParlaMint-RO.xml -xsl:Scripts/parlamint2meta.xsl \
	# {} > ${DATADIR}/ParlaMint-RO/{/.}-meta.tsv'

	ls ${DATADIR}/ParlaMint-SI/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s hdr=../${DATADIR}/ParlaMint-SI/ParlaMint-SI.xml -xsl:Scripts/parlamint2meta.xsl \
	{} > ${DATADIR}/ParlaMint-SI/{/.}-meta.tsv'

	ls ${DATADIR}/ParlaMint-TR/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s hdr=../${DATADIR}/ParlaMint-TR/ParlaMint-TR.xml -xsl:Scripts/parlamint2meta.xsl \
	{} > ${DATADIR}/ParlaMint-TR/{/.}-meta.tsv'

#Generation of character profiles
#Now that we have plain text, would be better to compute char counts from those!
chars-xml:
	rm -f ${DATADIR}/ParlaMint-??/chars-*.tbl

	ls ${DATADIR}/ParlaMint-BE/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'Scripts/chars.pl {} >> ${DATADIR}/ParlaMint-BE/chars-files-BE.tbl'
	Scripts/chars-summ.pl < ${DATADIR}/ParlaMint-BE/chars-files-BE.tbl > ${DATADIR}/ParlaMint-BE/chars-BE.tbl

	ls ${DATADIR}/ParlaMint-BG/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'Scripts/chars.pl {} >> ${DATADIR}/ParlaMint-BG/chars-files-BG.tbl'
	Scripts/chars-summ.pl < ${DATADIR}/ParlaMint-BG/chars-files-BG.tbl > ${DATADIR}/ParlaMint-BG/chars-BG.tbl

	ls ${DATADIR}/ParlaMint-CZ/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'Scripts/chars.pl {} >> ${DATADIR}/ParlaMint-CZ/chars-files-CZ.tbl'
	Scripts/chars-summ.pl < ${DATADIR}/ParlaMint-CZ/chars-files-CZ.tbl > ${DATADIR}/ParlaMint-CZ/chars-CZ.tbl

	ls ${DATADIR}/ParlaMint-DK/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'Scripts/chars.pl {} >> ${DATADIR}/ParlaMint-DK/chars-files-DK.tbl'
	Scripts/chars-summ.pl < ${DATADIR}/ParlaMint-DK/chars-files-DK.tbl > ${DATADIR}/ParlaMint-DK/chars-DK.tbl

	ls ${DATADIR}/ParlaMint-ES/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'Scripts/chars.pl {} >> ${DATADIR}/ParlaMint-ES/chars-files-ES.tbl'
	Scripts/chars-summ.pl < ${DATADIR}/ParlaMint-ES/chars-files-ES.tbl > ${DATADIR}/ParlaMint-ES/chars-ES.tbl

	ls ${DATADIR}/ParlaMint-FR/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'Scripts/chars.pl {} >> ${DATADIR}/ParlaMint-FR/chars-files-FR.tbl'
	Scripts/chars-summ.pl < ${DATADIR}/ParlaMint-FR/chars-files-FR.tbl > ${DATADIR}/ParlaMint-FR/chars-FR.tbl

	ls ${DATADIR}/ParlaMint-GB/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'Scripts/chars.pl {} >> ${DATADIR}/ParlaMint-GB/chars-files-GB.tbl'
	Scripts/chars-summ.pl < ${DATADIR}/ParlaMint-GB/chars-files-GB.tbl > ${DATADIR}/ParlaMint-GB/chars-GB.tbl

	ls ${DATADIR}/ParlaMint-HR/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'Scripts/chars.pl {} >> ${DATADIR}/ParlaMint-HR/chars-files-HR.tbl'
	Scripts/chars-summ.pl < ${DATADIR}/ParlaMint-HR/chars-files-HR.tbl > ${DATADIR}/ParlaMint-HR/chars-HR.tbl

	ls ${DATADIR}/ParlaMint-HU/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'Scripts/chars.pl {} >> ${DATADIR}/ParlaMint-HU/chars-files-HU.tbl'
	Scripts/chars-summ.pl < ${DATADIR}/ParlaMint-HU/chars-files-HU.tbl > ${DATADIR}/ParlaMint-HU/chars-HU.tbl

	ls ${DATADIR}/ParlaMint-IS/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'Scripts/chars.pl {} >> ${DATADIR}/ParlaMint-IS/chars-files-IS.tbl'
	Scripts/chars-summ.pl < ${DATADIR}/ParlaMint-IS/chars-files-IS.tbl > ${DATADIR}/ParlaMint-IS/chars-IS.tbl

	ls ${DATADIR}/ParlaMint-IT/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'Scripts/chars.pl {} >> ${DATADIR}/ParlaMint-IT/chars-files-IT.tbl'
	Scripts/chars-summ.pl < ${DATADIR}/ParlaMint-IT/chars-files-IT.tbl > ${DATADIR}/ParlaMint-IT/chars-IT.tbl

	ls ${DATADIR}/ParlaMint-LT/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'Scripts/chars.pl {} >> ${DATADIR}/ParlaMint-LT/chars-files-LT.tbl'
	Scripts/chars-summ.pl < ${DATADIR}/ParlaMint-LT/chars-files-LT.tbl > ${DATADIR}/ParlaMint-LT/chars-LT.tbl

	ls ${DATADIR}/ParlaMint-LV/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'Scripts/chars.pl {} >> ${DATADIR}/ParlaMint-LV/chars-files-LV.tbl'
	Scripts/chars-summ.pl < ${DATADIR}/ParlaMint-LV/chars-files-LV.tbl > ${DATADIR}/ParlaMint-LV/chars-LV.tbl

	ls ${DATADIR}/ParlaMint-NL/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'Scripts/chars.pl {} >> ${DATADIR}/ParlaMint-NL/chars-files-NL.tbl'
	Scripts/chars-summ.pl < ${DATADIR}/ParlaMint-NL/chars-files-NL.tbl > ${DATADIR}/ParlaMint-NL/chars-NL.tbl

	ls ${DATADIR}/ParlaMint-PL/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'Scripts/chars.pl {} >> ${DATADIR}/ParlaMint-PL/chars-files-PL.tbl'
	Scripts/chars-summ.pl < ${DATADIR}/ParlaMint-PL/chars-files-PL.tbl > ${DATADIR}/ParlaMint-PL/chars-PL.tbl

	# ls ${DATADIR}/ParlaMint-RO/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	# 'Scripts/chars.pl {} >> ${DATADIR}/ParlaMint-RO/chars-files-RO.tbl'
	# Scripts/chars-summ.pl < ${DATADIR}/ParlaMint-RO/chars-files-RO.tbl > ${DATADIR}/ParlaMint-RO/chars-RO.tbl

	ls ${DATADIR}/ParlaMint-SI/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'Scripts/chars.pl {} >> ${DATADIR}/ParlaMint-SI/chars-files-SI.tbl'
	Scripts/chars-summ.pl < ${DATADIR}/ParlaMint-SI/chars-files-SI.tbl > ${DATADIR}/ParlaMint-SI/chars-SI.tbl

	ls ${DATADIR}/ParlaMint-TR/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'Scripts/chars.pl {} >> ${DATADIR}/ParlaMint-TR/chars-files-TR.tbl'
	Scripts/chars-summ.pl < ${DATADIR}/ParlaMint-TR/chars-files-TR.tbl > ${DATADIR}/ParlaMint-TR/chars-TR.tbl

texts:
	rm -f ${DATADIR}/ParlaMint-??/*.txt

	ls ${DATADIR}/ParlaMint-BE/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s -xsl:Scripts/parlamint-tei2text.xsl {} > ${DATADIR}/ParlaMint-BE/{/.}.txt'
	ls ${DATADIR}/ParlaMint-BG/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s -xsl:Scripts/parlamint-tei2text.xsl {} > ${DATADIR}/ParlaMint-BG/{/.}.txt'
	ls ${DATADIR}/ParlaMint-CZ/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s -xsl:Scripts/parlamint-tei2text.xsl {} > ${DATADIR}/ParlaMint-CZ/{/.}.txt'
	ls ${DATADIR}/ParlaMint-DK/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s -xsl:Scripts/parlamint-tei2text.xsl {} > ${DATADIR}/ParlaMint-DK/{/.}.txt'
	ls ${DATADIR}/ParlaMint-ES/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s -xsl:Scripts/parlamint-tei2text.xsl {} > ${DATADIR}/ParlaMint-ES/{/.}.txt'
	ls ${DATADIR}/ParlaMint-FR/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s -xsl:Scripts/parlamint-tei2text.xsl {} > ${DATADIR}/ParlaMint-FR/{/.}.txt'
	ls ${DATADIR}/ParlaMint-GB/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s -xsl:Scripts/parlamint-tei2text.xsl {} > ${DATADIR}/ParlaMint-GB/{/.}.txt'
	ls ${DATADIR}/ParlaMint-HR/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s -xsl:Scripts/parlamint-tei2text.xsl {} > ${DATADIR}/ParlaMint-HR/{/.}.txt'
	ls ${DATADIR}/ParlaMint-HU/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s -xsl:Scripts/parlamint-tei2text.xsl {} > ${DATADIR}/ParlaMint-HU/{/.}.txt'
	ls ${DATADIR}/ParlaMint-IS/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s -xsl:Scripts/parlamint-tei2text.xsl {} > ${DATADIR}/ParlaMint-IS/{/.}.txt'
	ls ${DATADIR}/ParlaMint-IT/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s -xsl:Scripts/parlamint-tei2text.xsl {} > ${DATADIR}/ParlaMint-IT/{/.}.txt'
	ls ${DATADIR}/ParlaMint-LT/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s -xsl:Scripts/parlamint-tei2text.xsl {} > ${DATADIR}/ParlaMint-LT/{/.}.txt'
	ls ${DATADIR}/ParlaMint-LV/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s -xsl:Scripts/parlamint-tei2text.xsl {} > ${DATADIR}/ParlaMint-LV/{/.}.txt'
	ls ${DATADIR}/ParlaMint-NL/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s -xsl:Scripts/parlamint-tei2text.xsl {} > ${DATADIR}/ParlaMint-NL/{/.}.txt'
	ls ${DATADIR}/ParlaMint-PL/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s -xsl:Scripts/parlamint-tei2text.xsl {} > ${DATADIR}/ParlaMint-PL/{/.}.txt'
	ls ${DATADIR}/ParlaMint-SI/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s -xsl:Scripts/parlamint-tei2text.xsl {} > ${DATADIR}/ParlaMint-SI/{/.}.txt'
	ls ${DATADIR}/ParlaMint-TR/*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s -xsl:Scripts/parlamint-tei2text.xsl {} > ${DATADIR}/ParlaMint-TR/{/.}.txt'

verts:
	rm -f ${DATADIR}/ParlaMint-??/*.vert
	Scripts/parlamint-tei2vert.pl ${DATADIR}/ParlaMint-BE/ParlaMint-BE.ana.xml ${DATADIR}/ParlaMint-BE
	Scripts/parlamint-tei2vert.pl ${DATADIR}/ParlaMint-BG/ParlaMint-BG.ana.xml ${DATADIR}/ParlaMint-BG
	Scripts/parlamint-tei2vert.pl ${DATADIR}/ParlaMint-CZ/ParlaMint-CZ.ana.xml ${DATADIR}/ParlaMint-CZ
	Scripts/parlamint-tei2vert.pl ${DATADIR}/ParlaMint-DK/ParlaMint-DK.ana.xml ${DATADIR}/ParlaMint-DK
	Scripts/parlamint-tei2vert.pl ${DATADIR}/ParlaMint-ES/ParlaMint-ES.ana.xml ${DATADIR}/ParlaMint-ES
	Scripts/parlamint-tei2vert.pl ${DATADIR}/ParlaMint-FR/ParlaMint-FR.ana.xml ${DATADIR}/ParlaMint-FR
	Scripts/parlamint-tei2vert.pl ${DATADIR}/ParlaMint-GB/ParlaMint-GB.ana.xml ${DATADIR}/ParlaMint-GB
	Scripts/parlamint-tei2vert.pl ${DATADIR}/ParlaMint-HR/ParlaMint-HR.ana.xml ${DATADIR}/ParlaMint-HR
	Scripts/parlamint-tei2vert.pl ${DATADIR}/ParlaMint-HU/ParlaMint-HU.ana.xml ${DATADIR}/ParlaMint-HU
	Scripts/parlamint-tei2vert.pl ${DATADIR}/ParlaMint-IS/ParlaMint-IS.ana.xml ${DATADIR}/ParlaMint-IS
	Scripts/parlamint-tei2vert.pl ${DATADIR}/ParlaMint-IT/ParlaMint-IT.ana.xml ${DATADIR}/ParlaMint-IT
	Scripts/parlamint-tei2vert.pl ${DATADIR}/ParlaMint-LT/ParlaMint-LT.ana.xml ${DATADIR}/ParlaMint-LT
	Scripts/parlamint-tei2vert.pl ${DATADIR}/ParlaMint-LV/ParlaMint-LV.ana.xml ${DATADIR}/ParlaMint-LV
	Scripts/parlamint-tei2vert.pl ${DATADIR}/ParlaMint-NL/ParlaMint-NL.ana.xml ${DATADIR}/ParlaMint-NL
	Scripts/parlamint-tei2vert.pl ${DATADIR}/ParlaMint-PL/ParlaMint-PL.ana.xml ${DATADIR}/ParlaMint-PL
	#Scripts/parlamint-tei2vert.pl ${DATADIR}/ParlaMint-RO/ParlaMint-RO.ana.xml ${DATADIR}/ParlaMint-RO
	Scripts/parlamint-tei2vert.pl ${DATADIR}/ParlaMint-SI/ParlaMint-SI.ana.xml ${DATADIR}/ParlaMint-SI
	Scripts/parlamint-tei2vert.pl ${DATADIR}/ParlaMint-TR/ParlaMint-TR.ana.xml ${DATADIR}/ParlaMint-TR

#Make HTML, not yet operative
H = /project/corpora/Parla/ParlaMint/ParlaMint/
htm:	val-all
	Scripts/Stylesheets/bin/teitohtml --profiledir=$H --profile=profile \
	docs/ParlaMint-summary.xml docs/index.html

clean:
	rm -f ${DATADIR}/ParlaMint-??/*.xml

################################################
s = java -jar /usr/share/java/saxon.jar
P = parallel --gnu --halt 2
j = java -jar /usr/share/java/jing.jar 
copy = -I % $s -xi:on -xsl:Scripts/copy.xsl -s:% -o:%.all-in-one.xml
pc =  $j Schema/parla-clarin.rng
vrt = $j Schema/ParlaMint-teiCorpus.rng 	# Corpus root / text
vct = $j Schema/ParlaMint-TEI.rng		# Corpus component / text
vra = $j Schema/ParlaMint-teiCorpus.ana.rng	# Corpus root / analysed
vca = $j Schema/ParlaMint-TEI.ana.rng		# Corpus component / analysed
