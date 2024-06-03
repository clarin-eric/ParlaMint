######### Initial data and processing of MT and MT-USAS (.sem) CoNLL-U files

###### Corpus / corpora to be procssed
CORPUS = PT
CORPORA = AT BA BE BG CZ DK EE ES ES-CT ES-GA ES-PV FI FR GB GR HR HU IS IT LV NL NO PL PT RS SE SI TR UA

###### USAS part via UCREL pipeline: get & fix a few things

##### Merge bi-lingual CoNLL-Us (BE, ES-CT, UA) to joint CoNLL-Us
##### Do after cp-mt-conllu
mrg-conll:
	../Scripts/merge-conllu.pl ../Distro/ParlaMint-BE.conllu    ParlaMint-BE-en.sem
	../Scripts/merge-conllu.pl ../Distro/ParlaMint-ES-CT.conllu ParlaMint-ES-CT-en.sem
	../Scripts/merge-conllu.pl ../Distro/ParlaMint-ES-PV.conllu ParlaMint-ES-PV-en.sem
	../Scripts/merge-conllu.pl ../Distro/ParlaMint-UA.conllu    ParlaMint-UA-en.sem

nohup:
	nohup time make cp-mt-conllu-all > cp-mt-conllu.log &
cp-mt-conllu-all:
	for CORPUS in ${CORPORA}; do \
	rm -fr ./ParlaMint-$${CORPUS}-en.sem; \
	make cp-mt-conllu CORPUS=$${CORPUS}; \
	done;
cp-mt-conllu:
	../Scripts/cp-conllu.pl novalidate ../Distro \
	Sources.sem/ParlaMint-${CORPUS}-en.conllu . 2> ParlaMint-$${CORPUS}-en.sem.log

###### MT part via Taja's pipeline: copy & fix a few things, rename
test-cp-conllu:
	../Scripts/cp-conllu.pl validate '-' 'tmp/ParlaMint-${CORPUS}.conllu.translated' tmp/tmp
get-mt:	get-mt-notes get-mt-conllu
get-mt-conllu:
	../Scripts/cp-conllu.pl novalidate '' '/home/taja/ParlaMint-${CORPUS}.conllu.translated' .
get-mt-notes:
	-cp /home/taja/Notes-translated/ParlaMint-${CORPUS}.notes.translated.tsv .
	-cp /home/taja/Notes-translated/ParlaMint-${CORPUS}.notes.translated.ana.tsv .
	rm -f ParlaMint-${CORPUS}-en-notes.tsv
	-rename -f 's/\.notes.translated\.ana/-en-notes/' *.tsv
	-rename -f 's/\.notes.translated/-en-notes/' *.tsv
mt-for-transfer:
	zip -r ParlaMint-${CORPUS}-en.conllu.zip ParlaMint-${CORPUS}-en.conllu
	rsync -av ParlaMint-${CORPUS}-en.conllu.zip tomaz@nl.ijs.si:/home/tomaz/www/tmp/ParlaMint/MT/CoNLL-U-en

###################### SCRIPT VARIABLES
P = parallel --gnu --halt 2
#s = java -jar -Xmx240g ../Scripts/bin/saxon.jar
s = java -jar ../Scripts/bin/saxon.jar
j = java -jar ../Scripts/bin/jing.jar
