## Edited, still problems: BE ES HR LT LV PL SI TR?
## Not yet edited: BA BG RS
## Corpus already contains ministers: AT CZ DK GR HU IS NL NO PT SE SI TR
MC = BE
TSV = ../Data/Ministers/ParlaMint_ministers-${MC}.edited.tsv
V2  = /project/corpora/Parla/ParlaMint/V2/MasterV2.1
V3  = /project/corpora/Parla/ParlaMint/V3/Data
IN2 = ${V2}/ParlaMint-${MC}.TEI/ParlaMint-${MC}.xml
IN3 = ${V3}/ParlaMint-${MC}.TEI/ParlaMint-${MC}.xml
OUT = tmp

analyse:
	grep ERROR *.log > ParlaMint_ministers-XX-errors.log

## Generate TSV .auto files for minister affiliations
genV2:
	$s outDir=. -xsl:${RUN}/ministers-tei2tsv.xsl ${V2}/ParlaMint.xml
genV3:
	$s outDir=. -xsl:${RUN}/ministers-tei2tsv.xsl ${V3}/ParlaMint.xml

## Generate speaker file
PER = ParlaMint_speakers-${MC}.tsv
gen-persons-v2:
	$s -xsl:${RUN}/parlamint2tbl-persons.xsl ${IN2} > ${PER}
gen-persons-v3:
	$s -xsl:${RUN}/parlamint2tbl-persons.xsl ${IN3} > ${PER}


## Insert minister affiliations from TSV file into a testing root file.
insert-ministries-v2:
	$s tsv=${TSV} -xsl:${RUN}/ministers-tsv2tei.xsl ${IN2} \
	> ${OUT}/ParlaMint-${MC}.xml 2> ParlaMint_ministers-${MC}.log
	#${vrt} ${OUT}/ParlaMint-${MC}.xml
	${s} -xsl:${RUN}/check-links.xsl ${OUT}/ParlaMint-${MC}.xml
insert-ministries-v3:
	cp ${V3}/ParlaMint-${MC}.TEI/*.xml ${OUT}/ #copy factorised files
	$s tsv=${TSV} -xsl:${RUN}/ministers-tsv2tei.xsl ${IN3} \
	> ${OUT}/ParlaMint-${MC}.xml 2> ParlaMint_ministers-${MC}.log
	${vrp} ${OUT}/ParlaMint-${MC}-listPerson.xml
	${vrt} ${OUT}/ParlaMint-${MC}.xml
	${s} -xsl:${RUN}/check-links.xsl ${OUT}/ParlaMint-${MC}.xml
	#-diff -b ${IN3} ${OUT}/ParlaMint-${MC}.xml

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
