### Makefile for testing samples against Parla-CLARIN, ParlaMint ODD and ParlaMint RelaxNG schemas
### and converting RelaxNG .rng to .rnc
nohup:
	nohup time make all > compile.log &
all:	val rnc
xall:	val rnc

ALL = ../Samples/ParlaMint-*
ANA = '.ana'
TAX = 'taxonomy'
LST = 'list'
val:
	-ls ${ALL}/ParlaMint-*.xml   | grep -v ${ANA} | grep -v ${TAX} | grep -v ${LST} | xargs ${pc}
	-ls ${ALL}/ParlaMint-*.xml   | grep -v ${ANA} | grep -v ${TAX} | grep -v ${LST} | xargs ${pp}
	-ls ${ALL}/ParlaMint-*.xml   | grep -v ${ANA} | grep -v ${TAX} | grep -v ${LST} | xargs ${vrt}
	-ls ${ALL}/*/ParlaMint-*.xml | grep -v ${ANA} | grep -v ${TAX} | grep -v ${LST} | xargs ${vct}

	-ls ${ALL}/ParlaMint-*.xml   | grep    ${ANA} | grep -v ${TAX} | grep -v ${LST} | xargs ${pc}
	-ls ${ALL}/ParlaMint-*.xml   | grep    ${ANA} | grep -v ${TAX} | grep -v ${LST} | xargs ${pp}
	-ls ${ALL}/ParlaMint-*.xml   | grep    ${ANA} | grep -v ${TAX} | grep -v ${LST} | xargs ${vra}
	-ls ${ALL}/*/ParlaMint-*.xml | grep    ${ANA} | grep -v ${TAX} | grep -v ${LST} | xargs ${vca}

	-ls ${ALL}/ParlaMint-*listOrg.xml    | xargs ${vlo}
	-ls ${ALL}/ParlaMint-*listPerson.xml | xargs ${vlp}
	-ls ${ALL}/ParlaMint-*taxonomy*.xml  | xargs ${vta}

#Convert to RelaxNG compact syntax
rnc:
	$t ParlaMint-TEI.rng ParlaMint-TEI.rnc
	$t ParlaMint-TEI.ana.rng ParlaMint-TEI.ana.rnc
	$t ParlaMint-teiCorpus.rng ParlaMint-teiCorpus.rnc
	$t ParlaMint-teiCorpus.ana.rng ParlaMint-teiCorpus.ana.rnc
	$t ParlaMint-listOrg.rng ParlaMint-listOrg.rnc
	$t ParlaMint-listPerson.rng ParlaMint-listPerson.rnc
	$t ParlaMint-taxonomy.rng ParlaMint-taxonomy.rnc

#Doesn't work, cf. https://github.com/clarin-eric/ParlaMint/issues/74
xxx-xsd:
	$t ParlaMint-TEI.rng ParlaMint-TEI.xsd
	$t ParlaMint-TEI.ana.rng ParlaMint-TEI.ana.xsd
	$t ParlaMint-teiCorpus.rng ParlaMint-teiCorpus.xsd
	$t ParlaMint-teiCorpus.ana.rng ParlaMint-teiCorpus.ana.xsd
	$t ParlaMint-listOrg.rng ParlaMint-listOrg.xsd
	$t ParlaMint-listPerson.rng ParlaMint-listPerson.xsd
	$t ParlaMint-taxonomy.rng ParlaMint-taxonomy.xsd

## Count definitions
list:
	grep '<element name=' ParlaMint-*.rng | perl -pe 's|.+="||; s|">||' | sort | uniq

### Validations scenarios as variables
# Parla-CLARIN schema from https://github.com/clarin-eric/parla-clarin/tree/master/Schema
pc = -I % $s -xi -xsl:../Scripts/copy.xsl % | $j parla-clarin.rng
# ParlaMint ODD schema from ../TEI/
pp = -I % $s -xi -xsl:../Scripts/copy.xsl % | $j ParlaMint.odd.rng

vrt = $j ParlaMint-teiCorpus.rng 	# Corpus TEI root (text)
vct = $j ParlaMint-TEI.rng		# Corpus TEI component (text)
vra = $j ParlaMint-teiCorpus.ana.rng	# Corpus TEI.ana root (ling. analysed)
vca = $j ParlaMint-TEI.ana.rng		# Corpus TEI component (analysed)
vlo = $j ParlaMint-listOrg.rng		# Corpus TEI organisation list
vlp = $j ParlaMint-listPerson.rng	# Corpus TEI person list
vta = $j ParlaMint-taxonomy.rng		# Corpus TEI taxonomy

#Prerequisites
P = parallel --citation --gnu --halt 2
s = java -jar ../Scripts/bin/saxon.jar
j = java -jar ../Scripts/bin/jing.jar
t = java -jar ../Scripts/bin/trang.jar
