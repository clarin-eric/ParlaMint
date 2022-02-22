.DEFAULT_GOAL := help
PARLIAMENTS = AT BE BG CZ DK EE ES ES-CT ES-PV FI FR GB GR HR HU IS IT LT LV NL NO PL PT RO SE SI TR
DATADIR = Data
WORKINGDIR = DataTMP

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
	ls ${DATADIR}/ParlaMint-$</ParlaMint-*.xml | grep -v '.ana.' | grep -v '_' | xargs ${vrt}
	ls ${DATADIR}/ParlaMint-$</ParlaMint-*.xml | grep -v '.ana.' | grep    '_' | xargs ${vct}

$(val-schema-ana-ParlaMint-XX): val-schema-ana-ParlaMint-%: %
	ls ${DATADIR}/ParlaMint-$</ParlaMint-*.xml | grep    '.ana.' | grep -v '_' | xargs ${vra}
	ls ${DATADIR}/ParlaMint-$</ParlaMint-*.xml | grep    '.ana.' | grep    '_' | xargs ${vca}


$(val-schema-tei-ParlaCLARIN-XX): val-schema-tei-ParlaCLARIN-%: % working-dir-%
	$s -xi:on -xsl:Scripts/copy.xsl -s:${DATADIR}/ParlaMint-$</ParlaMint-$<.xml -o:${WORKINGDIR}/ParlaMint-$</ParlaMint-$<.xml
	${pc} ${WORKINGDIR}/ParlaMint-$</ParlaMint-$<.xml


$(val-schema-ana-ParlaCLARIN-XX): val-schema-ana-ParlaCLARIN-%: % working-dir-%
	$s -xi:on -xsl:Scripts/copy.xsl -s:${DATADIR}/ParlaMint-$</ParlaMint-$<.ana.xml -o:${WORKINGDIR}/ParlaMint-$</ParlaMint-$<.ana.xml
	${pc} ${WORKINGDIR}/ParlaMint-$</ParlaMint-$<.ana.xml



###### Check links
check-links-XX = $(addprefix check-links-, $(PARLIAMENTS))
## check-links ## validate all corpora with Scripts/check-links.xsl
check-links: $(check-links-XX)
## check-links-XX ## ...
$(check-links-XX): check-links-%: %
	for root in `ls ${DATADIR}/ParlaMint-$</ParlaMint-*.xml | grep -v '_'`;	do \
	  echo "checking links in root:" $${root}; \
	  ${s} ${vlink} $${root}; \
	  for component in `echo $${root}| xargs ${getincludes}`; do \
	    echo "checking links in component:" ${DATADIR}/ParlaMint-$</$${component}; \
	    ${s} meta=$(PWD)/$${root} ${vlink} ${DATADIR}/ParlaMint-$</$${component}; \
	  done; \
	done



###### Check content
check-content-XX = $(addprefix check-content-, $(PARLIAMENTS))
## check-content ## validate all corpora with Scripts/validate-parlamint.xsl
check-content: $(check-content-XX)
## check-content-XX ## ...
$(check-content-XX): check-content-%: %
	for root in `ls ${DATADIR}/ParlaMint-$</ParlaMint-*.xml | grep -v '_'`;	do \
	  echo "checking content in root:" $${root}; \
	  ${s} ${vcontent} $${root}; \
	  for component in `echo $${root}| xargs ${getincludes}`; do \
	    echo "checking content in component:" ${DATADIR}/ParlaMint-$</$${component}; \
	    ${s} ${vcontent} ${DATADIR}/ParlaMint-$</$${component}; \
	  done; \
	done



###### Validate ParlaMint validate-parlamint.pl
validate-parlamint-XX = $(addprefix validate-parlamint-, $(PARLIAMENTS))
## validate-parlamint ## validate all corpora with Scripts/validate-parlamint.pl
validate-parlamint: $(validate-parlamint-XX)
## validate-parlamint-XX ## validate country XX (equivalent to val-lang in previous makefile)
$(validate-parlamint-XX): validate-parlamint-%: %
	Scripts/validate-parlamint.pl Schema '${DATADIR}/ParlaMint-$<'



###### Convert (and validate)


chars-XX = $(addprefix chars-, $(PARLIAMENTS))
## chars ## create character tables
chars: $(chars-XX)
## chars-XX ## ...
$(chars-XX): chars-%: %
	rm -f ${DATADIR}/ParlaMint-$</chars-files-$<.tbl
	rm -f ${DATADIR}/ParlaMint-$</*.tmp
	nice find ${DATADIR}/ParlaMint-$</ -name '*.txt' | \
	$P --jobs 20 'cut -f2 {} > {.}.tmp'
	nice find ${DATADIR}/ParlaMint-$</ -name '*.tmp' | \
	$P --jobs 20 'Scripts/chars.pl {} >> ${DATADIR}/ParlaMint-$</chars-files-$<.tbl'
	Scripts/chars-summ.pl < ${DATADIR}/ParlaMint-$</chars-files-$<.tbl \
	> ${DATADIR}/ParlaMint-$</chars-$<.tbl
	rm -f ${DATADIR}/ParlaMint-$</*.tmp


text-XX = $(addprefix text-, $(PARLIAMENTS))
## text ## create text version from tei files
text: $(text-XX)
## text-XX ## convert tei files to text
$(text-XX): text-%: %
	rm -f ${DATADIR}/ParlaMint-$</*.txt
	ls ${DATADIR}/ParlaMint-$</*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s -xsl:Scripts/parlamint-tei2text.xsl {} > ${DATADIR}/ParlaMint-$</{/.}.txt'



meta-XX = $(addprefix meta-, $(PARLIAMENTS))
## meta ## generate metadata tables from unanotated version
meta: $(meta-XX)
## meta-XX ## ...
$(meta-XX): meta-%: %
	rm -f ${DATADIR}/ParlaMint-$</*-meta.tsv
	ls ${DATADIR}/ParlaMint-$</*_*.xml | grep -v '.ana.' | $P --jobs 10 \
	'$s hdr=../${DATADIR}/ParlaMint-$</ParlaMint-$<.xml -xsl:Scripts/parlamint2meta.xsl \
	{} > ${DATADIR}/ParlaMint-$</{/.}-meta.tsv'



conllu-XX = $(addprefix conllu-, $(PARLIAMENTS))
## conllu ## create connlu format files and valide them (parlamint2conllu.pl)
conllu: $(conllu-XX)
## conllu-XX ##
$(conllu-XX): conllu-%: %
	rm -f ${DATADIR}/ParlaMint-$</*.conllu
	Scripts/parlamint2conllu.pl ${DATADIR}/ParlaMint-$< ${DATADIR}/ParlaMint-$<


vertana-XX = $(addprefix vertana-, $(PARLIAMENTS))
## vertana ## create anotated vertical file (parlamint-tei2vert.pl)
vertana: $(vertana-XX)
## vertana-XX ##
$(vertana-XX): vertana-%: %
	rm -f ${DATADIR}/ParlaMint-$</*.vert
	Scripts/parlamint-tei2vert.pl ${DATADIR}/ParlaMint-$</ParlaMint-$<.ana.xml ${DATADIR}/ParlaMint-$<



######---------------
.PHONY: $(PARLIAMENTS)
$(PARLIAMENTS):

.PHONY: help
## help ## print this help
help:
	@echo "replace XX with country code or run target without -XX to process all countries: \n\t ${PARLIAMENTS}\n "
	@grep -E '^## *[a-zA-Z_-]+.*?##.*$$|^####' $(MAKEFILE_LIST) | awk 'BEGIN {FS = " *## *"}; {printf "\033[1m%s\033[0m\033[36m%-25s\033[0m %s\n", $$4, $$2, $$3}'

######ADVANCED
####if you want tu run target on multiple targets but not all
####you can overwrite PARLIAMENTS variable
####e.g. make check-links PARLIAMENTS="GB CZ"


$(addprefix working-dir-, $(PARLIAMENTS)): working-dir-%: %
	mkdir -p ${WORKINGDIR}/ParlaMint-$<

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