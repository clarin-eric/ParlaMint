setup:
	mkdir tmp
	git clone git@github.com:TEIC/Stylesheets.git

# Validate 
all:	prepare val-schema xml-schemas val-examples html

# ParlaMint TEI documentation and schema, as expanded by prepare target
ODD = tmp/ParlaMint.xml

# The infamous TEI P5 subset from the Guidelines, either local or from the Web
SUBSET = --localsource=p5subset.xml
#SUBSET = --localsource=https://tei-c.org/release/xml/tei/odd/p5subset.xml

# Location and directory name of the profile for conversion to HTML
PROFILE = --profiledir=$(shell pwd) --profile=profile

# Convert to HTML
html:	prepare val-schema
	Stylesheets/bin/teitohtml ${PROFILE} --odd ${SUBSET} ${OUTPUT} ${ODD} ../docs/index.html

# Compile schemas to RelaxNG, DTD and XSD; best use the RelaxNG one.
xml-schemas:	val-schema
	Stylesheets/bin/teitorelaxng    ${SUBSET} ${ODD} ParlaMint.rng
	Stylesheets/bin/teitornc        ${SUBSET} ${ODD} ParlaMint.rnc
	#Stylesheets/bin/teitodtd        ${SUBSET} ${ODD} ParlaMint.dtd
	#Stylesheets/bin/teitoxsd        ${SUBSET} ${ODD} ParlaMint.xsd
	#Stylesheets/bin/teitoschematron ${SUBSET} ${ODD} ParlaMint.sch

val:	val-schema val-examples
val-schema:
	$j tei_odds.rng tmp/ParlaMint.xml

# Validate examples
val-examples:
	$s -xi -xsl:copy-odd.xsl ../Data/ParlaMint-SI/ParlaMint-SI.xml > tmp/ParlaMint-SI.xml
	$j ParlaMint.rng tmp/ParlaMint-SI.xml
	$s -xi -xsl:copy-odd.xsl ../Data/ParlaMint-SI/ParlaMint-SI.ana.xml > tmp/ParlaMint-SI.ana.xml
	$j ParlaMint.rng tmp/ParlaMint-SI.ana.xml

# Make one file from the ODD
prepare:
	rm -f tmp/*
	$s -xi -xsl:copy-odd.xsl ParlaMint.odd.xml > tmp/ParlaMint.xml

### Location of Jing (for RelaxNG validation) and Saxon (for XSLT stylesheets)
j = java -jar /usr/share/java/jing.jar
s = java -jar /usr/share/java/saxon.jar
