<?xml version='1.0' encoding='UTF-8'?>
<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:eg="http://www.tei-c.org/ns/Examples"
    xmlns:pm="ParlaMint"
    exclude-result-prefixes="xsl tei">
  <xsl:param name="src"/>
  <xsl:variable name="orig" select="document($src)"/>
  
  <xsl:output indent="yes"/>
  
  <xsl:template match="tei:elementSpec">
    <xsl:copy>
      <xsl:variable name="ident" select="@ident"/>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="tei:desc"/>
      <xsl:apply-templates select="tei:content"/>
      <attList>
	<xsl:if test="tei:attList/tei:*">
	  <xsl:apply-templates select="tei:attList/tei:*"/>
	</xsl:if>
	<xsl:copy-of select="$orig//tei:elementSpec[@ident=$ident]/tei:attList/pm:attPreserve"/>
      </attList>
      <xsl:apply-templates select="tei:exemplum"/>
      <xsl:apply-templates select="tei:remarks"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tei:* | eg:* | pm:*">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="tei:* | eg:* | pm:* | text() | comment()"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="@*">
    <xsl:copy/>
  </xsl:template>
  <xsl:template match="comment()">
    <xsl:copy/>
  </xsl:template>
</xsl:stylesheet>
