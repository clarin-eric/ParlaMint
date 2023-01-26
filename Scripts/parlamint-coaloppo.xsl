<?xml version="1.0"?>
<!-- Dump all coalitions/oppositions as TSV file -->
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:tei="http://www.tei-c.org/ns/1.0" 
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:et="http://nl.ijs.si/et" 
  exclude-result-prefixes="#all"
  version="2.0">

  <xsl:output method="text"/>
  
  <xsl:template match="text()"/>
  <xsl:template match="/">
    <xsl:text>Country&#9;Role&#9;From&#9;To&#9;Party IDs&#10;</xsl:text>
    <xsl:for-each select="//xi:include">
      <!-- We need "../" as the this XSLT is in Scripts! -->
      <xsl:variable name="href" select="concat('../', @href)"/>
      <xsl:variable name="country" select="replace(@href, '.+ParlaMint-([A-Z]{2}(-[A-Z0-9]{1,3})?).*', '$1')"/>
      <xsl:variable name="coalition">
        <xsl:apply-templates select="document($href)//tei:relation[@name = 'coalition']">
          <xsl:with-param name="country" select="$country"/>
        </xsl:apply-templates>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="$coalition != ''">
          <xsl:value-of select="$coalition"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat($country, '&#9;coalition&#9;-&#9;-&#9;-&#10;')"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="opposition">
        <xsl:apply-templates select="document($href)//tei:relation[@name = 'opposition']">
          <xsl:with-param name="country" select="$country"/>
        </xsl:apply-templates>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="$opposition != ''">
          <xsl:value-of select="$opposition"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat($country, '&#9;opposition&#9;-&#9;-&#9;-&#10;')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="tei:relation">
    <xsl:param name="country"/>
    <xsl:value-of select="$country"/>
    <xsl:text>&#9;</xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:text>&#9;</xsl:text>
    <xsl:choose>
      <xsl:when test="@from">
        <xsl:value-of select="@from"/>
      </xsl:when>
      <xsl:otherwise>-</xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#9;</xsl:text>
    <xsl:choose>
      <xsl:when test="@to">
        <xsl:value-of select="@to"/>
      </xsl:when>
      <xsl:otherwise>-</xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#9;</xsl:text>
    <xsl:value-of select="replace(@mutual, '#', '')"/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
</xsl:stylesheet>
