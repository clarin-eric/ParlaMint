<?xml version="1.0"?>
<!-- Make table with basic info on speakers of a set of ParlaMint corpora  -->
<!-- Expects the auto-generatd ParlaMint root file (ParlaMint.xml) with all the <person> as input, outputs TSV -->
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:fn="http://www.w3.org/2005/xpath-functions" 
    xmlns:et="http://nl.ijs.si/et"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xi="http://www.w3.org/2001/XInclude"
    exclude-result-prefixes="fn et tei xs xi"
    version="2.0">

  <xsl:import href="parlamint-lib.xsl"/>
  
  <xsl:output method="text" encoding="utf-8"/>

  <xsl:variable name="header-row">
    <xsl:text>Country&#9;</xsl:text>
    <xsl:text>SpeakerID&#9;</xsl:text>
    <xsl:text>Name&#9;</xsl:text>
    <xsl:text>Sex</xsl:text>
    <xsl:text>&#10;</xsl:text>
  </xsl:variable>

  <xsl:template match="@*"/>
  <xsl:template match="text()"/>
  
  <xsl:template match="/">
    <xsl:value-of select="$header-row"/>
    <xsl:variable name="country" select="replace(base-uri(), 
                                         '.+ParlaMint-([A-Z]{2}(-[A-Z0-9]{1,3})?).*', 
                                         '$1')"/>
    <xsl:apply-templates select="$rootHeader//tei:listPerson/tei:person">
      <xsl:with-param name="country" select="$country"/>
      <xsl:sort select="@xml:id"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="tei:person">
    <xsl:param name="country"/>
    <xsl:value-of select="$country"/>
    <xsl:text>&#9;</xsl:text>
    <xsl:value-of select="@xml:id"/>
    <xsl:text>&#9;</xsl:text>
    <xsl:value-of select="et:format-name(tei:persName[1])"/>
    <xsl:text>&#9;</xsl:text>
    <xsl:choose>
      <xsl:when test="tei:sex/@value">
	<xsl:value-of select="tei:sex/@value"/>
      </xsl:when>
      <xsl:otherwise>-</xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
</xsl:stylesheet>
