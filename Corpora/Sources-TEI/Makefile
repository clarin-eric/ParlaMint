test-mw:
	$s tsv=../Corpora/Orientations/Orientation-UA.Wiki.tsv -xsl:../../Scripts/wiki-tsv2tei.xsl \
	ParlaMint-UA.TEI/ParlaMint-UA-listOrg.xml > ParlaMint-UA-listOrg.tmp.xml
test-me:
	$s tsv=../Corpora/Orientations/Orientation-UA.enco.tsv -xsl:../../Scripts/enco-tsv2tei.xsl \
	ParlaMint-UA.TEI/ParlaMint-UA-listOrg.xml > ParlaMint-UA-listOrg.tmp.xml

###### Adding common taxonomies
###### and inserting TSV metadata (political orientations for <listOrg>, ministers for <listPerson>)

### For one corpus
CORPUS = UA
one:
	../../Scripts/add-metadata.pl ../Orientations ../Ministers 'Orig/ParlaMint-${CORPUS}.TEI*' '.'

### For everything
nohup:
	nohup time make metadata > ParlaMint-metadata.log &

### Add metadata
metadata:
	../../Scripts/add-metadata.pl ../Orientations ../Ministers "Orig/ParlaMint-*.TEI*" "."

### Variables
s = java -jar /usr/share/java/saxon.jar
P = parallel --gnu --halt 2
GIT  = /project/corpora/Parla/ParlaMint/ParlaMint
HERE = ${GIT}/Corpora/Sources-TEI
