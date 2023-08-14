# Put component files in year directories
fix-ES-PV:
	${GIT}/Scripts/dirify-parlamint.pl 00NEW/ParlaMint-ES-PV.TEI
	${GIT}/Scripts/dirify-parlamint.pl 00NEW/ParlaMint-ES-PV.TEI.ana
fix-EE:
	${GIT}/Scripts/dirify-parlamint.pl 00NEW/ParlaMint-EE.TEI
	${GIT}/Scripts/dirify-parlamint.pl 00NEW/ParlaMint-EE.TEI.ana
fix-PL:
	${GIT}/Scripts/dirify-parlamint.pl 00NEW/ParlaMint-PL.TEI
	${GIT}/Scripts/dirify-parlamint.pl 00NEW/ParlaMint-PL.TEI.ana
fix-GB:
	${GIT}/Scripts/dirify-parlamint.pl 00NEW/ParlaMint-GB.TEI
	${GIT}/Scripts/dirify-parlamint.pl 00NEW/ParlaMint-GB.TEI.ana

# Useless, too many differences in indent and new lines
CORPORA = AT BA BE BG CZ DK EE ES ES-CT ES-GA FR GB GR HR HU IS IT LV NL NO PL PT RS SE SI TR UA
check-diff:
	for CORPUS in ${CORPORA}; do \
	echo $${CORPUS} ; \
	xmllint --c14n Orig/ParlaMint-$${CORPUS}.TEI/ParlaMint-$${CORPUS}.xml > $${CORPUS}.orig.tmp ; \
	xmllint --c14n ParlaMint-$${CORPUS}.TEI/ParlaMint-$${CORPUS}.xml > $${CORPUS}.tmp ; \
	diff $${CORPUS}.orig.tmp $${CORPUS}.tmp ; \
	xmllint --c14n Orig/ParlaMint-$${CORPUS}.TEI.ana/ParlaMint-$${CORPUS}.ana.xml > $${CORPUS}.ana.orig.tmp ; \
	xmllint --c14n ParlaMint-$${CORPUS}.TEI.ana/ParlaMint-$${CORPUS}.ana.xml > $${CORPUS}.ana.tmp ; \
	diff $${CORPUS}.ana.orig.tmp $${CORPUS}.ana.tmp ; \
	done;
	rm *.tmp

# Testing
CORPUS = AT
test-factorize:
	rm -fr Test/ParlaMint-${CORPUS}*
	mkdir Test || :
	$s outDir=Test/ParlaMint-${CORPUS}.TEI \
	   prefix="ParlaMint-${CORPUS}-" \
	   -xsl:../../Scripts/parlamint-factorize-teiHeader.xsl \
	   Orig/ParlaMint-${CORPUS}.TEI/ParlaMint-${CORPUS}.xml || :
	$s outDir=Test/ParlaMint-${CORPUS}.TEI.ana \
	   prefix="ParlaMint-${CORPUS}-" \
	   teiRoot=`pwd`"/Test/ParlaMint-${CORPUS}.TEI/ParlaMint-${CORPUS}.xml" \
	   -xsl:../../Scripts/parlamint-factorize-teiHeader.xsl \
	   Orig/ParlaMint-${CORPUS}.TEI.ana/ParlaMint-${CORPUS}.ana.xml || :

###### Factorisation of source corpora; needs to be run only once
factor-all:
	../../Scripts/parlamint-factorize-corpora.pl ../Taxonomies Orig


FINALIZE = ${GIT}/Scripts/parlamint2distro.pl -schema ${GIT}/Schema -docs ${HERE}/Docs
GIT  = /project/corpora/Parla/ParlaMint/ParlaMint-devel
HERE = /project/corpora/Parla/ParlaMint/V3/Data
######################VARIABLES
s = java -jar /usr/share/java/saxon.jar
P = parallel --gnu --halt 2
