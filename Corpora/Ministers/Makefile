MC = BA
V2  = /project/corpora/Parla/ParlaMint/V2/MasterV2.1
V3  = /project/corpora/Parla/ParlaMint/ParlaMint-V3/Corpora/Master
OUT = tmp

analyse:
	grep ERROR ParlaMint_*.log > Ministers-errors.log

## Generate TSV .auto files for minister affiliations
genV2:
	$s outDir=. -xsl:${RUN}/ministers-tei2tsv.xsl ${V2}/ParlaMint.xml
genV3:
	$s outDir=. -xsl:${RUN}/ministers-tei2tsv.xsl ${V3}/ParlaMint.xml

## Generate speaker file
PER = ParlaMint_speakers-${MC}.tsv
gen-persons-v2:
	$s -xsl:${RUN}/parlamint2tbl-persons.xsl ${V2}/ParlaMint-${MC}.TEI/ParlaMint-${MC}.xml > ${PER}
gen-persons-v3:
	#mv ${PER} ${PER}.v2
	$s -xsl:${RUN}/parlamint2tbl-persons.xsl ${V3}/ParlaMint-${MC}.TEI/ParlaMint-${MC}.xml > ${PER}
	#diff ${PER} ${PER}.v2


## Insert minister affiliations from TSV file into a testing root file.
insert-ministers-v2:
	$s tsv=../Corpora/Ministers/ParlaMint_ministers-${MC}.edited.tsv -xsl:${RUN}/ministers-tsv2tei.xsl \
	${V2}/ParlaMint-${MC}.TEI/ParlaMint-${MC}.xml \
	> ${OUT}/ParlaMint-${MC}.xml 2> ParlaMint_ministers-${MC}.log
	#${vrt} ${OUT}/ParlaMint-${MC}.xml
	${s} -xsl:${RUN}/check-links.xsl ${OUT}/ParlaMint-${MC}.xml
insert-ministers-v3:
	cp ${V3}/ParlaMint-${MC}.TEI/*.xml ${OUT}/ #copy factorised files
	$s meta=${V3}/ParlaMint-${MC}.TEI/ParlaMint-${MC}.xml tsv=../Corpora/Ministers/ParlaMint_ministers-${MC}.edited.tsv \
	-xsl:${RUN}/ministers-tsv2tei.xsl ${V3}/ParlaMint-${MC}.TEI/ParlaMint-${MC}-listPerson.xml \
	2> ParlaMint_ministers-${MC}.log | ${RUN}/polish-xml.pl > ${OUT}/ParlaMint-${MC}-listPerson.xml 
	${vrp} ${OUT}/ParlaMint-${MC}-listPerson.xml
	${s} meta=${V3}/ParlaMint-${MC}.TEI/ParlaMint-${MC}.xml -xsl:${RUN}/check-links.xsl ${OUT}/ParlaMint-${MC}-listPerson.xml
	-diff -b ${V3}/ParlaMint-${MC}.TEI/ParlaMint-${MC}-listPerson.xml ${OUT}/ParlaMint-${MC}-listPerson.xml


## All corpora with edited minster TSVs
# MCS = BA BE ES HR LT LV PL RS SI TR  #ES, LT missing corpora, TR has both auto and edited, check diff!!
MCS = BA BE HR LV PL RS SI
insert-all-ministers-v3:
	for MC in ${MCS}; do \
	cp ${V3}/ParlaMint-$${MC}.TEI/*.xml ${OUT}/; \
	$s meta=${V3}/ParlaMint-$${MC}.TEI/ParlaMint-$${MC}.xml tsv=../Corpora/Ministers/ParlaMint_ministers-$${MC}.edited.tsv \
	-xsl:${RUN}/ministers-tsv2tei.xsl ${V3}/ParlaMint-$${MC}.TEI/ParlaMint-$${MC}-listPerson.xml \
	2> ParlaMint_ministers-$${MC}.log | ${RUN}/polish-xml.pl > ${OUT}/ParlaMint-$${MC}-listPerson.xml; \
	${vrp} ${OUT}/ParlaMint-$${MC}-listPerson.xml; \
	${s} meta=${V3}/ParlaMint-$${MC}.TEI/ParlaMint-$${MC}.xml -xsl:${RUN}/check-links.xsl ${OUT}/ParlaMint-$${MC}-listPerson.xml; \
	diff -b ${V3}/ParlaMint-$${MC}.TEI/ParlaMint-$${MC}-listPerson.xml ${OUT}/ParlaMint-$${MC}-listPerson.xml; \
	done;

gen-all-persons-v3:
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
