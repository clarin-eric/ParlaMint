<?xml version="1.0"?>
<!-- Make TSV/LaTeX table with overview info on data of the ParlaMint corpora -->
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
  <xsl:variable name="preamble">\begin{tabular}{l|rrrrrrr}&#10;</xsl:variable>
  <xsl:variable name="header-row">
    <xsl:text>ID</xsl:text> <!-- ISO country code -->
    <xsl:value-of select="$col-sep"/>
    <xsl:text>Speeches</xsl:text> <!-- Number of speeches -->
    <xsl:value-of select="$col-sep"/>
    <xsl:text>W.Spks</xsl:text>  <!-- Number of speeches with speakers -->
    <xsl:value-of select="$col-sep"/>
    <xsl:text>W.NCs</xsl:text>  <!-- Number of speeches by non-chairs -->
    <xsl:value-of select="$col-sep"/>
    <xsl:text>W.MPs</xsl:text>  <!-- Number of speeches by MPs -->
    <xsl:value-of select="$col-sep"/>
    <xsl:text>Heads</xsl:text>  <!-- Number of headings -->
    <xsl:value-of select="$col-sep"/>
    <xsl:text>Notes</xsl:text>  <!-- Number of notes -->
    <xsl:value-of select="$col-sep"/>
    <xsl:text>Incidents</xsl:text>  <!-- Number of incidents -->
    <!--xsl:value-of select="$col-sep"/>
    <xsl:text>Paragraphs</xsl:text-->  <!-- Number of paragraphs -->
    <xsl:value-of select="$line-sep"/>
    <xsl:if test="matches($mode, 'tex', 'i')">\hline&#10;</xsl:if>
  </xsl:variable>

  <xsl:key name="ref" match="tei:org|tei:person" use="concat('#', @xml:id)"/>
  
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
      <xsl:apply-templates select="document(@href)/tei:teiCorpus/tei:teiHeader"/>
    </xsl:for-each>
    <xsl:if test="matches($mode, 'tex', 'i')">
      <xsl:text>\end{tabular}&#10;</xsl:text>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="tei:teiHeader">
    <xsl:variable name="head" select="."/>
    <xsl:value-of select="ancestor::tei:teiCorpus/replace(@xml:id, '.+-', '')"/>
    
    <xsl:value-of select="$col-sep"/>
    <xsl:variable name="utterances">
      <xsl:for-each select="document(../xi:include/@href)">
        <item>
          <xsl:value-of select="count(//tei:u)"/>
        </item>
      </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="et:sum($utterances/tei:item)"/>
    
    <xsl:value-of select="$col-sep"/>
    <xsl:variable name="speeches">
      <xsl:for-each select="document(../xi:include/@href)">
        <item>
          <xsl:value-of select="count(//tei:u[@who])"/>
        </item>
      </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="et:sum($speeches/tei:item)"/>
    
    <xsl:value-of select="$col-sep"/>
    <xsl:variable name="nonchairs">
      <xsl:for-each select="document(../xi:include/@href)">
        <item>
          <xsl:value-of select="count(//tei:u[@ana != '#chair'])"/>
        </item>
      </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="et:sum($nonchairs/tei:item)"/>
    
    <xsl:value-of select="$col-sep"/>
    <xsl:variable name="mps">
      <xsl:for-each select="document(../xi:include/@href)">
        <item>
          <xsl:value-of select="count(//tei:u[key('ref', @who, $head)/tei:affiliation/@role='MP'])"/>
        </item>
      </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="et:sum($mps/tei:item)"/>
    
    <xsl:value-of select="$col-sep"/>
    <xsl:variable name="heads">
      <xsl:for-each select="document(../xi:include/@href)">
        <item>
          <xsl:value-of select="count(//tei:head)"/>
        </item>
      </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="et:sum($heads/tei:item)"/>
    
    <xsl:value-of select="$col-sep"/>
    <xsl:variable name="notes">
      <xsl:for-each select="document(../xi:include/@href)">
        <item>
          <xsl:value-of select="count(//tei:note)"/>
        </item>
      </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="et:sum($notes/tei:item)"/>
    
    <xsl:value-of select="$col-sep"/>
    <xsl:variable name="incidents">
      <xsl:for-each select="document(../xi:include/@href)">
        <item>
          <xsl:value-of select="count(//tei:*
                                [self::tei:incident or self::tei:vocal or self::tei:kinesic]
                                )"/>
        </item>
      </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="et:sum($incidents/tei:item)"/>
    
    <!--xsl:value-of select="$col-sep"/>
    <xsl:variable name="paragraphs">
      <xsl:for-each select="document(../xi:include/@href)">
        <item>
          <xsl:value-of select="count(//tei:seg)"/>
        </item>
      </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="et:sum($paragraphs/tei:item)"/-->
    
    <xsl:value-of select="$line-sep"/>
  </xsl:template>

  <!-- Count nodes and, if LaTeX, give thousands separator -->
  <xsl:function name="et:sum">
    <xsl:param name="nodes"/>
    <xsl:choose>
      <xsl:when test="matches($mode, 'tex', 'i')">
        <xsl:value-of select="format-number(number(sum($nodes)), '###,###,###,###')"/>
      </xsl:when>
      <xsl:when test="matches($mode, 'tsv', 'i')">
        <xsl:value-of select="sum($nodes)"/>
      </xsl:when>
    </xsl:choose>
  </xsl:function>
</xsl:stylesheet>
