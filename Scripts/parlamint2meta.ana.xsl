<?xml version="1.0"?>
<!-- Transform one ParlaMint file to a TSV file with its .ana related metadata. -->
<!-- Includes header row, cf. template for tei:TEI -->
<!-- Needs the file with corpus teiHeader giving the sentiment taxonomy -->
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
  
  <xsl:template match="tei:TEI">
    <xsl:message select="concat('INFO: Converting ', @xml:id, ' to .ana metadata TSV')"/>
    <xsl:text>ID&#9;</xsl:text>
    <xsl:text>Parent_ID&#9;</xsl:text>
    <xsl:text>Element&#9;</xsl:text>
    <xsl:text>Language&#9;</xsl:text>
    <xsl:text>Senti_3&#9;</xsl:text>
    <xsl:text>Senti_6&#9;</xsl:text>
    <xsl:text>Senti_n&#9;</xsl:text>
    <xsl:text>Sents&#9;</xsl:text>
    <xsl:text>Words&#9;</xsl:text>
    <xsl:text>Tokens&#9;</xsl:text>
    <xsl:text>Names&#9;</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:apply-templates select=".//tei:u"/>
  </xsl:template>
  
  <xsl:template match="tei:u | tei:s">
    <xsl:variable name="parent_id">
      <xsl:choose>
        <xsl:when test="self::tei:u">
          <xsl:value-of select="$text_id"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="ancestor::tei:u/@xml:id"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="lang">
      <xsl:choose>
        <xsl:when test="self::tei:u">
          <xsl:call-template name="u-langs"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="et:l10n($out-lang,
                                $rootHeader//tei:langUsage/tei:language[@ident = $corpus-language])"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- IL doesn't have sentiment, SI has it for u as well, others for s only -->
    <xsl:variable name="senti3">
      <xsl:if test="$country-code != 'IL' and (self::tei:s or $country-code = 'SI')">
        <xsl:call-template name="senti">
          <xsl:with-param name="lang" select="$out-lang"/>
          <xsl:with-param name="type">3</xsl:with-param>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="senti6">
      <xsl:if test="$country-code != 'IL' and (self::tei:s or $country-code = 'SI')">
        <xsl:call-template name="senti">
          <xsl:with-param name="lang" select="$out-lang"/>
          <xsl:with-param name="type">6</xsl:with-param>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="sentin">
      <xsl:if test="$country-code != 'IL' and (self::tei:s or $country-code = 'SI')">
        <xsl:call-template name="senti">
          <xsl:with-param name="lang" select="$out-lang"/>
          <xsl:with-param name="type">n</xsl:with-param>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>
    <xsl:value-of select="concat(et:tsv-value(@xml:id), '&#9;')"/>
    <xsl:value-of select="concat(et:tsv-value($parent_id), '&#9;')"/>
    <xsl:value-of select="concat(name(), '&#9;')"/>
    <xsl:value-of select="concat($lang, '&#9;')"/>
    <xsl:value-of select="concat(et:tsv-value($senti3), '&#9;')"/>
    <xsl:value-of select="concat(et:tsv-value($senti6), '&#9;')"/>
    <xsl:value-of select="concat(et:tsv-value($sentin), '&#9;')"/>
    <xsl:value-of select="concat(count(self::tei:s) + count(.//tei:s), '&#9;')"/>
    <xsl:value-of select="concat(count(.//tei:w), '&#9;')"/>
    <xsl:value-of select="concat(count(.//tei:w) + count(.//tei:pc), '&#9;')"/>
    <xsl:value-of select="concat(count(.//tei:name), '&#9;')"/>
    <xsl:text>&#10;</xsl:text>
    <xsl:if test="self::tei:u">
      <xsl:apply-templates select=".//tei:s"/>
    </xsl:if>
  </xsl:template>
  
</xsl:stylesheet>
