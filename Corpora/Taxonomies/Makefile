#USAS taxonomy development
fix-usas:
	$s -xsl:fix-usastaxo.xsl usas-taxonomy.orig.xml > usas-taxonomy.xml
	xmllint --noout usas-taxonomy.orig.xml

#######################################
s = java -jar /usr/share/java/saxon.jar
j = java -jar /usr/share/java/jing.jar
