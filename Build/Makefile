########### Makefile for making a distributable version of the ParlaMint TEI, TEI.ana, and -en.TEI.ana corpora and metadata overviews
#### Variables give the included countries, version, handle, paths and scripts to use
#### make nohup1 starts make all and saves the log in Logs/ 
#### make mt-nohup1 starts make mt-all and saves the log in Logs/
#### make all builds the plain text and linguistically annotated corpora
#### make mt-all builds the machine translated and linguistically annotated corpora
#### and there are a lot of test- targets to test various parts of the build.

### VARIABLES

### COMPLETE SET OF CORPORA
CORPORA=AT BA BE BG CZ DK EE ES ES-CT ES-GA ES-PV FI FR GB GR HR HU IS IT LV NL NO PL PT RS SE SI TR UA

# Used in targets that run only for one corpus
CORPUS=

# Version number and PID of next ParlaMint release
VERSION = 5.0
HANDLE-TEI = http://hdl.handle.net/11356/2004
HANDLE-ANA = http://hdl.handle.net/11356/2005
HANDLE-MT  = http://hdl.handle.net/11356/2006

# For IL only:
# VERSION = 1.0
# HANDLE-TEI = http://hdl.handle.net/11356/2032
# HANDLE-ANA = http://hdl.handle.net/11356/2032

#Absolute paths are needed otherwise problems with XSLT
PARLAMINT := $(shell realpath .. | tr -d '\n')# get real absolute path to ParlaMint directory
HERE = ${PARLAMINT}/Build
TEMP = ${HERE}/Temp
SCH = ${PARLAMINT}/Schema
# Where the submitted corpora are found: ParlaMint-XX.TEI/ and ParlaMint-XX.TEI.ana
SOURCES = ${HERE}/Sources-TEI
# ParlaMint-XX-en.TEI.ana, MTed + semantically tagged:
SOURCES-MT = ${HERE}/Sources-CoNLLU

#Where the produced corpora are put for inspection
WEB = tomaz@nl.ijs.si:/home/tomaz/www/tmp/ParlaMint

##Note that script variables are at the end of the Makefile!

###### Targets

### Overviews to be put in Metadata/
### This should be done once all the corpora have been built
metadata:	metadata-persons metadata-orgs metadata-quant-tsv metadata-quant-tex
#Make overview LaTeX tables (e.g. for LREV paper)
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

### Make overall root(.ana) for ParlaMint for Sources-TEI/ and Distro/, 
### This should be done once all the corpora have been built
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

###### Various tests
test-tei2:
	${FINALIZE} -valid -codes SI -in ${HERE}/Distro -out ${HERE}/Distro
test-tei1:
	${FINALIZE} -tei -codes BG -in ${HERE}/Sources-TEI -out ${HERE}/Distro
test-vert6:
	../Scripts/parlamintp-tei2vert-xx.pl ${HERE}/Distro/ParlaMint-LV.TEI.ana Test/ParlaMint-LV-xx.vert
test-vert5:
	$s meta=../Build/Distro/ParlaMint-SI.TEI.ana/ParlaMint-SI.ana.xml -xsl:../Scripts/parlamint2xmlvert.xsl \
	../Build/Distro/ParlaMint-SI.TEI.ana/2020/ParlaMint-SI_2020-03-13-SDZ8-Izredna-31.ana.xml  > Test/test-SI.vert
test-vert4:
	$s meta=${HERE}/Distro/ParlaMint-SI.TEI.ana/ParlaMint-SI.ana.xml -xsl:../Scripts/parlamint2xmlvert.xsl \
	${HERE}/Distro/ParlaMint-SI.TEI.ana/2022/ParlaMint-SI_2022-01-13-SDZ8-Izredna-93.ana.xml > test-SI.vert
test-vert2:
	${FINALIZE} -vert -codes SI -in ${HERE}/Distro -out ${HERE}/Distro
test-vert1:
	${FINALIZE} -vert -codes GR -in ${HERE}/Temp -out ${HERE}/Temp
	${FINALIZE} -vert -codes GR-en -in ${HERE}/Temp -out ${HERE}/Temp
test-conll5:
	../Scripts/parlamintp2conllu.pl -jobs 1 -in ../Build/Sources-TEI/ParlaMint-AT.TEI.ana -out ../Build/Test
test-conll4:
	$s meta=../Build/Distro/ParlaMint-SI.TEI.ana/ParlaMint-SI.ana.xml \
	-xsl:../Scripts/parlamint2conllu.xsl ../Build/Distro/ParlaMint-SI.TEI.ana/2000/ParlaMint-SI_2000-10-27-SDZ3-Redna-01.ana.xml \
	> Test/test-SI.conllu
test-conll3:
	${FINALIZE} -conll -codes GR-en -in ${HERE}/Temp -out ${HERE}/Temp
test-conll2:
	${FINALIZE} -conll -codes GR -in ${HERE}/Temp -out ${HERE}/Temp
test-conll1:
	${FINALIZE} -conll -codes UA -in ${HERE}/Distro -out ${HERE}/Distro
test-meta6:
	$s out-lang=en meta=../Build/Sources-TEI/ParlaMint-FR.TEI.ana/ParlaMint-FR.ana.xml -xsl:../Scripts/parlamint2meta.ana.xsl \
	../Build/Sources-TEI/ParlaMint-FR.TEI.ana/2020/ParlaMint-FR_2020-01-07-O1114.ana.xml > Test/test.ana-meta-en.tsv
test-meta5:
	$s out-lang=en meta=../Build/Distro/ParlaMint-SI.TEI/ParlaMint-SI.xml -xsl:../Scripts/parlamint2meta.xsl \
	../Build/Distro/ParlaMint-SI.TEI/2000/ParlaMint-SI_2000-10-27-SDZ3-Redna-01.xml > Test/test.tsv
test-meta4:
	$s out-lang=xx meta=../Build/Distro/ParlaMint-SI/ParlaMint-SI.xml -xsl:../Scripts/parlamint2meta.xsl \
	../Build/Distro/ParlaMint-SI/2007/ParlaMint-SI_2007-11-28-SDZ4-Izredna-30.ana.xml > Test/test.tsv
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
	${FINALIZE} -txt -codes ES -in ${HERE}/Distro -out ${HERE}/Distro
test-text2:
	../Scripts/parlamintp-tei2text.pl -jobs 2 -in ../Build/Distro/ParlaMint-SI -out ../Build/Distro/ParlaMint-SI
test-valid1:
	${FINALIZE} -valid -codes SI -in ${HERE}/Distro -out ${HERE}/Distro
test-fix1:
	$s anaDir=../Build/Distro/ParlaMint-RS outDir=Test -xsl:../Scripts/parlamint2release.xsl \
	../Build/Distro/ParlaMint-RS/ParlaMint-RS.xml
test-fix2:
	$s anaDir=../Build/Distro/ParlaMint-AT outDir=Test -xsl:../Scripts/parlamint2release.xsl \
	../Build/Distro/ParlaMint-AT/ParlaMint-AT.xml

### Fixes
# Merge per-language translated CoNLL-Us (BE, ES-CT, ES-PV, UA) to joint CoNLL-U (with # lang info on newpar)
# It is more useful to have them merged than separate
fix-conll-nohup:
	nohup time make mrg-conll > Logs/ParlaMint_Merge_CoNLL-U.log &
fix-conll:
	Scripts/merge-conllu.pl Distro/ParlaMint-BE.conllu ${SOURCES-MT}/ParlaMint-BE-en.conllu
	Scripts/merge-conllu.pl Distro/ParlaMint-ES-CT.conllu ${SOURCES-MT}/ParlaMint-ES-CT-en.conllu
	Scripts/merge-conllu.pl Distro/ParlaMint-ES-PV.conllu ${SOURCES-MT}/ParlaMint-ES-PV-en.conllu
	Scripts/merge-conllu.pl Distro/ParlaMint-UA.conllu ${SOURCES-MT}/ParlaMint-UA-en.conllu

# In-place fix mistake with handle in corpora
OLD = http://hdl.handle.net/11356/1810
NEW = http://hdl.handle.net/11356/1488
fix-handle:
	for CORPUS in ${CORPORA}; do \
	Scripts/fix-handle.pl ${OLD} ${NEW} "Distro/ParlaMint-$${CORPUS}.TEI.ana/ParlaMint-$${CORPUS}.ana.xml"; \
	Scripts/fix-handle.pl ${OLD} ${NEW} "Distro/ParlaMint-$${CORPUS}.TEI.ana/*/*.ana.xml"; \
	done;

# Post-hoc copy READMEs to master, in case they need to be changed after the corpora have been built
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


# Make vertical file with en metadata, a hack:
XX-CORPORA = AT-xx BA-xx BE-xx BG-xx CZ-xx DK-xx EE-xx ES-xx ES-CT-xx ES-GA-xx ES-PV-xx FI-xx FR-xx GB-xx GR-xx HR-xx HU-xx IS-xx IT-xx LV-xx NL-xx NO-xx PL-xx PT-xx RS-xx SE-xx SI-xx TR-xx UA-xx
# Test: make make-verts-xx CORPORA='LV ES-CT'
make-verts-xx-nohup:
	nohup time make make-verts-xx > Logs/ParlaMint-Verts-xx.log &
make-verts-xx:
	for CORPUS in ${CORPORA}; do \
        ../Scripts/parlamintp-tei2vert-xx.pl -jobs ${THREADS} \
        -in ${HERE}/Distro/ParlaMint-$${CORPUS}.TEI.ana -out Temp/ParlaMint-$${CORPUS}-xx.vert; \
	done;
	perl ../Scripts/join-all-verts.pl -codes '${XX-CORPORA}' -in 'Temp' -out Verts/ParlaMint-XX.${VERSION}.vert

# Make vertical files only
make-verts:
	for CORPUS in ${CORPORA}; do \
	${FINALIZE} -vert -codes $${CORPUS} -in ${SOURCES} -out ${HERE}/Distro; \
	done;
	make verts

# Don't make TEI but only text, vert and conllu files
make-txt-vert-conll:
	for CORPUS in ${CORPORA}; do \
	${FINALIZE} -txt -vert -conll -codes $${CORPUS} -in ${SOURCES} -out ${HERE}/Distro; \
	done;

# Put logs and packed build to web for inspection by corpus compilers
web-nohup:
	nice nohup time make web > ParlaMint-Web.log &
web:
	rsync -av Logs/*.log ${WEB}/Logs
	rsync -av Packed/*.tgz ${WEB}/Repo


###### Targets for producing releasable version of ParlaMint corpora
FINALIZE = perl ../Scripts/parlamint2distro.pl -version ${VERSION} -teihandle ${HANDLE-TEI} -anahandle ${HANDLE-ANA} -schema ../Schema -docs Sources-Distro -procMemGB ${JAVA-MEMORY} -procChunkSize ${CHUNK-SIZE} -procThreads ${THREADS}

### For real
# More than one nohup, in case we want several runs at once
# In which case CORPORA variable needs to be changed first!
nohup1:
	nice nohup time make all > Logs/ParlaMint.1.log &
nohup2:
	nice nohup time make all > Logs/ParlaMint.2.log &
nohup3:
	nice nohup time make all > Logs/ParlaMint.3.log &

all:	final join-verts pack
xall:	final join-verts pack

pack-logs:
	mkdir -p Packed/ParlaMint-logs
	rm -f Packed/ParlaMint-logs/*
	for CORPUS in ${CORPORA}; do \
	cp Logs/ParlaMint-$${CORPUS}.*log Packed/ParlaMint-logs; \
	done
	cd Packed; tar -czf ParlaMint-logs.tgz ParlaMint-logs
	rm -fr Packed/ParlaMint-logs
	mkdir -p Packed/ParlaMint-en-logs
	rm -f Packed/ParlaMint-en-logs/*

pack:
	perl Scripts/pack-parlamint.pl -codes '${CORPORA}' -in Distro -out Packed
join-verts:
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
FINALIZE-MT=perl ../Scripts/parlamint2distro.pl -version ${VERSION} -anahandle ${HANDLE-MT} -schema ${PARLAMINT}/Schema -docs ${HERE}/Sources-Distro -procMemGB ${JAVA-MEMORY} -procChunkSize ${CHUNK-SIZE} -procThreads ${THREADS}

# Targets
mt-nohup1:
	nice nohup time make mt-all > Logs/ParlaMint-en.1.log &
mt-nohup2:
	nice nohup time make mt-all > Logs/ParlaMint-en.2.log &
mt-nohup3:
	nice nohup time make mt-all > Logs/ParlaMint-en.3.log &

mt-all:	mt-final
mt-xall-final:	mt-convert mt-final mt-verts mt-pack mt-web

# Make MT .txt and CoNLL files
mt-convert-txt:
	for CORPUS in ${CORPORA}; do \
	${FINALIZE-MT} -txt -conll -codes $${CORPUS}-en -out ${HERE}/Distro; \
	done;
mt-web:
	rsync -av Logs/*-en*.log ${WEB}/Logs
	rsync -av Packed/*-en*.tgz ${WEB}/Repo
mt-pack-logs:
	for CORPUS in ${CORPORA}; do \
	cp Logs/ParlaMint-$${CORPUS}-en.*log Packed/ParlaMint-en-logs; \
	done
	cd Packed; tar -czf ParlaMint-en-logs.tgz ParlaMint-en-logs
	rm -fr Packed/ParlaMint-en-logs
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
	perl ../Scripts/join-all-verts.pl     -codes '${CORPORA}' -in 'Distro' -out Verts/ParlaMint-XX.${VERSION}.vert
	perl ../Scripts/join-all-verts.pl -en -codes '${CORPORA}' -in 'Distro' -out Verts/ParlaMint-XX-en.${VERSION}.vert

# Sanity check for alignment
sanity:
	zcat Verts/ParlaMint-XX.${VERSION}.vert.gz | grep -c '</s>' 
	zcat Verts/ParlaMint-XX-en.${VERSION}.vert.gz | grep -c '</s>' 

# Convert from English CoNLL-U + source .TEI.ana -> -en.TEI.ana
# We did this, won't probably do it again, except for new corpora!
xx-mt-convert:
	for CORPUS in ${CORPORA}; do \
	perl Scripts/parlamint-mt2tei.pl \
	${HERE}/Distro/ParlaMint-$${CORPUS}.TEI.ana/ParlaMint-$${CORPUS}.ana.xml \
	${SOURCES-MT}/ParlaMint-$${CORPUS}-en-notes.tsv \
	${SOURCES-MT}/ParlaMint-$${CORPUS}-en.sem \
	${SOURCES}/ParlaMint-$${CORPUS}-en.TEI.ana 2> Logs/ParlaMint-$${CORPUS}-en.prepare.log; \
	done;

# Finalise -en.TEI.ana corpora
mt-final:
	for CORPUS in ${CORPORA}; do \
	${FINALIZE-MT} -all -notei -codes $${CORPUS}-en -in ${SOURCES} -out ${HERE}/Distro 2> Logs/ParlaMint-$${CORPUS}-en.log; \
	grep -a -i 'fatal' Logs/ParlaMint-$${CORPUS}-en.log >  Logs/ParlaMint-$${CORPUS}-en.error.log;  \
	grep -a -i 'error' Logs/ParlaMint-$${CORPUS}-en.log >> Logs/ParlaMint-$${CORPUS}-en.error.log;  \
	grep -a -i 'warn'  Logs/ParlaMint-$${CORPUS}-en.log >  Logs/ParlaMint-$${CORPUS}-en.warn.log;  \
	echo "$${CORPUS}-en.warn"; \
	cat Logs/ParlaMint-$${CORPUS}-en.warn.log | wc -l;  \
	cat Logs/ParlaMint-$${CORPUS}-en.warn.log | sort | uniq | wc -l;  \
	echo "$${CORPUS}-en.error"; \
	cat Logs/ParlaMint-$${CORPUS}-en.error.log | wc -l;  \
	cat Logs/ParlaMint-$${CORPUS}-en.error.log | sort | uniq | wc -l;  \
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
	${HERE}/Distro/ParlaMint-AT-en.TEI.ana/ParlaMint-AT-en.ana.xml
	$s meta=${HERE}/Distro/ParlaMint-AT-en.TEI.ana/ParlaMint-AT-en.ana.xml -xsl:../Scripts/validate-parlamint.xsl \
	${HERE}/Distro/ParlaMint-AT-en.TEI.ana/2005/ParlaMint-AT-en_2005-04-27-022-XXII-NRSITZ-00108.ana.xml
mt-test7:
	$s meta=${HERE}/Distro/ParlaMint-AT-en.TEI.ana/ParlaMint-AT-en.ana.xml -xsl:../Scripts/check-links.xsl \
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

TAXONOMIES-TEI = subcorpus speaker_types parla.legislature topic
TAXONOMIES-ANA = NER sentiment
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

###################### SCRIPT VARIABLES
##$JAVA-MEMORY## Set a java memory maxsize in GB
JAVA-MEMORY=480
JM := $(shell test -n "$(JAVA-MEMORY)" && echo -n "-Xmx$(JAVA-MEMORY)g")

CHUNK-SIZE=500
THREADS=10

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
