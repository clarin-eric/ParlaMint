fix-taxo:
	$s -xsl:bin/usas-tsv2taxonomy.xsl tsv=../tags-all.tsv ../Taxonomies/ParlaMint-taxonomy-USAS.ana.xml  > usas-taxo.xml
	${vta} usas-taxo.xml
nohup-tags:
	nohup time make get-tags > tags.log &
get-tags:
	bin/get-usas-tags.pl 'ParlaMint-*-en.conllu' > tags-all.tsv

sem-test4:
	perl ../../Scripts/conllu2tei.pl \
	< Test/ParlaMint-LV-en_2015-11-12-PT12-329.conllu > Test/Test-LV-en.xml
	xmllint --noout Test/Test-LV-en.xml
sem-test3:
	perl ../../Scripts/conllu2tei.pl \
	< Test/ParlaMint-LV-en_2015-11-12-PT12-329.conllu > Test/Test-LV-en.xml
	xmllint --noout Test/Test-LV-en.xml
sem-test2:
	../../Scripts/conllu2tei.pl < ParlaMint-BA-en.conllu/1998/ParlaMint-BA-en_1998-12-04-0.conllu > test.xml
	xmllint --noout test.xml
sem-test1:
	../../Scripts/conllu2tei.pl < test.conllu > test.xml
	xmllint --noout test.xml

###### Copy (and fix) original conllu files from Source-Sem/USAS to Source-Sem directory for 1 corpus
CORPUS = AT
cp-mt-conllu-one:
	../bin/cp-conllu.pl novalidate ../Master 'USAS/ParlaMint-${CORPUS}-en.conllu' .

#CORPORA = AT BA BE BG CZ DK EE ES ES-CT ES-GA ES-PV FI FR GB GR HR HU IS IT LV NL NO PL PT RS SE SI TR UA
CORPORA =  BG CZ DK EE ES ES-CT ES-GA ES-PV FI 

nohup:
	nohup time make cp-mt-conllu > cp-mt-conllu.log &
cp-mt-conllu:
	for CORPUS in ${CORPORA}; do \
	rm -fr ./ParlaMint-$${CORPUS}-en.conllu; \
	../bin/cp-conllu.pl validate ../Master USAS/ParlaMint-$${CORPUS}-en.conllu . 2>  ParlaMint-$${CORPUS}-en.conllu.log; \
	done;

cp-mt:	cp-mt-notes cp-mt-conllu
cp-mt-notes:
	cp ../Sources-MT/ParlaMint-*-en-notes.tsv .

##### Merge per-language annotated CoNLL-Us (BE, ES-CT, UA) to joint CoNLL-Us
##### Do after cp-mt-conllu
##### Should also delete per-language files!?!?
mrg-conll:
	../bin/merge-conllu.pl ../Master/ParlaMint-BE.conllu    ParlaMint-BE-en.conllu
	../bin/merge-conllu.pl ../Master/ParlaMint-ES-CT.conllu ParlaMint-ES-CT-en.conllu
	../bin/merge-conllu.pl ../Master/ParlaMint-UA.conllu    ParlaMint-UA-en.conllu

#URL = https://ucrel.lancs.ac.uk/paul/parlamint/PyMUSASTagged
URL = http://ucrel-api-01.lancaster.ac.uk/vidler/
nohup-get:
	nohup time make get > get.log &
get:
	cd USAS; \
	for CORPUS in ${CORPORA}; do \
	rm -f ParlaMint-$${CORPUS}-en.conllu.tar.gz; \
	wget ${URL}/ParlaMint-$${CORPUS}-en.conllu.tar.gz; \
	tar xfz ParlaMint-$${CORPUS}-en.conllu.tar.gz; \
	dos2unix ParlaMint-$${CORPUS}-en.conllu/*/*; \
	done;

###################### SCRIPT VARIABLES
#s = java -jar -Xmx240g /usr/share/java/saxon.jar
s = java -jar /usr/share/java/saxon.jar
j = java -jar /usr/share/java/jing.jar
P = parallel --gnu --halt 2
vta = $j ../../Schema/ParlaMint-taxonomy.rng		# Corpus TEI taxonomy
