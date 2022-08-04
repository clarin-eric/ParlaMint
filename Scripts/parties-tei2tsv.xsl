<?xml version="1.0"?>
<!-- Dump all parliamentary groups and political parties as TSV file for manual editing -->
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:tei="http://www.tei-c.org/ns/1.0" 
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:et="http://nl.ijs.si/et" 
  exclude-result-prefixes="#all"
  version="2.0">

  <!-- Where the corpora can be found (relative to the location of this script). -->
  <xsl:param name="path">../Data</xsl:param>
  <!-- Directory where the output TSV files are written to -->
  <xsl:param name="outDir">../Data/Metadata</xsl:param>
  <!-- How many template lines to output for corpora without any ministers -->
  <xsl:param name="outFilePrefix">ParlaMint_parties-</xsl:param>

  <xsl:template match="text()"/>
  <xsl:template match="tei:*"/>
  <xsl:template match="/">
    <xsl:for-each select="//xi:include">
      <xsl:variable name="href" select="concat($path, '/', @href)"/>
      <xsl:variable name="country" select="replace(@href, 
					   '.+ParlaMint-([A-Z]{2}(-[A-Z0-9]{1,3})?).*', 
					   '$1')"/>
      <xsl:variable name="outFile" select="concat($outDir, '/', 
					   $outFilePrefix, $country, '.tsv')"/>
      <xsl:message select="concat('INFO: Processing ', @href)"/>
      <xsl:result-document href="{$outFile}" method="text">
	<xsl:text>Country&#9;orgType&#9;orgID&#9;Abb-xx&#9;Abb-en&#9;Full-xx&#9;Full-en&#9;From&#9;To&#9;Orientation&#9;Comment&#10;</xsl:text>
	<xsl:apply-templates select="document($href)//tei:particDesc//tei:org
				       [@role = 'parliamentaryGroup' or @role = 'politicalParty']">
	  <xsl:with-param name="country" select="$country"/>
	</xsl:apply-templates>
      </xsl:result-document>
    </xsl:for-each>
  </xsl:template>
    
  <xsl:template match="tei:org">
    <xsl:param name="country"/>
    <xsl:value-of select="$country"/>
    <xsl:text>&#9;</xsl:text>
    <xsl:value-of select="@role"/>
    <xsl:text>&#9;</xsl:text>
    <xsl:value-of select="@xml:id"/>
    <xsl:text>&#9;</xsl:text>
    <xsl:variable name="lang" select="ancestor::tei:teiCorpus/@xml:lang"/>
    <xsl:variable name="name-xx-abb" select="tei:orgName[@full = 'abb']
					 [ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang = $lang]"/>
    <xsl:variable name="name-en-abb" select="tei:orgName[@full = 'abb']
					 [ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang = 'en']"/>
    <xsl:variable name="name-en-full" select="tei:orgName[@full = 'yes']
					 [ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang = 'en']"/>
    <xsl:variable name="name-xx-full" select="tei:orgName[@full = 'yes']
					 [ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang = $lang]"/>
    <!-- Some sanity checks -->
    <xsl:if test="$name-en-full[2]">
	<xsl:message select="concat('ERROR: more than one full party name in English language for ', 
			     @xml:id, ': ', $name-en-full[1], ' + ', $name-en-full[2])"/>
    </xsl:if>
    <xsl:if test="$name-en-abb[2]">
	<xsl:message select="concat('ERROR: more than one abbrev party name in English language for ', 
			     @xml:id, ': ', $name-en-abb[1], ' + ', $name-en-abb[2])"/>
    </xsl:if>
    <xsl:if test="$name-xx-full[2]">
	<xsl:message select="concat('ERROR: more than one full party name in local language for ', 
			     @xml:id, ': ', $name-xx-full[1], ' + ', $name-xx-full[2])"/>
    </xsl:if>
    <xsl:if test="$name-xx-abb[2]">
	<xsl:message select="concat('ERROR: more than one abbrev party name in local language for ', 
			     @xml:id, ': ', $name-xx-abb[1], ' + ', $name-xx-abb[2])"/>
    </xsl:if>
    <xsl:value-of select="et:output($name-xx-abb[1])"/>
    <xsl:text>&#9;</xsl:text>
    <xsl:value-of select="et:output($name-en-abb[1])"/>
    <xsl:text>&#9;</xsl:text>
    <xsl:value-of select="et:output($name-xx-full[1])"/>
    <xsl:text>&#9;</xsl:text>
    <xsl:value-of select="et:output($name-en-full[1])"/>
    <xsl:text>&#9;</xsl:text>
    <xsl:value-of select="et:output(tei:event[tei:label = 'existence']/@from)"/>
    <xsl:text>&#9;</xsl:text>
    <xsl:value-of select="et:output(tei:event[tei:label = 'existence']/@to)"/>
    <xsl:text>&#9;</xsl:text>
    <xsl:text>&#9;</xsl:text>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:function name="et:output">
    <xsl:param name="input"/>
    <xsl:choose>
      <xsl:when test="normalize-space($input)">
	<xsl:value-of select="$input"/>
      </xsl:when>
      <xsl:otherwise>-</xsl:otherwise>
    </xsl:choose>
  </xsl:function>
</xsl:stylesheet>
