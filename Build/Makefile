########### Makefile for making a distributable version of the ParlaMint TEI, TEI.ana, -en.TEI.ana corpora and metadata overviews
#### Variables give the corpora, version, handle, paths and scripts to use
#### make nohup1 starts make all and saves the log in Logs/

### VARIABLES

### COMPLETE SET OF CORPORA
CORPORA=AT BA BE BG CZ DK EE ES ES-CT ES-GA ES-PV FI FR GB GR HR HU IS IT LV NL NO PL PT RS SE SI TR UA
#CORPORA=
# Used in targets that run only for one corpus
CORPUS=

#Absolute paths are needed otherwise problems with XSLT
PARLAMINT := $(shell realpath .. | tr -d '\n')# get real absolute path to ParlaMint directory
HERE = ${PARLAMINT}/Build
TEMP = ${HERE}/Temp
SCH = ${PARLAMINT}/Schema

# Where the submitted corpora are found:
# ParlaMint-XX.TEI/ and ParlaMint-XX.TEI.ana
SOURCES = ${HERE}/Sources-TEI
# ParlaMint-XX-en.TEI.ana, MTed + semantically tagged:
SOURCES-MT = ${HERE}/Sources-CoNLLU

# Version number and PID of next ParlaMint release
VERSION = 4.1
HANDLE-TEI = http://hdl.handle.net/11356/1912
HANDLE-ANA = http://hdl.handle.net/11356/1911
HANDLE-MT  = http://hdl.handle.net/11356/1910

#Where the produced corpora are put for inspection
WEB = tomaz@nl.ijs.si:/home/tomaz/www/tmp/ParlaMint

##Note that script variables are at the end of the Makefile!

###### Targets

### Overviews to be put in Metadata/

metadata:	metadata-persons metadata-orgs metadata-quant-tsv metadata-quant-tex
#Make overview LaTeX tables (for LREV paper)
metadata-quant-tex:
	$s mode=tex -xsl:Scripts/parlamint2cnt-overview.xsl   Distro/ParlaMint.xml > Metadata/ParlaMint-overview-stats.tex
	$s mode=tex -xsl:Scripts/parlamint2cnt-particDesc.xsl Distro/ParlaMint.xml > Metadata/ParlaMint-participDesc-stats.tex
	$s mode=tex -xsl:Scripts/parlamint2cnt-speeches.xsl   Distro/ParlaMint.xml > Metadata/ParlaMint-speeches-stats.tex
#Make overview TSV tables
metadata-quant-tsv:
	$s mode=tsv -xsl:Scripts/parlamint2cnt-overview.xsl   Distro/ParlaMint.xml > Metadata/ParlaMint-overview-stats.tsv
	$s mode=tsv -xsl:Scripts/parlamint2cnt-particDesc.xsl Distro/ParlaMint.xml > Metadata/ParlaMint-participDesc-stats.tsv
	$s mode=tsv -xsl:Scripts/parlamint2cnt-speeches.xsl   Distro/ParlaMint.xml > Metadata/ParlaMint-speeches-stats.tsv
## Generate TSV files with time-independent information on organisations
metadata-orgs:
	$s out-lang=xx -xsl:Scripts/listOrg-tei2tsv.xsl Distro/ParlaMint.xml > Metadata/ParlaMint-listOrg.tsv
	$s out-lang=en -xsl:Scripts/listOrg-tei2tsv.xsl Distro/ParlaMint.xml > Metadata/ParlaMint-listOrg-en.tsv
## Generate TSV files with time-independent information on speakers
metadata-persons:
	$s out-lang=xx -xsl:Scripts/listPerson-tei2tsv.xsl Distro/ParlaMint.xml > Metadata/ParlaMint-listPerson.tsv
	$s out-lang=en -xsl:Scripts/listPerson-tei2tsv.xsl Distro/ParlaMint.xml > Metadata/ParlaMint-listPerson-en.tsv
## Generate TSV files for persons and orgs from the Sources-TEI directory
source-metadata:
	$s out-lang=xx -xsl:Scripts/listPerson-tei2tsv.xsl Sources-TEI/ParlaMint.xml > Metadata/ParlaMint-listPerson.tsv
	$s out-lang=en -xsl:Scripts/listPerson-tei2tsv.xsl Sources-TEI/ParlaMint.xml > Metadata/ParlaMint-listPerson-en.tsv
	$s out-lang=xx -xsl:Scripts/listOrg-tei2tsv.xsl Sources-TEI/ParlaMint.xml > Metadata/ParlaMint-listOrg.tsv
	$s out-lang=en -xsl:Scripts/listOrg-tei2tsv.xsl Sources-TEI/ParlaMint.xml > Metadata/ParlaMint-listOrg-en.tsv

###### Various tests
test:
	date
test-tei2:
	${FINALIZE} -valid -codes TR -in ${HERE}/Distro -out ${HERE}/Distro
test-tei1:
	${FINALIZE} -tei -codes BG -in ${HERE}/Sources-TEI -out ${HERE}/Distro
test-vert6:
	../Scripts/parlamintp-tei2vert-xx.pl ${HERE}/Distro/ParlaMint-LV.TEI.ana Test/ParlaMint-LV-xx.vert
test-vert5:
	$s meta=../Build/Distro/ParlaMint-DK.TEI.ana/ParlaMint-DK.ana.xml -xsl:../Scripts/parlamint2xmlvert.xsl \
	../Build/Distro/ParlaMint-DK.TEI.ana/2020/ParlaMint-DK_2020-01-07-20191-M42.ana.xml > Test/test-DK.vert
test-vert4:
	$s meta=${HERE}/Distro/ParlaMint-IS.TEI.ana/ParlaMint-IS.ana.xml -xsl:../Scripts/parlamint2xmlvert.xsl \
	${HERE}/Distro/ParlaMint-IS.TEI.ana/2022/ParlaMint-IS_2022-01-17-20.ana.xml > test-IS.vert
test-vert2:
	${FINALIZE} -vert -codes IS -in ${HERE}/Distro -out ${HERE}/Distro
test-vert1:
	${FINALIZE} -vert -codes GR -in ${HERE}/Temp -out ${HERE}/Temp
	${FINALIZE} -vert -codes GR-en -in ${HERE}/Temp -out ${HERE}/Temp
test-conll4:
	$s meta=../Build/Distro/ParlaMint-AT.TEI.ana/ParlaMint-AT.ana.xml \
	-xsl:../Scripts/parlamint2conllu.xsl ../Build/Distro/ParlaMint-AT.TEI.ana/1996/ParlaMint-AT_1996-01-15-020-XX-NRSITZ-00003.ana.xml \
	> Test/test-AT.conllu
test-conll3:
	${FINALIZE} -conll -codes GR-en -in ${HERE}/Temp -out ${HERE}/Temp
test-conll2:
	${FINALIZE} -conll -codes GR -in ${HERE}/Temp -out ${HERE}/Temp
test-conll1:
	${FINALIZE} -conll -codes UA -in ${HERE}/Distro -out ${HERE}/Distro
test-meta5:
	$s out-lang=en meta=../Build/Distro/ParlaMint-SE.TEI/ParlaMint-SE.xml -xsl:../Scripts/parlamint2meta.xsl \
	../Build/Distro/ParlaMint-SE.TEI/2015/ParlaMint-SE_2015-11-04-prot-201516--21.xml  > test.tsv
test-meta4:
	$s out-lang=en meta=../Build/Distro/ParlaMint-PT.TEI/ParlaMint-PT.xml -xsl:../Scripts/parlamint2meta.xsl \
	../Build/Distro/ParlaMint-PT.TEI/2022/ParlaMint-PT_2022-03-22.xml  > test.tsv
test-meta3:
	$s out-lang=en meta=../Build/Distro/ParlaMint-RS.TEI/ParlaMint-RS.xml -xsl:../Scripts/parlamint2meta.xsl \
	../Build/Distro/ParlaMint-RS.TEI/2016/ParlaMint-RS_2016-06-03-0.xml  > test.tsv
test-meta2:
	$s out-lang=en meta=../Build/Distro/ParlaMint-IS.TEI/ParlaMint-IS.xml -xsl:../Scripts/parlamint2meta.xsl \
	../Build/Test/test-IS.xml > test-IS.tsv
	$s out-lang=en meta=../Build/Distro/ParlaMint-AT.TEI/ParlaMint-AT.xml -xsl:../Scripts/parlamint2meta.xsl \
	../Build/Test/test-AT.xml > test-AT.tsv
test-meta1:
	${FINALIZE} -txt -codes IS -in ${HERE}/Temp -out ${HERE}/Temp
	#${FINALIZE} -txt -codes GR-en -in ${HERE}/Temp -out ${HERE}/Temp
test-text1:
	${FINALIZE} -txt -codes ES-CT -in ${HERE}/Distro -out ${HERE}/Distro

### Fixes
# Merge per-language translated CoNLL-Us (BE, ES-CT, ES-PV, UA) to joint CoNLL-U (with # lang info on newpar)
# It is more useful to have them merged than separate
mrg-conll-nohup:
	nohup time make mrg-conll > Logs/ParlaMint_Merge_CoNLL-U.log &
mrg-conll:
	Scripts/merge-conllu.pl Distro/ParlaMint-BE.conllu ${SOURCES-MT}/ParlaMint-BE-en.conllu
	Scripts/merge-conllu.pl Distro/ParlaMint-ES-CT.conllu ${SOURCES-MT}/ParlaMint-ES-CT-en.conllu
	Scripts/merge-conllu.pl Distro/ParlaMint-ES-PV.conllu ${SOURCES-MT}/ParlaMint-ES-PV-en.conllu
	Scripts/merge-conllu.pl Distro/ParlaMint-UA.conllu ${SOURCES-MT}/ParlaMint-UA-en.conllu

# Fix a mistake with handle in corpora
fix-handle:
	for CORPUS in ${CORPORA}; do \
	Scripts/fix-handle.pl "Distro/ParlaMint-$${CORPUS}.TEI.ana/ParlaMint-$${CORPUS}.ana.xml"; \
	Scripts/fix-handle.pl "Distro/ParlaMint-$${CORPUS}.TEI.ana/*/*.ana.xml"; \
	done;

# Copy READMEs to master
cp-readmes:
	Scripts/cp-readmes.pl -codes "${CORPORA}" -version ${VERSION} -teihandle ${HANDLE-TEI} -anahandle ${HANDLE-ANA} \
	-docs Sources-Distro -out ${HERE}/Distro

# Make samples only
all-samples:	samples mt-samples cp-samples
samples:
	for CORPUS in ${CORPORA}; do \
	${FINALIZE} -sample -codes $${CORPUS} -in ${SOURCES} -out ${HERE}/Distro 2> Logs/ParlaMint-$${CORPUS}-samples.log; \
	done;
# Make MT samples only
mt-samples:
	for CORPUS in ${CORPORA}; do \
	${FINALIZE-MT} -sample -codes $${CORPUS}-en -out ${HERE}/Distro 2>> Logs/ParlaMint-$${CORPUS}-samples.log; \
	done;
#Merge original and MTed samples into official Samples directory
cp-samples:
	Scripts/cp-samples.pl 'Distro/ParlaMint-*' ../Samples
	#cp Logs/ParlaMint-$${CORPUS}-samples.log ../Samples/ParlaMint-$${CORPUS}; \

# Make vertical file with en metadata, a hack:
XX-CORPORA = AT-xx BA-xx BE-xx BG-xx CZ-xx DK-xx EE-xx ES-xx ES-CT-xx ES-GA-xx ES-PV-xx FI-xx FR-xx GB-xx GR-xx HR-xx HU-xx IS-xx IT-xx LV-xx NL-xx NO-xx PL-xx PT-xx RS-xx SE-xx SI-xx TR-xx UA-xx
# Test: make make-verts-xx CORPORA='LV ES-CT'
make-verts-xx-nohup:
	nohup time make make-verts-xx > Logs/ParlaMint-Verts-xx.log &
make-verts-xx:
	for CORPUS in ${CORPORA}; do \
	../Scripts/parlamintp-tei2vert-xx.pl ${HERE}/Distro/ParlaMint-$${CORPUS}.TEI.ana Temp/ParlaMint-$${CORPUS}-xx.vert; \
	done;
	perl ../Scripts/join-all-verts.pl -codes '${XX-CORPORA}' -in 'Temp' -out Verts/ParlaMint-XX.${VERSION}.vert

# Make vertical files only
make-verts:
	for CORPUS in ${CORPORA}; do \
	${FINALIZE} -vert -codes $${CORPUS} -in ${SOURCES} -out ${HERE}/Distro; \
	done;
	make verts

# Don't make TEI but only text, vert and conllu files only
make-conll-vert-txt:
	for CORPUS in ${CORPORA}; do \
	${FINALIZE} -txt -vert -conll -codes $${CORPUS} -in ${SOURCES} -out ${HERE}/Distro; \
	done;

# Make overall root(.ana) for ParlaMint for Sources-TEI/ and Distro/, 
all-roots:	source-roots master-roots
source-roots:
	$s base=${HERE}/Sources-TEI type=TEI -xsl:../Scripts/parlamint2root.xsl \
	../Scripts/ParlaMint-rootTemplate.xml > ${HERE}/Sources-TEI/ParlaMint.xml
	$s base=${HERE}/Sources-TEI type=TEI.ana -xsl:../Scripts/parlamint2root.xsl \
	../Scripts/ParlaMint-rootTemplate.xml > ${HERE}/Sources-TEI/ParlaMint.ana.xml
master-roots:
	$s base=${HERE}/Distro type=TEI -xsl:../Scripts/parlamint2root.xsl \
	../Scripts/ParlaMint-rootTemplate.xml > ${HERE}/Distro/ParlaMint.xml
	$s base=${HERE}/Distro type=TEI.ana -xsl:../Scripts/parlamint2root.xsl \
	../Scripts/ParlaMint-rootTemplate.xml > ${HERE}/Distro/ParlaMint.ana.xml
	$s base=${HERE}/Distro type=en.TEI.ana -xsl:../Scripts/parlamint2root.xsl \
	../Scripts/ParlaMint-rootTemplate.xml > ${HERE}/Distro/ParlaMint-en.ana.xml

mt-logs:
	for CORPUS in ${CORPORA}; do \
	grep -a -i 'fatal' Logs/ParlaMint-$${CORPUS}-en.log >  Logs/ParlaMint-$${CORPUS}-en.error.log;  \
	grep -a -i 'error' Logs/ParlaMint-$${CORPUS}-en.log >> Logs/ParlaMint-$${CORPUS}-en.error.log;  \
	grep -a -i 'warn'  Logs/ParlaMint-$${CORPUS}-en.log >  Logs/ParlaMint-$${CORPUS}-en.warn.log;  \
	done;

web-nohup:
	nice nohup time make web > ParlaMint-Web.log &
web:
	rsync -av Logs/*.log ${WEB}/Logs
	rsync -av Packed/*.tgz ${WEB}/Repo

###### Targets for producing releasable version of ParlaMint corpora
FINALIZE = perl ../Scripts/parlamint2distro.pl -version ${VERSION} -teihandle ${HANDLE-TEI} -anahandle ${HANDLE-ANA} -schema ../Schema -docs Sources-Distro

### For real
# More than one nohup, in case we want several runs at once
# In which case CORPORA variable needs to be changed first!
nohup1:
	nice nohup time make all > Logs/ParlaMint.1.log &
nohup2:
	nice nohup time make all > Logs/ParlaMint.2.log &
nohup3:
	nice nohup time make all > Logs/ParlaMint.3.log &

all:	final
xall:	final verts pack

pack:
	perl Scripts/pack-parlamint.pl -codes '${CORPORA}' -in Distro -out Packed
verts:
	perl Scripts/join-verts.pl -version ${VERSION} -codes '${CORPORA}' -in Distro -out Verts
final:
	for CORPUS in ${CORPORA}; do \
	${FINALIZE} -all -codes $${CORPUS} -in ${SOURCES} -out ${HERE}/Distro 2> Logs/ParlaMint-$${CORPUS}.log; \
	grep -a -i 'fatal' Logs/ParlaMint-$${CORPUS}.log >  Logs/ParlaMint-$${CORPUS}.error.log;  \
	grep -a -i 'error' Logs/ParlaMint-$${CORPUS}.log >> Logs/ParlaMint-$${CORPUS}.error.log;  \
	grep -a -i 'warn'  Logs/ParlaMint-$${CORPUS}.log >  Logs/ParlaMint-$${CORPUS}.warn.log;  \
	echo "$${CORPUS}.warn"; \
	cat Logs/ParlaMint-$${CORPUS}.warn.log | wc -l;  \
	cat Logs/ParlaMint-$${CORPUS}.warn.log | sort | uniq | wc -l;  \
	echo "$${CORPUS}.error"; \
	cat Logs/ParlaMint-$${CORPUS}.error.log | wc -l;  \
	cat Logs/ParlaMint-$${CORPUS}.error.log | sort | uniq | wc -l;  \
	done;

###### Targets for producing MTed corpora
###### Input is a) original TEI.ana corpora, b) CoNLL-U of speech translations and c) list of translated notes

### Make MTed corpora

# Make distribution with:
FINALIZE-MT=perl ../Scripts/parlamint2distro.pl -version ${VERSION} -anahandle ${HANDLE-MT} -schema ${PARLAMINT}/Schema -docs ${HERE}/Sources-Distro

# Targets
mt-nohup1:
	nice nohup time make mt-all > Logs/ParlaMint-en.log &
mt-nohup2:
	nice nohup time make mt-all > Logs/ParlaMint-en.2.log &
mt-nohup3:
	nice nohup time make mt-all > Logs/ParlaMint-en.3.log &
mt-nohup4:
	nice nohup time make mt-all > Logs/ParlaMint-en.4.log &
mt-nohup5:
	nice nohup time make mt-all > Logs/ParlaMint-en.5.log &
mt-nohup6:
	nice nohup time make mt-all > Logs/ParlaMint-en.6.log &

mt-all:	mt-convert
mt-xall-final:	mt-convert mt-verts mt-pack mt-web

# Make MT .txt and CoNLL files
mt-convert-txt:
	for CORPUS in ${CORPORA}; do \
	${FINALIZE-MT} -txt -conll -codes $${CORPUS}-en -out ${HERE}/Distro; \
	done;
mt-web:
	rsync -av Logs/*-en*.log ${WEB}/Logs
	rsync -av Packed/*-en*.tgz ${WEB}/Repo
nohup-mt-pack:
	nohup time make mt-pack > mt-pack.log &
mt-pack:
	for CORPUS in ${CORPORA}; do \
	perl Scripts/pack-parlamint.pl -codes $${CORPUS}-en -in Distro -out Packed ; \
	done;

# Make MT CoNNL-U files only
mt-nohup-conll:
	nice nohup time make mt-make-conll >> Logs/ParlaMint-en-conll.log &
# Make CoNLL-U + TSV files, then overwrite CoNLL-U with the MT/USAS ones as they have xtra data
mt-make-conll:
	for CORPUS in ${CORPORA}; do \
	${FINALIZE-MT} -conll -codes $${CORPUS}-en -out ${HERE}/Distro; \
	cp -r ${SOURCES-MT}/ParlaMint-$${CORPUS}-en.conllu/* Distro/ParlaMint-$${CORPUS}-en.conllu; \
	done;

### Make joint vert for all ParlaMint corpora
# Make MT vertical files only
mt-nohup-verts:
	rm -f Logs/ParlaMint-en-verts.log
	nice nohup time make mt-verts >> Logs/ParlaMint-en-verts.log &
mt-make-verts:
	for CORPUS in ${CORPORA}; do \
	${FINALIZE-MT} -vert -codes $${CORPUS}-en -out ${HERE}/Distro; \
	done;
	#make mt-verts

# Join verts only
mt-verts:
	#perl ../Scripts/join-all-verts.pl     -codes '${CORPORA}' -in 'Distro' -out Verts/ParlaMint-XX.${VERSION}.vert
	perl ../Scripts/join-all-verts.pl -en -codes '${CORPORA}' -in 'Distro' -out Verts/ParlaMint-XX-en.${VERSION}.vert

# Sanity check for alignment
sanity:
	zcat Verts/ParlaMint-XX.${VERSION}.vert.gz | grep -c '</s>' 
	zcat Verts/ParlaMint-XX-en.${VERSION}.vert.gz | grep -c '</s>' 

# Convert from English CoNLL-U + source .TEI.ana -> -en.TEI.ana 
mt-convert:
	for CORPUS in ${CORPORA}; do \
	perl Scripts/parlamint-mt2tei.pl \
	${HERE}/Distro/ParlaMint-$${CORPUS}.TEI.ana/ParlaMint-$${CORPUS}.ana.xml \
	${SOURCES-MT}/ParlaMint-$${CORPUS}-en-notes.tsv \
	${SOURCES-MT}/ParlaMint-$${CORPUS}-en.sem \
	${TEMP}/ParlaMint-$${CORPUS}-en.TEI.ana 2> Logs/ParlaMint-$${CORPUS}-en.log; \
	${FINALIZE-MT} -all -notei -codes $${CORPUS}-en -in ${TEMP} -out ${HERE}/Distro \
	2>> Logs/ParlaMint-$${CORPUS}-en.log; \
	grep -a -i 'fatal' Logs/ParlaMint-$${CORPUS}-en.log >  Logs/ParlaMint-$${CORPUS}-en.error.log;  \
	grep -a -i 'error' Logs/ParlaMint-$${CORPUS}-en.log >> Logs/ParlaMint-$${CORPUS}-en.error.log;  \
	grep -a -i 'warn'  Logs/ParlaMint-$${CORPUS}-en.log >  Logs/ParlaMint-$${CORPUS}-en.warn.log;  \
	done;

### Make CoNLL-U only
# Convert from English CoNLL-U + source .TEI.ana -> -en.TEI.ana 
mt-conllu:
	for CORPUS in ${CORPORA}; do \
	${FINALIZE-MT} -conll -codes $${CORPUS}-en -in ${TEMP} -out ${HERE}/Distro; \
	done;

# Convert from English CoNLL-U + source .TEI.ana -> -en.TEI.ana 
mt-txt:
	for CORPUS in ${CORPORA}; do \
	${FINALIZE-MT} -txt -codes $${CORPUS}-en -in ${TEMP} -out ${HERE}/Distro; \
	done;

### Tests for debugging MT processing

mt-test10:
	${FINALIZE-MT} -all -notei -codes GB-en -in ${TEMP} -out ${HERE}/Distro \
	2>> Logs/ParlaMint-GB-en.log
	grep -a -i 'fatal' Logs/ParlaMint-GB-en.log >  Logs/ParlaMint-GB-en.error.log
	grep -a -i 'error' Logs/ParlaMint-GB-en.log >> Logs/ParlaMint-GB-en.error.log
	grep -a -i 'warn'  Logs/ParlaMint-GB-en.log >  Logs/ParlaMint-GB-en.warn.log
mt-test9:
	$s nosyntax=true out-lang=en meta=${HERE}/Distro/ParlaMint-ES-CT-en.TEI.ana/ParlaMint-ES-CT-en.ana.xml \
	-xsl:../Scripts/parlamint2xmlvert.xsl \
	${HERE}/Distro/ParlaMint-ES-CT-en.TEI.ana/2015/ParlaMint-ES-CT-en_2015-10-26-0101.ana.xml > test.vert
mt-test8:
	$s -xsl:../Scripts/validate-parlamint.xsl \
	${HERE}/Distro/ParlaMint-UA.TEI.ana/ParlaMint-UA.ana.xml
	$s meta=${HERE}/Distro/ParlaMint-UA.TEI.ana/ParlaMint-UA.ana.xml -xsl:../Scripts/validate-parlamint.xsl \
	${HERE}/Distro/ParlaMint-UA.TEI.ana/2022/ParlaMint-UA_2022-01-25-m0.ana.xml
mt-test7:
	$s meta=${HERE}/Distro/ParlaMint-AT-en.TEI.ana/ParlaMint-AT-en.ana.xml -xsl:../Scripts//check-links.xsl \
	${HERE}/Distro/ParlaMint-AT-en.TEI.ana/2022/ParlaMint-AT-en_2022-01-20-027-XXVII-NRSITZ-00139.ana.xml
mt-test6:
	${FINALIZE-MT} -sample -codes ES-CT-en -out ${HERE}/Distro
mt-test5:
	${vta} Test/ParlaMint-AT-en.TEI.ana/ParlaMint-taxonomy-*.xml
	${vlp} Test/ParlaMint-AT-en.TEI.ana/ParlaMint-AT-listPerson.xml
	${vlo} Test/ParlaMint-AT-en.TEI.ana/ParlaMint-AT-listOrg.xml
	${vra} Test/ParlaMint-AT-en.TEI.ana/ParlaMint-AT-en.ana.xml
	${vca} Test/ParlaMint-AT-en.TEI.ana/1996/*.xml
mt-test4:
	perl Scripts/mt-insert-s.pl \
	  ../Scripts/tmp/363a4AJ0Jh/ParlaMint-BA-en_2006-09-18-0.body.xml \
	< ../Scripts/tmp/363a4AJ0Jh/ParlaMint-BA-en_2006-09-18-0.note.xml\
	> Test/ParlaMint-BA-en_2006-09-18-0.ana.xml
mt-test3:
	$s noteFile=Test/ParlaMint-AT.notes.translated.tsv -xsl:Scripts/mt-insert-notes.xsl \
	Test/ParlaMint-AT-en_1996-01-30-020-XX-NRSITZ-00004.null.xml \
	> Test/ParlaMint-AT-en_1996-01-30-020-XX-NRSITZ-00004.notes.xml
mt-test2:
	perl ../Scripts/conllu2tei.pl < Test/ParlaMint-TR-en_2011-07-04-tbmm-T24.conllu > Test/0.body.xml
mt-test1:
	rm -fr Test/ParlaMint-LV.tmp/*
	$s outDir=Test/ParlaMint-LV.tmp -xsl:Scripts/mt-prepare4mt.xsl ${HERE}/Distro/ParlaMint-LV.TEI.ana/ParlaMint-LV.ana.xml

#### Old and probably no longer useful

### Merging taxonomies (now the common taxonomy files should be edited, not merging local copies anymore)

TAXONOMIES-TEI = subcorpus speaker_types parla.legislature
TAXONOMIES-ANA = NER
merge-taxos-nohup:
	nohup time make merge-taxos 2> Taxonomies/ParlaMint-taxonomy-merge.log > Logs/ParlaMint-taxonomy.log &
merge-taxos:
	for TAXONOMY in ${TAXONOMIES-TEI}; do \
	$s template=../Build/Taxonomies/ParlaMint-taxonomy-$${TAXONOMY}.template.xml \
	-xsl:../Scripts/parlamint-merge-taxonomy.xsl Distro/ParlaMint.xml \
	> Taxonomies/ParlaMint-taxonomy-$${TAXONOMY}.xml; \
	done;
	for TAXONOMY in ${TAXONOMIES-ANA}; do \
	$s template=../Build/Taxonomies/ParlaMint-taxonomy-$${TAXONOMY}.ana.template.xml \
	-xsl:../Scripts/parlamint-merge-taxonomy.xsl Distro/ParlaMint.ana.xml \
	> Taxonomies/ParlaMint-taxonomy-$${TAXONOMY}.ana.xml; \
	done;
	${vta} Taxonomies/ParlaMint-taxonomy-*.xml

### Some ideas, need to think about them...

#REGIS=at ba be bg cz dk es_ct fr gb gr hr hu is it lv nl no pl pt rs se si tr ua
REGIS=ua
QUERY=https://dev:alfabetagama@www.clarin.si/noske-beta/parlamint.cgi/wordlist?
TAIL=wlmaxitems=1000;wlattr=speech.body;wlminfreq=1;include_nonwords=1;wlsort=f;wlnums=docf;format=xml
body:
	rm -f body.xml
	for REGI in ${REGIS} ; do \
	curl "${QUERY}corpname=parlamint30_$${REGI};${TAIL}" | grep -v xml >> body.xml ; \
	done

###################### SCRIPT VARIABLES
##$JAVA-MEMORY## Set a java memory maxsize in GB
JAVA-MEMORY=240
JM := $(shell test -n "$(JAVA-MEMORY)" && echo -n "-Xmx$(JAVA-MEMORY)g")

P = parallel --citation --gnu --halt 2
#Run java with a large heap, as a complete corpus needs to be read in
s = java -jar $(JM) ../Scripts/bin/saxon.jar
j = java -jar ../Scripts/bin/jing.jar

pc = -I % $s -xi -xsl:../Scripts/copy.xsl % | $j parla-clarin.rng
pm = $j ${SCH}/ParlaMint.odd.rng 	        # Validate with ParlaMint ODD
vrt = $j ${SCH}/ParlaMint-teiCorpus.rng 	# Corpus root / text
vct = $j ${SCH}/ParlaMint-TEI.rng		# Corpus component / text
vra = $j ${SCH}/ParlaMint-teiCorpus.ana.rng	# Corpus root / analysed
vca = $j ${SCH}/ParlaMint-TEI.ana.rng		# Corpus component / analysed
vlo = $j ${SCH}/ParlaMint-listOrg.rng		# Corpus organisation list
vlp = $j ${SCH}/ParlaMint-listPerson.rng	# Corpus person list
vta = $j ${SCH}/ParlaMint-taxonomy.rng		# Corpus taxonomy
