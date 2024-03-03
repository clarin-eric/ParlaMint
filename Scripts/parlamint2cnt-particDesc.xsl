<?xml version="1.0"?>
<!-- Make TSV/LaTeX table with overview info on metadata of the ParlaMint corpora: -->
<!-- stats on particDesc/person and particDesc/org -->
<!-- Input is main ParlaMint corpus root ParlaMint.xml (with XIncludes to the individial corpus roots) -->
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

  <xsl:output method="text" encoding="utf-8"/>

  <!-- What to output the table as -->
  <xsl:param name="mode">TeX</xsl:param>

  <xsl:import href="parlamint-lib.xsl"/>
  
  <!-- Mode dependent colon and line separators -->
  <xsl:variable name="col-sep">
    <xsl:choose>
      <xsl:when test="matches($mode, 'tex', 'i')">
        <xsl:text>&amp;</xsl:text>
      </xsl:when>
      <xsl:when test="matches($mode, 'tsv', 'i')">
        <xsl:text>&#9;</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="line-sep">
    <xsl:choose>
      <xsl:when test="matches($mode, 'tex', 'i')">
        <xsl:text>\\&#10;</xsl:text>
      </xsl:when>
      <xsl:when test="matches($mode, 'tsv', 'i')">
        <xsl:text>&#10;</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>
  
  <!-- If LaTeX -->
  <xsl:variable name="preamble">\begin{tabular*}{\textwidth}{@{\extracolsep\fill}l rrr@{~}rrrr@{~}rrrr@{}}&#10;</xsl:variable>
  <!-- Either format -->
  <xsl:variable name="header-row">
    <xsl:if test="matches($mode, 'tex', 'i')">
      <xsl:text>\toprule&#10;</xsl:text>
      <xsl:text>&amp;\multicolumn{3}{@{}c@{}}{Organisation}&amp;\multicolumn{4}{@{}c@{}}{Person}&amp;\multicolumn{4}{@{}c@{}}{Affiliation}\\&#10;</xsl:text>
      <xsl:text>\cmidrule{2-4}\cmidrule{5-8}\cmidrule{9-12}</xsl:text>
    </xsl:if>
    <xsl:text>ID</xsl:text> <!-- ISO country code -->
    <!-- Organizations:-->
    <xsl:value-of select="$col-sep"/>
    <xsl:text>Org</xsl:text>  <!-- Number of organistations -->
    <xsl:value-of select="$col-sep"/>
    <xsl:text>Prt</xsl:text> <!-- Number of political parties -->
    <xsl:value-of select="$col-sep"/>
    <xsl:text>C/O</xsl:text> <!-- Number of coalitions + oppositions -->
    <xsl:value-of select="$col-sep"/>
    <!-- Persons -->
    <xsl:text>Pers</xsl:text>  <!-- Number of "speakers" -->
    <xsl:value-of select="$col-sep"/>
    <xsl:text>Sex</xsl:text>  <!-- Speakers with gender -->
    <xsl:value-of select="$col-sep"/>
    <xsl:text>Birth</xsl:text>  <!-- Speakers with birth dates -->
    <xsl:value-of select="$col-sep"/>
    <xsl:text>URL</xsl:text>  <!-- Speakers with one or more URLs (contact, twitter, facebook) -->
    <xsl:value-of select="$col-sep"/>
    <!-- Speakers with images not included, as too little space on page -->
    <!--
    <xsl:value-of select="$col-sep"/>
    <xsl:text>IMG</xsl:text>  
    -->
    <!-- Affiliations-->
    <xsl:text>Affil</xsl:text>   <!-- Number of all (timestamped) affiliations -->
    <xsl:value-of select="$col-sep"/>
    <xsl:text>Mini</xsl:text>  <!-- Number of speakers that are ministers -->
    <xsl:value-of select="$col-sep"/>
    <xsl:text>MPs</xsl:text>  <!-- Number of MPs -->
    <xsl:value-of select="$col-sep"/>
    <xsl:text>PrtyM</xsl:text>  <!-- Number of speakers affiliated with political parties -->
    <xsl:value-of select="$line-sep"/>
    <xsl:if test="matches($mode, 'tex', 'i')">\midrule&#10;</xsl:if>
  </xsl:variable>

  <xsl:key name="ref" match="tei:org" use="concat('#', @xml:id)"/>
  
  <xsl:template match="tei:teiCorpus">
    <xsl:choose>
      <xsl:when test="matches($mode, 'tex', 'i')">
        <xsl:value-of select="$preamble"/>
        <xsl:value-of select="$header-row"/>
      </xsl:when>
      <xsl:when test="matches($mode, 'tsv', 'i')">
        <xsl:value-of select="$header-row"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="yes">Parameter 'mode' should be either TSV of TeX.</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:for-each select="xi:include">
      <xsl:variable name="teiHeader">
        <xsl:apply-templates mode="expand" select="document(@href)/tei:teiCorpus/tei:teiHeader"/>
      </xsl:variable>
      <xsl:value-of select="replace(@href, '^ParlaMint-([A-Z-]+).+', '$1')"/>
      <xsl:value-of select="$col-sep"/>
      <xsl:apply-templates select="$teiHeader"/>
    </xsl:for-each>
    <xsl:if test="matches($mode, 'tex', 'i')">
      <xsl:text>\botrule&#10;\end{tabular*}&#10;</xsl:text>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="tei:teiHeader">
    <xsl:variable name="particDesc" select=".//tei:particDesc"/>
    <!-- All organisations -->
    <xsl:value-of select="et:cnt($particDesc//tei:org)"/>
    <xsl:value-of select="$col-sep"/>
    <!-- Political parties -->
    <xsl:value-of select="et:cnt($particDesc//tei:org[@role='politicalParty' or @role='parliamentaryGroup'])"/>
    <xsl:value-of select="$col-sep"/>
    <!-- Coalitions/oppositions -->
    <xsl:value-of select="et:cnt($particDesc//tei:relation[@name='coalition' or @name='opposition'])"/>
    <xsl:value-of select="$col-sep"/>
    <!-- Speakers -->
    <xsl:value-of select="et:cnt($particDesc//tei:person)"/>
    <xsl:value-of select="$col-sep"/>
    <!-- Sex -->
    <xsl:value-of select="et:cnt($particDesc//tei:person
                          [tei:sex[@value != 'U']]
                          )"/>
    <xsl:value-of select="$col-sep"/>
    <!-- Births -->
    <xsl:value-of select="et:cnt($particDesc//tei:person
                          [tei:birth]
                          )"/>
    <xsl:value-of select="$col-sep"/>
    <!-- URLs -->
    <xsl:value-of select="et:cnt($particDesc//tei:person
                          [tei:idno[@type='URI']]
                          )"/>
    <xsl:value-of select="$col-sep"/>
    <!-- Picture, not included -->
    <!--
    <xsl:value-of select="$col-sep"/>
    <xsl:value-of select="et:cnt($particDesc//tei:person
                          [tei:figure]
                          )"/>
    -->
    <!-- Number of affiliations -->
    <xsl:value-of select="et:cnt($particDesc//tei:person/tei:affiliation)"/>
    <xsl:value-of select="$col-sep"/>
    <!-- Ministers -->
    <xsl:value-of select="et:cnt($particDesc//tei:person[tei:affiliation[@role='minister']])"/>
    <xsl:value-of select="$col-sep"/>
    <!-- MPs -->
    <xsl:value-of select="et:cnt($particDesc//tei:person[tei:affiliation[@role='member' and
                          key('ref', @ref)[@role='parliament']]
                          ])"/>
    <xsl:value-of select="$col-sep"/>
    <!-- People with party affiliation -->
    <xsl:value-of select="et:cnt($particDesc//tei:person[
                          tei:affiliation[@role='member' and
                          key('ref', @ref)[@role='politicalParty' or @role='parliamentaryGroup']]
                          ])"/>
    <xsl:value-of select="$line-sep"/>
  </xsl:template>

  <!-- Count nodes and, if LaTeX, give thousands separator -->
  <xsl:function name="et:cnt">
    <xsl:param name="nodes"/>
    <xsl:choose>
      <xsl:when test="matches($mode, 'tex', 'i')">
        <xsl:value-of select="format-number(count($nodes), '###,###,###')"/>
      </xsl:when>
      <xsl:when test="matches($mode, 'tsv', 'i')">
        <xsl:value-of select="count($nodes)"/>
      </xsl:when>
    </xsl:choose>
  </xsl:function>
</xsl:stylesheet>
