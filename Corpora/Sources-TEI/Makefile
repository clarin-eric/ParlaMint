###### Preparing the received corpora

nohup:
	nohup time make prep > preparation.log &
prep:	metadata
xprep:	factorize metadata
### Add metadata
metadata:
	../../Scripts/add-metadata.pl ../Orientations ../Ministers "Orig/ParlaMint-*.TEI" .
	../../Scripts/add-metadata.pl ../Orientations ../Ministers "Orig/ParlaMint-*.TEI.ana" .
### Factorisation of source corpora and Orig
factorize:
	../../Scripts/parlamint-factorize-corpora.pl ../Taxonomies Orig

### Variables
s = java -jar /usr/share/java/saxon.jar
P = parallel --gnu --halt 2
GIT  = /project/corpora/Parla/ParlaMint/ParlaMint
HERE = ${GIT}/Corpora/Sources-TEI
