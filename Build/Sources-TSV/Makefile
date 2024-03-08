###################### BETTER? VARIABLES
#Absolute paths are needed otherwise problems with XSLT
PARLAMINT := $(shell realpath ../.. | tr -d '\n')# get real absolute path to ParlaMint directory
HERE = ${PARLAMINT}/Corpora/Sources-TEI
SCH = ${PARLAMINT}/Schema

###### Makefile for generating and test-adding TSV metadata to ParlaMint XML top-level files

# Corpus for targets that process only one
CORPUS=AT

#### Adding all TSV metadata (+ transliteration) from here to ../Sources-TEI
# Corpora that exist and have metadata to be added
META-CORPORA=AT BA BE BG CZ DK EE ES ES-CT ES-GA ES-PV FI FR GB GR HR HU IS IT LV NL NO PL PT RS SE SI TR UA

## Testing the approach, output goes to test/
test-insert-metadata:
	${BIN}/add-metadata.pl ${CORPDIR} test/
test-insert-all-metadata:
	for CORPUS in ${META-CORPORA}; do \
	make test-insert-metadata CORPUS=$${CORPUS}; \
	done;

insert-metadata:
	${BIN}/add-metadata.pl ${CORPDIR} ${OUTDIR} > ${CORPDIR}/Add-Metadata.log
	grep -a -i 'fatal' ${CORPDIR}/Add-Metadata.log >  ${CORPDIR}/Add-Metadata.error.log
	grep -a -i 'error' ${CORPDIR}/Add-Metadata.log >> ${CORPDIR}/Add-Metadata.error.log
	grep -a -i 'warn'  ${CORPDIR}/Add-Metadata.log >  ${CORPDIR}/Add-Metadata.warn.log

insert-all-metadata:
	for CORPUS in ${META-CORPORA}; do \
	make insert-metadata CORPUS=$${CORPUS}; \
	done;

### For everything & log result
nohup:
	nohup time make insert-all-metadata > Add-Metadata.log; \

#### Targets for generating "empty" TSV files then used for adding meta-data
#### and for testing for a particular metadata layer

#### Processing ministers
# Corpora that have the edited minister TSV:
MINI-CORPORA=BA BE EE ES-PV GB HR PL RS

# Input ParlaMint-XX-listPerson.xml and ParlaMint-XX-listOrg.xml
LISTPERSON=ParlaMint-${CORPUS}/ParlaMint-${CORPUS}-listPerson.xml
LISTORG=ParlaMint-${CORPUS}/ParlaMint-${CORPUS}-listOrg.xml
CORPDIR=${HERE}/ParlaMint-${CORPUS}

## Generate TSV .auto files for minister affiliations
generate-ministers:
	$s xml=${HERE}/${LISTORG} -xsl:${BIN}/ministers-tei2tsv.xsl \
	${LISTPERSON} > ParlaMint-${CORPUS}/Ministers-${CORPUS}.auto.tsv
generate-all-ministers:
	for CORPUS in ${MINI-CORPORA}; do \
	make generate-ministers CORPUS=$${CORPUS}; \
	done;

# Test insert of ministers
test-insert-ministers:
	$s tsv=${CORPDIR}/Ministers-${CORPUS}.edited.tsv xml=${HERE}/${LISTORG} \
	-xsl:${BIN}/ministers-tsv2tei.xsl ${LISTPERSON} | ${BIN}/polish-xml.pl \
	> test/ParlaMint-${CORPUS}-listPerson.xml 
	${vrp} test/ParlaMint-${CORPUS}-listPerson.xml
	${BIN}/polish-xml.pl < ${LISTPERSON} > test/ParlaMint-${CORPUS}-listPerson.orig.xml
	-diff -b  test/ParlaMint-${CORPUS}-listPerson.orig.xml test/ParlaMint-${CORPUS}-listPerson.xml
test-insert-all-ministers:
	for CORPUS in ${MINI-CORPORA}; do \
	make test-insert-ministers CORPUS=$${CORPUS}; \
	done;

#### Processing orientations

# Works only for corpora that have all 3 orientations, i.e. BE, PT
test-insert-orientations:
	$s tsv=${CORPDIR}/Orientation-${CORPUS}.enco.tsv -xsl:${BIN}/enco-tsv2tei.xsl \
	${HERE}/${LISTORG} | \
	$s tsv=${CORPDIR}/Orientation-${CORPUS}.CHES.tsv -xsl:${BIN}/ches-tsv2tei.xsl - | \
	$s tsv=${CORPDIR}/Orientation-${CORPUS}.Wiki.tsv -xsl:${BIN}/wiki-tsv2tei.xsl - | ${BIN}/polish-xml.pl \
	> test/ParlaMint-${CORPUS}-listOrg.xml
	${vro} test/ParlaMint-${CORPUS}-listOrg.xml
	${BIN}/polish-xml.pl < ${HERE}/${LISTORG} > test/ParlaMint-${CORPUS}-listOrg.orig.xml
	-diff -b test/ParlaMint-${CORPUS}-listOrg.orig.xml test/ParlaMint-${CORPUS}-listOrg.xml

## Encoder orientation
# Only corpora that have the encoder orientations TSV:
ENCO-CORPORA = BE PT UA
test-insert-encoder:
	$s tsv=${CORPDIR}/Orientation-${CORPUS}.enco.tsv -xsl:${BIN}/enco-tsv2tei.xsl \
	${HERE}/${LISTORG} | ${BIN}/polish-xml.pl > test/ParlaMint-${CORPUS}-listOrg.xml
	${vro} test/ParlaMint-${CORPUS}-listOrg.xml
	${BIN}/polish-xml.pl < ${HERE}/${LISTORG} > test/ParlaMint-${CORPUS}-listOrg.orig.xml
	-diff -b test/ParlaMint-${CORPUS}-listOrg.orig.xml test/ParlaMint-${CORPUS}-listOrg.xml
test-insert-all-encoder:
	for CORPUS in ${ENCO-CORPORA}; do \
	make test-insert-encoder CORPUS=$${CORPUS}; \
	done;

## Wiki orientation
# Only corpora that have the Wiki orientations TSV:
WIKI-CORPORA = AT BA BE BG CZ DK EE ES-CT ES-GA ES ES-PV FI FR GB GR HR HU IS IT LT LV NL NO PL PT RS SE SI TR UA
test-insert-wiki:
	$s tsv=${CORPDIR}/Orientation-${CORPUS}.Wiki.tsv -xsl:${BIN}/wiki-tsv2tei.xsl \
	${HERE}/${LISTORG} | ${BIN}/polish-xml.pl > test/ParlaMint-${CORPUS}-listOrg.xml
	-${vro} test/ParlaMint-${CORPUS}-listOrg.xml
	${BIN}/polish-xml.pl < ${HERE}/${LISTORG} > test/ParlaMint-${CORPUS}-listOrg.orig.xml
	-diff -b test/ParlaMint-${CORPUS}-listOrg.orig.xml test/ParlaMint-${CORPUS}-listOrg.xml
test-insert-all-wiki:
	for CORPUS in ${WIKI-CORPORA}; do \
	make test-insert-wiki CORPUS=$${CORPUS}; \
	done;

## CHES orientation
# Only corpora that have the CHES orientations TSV:
CHES-CORPORA = AT BE BG CZ DK EE ES FI FR GB GR HR HU IS IT LT LV NL NO PL PT RO SE SI TR
test-insert-ches:
	$s tsv=${CORPDIR}/Orientation-${CORPUS}.CHES.tsv -xsl:${BIN}/ches-tsv2tei.xsl \
	${HERE}/${LISTORG} | ${BIN}/polish-xml.pl > test/ParlaMint-${CORPUS}-listOrg.xml
	-${vro} test/ParlaMint-${CORPUS}-listOrg.xml
	${BIN}/polish-xml.pl < ${HERE}/${LISTORG} > test/ParlaMint-${CORPUS}-listOrg.orig.xml
	-diff -b test/ParlaMint-${CORPUS}-listOrg.orig.xml test/ParlaMint-${CORPUS}-listOrg.xml
test-insert-all-ches:
	for CORPUS in ${CHES-CORPORA}; do \
	make test-insert-ches CORPUS=$${CORPUS}; \
	done;

## Sex info
# Only corpora that we know how to auto-determine sex (and often don't have it)
SEX-CORPORA = BA HR RS

## Generate TSV .auto files for sex
generate-sex:
	$s -xsl:${BIN}/sex-tei2tsv.xsl ${LISTPERSON} > ParlaMint-${CORPUS}/Sex-${CORPUS}.auto.tsv
generate-all-sex:
	for CORPUS in ${SEX-CORPORA}; do \
	make generate-sex CORPUS=$${CORPUS}; \
	done;

#Auto-produce the fixed sex TSV file
#For other languages a different procedure would have to be written
fix-sex:
	${BIN}/slavic-sex.pl < ${CORPDIR}/Sex-${CORPUS}.auto.tsv >  ${CORPDIR}/Sex-${CORPUS}.fixed.tsv
fix-all-sex:
	for CORPUS in ${SEX-CORPORA}; do \
	make fix-sex CORPUS=$${CORPUS}; \
	done;

test-insert-sex:
	$s tsv=${CORPDIR}/Sex-${CORPUS}.fixed.tsv -xsl:${BIN}/sex-tsv2tei.xsl ${LISTPERSON} | ${BIN}/polish-xml.pl \
	> test/ParlaMint-${CORPUS}-listPerson.xml
	-${vrp} test/ParlaMint-${CORPUS}-listPerson.xml
	${BIN}/polish-xml.pl < ${LISTPERSON} > test/ParlaMint-${CORPUS}-listPerson.orig.xml
	-diff -b  test/ParlaMint-${CORPUS}-listPerson.orig.xml test/ParlaMint-${CORPUS}-listPerson.xml
test-insert-all-sex:
	for CORPUS in ${SEX-CORPORA}; do \
	make test-insert-sex CORPUS=$${CORPUS}; \
	done;

inspect-sex:
	for CORPUS in ${SEX-CORPORA}; do \
	echo "In:" ; \
	cat Sex-$${CORPUS}.auto.tsv | cut -f1,5 | grep -v 'country' | sort | uniq -c ; \
	echo "Out:" ; \
	cat Sex-$${CORPUS}.fixed.tsv | cut -f1,5 | grep -v 'country' | sort | uniq -c ; \
	done;
personname-bug:
	# Shows forenames that end in -ič, this indicates that surname has been encoded as forename
	cut -f 1,3 Sex-*.tsv | grep 'ić$$'

########## Download TSV files from external sources (overwrite existing)
GSID-UA := 2PACX-1vRTvI3QU1_q3V8cyVHeDv_Uo_OSDwuwYlmQgNq6OMClZ3QN5-5xKQ1uv34GvWV9Mvorv8ul4qJQoyEU
GSID-UAwiki := 65847493
GSID-UAenco := 1425829794
download-UA:
	wget "https://docs.google.com/spreadsheets/d/e/$(GSID-UA)/pub?gid=$(GSID-UAwiki)&single=true&output=tsv" -O - \
	  | tr -d '\r' > ParlaMint-UA/Orientation-UA.Wiki.tsv
	wget "https://docs.google.com/spreadsheets/d/e/$(GSID-UA)/pub?gid=$(GSID-UAenco)&single=true&output=tsv" -O - \
	  | tr -d '\r' > ParlaMint-UA/Orientation-UA.enco.tsv

######## Variables

####  Needed directories
# $HERE assumes that the Makefile is run from this directory!
HERE=$(shell pwd)
BIN=../Scripts
OUTDIR=../Sources-TEI
SCH=../../Schema

#### Prerequsites
P = parallel --citation --gnu --halt 2
s = java -jar ../../Scripts/bin/saxon.jar
j = java -jar ../../Scripts/bin/jing.jar

# Validate with Parla-CLARIN schema
pc =  $j ${SCH}/parla-clarin.rng
# Validate with Parla-CLARIN schema
odd =  $j ${SCH}/ParlaMint.odd.rng
# Corpus root / text
vrt = $j ${SCH}/ParlaMint-teiCorpus.rng
# Corpus root / analysed
vra = $j ${SCH}/ParlaMint-teiCorpus.ana.rng
# Corpus listPerson
vrp = $j ${SCH}/ParlaMint-listPerson.rng
# Corpus listOrg
vro = $j ${SCH}/ParlaMint-listOrg.rng
