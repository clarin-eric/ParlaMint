<?xml version='1.0' encoding='UTF-8'?>
<!-- Unify egXML/@source values -->
<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:eg="http://www.tei-c.org/ns/Examples"
    exclude-result-prefixes="xsl">
  
  <xsl:output indent="yes"/>
  <xsl:template match="eg:egXML">
    <xsl:copy>
      <xsl:attribute name="source">
	<xsl:choose>
	  <xsl:when test="@source = '#ParlaMint'">#ParlaMint</xsl:when>
	  <xsl:otherwise>#TEI</xsl:otherwise>
	</xsl:choose>
      </xsl:attribute>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>
  <!--xsl:template match="tei:* | eg:*">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="tei:* | eg:* | text()"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="@*">
    <xsl:copy/>
  </xsl:template-->
</xsl:stylesheet>
