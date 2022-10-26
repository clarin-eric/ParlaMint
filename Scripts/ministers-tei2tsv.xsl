<?xml version="1.0"?>
<!-- Dump all ministers in a corpus as TSV file -->
<!-- Takes as input the ParlaMint root file with XIncludes to all the ParlaMint corpora -->
<!-- Note that this script assumes some constructs to be written in ParlaMint 2.1 way, not V3.0, so this needs to be fixed for the new release! -->
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:tei="http://www.tei-c.org/ns/1.0" 
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:et="http://nl.ijs.si/et" 
  exclude-result-prefixes="#all"
  version="2.0">

  <xsl:import href="parlamint-lib.xsl"/>
  
  <!-- Where the corpora can be found (if relative then to the location of this script). -->
  <xsl:param name="path">../Data</xsl:param>
  
  <!-- Directory where the output TSV files are written to -->
  <xsl:param name="outDir">../Data/Metadata/Ministers</xsl:param>
  
  <!-- Prefix for output files -->
  <xsl:param name="outFilePrefix">ParlaMint_ministers-</xsl:param>
  
  <!-- How many template lines to output for corpora without any ministers -->
  <xsl:param name="maxLines">1</xsl:param>

  <xsl:template match="text()"/>
  <xsl:template match="tei:*"/>
  <xsl:template match="/">
    <xsl:for-each select="//xi:include">
      <!-- We need to prefix $path to @href to point to the actual location of corpus roots -->
      <xsl:variable name="href" select="concat($path, '/', @href)"/>
      <xsl:variable name="country" select="replace(@href, 
					   '.+ParlaMint-([A-Z]{2}(-[A-Z0-9]{1,3})?).*', 
					   '$1')"/>
      <xsl:variable name="outFile" select="concat($outDir, '/', 
					   $outFilePrefix, $country, '.tsv')"/>
      <xsl:message select="concat('INFO: Getting ', $path)"/>
      <xsl:message select="concat('INFO: Creating ', $outFile)"/>
      <xsl:result-document href="{$outFile}" method="text">
	<xsl:text>Country&#9;PersonID&#9;Role&#9;From&#9;To&#9;Gov.&#9;Ministry&#9;Name-xx&#9;Name-en&#9;Comment&#10;</xsl:text>
	<xsl:variable name="content">
	  <xsl:variable name="rootHeader">
	    <xsl:apply-templates mode="XInclude" select="document($href)//tei:teiHeader"/>
	  </xsl:variable>
	  <xsl:apply-templates select="$rootHeader//tei:listPerson/tei:person/
				       tei:affiliation[@role = 'minister']">
	    <xsl:with-param name="country" select="$country"/>
	  </xsl:apply-templates>
	</xsl:variable>
	<xsl:choose>
	  <xsl:when test="normalize-space($content)">
	    <xsl:value-of select="$content"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:for-each select="1 to $maxLines">
	      <xsl:value-of select="concat($country, '&#9;', '-', '&#9;', 'minister', '&#9;', 
		'-', '&#9;', '-', '&#9;', '-', '&#9;', '-', '&#9;', '-', '&#9;', '-', '&#9;', '-', '&#10;')"/>
	    </xsl:for-each>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:result-document>
    </xsl:for-each>
  </xsl:template>
    
  <xsl:template match="tei:affiliation[@role = 'minister']">
    <xsl:param name="country"/>
    <!-- Country / Region -->
    <xsl:value-of select="$country"/>
    <xsl:text>&#9;</xsl:text>
    <!-- Person ID -->
    <xsl:value-of select="ancestor::tei:person/@xml:id"/>
    <xsl:text>&#9;</xsl:text>
    <!-- Affiliation role, fixed to minister -->
    <xsl:text>minister</xsl:text>
    <xsl:text>&#9;</xsl:text>
    <!-- From date -->
    <xsl:choose>
      <xsl:when test="@from">
	<xsl:value-of select="@from"/>
      </xsl:when>
      <xsl:otherwise>-</xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#9;</xsl:text>
    <!-- To date -->
    <xsl:choose>
      <xsl:when test="@to">
	<xsl:value-of select="@to"/>
      </xsl:when>
      <xsl:otherwise>-</xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#9;</xsl:text>
    <!-- Government term, CURRENTLY THE OLD WAY! -->
    <xsl:choose>
      <xsl:when test="@ref">
	<xsl:value-of select="replace(@ref, '#', '')"/>
      </xsl:when>
      <xsl:otherwise>-</xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#9;</xsl:text>
    <!-- Ministry ID -->
    <xsl:choose>
      <xsl:when test="@ana">
	<xsl:value-of select="replace(@ana, '#', '')"/>
      </xsl:when>
      <xsl:otherwise>-</xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#9;</xsl:text>
    <!-- Minister free text in local language, THE OLD WAY! -->
    <xsl:variable name="lang" select="ancestor::tei:teiCorpus/@xml:lang"/>
    <xsl:choose>
      <xsl:when test="ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang = $lang and normalize-space(.)">
	<xsl:value-of select="normalize-space(.)"/>
      </xsl:when>
      <xsl:otherwise>-</xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#9;</xsl:text>
    <!-- Minister free text in English -->
    <xsl:choose>
      <xsl:when test="ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang = 'en' and normalize-space(.)">
	<xsl:value-of select="normalize-space(.)"/>
      </xsl:when>
      <xsl:otherwise>-</xsl:otherwise>
    </xsl:choose>
    <!-- Comment -->
    <xsl:text>&#9;</xsl:text>
    <xsl:text>-</xsl:text>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
</xsl:stylesheet>
