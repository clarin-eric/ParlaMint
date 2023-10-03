###### Copy (and fix) original conllu files to Source-MT directory for 1 corpus
CORPUS = FI
test1:
	../bin/cp-conllu.pl validate '-' 'Temp/ParlaMint-${CORPUS}.conllu.translated' Temp/tmp

cp-mt:	cp-mt-notes cp-mt-conllu
cp-mt-conllu:
	../bin/cp-conllu.pl validate '' '/home/taja/ParlaMint-${CORPUS}.conllu.translated' .
cp-mt-conllu-add:
	#../bin/cp-conllu.pl novalidate '' '/home/taja/ParlaMint-${CORPUS}.conllu.translated' .
	../bin/cp-conllu.pl validate '' '/home/taja/ParlaMint-${CORPUS}.conllu.translated.additional' .
# ParlaMint-XX.notes.translated.tsv -> ParlaMint-XX-en-notes.tsv
cp-mt-notes:
	cp /home/taja/Notes-translated/ParlaMint-${CORPUS}.notes.translated.ana.tsv .
	rename -f 's/\.notes.translated\.ana/-en-notes/' *.tsv

pack:
	zip -r ParlaMint-AT-en.conllu.zip ParlaMint-AT-en.conllu
	zip -r ParlaMint-BA-en.conllu.zip ParlaMint-BA-en.conllu
	zip -r ParlaMint-BE-en.conllu.zip ParlaMint-BE-en.conllu
	zip -r ParlaMint-BG-en.conllu.zip ParlaMint-BG-en.conllu
	zip -r ParlaMint-CZ-en.conllu.zip ParlaMint-CZ-en.conllu
	zip -r ParlaMint-DK-en.conllu.zip ParlaMint-DK-en.conllu
	zip -r ParlaMint-EE-en.conllu.zip ParlaMint-EE-en.conllu
	zip -r ParlaMint-ES-en.conllu.zip ParlaMint-ES-en.conllu
	zip -r ParlaMint-ES-CT-en.conllu.zip ParlaMint-ES-CT-en.conllu
	zip -r ParlaMint-ES-GA-en.conllu.zip ParlaMint-ES-GA-en.conllu
	zip -r ParlaMint-FR-en.conllu.zip ParlaMint-FR-en.conllu
	zip -r ParlaMint-GR-en.conllu.zip ParlaMint-GR-en.conllu
	zip -r ParlaMint-HR-en.conllu.zip ParlaMint-HR-en.conllu
	zip -r ParlaMint-HU-en.conllu.zip ParlaMint-HU-en.conllu
	zip -r ParlaMint-IS-en.conllu.zip ParlaMint-IS-en.conllu
	zip -r ParlaMint-IT-en.conllu.zip ParlaMint-IT-en.conllu
	zip -r ParlaMint-LV-en.conllu.zip ParlaMint-LV-en.conllu
	zip -r ParlaMint-NL-en.conllu.zip ParlaMint-NL-en.conllu
	zip -r ParlaMint-NO-en.conllu.zip ParlaMint-NO-en.conllu
	zip -r ParlaMint-PL-en.conllu.zip ParlaMint-PL-en.conllu
	zip -r ParlaMint-PT-en.conllu.zip ParlaMint-PT-en.conllu
	zip -r ParlaMint-RS-en.conllu.zip ParlaMint-RS-en.conllu
	zip -r ParlaMint-SE-en.conllu.zip ParlaMint-SE-en.conllu
	zip -r ParlaMint-SI-en.conllu.zip ParlaMint-SI-en.conllu
	zip -r ParlaMint-TR-en.conllu.zip ParlaMint-TR-en.conllu
	zip -r ParlaMint-UA-en.conllu.zip ParlaMint-UA-en.conllu
	rsync -av *-en.conllu.zip tomaz@nl.ijs.si:/home/tomaz/www/tmp/ParlaMint/MT/CoNLL-U-en
