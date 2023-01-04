<?xml version="1.0"?>
<!-- Transform one ParlaMint file to plain text -->
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0" 
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="xsl tei"
  version="2.0">

  <xsl:output method="text"/>
  
  <xsl:template match="/">
    <!--xsl:message select="concat('INFO: converting ', tei:TEI/@xml:id, ' to text')"/-->
    <xsl:apply-templates select="//tei:u"/>
  </xsl:template>
  
  <xsl:template match="tei:u">
    <xsl:variable name="text">
      <xsl:apply-templates/>
    </xsl:variable>
    <xsl:value-of select="concat(@xml:id, '&#9;', 
                          normalize-space($text), '&#10;')"/>
  </xsl:template>

  <xsl:template match="tei:note | tei:gap | tei:vocal | tei:kinesic | tei:incident">
    <xsl:variable name="text">
      <xsl:value-of select="normalize-space(.)"/>
    </xsl:variable>
    <xsl:value-of select="concat('[[', normalize-space($text), ']]')"/>
  </xsl:template>

</xsl:stylesheet>
