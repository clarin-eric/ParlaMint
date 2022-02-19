# Validate 
all:	prepare val-schema xml-schemas val-samples html mount

# ParlaMint TEI documentation and schema, as expanded by prepare target
ODD = tmp/ParlaMint.xml

# The infamous TEI P5 subset from the Guidelines, either local or from the Web
SUBSET = --localsource=p5subset.xml
#SUBSET = --localsource=https://tei-c.org/release/xml/tei/odd/p5subset.xml

# Location and directory name of the profile for conversion to HTML
PROFILE = --profiledir=$(shell pwd) --profile=profile

# Put the docs directory somewhere where the HTML can be viewed
# This is a local thing!
mount:
	rsync -a ../docs/ tomaz@nl.ijs.si:/home/tomaz/www/tmp/ParlaMint/Pages

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

val:	val-schema val-samples
val-schema:
	$j tei_odds.rng tmp/ParlaMint.xml

# Validate samples
val-samples:
	validate.pl samples ../Data

# Validate all the full set of components
val-master:
	validate.pl master ../../V2/MasterV2.1

# Make one file from the ODD
prepare:
	rm -f tmp/*
	$s -xi -xsl:copy-odd.xsl ParlaMint.odd.xml > tmp/ParlaMint.xml

# Initialise
setup:
	mkdir tmp
	git clone git@github.com:TEIC/Stylesheets.git

### Location of Jing (for RelaxNG validation) and Saxon (for XSLT stylesheets)
j = java -jar /usr/share/java/jing.jar
s = java -jar /usr/share/java/saxon.jar
