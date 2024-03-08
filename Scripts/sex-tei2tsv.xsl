<?xml version="1.0"?>
<!-- Dump person sex to a TSV file -->
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:tei="http://www.tei-c.org/ns/1.0" 
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:et="http://nl.ijs.si/et" 
  exclude-result-prefixes="#all"
  version="2.0">

  <xsl:output method="text"/>

  <!-- Get country of corpus from filename -->
  <xsl:variable name="country"
                select="replace(base-uri(), 
                        '.+ParlaMint-([A-Z]{2}(-[A-Z0-9]{1,3})?).*', 
                        '$1')"/>
  
  <xsl:template match="text()"/>
  <xsl:template match="tei:*"/>
  
  <xsl:template match="/">
    <xsl:text>country&#9;id&#9;surname&#9;forename&#9;sex&#10;</xsl:text>
    <xsl:apply-templates select="//tei:person">
      <xsl:sort/>
    </xsl:apply-templates>
  </xsl:template>
    
  <xsl:template match="tei:person">
    <xsl:value-of select="$country"/>
    <xsl:text>&#9;</xsl:text>
    <xsl:value-of select="@xml:id"/>
    <xsl:text>&#9;</xsl:text>
    <!-- There can be more than one surname or forname
         but we don't care if we mangle the surname, and we take only the first forename as geneder relevant -->
    <xsl:value-of select="tei:persName/tei:forename[1]"/>
    <xsl:text>&#9;</xsl:text>
    <xsl:value-of select="tei:persName/tei:surname"/>
    <xsl:text>&#9;</xsl:text>
    <xsl:choose>
      <xsl:when test="tei:sex/@value">
        <xsl:value-of select="tei:sex/@value"/>
      </xsl:when>
      <xsl:otherwise>U</xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

</xsl:stylesheet>
