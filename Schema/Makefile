test:
	$s -xi -xsl:../Scripts/copy.xsl ParlaMint-XX.xml | $j parla-clarin.rng
	${vrt} ParlaMint-XX.xml
	${vct} ParlaMint-XX_1.xml
nohup:
	nohup time make all > nohup.all &
all:	val trang
trang:
	$t ParlaMint-TEI.rng ParlaMint-TEI.rnc
	$t ParlaMint-TEI.rng ParlaMint-TEI.xsd
	$t ParlaMint-TEI.ana.rng ParlaMint-TEI.ana.rnc
	$t ParlaMint-TEI.ana.rng ParlaMint-TEI.ana.xsd
	$t ParlaMint-teiCorpus.rng ParlaMint-teiCorpus.rnc
	$t ParlaMint-teiCorpus.rng ParlaMint-teiCorpus.xsd
	$t ParlaMint-teiCorpus.ana.rng ParlaMint-teiCorpus.ana.rnc
	$t ParlaMint-teiCorpus.ana.rng ParlaMint-teiCorpus.ana.xsd
	cd ..; make val
val:
	ls ../ParlaMint-*/ParlaMint-*.xml | grep -v '.ana.' | grep -v '_' | xargs ${pc}
	ls ../ParlaMint-*/ParlaMint-*.xml | grep -v '.ana.' | grep -v '_' | xargs ${vrt}
	ls ../ParlaMint-*/ParlaMint-*.xml | grep -v '.ana.' | grep    '_' | xargs ${vct}
	ls ../ParlaMint-*/ParlaMint-*.xml | grep    '.ana.' | grep -v '_' | xargs ${pc}
	ls ../ParlaMint-*/ParlaMint-*.xml | grep    '.ana.' | grep -v '_' | xargs ${vra}
	ls ../ParlaMint-*/ParlaMint-*.xml | grep    '.ana.' | grep    '_' | xargs ${vca}

s = java -jar /usr/share/java/saxon.jar
t = java -jar /usr/share/java/trang.jar
j = java -jar /usr/share/java/jing.jar
pc = -I % $s -xi -xsl:../Scripts/copy.xsl % | $j parla-clarin.rng
vrt = $j ParlaMint-teiCorpus.rng 	# Corpus root / text
vct = $j ParlaMint-TEI.rng		# Corpus component / text
vra = $j ParlaMint-teiCorpus.ana.rng	# Corpus root / analysed
vca = $j ParlaMint-TEI.ana.rng		# Corpus component / analysed
P = parallel --citation --gnu --halt 2

#Count things like org/@role
what = grep ' corresp=' | grep corresp
what:
	cat ../ParlaMint-*/ParlaMint-*.xml | ${what}
