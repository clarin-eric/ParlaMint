usas-test:
	${vca} ../Corpora/Master/ParlaMint-LV-en.TEI.ana/*/ParlaMint-LV-en_*.ana.xml

## We use this Makefile also for testing scripts:
list:
	grep '<element name=' ParlaMint-*.rng | perl -pe 's|.+="||; s|">||' | sort | uniq

nohup:
	nohup time make all > compile.log &
all:	relax
xall:	val rnc

val:
	../Samples/ParlaMint-*/ParlaMint-*.xml

#Authored, strangely enough, in .rng!

#Convert to RelaxNG compact syntax
relax:
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

#Useful XML validations
pc = -I % $s -xi -xsl:../Scripts/copy.xsl % | $j parla-clarin.rng

vrt = $j ParlaMint-teiCorpus.rng 	# Corpus TEI root (text)
vct = $j ParlaMint-TEI.rng		# Corpus TEI component (text)
vra = $j ParlaMint-teiCorpus.ana.rng	# Corpus TEI.ana root (ling. analysed)
vca = $j ParlaMint-TEI.ana.rng		# Corpus TEI component (analysed)
vlo = $j ParlaMint-listOrg.rng		# Corpus TEI organisation list
vlp = $j ParlaMint-listPerson.rng	# Corpus TEI person list
vta = $j ParlaMint-taxonomy.rng		# Corpus TEI taxonomy

#Prerequisites, change as needed
s = java -jar /usr/share/java/saxon.jar
j = java -jar /usr/share/java/jing.jar
t = java -jar /usr/share/java/trang.jar
P = parallel --citation --gnu --halt 2
