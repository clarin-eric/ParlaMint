<?xml version='1.0' encoding='UTF-8'?>
<!-- Copy input TEI ODD to output -->
<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:sch="http://purl.oclc.org/dsdl/schematron" 
    xmlns:ex="http://www.tei-c.org/ns/Examples"
    xmlns:eg="http://www.tei-c.org/ns/Examples"
    xmlns:egXML="http://www.tei-c.org/ns/Examples"
    exclude-result-prefixes="xsl sch">
  <xsl:strip-space elements="*"/>
  <xsl:output method="xml" version="1.0" encoding="utf-8" indent="no" omit-xml-declaration="no"/>
  <xsl:template match="tei:* | ex:*">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="tei:*|ex:*|text()"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="@*">
    <xsl:copy/>
  </xsl:template>
</xsl:stylesheet>
