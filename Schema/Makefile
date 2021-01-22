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
	ls ../ParlaMint-*/ParlaMint-*.xml | grep -v '.ana.' | grep -v '_' | xargs ${vrt}
	ls ../ParlaMint-*/ParlaMint-*.xml | grep -v '.ana.' | grep    '_' | xargs ${vct}
	ls ../ParlaMint-*/ParlaMint-*.xml | grep    '.ana.' | grep -v '_' | xargs ${vra}
	ls ../ParlaMint-*/ParlaMint-*.xml | grep    '.ana.' | grep    '_' | xargs ${vca}

s = java -jar /usr/share/java/saxon.jar
t = java -jar /usr/share/java/trang.jar
j = java -jar /usr/share/java/jing.jar 
vrt = $j ParlaMint-teiCorpus.rng 	# Corpus root / text
vct = $j ParlaMint-TEI.rng		# Corpus component / text
vra = $j ParlaMint-teiCorpus.ana.rng	# Corpus root / analysed
vca = $j ParlaMint-TEI.ana.rng		# Corpus component / analysed
P = parallel --citation --gnu --halt 2

#Count things like org/@role
what-root = grep '<org ' | perl -pe 's/.+role="//; s/".+//' | sort |  uniq -c
what-root:
	cat ../ParlaMint-BG/ParlaMint-BG/ParlaMint-bg.xml | ${what-root}
	cat ../ParlaMint-HR/ParlaMint-HR/ParlaMint-hr.xml | ${what-root}
	cat ../ParlaMint-PL/ParlaMint-PL/ParlaMint-pl.xml | ${what-root}
	cat ../ParlaMint-SI/ParlaMint-SI/ParlaMint-SI.xml | ${what-root}
what = grep '<org ' | perl -pe 's/.+role="//; s/".+//' | sort |  uniq -c
what:
	cat ../ParlaMint-BG/ParlaMint-bg.ana/ParlaMint-BG_*ana.xml | ${what}
	cat ../ParlaMint-HR/ParlaMint-hr.ana/ParlaMint-HR_*ana.xml | ${what}
	cat ../ParlaMint-PL/ParlaMint-pl.ana/ParlaMint-PL_*ana.xml | ${what}
	cat ../ParlaMint-SI/ParlaMint-SI.ana/ParlaMint-SI_*ana.xml | ${what}
