PER = ParlaMint_speakers-${MC}.tsv
gen-persons-v2:
	$s -xsl:${RUN}/parlamint2tbl-persons.xsl ${IN2} > ${PER}
gen-persons-v3:
	$s -xsl:${RUN}/parlamint2tbl-persons.xsl ${IN3} > ${PER}

## Insert minister affiliations from TSV file into a root file.
## Fixed: BE ES HR LT LV PL TR
MC = TR
TSV = ../Data/Ministers/ParlaMint_ministers-${MC}.edited.tsv
IN2 = ${V2}/ParlaMint-${MC}.TEI/ParlaMint-${MC}.xml
IN3 = ${V3}/ParlaMint-${MC}/ParlaMint-${MC}.xml
IN3F = /project/corpora/Parla/ParlaMint/V3/Master/ParlaMint-${MC}.TEI/ParlaMint-${MC}.xml
OUT = tmp/ParlaMint-${MC}.xml
insert-ministries-v2:
	$s tsv=${TSV} -xsl:${RUN}/ministers-tsv2tei.xsl ${IN2} > ${OUT} 2> ParlaMint_ministers-${MC}.log
	#${vrt} ${OUT}
	${s} -xsl:${RUN}/check-links.xsl ${OUT}
insert-ministries-v3:
	$s tsv=${TSV} -xsl:${RUN}/ministers-tsv2tei.xsl ${IN3} > ${OUT}
	${vrt} ${OUT}
	${s} -xsl:${RUN}/check-links.xsl ${OUT}
	-diff -b ${IN3} ${OUT}
insert-ministries-v3f:
	$s tsv=${TSV} -xsl:${RUN}/ministers-tsv2tei.xsl ${IN3F} > ${OUT}
	${vrt} ${OUT}
	${s} -xsl:${RUN}/check-links.xsl ${OUT}
	-diff -b ${IN3F} ${OUT}

V2  = /project/corpora/Parla/ParlaMint/V2/MasterV2.1
V3  = /project/corpora/Parla/ParlaMint/ParlaMint-data/Data

## Generate TSV files for minister affiliations on the basis of the corpus root files.
gen:	genV2 genV3
genV2:
	$s outDir=. -xsl:${RUN}/ministers-tei2tsv.xsl ${V2}/ParlaMint.xml
genV3:
	$s outDir=. -xsl:${RUN}/ministers-tei2tsv.xsl ${V3}/ParlaMint.xml

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
