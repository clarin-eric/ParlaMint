###### Makefile for generating and adding TSV metadata to ParlaMint XML listPerson and listOrg files.
###### Input files (TSV + XML) should be in ParlaMint-${CORPUS}/
###### Output files (listPerson XML + listOrg XML) are written to
###### ../Sources-TEI/ParlaMint-${CORPUS}.TEI/ and ../Sources-TEI/ParlaMint-${CORPUS}.TEI.ana/
######
###### The targets work for either one corpus, or all defined corpora for a TSV metadata type:
###### - generate initialised (on the basis of the corpus in ../Sources-TEI) TSV files, ready to be edited
###### - test insert all or some edited TSV metadata into XML, output goes to ./Test/
###### - insert all or some TSV metadata into XML, output goes to ../Sources-TEI/
######

### Corpus for targets that process only one corpus
CORPUS=AT

###### Adding all currently existing TSV metadata (+ transliteration) to corpora

### Corpora that exist and have metadata to be added (currently all of them):
META-CORPORA=AT BA BE BG CZ DK EE ES ES-CT ES-GA ES-PV FI FR GB GR HR HU IS IT LV NL NO PL PT RS SE SI TR UA

### Testing metadata insertion, output goes to Test/
test-insert-metadata:
	${BIN}/add-metadata.pl ${INDIR} Test/
test-insert-all-metadata:
	for CORPUS in ${META-CORPORA}; do \
	make test-insert-metadata CORPUS=$${CORPUS}; \
	done;

### MAIN TARGETS FOR METADATA INSERTION
### Applying insertion of all metadata, for one corpus
insert-metadata:
	${BIN}/add-metadata.pl ${INDIR} ${OUTDIR-TEI} 2>  ${INDIR}/Add-Metadata.log
	${BIN}/add-metadata.pl ${INDIR} ${OUTDIR-ANA} 2>> ${INDIR}/Add-Metadata.log
	-grep -a -i 'fatal' ${INDIR}/Add-Metadata.log | sort | uniq >  ${INDIR}/Add-Metadata.error.log
	-grep -a -i 'error' ${INDIR}/Add-Metadata.log | sort | uniq >> ${INDIR}/Add-Metadata.error.log
	-grep -a -i 'warn'  ${INDIR}/Add-Metadata.log | sort | uniq >  ${INDIR}/Add-Metadata.warn.log

### Applying metadata insertion, for all corpora
insert-all-metadata:
	for CORPUS in ${META-CORPORA}; do \
	make insert-metadata CORPUS=$${CORPUS}; \
	done;

### Do metadata insertion for all corpora in the background and log the result
nohup:
	nohup time make insert-all-metadata > Add-Metadata.log; \

####### Targets for generating initialised TSV files (then used for adding meta-data)
####### and for testing TSV insertion for a particular metadata layer

#### Processing ministers
# Corpora that have the edited minister TSV:
# Note that GB has this TSV, but already contains ministers, so we don't insert them!
MINI-CORPORA=BA BE EE ES-PV HR PL RS


## Generate TSV .auto files for minister affiliations
generate-ministers:
	$s xml=${MASTER}/${ORG} -xsl:${BIN}/ministers-tei2tsv.xsl \
	${MASTER}/${PERSON} > ParlaMint-${CORPUS}/Ministers-${CORPUS}.auto.tsv
generate-all-ministers:
	for CORPUS in ${MINI-CORPORA}; do \
	make generate-ministers CORPUS=$${CORPUS}; \
	done;

# Test insert of ministers
test-insert-ministers:
	$s tsv=${INDIR}/Ministers-${CORPUS}.edited.tsv xml=${INDIR}/${ORG} \
	-xsl:${BIN}/ministers-tsv2tei.xsl ${INDIR}/${PERSON} | ${BIN}/polish-xml.pl \
	> Test/${PERSON} 
	${vrp} Test/${PERSON}
	${BIN}/polish-xml.pl < ${INDIR}/${PERSON} > Test/${PERSON-CMP}
	-diff -b  Test/${PERSON-CMP} Test/${PERSON}
test-insert-all-ministers:
	for CORPUS in ${MINI-CORPORA}; do \
	make test-insert-ministers CORPUS=$${CORPUS}; \
	done;

####### Processing political orientations (encoder, Wiki, CHES)

# Works only for corpora that have all 3 orientations, i.e. BE, PT
test-insert-orientations:
	$s tsv=${INDIR}/Orientation-${CORPUS}.enco.tsv -xsl:${BIN}/enco-tsv2tei.xsl \
	${INDIR}/${ORG} | \
	$s tsv=${INDIR}/Orientation-${CORPUS}.CHES.tsv -xsl:${BIN}/ches-tsv2tei.xsl - | \
	$s tsv=${INDIR}/Orientation-${CORPUS}.Wiki.tsv -xsl:${BIN}/wiki-tsv2tei.xsl - | ${BIN}/polish-xml.pl \
	> Test/${ORG}
	${vro} Test/${ORG}
	${BIN}/polish-xml.pl < ${INDIR}/${ORG} > Test/${ORG-CMP}
	-diff -b Test/${ORG-CMP} Test/${ORG}

### Processing encoder orientation
# Corpora that have the encoder orientations TSV:
ENCO-CORPORA = BE PT UA

## Generate TSV .auto files for encoder orientations
generate-encoder:
	$s -xsl:${BIN}/enco-tei2tsv.xsl \
	${MASTER}/${ORG} > ParlaMint-${CORPUS}/Ministers-${CORPUS}.auto.tsv
generate-all-encoder:
	for CORPUS in ${ENCO-CORPORA}; do \
	make generate-ministers CORPUS=$${CORPUS}; \
	done;

test-insert-encoder:
	$s tsv=${INDIR}/OrientationEnco-${CORPUS}.edited.tsv -xsl:${BIN}/enco-tsv2tei.xsl \
	${INDIR}/${ORG} | ${BIN}/polish-xml.pl > Test/${ORG}
	${vro} Test/${ORG}
	${BIN}/polish-xml.pl < ${INDIR}/${ORG} > Test/${ORG}
	-diff -b Test/${ORG-CMP} Test/${ORG}
test-insert-all-encoder:
	for CORPUS in ${ENCO-CORPORA}; do \
	make test-insert-encoder CORPUS=$${CORPUS}; \
	done;

### Processing Wiki orientation
# Corpora that have the Wiki orientations TSV:
WIKI-CORPORA = AT BA BE BG CZ DK EE ES-CT ES-GA ES ES-PV FI FR GB GR HR HU IS IT LT LV NL NO PL PT RS SE SI TR UA
test-insert-wiki:
	$s tsv=${INDIR}/OrientationWiki-${CORPUS}.edited.tsv -xsl:${BIN}/wiki-tsv2tei.xsl \
	${INDIR}/${ORG} | ${BIN}/polish-xml.pl > Test/${ORG}
	-${vro} Test/${ORG}
	${BIN}/polish-xml.pl < ${INDIR}/${ORG} > Test/${ORG-CMP}
	-diff -b Test/${ORG-CMP} Test/${ORG}
test-insert-all-wiki:
	for CORPUS in ${WIKI-CORPORA}; do \
	make test-insert-wiki CORPUS=$${CORPUS}; \
	done;

### Processing CHES orientation
# Corpora that have the CHES orientations TSV:
CHES-CORPORA = AT BE BG CZ DK EE ES FI FR GB GR HR HU IS IT LT LV NL NO PL PT RO SE SI TR
test-insert-ches:
	$s tsv=${INDIR}/OrientationCHES-${CORPUS}.edited.tsv -xsl:${BIN}/ches-tsv2tei.xsl \
	${INDIR}/${ORG} | ${BIN}/polish-xml.pl > Test/${ORG}
	-${vro} Test/${ORG}
	${BIN}/polish-xml.pl < ${INDIR}/${ORG} > Test/${ORG-CMP}
	-diff -b Test/${ORG-CMP} Test/${ORG}
test-insert-all-ches:
	for CORPUS in ${CHES-CORPORA}; do \
	make test-insert-ches CORPUS=$${CORPUS}; \
	done;

## Processing Sex info
# Only corpora that we know how to auto-determine sex (and often don't have it)
SEX-CORPORA = BA HR RS

## Generate TSV .auto files for sex
generate-sex:
	$s -xsl:${BIN}/sex-tei2tsv.xsl ${MASTER}/${PERSON} > ParlaMint-${CORPUS}/Sex-${CORPUS}.auto.tsv
generate-all-sex:
	for CORPUS in ${SEX-CORPORA}; do \
	make generate-sex CORPUS=$${CORPUS}; \
	done;

#Auto-produce the fixed sex TSV file
#For other languages a different procedure would have to be written
fix-sex:
	${BIN}/slavic-sex.pl < ${INDIR}/Sex-${CORPUS}.auto.tsv >  ${INDIR}/Sex-${CORPUS}.edited.tsv
fix-all-sex:
	for CORPUS in ${SEX-CORPORA}; do \
	make fix-sex CORPUS=$${CORPUS}; \
	done;

test-insert-sex:
	$s tsv=${INDIR}/Sex-${CORPUS}.edited.tsv -xsl:${BIN}/sex-tsv2tei.xsl ${INDIR}/${PERSON} | ${BIN}/polish-xml.pl \
	> Test/${PERSON}
	-${vrp} Test/${PERSON}
	${BIN}/polish-xml.pl < ${INDIR}/${PERSON} > Test/${PERSON-CMP}
	-diff -b  Test/${PERSON-CMP} Test/${PERSON}
test-insert-all-sex:
	for CORPUS in ${SEX-CORPORA}; do \
	make test-insert-sex CORPUS=$${CORPUS}; \
	done;

inspect-sex:
	for CORPUS in ${SEX-CORPORA}; do \
	echo "In:" ; \
	cat Sex-$${CORPUS}.auto.tsv | cut -f1,5 | grep -v 'country' | sort | uniq -c ; \
	echo "Out:" ; \
	cat Sex-$${CORPUS}.edited.tsv | cut -f1,5 | grep -v 'country' | sort | uniq -c ; \
	done;
personname-bug:
	# Shows forenames that end in -ič, this indicates that surname has been encoded as forename
	cut -f 1,3 Sex-*.tsv | grep 'ić$$'

########## Download TSV files from external sources (overwrite existing), UA only
GSID-UA := 2PACX-1vRTvI3QU1_q3V8cyVHeDv_Uo_OSDwuwYlmQgNq6OMClZ3QN5-5xKQ1uv34GvWV9Mvorv8ul4qJQoyEU
GSID-UAwiki := 65847493
GSID-UAenco := 1425829794
download-UA:
	wget "https://docs.google.com/spreadsheets/d/e/$(GSID-UA)/pub?gid=$(GSID-UAwiki)&single=true&output=tsv" -O - \
	  | tr -d '\r' > ParlaMint-UA/Orientation-UA.Wiki.tsv
	wget "https://docs.google.com/spreadsheets/d/e/$(GSID-UA)/pub?gid=$(GSID-UAenco)&single=true&output=tsv" -O - \
	  | tr -d '\r' > ParlaMint-UA/Orientation-UA.enco.tsv

######## Support variables

### Variables for directories and files, should not be changed!
# Absolute path to ParlaMint directory
PARLAMINT := $(shell realpath ../.. | tr -d '\n')
# Absolute path to this directory
HERE = ${PARLAMINT}/Build/Sources-TSV
# Location of input listPerson and listOrg for a corpus
INDIR=${HERE}/ParlaMint-${CORPUS}
# Location of output listPerson and listOrg for a corpus
OUTDIR-TEI=../Sources-TEI/ParlaMint-${CORPUS}.TEI
OUTDIR-ANA=../Sources-TEI/ParlaMint-${CORPUS}.TEI.ana
# We assume the master directory listPerson and listOrg is the TEI dir
MASTER=${OUTDIR-TEI}

# listPerson XML file for a corpus
PERSON=ParlaMint-${CORPUS}-listPerson.xml
# for comparison purpuses
PERSON-CMP=ParlaMint-${CORPUS}-listPerson.orig.xml
# listOrg XML file for a corpus
ORG=ParlaMint-${CORPUS}-listOrg.xml
# for comparison purpuses
ORG-CMP=ParlaMint-${CORPUS}-listOrg.xml

# Location of scripts
BIN=../Scripts
# Location of XML schemas for output validation 
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
