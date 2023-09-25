test-mw:
	$s tsv=../Corpora/Orientations/Orientation-UA.Wiki.tsv -xsl:../../Scripts/wiki-tsv2tei.xsl \
	ParlaMint-UA.TEI/ParlaMint-UA-listOrg.xml > ParlaMint-UA-listOrg.tmp.xml
test-me:
	$s tsv=../Corpora/Orientations/Orientation-UA.enco.tsv -xsl:../../Scripts/enco-tsv2tei.xsl \
	ParlaMint-UA.TEI/ParlaMint-UA-listOrg.xml > ParlaMint-UA-listOrg.tmp.xml
test-f:
	$s outDir=Test prefix='ParlaMint-GR-' teiRoot=Orig/ParlaMint-GR.TEI/ParlaMint-GR.xml \
	-xsl:../../Scripts/parlamint-factorize-teiHeader.xsl Orig/ParlaMint-GR.TEI/BKP/ParlaMint-GR.xml

###### Adding common taxonomies
###### and inserting TSV metadata (political orientations for <listOrg>, ministers for <listPerson>)

### For one corpus
CORPUS = TR
one:
	../../Scripts/parlamint-factorize-corpora.pl ../Taxonomies 'Orig/ParlaMint-${CORPUS}.TEI*'
	../../Scripts/add-metadata.pl ../Orientations ../Ministers 'Orig/ParlaMint-${CORPUS}.TEI*' '.'
### For everything
nohup:
	nohup time make prep > ParlaMint-metadata.log &
prep:	factorize metadata
xprep:	factorize metadata

### Add metadata
metadata:
	../../Scripts/add-metadata.pl ../Orientations ../Ministers "Orig/ParlaMint-*.TEI*" "."
### Factorisation of source corpora in Orig
factorize:
	../../Scripts/parlamint-factorize-corpora.pl ../Taxonomies Orig

### Variables
s = java -jar /usr/share/java/saxon.jar
P = parallel --gnu --halt 2
GIT  = /project/corpora/Parla/ParlaMint/ParlaMint
HERE = ${GIT}/Corpora/Sources-TEI
