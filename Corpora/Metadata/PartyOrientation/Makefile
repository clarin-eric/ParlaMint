all:	get cnv
path = /project/corpora/Parla/ParlaMint/ParlaMint/Parties
cnv:
	$s sheet=${path}/ParlaMint-Coalitions.tsv -xsl:../Scripts/coaloppo-tsv2xml.xsl \
	../ParlaMint.xml > ParlaMint-relations.xml 2> ParlaMint-relations.log
get:
	-cp 'ParlaMint-Coalitions - coalOppo.tsv' ParlaMint-Coalitions.tsv
	dos2unix ParlaMint-Coalitions.tsv

################################################
s = java -jar /usr/share/java/saxon.jar
j = java -jar /usr/share/java/jing.jar
