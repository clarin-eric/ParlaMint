############### Makefile for making a distributable version of the ParlaMint corpora #################

### VARIABLES
# Which corpora to process, takes cca 1 day per corpus!
CORPORA =  AT
# Submitted corpora
#CORPORA = AT BA BE BG CZ DK ES-CT FR GB GR HR HU IS IT LV NL NO PL PT RS SE SI TR UA
# All ParlaMint II corpora
#ALL_CORPORA = AT BA BE BG CZ DK EE ES ES-CT ES-GA ES-PV FI FR GB GR HR HU IS IT LT LV NL NO PL PT RS RO SE SI TR UA

# Used for testing scripts
#CORPUS = BA
CORPUS = LV

#Where things are, as we use several branches: this one (most likely dev) and documentation
PARLAMINT = /project/corpora/Parla/ParlaMint
HERE = ${PARLAMINT}/ParlaMint-V3/Distro
DOC = ${PARLAMINT}/ParlaMint-documentation
SCH = ${DOC}/Schema
TEMP = ${HERE}/Temp

#Where the submitted corpora are found (ParlaMint- .TEI/ and .TEI.ana/
SOURCE = ${HERE}/Source
SOURCE-MT = ${HERE}/Source-MT

# Version number
VERSION = 3.0
# PID of TEI and TEI.ana ParlaMint-en release
HANDLE-TEI = http://hdl.handle.net/11356/1486
HANDLE-ANA = http://hdl.handle.net/11356/1810
# PID of MTed (.ana) ParlaMint-en release
HANDLE-MT = http://hdl.handle.net/11356/1810

#Where the produced corpora are put for inspection
WEB = tomaz@nl.ijs.si:/home/tomaz/www/tmp/ParlaMint/
web-nohup:
	nice nohup time make web > ParlaMint-web &
web:
	rsync -av Logs/*.log ${WEB}/Logs
	rsync -av Packed/*.tgz ${WEB}/Repo

###### Targets for producing releasable version of ParlaMint corpora
FINALIZE = perl ../Scripts/parlamint2distro.pl -version ${VERSION} -teihandle ${HANDLE-TEI} -anahandle ${HANDLE-ANA} -schema ../Schema -docs Docs

#Tests
test1:
	rm -fr Test/Out/ParlaMint-${CORPUS}*
	perl ../Scripts/parlamint2distro.pl -tei -ana -val -codes ${CORPUS} -in Test/In -out Test/Out \
	-version 3.0 -teihandle ${HANDLE-TEI} -anahandle ${HANDLE-ANA} -schema ../Schema -docs Docs \

errs1:
	grep -i error Logs/*.log | \
	grep -v '...suppressing' | grep -v 'Format errors' | grep -v 'Syntax errors' | grep -v 'FAILED'

### Some idea, need to think about it!
#REGIS=at ba be bg cz dk es_ct fr gb gr hr hu is it lv nl no pl pt rs se si tr ua
REGIS=ua
QUERY=https://dev:alfabetagama@www.clarin.si/noske-beta/parlamint.cgi/wordlist?
TAIL=wlmaxitems=1000;wlattr=speech.body;wlminfreq=1;include_nonwords=1;wlsort=f;wlnums=docf;format=xml
body:
	rm -f body.xml
	for REGI in ${REGIS} ; do \
	curl "${QUERY}corpname=parlamint30_$${REGI};${TAIL}" | grep -v xml >> body.xml ; \
	done

### For real
nohup:
	nice nohup time make all > Logs/ParlaMint.log &
all:	final verts pack

pack:
	perl ../Scripts/pack-parlamint.pl -codes '${CORPORA}' -in Master -out Distro
verts:
	perl ../Scripts/join-verts.pl -codes '${CORPORA}' -in Master -out Verts
final:
	for CORPUS in ${CORPORA}; do \
	${FINALIZE} -all -codes $${CORPUS} -in ${SOURCE} -out ${HERE}/Master 2> Logs/ParlaMint-$${CORPUS}.log; \
	grep -a -i error Logs/ParlaMint-$${CORPUS}.log > Logs/ParlaMint-$${CORPUS}.error.log;  \
	grep -a -i warn  Logs/ParlaMint-$${CORPUS}.log > Logs/ParlaMint-$${CORPUS}.warn.log;  \
	echo "$${CORPUS}.warn"; \
	cat Logs/ParlaMint-$${CORPUS}.warn.log | wc -l;  \
	cat Logs/ParlaMint-$${CORPUS}.warn.log | sort | uniq | wc -l;  \
	echo "$${CORPUS}.error"; \
	cat Logs/ParlaMint-$${CORPUS}.error.log | wc -l;  \
	cat Logs/ParlaMint-$${CORPUS}.error.log | sort | uniq | wc -l;  \
	done;

###### Targets for producing MTed corpora
###### Input are a) original TEI.ana corpus, b) CoNLL-U of speech translations and c) list of translated notes

### Make joint vert for all ParlaMint corpora - Still neet to think aout this!
all-verts:
	perl ../Scripts/join-all-verts.pl -in 'Corpora/ParlaMint-B*.vert/*/*.vert' -out Verts/ParlaMint-XX.3.0.vert.gz

### Make MTed corpora

# Make distribution with:
FINALIZE-MT = perl ../Scripts/parlamint2distro.pl -anahandle ${HANDLE-MT} -schema ${DOC}/Schema -docs ${HERE}/Docs

# Targets
mt-nohup:
	nice nohup time make mt-all-final > Logs/ParlaMint-en.log &
mt-all-final:	mt-convert
mt-xall-final:	mt-convert mt-verts mt-pack

mt-pack:
	perl ../Scripts/pack-parlamint.pl -codes '${CORPORA}' -in Master -out Distro
mt-verts:
	perl ../Scripts/join-mt-verts.pl -codes '${CORPORA}' -in Master -out Verts
mt-convert:
	for CORPUS in ${CORPORA}; do \
	perl ../Scripts/mt-conllu2tei.pl \
	${SOURCE}/ParlaMint-$${CORPUS}.TEI.ana/ParlaMint-$${CORPUS}.ana.xml \
	${SOURCE-MT}/ParlaMint-$${CORPUS}-en-notes.tsv \
	${SOURCE-MT}/ParlaMint-$${CORPUS}-en.conllu \
	${TEMP}/ParlaMint-$${CORPUS}-en.TEI.ana 2> Logs/ParlaMint-$${CORPUS}-en.log; \
	${FINALIZE-MT} -all -notei -noconllu -codes $${CORPUS}-en -in ${TEMP} -out ${HERE}/Master \
	2>> Logs/ParlaMint-$${CORPUS}-en.log; \
	done;

### Various tests for debugging MT processing
mt-test8:
	$s -xsl:../Scripts/validate-parlamint.xsl \
	${HERE}/Master/ParlaMint-AT-en.TEI.ana/ParlaMint-AT-en.ana.xml
	$s meta=${HERE}/Master/ParlaMint-AT-en.TEI.ana/ParlaMint-AT-en.ana.xml -xsl:../Scripts/validate-parlamint.xsl \
	${HERE}/Master/ParlaMint-AT-en.TEI.ana/2022/ParlaMint-AT-en_2022-01-20-027-XXVII-NRSITZ-00139.ana.xml
mt-test7:
	$s meta=${HERE}/Master/ParlaMint-AT-en.TEI.ana/ParlaMint-AT-en.ana.xml -xsl:../Scripts//check-links.xsl \
	${HERE}/Master/ParlaMint-AT-en.TEI.ana/2022/ParlaMint-AT-en_2022-01-20-027-XXVII-NRSITZ-00139.ana.xml
mt-test6:
	${FINALIZE-MT} -vert -codes AT-en -in ${TEMP} -out ${HERE}/Master
mt-test5:
	${vta} Test/ParlaMint-AT-en.TEI.ana/ParlaMint-taxonomy-*.xml
	${vlp} Test/ParlaMint-AT-en.TEI.ana/ParlaMint-AT-listPerson.xml
	${vlo} Test/ParlaMint-AT-en.TEI.ana/ParlaMint-AT-listOrg.xml
	${vra} Test/ParlaMint-AT-en.TEI.ana/ParlaMint-AT-en.ana.xml
	${vca} Test/ParlaMint-AT-en.TEI.ana/1996/*.xml
mt-test4:
	perl ../Scripts/mt-insert-s.pl \
	  Test/ParlaMint-AT-en_1996-01-30-020-XX-NRSITZ-00004.body.xml \
	< Test/ParlaMint-AT-en_1996-01-30-020-XX-NRSITZ-00004.notes.xml \
	> Test/ParlaMint-AT-en_1996-01-30-020-XX-NRSITZ-00004.ana.xml
mt-test3:
	$s noteFile=Test/ParlaMint-AT.notes.translated.tsv -xsl:../Scripts/mt-insert-notes.xsl \
	$s noteFile=../taja/Notes-translated/ParlaMint-AT.notes.translated.tsv -xsl:../Scripts/mt-insert-notes.xsl \
	Test/ParlaMint-AT-en_1996-01-30-020-XX-NRSITZ-00004.null.xml \
	> Test/ParlaMint-AT-en_1996-01-30-020-XX-NRSITZ-00004.notes.xml
mt-test2:
	perl ../Scripts/conllu2tei.pl \
	< taja/ParlaMint-AT.conllu.translated/1996/ParlaMint-AT_1996-01-30-020-XX-NRSITZ-00004.conllu \
	> Test/ParlaMint-AT-en_1996-01-30-020-XX-NRSITZ-00004.body.xml
mt-test1:
	#rm -fr Test/ParlaMint-AT.tmp/*
	$s outDir=Test/ParlaMint-AT.tmp -xsl:../Scripts/mt-prepare4mt.xsl ${SOURCE}/ParlaMint-AT.TEI.ana/ParlaMint-AT.ana.xml 

# Producing almost XX-en, uses CORPUS variable
mt-prep-nohup:
	nohup time make mt-prep-cnv > Logs/ParlaMint-${CORPUS}-mt2tei.log &
mt-prep-cnv:
	perl ../Scripts/mt-conllu2tei.pl \
	${SOURCE}/ParlaMint-${CORPUS}.TEI.ana/ParlaMint-${CORPUS}.ana.xml \
	${SOURCE-MT}/ParlaMint-${CORPUS}-en-notes.tsv \
	${SOURCE-MT}/ParlaMint-${CORPUS}-en.conllu \
	Test/ParlaMint-${CORPUS}-en.TEI.ana

###################### SCRIPT VARIABLES
#s = java -jar -Xmx240g /usr/share/java/saxon.jar
s = java -jar /usr/share/java/saxon.jar
j = java -jar /usr/share/java/jing.jar
P = parallel --gnu --halt 2

pc = -I % $s -xi -xsl:../Scripts/copy.xsl % | $j parla-clarin.rng
vrt = $j ${SCH}/ParlaMint-teiCorpus.rng 	# Corpus root / text
vct = $j ${SCH}/ParlaMint-TEI.rng		# Corpus component / text
vra = $j ${SCH}/ParlaMint-teiCorpus.ana.rng	# Corpus root / analysed
vca = $j ${SCH}/ParlaMint-TEI.ana.rng		# Corpus component / analysed
vlo = $j ${SCH}/ParlaMint-listOrg.rng		# Corpus organisation list
vlp = $j ${SCH}/ParlaMint-listPerson.rng	# Corpus person list
vta = $j ${SCH}/ParlaMint-taxonomy.rng		# Corpus taxonomy
