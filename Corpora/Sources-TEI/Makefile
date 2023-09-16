test:
	$s outDir=Test prefix='ParlaMint-GR-' teiRoot=Orig/ParlaMint-GR.TEI/ParlaMint-GR.xml \
	-xsl:../../Scripts/parlamint-factorize-teiHeader.xsl Orig/ParlaMint-GR.TEI/BKP/ParlaMint-GR.xml
###### Preparing the received corpora
CORPUS = DK
one:
	../../Scripts/parlamint-factorize-corpora.pl ../Taxonomies 'Orig/ParlaMint-${CORPUS}.TEI*'
	../../Scripts/add-metadata.pl ../Orientations ../Ministers 'Orig/ParlaMint-${CORPUS}.TEI*' '.'

nohup:
	nohup time make prep > preparation.log &
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
