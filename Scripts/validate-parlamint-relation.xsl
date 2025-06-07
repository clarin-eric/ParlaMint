<?xml version='1.0' encoding='UTF-8'?>
<!-- Validation of coalition / opposition relations -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:mk="http://ufal.mff.cuni.cz/matyas-kopp"
  exclude-result-prefixes="tei mk xi">

  <!--xsl:import href="parlamint-lib.xsl"/-->
  
  <xsl:output method="text"/>

  <xsl:template match="tei:*">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="text()"/>

  <xsl:template match="tei:listRelation">
    <xsl:variable name="coalition">
      <xsl:for-each select="tei:relation[@name = 'coalition']">
        <xsl:variable name="orig" select="."/>
        <xsl:variable name="from" select="@from"/>
        <xsl:variable name="to" select="@to"/>
        <xsl:for-each select="tokenize(@mutual, ' ')">
          <coalition org="{.}" from="{$from}" to="{$to}">
            <xsl:copy-of select="$orig"/>
          </coalition>
        </xsl:for-each>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="opposition">
      <xsl:for-each select="tei:relation[@name = 'opposition']">
        <xsl:variable name="orig" select="."/>
        <xsl:variable name="from" select="@from"/>
        <xsl:variable name="to" select="@to"/>
        <xsl:for-each select="tokenize(@active, ' ')">
          <opposition org="{.}" from="{$from}" to="{$to}">
            <xsl:copy-of select="$orig"/>
          </opposition>
        </xsl:for-each>
      </xsl:for-each>
    </xsl:variable>

    <xsl:for-each select="$coalition/tei:coalition">
      <xsl:variable name="org" select="@org"/>
      <xsl:variable name="from" select="@from"/>
      <xsl:variable name="to" select="@to"/>
      <xsl:variable name="orig" select="tei:relation"/>
      <xsl:for-each select="$opposition/tei:opposition[@org = $org]">
        <!--xsl:message select="concat('INFO: coalition /opposition for ', $org)"/-->
        <xsl:variable name="ok">
          <xsl:choose>
            <xsl:when test="normalize-space($from) and normalize-space(@from) and
                            normalize-space($to) and normalize-space(@to) and
                            ($from &gt; @to or $to &lt; @from)">OK</xsl:when>
            <xsl:when test="not(normalize-space($from)) and normalize-space($to) and
                            normalize-space(@from) and
                            ($to &lt; @from)">OK</xsl:when>
            <xsl:when test="not(normalize-space($to)) and normalize-space($from) and
                            normalize-space(@to) and
                            ($from &gt; @to)">OK</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:if test="not(normalize-space($ok))">
          <xsl:message select="concat('ERROR: ', $org,
                               ' in coalition @form -- @to = ', $from, ' -- ', $to,
                               ' and in opposition @form -- @to = ', @from, ' -- ', @to,
                               ' cf.&#10;',
                               '&#9;relation name=&quot;coalition&quot;',
                               ' mutual=&quot;', $orig/@mutual, '&quot;',
                               ' from=&quot;', $from, '&quot;',
                               ' to=&quot;', $to, '&quot;',
                               '&#10;&#9;and&#10;',
                               '&#9;relation name=&quot;opposition&quot;',
                               ' active=&quot;', tei:relation/@active, '&quot;',
                               ' from=&quot;', tei:relation/@from, '&quot;',
                               ' to=&quot;', tei:relation/@to, '&quot;'
                               )"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>
  
</xsl:stylesheet>
