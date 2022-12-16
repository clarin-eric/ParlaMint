.DEFAULT_GOAL := help

##$PARLIAMENTS##Space separated list of parliaments codes.
PARLIAMENTS = AT BE BG CZ DK EE ES ES-CT ES-GA ES-PV FI FR GB GR HR HU IS IT LT LV NL NO PL PT RO SE SI TR BA RS
PARLIAMENTS-v2 = BE BG CZ DK ES FR GB HR HU IS IT LT LV NL PL SI TR


##$DATADIR## Folder with country corpus folders. Default value is 'Data'.
DATADIR = Data
##$WORKINGDIR## In this folder will be stored temporary files. Default value is 'DataTMP'.
WORKINGDIR = Data/TMP
##$CORPUSDIR_SUFFIX## This value is appended to corpus folder so corpus directory name shouldn't be prefix
##$##                 of corpus root file. E.g. setting CORPUSDIR_SUFFIX=.TEI allow running targets on content
##$##                 of ParlaMint-XX.TEI folder that contains corresponding ParlaMint-XX(.ana).xml files.
##$##                 Default value is ''.
CORPUSDIR_SUFFIX =

DATA_XX_REP = ParlaMint-data-XX
CURRENT_COMMIT := $(shell git rev-parse --short HEAD)

###### Setup
## check-prereq ## test if prerequisities are installed, more about installing prerequisities in CONTRIBUTING.md file
check-prereq:
	@test -f /usr/share/java/saxon.jar
	@unzip -p /usr/share/java/saxon.jar META-INF/MANIFEST.MF|grep 'Main-Class:'| grep -q 'net.sf.saxon.Transform'
	@echo "Saxon: OK"
	@test -f /usr/share/java/jing.jar
	@unzip -p /usr/share/java/jing.jar META-INF/MANIFEST.MF|grep 'Main-Class:'| grep -q 'relaxng'
	@echo "Jing: OK"
	@test -f Scripts/tools/validate.py
	@python3 -m re
	@echo "UD tools: OK"
	@echo "INFO: Maximum java heap size (saxon needs 5-times more than the size of processed xml file)"
	@java -XX:+PrintFlagsFinal -version 2>&1| grep " MaxHeapSize"|sed "s/^.*= *//;s/ .*$$//"|awk '{print "\t" $$1/1024/1024/1024 " GB"}'


setup-parliament:
ifndef PARLIAMENT-CODE
	$(error PARLIAMENT-CODE is not set - use "make TARGET PARLIAMENT-CODE='<CODE>'" )
endif
ifndef PARLIAMENT-NAME
	$(error PARLIAMENT-NAME is not set - use "make TARGET PARLIAMENT-NAME='<COUNTRY>'" )
endif
ifndef LANG-LIST
	$(error LANG-LIST is not set - use "make TARGET LANG-LIST='<langcode1> (Language1), <langcode2> (Language2)'" )
endif
	test ! -d ./Data/ParlaMint-$(PARLIAMENT-CODE)
	mkdir ./Data/ParlaMint-$(PARLIAMENT-CODE)
	echo "# ParlaMint directory for samples of country $(PARLIAMENT-CODE) ($(PARLIAMENT-NAME))" > ./Data/ParlaMint-$(PARLIAMENT-CODE)/README.md
	echo "## Languages: $(LANG-LIST)" >> ./Data/ParlaMint-$(PARLIAMENT-CODE)/README.md

setup-parliament-newInParlaMint2:
	make setup-parliament PARLIAMENT-NAME='Austria' PARLIAMENT-CODE='AT' LANG-LIST='de (German)'
	make setup-parliament PARLIAMENT-NAME='Basque Country' PARLIAMENT-CODE='ES-PV' LANG-LIST='eu (Basque)'
	make setup-parliament PARLIAMENT-NAME='Catalonia' PARLIAMENT-CODE='ES-CT' LANG-LIST='ca (Catalan)'
	make setup-parliament PARLIAMENT-NAME='Estonia' PARLIAMENT-CODE='EE' LANG-LIST='et (Estonian)'
	make setup-parliament PARLIAMENT-NAME='Finland' PARLIAMENT-CODE='FI' LANG-LIST='fi (Finnish)'
	make setup-parliament PARLIAMENT-NAME='Greece' PARLIAMENT-CODE='GR' LANG-LIST='el (Greek)'
	make setup-parliament PARLIAMENT-NAME='Norway' PARLIAMENT-CODE='NO' LANG-LIST='no (Norwegian)'
	make setup-parliament PARLIAMENT-NAME='Portugal' PARLIAMENT-CODE='PT' LANG-LIST='pt (Portuguese)'
	make setup-parliament PARLIAMENT-NAME='Romania' PARLIAMENT-CODE='RO' LANG-LIST='ro (Romanian)'
	make setup-parliament PARLIAMENT-NAME='Sweden' PARLIAMENT-CODE='SE' LANG-LIST='sv (Swedish)'
	make setup-parliament PARLIAMENT-NAME='Galicia' PARLIAMENT-CODE='ES-GA' LANG-LIST='gl (Galician)'
	make setup-parliament PARLIAMENT-NAME='Bosnia and Herzegovina' PARLIAMENT-CODE='BA' LANG-LIST='bs (Bosnian)'
	make setup-parliament PARLIAMENT-NAME='Serbia' PARLIAMENT-CODE='RS' LANG-LIST='sr (Serbian)'


###### Validate with Relax NG schema
val-schema-XX = $(addprefix val-schema-, $(PARLIAMENTS))
val-schema-tei-XX = $(addprefix val-schema-tei-, $(PARLIAMENTS))
val-schema-ana-XX = $(addprefix val-schema-ana-, $(PARLIAMENTS))
val-schema-ParlaMint-XX = $(addprefix val-schema-ParlaMint-, $(PARLIAMENTS))
val-schema-ParlaCLARIN-XX = $(addprefix val-schema-ParlaCLARIN-, $(PARLIAMENTS))
val-schema-tei-ParlaMint-XX = $(addprefix val-schema-tei-ParlaMint-, $(PARLIAMENTS))
val-schema-tei-ParlaCLARIN-XX = $(addprefix val-schema-tei-ParlaCLARIN-, $(PARLIAMENTS))
val-schema-ana-ParlaMint-XX = $(addprefix val-schema-ana-ParlaMint-, $(PARLIAMENTS))
val-schema-ana-ParlaCLARIN-XX = $(addprefix val-schema-ana-ParlaCLARIN-, $(PARLIAMENTS))

## val-schema ## run all corpora Relax NG validation on tei+ana versions
####with ParlaMint and Parla-CLARIN schemas
val-schema: $(val-schema-XX)

## val-schema-XX ## run country XX  Relax NG validation on tei+ana versions with ParlaMint and Parla-CLARIN schemas
$(val-schema-XX): val-schema-%: val-schema-ParlaMint-% val-schema-ParlaCLARIN-%
	echo "parliament validation $@ | " $(subst val-,,$@)

## val-schema-tei ## run all corpora Relax NG validation on tei versions with ParlaMint and Parla-CLARIN schemas
val-schema-tei: $(val-schema-tei-XX)
## val-schema-tei-XX ## ...
$(val-schema-tei-XX): val-schema-tei-%: val-schema-tei-ParlaMint-% val-schema-tei-ParlaCLARIN-%

## val-schema-ana ## run all corpora Relax NG validation on ana versions with ParlaMint and Parla-CLARIN schemas
val-schema-ana: $(val-schema-ana-XX)
## val-schema-ana-XX ## ...
$(val-schema-ana-XX): val-schema-ana-%: val-schema-ana-ParlaMint-% val-schema-ana-ParlaCLARIN-%

## val-schema-ParlaMint ## run all corpora Relax NG validation on tei+ana versions with ParlaMint schema
val-schema-ParlaMint: $(val-schema-ParlaMint-XX)
## val-schema-ParlaMint-XX ## ...
$(val-schema-ParlaMint-XX): val-schema-ParlaMint-%: val-schema-tei-ParlaMint-% val-schema-ana-ParlaMint-%

## val-schema-ParlaCLARIN ## run all corpora Relax NG validation on tei+ana versions with Parla-CLARIN schema
val-schema-ParlaCLARIN: $(val-schema-ParlaCLARIN-XX)
## val-schema-ParlaCLARIN-XX ## ...
$(val-schema-ParlaCLARIN-XX): val-schema-ParlaCLARIN-%: val-schema-tei-ParlaCLARIN-% val-schema-ana-ParlaCLARIN-%

$(val-schema-tei-ParlaMint-XX): val-schema-tei-ParlaMint-%: %
	find ${DATADIR} -type f -path "${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-$<.xml" | xargs ${vrt}
	find ${DATADIR} -type f -path "${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-$<_*.xml" | grep -v '.ana.' | xargs ${vct}
	find ${DATADIR} -type f -path "${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-*taxonomy*.xml" | grep -v '.ana.' | xargs ${vch_taxonomy}
	find ${DATADIR} -type f -path "${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-$<-listPerson.xml" | xargs ${vch_pers}
	find ${DATADIR} -type f -path "${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-$<-listOrg.xml" | xargs ${vch_orgs}

$(val-schema-ana-ParlaMint-XX): val-schema-ana-ParlaMint-%: %
	find ${DATADIR} -type f -path "${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-$<.ana.xml" | xargs ${vra}
	find ${DATADIR} -type f -path "${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-$<_*.ana.xml" | grep    '_' | xargs ${vca}
	find ${DATADIR} -type f -path "${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-*taxonomy*.xml" | xargs ${vch_taxonomy}
	find ${DATADIR} -type f -path "${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-$<-listPerson.xml" | xargs ${vch_pers}
	find ${DATADIR} -type f -path "${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-$<-listOrg.xml" | xargs ${vch_orgs}


$(val-schema-tei-ParlaCLARIN-XX): val-schema-tei-ParlaCLARIN-%: % working-dir-%
	test -f ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-$<.xml \
	  && $s -xi:on -xsl:Scripts/copy.xsl -s:${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-$<.xml -o:${WORKINGDIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-$<.xml \
	  && ${pc} ${WORKINGDIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-$<.xml \
	  || echo "WARNING skipping/failing $@"


$(val-schema-ana-ParlaCLARIN-XX): val-schema-ana-ParlaCLARIN-%: % working-dir-%
	test -f ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-$<.ana.xml \
	  && $s -xi:on -xsl:Scripts/copy.xsl -s:${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-$<.ana.xml -o:${WORKINGDIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-$<.ana.xml \
	  && ${pc} ${WORKINGDIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-$<.ana.xml \
	  || echo "WARNING skipping/failing $@"



###### Check links
check-links-XX = $(addprefix check-links-, $(PARLIAMENTS))
## check-links ## validate all corpora with Scripts/check-links.xsl
check-links: $(check-links-XX)
## check-links-XX ## ...
$(check-links-XX): check-links-%: %
	for root in `find ${DATADIR} -type f -path "${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-*.xml" | grep -P "ParlaMint-$<${CORPUSDIR_SUFFIX}(|ana).xml"`;	do \
	  echo "checking links in root:" $${root}; \
	  ${s} ${vlink} $${root}; \
	  for component in `echo $${root}| xargs ${getheaderincludes}`; do \
	    echo "checking links in header component:" ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/$${component}; \
	    ${s} meta=$(PWD)/$${root} ${vlink} ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/$${component}; \
	  done; \
	  for component in `echo $${root}| xargs ${getcomponentincludes}`; do \
	    echo "checking links in component:" ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/$${component}; \
	    ${s} meta=$(PWD)/$${root} ${vlink} ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/$${component}; \
	  done; \
	done



###### Check content
check-content-XX = $(addprefix check-content-, $(PARLIAMENTS))
## check-content ## validate all corpora with Scripts/validate-parlamint.xsl
#### and Scripts/validate-parlamint-particDesc.xsl
#### particDesc validation prints line number in messages
check-content: $(check-content-XX)
## check-content-XX ## ...
$(check-content-XX): check-content-%: %
	rm -rf ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/check-content-TMP;
	mkdir ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/check-content-TMP;
	for file2LINE in `find ${DATADIR} -type f -path "${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-*.xml" | grep -P "ParlaMint(:?-$<${CORPUSDIR_SUFFIX})?(|\.ana|-taxonomy.*|-list.*).xml"`;	do \
	  awk '{gsub(/(<[a-zA-Z:]+)/,"& LINE=\"" NR "\"",$$0);print}' "$${file2LINE}" \
	    > ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/check-content-TMP/$${file2LINE##*/};\
	done
	for root in `find ${DATADIR} -type f -path "${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-$<${CORPUSDIR_SUFFIX}*.xml" | grep -P "ParlaMint-$<${CORPUSDIR_SUFFIX}(|\.ana).xml"`;	do \
	  echo "checking content in root:" $${root}; \
	  echo "  - general"; \
	  ${s} ${vcontent} $${root}; \
	  echo "  - organisations + persons"; \
	  ${s} -xsl:Scripts/validate-parlamint-particDesc.xsl "${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/check-content-TMP/$${root##*/}" ;\
	  for component in `echo $${root}| xargs ${getcomponentincludes}`; do \
	    echo "checking content in component:" ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/$${component}; \
	    ${s} ${vcontent} ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/$${component}; \
	  done; \
	done
	rm -r ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/check-content-TMP



###### Validate ParlaMint validate-parlamint.pl
validate-parlamint-XX = $(addprefix validate-parlamint-, $(PARLIAMENTS))
## validate-parlamint ## validate all corpora with Scripts/validate-parlamint.pl
#### (not showing line numbers in messages)
validate-parlamint: $(validate-parlamint-XX)
## validate-parlamint-XX ## validate country XX (equivalent to val-lang in previous makefile)
$(validate-parlamint-XX): validate-parlamint-%: %
	Scripts/validate-parlamint.pl Schema '${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}'



###### Convert (and validate)

## root ## Make ParlaMint corpus root
root:
	$s base=../Data -xsl:Scripts/parlamint2root.xsl \
	Scripts/ParlaMint-template.xml > ${DATADIR}/ParlaMint.xml
	$s base=../Data -xsl:Scripts/parlamint2root.xsl \
	Scripts/ParlaMint-template.ana.xml > ${DATADIR}/ParlaMint.ana.xml

chars-XX = $(addprefix chars-, $(PARLIAMENTS))
## chars ## create character tables
chars: $(chars-XX)
## chars-XX ## ...
$(chars-XX): chars-%: %
	rm -f ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/chars-files-$<.tbl
	rm -f ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-$<_*.tmp
	nice find ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ -name 'ParlaMint-$<_*.txt' | \
	$P --jobs 20 'cut -f2 {} > {.}.tmp'
	nice find ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ -name 'ParlaMint-$<_*.tmp' | \
	$P --jobs 20 'Scripts/chars.pl {} >> ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/chars-files-$<.tbl'
	test -f ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-$<.xml \
	 && Scripts/chars-summ.pl < ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/chars-files-$<.tbl \
	    > ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/chars-$<.tbl \
	  || echo "WARNING skipping/failing $@ (missing txt files or chars-summ.pl failed)"
	rm -f ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-$<_*.tmp


text-XX = $(addprefix text-, $(PARLIAMENTS))
## text ## create text version from tei files
text: $(text-XX)
## text-XX ## convert tei files to text
$(text-XX): text-%: %
	rm -f ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-$<_*.txt
	find ${DATADIR} -type f -path "${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-$<_*.xml" | grep -v '.ana.' | $P --jobs 10 \
	'$s -xsl:Scripts/parlamint-tei2text.xsl {} > ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/{/.}.txt'



meta-XX = $(addprefix meta-, $(PARLIAMENTS))
## meta ## generate metadata tables from unanotated version
meta: $(meta-XX)
## meta-XX ## ...
$(meta-XX): meta-%: %
	rm -f ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/*-meta.tsv
	find ${DATADIR} -type f -path "${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-*_*.xml" | grep -v '.ana.' | $P --jobs 10 \
	'$s meta=../${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-$<.xml -xsl:Scripts/parlamint2meta.xsl \
	{} > ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/{/.}-meta.tsv'



conllu-XX = $(addprefix conllu-, $(PARLIAMENTS))
## conllu ## create connlu format files and valide them (parlamint2conllu.pl)
conllu: $(conllu-XX)
## conllu-XX ##
$(conllu-XX): conllu-%: %
	rm -f ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/*.conllu
	test -f ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-$<.ana.xml \
	  && Scripts/parlamint2conllu.pl ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX} ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX} \
	  || echo "WARNING skipping/failing $@"


vertana-XX = $(addprefix vertana-, $(PARLIAMENTS))
## vertana ## create anotated vertical file (parlamint-tei2vert.pl)
vertana: $(vertana-XX)
## vertana-XX ##
$(vertana-XX): vertana-%: %
	rm -f ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/*.vert
	test -f ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-$<.ana.xml \
	  && Scripts/parlamint-tei2vert.pl ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-$<.ana.xml ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX} \
	  || echo "WARNING skipping/failing $@"


###### Fixings and common content

add-common-content-XX = $(addprefix add-common-content-, $(PARLIAMENTS))
## add-common-content ## calculate and add common content (tagUsage,)
add-common-content: $(add-common-content-XX)
## add-common-content-XX ##
$(add-common-content-XX): add-common-content-%: %
	rm -rf ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/add-common-content
	mkdir -p ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/add-common-content
	$s outDir=${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/add-common-content \
	   -xsl:Scripts/parlamint-add-common-content.xsl \
	   ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-$<.ana.xml || :
	$s outDir=${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/add-common-content \
	   anaDir=`pwd`/${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/add-common-content/ParlaMint-$<${CORPUSDIR_SUFFIX} \
	   -xsl:Scripts/parlamint-add-common-content.xsl \
	   ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-$<.xml || :
	for component in `echo ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-$<.ana.xml| xargs ${getheaderincludes}`; do \
	  echo "copying header component: ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/$${component}" ; \
	    cp ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/$${component} ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/add-common-content/ParlaMint-$<${CORPUSDIR_SUFFIX}; \
	done;
	echo "Result is in: ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/add-common-content/ParlaMint-$<${CORPUSDIR_SUFFIX}"

factorize-teiHeader-XX = $(addprefix factorize-teiHeader-, $(PARLIAMENTS))
## factorize-teiHeader ## move the content of listPerson, listOrg and all taxonomies elements
#### from teiHeader into separate files and xincludes them
factorize-teiHeader: $(factorize-teiHeader-XX)
## factorize-teiHeader-XX ##
$(factorize-teiHeader-XX): factorize-teiHeader-%: %
	rm -rf ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/factorize-teiHeader
	mkdir -p ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/factorize-teiHeader
	$s outDir=${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/factorize-teiHeader \
	   prefix="ParlaMint-$<${CORPUSDIR_SUFFIX}-" \
	   -xsl:Scripts/parlamint-factorize-teiHeader.xsl \
	   ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-$<.xml || :
	SKIP=`echo ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/factorize-teiHeader/ParlaMint-$<.xml| xargs ${getheaderincludes}|tr "\n" " " ` \
	&& $s outDir=${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/factorize-teiHeader \
	   prefix="ParlaMint-$<${CORPUSDIR_SUFFIX}-" \
	   skip="$${SKIP}" \
	   -xsl:Scripts/parlamint-factorize-teiHeader.xsl \
	   ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-$<.ana.xml || :

factorize-teiHeader-INPLACE-XX = $(addprefix factorize-teiHeader-INPLACE-, $(PARLIAMENTS))
## factorize-teiHeader-INPLACE ##
factorize-teiHeader-INPLACE: $(factorize-teiHeader-INPLACE-XX)
## factorize-teiHeader-INPLACE-XX ##
$(factorize-teiHeader-INPLACE-XX): factorize-teiHeader-INPLACE-%: % factorize-teiHeader-%
	@echo "modified files:"
	@(cd ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/factorize-teiHeader/; ls ParlaMint-$<${CORPUSDIR_SUFFIX}*.xml|grep -v 'ParlaMint-$<${CORPUSDIR_SUFFIX}-')
	@echo "new files:"
	@(cd ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/factorize-teiHeader/; ls ParlaMint-$<${CORPUSDIR_SUFFIX}-*.xml ) || :
	@mv ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/factorize-teiHeader/* ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/
	@rm -r ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/factorize-teiHeader
	@test -d .git && echo -n "=================\nINFO: Changes in ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}\n" && git status ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX} || :


composite-teiHeader-XX = $(addprefix composite-teiHeader-, $(PARLIAMENTS))
## composite-teiHeader ## oposite to factorize-teiHeader
composite-teiHeader: $(composite-teiHeader-XX)
## composite-teiHeader-XX ##
$(composite-teiHeader-XX): composite-teiHeader-%: %
	rm -rf ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/composite-teiHeader
	mkdir -p ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/composite-teiHeader
	$s outDir=${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/composite-teiHeader \
	   -xsl:Scripts/parlamint-composite-teiHeader.xsl \
	   ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-$<.xml 2>&1 \
	   | tee -a ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/composite-teiHeader/included.log || :
	$s outDir=${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/composite-teiHeader \
	   -xsl:Scripts/parlamint-composite-teiHeader.xsl \
	   ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-$<.ana.xml 2>&1 \
	   | tee -a ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/composite-teiHeader/included.log || :

composite-teiHeader-INPLACE-XX = $(addprefix composite-teiHeader-INPLACE-, $(PARLIAMENTS))
## composite-teiHeader-INPLACE ##
composite-teiHeader-INPLACE: $(composite-teiHeader-INPLACE-XX)
## composite-teiHeader-INPLACE-XX ##
$(composite-teiHeader-INPLACE-XX): composite-teiHeader-INPLACE-%: % composite-teiHeader-%
	@echo "modified files:"
	@(cd ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/composite-teiHeader/; ls ParlaMint-$<${CORPUSDIR_SUFFIX}*.xml|grep -v 'ParlaMint-$<${CORPUSDIR_SUFFIX}-')
	@echo "removed files:"
	@cat ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/composite-teiHeader/included.log|sed -n 's/^including: //p'|sort|uniq
	@cat ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/composite-teiHeader/included.log|sed -n 's/^including: //p'|sort|uniq \
	  | xargs -I {} rm ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/{}
	@mv ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/composite-teiHeader/*.xml ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/
	@rm -r ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/composite-teiHeader
	@test -d .git && echo -n "=================\nINFO: Changes in ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}\n" && git status ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX} || :



######---------------
.PHONY: $(PARLIAMENTS)
$(PARLIAMENTS):

help-intro:
	@echo "replace XX with country code or run target without -XX to process all countries: \n\t ${PARLIAMENTS}\n "

help-variables:
	@echo "\033[1m\033[32mVARIABLES:\033[0m"
	@echo "Variable VAR with value 'value' can be set when calling target TARGET in $(MAKEFILE_LIST): make VAR=value TARGET"
	@grep -E '^## *\$$[a-zA-Z_-]*.*?##.*$$' $(MAKEFILE_LIST) |sed 's/^## *\$$/##/'| awk 'BEGIN {FS = " *## *"}; {printf "\033[1m%s\033[0m\033[36m%-18s\033[0m %s\n", $$4, $$2, $$3}'

help-targets:
	@echo "\033[1m\033[32mTARGETS:\033[0m"
	@grep -E '^## *[a-zA-Z_-]+.*?##.*$$|^####' $(MAKEFILE_LIST) | awk 'BEGIN {FS = " *## *"}; {printf "\033[1m%s\033[0m\033[36m%-25s\033[0m %s\n", $$4, $$2, $$3}'


.PHONY: help
## help ## print this help
help: help-intro help-variables help-targets

## help-advanced ## print full help
help-advanced: help
	@echo "\033[1m\033[32mADVANCED:\033[0m"
	@echo "If you want to run target on multiple targets but not all, you can overwrite PARLIAMENTS variable. E.g. make check-links PARLIAMENTS=\"GB CZ\""
	@grep -E '^## *![a-zA-Z_-]+.*?##.*$$|^##!##' $(MAKEFILE_LIST) |sed 's/^## *!/##/'| awk 'BEGIN {FS = " *## *"}; {printf "\033[1m%s\033[0m\033[35m%-25s\033[0m %s\n", $$4, $$2, $$3}'




$(addprefix working-dir-, $(PARLIAMENTS)): working-dir-%: %
	mkdir -p ${WORKINGDIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}


##!####DEVEL
##!DEV-list-script-local-deps## for each file in Scripts folder shows list of dependencies in Script folder
DEV-list-script-local-deps:
	regex=`ls -p Scripts| grep -v "/"| tr '\n' '|'|sed 's/|$$//'`; \
	for file in `ls -p Scripts| grep -v "/"`; do \
	  echo -n "$$file:\t"; \
	  grep -Eo "$$regex" Scripts/$$file|grep -v "^$$file$$"|sort|uniq| tr '\n' ' '; \
	  echo;\
	done


DEV-validate-particDesc-XX = $(addprefix DEV-validate-particDesc-, $(PARLIAMENTS))
##!DEV-validate-particDesc ##
DEV-validate-particDesc: $(DEV-validate-particDesc-XX)
##!DEV-validate-particDesc-XX ##
$(DEV-validate-particDesc-XX): DEV-validate-particDesc-%: % working-dir-%
	for file in `find ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX} -name ParlaMint-$<.xml | grep -v "_"`; do \
	  ${s} -xsl:Scripts/validate-parlamint-particDesc.xsl $${file} ;\
	done


DEV-val-schema-ParlaMintODD-XX = $(addprefix DEV-val-schema-ParlaMintODD-, $(PARLIAMENTS))
##!DEV-val-schema-ParlaMintODD ## run all corpora Relax NG validation on tei+ana versions with ParlaMint schema
DEV-val-schema-ParlaMintODD: $(DEV-val-schema-ParlaMintODD-XX)
##!DEV-val-schema-ParlaMintODD-XX ## ...
$(DEV-val-schema-ParlaMintODD-XX): DEV-val-schema-ParlaMintODD-%: %
	find ${DATADIR} -type f -path "${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-*.xml" | xargs ${vodd}



DEV-links-summ-XX = $(addprefix DEV-links-summ-, $(PARLIAMENTS))
##!DEV-links-summ## print table with numbers of links by type for corpus root files (file fromAttribute fromElement toElement linkType #)
DEV-links-summ:
	make $(DEV-links-summ-XX) | perl -e 'my (%tab,%country);while(<>){my($$n,$$c,$$t)=/^(\d+)\t([^\t]*)\t(.*)/; next unless $$c; $$country{$$c}=1;$$tab{$$t}//={};$$tab{$$t}->{$$c}=$$n;};print "file\tfromAt\tfromEl\ttoEl\ttarget";foreach $$c (sort keys %country){printnum($$c)};print "\n";foreach my $$t (sort keys %tab){print "$$t";foreach $$c (sort keys %country){printnum($$tab{$$t}->{$$c}//"-")};print "\n"};sub printnum{print "\t" . shift}'
##!DEV-links-summ-XX## ...
$(DEV-links-summ-XX): DEV-links-summ-%: %
	@for root in `find ${DATADIR} -type f -path "${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-*.xml" | grep -v '_'`;	do \
	  ${s} ${listlink} $${root} 2>&1; \
	  for component in `echo $${root}| xargs ${getincludes}`; do \
	    ${s} meta=$(PWD)/$${root} ${listlink} ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/$${component} 2>&1; \
	  done \
	done |sed "s/ [^ ]*$$//"| sort|uniq -c|sed "s/^ *//"|tr -s " "| tr " " "\t"

DEV-roles-summ-XX = $(addprefix DEV-roles-summ-, $(PARLIAMENTS))
##!DEV-roles-summ## print table with numbers of roles (affiliation -> organisation) use unanotated corpus file (affiliationRole orgRole #)
DEV-roles-summ:
	make $(DEV-roles-summ-XX) | perl -e 'my (%tab,%country);while(<>){my($$n,$$c,$$t)=/^(\d+)\t([^\t]*)\t(.*)/; next unless $$c; $$country{$$c}=1;$$tab{$$t}//={};$$tab{$$t}->{$$c}=$$n;};print "affiliationRole\torgRole";foreach $$c (sort keys %country){printnum($$c)};print "\n";foreach my $$t (sort keys %tab){print "$$t";foreach $$c (sort keys %country){printnum($$tab{$$t}->{$$c}//"-")};print "\n"};sub printnum{print "\t" . shift}'
##!DEV-roles-summ-XX## ...
$(DEV-roles-summ-XX): DEV-roles-summ-%: %
	@find ${DATADIR} -type f -path "${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-$<.xml" | \
	  xargs -I {} ${s} ${listrole} {} 2>&1 |sort|uniq -c|sed "s/^ *//"|tr -s " "| tr " " "\t"

DEV-attributes-summ-XX = $(addprefix DEV-attributes-summ-, $(PARLIAMENTS))
##!DEV-attributes-summ## print table with numbers of element-attributes pairs (element attribute #)
DEV-attributes-summ:
	make $(DEV-attributes-summ-XX) | perl -e 'my (%tab,%country);while(<>){my($$n,$$c,$$t)=/^(\d+)\t([^\t]*)\t(.*)/; next unless $$c; $$country{$$c}=1;$$tab{$$t}//={};$$tab{$$t}->{$$c}=$$n;};print "element\tattribute";foreach $$c (sort keys %country){printnum($$c)};print "\n";foreach my $$t (sort keys %tab){print "$$t";foreach $$c (sort keys %country){printnum($$tab{$$t}->{$$c}//"-")};print "\n"};sub printnum{print "\t" . shift}'
##!DEV-attributes-summ-XX## ...
$(DEV-attributes-summ-XX): DEV-attributes-summ-%: %
	@for root in `find ${DATADIR} -type f -path "${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-*.xml" | grep -v '_'`;	do \
	  ${s} ${listattr} $${root} 2>&1; \
	  for component in `echo $${root}| xargs ${getincludes}`; do \
	    ${s} ${listattr} ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/$${component} 2>&1; \
	  done \
	done | sort|uniq -c|sed "s/^ *//"|tr -s " "| tr " " "\t"

##!DEV-speaker_types-in-taxonomy## print speaker types: id english_term ParlaMint-XX local_term
DEV-speaker_types-in-taxonomy:
	@echo -n "category_id\tterm_en\tcode\tterm_local\n"
	@for root in `find ${DATADIR} -type f -path "${DATADIR}/ParlaMint-*${CORPUSDIR_SUFFIX}/ParlaMint-*.xml" | grep -v '_'| grep -v '.ana.xml'`; do \
	  java -cp /usr/share/java/saxon.jar net.sf.saxon.Query -xi:off \!method=adaptive \
	      -qs:'//*:taxonomy[@xml:id="speaker_types"]//*:category/concat(@xml:id,"|"  ,.//*:term[ancestor-or-self::*[@xml:lang][1]/@xml:lang="en"],"|"   ,/*:teiCorpus/@xml:id,"|"   ,.//*:term[not(ancestor-or-self::*[@xml:lang][1]/@xml:lang="en") ])' \
	      -s:$${root} ; \
	  echo;\
	done | sed 's/^"//;s/"$$//;s/ParlaMint-//;s/|/\t/g'|sort|uniq


fix-v2tov3-XX = $(addprefix fix-v2tov3-, $(PARLIAMENTS-v2))
##!fix-v2tov3 ## convert ParlaMint v2 format to ParlaMint v3 format
fix-v2tov3: $(fix-v2tov3-XX)
##!fix-v2tov3-XX ##
$(fix-v2tov3-XX): fix-v2tov3-%: % working-dir-%
	rm -rf ${WORKINGDIR}/fix-v2tov3/ParlaMint-$<${CORPUSDIR_SUFFIX}
	./Scripts/fixings/v2tov3/v2tov3.pl '${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/**.xml' ${WORKINGDIR}/fix-v2tov3
	@echo -n "INFO: "
	@find ${WORKINGDIR}/fix-v2tov3/ParlaMint-$<${CORPUSDIR_SUFFIX} -type f | wc -l | tr -d '\n'
	@echo " fixed files are stored in ${WORKINGDIR}/fix-v2tov3/ParlaMint-$<${CORPUSDIR_SUFFIX}"


fix-v2tov3-diff-XX = $(addprefix fix-v2tov3-diff-, $(PARLIAMENTS-v2))
##!fix-v2tov3-diff## show diff between ParlaMint v2 format and converted ParlaMint v3 format
fix-v2tov3-diff: $(fix-v2tov3-diff-XX)
##!fix-v2tov3-diff-XX##
$(fix-v2tov3-diff-XX): fix-v2tov3-diff-%: %
	@find ${WORKINGDIR}/fix-v2tov3/ParlaMint-$<${CORPUSDIR_SUFFIX} -type f -printf '%f\n' \
	  | xargs -I {} \
	      diff --text --width=250 --suppress-common-lines --side-by-side --ignore-space-change \
	           ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/{} \
	           ${WORKINGDIR}/fix-v2tov3/ParlaMint-$<${CORPUSDIR_SUFFIX}/{} \
	  || : # supress exit error when files are different

fix-overlapping-affiliations-XX = $(addprefix fix-overlapping-affiliations-, $(PARLIAMENTS-v2))
##!fix-overlapping-affiliations ## convert ParlaMint v2 format to ParlaMint v3 format
fix-overlapping-affiliations: $(fix-overlapping-affiliations-XX)
##!fix-overlapping-affiliations-XX ##
$(fix-overlapping-affiliations-XX): fix-overlapping-affiliations-%: % working-dir-%
	rm -rf ${WORKINGDIR}/fix-overlapping-affiliations/ParlaMint-$<${CORPUSDIR_SUFFIX}
	mkdir -p ${WORKINGDIR}/fix-overlapping-affiliations/ParlaMint-$<${CORPUSDIR_SUFFIX}
	find ${DATADIR} -type f -path "${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-$<*.xml" -printf '%f\n' | grep -v '_' \
	| xargs -I {} $s ${faff} -s:${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/{} -o:${WORKINGDIR}/fix-overlapping-affiliations/ParlaMint-$<${CORPUSDIR_SUFFIX}/{}


fix-v2tov3-full-XX = $(addprefix fix-v2tov3-full-, $(PARLIAMENTS-v2))
##!fix-v2tov3-full ## convert ParlaMint v2 format to ParlaMint v3 format and fix overlapping affiliations
fix-v2tov3-full: $(fix-v2tov3-full-XX)
##!fix-v2tov3-full-XX ##
$(fix-v2tov3-full-XX): fix-v2tov3-full-%: % working-dir-% fix-v2tov3-%
	rm -rf ${WORKINGDIR}/fix-v2tov3-full/ParlaMint-$<${CORPUSDIR_SUFFIX}
	mkdir -p ${WORKINGDIR}/fix-v2tov3-full/ParlaMint-$<${CORPUSDIR_SUFFIX}
	make fix-overlapping-affiliations-$< DATADIR=${WORKINGDIR}/fix-v2tov3
	rsync -av ${WORKINGDIR}/fix-v2tov3/ParlaMint-$<${CORPUSDIR_SUFFIX}/ ${WORKINGDIR}/fix-v2tov3-full/ParlaMint-$<${CORPUSDIR_SUFFIX}
	rsync -av ${WORKINGDIR}/fix-overlapping-affiliations/ParlaMint-$<${CORPUSDIR_SUFFIX}/ ${WORKINGDIR}/fix-v2tov3-full/ParlaMint-$<${CORPUSDIR_SUFFIX}


##! DEV-data-XX-clone-in-subfolder##
DEV-data-XX-clone-in-subfolder:
	git clone git@github.com:clarin-eric/ParlaMint.git ${DATA_XX_REP}

DEV-data-XX-create-branch-XX = $(addprefix DEV-data-XX-create-branch-, $(PARLIAMENTS-v2))
##!DEV-data-XX-create-branch ## create data-XX branch for each country from data branch in DATA_XX_REP folder
DEV-data-XX-create-branch: .update_DATA_XX_REP $(DEV-data-XX-create-branch-XX)
##!DEV-data-XX-create-branch-XX ##
$(DEV-data-XX-create-branch-XX): DEV-data-XX-create-branch-%: %
	git -C ${DATA_XX_REP} checkout data
	git -C ${DATA_XX_REP} checkout -b data-$<

DEV-data-XX-reset-data-XX = $(addprefix DEV-data-XX-reset-data-, $(PARLIAMENTS-v2))
##!DEV-data-XX-reset-data ##
DEV-data-XX-reset-data: .update_DATA_XX_REP $(DEV-data-XX-reset-data-XX)
##!DEV-data-XX-reset-data-XX ##
$(DEV-data-XX-reset-data-XX): DEV-data-XX-reset-data-%: %
	git -C ${DATA_XX_REP} checkout data
	git -C ${DATA_XX_REP} pull
	git -C ${DATA_XX_REP} checkout data-$<
	# this avoid merge conflicts, we just want to overwrite xml content with content drom data branch:
	rm -f ${DATA_XX_REP}/${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-$<*.xml
	git -C ${DATA_XX_REP} checkout data ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/
	# git -C ${DATA_XX_REP} ls-files --deleted|xargs -C ${DATA_XX_REP} git rm
	git -C ${DATA_XX_REP} commit -m "reset xml content of data-$< with data" \
	                             ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-$<*.xml \
	  || echo "No change in xml data"
	git -C ${DATA_XX_REP} restore --staged ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}
	git -C ${DATA_XX_REP} ls-files --modified | xargs git -C ${DATA_XX_REP} checkout
	git -C ${DATA_XX_REP} ls-files --others --exclude-standard |sed "s@^@${DATA_XX_REP}/@"| xargs -I {} rm {}
	# merge other changes to keep data-XX branch updated
	git -C ${DATA_XX_REP} merge data

DEV-data-XX-sync-with-data-and-push-XX = $(addprefix DEV-data-XX-sync-with-data-and-push-, $(PARLIAMENTS-v2))
##!DEV-data-XX-sync-with-data-and-push ##
DEV-data-XX-sync-with-data-and-push: .update_DATA_XX_REP $(DEV-data-XX-sync-with-data-and-push-XX)
##!DEV-data-XX-sync-with-data-and-push-XX ##
$(DEV-data-XX-sync-with-data-and-push-XX): DEV-data-XX-sync-with-data-and-push-%: %
	git -C ${DATA_XX_REP} pull origin data
	git -C ${DATA_XX_REP} checkout data-$<
	git -C ${DATA_XX_REP} merge data
	git -C ${DATA_XX_REP} push --set-upstream origin data-$<

DEV-data-XX-fix-XX = $(addprefix DEV-data-XX-fix-, $(PARLIAMENTS-v2))
##!DEV-data-XX-fix ##
DEV-data-XX-fix-XX: $(DEV-data-XX-fix-XX)
##!DEV-data-XX-fix-XX ##
$(DEV-data-XX-fix-XX): DEV-data-XX-fix-%: % DEV-data-XX-reset-data-%
	git -C ${DATA_XX_REP} checkout data-$<
	make fix-v2tov3-full-$< DATADIR=${DATA_XX_REP}/${DATADIR} WORKINGDIR=${DATA_XX_REP}/${WORKINGDIR}
	rsync -av ${DATA_XX_REP}/${WORKINGDIR}/fix-v2tov3-full/ParlaMint-$<${CORPUSDIR_SUFFIX}/ \
	          ${DATA_XX_REP}/${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}
	git -C ${DATA_XX_REP} status
	#git -C ${DATA_XX_REP} commit -m "fix data-$< with  v2tov3 [${CURRENT_COMMIT}]" \
	#                             ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-$<*.xml
	git -C ${DATA_XX_REP} commit -a -m "fix data-$< with  v2tov3 [${CURRENT_COMMIT}]"
	echo "to push changes:"
	echo "git -C ${DATA_XX_REP} push --set-upstream origin data-$<"


.update_DATA_XX_REP:
	git -C ${DATA_XX_REP} pull --all


##!create-UD-SYN-taxonomy##
create-taxonomy-UD-SYN:
	test -d Scripts/UD-docs || git clone git@github.com:UniversalDependencies/docs.git Scripts/UD-docs
	git -C Scripts/UD-docs checkout pages-source
	git -C Scripts/UD-docs pull
	Scripts/create-taxonomy-UD-SYN.pl --in Scripts/UD-docs --out ParlaMint-taxonomy-UD-SYN.ana.xml


######################Generating and ingesting TSV added metadata

## Generate TSV files for party information on the basis of the corpus root files.
generate-parties:
	$s path=../${DATADIR} outDir=Data/Metadata/Parties -xsl:Scripts/parties-tei2tsv.xsl \
	${DATADIR}/ParlaMint.xml 2> Data/Metadata/Parties/ParlaMint_parties.log

## Insert political orientation of parties from TSV file into a root file.
insert-orientation-test-all:
	make insert-orientation-test OC=BE DATADIR=../ParlaMint-v2tov3/Data
	make insert-orientation-test OC=BG DATADIR=../ParlaMint-v2tov3/Data
	make insert-orientation-test OC=CZ DATADIR=../ParlaMint-v2tov3/Data
	make insert-orientation-test OC=DK DATADIR=../ParlaMint-v2tov3/Data
	make insert-orientation-test OC=ES DATADIR=../ParlaMint-v2tov3/Data
	make insert-orientation-test OC=FR DATADIR=../ParlaMint-v2tov3/Data
	make insert-orientation-test OC=GB DATADIR=../ParlaMint-v2tov3/Data
	make insert-orientation-test OC=IS DATADIR=../ParlaMint-v2tov3/Data
	make insert-orientation-test OC=IT DATADIR=../ParlaMint-v2tov3/Data
	make insert-orientation-test OC=LT DATADIR=../ParlaMint-v2tov3/Data
	make insert-orientation-test OC=LV DATADIR=../ParlaMint-v2tov3/Data
	make insert-orientation-test OC=NL DATADIR=../ParlaMint-v2tov3/Data
	make insert-orientation-test OC=IT DATADIR=../ParlaMint-v2tov3/Data
	make insert-orientation-test OC=PL DATADIR=../ParlaMint-v2tov3/Data
	make insert-orientation-test OC=SI DATADIR=../ParlaMint-v2tov3/Data
	make insert-orientation-test OC=TR DATADIR=../ParlaMint-v2tov3/Data

OC = DK
insert-orientation-test-new:
	$s tsv=../Data/Metadata/Parties/Orientation-${OC}.tsv -xsl:Scripts/orientations-tsv2tei.xsl \
	${DATADIR}/ParlaMint-${OC}/ParlaMint-${OC}-listOrg.xml > Scripts/tmp/ParlaMint-${OC}-listOrg.xml
insert-orientation-test:
	$s tsv=../Data/Metadata/Parties/Orientation-${OC}.tsv -xsl:Scripts/orientations-tsv2tei.xsl \
	${DATADIR}/ParlaMint-${OC}/ParlaMint-${OC}.xml > Scripts/tmp/ParlaMint-${OC}.xml
insert-orientation-test-val:
	$s tsv=../Data/Metadata/Parties/Orientation-${OC}.tsv -xsl:Scripts/orientations-tsv2tei.xsl \
	${DATADIR}/ParlaMint-${OC}/ParlaMint-${OC}.xml > Scripts/tmp/ParlaMint-${OC}.xml
	#-diff -b ${DATADIR}/ParlaMint-${OC}/ParlaMint-${OC}.xml Scripts/tmp/ParlaMint-${OC}.xml
	#${pc} Scripts/tmp/ParlaMint-${OC}.xml
	#${vrt} Scripts/tmp/ParlaMint-${OC}.xml
	#${s} ${vlink} Scripts/tmp/ParlaMint-${OC}.xml

## Generate TSV files for minister affiliations on the basis of the corpus root files.
generate-ministers:
	$s outDir=Data/Ministers -xsl:Scripts/ministers-tei2tsv.xsl ${DATADIR}/ParlaMint.xml

## Insert minister affiliations from TSV file into a root file.
MC = BE
TSV = /project/corpora/Parla/ParlaMint/Minister
insert-ministries-test:
	$s tsv=${TSV}/ParlaMint_ministers-${MC}.tsv -xsl:Scripts/ministers-tsv2tei.xsl \
	${DATADIR}/ParlaMint-${MC}/ParlaMint-${MC}.xml > Scripts/tmp/ParlaMint-${MC}.xml
	-diff -b ${DATADIR}/ParlaMint-${MC}/ParlaMint-${MC}.xml Scripts/tmp/ParlaMint-${MC}.xml
	${vrt} Scripts/tmp/ParlaMint-${MC}.xml
	${s} ${vlink} Scripts/tmp/ParlaMint-${MC}.xml

######################VARIABLES
s = java -jar /usr/share/java/saxon.jar
P = parallel --gnu --halt 2
j = java -jar /usr/share/java/jing.jar
copy = -I % $s -xi:on -xsl:Scripts/copy.xsl -s:% -o:%.all-in-one.xml
vlink = -xsl:Scripts/check-links.xsl
listlink = -xsl:Scripts/list-links.xsl
listrole = -xsl:Scripts/list-affiliation-org-role-pairs.xsl
listattr = -xsl:Scripts/list-element-attribute.xsl
faff = -xsl:Scripts/fixings/fix-overlapping-affiliations.xsl
vcontent = -xsl:Scripts/validate-parlamint.xsl
getincludes = -I % java -cp /usr/share/java/saxon.jar net.sf.saxon.Query -xi:off \!method=adaptive -qs:'//*[local-name()="include"]/@href' -s:% |sed 's/^ *href="//;s/"//'
getheaderincludes = -I % java -cp /usr/share/java/saxon.jar net.sf.saxon.Query -xi:off \!method=adaptive -qs:'//*[local-name()="teiHeader"]//*[local-name()="include"]/@href' -s:% |sed 's/^ *href="//;s/"//'
getcomponentincludes = -I % java -cp /usr/share/java/saxon.jar net.sf.saxon.Query -xi:off \!method=adaptive -qs:'/*/*[local-name()="include"]/@href' -s:% |sed 's/^ *href="//;s/"//'
pc =  $j Schema/parla-clarin.rng                # Validate with Parla-CLARIN schema
vrt = $j Schema/ParlaMint-teiCorpus.rng 	# Corpus root / text
vct = $j Schema/ParlaMint-TEI.rng		# Corpus component / text
vra = $j Schema/ParlaMint-teiCorpus.ana.rng	# Corpus root / analysed
vca = $j Schema/ParlaMint-TEI.ana.rng		# Corpus component / analysed
vodd = $j TEI/ParlaMint.odd.rng		# validate with rng derived from odd
vch_taxonomy = $j Schema/ParlaMint-taxonomy.rng # factorized taxonomy
vch_pers = $j Schema/ParlaMint-listPerson.rng # factorized listPerson
vch_orgs = $j Schema/ParlaMint-listOrg.rng # factorized listOrg
