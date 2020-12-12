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
xmllint:
	xmllint --noout --relaxng ParlaMint-teiCorpus.ana.rng --noout \
	../ParlaMint-XX/ParlaMint-XX.ana/ParlaMint-BG.ana.xml
test-xmllint:
	-xmllint --noout --relaxng  ParlaMint-TEI.rng           ../ParlaMint-SI/ParlaMint-SI/ParlaMint-SI_*.xml
	-xmllint --noout --relaxng  ParlaMint-teiCorpus.rng     ../ParlaMint-SI/ParlaMint-SI/ParlaMint-SI.xml
	-xmllint --noout --relaxng  ParlaMint-TEI.ana.rng       ../ParlaMint-SI/ParlaMint-SI.ana/ParlaMint-SI_*ana.xml
	-xmllint --noout --relaxng  ParlaMint-teiCorpus.ana.rng ../ParlaMint-SI/ParlaMint-SI.ana/ParlaMint-SI.ana.xml


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

test-root.ana:
	-$j ParlaMint-teiCorpus.ana.rng ../ParlaMint-XX/ParlaMint-XX.ana/ParlaMint-BG.ana.xml
	-$j ParlaMint-teiCorpus.ana.rng ../ParlaMint-XX/ParlaMint-XX.ana/ParlaMint-HR.ana.xml
	-$j ParlaMint-teiCorpus.ana.rng ../ParlaMint-XX/ParlaMint-XX.ana/ParlaMint-PL.ana.xml
	-$j ParlaMint-teiCorpus.ana.rng ../ParlaMint-XX/ParlaMint-XX.ana/ParlaMint-SI.ana.xml
test-root:
	-$j ParlaMint-teiCorpus.rng ../ParlaMint-XX/ParlaMint-XX/ParlaMint-BG.xml
	-$j ParlaMint-teiCorpus.rng ../ParlaMint-XX/ParlaMint-XX/ParlaMint-HR.xml
	-$j ParlaMint-teiCorpus.rng ../ParlaMint-XX/ParlaMint-XX/ParlaMint-PL.xml
	-$j ParlaMint-teiCorpus.rng ../ParlaMint-XX/ParlaMint-XX/ParlaMint-SI.xml
test-ana:
	-$j ParlaMint-TEI.ana.rng ../ParlaMint-XX/ParlaMint-XX.ana/ParlaMint-BG_*.xml
	-$j ParlaMint-TEI.ana.rng ../ParlaMint-XX/ParlaMint-XX.ana/ParlaMint-HR_*.xml
	-$j ParlaMint-TEI.ana.rng ../ParlaMint-XX/ParlaMint-XX.ana/ParlaMint-PL_*.xml
	-$j ParlaMint-TEI.ana.rng ../ParlaMint-XX/ParlaMint-XX.ana/ParlaMint-SI_*.xml
test:
	-$j ParlaMint-TEI.rng ../ParlaMint-XX/ParlaMint-XX/ParlaMint-BG_*.xml
	# -$j ParlaMint-TEI.rng ../ParlaMint-XX/ParlaMint-XX/ParlaMint-HR_*.xml
	# -$j ParlaMint-TEI.rng ../ParlaMint-XX/ParlaMint-XX/ParlaMint-PL_*.xml
	# -$j ParlaMint-TEI.rng ../ParlaMint-XX/ParlaMint-XX/ParlaMint-SI_*.xml

val-XX:	val-BG val-HR val-PL val-SI
val-BG:
	-$j ParlaMint-teiCorpus.rng     ../ParlaMint-BG/ParlaMint-BG/ParlaMint-BG.xml
	-$j ParlaMint-TEI.rng           ../ParlaMint-BG/ParlaMint-BG/ParlaMint-BG_*.xml
	-$j ParlaMint-teiCorpus.ana.rng ../ParlaMint-BG/ParlaMint-BG.ana/ParlaMint-BG.ana.xml
	-$j ParlaMint-TEI.ana.rng       ../ParlaMint-BG/ParlaMint-BG.ana/ParlaMint-BG_*ana.xml
val-HR:
	-$j ParlaMint-teiCorpus.rng     ../ParlaMint-HR/ParlaMint-HR/ParlaMint-HR.xml
	-$j ParlaMint-TEI.rng           ../ParlaMint-HR/ParlaMint-HR/ParlaMint-HR_*.xml
	-$j ParlaMint-teiCorpus.ana.rng ../ParlaMint-HR/ParlaMint-HR.ana/ParlaMint-HR.ana.xml
	-$j ParlaMint-TEI.ana.rng       ../ParlaMint-HR/ParlaMint-HR.ana/ParlaMint-HR_*ana.xml
val-PL:
	-$j ParlaMint-teiCorpus.rng     ../ParlaMint-PL/ParlaMint-PL/ParlaMint-PL.xml
	-$j ParlaMint-TEI.rng           ../ParlaMint-PL/ParlaMint-PL/ParlaMint-PL_*.xml
	-$j ParlaMint-teiCorpus.ana.rng ../ParlaMint-PL/ParlaMint-PL.ana/ParlaMint-PL.ana.xml
	-$j ParlaMint-TEI.ana.rng       ../ParlaMint-PL/ParlaMint-PL.ana/ParlaMint-PL_*ana.xml
val-SI:
	-$j ParlaMint-teiCorpus.rng     ../ParlaMint-SI/ParlaMint-SI/ParlaMint-SI.xml
	-$j ParlaMint-TEI.rng           ../ParlaMint-SI/ParlaMint-SI/ParlaMint-SI_*.xml
	-$j ParlaMint-teiCorpus.ana.rng ../ParlaMint-SI/ParlaMint-SI.ana/ParlaMint-SI.ana.xml
	-$j ParlaMint-TEI.ana.rng       ../ParlaMint-SI/ParlaMint-SI.ana/ParlaMint-SI_*ana.xml

nohup:
	nohup time make all > nohup.all &
all:	val val.ana val-root val-root.ana
val-root.ana:
	-$j ParlaMint-teiCorpus.ana.rng ../ParlaMint-BG/ParlaMint-BG.ana/ParlaMint-BG.ana.xml
	-$j ParlaMint-teiCorpus.ana.rng ../ParlaMint-HR/ParlaMint-HR.ana/ParlaMint-HR.ana.xml
	-$j ParlaMint-teiCorpus.ana.rng ../ParlaMint-PL/ParlaMint-PL.ana/ParlaMint-PL.ana.xml
	-$j ParlaMint-teiCorpus.ana.rng ../ParlaMint-SI/ParlaMint-SI.ana/ParlaMint-SI.ana.xml
val-root:
	-$j ParlaMint-teiCorpus.rng ../ParlaMint-BG/ParlaMint-BG/ParlaMint-BG.xml
	-$j ParlaMint-teiCorpus.rng ../ParlaMint-HR/ParlaMint-HR/ParlaMint-HR.xml
	-$j ParlaMint-teiCorpus.rng ../ParlaMint-PL/ParlaMint-PL/ParlaMint-PL.xml
	-$j ParlaMint-teiCorpus.rng ../ParlaMint-SI/ParlaMint-SI/ParlaMint-SI.xml
val.ana:
	-$j ParlaMint-TEI.ana.rng ../ParlaMint-BG/ParlaMint-BG.ana/ParlaMint-BG_*ana.xml
	-$j ParlaMint-TEI.ana.rng ../ParlaMint-HR/ParlaMint-HR.ana/ParlaMint-HR_*ana.xml
	-$j ParlaMint-TEI.ana.rng ../ParlaMint-PL/ParlaMint-PL.ana/ParlaMint-PL_*ana.xml
	-$j ParlaMint-TEI.ana.rng ../ParlaMint-SI/ParlaMint-SI.ana/ParlaMint-SI_*ana.xml
val:
	-$j ParlaMint-TEI.rng ../ParlaMint-BG/ParlaMint-BG/ParlaMint-BG_*.xml
	-$j ParlaMint-TEI.rng ../ParlaMint-HR/ParlaMint-HR/ParlaMint-HR_*.xml
	-$j ParlaMint-TEI.rng ../ParlaMint-PL/ParlaMint-PL/ParlaMint-PL_*.xml
	-$j ParlaMint-TEI.rng ../ParlaMint-SI/ParlaMint-SI/ParlaMint-SI_*.xml

#s = java -jar /usr/local/bin/saxon9he.jar
s = java -jar /usr/share/java/saxon.jar
t = java -jar /usr/share/java/trang.jar
j = java -jar /usr/share/java/jing.jar
P = parallel --citation --gnu --halt 2
