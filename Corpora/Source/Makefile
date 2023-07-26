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

FINALIZE = ${GIT}/Scripts/parlamint2distro.pl -schema ${GIT}/Schema -docs ${HERE}/Docs
GIT  = /project/corpora/Parla/ParlaMint/ParlaMint-devel
HERE = /project/corpora/Parla/ParlaMint/V3/Data
######################VARIABLES
s = java -jar /usr/share/java/saxon.jar
P = parallel --gnu --halt 2
