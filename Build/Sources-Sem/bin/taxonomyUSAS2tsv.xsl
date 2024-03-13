<?xml version='1.0' encoding='UTF-8'?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:et="http://nl.ijs.si/et" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xsl tei et xs xi"
  version="2.0">
  
  <!-- File with TSV data -->
  <xsl:output method="text"/>
  
  <xsl:template match="/">
    <xsl:apply-templates select="tei:taxonomy/tei:category"/>
  </xsl:template>
  
  <xsl:template match="tei:category">
    <xsl:value-of select="@xml:id"/>
    <xsl:text>&#9;</xsl:text>
    <xsl:value-of select="tei:catDesc/tei:term"/>
    <xsl:text>&#9;</xsl:text>
    <xsl:value-of select="substring-after(tei:catDesc, ': ')"/>
    <xsl:text>&#9;</xsl:text>
    <xsl:value-of select="@n"/>
    <xsl:text>&#10;</xsl:text>
    <xsl:apply-templates select="tei:category"/>
  </xsl:template>
</xsl:stylesheet>
