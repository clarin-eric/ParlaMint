### Testing targets
MC = PT
test-tsv2tei:
	$s tsv=${HERE}/Orientation-${MC}.enco.tsv -xsl:${RUN}/enco-tsv2tei.xsl \
	${DATA}/ParlaMint-${MC}.TEI/ParlaMint-${MC}-listOrg.xml | \
	$s tsv=${HERE}/Orientation-${MC}.CHES.tsv -xsl:${RUN}/ches-tsv2tei.xsl - | \
	$s tsv=${HERE}/Orientation-${MC}.Wiki.tsv -xsl:${RUN}/wiki-tsv2tei.xsl - | ${RUN}/polish-xml.pl \
	> tmp/ParlaMint-${MC}-listOrg.xml
	${vro} tmp/ParlaMint-${MC}-listOrg.xml
	-diff -b ${DATA}/ParlaMint-${MC}.TEI/ParlaMint-${MC}-listOrg.xml tmp/ParlaMint-${MC}-listOrg.xml
test-enco:
	$s tsv=${HERE}/Orientation-${MC}.enco.tsv -xsl:${RUN}/enco-tsv2tei.xsl \
	${DATA}/ParlaMint-${MC}.TEI/ParlaMint-${MC}-listOrg.xml | ${RUN}/polish-xml.pl \
	> tmp/ParlaMint-${MC}-listOrg.xml
	${vro} tmp/ParlaMint-${MC}-listOrg.xml
	-diff -b ${DATA}/ParlaMint-${MC}.TEI/ParlaMint-${MC}-listOrg.xml tmp/ParlaMint-${MC}-listOrg.xml
test-wiki:
	$s tsv=${HERE}/Orientation-${MC}.Wiki.tsv -xsl:${RUN}/wiki-tsv2tei.xsl \
	${DATA}/ParlaMint-${MC}.TEI/ParlaMint-${MC}-listOrg.xml | ${RUN}/polish-xml.pl > tmp/ParlaMint-${MC}-listOrg.xml
	${vro} tmp/ParlaMint-${MC}-listOrg.xml
	-diff -b ${DATA}/ParlaMint-${MC}.TEI/ParlaMint-${MC}-listOrg.xml tmp/ParlaMint-${MC}-listOrg.xml
test-ches:
	$s tsv=${HERE}/Orientation-${MC}.CHES.tsv -xsl:${RUN}/ches-tsv2tei.xsl \
	${DATA}/ParlaMint-${MC}.TEI/ParlaMint-${MC}-listOrg.xml | ${RUN}/polish-xml.pl > tmp/ParlaMint-${MC}-listOrg.xml
	${vro} tmp/ParlaMint-${MC}-listOrg.xml
	#-diff -b ${DATA}/ParlaMint-${MC}.TEI/ParlaMint-${MC}-listOrg.xml tmp/ParlaMint-${MC}-listOrg.xml

######### Test over all (relevant) corpora
#ENCO + CHES + WIKI corpora
CENCO = BE PT
#CHES + WIKI corpora
CCHES = AT BG CZ DK EE FR GB GR HR HU IS IT LV NL NO PL SE SI TR
#WIKI corpora
CWIKI = BA ES-CT ES-GA RS UA

test-all-metadata-nohup:
	nohup time make test-all-metadata 2> Orientation-tsv2tei.log > nohup.orientation.log &

test-all-metadata:	test-cenco-metadata test-cches-metadata test-cwiki-metadata
test-cenco-metadata:
	for CORPUS in ${CENCO}; do \
	$s tsv=${HERE}/Orientation-$${CORPUS}.enco.tsv -xsl:${RUN}/enco-tsv2tei.xsl \
	${DATA}/ParlaMint-$${CORPUS}.TEI/ParlaMint-$${CORPUS}-listOrg.xml | \
	$s tsv=${HERE}/Orientation-$${CORPUS}.CHES.tsv -xsl:${RUN}/ches-tsv2tei.xsl - | \
	$s tsv=${HERE}/Orientation-$${CORPUS}.Wiki.tsv -xsl:${RUN}/wiki-tsv2tei.xsl - | ${RUN}/polish-xml.pl \
	> tmp/ParlaMint-$${CORPUS}-listOrg.xml; \
	${vro} tmp/ParlaMint-$${CORPUS}-listOrg.xml; \
	done;
test-cches-metadata:
	for CORPUS in ${CCHES}; do \
	$s tsv=${HERE}/Orientation-$${CORPUS}.CHES.tsv -xsl:${RUN}/ches-tsv2tei.xsl \
	${DATA}/ParlaMint-$${CORPUS}.TEI/ParlaMint-$${CORPUS}-listOrg.xml | \
	$s tsv=${HERE}/Orientation-$${CORPUS}.Wiki.tsv -xsl:${RUN}/wiki-tsv2tei.xsl - | ${RUN}/polish-xml.pl \
	> tmp/ParlaMint-$${CORPUS}-listOrg.xml; \
	${vro} tmp/ParlaMint-$${CORPUS}-listOrg.xml; \
	done;
test-cwiki-metadata:
	for CORPUS in ${CORPORA}; do \
	$s tsv=${HERE}/Orientation-$${CORPUS}.Wiki.tsv -xsl:${RUN}/wiki-tsv2tei.xsl \
	${DATA}/ParlaMint-$${CORPUS}.TEI/ParlaMint-$${CORPUS}-listOrg.xml | ${RUN}/polish-xml.pl > tmp/ParlaMint-$${CORPUS}-listOrg.xml; \
	${vro} tmp/ParlaMint-$${CORPUS}-listOrg.xml; \
	done;

#All CHES corpora:
#CORPORA = AT BE BG CZ DK EE ES FI FR GB GR HR HU IS IT LT LV NL NO PL PT RO SE SI TR
#CHES corpora for current ParlaMint:
#CORPORA = AT BE BG CZ DK EE FR GB GR HR HU IS IT LV NL NO PL PT SE SI TR
#All ParlaMint submitted corpora (missing FI, LT, RO):
CORPORA = AT BA BE BG CZ DK EE ES ES-CT ES-GA FR GB GR HR HU IS IT LV NL NO PL PT RS SE SI TR UA
test-all-wiki:
	for CORPUS in ${CORPORA}; do \
	$s tsv=${HERE}/Orientation-$${CORPUS}.Wiki.tsv -xsl:${RUN}/wiki-tsv2tei.xsl \
	${DATA}/ParlaMint-$${CORPUS}.TEI/ParlaMint-$${CORPUS}-listOrg.xml | ${RUN}/polish-xml.pl > tmp/ParlaMint-$${CORPUS}-listOrg.xml; \
	${vro} tmp/ParlaMint-$${CORPUS}-listOrg.xml; \
	done;
test-all-ches:
	for CORPUS in ${CORPORA}; do \
	$s tsv=${HERE}/Orientation-$${CORPUS}.CHES.tsv -xsl:${RUN}/ches-tsv2tei.xsl \
	${DATA}/ParlaMint-$${CORPUS}.TEI/ParlaMint-$${CORPUS}-listOrg.xml | ${RUN}/polish-xml.pl > tmp/ParlaMint-$${CORPUS}-listOrg.xml; \
	${vro} tmp/ParlaMint-$${CORPUS}-listOrg.xml; \
	done;

## Generate TSV files with party information on the basis of the corpus root file.
generate-parties:
	$s path=${DATA} outDir=tmp -xsl:${RUN}/parties-tei2tsv.xsl \
	${DATA}/ParlaMint.xml 2> ParlaMint_parties.log

## Dump encoder info on political orientations from TEI to TSV
encoder:
	make encoder-BE encoder-PT encoder-UA 2> Orientation-enco.log
encoder-BE:
	$s -xsl:${RUN}/enco-tei2tsv.xsl ${DATA}/ParlaMint-BE.TEI/ParlaMint-BE-listOrg.xml > Orientation-BE.enco.tsv
encoder-PT:
	$s -xsl:${RUN}/enco-tei2tsv.xsl ${DATA}/ParlaMint-PT.TEI/ParlaMint-PT-listOrg.xml > Orientation-PT.enco.tsv
encoder-UA:
	$s -xsl:${RUN}/enco-tei2tsv.xsl ${DATA}/ParlaMint-UA.TEI/ParlaMint-UA-listOrg.xml > Orientation-UA.enco.tsv

## Download TSV files from external sources (overwrite existing)

GSID-UA := 2PACX-1vRTvI3QU1_q3V8cyVHeDv_Uo_OSDwuwYlmQgNq6OMClZ3QN5-5xKQ1uv34GvWV9Mvorv8ul4qJQoyEU
GSID-UAwiki := 65847493
GSID-UAenco := 1425829794

download-UA:
	wget "https://docs.google.com/spreadsheets/d/e/$(GSID-UA)/pub?gid=$(GSID-UAwiki)&single=true&output=tsv" -O - \
	  | tr -d '\r' > Orientation-UA.Wiki.tsv
	wget "https://docs.google.com/spreadsheets/d/e/$(GSID-UA)/pub?gid=$(GSID-UAenco)&single=true&output=tsv" -O - \
	  | tr -d '\r' > Orientation-UA.enco.tsv


######################VARIABLES

####  Needed directories
HERE = /project/corpora/Parla/ParlaMint/ParlaMint/Corpora/Orientations
DATA = /project/corpora/Parla/ParlaMint/ParlaMint/Corpora/Master
RUN = ../../Scripts
SCH = ../../Schema
OUT = tmp

#### XML
s = java -jar /usr/share/java/saxon.jar
j = java -jar /usr/share/java/jing.jar
# Validate with Parla-CLARIN schema
pc =  $j ${SCH}/parla-clarin.rng
# Corpus root / text
vrt = $j ${SCH}/ParlaMint-teiCorpus.rng
# Corpus root / analysed
vra = $j ${SCH}/ParlaMint-teiCorpus.ana.rng
# Corpus listPerson
vrp = $j ${SCH}/ParlaMint-listPerson.rng
# Corpus listOrg
vro = $j ${SCH}/ParlaMint-listOrg.rng

