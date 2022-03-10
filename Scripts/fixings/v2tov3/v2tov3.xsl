<?xml version='1.0' encoding='UTF-8'?>
<!-- Fix bugs from ParlaMint V2 for V3 -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:et="http://nl.ijs.si/et"
  xmlns:saxon="http://saxon.sf.net/"
  exclude-result-prefixes="et fn tei saxon">
  <xsl:output indent="yes"/>
  <xsl:strip-space elements="*"/>
  <xsl:preserve-space elements="tei:change tei:seg"/>

  <xsl:param name="version">3.0a</xsl:param>
  <xsl:param name="change">
    <change when="{$today-iso}"><name>Matyáš Kopp</name>: Fixes for Version 3.</change>
  </xsl:param>
  <xsl:variable name="today-iso" select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>
  <xsl:variable name="id" select="replace(document-uri(/), '.+/([^/]+)\.xml', '$1')"/>
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
    <!--xsl:message>
      <xsl:text>INFO: converting </xsl:text>
      <xsl:value-of select="tei:*/@xml:id"/>
    </xsl:message-->
    <!--xsl:text>&#10;</xsl:text-->
    <xsl:apply-templates/>
  </xsl:template>

  <!-- STAMP -->
  <xsl:template match="tei:editionStmt/tei:edition">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:value-of select="$version"/>
    </xsl:copy>
  </xsl:template>


  <xsl:template match=" tei:idno[@type='URI' and @subtype='wikimedia' and contains(./text(), 'wikipedia.org')] | tei:idno[@type='URI' and @subtype and contains(./text(), concat(@subtype,'.') ) ] | tei:idno[@type='URI' and not(@subtype) and contains(./text(), 'github.com' ) ] ">
    <xsl:copy>
      <xsl:apply-templates select="@* | * | text() | comment()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:idno[not(text())]">
    <xsl:message>
      <xsl:text>ERROR: empty string in idno: </xsl:text> <xsl:copy-of select="."/>
    </xsl:message>
    <xsl:next-match/>
  </xsl:template>

  <xsl:template match="tei:bibl/tei:idno[contains(./text(), 'parlametar.bg') and $country='BG']">
    <xsl:message>
      <xsl:text>INFO: removing parlameter idno: </xsl:text> <xsl:copy-of select="."/>
    </xsl:message>
  </xsl:template>

  <xsl:template match="tei:idno">
    <xsl:copy>
      <xsl:apply-templates select="@*[not(contains(' type subtype ', local-name()))]"/>
      <xsl:if test="@type and @type=upper-case(@type) and not(contains(' URI URL ', @type))">
        <xsl:message>
          <xsl:text>ERROR: unexpected value idno/@type=</xsl:text> <xsl:value-of select="@type"/>
        </xsl:message>
      </xsl:if>
      <xsl:attribute name="type">URI</xsl:attribute>
      <xsl:choose>
        <!-- BE -->
        <xsl:when test="$country='BE' and contains(./text(), 'www.dekamer.be')">
          <xsl:attribute name="subtype">parliament</xsl:attribute>
        </xsl:when>
        <xsl:when test="$country='BE' and contains(./text(), 'wikipedia.org')">
          <xsl:attribute name="subtype">wikimedia</xsl:attribute>
        </xsl:when>

        <!-- BG -->
        <xsl:when test="$country='BG' and contains(./text(), 'parliament.bg')">
          <xsl:attribute name="subtype">parliament</xsl:attribute>
        </xsl:when>
        <xsl:when test="$country='BG' and contains(./text(), 'parlametar.bg') and ./parent::tei:bibl">
          <xsl:message>
            <xsl:text>ERROR: parlametar should be removes</xsl:text> <xsl:copy-of select="./parent::*"/>
          </xsl:message>
        </xsl:when>
        <xsl:when test="$country='BG' and (contains(./text(), 'government.bg') or contains(./text(), 'comdos.bg'))">
          <xsl:message>
            <xsl:text>WARN: removing idno/@subtype </xsl:text> <xsl:copy-of select="."/>
          </xsl:message>
        </xsl:when>
        <xsl:when test="$country='BG' and (contains(./text(), 'kalinveliov.com') or contains(./text(), 'aop.bg/'))">
          <xsl:message>
            <xsl:text>WARN: no subtype</xsl:text>
          </xsl:message>
        </xsl:when>
        <!-- CZ -->
        <xsl:when test="$country='CZ' and contains(./text(), 'psp.cz')">
          <xsl:attribute name="subtype">parliament</xsl:attribute>
        </xsl:when>
        <xsl:when test="$country='CZ' and contains(./text(), 'vlada.cz')">
          <xsl:attribute name="subtype">government</xsl:attribute>
        </xsl:when>
        <xsl:when test="$country='CZ' and contains(./text(), 'github') and @type='URL'"/>
        <xsl:when test="$country='CZ' and @subtype='personal'">
          <!-- no fixture - just copy attribute -->
          <xsl:apply-templates select="@subtype"/>
        </xsl:when>

        <!-- DK -->
        <xsl:when test="$country='DK' and contains(./text(), 'www.ft.dk')">
          <xsl:attribute name="subtype">parliament</xsl:attribute>
        </xsl:when>
        <xsl:when test="$country='DK' and contains(./text(), 'wikipedia.org')">
          <xsl:attribute name="subtype">wikimedia</xsl:attribute>
        </xsl:when>

        <!-- ES -->
        <xsl:when test="$country='ES' and contains(./text(), 'www.congreso.es')">
          <xsl:attribute name="subtype">parliament</xsl:attribute>
        </xsl:when>

        <!-- FR -->
        <xsl:when test="$country='FR' and contains(./text(), 'assemblee-nationale.fr')">
          <xsl:attribute name="subtype">parliament</xsl:attribute>
        </xsl:when>
        <xsl:when test="$country='FR' and contains(./text(), 'wikipedia.org')">
          <xsl:attribute name="subtype">wikimedia</xsl:attribute>
        </xsl:when>

        <!-- GB -->
        <xsl:when test="$country='GB' and contains(./text(), 'parliament.uk')"> <!-- [hansard-api,hansard,members].parliament.uk -->
          <xsl:attribute name="subtype">parliament</xsl:attribute>
        </xsl:when>

        <!-- HR -->
        <xsl:when test="$country='HR' and contains(./text(), 'www.sabor.hr')">
          <xsl:attribute name="subtype">parliament</xsl:attribute>
        </xsl:when>
        <xsl:when test="$country='HR' and contains(./text(), 'https://parlametar.hr')">
          <xsl:attribute name="subtype">bussiness</xsl:attribute>
        </xsl:when>

        <!-- HU skipping-->

        <!-- IS -->
        <xsl:when test="$country='IS' and contains(./text(),'althingi.is')">
          <xsl:attribute name="subtype">parliament</xsl:attribute>
        </xsl:when>
        <xsl:when test="$country='IS' and contains(./text(), 'wikipedia.org')">
          <xsl:attribute name="subtype">wikimedia</xsl:attribute>
        </xsl:when>

        <!-- IT -->
        <xsl:when test="$country='IT' and contains(./text(), 'senato.it')">
          <xsl:attribute name="subtype">parliament</xsl:attribute>
        </xsl:when>
        <xsl:when test="$country='IT' and contains(./text(), 'wikipedia.org')">
          <xsl:attribute name="subtype">wikimedia</xsl:attribute>
        </xsl:when>

        <!-- LT -->
        <xsl:when test="$country='LT' and contains(./text(), 'lrs.lt')">
          <xsl:attribute name="subtype">parliament</xsl:attribute>
        </xsl:when>
        <xsl:when test="$country='LT' and contains(./text(), 'wikipedia.org')">
          <xsl:attribute name="subtype">wikimedia</xsl:attribute>
        </xsl:when>

        <!-- LV -->
        <xsl:when test="$country='LV' and contains(./text(), 'www.saeima.lv')">
          <xsl:attribute name="subtype">parliament</xsl:attribute>
        </xsl:when>
        <xsl:when test="$country='LV' and contains(./text(), 'wikipedia.org')">
          <xsl:attribute name="subtype">wikimedia</xsl:attribute>
        </xsl:when>

        <!-- NL -->
        <xsl:when test="$country='NL' and contains(./text(), 'www.eerstekamer.nl')">
          <xsl:attribute name="subtype">parliament</xsl:attribute>
        </xsl:when>
        <xsl:when test="$country='NL' and contains(./text(), 'www.tweedekamer.nl')">
          <xsl:attribute name="subtype">parliament</xsl:attribute>
        </xsl:when>
        <xsl:when test="$country='NL' and contains(./text(), 'wikipedia.org')">
          <xsl:attribute name="subtype">wikimedia</xsl:attribute>
        </xsl:when>

        <!-- PL -->
        <xsl:when test="$country='PL' and contains(./text(), 'www.senat.gov.pl')">
          <xsl:attribute name="subtype">parliament</xsl:attribute>
        </xsl:when>
        <xsl:when test="$country='PL' and contains(./text(), 'www.sejm.gov.pl')">
          <xsl:attribute name="subtype">parliament</xsl:attribute>
        </xsl:when>

        <!-- SI -->
        <xsl:when test="$country='SI' and contains(./text(), 'www.dz-rs.si')">
          <xsl:attribute name="subtype">parliament</xsl:attribute>
        </xsl:when>

        <!-- TR -->
        <xsl:when test="$country='TR' and contains(./text(), 'www.tbmm.gov.tr')">
          <xsl:attribute name="subtype">parliament</xsl:attribute>
        </xsl:when>
        <xsl:when test="$country='TR' and contains(./text(), 'wikidata.org')">
          <xsl:attribute name="subtype">wikidata</xsl:attribute>
        </xsl:when>
        <xsl:when test="$country='TR' and contains(./text(), 'wikipedia.org')">
          <xsl:attribute name="subtype">wikimedia</xsl:attribute>
        </xsl:when>

        <!-- no country specific fix -->
        <xsl:when test="contains(' wikidata facebook twitter tiktok instagram ',concat(' ',@type,' '))">
          <xsl:message><xsl:text>WARN: ussing all lang patch (orgs) idno/@subtype </xsl:text> <xsl:copy-of select="."/></xsl:message>
          <xsl:attribute name="subtype" select="@type"/>
        </xsl:when>
        <xsl:when test="contains(concat(' ',@sub,' ',@subtype), ' wiki') and @subtype != 'wikimedia'">
          <xsl:message><xsl:text>WARN: ussing all lang patch (wiki) idno/@subtype </xsl:text> <xsl:copy-of select="."/></xsl:message>
          <xsl:attribute name="subtype">wikimedia</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message terminate="no"><xsl:text>ERROR otherwise </xsl:text> <xsl:value-of select="$country"/><xsl:text> </xsl:text><xsl:copy-of select="."/></xsl:message>
          <!-- no fixture - just copy attribute -->
          <xsl:apply-templates select="@subtype"/>
        </xsl:otherwise>
      </xsl:choose>
      <!--xsl:attribute name="subtype" select="@type"/-->
      <xsl:value-of select="."/>
    </xsl:copy>
  </xsl:template>
  
  <!-- COPY REST -->
  <xsl:template match="*">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@*">
    <xsl:copy/>
  </xsl:template>

  <xsl:template match="comment()">
    <xsl:copy/>
  </xsl:template>

</xsl:stylesheet>
