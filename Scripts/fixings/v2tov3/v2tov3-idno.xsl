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


  <xsl:template match="tei:idno[@type='URI' 
		       and @subtype='wikimedia' and contains(./text(), 'wikipedia.org')] | 
		       tei:idno[@type='URI' 
		       and @subtype and contains(./text(), concat(@subtype,'.') ) ] | 
		       tei:idno[@type='URI' and 
		       not(@subtype) and contains(./text(), 'github.com' ) ] ">
    <xsl:copy>
      <xsl:apply-templates select="@* | * | text() | comment()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:idno[not(text())]">
    <xsl:choose>
      <xsl:when test="$country='LV' and @subtype='handle' and./parent::tei:publicationStmt">
        <xsl:copy>
          <xsl:attribute name="type">URI</xsl:attribute>
          <xsl:text>https://github.com/clarin-eric/ParlaMint</xsl:text>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="error">
          <xsl:with-param name="severity">ERROR</xsl:with-param>
          <xsl:with-param name="msg">
	    <xsl:text>removing due to empty string in idno: </xsl:text>
	    <xsl:apply-templates select="." mode="serialize"/>
	  </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:bibl/tei:idno[contains(./text(), 'parlametar.bg') and $country='BG']">
    <xsl:call-template name="error">
      <xsl:with-param name="severity">INFO</xsl:with-param>
      <xsl:with-param name="msg">
	<xsl:text>removing parlameter idno: </xsl:text>
	<xsl:apply-templates select="." mode="serialize"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="tei:idno[$country='IS' and text() = 'www.athingi.is']">
    <xsl:call-template name="error">
      <xsl:with-param name="severity">INFO</xsl:with-param>
      <xsl:with-param name="msg">
	<xsl:text>fixing idno url and adding subtype: </xsl:text>
	<xsl:apply-templates select="." mode="serialize"/>
      </xsl:with-param>
    </xsl:call-template>
    <idno type="URI" subtype="parliament">https://www.althingi.is/</idno>
  </xsl:template>

  <xsl:template match="tei:idno">
    <xsl:copy>
      <xsl:apply-templates select="@*[not(contains(' type subtype ', local-name()))]"/>
      <xsl:if test="@type and @type=upper-case(@type) and not(contains(' URI URL ', @type))">
        <xsl:call-template name="error">
          <xsl:with-param name="severity">ERROR</xsl:with-param>
          <xsl:with-param name="msg">
	    <xsl:text>unexpected value idno/@type=</xsl:text>
	    <xsl:value-of select="@type"/>
	  </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
      <xsl:attribute name="type">URI</xsl:attribute>
      <xsl:choose>
	<!-- no change needed -->
        <xsl:when test="contains(./text(), 'wikipedia.org') and @subtype='wikimedia'"> 
          <xsl:apply-templates select="@subtype"/>
        </xsl:when>
	<!-- no change needed -->
        <xsl:when test="contains(./text(), 'fb.com') and @subtype='facebook'">
          <xsl:apply-templates select="@subtype"/>
        </xsl:when>

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
        <xsl:when test="$country='BG' and contains(./text(), 'government.bg')">
          <xsl:attribute name="subtype">government</xsl:attribute>
        </xsl:when>
        <xsl:when test="$country='BG' and contains(./text(), 'comdos.bg')">
          <xsl:attribute name="subtype">publicService</xsl:attribute>
        </xsl:when>
        <xsl:when test="$country='BG' and (contains(./text(), 'kalinveliov.com') or contains(./text(), 'aop.bg/'))">
          <xsl:call-template name="error">
            <xsl:with-param name="severity">ERROR</xsl:with-param>
            <xsl:with-param name="msg"><xsl:text>no subtype</xsl:text></xsl:with-param>
          </xsl:call-template>
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

        <!-- GR -->
        <xsl:when test="$country='GR' and contains(./text(), 'hellenicparliament.gr')">
          <xsl:attribute name="subtype">parliament</xsl:attribute>
        </xsl:when>

        <!-- HR -->
        <xsl:when test="$country='HR' and contains(./text(), 'www.sabor.hr')">
          <xsl:attribute name="subtype">parliament</xsl:attribute>
        </xsl:when>
        <xsl:when test="$country='HR' and contains(./text(), 'parlametar.hr')">
          <xsl:attribute name="subtype">business</xsl:attribute>
        </xsl:when>

        <!-- HU -->
        <xsl:when test="$country='HU' and contains(./text(), 'parlament.hu')">
          <xsl:attribute name="subtype">parliament</xsl:attribute>
        </xsl:when>
        <xsl:when test="$country='HU' and contains(./text(), 'wikipedia.org')">
          <xsl:attribute name="subtype">wikimedia</xsl:attribute>
        </xsl:when>

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
          <xsl:call-template name="error">
            <xsl:with-param name="severity">WARN</xsl:with-param>
            <xsl:with-param name="msg">
	      <xsl:text>using all lang patch (orgs) idno/@subtype </xsl:text>
	      <xsl:apply-templates select="." mode="serialize"/>
	    </xsl:with-param>
          </xsl:call-template>
          <xsl:attribute name="subtype" select="@type"/>
        </xsl:when>
        <xsl:when test="contains(concat(' ',@sub,' ',@subtype), ' wiki') and @subtype != 'wikimedia'">
          <xsl:call-template name="error">
            <xsl:with-param name="severity">WARN</xsl:with-param>
            <xsl:with-param name="msg">
	      <xsl:text>using all lang patch (wiki) idno/@subtype </xsl:text>
	      <xsl:apply-templates select="." mode="serialize"/>
	    </xsl:with-param>
          </xsl:call-template>
          <xsl:attribute name="subtype">wikimedia</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="error">
            <xsl:with-param name="severity">ERROR</xsl:with-param>
            <xsl:with-param name="msg">
	      <xsl:text>otherwise </xsl:text>
	      <xsl:value-of select="$country"/>
	      <xsl:text> </xsl:text>
	      <xsl:apply-templates select="." mode="serialize"/>
	    </xsl:with-param>
          </xsl:call-template>
          <!-- no fixture - just copy attribute -->
          <xsl:apply-templates select="@subtype"/>
        </xsl:otherwise>
      </xsl:choose>
      <!--xsl:attribute name="subtype" select="@type"/-->
      <xsl:value-of select="."/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
