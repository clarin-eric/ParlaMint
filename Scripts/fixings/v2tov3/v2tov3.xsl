<?xml version='1.0' encoding='UTF-8'?>
<!-- Fix bugs from ParlaMint V2 for V3 -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:et="http://nl.ijs.si/et"
  xmlns:mk="http://ufal.mff.cuni.cz/matyas-kopp"
  xmlns:saxon="http://saxon.sf.net/"
  exclude-result-prefixes="et mk fn xs tei saxon">
  <xsl:output indent="yes"/>
  <xsl:strip-space elements="*"/>
  <xsl:preserve-space elements="tei:change tei:seg"/>

  <xsl:param name="version">3.0a</xsl:param>
  <xsl:param name="change">
    <change when="{$today-iso}"><name>Matyáš Kopp</name>: Fixes for Version 3.</change>
  </xsl:param>
  <xsl:variable name="today-iso" select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>
  <xsl:variable name="id" select="replace(/tei:*/@xml:id, '.+/([^/]+)\.xml', '$1')"/>
  <xsl:variable name="lang" select="/tei:*/@xml:lang"/>
  <xsl:variable name="country" select="replace($id, 'ParlaMint-([^._]+).*', '$1')"/>

  <xsl:variable name="type">
    <xsl:choose>
      <xsl:when test="matches($id, '^ParlaMint-..\.ana$')">ana</xsl:when>
      <xsl:when test="matches($id, '^ParlaMint-..$')">txt</xsl:when>
      <xsl:when test="matches($id, '^ParlaMint-.._.+\.ana$')">ana</xsl:when>
      <xsl:when test="matches($id, '^ParlaMint-.._.+$')">txt</xsl:when>
      <xsl:otherwise>
	<xsl:message select="concat('ERROR ', $id, ': bad root ID ', $id)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- STAMP -->
  <xsl:template match="tei:editionStmt/tei:edition">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:value-of select="$version"/>
    </xsl:copy>
  </xsl:template>

  <xsl:include href="v2tov3-idno.xsl" />
  <xsl:include href="v2tov3-affiliation.xsl" />


  <!-- fix (HU) -->
  <xsl:template match="@type[$country = 'HU' and ./parent::tei:name and .='adress']" priority="1">
    <xsl:attribute name="type">address</xsl:attribute>
  </xsl:template>

  <!-- remove pubPlace (CZ) -->
  <xsl:template match="tei:pubPlace[$country = 'CZ']"/>

  <!-- remove text content from some elements -->
  <xsl:template match="text()[contains(' affiliation birth death sex ',mk:borders(../name()))]"/>

  <!-- replace @full='init' with @full='abb' -->
  <xsl:template match="@full[./parent::tei:orgName/parent::tei:org and .='init']" priority="1">
    <xsl:attribute name="full">abb</xsl:attribute>
  </xsl:template>

  <!-- COPY REST -->
  <xsl:template match="*">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@*[not(name()='LINE')]">
    <xsl:copy/>
  </xsl:template>

  <xsl:template match="@LINE"/>


  <xsl:template match="comment()">
    <xsl:copy/>
  </xsl:template>

  <!-- serialize elements -->
  <xsl:template match="*" mode="serialize">
    <xsl:text>[</xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:apply-templates select="@*" mode="serialize" />
    <xsl:choose>
        <xsl:when test="node()">
            <xsl:text>]</xsl:text>
            <xsl:apply-templates mode="serialize" />
            <xsl:text>[/</xsl:text>
            <xsl:value-of select="name()"/>
            <xsl:text>]</xsl:text>
        </xsl:when>
        <xsl:otherwise>
            <xsl:text> /]</xsl:text>
        </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="@*[not(name()='LINE')]" mode="serialize">
    <xsl:text> </xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:text>="</xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>"</xsl:text>
  </xsl:template>

  <xsl:template match="@LINE" mode="serialize"></xsl:template>

  <xsl:template match="text()" mode="serialize">
    <xsl:value-of select="."/>
  </xsl:template>

  <!-- NAMED TEMPLATES -->
  <xsl:template name="error">
    <xsl:param name="msg">???</xsl:param>
    <xsl:param name="severity">ERROR</xsl:param>
    <xsl:param name="ident">??</xsl:param>
    <xsl:message>
      <xsl:value-of select="$severity"/>
      <xsl:text>[</xsl:text>
      <xsl:value-of select="$ident"/>
      <xsl:text>]&#32;</xsl:text>
      <xsl:value-of select="/tei:*/@xml:id"/>
      <xsl:text>:</xsl:text>
      <xsl:value-of select="./@LINE"/>
      <xsl:text>&#32;</xsl:text>
      <xsl:value-of select="$msg"/>
    </xsl:message>
  </xsl:template>

  <!-- FUNCTIONS -->

  <xsl:function name="mk:get_from">
    <xsl:param name="node"/>
    <xsl:variable name="crop" select="10"/>
    <xsl:choose>
      <xsl:when test="$node/@from"><xsl:value-of select="substring($node/@from,1,$crop)"/></xsl:when>
      <xsl:when test="$node/@when"><xsl:value-of select="substring($node/@when,1,$crop)"/></xsl:when>
      <xsl:when test="$node
                        and $node/ancestor::tei:teiHeader//tei:sourceDesc/tei:bibl[1]/tei:date
                        and not($node/parent::tei:bibl/parent::tei:sourceDesc/parent::tei:fileDesc)">
        <xsl:value-of select="mk:get_from($node/ancestor::tei:teiHeader//tei:sourceDesc/tei:bibl[1]/tei:date)"/>
      </xsl:when>
      <xsl:otherwise>1900-01-01</xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="mk:get_to">
    <xsl:param name="node"/>
    <xsl:variable name="crop" select="10"/>
    <xsl:choose>
      <xsl:when test="$node/@to"><xsl:value-of select="substring($node/@to,1,$crop)"/></xsl:when>
      <xsl:when test="$node/@when"><xsl:value-of select="substring($node/@when,1,$crop)"/></xsl:when>
      <xsl:when test="$node
                        and $node/ancestor::tei:teiHeader//tei:sourceDesc/tei:bibl[1]/tei:date
                        and not($node/parent::tei:bibl/parent::tei:sourceDesc/parent::tei:fileDesc)">
        <xsl:value-of select="mk:get_to($node/ancestor::tei:teiHeader//tei:sourceDesc/tei:bibl[1]/tei:date)"/>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="$node/ancestor::tei:teiHeader//tei:publicationStmt/tei:date/@when"/></xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="mk:borders">
    <xsl:param name="str"/>
    <xsl:value-of select="concat(' ',$str,' ')"/>
  </xsl:function>
</xsl:stylesheet>
