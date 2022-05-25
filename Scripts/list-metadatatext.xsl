<?xml version='1.0' encoding='UTF-8'?>
<!-- Output all elements in teiHeader that has attributes and contains text only -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  exclude-result-prefixes="fn tei">
  <xsl:strip-space elements="*"/>
  <xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="yes"/>
  <xsl:template match="/">
    <DUMMY xmlns="http://www.tei-c.org/ns/1.0">
      <xsl:apply-templates select="//tei:teiHeader"/>
    </DUMMY>
  </xsl:template>
  <xsl:template match="tei:*[@* and not(tei:*) and normalize-space(.)]">
    <xsl:copy-of select="."/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
  <xsl:template match="@*"/>
  <xsl:template match="text()"/>
</xsl:stylesheet>
