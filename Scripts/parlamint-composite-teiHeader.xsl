<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="tei xs" >
  <xsl:param name="outDir"/>

  <xsl:output method="xml" indent="yes" encoding="UTF-8" />
  <xsl:preserve-space elements="catDesc seg"/>

  <xsl:variable name="outRoot">
    <xsl:value-of select="$outDir"/>
    <xsl:text>/</xsl:text>
    <xsl:value-of select="replace(base-uri(), '.*/(.+)$', '$1')"/>
  </xsl:variable>

  <xsl:template match="/">
    <xsl:message select="concat('INFO: Starting to process ', tei:teiCorpus/@xml:id)"/>
    <!-- Output Root file -->
    <xsl:result-document href="{$outRoot}">
      <xsl:apply-templates/>
    </xsl:result-document>
  </xsl:template>

  <xsl:template match="tei:teiHeader//xi:include">
     <xsl:message select="concat('including: ',@href)"/>
     <xsl:copy-of select="document(@href)"/>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>