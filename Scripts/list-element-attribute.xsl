<?xml version="1.0" encoding="UTF-8"?>
<!--  -->
<xsl:stylesheet 
    xmlns="http://www.tei-c.org/ns/1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:et="http://nl.ijs.si/et"
    xmlns:mk="http://ufal.mff.cuni.cz/matyas-kopp"
    exclude-result-prefixes="tei et mk"
    version="2.0">

  <xsl:output encoding="utf-8" method="text"/>

  <xsl:variable name="country" select="replace(replace(document-uri(/), '.+/([^/]+)\.xml', '$1'), 'ParlaMint-([^._]+).*', '$1')"/>

  <xsl:template match="text()"/>

  <xsl:template match="tei:*">
    <xsl:apply-templates select="@*"/>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="@*">
    <xsl:value-of select="mk:print_pair(./parent::tei:*/name(),name())"/>
  </xsl:template>

  <xsl:function name="mk:print_pair">
    <xsl:param name="elem"/>
    <xsl:param name="attr"/>
    <xsl:message>
              <xsl:value-of select="$country"/>
              <xsl:text>&#32;</xsl:text>
              <xsl:value-of select="$elem"/>
              <xsl:text>&#32;</xsl:text>
              <xsl:value-of select="$attr"/>
    </xsl:message>
  </xsl:function>

</xsl:stylesheet>
