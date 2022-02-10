test:	xml-schemas
	$j ../Schema/parla-clarin.rng Test/Comp.xml
	$j ParlaMint.rng Test/Comp.xml

# Validate 
all:	val-schema xml-schemas val-examples html

# ParlaMint TEI documentation and schema
SCHEMA = ParlaMint.odd.xml

# The infamous TEI P5 subset from the Guidelines
#SUBSET = --localsource=p5subset.xml
SUBSET = --localsource=https://tei-c.org/release/xml/tei/odd/p5subset.xml

# Location and directory name of the profile for conversion to HTML
PROFILE = --profiledir=/project/corpora/Parla/ParlaMint/ParlaMint/TEI --profile=profile

# Convert to HTML
html:	val-schema
	Stylesheets/bin/teitohtml ${PROFILE} --odd ${SUBSET} ${OUTPUT} ${SCHEMA} ../docs/index.html

# Compile schemas to RelaxNG, DTD and XSD; best use the RelaxNG one.
xml-schemas:	val-schema
	Stylesheets/bin/teitorelaxng    ${SUBSET} ${SCHEMA} ParlaMint.rng
	Stylesheets/bin/teitornc        ${SUBSET} ${SCHEMA} ParlaMint.rnc
	#Stylesheets/bin/teitodtd        ${SUBSET} ${SCHEMA} ParlaMint.dtd
	#Stylesheets/bin/teitoxsd        ${SUBSET} ${SCHEMA} ParlaMint.xsd
	#Stylesheets/bin/teitoschematron ${SUBSET} ${SCHEMA} ParlaMint.sch

val:	val-schema val-examples
val-schema:
	$j tei_odds.rng ParlaMint.odd.xml

# Validate examples
val-examples:
	$j ../Schema/parla-clarin.rng ../ParlaMint-SI/ParlaMint-SI_2014-08-25-SDZ7-Izredna-01.xml
	$j ParlaMint.rng ../ParlaMint-SI/ParlaMint-SI_2014-08-25-SDZ7-Izredna-01.xml
	# This doesn't work as jing does not take STDIN input
	# xmllint --xinclude ../ParlaMint-SI/ParlaMint-SI.xml | $j ParlaMint.rng

### Location of Jing (for RelaxNG validation) and Saxon (for XSLT stylesheets)
j = java -jar /usr/share/java/jing.jar
s = java -jar /usr/share/java/saxon.jar
