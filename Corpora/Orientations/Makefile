MC = BA
HERE = /project/corpora/Parla/ParlaMint/ParlaMint-V3/Corpora/Orientations
V3  = /project/corpora/Parla/ParlaMint/ParlaMint-V3/Corpora/Master
RUN = ../../Scripts
SCH = ../../Schema
OUT = tmp

## Generate TSV files for party information on the basis of the corpus root files.
generate-parties:
	$s path=${V3} outDir=New -xsl:${RUN}/parties-tei2tsv.xsl \
	${V3}/ParlaMint.xml 2> ParlaMint_parties.log

## Insert political orientation of parties from TSV into a ParlaMint root file.
test-parlamint:
	make test-orientation-parlamint-2 2> insert.log
test-orientation-parlamint-2:
	make test-orientation MC=BA
	make test-orientation MC=ES-GA
	make test-orientation MC=ES-CT
	make test-orientation MC=RS
	make test-orientation MC=UA
test-orientation-parlamint-1:
	make test-orientation MC=HU
	make test-orientation MC=NO
	make test-orientation MC=SE
	make test-orientation MC=AT
	make test-orientation MC=BE
	make test-orientation MC=BG
	make test-orientation MC=CZ
	make test-orientation MC=DK
	make test-orientation MC=EE
	make test-orientation MC=FR
	make test-orientation MC=GB
	make test-orientation MC=GR
	make test-orientation MC=HR
	make test-orientation MC=HU
	make test-orientation MC=IS
	make test-orientation MC=IT
	make test-orientation MC=LV
	make test-orientation MC=NL
	make test-orientation MC=NO
	make test-orientation MC=PL
	make test-orientation MC=PT
	make test-orientation MC=SE
	make test-orientation MC=SI
	make test-orientation MC=TR

test-orientation:
	$s tsv=${HERE}/Orientation-${MC}.tsv -xsl:${RUN}/orientations-tsv2tei.xsl \
	${V3}/ParlaMint-${MC}.TEI/ParlaMint-${MC}-listOrg.xml | ${RUN}/polish-xml.pl > tmp/ParlaMint-${MC}-listOrg.xml
	${vro} tmp/ParlaMint-${MC}-listOrg.xml
	#-diff -b ${V3}/ParlaMint-${MC}.TEI/ParlaMint-${MC}-listOrg.xml tmp/ParlaMint-${MC}-listOrg.xml

######################VARIABLES
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

diffit:
	-diff Old/ParlaMint_parties-BE.tsv New/ParlaMint_parties-BE.tsv
	-diff Old/ParlaMint_parties-BG.tsv New/ParlaMint_parties-BG.tsv
	-diff Old/ParlaMint_parties-CZ.tsv New/ParlaMint_parties-CZ.tsv
	-diff Old/ParlaMint_parties-DK.tsv New/ParlaMint_parties-DK.tsv
	-diff Old/ParlaMint_parties-ES.tsv New/ParlaMint_parties-ES.tsv
	-diff Old/ParlaMint_parties-FR.tsv New/ParlaMint_parties-FR.tsv
	-diff Old/ParlaMint_parties-GB.tsv New/ParlaMint_parties-GB.tsv
	-diff Old/ParlaMint_parties-HR.tsv New/ParlaMint_parties-HR.tsv
	-diff Old/ParlaMint_parties-IS.tsv New/ParlaMint_parties-IS.tsv
	-diff Old/ParlaMint_parties-IT.tsv New/ParlaMint_parties-IT.tsv
	-diff Old/ParlaMint_parties-LT.tsv New/ParlaMint_parties-LT.tsv
	-diff Old/ParlaMint_parties-LV.tsv New/ParlaMint_parties-LV.tsv
	-diff Old/ParlaMint_parties-NL.tsv New/ParlaMint_parties-NL.tsv
	-diff Old/ParlaMint_parties-PL.tsv New/ParlaMint_parties-PL.tsv
	-diff Old/ParlaMint_parties-SI.tsv New/ParlaMint_parties-SI.tsv
	-diff Old/ParlaMint_parties-TR.tsv New/ParlaMint_parties-TR.tsv
