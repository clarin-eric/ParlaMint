<?xml version="1.0" encoding="UTF-8"?>
<!-- Return all included files' relative path from current file -->
<xsl:stylesheet 
    xmlns="http://www.tei-c.org/ns/1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xi="http://www.w3.org/2001/XInclude"
    xmlns:tei="http://www.tei-c.org/ns/1.0" 
    exclude-result-prefixes="#all"
    version="2.0">

  <!--
  DEFAULT VALUE: context-elements="" means no filtering - all xincudes are printed
  set space-separated list of parent elements if only specific included files are necesary
  eg context-elements="teiCorpus" for component files
  or context-elements="particDesc classDecl" for header files
  -->
  <xsl:param name="context-elements"></xsl:param>
  <xsl:variable name="celems" select="tokenize($context-elements)"/>

  <xsl:output encoding="utf-8" method="text"/>
  <xsl:template match="xi:include[not($celems) or parent::*[local-name() = $celems]]">
    <xsl:value-of select="@href"/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="element()">
    <xsl:apply-templates select="element()"/>
  </xsl:template>
</xsl:stylesheet>
