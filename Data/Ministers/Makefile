V2  = /project/corpora/Parla/ParlaMint/V2/MasterV2.1
V3  = /project/corpora/Parla/ParlaMint/ParlaMint-data/Data

## Generate TSV files for minister affiliations on the basis of the corpus root files.
genV2:
	$s outDir=. -xsl:${RUN}/ministers-tei2tsv.xsl ${V2}/ParlaMint.xml
genV3:
	$s outDir=. -xsl:${RUN}/ministers-tei2tsv.xsl ${V3}/ParlaMint.xml

## Insert minister affiliations from TSV file into a root file.
MC = BE
insert-ministries-test:
	$s tsv=${TSV}/ParlaMint_ministers-${MC}.tsv -xsl:Scripts/ministers-tsv2tei.xsl \
	${DATADIR}/ParlaMint-${MC}/ParlaMint-${MC}.xml > Scripts/tmp/ParlaMint-${MC}.xml
	-diff -b ${DATADIR}/ParlaMint-${MC}/ParlaMint-${MC}.xml Scripts/tmp/ParlaMint-${MC}.xml
	${vrt} Scripts/tmp/ParlaMint-${MC}.xml
	${s} -xsl:${RUN}/check-links.xsl Scripts/tmp/ParlaMint-${MC}.xml


######################VARIABLES
RUN = ../../Scripts
SCH = ../../Schema
s = java -jar /usr/share/java/saxon.jar
j = java -jar /usr/share/java/jing.jar
pc =  $j ${SCH}/parla-clarin.rng                # Validate with Parla-CLARIN schema
vrt = $j ${SCH}/ParlaMint-teiCorpus.rng 	# Corpus root / text
vra = $j ${SCH}/ParlaMint-teiCorpus.ana.rng	# Corpus root / analysed
