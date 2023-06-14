<?xml version='1.0' encoding='UTF-8'?>
<!--
  Input:
    - single common parlamint taxonomy
    - langs="" space separated language codes (if empty, all languages except en is removed from taxonomy)
  Output:
    - taxonomy with:
      - english version
      - if translation for certain language missing then empty translation (in comment is stored an english origin)
      - langs version if present in common taxonomy
    - /taxonomy/xml:lang is set to "mul"
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="tei">

  <xsl:output method="xml" indent="yes"/>
  <xsl:param name="langs"/>
  <xsl:variable name="languages" select="tokenize($langs, '\s+')"/>

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:taxonomy">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:desc[@xml:lang = 'en'] | tei:catDesc[@xml:lang = 'en']">
    <xsl:variable name="elem" select="."/>
    <!-- put English at the first place -->
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
    <!-- all translations follows in alphabetical order -->
    <xsl:for-each select="$languages">
      <xsl:sort select="."/>
      <xsl:variable name="lang" select="."/>
      <xsl:variable name="translated-elem" select="$elem/parent::tei:*/tei:*[
                                                      local-name() = $elem/local-name()
                                                      and @xml:lang = $lang
                                                      and normalize-space(.)
                                                      ]"/>
      <xsl:message><xsl:copy-of select="$elem"/><xsl:copy-of select="$translated-elem"/></xsl:message>
      <xsl:choose>
        <!-- skipping english -->
        <xsl:when test=". = 'en'"/>
        <!-- preserving translation from common file -->
        <xsl:when test="$translated-elem">
          <xsl:apply-templates select="$translated-elem" mode="preserve-translation"/>
        </xsl:when>
        <!-- prepare elements for new translation -->
        <xsl:otherwise>
          <xsl:apply-templates select="$elem" mode="translate">
            <xsl:with-param name="lang" select="$lang"/>
          </xsl:apply-templates>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="tei:*[@xml:lang and not(@xml:lang = 'en') and not(@xml:lang = 'mul')]"/>

  <xsl:template match="tei:*[not(@xml:lang)]">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:*" mode="preserve-translation">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates mode="preserve-translation"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:*" mode="translate">
    <xsl:param name="lang"/>
    <xsl:copy>
      <xsl:if test="$lang"><xsl:attribute name="xml:lang" select="$lang"/></xsl:if>
      <xsl:apply-templates mode="translate"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@*">
    <xsl:copy/>
  </xsl:template>

  <xsl:template match="text()[normalize-space(.)]" mode="translate">
    <xsl:if test="matches(.,'^ *:.*$')"><xsl:text>: </xsl:text></xsl:if>
    <xsl:comment><xsl:value-of select="replace(.,'^ *: *','')"/></xsl:comment>
  </xsl:template>

</xsl:stylesheet>