<?xml version="1.0" encoding="UTF-8"?>
<!-- return all included files' relative path from current file -->
<xsl:stylesheet 
    xmlns="http://www.tei-c.org/ns/1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xi="http://www.w3.org/2001/XInclude"
    xmlns:tei="http://www.tei-c.org/ns/1.0" 
    exclude-result-prefixes="#all"
    version="2.0">

  <xsl:output encoding="utf-8" method="text"/>
  <xsl:template match="xi:include">
    <xsl:value-of select="@href"/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="element()">
    <xsl:apply-templates select="element()"/>
  </xsl:template>
</xsl:stylesheet>
