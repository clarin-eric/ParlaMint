## Develop USAS taxomomy, so all USAS first tags are mapped to exising taxomomy categories

# Debug:
# Compare taxonomy categories that USAS tags found in corpora map to, with the ones in the taxonomy
diff-taxo:
	cut -f2 usas-ana.tsv | perl -pe 's/sem://g; s/ /\n/g' | sort | uniq > ana-corpus.lst
	grep '<category' ../Taxonomies/ParlaMint-taxonomy-USAS.ana.xml  | perl -pe 's|.+xml:id="||; s|".+||' | sort > ana-taxonomy.lst
	-diff ana-taxonomy.lst ana-corpus.lst | grep -c '>'
	-diff ana-taxonomy.lst ana-corpus.lst | grep -c '<'

# The script that implements the mapping between USAS tags and taxonomy categories
make-sem:
	bin/usas2ana.pl < usas-tags.lst > usas-ana.tsv

# Get all USAS tags from all the corpora
nohup-tags:
	nohup time make get-tags > usas-tags.log &
get-tags:
	bin/get-usas-tags.pl 'ParlaMint-*-en.conllu' > usas-tags.lst


# Old and probably obsolete
get-taxo:
	$s -xsl:bin/taxonomyUSAS2tsv.xsl usas-taxo.xml > usas-taxo.tsv
	${vta} usas-taxo.xml
fix-taxo:
	$s -xsl:bin/usas-tsv2taxonomy.xsl tsv=../usas-tags.tsv ../Taxonomies/ParlaMint-taxonomy-USAS.ana.template.xml  > usas-taxo.xml
	${vta} usas-taxo.xml


# Tests
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

###### Copy (and fix) original conllu files from ./USAS to . for 1 corpus
CORPUS = GB
cp-mt-conllu-one:
	../bin/cp-conllu.pl novalidate ../Master 'USAS/ParlaMint-${CORPUS}-en.conllu' .

##### Merge bi-lingual CoNLL-Us (BE, ES-CT, UA) to joint CoNLL-Us
##### Do after cp-mt-conllu
mrg-conll:
	../bin/merge-conllu.pl ../Master/ParlaMint-BE.conllu    ParlaMint-BE-en.conllu
	../bin/merge-conllu.pl ../Master/ParlaMint-ES-CT.conllu ParlaMint-ES-CT-en.conllu
	../bin/merge-conllu.pl ../Master/ParlaMint-ES-PV.conllu ParlaMint-ES-PV-en.conllu
	../bin/merge-conllu.pl ../Master/ParlaMint-UA.conllu    ParlaMint-UA-en.conllu

CORPORA = AT BA BE BG CZ DK EE ES ES-CT ES-GA ES-PV FI FR GB GR HR HU IS IT LV NL NO PL PT RS SE SI TR UA
nohup:
	nohup time make cp-mt-conllu > cp-mt-conllu.log &

cp-mt:	cp-mt-notes cp-mt-conllu

cp-mt-conllu:
	for CORPUS in ${CORPORA}; do \
	rm -fr ./ParlaMint-$${CORPUS}-en.conllu; \
	../bin/cp-conllu.pl novalidate ../Master USAS/ParlaMint-$${CORPUS}-en.conllu . 2>  ParlaMint-$${CORPUS}-en.conllu.log; \
	done;

# Will not get GB!
cp-mt-notes:
	cp ../Sources-MT/ParlaMint-*-en-notes.tsv .

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
P = parallel --gnu --halt 2
#s = java -jar -Xmx240g ../Scripts/bin/saxon.jar
s = java -jar ../../Scripts/bin/saxon.jar
j = java -jar ../../Scripts/bin/jing.jar
vta = $j ../../Schema/ParlaMint-taxonomy.rng		# Corpus TEI taxonomy
