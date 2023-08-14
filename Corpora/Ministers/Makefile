MC = BA
V3  = /project/corpora/Parla/ParlaMint/ParlaMint/Corpora/Master
OUT = tmp

analyse:
	grep ERROR ParlaMint_*.log > Ministers-errors.log

## Generate TSV .auto files for minister affiliations
gen-auto-ministers:
	$s outDir=. -xsl:${RUN}/ministers-tei2tsv.xsl ${V3}/ParlaMint.xml

## Generate speaker file
PER = ParlaMint_speakers-${MC}.tsv
gen-persons:
	#mv ${PER} ${PER}.tmp
	$s -xsl:${RUN}/parlamint2tbl-persons.xsl ${V3}/ParlaMint-${MC}.TEI/ParlaMint-${MC}.xml > ${PER}
	#diff ${PER} ${PER}.tmp

insert-ministers:
	cp ${V3}/ParlaMint-${MC}.TEI/*.xml ${OUT}/ #copy factorised files
	$s meta=${V3}/ParlaMint-${MC}.TEI/ParlaMint-${MC}.xml tsv=../Corpora/Ministers/ParlaMint_ministers-${MC}.edited.tsv \
	-xsl:${RUN}/ministers-tsv2tei.xsl ${V3}/ParlaMint-${MC}.TEI/ParlaMint-${MC}-listPerson.xml \
	2> ParlaMint_ministers-${MC}.log | ${RUN}/polish-xml.pl > ${OUT}/ParlaMint-${MC}-listPerson.xml 
	${vrp} ${OUT}/ParlaMint-${MC}-listPerson.xml
	${s} meta=${V3}/ParlaMint-${MC}.TEI/ParlaMint-${MC}.xml -xsl:${RUN}/check-links.xsl ${OUT}/ParlaMint-${MC}-listPerson.xml
	-diff -b ${V3}/ParlaMint-${MC}.TEI/ParlaMint-${MC}-listPerson.xml ${OUT}/ParlaMint-${MC}-listPerson.xml


## All corpora with edited minster TSVs
# MCS = BA BE ES HR LT LV PL RS SI TR  # LT missing corpus, TR has both auto and edited, check diff!!
# MCS = BA BE ES HR LV PL RS SI        # Only actual corpora
MCS = BA ES HR LV PL RS SI           # New corpora
insert-all-ministers:
	for MC in ${MCS}; do \
	cp ${V3}/ParlaMint-$${MC}.TEI/*.xml ${OUT}/; \
	$s meta=${V3}/ParlaMint-$${MC}.TEI/ParlaMint-$${MC}.xml tsv=../Corpora/Ministers/ParlaMint_ministers-$${MC}.edited.tsv \
	-xsl:${RUN}/ministers-tsv2tei.xsl ${V3}/ParlaMint-$${MC}.TEI/ParlaMint-$${MC}-listPerson.xml \
	2> ParlaMint_ministers-$${MC}.log | ${RUN}/polish-xml.pl > ${OUT}/ParlaMint-$${MC}-listPerson.xml; \
	${vrp} ${OUT}/ParlaMint-$${MC}-listPerson.xml; \
	${s} meta=${V3}/ParlaMint-$${MC}.TEI/ParlaMint-$${MC}.xml -xsl:${RUN}/check-links.xsl ${OUT}/ParlaMint-$${MC}-listPerson.xml; \
	diff -b ${V3}/ParlaMint-$${MC}.TEI/ParlaMint-$${MC}-listPerson.xml ${OUT}/ParlaMint-$${MC}-listPerson.xml; \
	done;

gen-all-persons:
	for MC in ${MCS}; do \
	$s -xsl:${RUN}/parlamint2tbl-persons.xsl ${V3}/ParlaMint-$${MC}.TEI/ParlaMint-$${MC}.xml > ParlaMint_speakers-$${MC}.tsv; \
	done;

######################VARIABLES
RUN = ../../Scripts
SCH = ../../Schema
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
