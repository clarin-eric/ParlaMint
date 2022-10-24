## We use this Makefile also for testing scripts:
META = $F/DataXI/ParlaMint-CZ/ParlaMint-CZ.xml
cl-test:
	#$s -xsl:../Scripts/check-links.xsl ${META}
	$s meta=${META} -xsl:../Scripts/check-links.xsl \
	$F/DataXI/ParlaMint-CZ/ParlaMint-CZ_2016-04-13-ps2013-044-02-013-114.xml

F = ../../Factorized
f-test:	f-test-root f-test-anaroot f-test-component f-test-anacomponent f-test-splits f-test-odd

f-test-root:
	$j ParlaMint-teiCorpus.rng $F/Data/ParlaMint-CZ/ParlaMint-CZ.xml
	$j ParlaMint-teiCorpus.rng $F/DataXI/ParlaMint-CZ/ParlaMint-CZ.xml
	$j ParlaMint-teiCorpus.rng $F/Data/ParlaMint-BE/ParlaMint-BE.xml
	$j ParlaMint-teiCorpus.rng $F/DataXI/ParlaMint-BE/ParlaMint-BE.xml
f-test-anaroot:
	$j ParlaMint-teiCorpus.ana.rng $F/Data/ParlaMint-CZ/ParlaMint-CZ.ana.xml
	$j ParlaMint-teiCorpus.ana.rng $F/DataXI/ParlaMint-CZ/ParlaMint-CZ.ana.xml
	$j ParlaMint-teiCorpus.ana.rng $F/Data/ParlaMint-BE/ParlaMint-BE.ana.xml
	$j ParlaMint-teiCorpus.ana.rng $F/DataXI/ParlaMint-BE/ParlaMint-BE.ana.xml
f-test-component:
	$j ParlaMint-TEI.rng $F/Data/ParlaMint-CZ/ParlaMint-CZ_2016-04-13-ps2013-044-02-013-114.xml
	$j ParlaMint-TEI.rng $F/Data/ParlaMint-BE/ParlaMint-BE_2014-06-30-54-plenair-ip002x.xml
f-test-anacomponent:
	$j ParlaMint-TEI.ana.rng   $F/Data/ParlaMint-CZ/ParlaMint-CZ_2016-04-13-ps2013-044-02-013-114.ana.xml
	$j ParlaMint-TEI.ana.rng   $F/Data/ParlaMint-BE/ParlaMint-BE_2014-06-30-54-plenair-ip002x.ana.xml
f-test-splits:
	$j ParlaMint-taxonomy.rng  $F/DataXI/ParlaMint-CZ/ParlaMint-CZ-taxonomy-*.xml
	$j ParlaMint-taxonomy.rng  $F/DataXI/ParlaMint-BE/ParlaMint-BE-taxonomy-*.xml
	$j ParlaMint-listOrg.rng   $F/DataXI/ParlaMint-CZ/ParlaMint-CZ-listOrg.xml
	$j ParlaMint-listOrg.rng   $F/DataXI/ParlaMint-BE/ParlaMint-BE-listOrg.xml
	$j ParlaMint-listPerson.rng   $F/DataXI/ParlaMint-CZ/ParlaMint-CZ-listPerson.xml
	$j ParlaMint-listPerson.rng   $F/DataXI/ParlaMint-BE/ParlaMint-BE-listPerson.xml
f-test-odd:
	$j ../TEI/ParlaMint.odd.rng $F/Data/ParlaMint-CZ/ParlaMint-CZ.xml
	$j ../TEI/ParlaMint.odd.rng $F/DataXI/ParlaMint-CZ/ParlaMint-CZ.xml
	$j ../TEI/ParlaMint.odd.rng $F/Data/ParlaMint-BE/ParlaMint-BE.xml
	$j ../TEI/ParlaMint.odd.rng $F/DataXI/ParlaMint-BE/ParlaMint-BE.xml
	$j ../TEI/ParlaMint.odd.rng $F/Data/ParlaMint-CZ/ParlaMint-CZ.ana.xml
	$j ../TEI/ParlaMint.odd.rng $F/DataXI/ParlaMint-CZ/ParlaMint-CZ.ana.xml
	$j ../TEI/ParlaMint.odd.rng $F/Data/ParlaMint-BE/ParlaMint-BE.ana.xml
	$j ../TEI/ParlaMint.odd.rng $F/DataXI/ParlaMint-BE/ParlaMint-BE.ana.xml
	$j ../TEI/ParlaMint.odd.rng $F/Data/ParlaMint-CZ/ParlaMint-CZ_2016-04-13-ps2013-044-02-013-114.xml
	$j ../TEI/ParlaMint.odd.rng $F/Data/ParlaMint-BE/ParlaMint-BE_2014-06-30-54-plenair-ip002x.xml
	$j ../TEI/ParlaMint.odd.rng   $F/Data/ParlaMint-CZ/ParlaMint-CZ_2016-04-13-ps2013-044-02-013-114.ana.xml
	$j ../TEI/ParlaMint.odd.rng   $F/Data/ParlaMint-BE/ParlaMint-BE_2014-06-30-54-plenair-ip002x.ana.xml


list:
	grep '<element name=' ParlaMint-*.rng | perl -pe 's|.+="||; s|">||' | sort | uniq
nohup:
	nohup time make all > compile.log &
all:	trang
xall:	val trang

#Authored, strangely enough, in .rng!
t = java -jar /usr/share/java/trang.jar
trang:	rnc
rnc:
	$t ParlaMint-TEI.rng ParlaMint-TEI.rnc
	$t ParlaMint-TEI.ana.rng ParlaMint-TEI.ana.rnc
	$t ParlaMint-teiCorpus.rng ParlaMint-teiCorpus.rnc
	$t ParlaMint-teiCorpus.ana.rng ParlaMint-teiCorpus.ana.rnc
	$t ParlaMint-listOrg.rng ParlaMint-listOrg.rnc
	$t ParlaMint-listPerson.rng ParlaMint-listPerson.rnc
	$t ParlaMint-taxonomy.rng ParlaMint-taxonomy.rnc

#Doesn't work, cf. https://github.com/clarin-eric/ParlaMint/issues/74
xsd:
	$t ParlaMint-TEI.rng ParlaMint-TEI.xsd
	$t ParlaMint-TEI.ana.rng ParlaMint-TEI.ana.xsd
	$t ParlaMint-teiCorpus.rng ParlaMint-teiCorpus.xsd
	$t ParlaMint-teiCorpus.ana.rng ParlaMint-teiCorpus.ana.xsd
	$t ParlaMint-listOrg.rng ParlaMint-listOrg.xsd
	$t ParlaMint-listPerson.rng ParlaMint-listPerson.xsd
	$t ParlaMint-taxonomy.rng ParlaMint-taxonomy.xsd

#DATADIR = ../Data
# For testing v3 corpora
DATADIR = ../../ParlaMint-data/Data
#DATADIR = ../../ParlaMint-v2tov3/Data
val:
	-ls ${DATADIR}/ParlaMint-*/ParlaMint-*.xml | grep -v '.ana.' | grep -v '_' | xargs ${pc}
	-ls ${DATADIR}/ParlaMint-*/ParlaMint-*.xml | grep -v '.ana.' | grep -v '_' | xargs ${vrt}
	-ls ${DATADIR}/ParlaMint-*/ParlaMint-*.xml | grep -v '.ana.' | grep    '_' | xargs ${vct}
	-ls ${DATADIR}/ParlaMint-*/ParlaMint-*.xml | grep    '.ana.' | grep -v '_' | xargs ${pc}
	-ls ${DATADIR}/ParlaMint-*/ParlaMint-*.xml | grep    '.ana.' | grep -v '_' | xargs ${vra}
	-ls ${DATADIR}/ParlaMint-*/ParlaMint-*.xml | grep    '.ana.' | grep    '_' | xargs ${vca}

s = java -jar /usr/share/java/saxon.jar
j = java -jar /usr/share/java/jing.jar
pc = -I % $s -xi -xsl:../Scripts/copy.xsl % | $j parla-clarin.rng
vrt = $j ParlaMint-teiCorpus.rng 	# Corpus root / text
vct = $j ParlaMint-TEI.rng		# Corpus component / text
vra = $j ParlaMint-teiCorpus.ana.rng	# Corpus root / analysed
vca = $j ParlaMint-TEI.ana.rng		# Corpus component / analysed
vlo = $j ParlaMint-listOrg.rng		# Corpus organisation list
vlp = $j ParlaMint-listPerson.rng	# Corpus person list
vta = $j ParlaMint-taxonomy.rng		# Corpus taxonomy
P = parallel --citation --gnu --halt 2

#Count things like org/@role
what = grep ' corresp=' | grep corresp
what:
	cat ${DATADIR}/ParlaMint-*/ParlaMint-*.xml | ${what}
