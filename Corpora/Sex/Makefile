MCS = BA HR RS

bug:
	cut -f 1,3 personSex-*.tsv | grep 'ić$$'
nohup:
	nohup time make all > sex.log &
all:	gen-sex fix-sex
fix-sex:
	for MC in ${MCS}; do \
	make-sex.pl < personSex-$${MC}.auto.tsv >  personSex-$${MC}.fixed.tsv ; \
	done;
ana:
	for MC in ${MCS}; do \
	cat personSex-$${MC}.auto.tsv | cut -f1,5 | grep -v 'Country' | sort | uniq -c ; \
	done;
## Generate TSV .auto files for sex
gen-sex:
	for MC in ${MCS}; do \
	$s -xsl:${RUN}/sex-tei2tsv.xsl ${V4}/ParlaMint-$${MC}.TEI/ParlaMint-$${MC}-listPerson.xml > personSex-$${MC}.auto.tsv ; \
	done;

######################VARIABLES
RUN = ../../Scripts
SCH = ../../Schema
V4  = /project/corpora/Parla/ParlaMint/ParlaMint/Corpora/Master
s = java -jar ${RUN}/bin/saxon.jar
j = java -jar ${RUN}/bin/jing.jar
# Validate with Parla-CLARIN schema
pc =  $j ${SCH}/parla-clarin.rng
# Corpus root / text
vrt = $j ${SCH}/ParlaMint-teiCorpus.rng
# Corpus root / analysed
vra = $j ${SCH}/ParlaMint-teiCorpus.ana.rng
# Corpus listPerson
vrp = $j ${SCH}/ParlaMint-listPerson.rng
