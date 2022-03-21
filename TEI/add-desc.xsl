<?xml version='1.0' encoding='UTF-8'?>
<!-- Copy input TEI ODD to output -->
<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:eg="http://www.tei-c.org/ns/Examples"
    exclude-result-prefixes="xsl">
  <xsl:param name="odd-subset">p5subset.xml</xsl:param>
  <xsl:variable name="subset" select="document($odd-subset)"/>
  
  <xsl:output indent="yes"/>
  <xsl:template match="tei:elementSpec">
    <xsl:copy>
      <xsl:variable name="ident" select="@ident"/>
      <xsl:apply-templates select="@*"/>
      <xsl:copy-of select="$subset//tei:elementSpec[@ident=$ident]/tei:desc[@xml:lang='en']"/>
      <xsl:apply-templates select="tei:* | eg:* | text()"/>

      <xsl:copy-of select="$subset//tei:elementSpec[@ident=$ident]/tei:exemplum[@xml:lang='en']"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="tei:* | eg:*">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="tei:* | eg:* | text()"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="@*">
    <xsl:copy/>
  </xsl:template>
</xsl:stylesheet>
