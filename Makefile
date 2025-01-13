.DEFAULT_GOAL := help

##$PARLIAMENTS: Space separated list of country codes
#Parliaments for V4.1
PARLIAMENTS = AT BE BG CZ DK EE ES ES-CT ES-GA ES-PV FI FR GB GR HR HU IS IT LV NL NO PL PT SE SI TR BA RS UA IL

##$JAVA-MEMORY## Set a java memory maxsize in GB
JAVA-MEMORY =
JM := $(shell test -n "$(JAVA-MEMORY)" && echo -n "-Xmx$(JAVA-MEMORY)g")
PARALLEL-JOBS = 10

LANG-LIST =
leftBRACKET := (
rightBRACKET := )
LANG-CODE-LIST := $(shell echo "$(LANG-LIST)" | sed "s/$(leftBRACKET)[^$(rightBRACKET)]*$(rightBRACKET),*/ /g" | tr -s " " | sed 's/ $$//' )

TAXONOMIES-TRANSLATE-INTERF = NER.ana parla.legislature politicalOrientation speaker_types subcorpus
TAXONOMIES-TRANSLATE = $(addprefix ParlaMint-taxonomy-, $(TAXONOMIES-TRANSLATE-INTERF))

TAXONOMIES-COPY-INTERF = UD-SYN.ana CHES
TAXONOMIES-COPY = $(addprefix ParlaMint-taxonomy-, $(TAXONOMIES-COPY-INTERF))

##$DATADIR## Folder with country corpus folders. Default value is 'Samples'.
DATADIR = Samples
DATACORPORADIR = Build/Distro
SHARED = Build
##$WORKINGDIR## In this folder will be stored temporary files. Default value is 'DataTMP'.
WORKINGDIR = Samples/TMP
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
	@uname -a|grep -iq ubuntu || \
	  ( echo -n "WARN: not running on ubuntu-derived system: " && uname -a )
	@echo -n "Saxon: "
	@test -f ./Scripts/bin/saxon.jar && \
	  unzip -p ./Scripts/bin/saxon.jar META-INF/MANIFEST.MF|grep 'Main-Class:'| grep -q 'net.sf.saxon.Transform' && \
	  echo "OK" || echo "FAIL"
	@echo -n "Jing: "
	@test -f ./Scripts/bin/jing.jar && \
	  unzip -p ./Scripts/bin/jing.jar META-INF/MANIFEST.MF|grep 'Main-Class:'| grep -q 'relaxng' && \
	  echo "OK" || echo "FAIL"
	@echo -n "UD tools: "
	@test -f Scripts/bin/tools/validate.py && \
	  python3 -m re && \
	  echo "OK" || echo "FAIL"
	@which parallel > /dev/null && \
	  echo "parallel: OK" || echo "WARN: command parallel is missing"
	@echo "INFO: Maximum java heap size (saxon needs 5-times more than the size of processed xml file)$(JM)"
	@java $(JM) -XX:+PrintFlagsFinal -version 2>&1| grep " MaxHeapSize"|sed "s/^.*= *//;s/ .*$$//"|awk '{print "\t" $$1/1024/1024/1024 " GB"}'
	@echo "INFO: Setup guide in CONTRIBUTING.md file"


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
	test ! -d ./Samples/ParlaMint-$(PARLIAMENT-CODE)
	mkdir ./Samples/ParlaMint-$(PARLIAMENT-CODE)
	echo "# ParlaMint directory for samples of country $(PARLIAMENT-CODE) ($(PARLIAMENT-NAME))" > ./Samples/ParlaMint-$(PARLIAMENT-CODE)/README.md
	echo "## Languages: $(LANG-LIST)" >> ./Samples/ParlaMint-$(PARLIAMENT-CODE)/README.md
	echo "LANG-CODE-LIST=$(LANG-CODE-LIST)"
	make initTaxonomies-$(PARLIAMENT-CODE) PARLIAMENTS="$(PARLIAMENT-CODE)" LANG-CODE-LIST="$(LANG-CODE-LIST)"
	git status ./Samples/ParlaMint-$(PARLIAMENT-CODE)/*

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


## initTaxonomies-XX ## initialize taxonomies in folder ParlaMint-XX
#### parameter LANG-CODE-LIST can contain space separated list of languages
initTaxonomies-XX = $(addprefix initTaxonomies-, $(PARLIAMENTS))
$(initTaxonomies-XX): initTaxonomies-%: $(addprefix initTaxonomy-%--, $(TAXONOMIES-TRANSLATE)) $(addprefix copyTaxonomy-%--, $(TAXONOMIES-COPY))

# initTaxonomy-XX-tt = $(foreach X,$(PARLIAMENTS),$(foreach Y,$(TAXONOMIES-TRANSLATE), initTaxonomy-$X-$Y))
initTaxonomy-XX-tt = $(foreach X,$(PARLIAMENTS),$(addprefix initTaxonomy-${X}--, $(TAXONOMIES-TRANSLATE) ) )
$(initTaxonomy-XX-tt): initTaxonomy-%:
	@test -z "$(LANG-CODE-LIST)" && echo "WARNING: no language specified in " `echo -n '$*' | sed 's/^.*--//'` " taxonomy preparation" || echo "INFO: preparing " `echo -n '$*' | sed 's/^.*--//'` "taxonomy"
	@${s} langs="$(LANG-CODE-LIST)" parlamint="ParlaMint-"`echo -n '$*' | sed 's/--.*$$//'` -xsl:Scripts/parlamint-init-taxonomy.xsl \
	  ${SHARED}/Taxonomies/`echo -n '$*.xml' | sed 's/^.*--//'` \
	  > ${DATADIR}/ParlaMint-`echo -n '$*' | sed 's/--.*$$//'`${CORPUSDIR_SUFFIX}/`echo -n '$*.xml' | sed 's/^.*--//'`

copyTaxonomy-XX-tt = $(foreach X,$(PARLIAMENTS),$(addprefix copyTaxonomy-${X}--, $(TAXONOMIES-COPY) ) )
$(copyTaxonomy-XX-tt): copyTaxonomy-%:
	@echo "INFO: copying " `echo -n '$*' | sed 's/^.*--//'` "taxonomy"
	@${s} langs="$(LANG-CODE-LIST)" if-lang-missing="skip" -xsl:Scripts/parlamint-init-taxonomy.xsl \
	  ${SHARED}/Taxonomies/`echo -n '$*.xml' | sed 's/^.*--//'` \
	  > ${DATADIR}/ParlaMint-`echo -n '$*' | sed 's/--.*$$//'`${CORPUSDIR_SUFFIX}/`echo -n '$*.xml' | sed 's/^.*--//'`



translateTaxonomies-XX = $(addprefix translateTaxonomies-, $(PARLIAMENTS))
$(translateTaxonomies-XX): translateTaxonomies-%: $(addprefix translateTaxonomy-%--, $(TAXONOMIES-TRANSLATE))


translateTaxonomy-XX-tt = $(foreach X,$(PARLIAMENTS),$(addprefix translateTaxonomy-${X}--, $(TAXONOMIES-TRANSLATE) ) )
$(translateTaxonomy-XX-tt): translateTaxonomy-%:
	$(eval $@_XX := $(shell echo -n '$*' | sed 's/--.*$$//'))
	$(eval $@_tt := $(shell echo -n '$*' | sed 's/^.*--//'))
	$(eval $@_langs := $(shell grep 'ParlaMint-$($@_XX)$$' ${SHARED}/Taxonomies/taxonomy-translation-responsibility.tsv|cut -f1|tr "\n" " "))
	@echo "INFO: ParlaMint $($@_XX)"
	@echo "INFO: Taxonomy $($@_tt)"
	@echo "INFO: Languages $($@_langs)"
	@mkdir tmp || :
	@test -e `pwd`/${DATADIR}/ParlaMint-$($@_XX)${CORPUSDIR_SUFFIX}/$($@_tt).xml \
	|| echo -n "\nERROR: missing taxonomy  ${DATADIR}/ParlaMint-$($@_XX)${CORPUSDIR_SUFFIX}/$($@_tt).xml\n"
	@echo -n "INFO: validating translation taxonomy ${DATADIR}/ParlaMint-$($@_XX)${CORPUSDIR_SUFFIX}/$($@_tt).xml: " \
	&& ${vch_taxonomy} ${DATADIR}/ParlaMint-$($@_XX)${CORPUSDIR_SUFFIX}/$($@_tt).xml \
	&& echo OK \
	&& echo "INFO: translating $($@_tt) taxonomy" \
	&& ${s} parlamint="ParlaMint-$($@_XX)${CORPUSDIR_SUFFIX}" \
	      translation-input=`pwd`/${DATADIR}/ParlaMint-$($@_XX)${CORPUSDIR_SUFFIX}/$($@_tt).xml  \
	      langs="$($@_langs) -" \
	      -xsl:Scripts/parlamint-add-translation-to-taxonomy.xsl \
	      ${SHARED}/Taxonomies/$($@_tt).xml \
	      > tmp/temporary-taxonomy.xml \
	&& echo -n "INFO: validating output taxonomy with new translations: " \
	&& ${vch_taxonomy} tmp/temporary-taxonomy.xml \
	&& echo OK \
	&& cp tmp/temporary-taxonomy.xml ${SHARED}/Taxonomies/$($@_tt).xml \
	|| echo -n "\nERROR: validations failed ${DATADIR}/ParlaMint-$($@_XX)${CORPUSDIR_SUFFIX}/$($@_tt).xml\n"


initTaxonomies4translation-XX = $(addprefix initTaxonomies4translation-, $(PARLIAMENTS))
$(initTaxonomies4translation-XX): initTaxonomies4translation-%: $(addprefix initTaxonomy4translation-%--, $(TAXONOMIES-TRANSLATE))


initTaxonomy4translation-XX-tt = $(foreach X,$(PARLIAMENTS),$(addprefix initTaxonomy4translation-${X}--, $(TAXONOMIES-TRANSLATE) ) )
$(initTaxonomy4translation-XX-tt): initTaxonomy4translation-%:
	$(eval $@_XX := $(shell echo -n '$*' | sed 's/--.*$$//'))
	$(eval $@_tt := $(shell echo -n '$*' | sed 's/^.*--//'))
	$(eval $@_langs := $(shell grep 'ParlaMint-$($@_XX)$$' ${SHARED}/Taxonomies/taxonomy-translation-responsibility.tsv|cut -f1|tr "\n" " "|sed "s/ $$//"))
	@echo "INFO: ParlaMint $($@_XX)"
	@echo "INFO: Taxonomy $($@_tt)"
	@echo "INFO: Languages $($@_langs)"
	make initTaxonomy-$($@_XX)--$($@_tt) LANG-CODE-LIST="$($@_langs)"


validateTaxonomies-XX = $(addprefix validateTaxonomies-, $(PARLIAMENTS))
$(validateTaxonomies-XX): validateTaxonomies-%: $(addprefix validateTaxonomy-%--, $(TAXONOMIES-TRANSLATE))

validateTaxonomy-XX-tt = $(foreach X,$(PARLIAMENTS),$(addprefix validateTaxonomy-${X}--, $(TAXONOMIES-TRANSLATE) ) )
$(validateTaxonomy-XX-tt): validateTaxonomy-%:
	@test -e `pwd`/${DATADIR}/ParlaMint-`echo -n '$*' | sed 's/--.*$$//'`${CORPUSDIR_SUFFIX}/`echo -n '$*.xml' | sed 's/^.*--//'` \
	|| echo -n "\nERROR: missing taxonomy " ${DATADIR}/ParlaMint-`echo -n '$*' | sed 's/--.*$$//'`${CORPUSDIR_SUFFIX}/`echo -n '$*.xml' | sed 's/^.*--//'`,"\n"
	@echo -n "INFO: validating translation taxonomy" ${DATADIR}/ParlaMint-`echo -n '$*' | sed 's/--.*$$//'`${CORPUSDIR_SUFFIX}/`echo -n '$*.xml' | sed 's/^.*--//'` ": " \
	&& ${vch_taxonomy} ${DATADIR}/ParlaMint-`echo -n '$*' | sed 's/--.*$$//'`${CORPUSDIR_SUFFIX}/`echo -n '$*.xml' | sed 's/^.*--//'` \
	&& echo OK \
	|| echo -n "\nERROR: validation failed  " ${DATADIR}/ParlaMint-`echo -n '$*' | sed 's/--.*$$//'`${CORPUSDIR_SUFFIX}/`echo -n '$*.xml' | sed 's/^.*--//'`,"\n"


#	@cp ${SHARED}/Taxonomies/`echo -n '$*.xml' | sed 's/^.*--//'` \
#	   ${DATADIR}/ParlaMint-`echo -n '$*' | sed 's/--.*$$//'`${CORPUSDIR_SUFFIX}/`echo -n '$*.xml' | sed 's/^.*--//'`


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
	find -H ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX} -maxdepth 1 -type f -name "ParlaMint-$<.xml" | xargs ${vrt}
	find -H ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX} -maxdepth 2 -type f -name "ParlaMint-$<_*.xml" | grep -v '.ana.' | xargs ${vct}
	find -H ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX} -maxdepth 1 -type f -name "ParlaMint-*taxonomy*.xml" | grep -v '.ana.' | xargs ${vch_taxonomy}
	find -H ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX} -maxdepth 1 -type f -name "ParlaMint-$<-listPerson.xml" | xargs ${vch_pers}
	find -H ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX} -maxdepth 1 -type f -name "ParlaMint-$<-listOrg.xml" | xargs ${vch_orgs}

$(val-schema-ana-ParlaMint-XX): val-schema-ana-ParlaMint-%: %
	find -H ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX} -maxdepth 1 -type f -name "ParlaMint-$<.ana.xml" | xargs ${vra}
	find -H ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX} -maxdepth 2 -type f -name "ParlaMint-$<_*.ana.xml" | grep    '_' | xargs ${vca}
	find -H ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX} -maxdepth 1 -type f -name "ParlaMint-*taxonomy*.xml" | xargs ${vch_taxonomy}
	find -H ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX} -maxdepth 1 -type f -name "ParlaMint-$<-listPerson.xml" | xargs ${vch_pers}
	find -H ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX} -maxdepth 1 -type f -name "ParlaMint-$<-listOrg.xml" | xargs ${vch_orgs}


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
	for root in `find -H ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX} -maxdepth 1 -type f -name "ParlaMint-*.xml" | grep -P "ParlaMint-$<${CORPUSDIR_SUFFIX}(|\.ana).xml"`;	do \
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
	for file2LINE in `find -H ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX} -maxdepth 1 -type f -name "ParlaMint-*.xml" | grep -P "ParlaMint(:?-$<${CORPUSDIR_SUFFIX})?(|\.ana|-taxonomy.*|-list.*).xml"`;	do \
	  awk '{gsub(/(<[a-zA-Z:]+)/,"& LINE=\"" NR "\"",$$0);print}' "$${file2LINE}" \
	    > ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/check-content-TMP/$${file2LINE##*/};\
	done
	for root in `find -H ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX} -maxdepth 1 -type f -name "ParlaMint-$<${CORPUSDIR_SUFFIX}*.xml" | grep -P "ParlaMint-$<${CORPUSDIR_SUFFIX}(|\.ana).xml"`;	do \
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
	Scripts/validate-parlamint.pl Schema '${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}' || echo "ERROR: fatal error when validating ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}"



###### Convert (and validate)

## root ## Make ParlaMint corpus root
root-master:
	$s base=../${DATACORPORADIR} type=TEI -xsl:Scripts/parlamint2root.xsl \
	Scripts/ParlaMint-rootTemplate.xml > ${DATACORPORADIR}/ParlaMint.xml
	$s base=../${DATACORPORADIR} type=TEI.ana -xsl:Scripts/parlamint2root.xsl \
	Scripts/ParlaMint-rootTemplate.xml > ${DATACORPORADIR}/ParlaMint.ana.xml
	$s base=../${DATACORPORADIR} type=en.TEI.ana -xsl:Scripts/parlamint2root.xsl \
	Scripts/ParlaMint-rootTemplate.xml > ${DATACORPORADIR}/ParlaMint-en.ana.xml
root-sample:
	for t_i in TEI_ TEI.ana_.ana en.TEI.ana_-en.ana; do \
	  type=$${t_i%_*};\
	  interfix=$${t_i#*_};\
	  $s base=../$(DATADIR) \
	    type=$$type \
	    isSample=1 \
	    -xsl:Scripts/parlamint2root.xsl \
	    Scripts/ParlaMint-rootTemplate.xml > ${DATADIR}/ParlaMint$$interfix.xml ; \
	done


chars-XX = $(addprefix chars-, $(PARLIAMENTS))
## chars ## create character tables
chars: $(chars-XX)
## chars-XX ## ...
$(chars-XX): chars-%: %
	rm -f ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/chars-files-$<.tbl
	rm -f ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-$<_*.tmp
	nice find -H ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ -name 'ParlaMint-$<_*.txt' | \
	$P --jobs 20 'cut -f2 {} > {.}.tmp'
	nice find -H ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ -name 'ParlaMint-$<_*.tmp' | \
	$P --jobs 20 'Scripts/chars.pl {} >> ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/chars-files-$<.tbl'
	test -f ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-$<.xml \
	 && Scripts/chars-summ.pl < ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/chars-files-$<.tbl \
	    > ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/chars-$<.tbl \
	  || echo "WARNING skipping/failing $@ (missing txt files or chars-summ.pl failed)"
	rm -f ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-$<_*.tmp


text-XX = $(addprefix text-, $(PARLIAMENTS))
## text ## create text version from TEI files
text: $(text-XX)
## text-XX ## convert TEI files to text
$(text-XX): text-%: %
	rm -f `ls ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-$<_*.txt |  grep -v '.ana.'`
	find -H ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX} -maxdepth 2 -type f -name "ParlaMint-$<_*.xml" | grep -v '.ana.' | $P --jobs 10 \
	'$s -xsl:Scripts/parlamint-tei2text.xsl {} > ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/{.}.txt'

text.ana-XX = $(addprefix text.ana-, $(PARLIAMENTS))
## text.ana ## create text version from TEI.ana files
text.ana: $(text.ana-XX)
## text.ana-XX ## convert TEI.ana files to text
$(text.ana-XX): text.ana-%: %
	rm -f ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-$<_*.ana.txt
	find -H ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX} -maxdepth 2 -type f -name "ParlaMint-$<_*.xml" | grep '.ana.' | $P --jobs 10 \
	'$s -xsl:Scripts/parlamint-tei2text.xsl {} > ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/{.}.txt'



meta-XX = $(addprefix meta-, $(PARLIAMENTS))
## meta ## generate metadata tables from unanotated version
meta: $(meta-XX)
## meta-XX ## ...
$(meta-XX): meta-%: %
	rm -f ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/*-meta.tsv
	find -H ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX} -maxdepth 2 -type f -name "ParlaMint-*_*.xml" | grep -v '.ana.' | $P --jobs 10 \
	'$s meta=../${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-$<.xml -xsl:Scripts/parlamint2meta.xsl \
	{} > ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/{.}-meta.tsv'



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


###### Useful conversions and scripts

text.seg-XX = $(addprefix text.seg-, $(PARLIAMENTS))
## text.seg ## create text version from TEI files - each line contains one segment
text.seg: $(text.seg-XX)
## text.seg-XX ## convert TEI files to text
$(text.seg-XX): text.seg-%: %
	@mkdir -p ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/text.seg
	@rm -f ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/text.seg/ParlaMint-$<_*.seg.txt
	@find -H ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX} -maxdepth 2 -type f -name "ParlaMint-$<_*.xml" | grep -v '.ana.' | $P --jobs 10 \
	'$s -xsl:Scripts/parlamint-tei2text.xsl element=seg {} > ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/text.seg/{/.}.seg.txt'
	@echo "INFO: segments converted to text are stored in ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/text.seg"

text.seg.ana-XX = $(addprefix text.seg.ana-, $(PARLIAMENTS))
## text.seg.ana ## create text version from TEI.ana files - each line contains one segment
text.seg.ana: $(text.seg.ana-XX)
## text.seg.ana-XX ## convert TEI.ana files to text
$(text.seg.ana-XX): text.seg.ana-%: %
	@mkdir -p ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/text.seg.ana
	@rm -f ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/text.seg.ana/ParlaMint-$<_*.seg.txt
	@find -H ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX} -maxdepth 2 -type f -name "ParlaMint-$<_*.xml" | grep '.ana.' | $P --jobs 10 \
	'$s -xsl:Scripts/parlamint-tei2text.xsl element=seg {} > ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/text.seg.ana/{/.}'
	@find -H ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/text.seg.ana -type f | $P  'mv {} {.}.seg.txt'
	@echo "INFO: annotated segments converted to text are stored in ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/text.seg.ana"




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

##!####DISTRO

sync-Sources-TEI-XX = $(addprefix sync-Sources-TEI-, $(PARLIAMENTS))
##!sync-Sources-TEI##
sync-Sources-TEI: $(sync-Sources-TEI-XX)
$(sync-Sources-TEI-XX): sync-Sources-TEI-%:
	rsync -a --compress --progress -e'ssh -oCompression=no' $(SOURCE-LOCATION)/Build/Sources-TEI/ParlaMint-$*.TEI* Build/Sources-TEI/


distro-make-all-XX = $(addprefix distro-make-all-, $(PARLIAMENTS))
##!distro-make-all## enqueue slurm job for creating distribution from Build/Source-TEI
distro-make-all: $(distro-make-all-XX)
$(distro-make-all-XX): distro-make-all-%: Scripts/slurm_run_make-all.sh
	CORPSIZE=$$(du -s --apparent-size Build/Sources-TEI/ParlaMint-$*.TEI.ana/|cut  -f1); \
	CORPFILES=$$(find Build/Sources-TEI/ParlaMint-$*.TEI.ana/ -type f|wc -l); \
	LARGESTFILE=$$(du -a --apparent-size Build/Sources-TEI/ParlaMint-$*.TEI.ana/ | grep 'xml$$' | sort -n -r | head -n 1 | cut -f1); \
	CHUNKSIZEEXP=$$(echo "20000000 / $$LARGESTFILE" | bc ); \
	CHUNKSIZEREQ=$$( [ "$$CHUNKSIZEEXP" -gt "1000" ] && echo -n 1000 || ( [ "$$CHUNKSIZEEXP" -lt "50" ]  && echo -n 50 || echo  "($$CHUNKSIZEEXP+99) / 100 *100 " | bc) ); \
	MEMEXP=$$(echo "$$LARGESTFILE * $$CHUNKSIZEREQ*2.5/1000000+55" | bc ); \
	MEMREQ=$$( [ "$$CORPFILES" -gt "2000" ] && echo -n 250 || echo -n $$MEMEXP ); \
	CPUREQ=$$( [ "$$MEMREQ" -gt "250" ] && echo -n 14 || ( [ "$$MEMREQ" -gt "200" ]  && echo -n 60 || ([ "$$MEMREQ" -gt "120" ]  && echo -n 30 || echo -n 24 ) )  ); \
	echo "COMMAND: sbatch --job-name=pm$*-distro --mem=$${MEMREQ}G --cpus-per-task=$$CPUREQ Scripts/slurm_run_make-all.sh $* $${MEMREQ} $${CHUNKSIZEREQ}"; \
	sbatch --job-name=pm$*-distro --mem=$${MEMREQ}G --cpus-per-task=$$CPUREQ Scripts/slurm_run_make-all.sh $* $${MEMREQ} $${CHUNKSIZEREQ}



Scripts/slurm_run_make-all.sh:
	echo '#!/bin/bash' > $@
	echo "#SBATCH --chdir=Build/  ## first change directory and then all paths are relative to location" >> $@
	echo '#SBATCH --output=Logs/%x.%j.log' >> $@
	echo '#SBATCH --ntasks=1' >> $@
	echo '#SBATCH --cpus-per-task=30' >> $@
	echo '#SBATCH -p cpu-troja,cpu-ms' >> $@
	echo '#SBATCH -q low' >> $@
	echo '#SBATCH --mem=120G' >> $@
	echo '' >> $@
	echo 'set -e' >> $@
	echo 'which parallel || ( echo "missing parallel ($$(hostname))" && exit 1 )' >> $@
	echo '' >> $@
	echo 'CORP=$$1' >> $@
	echo 'COMMIT=$$(git rev-parse --short HEAD)' >> $@
	echo 'INSIZE=$$(du -s --apparent-size Sources-TEI/ParlaMint-$$CORP.TEI.ana/|cut  -f1)' >> $@
	echo 'echo "$$SLURM_JOB_ID $$CORP"' >> $@
	echo 'MEM=$$2' >> $@
	echo 'CHUNKSIZE=$$3' >> $@
	echo 'CMD="make all CORPORA=$$CORP JAVA-MEMORY=$$MEM CHUNK-SIZE=$$CHUNKSIZE"' >> $@
	echo 'echo -e "$$(date +"%Y-%m-%dT%T")\t$$COMMIT\t$$CORP\tSTARTED\t$$SLURM_JOB_ID\t$$(hostname)\tmem=$$SLURM_MEM_PER_NODE cpus=$$SLURM_CPUS_ON_NODE in_ana=$$(echo "$${INSIZE}/1000000"|bc)GB\t$$CMD" >> Logs/ParlaMint.slurm.log' >> $@
	echo 'RES=$$(/usr/bin/time --output=Logs/ParlaMint.slurm.$$SLURM_JOB_ID.tmp -f "%x\t%E real, %U user, %S sys, %M kB" $$CMD)' >> $@
	echo 'TIME=$$(cut -f 2 Logs/ParlaMint.slurm.$$SLURM_JOB_ID.tmp)' >> $@
	echo 'CODE=$$(cut -f 1 Logs/ParlaMint.slurm.$$SLURM_JOB_ID.tmp)' >> $@
	echo 'rm Logs/ParlaMint.slurm.$$SLURM_JOB_ID.tmp' >> $@
	echo 'echo -e "$$(date +"%Y-%m-%dT%T")\t$$COMMIT\t$$CORP\t$$( [ "$$CODE" -gt "0" ] && echo "FAILED-$$CODE" || echo "FINISHED" )\t$$SLURM_JOB_ID\t$$(hostname)\t$$TIME\t$$CMD" >> Logs/ParlaMint.slurm.log' >> $@

##!####MT DISTRO

sync-Sources-CoNLLU-XX = $(addprefix sync-Sources-CoNLLU-, $(PARLIAMENTS))
##!sync-Sources-CoNLLU##
sync-Sources-CoNLLU: $(sync-Sources-CoNLLU-XX)
$(sync-Sources-CoNLLU-XX): sync-Sources-CoNLLU-%:
	rsync -a --compress --progress -e'ssh -oCompression=no' $(SOURCE-LOCATION)/Build/Sources-CoNLLU/ParlaMint-$*-en* Build/Sources-CoNLLU/

distro-make-mt-all-XX = $(addprefix distro-make-mt-all-, $(PARLIAMENTS))
##!distro-make-mt-all## enqueue slurm job for creating distribution from MT
distro-make-mt-all: $(distro-make-mt-all-XX)
$(distro-make-mt-all-XX): distro-make-mt-all-%: Scripts/slurm_run_make-mt-all.sh
	CORPSIZE=$$(du -s --apparent-size Build/Sources-TEI/ParlaMint-$*.TEI.ana/|cut  -f1); \
	LARGESTFILE=$$(du -a --apparent-size Build/Sources-TEI/ParlaMint-$*.TEI.ana/ | grep 'xml$$' | sort -n -r | head -n 1 | cut -f1); \
	CHUNKSIZEEXP=$$(echo "20000000 / $$LARGESTFILE" | bc ); \
	CHUNKSIZEREQ=$$( [ "$$CHUNKSIZEEXP" -gt "1000" ] && echo -n 1000 || ( [ "$$CHUNKSIZEEXP" -lt "50" ]  && echo -n 50 || echo  "($$CHUNKSIZEEXP+99) / 100 *100 " | bc) ); \
	MEMEXP=$$(echo "$$CHUNKSIZEREQ*2.5/1000000+55" | bc ); \
	MEMREQ=$$( [ "$$MEMEXP" -lt "30" ] && echo -n 30 || echo -n $$MEMEXP ); \
	CPUREQ=$$( [ "$$MEMREQ" -gt "250" ] && echo -n 14 || ( [ "$$MEMREQ" -gt "120" ]  && echo -n 30 || echo -n 24 )  ); \
	echo "COMMAND: sbatch --job-name=pm$*-en-distro --mem=$${MEMREQ}G --cpus-per-task=$$CPUREQ Scripts/slurm_run_make-mt-all.sh $* $${MEMREQ} $${CHUNKSIZEREQ}"; \
	sbatch --job-name=pm$*-en-distro --mem=$${MEMREQ}G --cpus-per-task=$$CPUREQ Scripts/slurm_run_make-mt-all.sh $* $${MEMREQ} $${CHUNKSIZEREQ}

Scripts/slurm_run_make-mt-all.sh:
	echo '#!/bin/bash' > $@
	echo "#SBATCH --chdir=Build/  ## first change directory and then all paths are relative to location" >> $@
	echo '#SBATCH --output=Logs/%x.%j.log' >> $@
	echo '#SBATCH --ntasks=1' >> $@
	echo '#SBATCH --cpus-per-task=30' >> $@
	echo '#SBATCH -p cpu-troja,cpu-ms' >> $@
	echo '#SBATCH -q low' >> $@
	echo '#SBATCH --mem=120G' >> $@
	echo '' >> $@
	echo 'set -e' >> $@
	echo 'which parallel || ( echo "missing parallel ($$(hostname))" && exit 1 )' >> $@
	echo '' >> $@
	echo 'CORP=$$1' >> $@
	echo 'COMMIT=$$(git rev-parse --short HEAD)' >> $@
	echo 'INSIZE=$$(du -s --apparent-size Sources-TEI/ParlaMint-$$CORP.TEI.ana/|cut  -f1)' >> $@
	echo 'echo "$$SLURM_JOB_ID $$CORP"' >> $@
	echo 'MEM=$$2' >> $@
	echo 'CHUNKSIZE=$$3' >> $@
	echo 'CMD="make mt-all CORPORA=$$CORP JAVA-MEMORY=$$MEM CHUNK-SIZE=$$CHUNKSIZE""' >> $@
	echo 'echo -e "$$(date +"%Y-%m-%dT%T")\t$$COMMIT\t$$CORP\tSTARTED\t$$SLURM_JOB_ID\t$$(hostname)\tmem=$$SLURM_MEM_PER_NODE cpus=$$SLURM_CPUS_ON_NODE in_ana=$$(echo "$${INSIZE}/1000000"|bc)GB\t$$CMD" >> Logs/ParlaMint-en.slurm.log' >> $@
	echo 'RES=$$(/usr/bin/time --output=Logs/ParlaMint-en.slurm.$$SLURM_JOB_ID.tmp -f "%x\t%E real, %U user, %S sys, %M kB" $$CMD)' >> $@
	echo 'TIME=$$(cut -f 2 Logs/ParlaMint-en.slurm.$$SLURM_JOB_ID.tmp)' >> $@
	echo 'CODE=$$(cut -f 1 Logs/ParlaMint-en.slurm.$$SLURM_JOB_ID.tmp)' >> $@
	echo 'rm Logs/ParlaMint-en.slurm.$$SLURM_JOB_ID.tmp' >> $@
	echo 'echo -e "$$(date +"%Y-%m-%dT%T")\t$$COMMIT\t$$CORP\t$$( [ "$$CODE" -gt "0" ] && echo "FAILED-$$CODE" || echo "FINISHED" )\t$$SLURM_JOB_ID\t$$(hostname)\t$$TIME\t$$CMD" >> Logs/ParlaMint-en.slurm.log' >> $@

##!####DISTRO2TEITOK
distro2teitok-XX = $(addprefix distro2teitok-, $(PARLIAMENTS))
##!distro2teitok-##
distro2teitok: $(distro2teitok-XX)
$(distro2teitok-XX): distro2teitok-%:
	$(eval TEIanadir :=Build/Distro/ParlaMint-$*.TEI.ana)
	$(eval METAdir :=Build/Distro/ParlaMint-$*.conllu)
	$(eval TTdir :=Build/Teitok/ParlaMint-$*)
	$(eval FL :=$(TTdir)-components.fl)
	test  -d "$(TEIanadir)" || echo "FATAL ERROR: TEI.ana folder is missing: $(TEIanadir)"
	test  -d "$(METAdir)" || echo "FATAL ERROR: conllu folder is missing: $(METAdir)"
	mkdir -p $(TTdir)
	echo  "$(TEIanadir)/ParlaMint-$*.ana.xml" | xargs ${getcomponentincludes} > $(FL)
	bash -c 'paste <(echo;head -n -1 $(FL)) <(cat $(FL)) <(tail -n +2 $(FL))' \
	  | sed 's@\(.*\)\t\(.*\)\t\(.*\)@--prev="\1" --file="$(TEIanadir)/\2" --next="\3"@' \
	  | sed 's/"/\\"/g' \
	  | xargs -L1 echo 'perl Scripts/parlamint2teitok.pl --force --notok --tsvdir="$(METAdir)/" --outdir="$(TTdir)/" ' \
	  > $(TTdir).sh
	cat $(TTdir).sh | parallel --gnu --halt 0 --jobs $(PARALLEL-JOBS)
	rm $(TTdir)-components.fl $(TTdir).sh


slurm-distro2teitok-XX = $(addprefix slurm-distro2teitok-, $(PARLIAMENTS))
##!slurm-distro2teitok-## enqueue slurm job for creating teitok version from distro
slurm-distro2teitok: $(slurm-distro2teitok-XX)
$(slurm-distro2teitok-XX): slurm-distro2teitok-%: Scripts/slurm_run_distro2teitok.sh
	sbatch --job-name=pm$*-tt --mem=10G --cpus-per-task=28 Scripts/slurm_run_distro2teitok.sh $*


Scripts/slurm_run_distro2teitok.sh:
	echo '#!/bin/bash' > $@
	#echo "#SBATCH --chdir=  ## first change directory and then all paths are relative to location" >> $@
	echo '#SBATCH --output=Build/Logs/%x.%j.log' >> $@
	echo '#SBATCH --ntasks=1' >> $@
	echo '#SBATCH --cpus-per-task=30' >> $@
	echo '#SBATCH -p cpu-troja,cpu-ms' >> $@
	echo '#SBATCH -q low' >> $@
	echo '#SBATCH --mem=120G' >> $@
	echo '' >> $@
	echo 'set -e' >> $@
	echo 'which parallel || ( echo "missing parallel ($$(hostname))" && exit 1 )' >> $@
	echo '' >> $@
	echo 'CORP=$$1' >> $@
	echo 'COMMIT=$$(git rev-parse --short HEAD)' >> $@
	echo 'INSIZE=$$(du -s --apparent-size Build/Distro/ParlaMint-$$CORP.TEI.ana/|cut  -f1)' >> $@
	echo 'echo "$$SLURM_JOB_ID $$CORP"' >> $@
	echo '# MEM=$$(echo -n "$$SLURM_MEM_PER_NODE/1000-1" | bc )' >> $@
	echo 'CMD="make distro2teitok PARLIAMENTS=$$CORP PARALLEL-JOBS=$$SLURM_CPUS_ON_NODE"' >> $@
	echo 'echo -e "$$(date +"%Y-%m-%dT%T")\t$$COMMIT\t$$CORP\tSTARTED\t$$SLURM_JOB_ID\t$$(hostname)\tmem=$$SLURM_MEM_PER_NODE cpus=$$SLURM_CPUS_ON_NODE in_ana=$$(echo "$${INSIZE}/1000000"|bc)GB\t$$CMD" >> Build/Logs/ParlaMint.tt.slurm.log' >> $@
	echo 'RES=$$(/usr/bin/time --output=Build/Logs/ParlaMint.tt.slurm.$$SLURM_JOB_ID.tmp -f "%x\t%E real, %U user, %S sys, %M kB" $$CMD)' >> $@
	echo 'TIME=$$(cut -f 2 Build/Logs/ParlaMint.tt.slurm.$$SLURM_JOB_ID.tmp)' >> $@
	echo 'CODE=$$(cut -f 1 Build/Logs/ParlaMint.tt.slurm.$$SLURM_JOB_ID.tmp)' >> $@
	echo 'rm Build/Logs/ParlaMint.tt.slurm.$$SLURM_JOB_ID.tmp' >> $@
	echo 'echo -e "$$(date +"%Y-%m-%dT%T")\t$$COMMIT\t$$CORP\t$$( [ "$$CODE" -gt "0" ] && echo "FAILED-$$CODE" || echo "FINISHED" )\t$$SLURM_JOB_ID\t$$(hostname)\t$$TIME\t$$CMD" >> Build/Logs/ParlaMint.tt.slurm.log' >> $@

##!####TEITOK2CQP
CQPsettings = "cqpsetting file path"
teitok2cqp-XX = $(addprefix teitok2cqp-, $(PARLIAMENTS))
##!teitok2cqp-##
teitok2cqp: $(teitok2cqp-XX)
$(teitok2cqp-XX): teitok2cqp-%: Build/Teitok-cqp check-prereq-teitok2cqp
	settings=`realpath $(CQPsettings)`;\
	cd Build/Teitok-tmp; \
	perl ../../Scripts/teitok2cqp.pl --setfile=$$settings --sub="ParlaMint-$*"

Build/Teitok-cqp:
	mkdir -p Build/Teitok-cqp
	mkdir -p Build/Teitok-tmp/tmp
	ln -s ../Teitok Build/Teitok-tmp/xmlfiles
	ln -s ../Teitok-cqp Build/Teitok-tmp/cqp

check-prereq-teitok2cqp:
	test -f $(CQPsettings) || (echo "missing cqp setting file CQPsettings=$(CQPsettings)" && exit 1)
	test -f Scripts/bin/tt-cwb-encode || (echo "missing Scripts/bin/tt-cwb-encode" && exit 1)
	test -f Scripts/bin/cwb-makeall || (echo "missing Scripts/bin/cwb-makeall" && exit 1)

slurm-teitok2cqp-XX = $(addprefix slurm-teitok2cqp-, $(PARLIAMENTS))
##!slurm-teitok2cqp-## enqueue slurm job for creating teitok version from distro
slurm-teitok2cqp: $(slurm-teitok2cqp-XX)
$(slurm-teitok2cqp-XX): slurm-teitok2cqp-%: Scripts/slurm_run_teitok2cqp.sh check-prereq-teitok2cqp
	sbatch --job-name=pm$*-cqp --mem=10G --cpus-per-task=1 Scripts/slurm_run_teitok2cqp.sh $* $(CQPsettings)

Scripts/slurm_run_teitok2cqp.sh:
	echo '#!/bin/bash' > $@
	#echo "#SBATCH --chdir=  ## first change directory and then all paths are relative to location" >> $@
	echo '#SBATCH --output=Build/Logs/%x.%j.log' >> $@
	echo '#SBATCH --ntasks=1' >> $@
	echo '#SBATCH --cpus-per-task=30' >> $@
	echo '#SBATCH -p cpu-troja,cpu-ms' >> $@
	echo '#SBATCH -q low' >> $@
	echo '' >> $@
	echo 'set -e' >> $@
	echo 'which parallel || ( echo "missing parallel ($$(hostname))" && exit 1 )' >> $@
	echo '' >> $@
	echo 'CORP=$$1' >> $@
	echo 'COMMIT=$$(git rev-parse --short HEAD)' >> $@
	echo 'INSIZE=$$(du -s --apparent-size Build/Distro/ParlaMint-$$CORP.TEI.ana/|cut  -f1)' >> $@
	echo 'echo "$$SLURM_JOB_ID $$CORP"' >> $@
	echo '# MEM=$$(echo -n "$$SLURM_MEM_PER_NODE/1000-1" | bc )' >> $@
	echo 'CMD="make teitok2cqp PARLIAMENTS=$$CORP CQPsettings=$$2"' >> $@
	echo 'echo -e "$$(date +"%Y-%m-%dT%T")\t$$COMMIT\t$$CORP\tSTARTED\t$$SLURM_JOB_ID\t$$(hostname)\tmem=$$SLURM_MEM_PER_NODE cpus=$$SLURM_CPUS_ON_NODE in_ana=$$(echo "$${INSIZE}/1000000"|bc)GB\t$$CMD" >> Build/Logs/ParlaMint.cqp.slurm.log' >> $@
	echo 'RES=$$(/usr/bin/time --output=Build/Logs/ParlaMint.cqp.slurm.$$SLURM_JOB_ID.tmp -f "%x\t%E real, %U user, %S sys, %M kB" $$CMD)' >> $@
	echo 'TIME=$$(cut -f 2 Build/Logs/ParlaMint.cqp.slurm.$$SLURM_JOB_ID.tmp)' >> $@
	echo 'CODE=$$(cut -f 1 Build/Logs/ParlaMint.cqp.slurm.$$SLURM_JOB_ID.tmp)' >> $@
	echo 'rm Build/Logs/ParlaMint.cqp.slurm.$$SLURM_JOB_ID.tmp' >> $@
	echo 'echo -e "$$(date +"%Y-%m-%dT%T")\t$$COMMIT\t$$CORP\t$$( [ "$$CODE" -gt "0" ] && echo "FAILED-$$CODE" || echo "FINISHED" )\t$$SLURM_JOB_ID\t$$(hostname)\t$$TIME\t$$CMD" >> Build/Logs/ParlaMint.cqp.slurm.log' >> $@



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
	for file in `find ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ -name ParlaMint-$<.xml | grep -v "_"`; do \
	  ${s} -xsl:Scripts/validate-parlamint-particDesc.xsl $${file} ;\
	done


DEV-val-schema-ParlaMintODD-XX = $(addprefix DEV-val-schema-ParlaMintODD-, $(PARLIAMENTS))
##!DEV-val-schema-ParlaMintODD ## run all corpora Relax NG validation on tei+ana versions with ParlaMint schema
DEV-val-schema-ParlaMintODD: $(DEV-val-schema-ParlaMintODD-XX)
##!DEV-val-schema-ParlaMintODD-XX ## ...
$(DEV-val-schema-ParlaMintODD-XX): DEV-val-schema-ParlaMintODD-%: %
	find -H ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX} -maxdepth 1 -type f -name "ParlaMint-*.xml" | xargs ${vodd}



DEV-links-summ-XX = $(addprefix DEV-links-summ-, $(PARLIAMENTS))
##!DEV-links-summ## print table with numbers of links by type for corpus root files (file fromAttribute fromElement toElement linkType #)
DEV-links-summ:
	make $(DEV-links-summ-XX) | perl -e 'my (%tab,%country);while(<>){my($$n,$$c,$$t)=/^(\d+)\t([^\t]*)\t(.*)/; next unless $$c; $$country{$$c}=1;$$tab{$$t}//={};$$tab{$$t}->{$$c}=$$n;};print "file\tfromAt\tfromEl\ttoEl\ttarget";foreach $$c (sort keys %country){printnum($$c)};print "\n";foreach my $$t (sort keys %tab){print "$$t";foreach $$c (sort keys %country){printnum($$tab{$$t}->{$$c}//"-")};print "\n"};sub printnum{print "\t" . shift}'
##!DEV-links-summ-XX## ...
$(DEV-links-summ-XX): DEV-links-summ-%: %
	@for root in `find -H ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX} -maxdepth 1 -type f -name "ParlaMint-*.xml" | grep -P "ParlaMint-$<${CORPUSDIR_SUFFIX}(|\.ana).xml"`;	do \
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
	@find -H ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX} -maxdepth 1 -type f -name "ParlaMint-$<.xml" | \
	  xargs -I {} ${s} ${listrole} {} 2>&1 |sort|uniq -c|sed "s/^ *//"|tr -s " "| tr " " "\t"

DEV-attributes-summ-XX = $(addprefix DEV-attributes-summ-, $(PARLIAMENTS))
##!DEV-attributes-summ## print table with numbers of element-attributes pairs (element attribute #)
DEV-attributes-summ:
	make $(DEV-attributes-summ-XX) | perl -e 'my (%tab,%country);while(<>){my($$n,$$c,$$t)=/^(\d+)\t([^\t]*)\t(.*)/; next unless $$c; $$country{$$c}=1;$$tab{$$t}//={};$$tab{$$t}->{$$c}=$$n;};print "element\tattribute";foreach $$c (sort keys %country){printnum($$c)};print "\n";foreach my $$t (sort keys %tab){print "$$t";foreach $$c (sort keys %country){printnum($$tab{$$t}->{$$c}//"-")};print "\n"};sub printnum{print "\t" . shift}'
##!DEV-attributes-summ-XX## ...
$(DEV-attributes-summ-XX): DEV-attributes-summ-%: %
	@for root in `find -H ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX} -maxdepth 1 -type f -name "ParlaMint-*.xml" | grep -P "ParlaMint-$<${CORPUSDIR_SUFFIX}(|\.ana).xml"`;	do \
	  ${s} ${listattr} $${root} 2>&1; \
	  for component in `echo $${root}| xargs ${getincludes}`; do \
	    ${s} ${listattr} ${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/$${component} 2>&1; \
	  done \
	done | sort|uniq -c|sed "s/^ *//"|tr -s " "| tr " " "\t"

##!DEV-speaker_types-in-taxonomy## print speaker types: id english_term ParlaMint-XX local_term
DEV-speaker_types-in-taxonomy:
	@echo -n "category_id\tterm_en\tcode\tterm_local\n"
	@for root in `find -H ${DATADIR} -type f -path "${DATADIR}/ParlaMint-*${CORPUSDIR_SUFFIX}/ParlaMint-*.xml" | grep -v '_'| grep -v '.ana.xml'`; do \
	  java -cp ./Scripts/bin/saxon.jar net.sf.saxon.Query -xi:off \!method=adaptive \
	      -qs:'//*:taxonomy[@xml:id="speaker_types"]//*:category/concat(@xml:id,"|"  ,.//*:term[ancestor-or-self::*[@xml:lang][1]/@xml:lang="en"],"|"   ,/*:teiCorpus/@xml:id,"|"   ,.//*:term[not(ancestor-or-self::*[@xml:lang][1]/@xml:lang="en") ])' \
	      -s:$${root} ; \
	  echo;\
	done | sed 's/^"//;s/"$$//;s/ParlaMint-//;s/|/\t/g'|sort|uniq


DEV-parlamint2release-XX = $(addprefix DEV-parlamint2release-, $(PARLIAMENTS))
##!DEV-parlamint2release## run parlamint2release script on folder and the result put to ....../ParlaMint-XX.parlamint2release
DEV-parlamint2release: $(DEV-parlamint2release-XX)
##!DEV-parlamint2release-XX## ...
$(DEV-parlamint2release-XX): DEV-parlamint2release-%: %
	for root in `find -H ${DATADIR} -type f -path "${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-$<.*xml" `;	do \
	  echo "INFO: processing $${root}" ;\
	  ${s} outDir=${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}.parlamint2release -xsl:Scripts/parlamint2release.xsl $${root} || echo "FATAL ERROR $${root}" ;\
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
	find -H ${DATADIR} -type f -path "${DATADIR}/ParlaMint-$<${CORPUSDIR_SUFFIX}/ParlaMint-$<*.xml" -printf '%f\n' | grep -v '_' \
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
	Scripts/create-taxonomy-UD-SYN.pl --in Scripts/UD-docs --out Build/Taxonomies/ParlaMint-taxonomy-UD-SYN.ana.xml --commit $(shell git -C Scripts/UD-docs rev-parse HEAD)

######################VARIABLES
s = java $(JM) -jar ./Scripts/bin/saxon.jar
P = parallel --gnu --halt 2
j = java $(JM) -jar ./Scripts/bin/jing.jar
copy = -I % $s -xi:on -xsl:Scripts/copy.xsl -s:% -o:%.all-in-one.xml
vlink = -xsl:Scripts/check-links.xsl
listlink = -xsl:Scripts/list-links.xsl
listrole = -xsl:Scripts/list-affiliation-org-role-pairs.xsl
listattr = -xsl:Scripts/list-element-attribute.xsl
faff = -xsl:Scripts/fixings/fix-overlapping-affiliations.xsl
vcontent = -xsl:Scripts/validate-parlamint.xsl
getincludes = -I % java -cp ./Scripts/bin/saxon.jar net.sf.saxon.Query -xi:off \!method=adaptive -qs:'//*[local-name()="include"]/@href' -s:% |sed 's/^ *href="//;s/"//'
getheaderincludes = -I % java -cp ./Scripts/bin//saxon.jar net.sf.saxon.Query -xi:off \!method=adaptive -qs:'//*[local-name()="teiHeader"]//*[local-name()="include"]/@href' -s:% |sed 's/^ *href="//;s/"//'
getcomponentincludes = -I % java -cp ./Scripts/bin/saxon.jar net.sf.saxon.Query -xi:off \!method=adaptive -qs:'/*/*[local-name()="include"]/@href' -s:% |sed 's/^ *href="//;s/"//'
pc =  $j Schema/parla-clarin.rng                # Validate with Parla-CLARIN schema
vrt = $j Schema/ParlaMint-teiCorpus.rng 	# Corpus root / text
vct = $j Schema/ParlaMint-TEI.rng		# Corpus component / text
vra = $j Schema/ParlaMint-teiCorpus.ana.rng	# Corpus root / analysed
vca = $j Schema/ParlaMint-TEI.ana.rng		# Corpus component / analysed
vodd = $j TEI/ParlaMint.odd.rng		# validate with rng derived from odd
vch_taxonomy = $j Schema/ParlaMint-taxonomy.rng # factorized taxonomy
vch_pers = $j Schema/ParlaMint-listPerson.rng # factorized listPerson
vch_orgs = $j Schema/ParlaMint-listOrg.rng # factorized listOrg
