#Development of merging taxonomies on the legislature one
TEST = ../Data/Taxonomies/ParlaMint-taxonomy-parla.legislature.test.xml

# V3 data
CZ = ../Data/ParlaMint-CZ/ParlaMint-taxonomy-parla.legislature.xml
GR = ../Data/ParlaMint-GR/ParlaMint-GR.xml
IS = ../Data/ParlaMint-IS/ParlaMint-IS.xml

# V2 data
BE = ../../ParlaMint-v2tov3/Data/ParlaMint-BE/ParlaMint-BE.xml
BG = ../../ParlaMint-v2tov3/Data/ParlaMint-BG/ParlaMint-BG.xml
DK = ../../ParlaMint-v2tov3/Data/ParlaMint-DK/ParlaMint-DK.xml
ES = ../../ParlaMint-v2tov3/Data/ParlaMint-ES/ParlaMint-ES.xml
FR = ../../ParlaMint-v2tov3/Data/ParlaMint-FR/ParlaMint-FR.xml
GB = ../../ParlaMint-v2tov3/Data/ParlaMint-GB/ParlaMint-GB.xml
HR = ../../ParlaMint-v2tov3/Data/ParlaMint-HR/ParlaMint-HR.xml
HU = ../../ParlaMint-v2tov3/Data/ParlaMint-HU/ParlaMint-HU.xml
IS = ../../ParlaMint-v2tov3/Data/ParlaMint-IS/ParlaMint-IS.xml
IT = ../../ParlaMint-v2tov3/Data/ParlaMint-IT/ParlaMint-IT.xml
LT = ../../ParlaMint-v2tov3/Data/ParlaMint-LT/ParlaMint-LT.xml
LV = ../../ParlaMint-v2tov3/Data/ParlaMint-LV/ParlaMint-LV.xml
NL = ../../ParlaMint-v2tov3/Data/ParlaMint-NL/ParlaMint-NL.xml
PL = ../../ParlaMint-v2tov3/Data/ParlaMint-PL/ParlaMint-PL.xml
SI = ../../ParlaMint-v2tov3/Data/ParlaMint-SI/ParlaMint-SI.xml
TR = ../../ParlaMint-v2tov3/Data/ParlaMint-TR/ParlaMint-TR.xml

MRG = ../../Scripts/parlamint-merge-taxonomy.xsl
test-merge-taxo:
	$s new=${BE} -xsl:${MRG} ParlaMint-taxonomy-parla.legislature.xml \
	> ParlaMint-taxonomy-parla.legislature.tmp.xml
merge-taxos-log:
	make merge-taxos 2> ParlaMint-taxonomy-parla.legislature.log.xml
merge-taxos:
	cat ParlaMint-taxonomy-parla.legislature.xml \
	| $s new=${CZ} -xsl:${MRG} - \
	| $s new=${GR} -xsl:${MRG} - \
	| $s new=${IS} -xsl:${MRG} - \
	| $s new=${BE} -xsl:${MRG} - \
	| $s new=${BG} -xsl:${MRG} - \
	| $s new=${DK} -xsl:${MRG} - \
	| $s new=${ES} -xsl:${MRG} - \
	| $s new=${FR} -xsl:${MRG} - \
	| $s new=${GB} -xsl:${MRG} - \
	| $s new=${HR} -xsl:${MRG} - \
	| $s new=${HU} -xsl:${MRG} - \
	| $s new=${IT} -xsl:${MRG} - \
	| $s new=${LT} -xsl:${MRG} - \
	| $s new=${LV} -xsl:${MRG} - \
	| $s new=${NL} -xsl:${MRG} - \
	| $s new=${PL} -xsl:${MRG} - \
	| $s new=${TR} -xsl:${MRG} - \
	> ParlaMint-taxonomy-parla.legislature.tmp.xml
	$j ../../Schema/ParlaMint-taxonomy.rng ParlaMint-taxonomy-parla.legislature.tmp.xml

#USAS taxonomy development
fix-usas:
	$s -xsl:fix-usastaxo.xsl usas-taxonomy.orig.xml > usas-taxonomy.xml
	xmllint --noout usas-taxonomy.orig.xml

#######################################
s = java -jar /usr/share/java/saxon.jar
j = java -jar /usr/share/java/jing.jar
