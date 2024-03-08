###### Copy (and fix) original conllu files to Source-MT directory for 1 corpus
CORPUS = ES-PV
test1:
	../bin/cp-conllu.pl validate '-' 'tmp/ParlaMint-${CORPUS}.conllu.translated' tmp/tmp

cp-mt:	cp-mt-notes cp-mt-conllu
cp-mt-conllu:
	../bin/cp-conllu.pl novalidate '' '/home/taja/ParlaMint-${CORPUS}.conllu.translated' .
cp-mt-conllu-add:
	#../bin/cp-conllu.pl novalidate '' '/home/taja/ParlaMint-${CORPUS}.conllu.translated' .
	../bin/cp-conllu.pl validate '' '/home/taja/ParlaMint-${CORPUS}.conllu.translated.additional' .
# ParlaMint-XX.notes.translated.tsv -> ParlaMint-XX-en-notes.tsv
cp-mt-notes:
	cp /home/taja/Notes-translated/ParlaMint-${CORPUS}.notes.translated.ana.tsv .
	rename -f 's/\.notes.translated\.ana/-en-notes/' *.tsv
pack:
	zip -r ParlaMint-${CORPUS}-en.conllu.zip ParlaMint-${CORPUS}-en.conllu
	rsync -av ParlaMint-${CORPUS}-en.conllu.zip tomaz@nl.ijs.si:/home/tomaz/www/tmp/ParlaMint/MT/CoNLL-U-en
