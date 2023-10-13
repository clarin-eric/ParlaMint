fix-taxo:
	$s -xsl:bin/usas-tsv2taxonomy.xsl tsv=../tags.tsv ../Taxonomies/ParlaMint-taxonomy-USAS.ana.xml  > usas-taxo.xml
get-tags:
	bin/get-usas-tags.pl USAS/ParlaMint-*-en.conllu > tags-all.tsv

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

##### Merge per-language annotated CoNLL-Us (BE, ES-CT, UA) to joint CoNLL-Us
mrg-conll:
	#../bin/merge-conllu.pl Master/ParlaMint-BE.conllu USAS/ParlaMint-BE-en.conllu
	../bin/merge-conllu.pl ../Master/ParlaMint-ES-CT.conllu USAS/ParlaMint-ES-CT-en.conllu
	#../bin/merge-conllu.pl Master/ParlaMint-UA.conllu USAS/ParlaMint-UA-en.conllu



###### Copy (and fix) original conllu files to Source-MT directory for 1 corpus
CORPUS = ES-CT
cp-mt-conllu-one:
	../bin/cp-conllu.pl novalidate ../Master 'USAS/ParlaMint-${CORPUS}-en.conllu' .

#CORPORA = AT BA BE BG CZ DK EE ES ES-CT ES-GA ES-PV FI FR GB GR HR HU IS IT LV NL NO PL PT RS SE SI TR UA
CORPORA =  AT CZ FI HU UA

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
