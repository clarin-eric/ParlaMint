## Edited, still problems: RS BA
## Not yet edited: 
## Edited, problems because of old corpus: LV LT PL ES
## Edited, OK: BE HR
## Corpus already contains ministers: AT BG CZ DK GR HU IS IT NL NO PT SE SI TR
MC = BA
TSV = ../Data/Ministers/ParlaMint_ministers-${MC}.edited.tsv
V2  = /project/corpora/Parla/ParlaMint/V2/MasterV2.1
V3  = /project/corpora/Parla/ParlaMint/V3/Master
IN2 = ${V2}/ParlaMint-${MC}.TEI/ParlaMint-${MC}.xml
IN3 = ${V3}/ParlaMint-${MC}.TEI/ParlaMint-${MC}.xml
IN3lp = ${V3}/ParlaMint-${MC}.TEI/ParlaMint-${MC}-listPerson.xml
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
	$s meta=${IN3} tsv=${TSV} -xsl:${RUN}/ministers-tsv2tei.xsl ${IN3lp} \
	2> ParlaMint_ministers-${MC}.log | ${RUN}/polish-xml.pl > ${OUT}/ParlaMint-${MC}-listPerson.xml 
	${vrp} ${OUT}/ParlaMint-${MC}-listPerson.xml
	${s} meta=${IN3} -xsl:${RUN}/check-links.xsl ${OUT}/ParlaMint-${MC}-listPerson.xml
	-diff -b ${IN3lp} ${OUT}/ParlaMint-${MC}-listPerson.xml

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
