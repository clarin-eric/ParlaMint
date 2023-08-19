######## Merge taxonomies

TAXONOMIES-TEI = subcorpus speaker_types parla.legislature
TAXONOMIES-ANA = NER

merge-taxos-nohup:
	nohup time make merge-taxos 2> Taxonomies/ParlaMint-taxonomy-merge.log > Logs/ParlaMint-taxonomy.log &

merge-taxos:
	for TAXONOMY in ${TAXONOMIES-TEI}; do \
	$s template=../Corpora/Taxonomies/ParlaMint-taxonomy-$${TAXONOMY}.template.xml \
	-xsl:../Scripts/parlamint-merge-taxonomy.xsl Master/ParlaMint.xml \
	> Taxonomies/ParlaMint-taxonomy-$${TAXONOMY}.xml; \
	done;
	for TAXONOMY in ${TAXONOMIES-ANA}; do \
	$s template=../Corpora/Taxonomies/ParlaMint-taxonomy-$${TAXONOMY}.ana.template.xml \
	-xsl:../Scripts/parlamint-merge-taxonomy.xsl Master/ParlaMint.ana.xml \
	> Taxonomies/ParlaMint-taxonomy-$${TAXONOMY}.ana.xml; \
	done;
	${vta} Taxonomies/ParlaMint-taxonomy-*.xml

############### Makefile for making a distributable version of the ParlaMint and ParlaMint-en corpora

### VARIABLES

# All ParlaMint II corpora
# CORPORA = AT BA BE BG CZ DK EE ES ES-CT ES-GA ES-PV FI FR GB GR HR HU IS IT LT LV NL NO PL PT RS RO SE SI TR UA
# Missing corpora: FI LT RO ES-PV

######## SUBMITTED CORPORA FOR V 3.1
# CORPORA = AT BA BE BG CZ DK EE ES ES-CT ES-GA FR GB GR HR HU IS IT LV NL NO PL PT RS SE SI TR UA

# Partial runs:
CORPORA = CZ

######## MTed CORPORA FOR V 3.1
MT-CORPORA = AT-en BA-en BE-en BG-en CZ-en DK-en EE-en ES-en ES-CT-en ES-GA-en FR-en GR-en HR-en HU-en IS-en IT-en LV-en NL-en NO-en PL-en PT-en RS-en SE-en SI-en TR-en UA-en

# Used in test targets:
CORPUS = UA

#Where things are, as we use several branches: this one (most likely dev), and documentation
PARLAMINT = /project/corpora/Parla/ParlaMint/ParlaMint
SCH = ${PARLAMINT}/Schema
HERE = ${PARLAMINT}/Corpora
TEMP = ${HERE}/Temp

#Where the submitted corpora are found (ParlaMint- .TEI/ and .TEI.ana/
SOURCES = ${HERE}/Sources-TEI
SOURCES-MT = ${HERE}/Sources-MT

# Version number and PID of next(!) TEI and TEI.ana ParlaMint release
VERSION = 3.1
HANDLE-TEI = http://hdl.handle.net/11356/1859
HANDLE-ANA = http://hdl.handle.net/11356/1860

# Version number and PID of next MTed ParlaMint-en.ana release
VERSION-MT = 3.1
HANDLE-MT = http://hdl.handle.net/11356/1864

#Where the produced corpora are put for inspection
WEB = tomaz@nl.ijs.si:/home/tomaz/www/tmp/ParlaMint/

###### Targets

### Fixes for 3.1-en:

# Instead of TEI-derived CoNLL-U files we release original MTed CoNLL-U
# because it contains word alignments 
# Script also adds -en suffix to filesnames + readme.
mt-cp-conllu:
	bin/cp-conllu.pl validate '${SOURCES-MT}/ParlaMint-*-en.conllu' 'Master'

# Make txt and tsv files with tsvs
mt-convert-txt:
	for CORPUS in ${CORPORA}; do \
	${FINALIZE-MT} -txt -conll -codes $${CORPUS}-en -out ${HERE}/Master; \
	done;

### Fixes for 3.0:
# Merge per-language translated CoNLL-Us (BE, ES-CT, UA) to joint CoNLL-Us
mrg-conll-nohup:
	nohup time make mrg-conll > Logs/ParlaMint_Merge_CoNLL-U.log &
mrg-conll:
	bin/merge-conllu.pl Master/ParlaMint-BE.conllu ${SOURCES-MT}/ParlaMint-BE-en.conllu
	bin/merge-conllu.pl Master/ParlaMint-ES-CT.conllu ${SOURCES-MT}/ParlaMint-ES-CT-en.conllu
	bin/merge-conllu.pl Master/ParlaMint-UA.conllu ${SOURCES-MT}/ParlaMint-UA-en.conllu

# Fix a mistake with handle in corpora
fix-handle:
	for CORPUS in ${CORPORA}; do \
	bin/fix-handle.pl "Master/ParlaMint-$${CORPUS}.TEI.ana/ParlaMint-$${CORPUS}.ana.xml"; \
	bin/fix-handle.pl "Master/ParlaMint-$${CORPUS}.TEI.ana/*/*.ana.xml"; \
	done;

# Copy READMEs to master
cp-readmes:
	bin/cp-readmes.pl -codes "${CORPORA}" -version ${VERSION} -teihandle ${HANDLE-TEI} -anahandle ${HANDLE-ANA} \
	-docs Docs -out ${HERE}/Master

# Make samples only
samples:
	for CORPUS in ${CORPORA}; do \
	${FINALIZE} -sample -codes $${CORPUS} -in ${SOURCES} -out ${HERE}/Master 2> Logs/ParlaMint-$${CORPUS}.log; \
	grep -a -i 'error' Logs/ParlaMint-$${CORPUS}.log > Logs/ParlaMint-$${CORPUS}.error.log;  \
	grep -a -i 'warn'  Logs/ParlaMint-$${CORPUS}.log > Logs/ParlaMint-$${CORPUS}.warn.log;  \
	done;

# Make vertical files only
make-verts:
	for CORPUS in ${CORPORA}; do \
	${FINALIZE} -vert -codes $${CORPUS} -in ${SOURCES} -out ${HERE}/Master; \
	done;
	make verts

# Make overall root(.ana) for ParlaMint
make-root:
	$s base=${HERE}/Master -xsl:../Scripts/parlamint2root.xsl \
	../Scripts/ParlaMint-template.xml > ${HERE}/Master/ParlaMint.xml
	$s base=${HERE}/Master -xsl:../Scripts/parlamint2root.xsl \
	../Scripts/ParlaMint-template.ana.xml > ${HERE}/Master/ParlaMint.ana.xml

mt-make-root:
	$s base=${HERE}/Master -xsl:../Scripts/parlamint2root.xsl \
	../Scripts/ParlaMint-template-en.ana.xml > ${HERE}/Master/ParlaMint-en.ana.xml

cp-samples:
	# bin/cp-samples.pl 'Master/Sample-ParlaMint-*-en' Test
	bin/cp-samples.pl 'Master/Sample-ParlaMint-*-en' ../Samples

mt-logs:
	for CORPUS in ${CORPORA}; do \
	grep -a -i 'error' Logs/ParlaMint-$${CORPUS}-en.log > Logs/ParlaMint-$${CORPUS}-en.error.log;  \
	grep -a -i 'warn'  Logs/ParlaMint-$${CORPUS}-en.log > Logs/ParlaMint-$${CORPUS}-en.warn.log;  \
	done;

web-nohup:
	nice nohup time make web > ParlaMint-web &
web:
	rsync -av Logs/*.log ${WEB}/Logs
	rsync -av Packed/*.tgz ${WEB}/Repo

###### Targets for producing releasable version of ParlaMint corpora
FINALIZE = perl ../Scripts/parlamint2distro.pl -version ${VERSION} -teihandle ${HANDLE-TEI} -anahandle ${HANDLE-ANA} -schema ../Schema -docs Docs

### For real
nohup:
	nice nohup time make all > Logs/ParlaMint.log &

# Second nohup, in case we want several runs at once
# In which case CORPORA variable needs to be changed first!
nohup2:
	nice nohup time make all > Logs/ParlaMint.2.log &

all:	final verts
xall:	final verts pack

pack:
	perl ../Scripts/pack-parlamint.pl -codes '${CORPORA}' -in Master -out Packed
verts:
	perl ../Scripts/join-verts.pl -version ${VERSION} -codes '${CORPORA}' -in Master -out Verts
final:
	for CORPUS in ${CORPORA}; do \
	${FINALIZE} -all -codes $${CORPUS} -in ${SOURCES} -out ${HERE}/Master 2> Logs/ParlaMint-$${CORPUS}.log; \
	grep -a -i 'error' Logs/ParlaMint-$${CORPUS}.log > Logs/ParlaMint-$${CORPUS}.error.log;  \
	grep -a -i 'warn'  Logs/ParlaMint-$${CORPUS}.log > Logs/ParlaMint-$${CORPUS}.warn.log;  \
	echo "$${CORPUS}.warn"; \
	cat Logs/ParlaMint-$${CORPUS}.warn.log | wc -l;  \
	cat Logs/ParlaMint-$${CORPUS}.warn.log | sort | uniq | wc -l;  \
	echo "$${CORPUS}.error"; \
	cat Logs/ParlaMint-$${CORPUS}.error.log | wc -l;  \
	cat Logs/ParlaMint-$${CORPUS}.error.log | sort | uniq | wc -l;  \
	done;

###### Targets for producing MTed corpora
###### Input are a) original TEI.ana corpus, b) CoNLL-U of speech translations and c) list of translated notes

### Make MTed corpora

# Make distribution with:
FINALIZE-MT = perl ../Scripts/parlamint2distro.pl -version ${VERSION-MT} -anahandle ${HANDLE-MT} -schema ${PARLAMINT}/Schema -docs ${HERE}/Docs

# Targets
mt-nohup:
	nice nohup time make mt-all-final > Logs/ParlaMint-en.log &
mt-all-final:	mt-convert
mt-xall-final:	mt-init mt-convert mt-verts mt-pack mt-web

mt-web:
	rsync -av Logs/*-en*.log ${WEB}/Logs
	rsync -av Packed/*-en*.tgz ${WEB}/Repo
mt-pack:
	perl ../Scripts/pack-parlamint.pl -codes '${MT-CORPORA}' -in Master -out Packed

### Make joint vert for all ParlaMint corpora

# Make MT vertical files only
mt-make-verts:
	for CORPUS in ${CORPORA}; do \
	${FINALIZE} -vert -codes $${CORPUS}-en -out ${HERE}/Master; \
	done;
	make mt-verts

# Join verts only
mt-verts:
	perl ../Scripts/join-all-verts.pl     -codes '${CORPORA}' -in 'Master' -out Verts/ParlaMint-XX.3.0.vert
	perl ../Scripts/join-all-verts.pl -en -codes '${CORPORA}' -in 'Master' -out Verts/ParlaMint-XX-en.3.0.vert
	# Sanity check
	zcat Verts/ParlaMint-XX.3.0.vert.gz | grep -c '</s>' 
	zcat Verts/ParlaMint-XX-en.3.0.vert.gz | grep -c '</s>' 

# Convert from English CoNLL-U + source .TEI.ana -> -en.TEI.ana 
mt-convert:
	for CORPUS in ${CORPORA}; do \
	perl ../Scripts/mt-conllu2tei.pl \
	${HERE}/Master/ParlaMint-$${CORPUS}.TEI.ana/ParlaMint-$${CORPUS}.ana.xml \
	${SOURCES-MT}/ParlaMint-$${CORPUS}-en-notes.tsv \
	${SOURCES-MT}/ParlaMint-$${CORPUS}-en.conllu \
	${TEMP}/ParlaMint-$${CORPUS}-en.TEI.ana 2> Logs/ParlaMint-$${CORPUS}-en.log; \
	${FINALIZE-MT} -all -notei -noconll -codes $${CORPUS}-en -in ${TEMP} -out ${HERE}/Master \
	2>> Logs/ParlaMint-$${CORPUS}-en.log; \
	grep -a -i 'error' Logs/ParlaMint-$${CORPUS}-en.log > Logs/ParlaMint-$${CORPUS}-en.error.log;  \
	grep -a -i 'warn'  Logs/ParlaMint-$${CORPUS}-en.log > Logs/ParlaMint-$${CORPUS}-en.warn.log;  \
	done;

### Tests for debugging MT processing

mt-test9:
	perl ../Scripts/mt-conllu2tei.pl \
	${HERE}/Master/ParlaMint-LV.TEI.ana/ParlaMint-LV.ana.xml \
	${SOURCES-MT}/ParlaMint-LV-en-notes.tsv \
	Sources-Sem/Test/ParlaMint-LV-en.conllu \
	${TEMP}/ParlaMint-LV-en.TEI.ana
	${FINALIZE-MT} -all -notei -noconll -codes LV-en -in ${TEMP} -out ${HERE}/Test

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
	Test/ParlaMint-AT-en_1996-01-30-020-XX-NRSITZ-00004.null.xml \
	> Test/ParlaMint-AT-en_1996-01-30-020-XX-NRSITZ-00004.notes.xml
mt-test2a:
	perl ../Scripts/conllu2tei.pl < Test/0.conllu > Test/0.body.xml
mt-test2:
	perl ../Scripts/conllu2tei.pl \
	< ${SOURCES-MT}/ParlaMint-LV-en.conllu/2015/ParlaMint-LV_2015-11-12-PT12-329.conllu \
	> Test/ParlaMint-LV_2015-11-12-PT12-329.body.xml
	xmllint --noout Test/ParlaMint-LV_2015-11-12-PT12-329.body.xml
mt-test1:
	rm -fr Test/ParlaMint-CZ.tmp/*
	$s outDir=Test/ParlaMint-CZ.tmp -xsl:../Scripts/mt-prepare4mt.xsl ${HERE}/Master/ParlaMint-CZ.TEI.ana/ParlaMint-CZ.ana.xml

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
