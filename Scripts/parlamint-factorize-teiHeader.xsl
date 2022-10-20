<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="tei xs" >
  <xsl:param name="outDir"/>
  <xsl:param name="prefix"/>

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
    <xsl:message>INFO: processing root </xsl:message>
    <xsl:result-document href="{$outRoot}">
      <xsl:apply-templates/>
    </xsl:result-document>
  </xsl:template>

  <xsl:template match="tei:listPerson | tei:listOrg | tei:taxonomy">
    <xsl:variable name="filename" select="concat($prefix,local-name(),@xml:id/concat('-',.),'.xml')"/>
    <xsl:variable name="path" select="concat($outDir,'/',$filename)"/>
    <xsl:message select="concat('Saving ',local-name(), ' to ',$path)"/>
    <xsl:result-document href="{$path}" method="xml">
      <xsl:copy-of select="." copy-namespaces="no"/>
    </xsl:result-document>
    <xsl:element name="xi:include" namespace="http://www.w3.org/2001/XInclude">
      <xsl:namespace name="xi" select="'http://www.w3.org/2001/XInclude'"/>
      <xsl:attribute name="href">
        <xsl:value-of select="$filename"/>
      </xsl:attribute>
    </xsl:element>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>