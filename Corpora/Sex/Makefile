### Testing targets
MC = RS
test-sex:
	$s tsv=${HERE}/personSex-${MC}.fixed.tsv -xsl:${RUN}/sex-tsv2tei.xsl \
	${DATA}/ParlaMint-${MC}.TEI/ParlaMint-${MC}-listPerson.xml | ${RUN}/polish-xml.pl \
	> tmp/ParlaMint-${MC}-listPerson.xml
	-${vrp} tmp/ParlaMint-${MC}-listPerson.xml
	-${odd} tmp/ParlaMint-${MC}-listPerson.xml
	-${pc} tmp/ParlaMint-${MC}-listPerson.xml
	-diff -b ${DATA}/ParlaMint-${MC}.TEI/ParlaMint-${MC}-listPerson.xml tmp/ParlaMint-${MC}-listPerson.xml

MCS = BA HR RS
bug:
	cut -f 1,3 personSex-*.tsv | grep 'ić$$'
ana:
	for MC in ${MCS}; do \
	echo "In:" ; \
	cat personSex-$${MC}.auto.tsv | cut -f1,5 | grep -v 'country' | sort | uniq -c ; \
	echo "Out:" ; \
	cat personSex-$${MC}.fixed.tsv | cut -f1,5 | grep -v 'country' | sort | uniq -c ; \
	done;
nohup:
	nohup time make all > sex.log &
all:	gen-sex fix-sex
fix-sex:
	for MC in ${MCS}; do \
	determine-sex.pl < personSex-$${MC}.auto.tsv >  personSex-$${MC}.fixed.tsv ; \
	done;

## Generate TSV .auto files for sex
gen-sex:
	for MC in ${MCS}; do \
	$s -xsl:${RUN}/sex-tei2tsv.xsl ${DATA}/ParlaMint-$${MC}.TEI/ParlaMint-$${MC}-listPerson.xml > personSex-$${MC}.auto.tsv ; \
	done;

####  Needed directories
HERE = `pwd`
DATA = ${HERE}/../Master
RUN = ../../Scripts
SCH = ../../Schema
OUT = tmp

#### XML
s = java -jar ${RUN}/bin/saxon.jar
j = java -jar ${RUN}/bin/jing.jar
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
