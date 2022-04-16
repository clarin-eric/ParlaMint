.DEFAULT_GOAL := help

##$PARLIAMENTS##Space separated list of parliaments codes.
PARLIAMENTS = AT BE BG CZ DK EE ES ES-CT ES-GA ES-PV FI FR GB GR HR HU IS IT LT LV NL NO PL PT RO SE SI TR
PARLIAMENTS-v2 = BE BG CZ DK ES FR GB GR HR HU IS IT LT LV NL PL SI TR
##$DATADIR## Folder with country corpus folders. Default value is 'Data'.
DATADIR = Data
##$WORKINGDIR## In this folder will be stored temporary files. Default value is 'DataTMP'.
WORKINGDIR = Data/TMP
##$CORPUSDIR_SUFFIX## This value is appended to corpus folder so corpus directory name shouldn't be prefix
##$##                 of corpus root file. E.g. setting CORPUSDIR_SUFFIX=.TEI allow running targets on content
##$##                 of ParlaMint-XX.TEI folder that contains corresponding ParlaMint-XX(.ana).xml files.
##$##                 Default value is ''.
CORPUSDIR_SUFFIX =

###### Setup
## check-prereq ## test if prerequisities are installed
check-prereq:
	@test -f /usr/share/java/saxon.jar
	@unzip -p /usr/share/java/saxon.jar META-INF/MANIFEST.MF|grep 'Main-Class:'| grep -q 'net.sf.saxon.Transform'
	@echo "Saxon: OK"
	@test -f /usr/share/java/jing.jar
	@unzip -p /usr/share/java/jing.jar META-INF/MANIFEST.MF|grep 'Main-Class:'| grep -q 'relaxng'
	@echo "Jing: OK"
	@test -f Scripts/tools/validate.py
	@python -m re
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
	find ${DATADIR} -type f -path "${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-*.xml" | grep -v '.ana.' | grep -v '_' | xargs ${vrt}
	find ${DATADIR} -type f -path "${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-*.xml" | grep -v '.ana.' | grep    '_' | xargs ${vct}

$(val-schema-ana-ParlaMint-XX): val-schema-ana-ParlaMint-%: %
	find ${DATADIR} -type f -path "${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-*.xml" | grep    '.ana.' | grep -v '_' | xargs ${vra}
	find ${DATADIR} -type f -path "${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-*.xml" | grep    '.ana.' | grep    '_' | xargs ${vca}


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
	for root in `find ${DATADIR} -type f -path "${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-*.xml" | grep -v '_'`;	do \
	  echo "checking links in root:" $${root}; \
	  ${s} ${vlink} $${root}; \
	  for component in `echo $${root}| xargs ${getincludes}`; do \
	    echo "checking links in component:" ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/$${component}; \
	    ${s} meta=$(PWD)/$${root} ${vlink} ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/$${component}; \
	  done; \
	done



###### Check content
check-content-XX = $(addprefix check-content-, $(PARLIAMENTS))
## check-content ## validate all corpora with Scripts/validate-parlamint.xsl
check-content: $(check-content-XX)
## check-content-XX ## ...
$(check-content-XX): check-content-%: %
	for root in `find ${DATADIR} -type f -path "${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-*.xml" | grep -v '_'`;	do \
	  echo "checking content in root:" $${root}; \
	  ${s} ${vcontent} $${root}; \
	  for component in `echo $${root}| xargs ${getincludes}`; do \
	    echo "checking content in component:" ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/$${component}; \
	    ${s} ${vcontent} ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/$${component}; \
	  done; \
	done



###### Validate ParlaMint validate-parlamint.pl
validate-parlamint-XX = $(addprefix validate-parlamint-, $(PARLIAMENTS))
## validate-parlamint ## validate all corpora with Scripts/validate-parlamint.pl
validate-parlamint: $(validate-parlamint-XX)
## validate-parlamint-XX ## validate country XX (equivalent to val-lang in previous makefile)
$(validate-parlamint-XX): validate-parlamint-%: %
	Scripts/validate-parlamint.pl Schema '${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}'



###### Convert (and validate)

## root ## Make ParlaMint corpus root
root:
	$s -xsl:Scripts/parlamint2root.xsl Scripts/ParlaMint-template.xml > ${DATADIR}/ParlaMint.xml
	$s -xsl:Scripts/parlamint2root.xsl Scripts/ParlaMint-template.ana.xml > ${DATADIR}/ParlaMint.ana.xml


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
	'$s hdr=../${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-$<.xml -xsl:Scripts/parlamint2meta.xsl \
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
	  awk '{gsub(/(<[a-zA-Z:]+)/,"& LINE=\"" NR "\"",$$0);print}' "$$file"\
	  | java -jar /usr/share/java/saxon.jar -xsl:Scripts/validate-parlamint-particDesc.xsl -s:- ;\
	done


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
fix-v2tov3-diff: $(fix-v2tov3-XX)
##!fix-v2tov3-diff-XX##
$(fix-v2tov3-diff-XX): fix-v2tov3-diff-%: %
	@find ${WORKINGDIR}/fix-v2tov3/ParlaMint-$<${CORPUSDIR_SUFFIX} -type f -printf '%f\n' \
	  | xargs -I {} \
	      diff --text --width=250 --suppress-common-lines --side-by-side --ignore-space-change \
	           ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/{} \
	           ${WORKINGDIR}/fix-v2tov3/ParlaMint-$<${CORPUSDIR_SUFFIX}/{} \
	  || : # supress exit error when files are different


s = java -jar /usr/share/java/saxon.jar
P = parallel --gnu --halt 2
j = java -jar /usr/share/java/jing.jar
copy = -I % $s -xi:on -xsl:Scripts/copy.xsl -s:% -o:%.all-in-one.xml
vlink = -xsl:Scripts/check-links.xsl
vcontent = -xsl:Scripts/validate-parlamint.xsl
getincludes = -I % xmllint --xpath '//*[local-name()="include"]/@href' % |sed 's/^ *href="//;s/"//'
pc =  $j Schema/parla-clarin.rng
vrt = $j Schema/ParlaMint-teiCorpus.rng 	# Corpus root / text
vct = $j Schema/ParlaMint-TEI.rng		# Corpus component / text
vra = $j Schema/ParlaMint-teiCorpus.ana.rng	# Corpus root / analysed
vca = $j Schema/ParlaMint-TEI.ana.rng		# Corpus component / analysed
