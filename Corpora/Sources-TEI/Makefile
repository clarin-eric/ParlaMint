val:
	${vxx} ParlaMint-PL.test.xml
test-ch:
	$s tsv=../Corpora/Orientations/Orientation-BE.CHES.tsv -xsl:../../Scripts/ches-tsv2tei.xsl \
	ParlaMint-BE.TEI/ParlaMint-BE-listOrg.xml > ParlaMint-CHES-listOrg.tmp.xml
	${vlo} ParlaMint-CHES-listOrg.tmp.xml
test-mw:
	$s tsv=../Corpora/Orientations/Orientation-UA.Wiki.tsv -xsl:../../Scripts/wiki-tsv2tei.xsl \
	ParlaMint-UA.TEI/ParlaMint-UA-listOrg.xml > ParlaMint-UA-listOrg.tmp.xml
test-en:
	$s tsv=../Corpora/Orientations/Orientation-UA.enco.tsv -xsl:../../Scripts/enco-tsv2tei.xsl \
	ParlaMint-UA.TEI/ParlaMint-UA-listOrg.xml > ParlaMint-UA-listOrg.tmp.xml

###### Adding common taxonomies
###### and inserting TSV metadata (political orientations for <listOrg>, ministers for <listPerson>)

### For one corpus
CORPUS = PL
one:
	../../Scripts/add-metadata.pl ../Orientations ../Ministers 'Orig/ParlaMint-${CORPUS}.TEI*' '.'

### For everything
nohup:
	nohup time make metadata > ParlaMint-metadata.log &

### Add metadata
metadata:
	../../Scripts/add-metadata.pl ../Orientations ../Ministers "Orig/ParlaMint-*.TEI*" "."

###################### VARIABLES
#Absolute paths are needed otherwise problems with XSLT
PARLAMINT := $(shell realpath ../.. | tr -d '\n')# get real absolute path to ParlaMint directory
HERE = ${PARLAMINT}/Corpora/Sources-TEI
SCH = ${PARLAMINT}/Schema

######### SCRIPT VARIABLES
P = parallel --citation --gnu --halt 2
j = java -jar ../../Scripts/bin/jing.jar
s = java -jar ../../Scripts/bin/saxon.jar
#Run java with a large heap, as a complete corpus needs to be read in
#s = java -jar -Xmx240g ../../Scripts/bin/saxon.jar

pc = -I % $s -xi -xsl:../Scripts/copy.xsl % | $j parla-clarin.rng
vxx = $j ${SCH}/ParlaMint.odd.rng 	        # Validated with ParlaMint TEI 
vrt = $j ${SCH}/ParlaMint-teiCorpus.rng 	# Corpus root / text
vct = $j ${SCH}/ParlaMint-TEI.rng		# Corpus component / text
vra = $j ${SCH}/ParlaMint-teiCorpus.ana.rng	# Corpus root / analysed
vca = $j ${SCH}/ParlaMint-TEI.ana.rng		# Corpus component / analysed
vlo = $j ${SCH}/ParlaMint-listOrg.rng		# Corpus organisation list
vlp = $j ${SCH}/ParlaMint-listPerson.rng	# Corpus person list
vta = $j ${SCH}/ParlaMint-taxonomy.rng		# Corpus taxonomy
