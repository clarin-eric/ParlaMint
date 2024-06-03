<?xml version="1.0"?>
<!-- Dump string content of all elements to be transliterated to a TSV file -->
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:tei="http://www.tei-c.org/ns/1.0" 
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:et="http://nl.ijs.si/et" 
  exclude-result-prefixes="#all"
  version="2.0">

  <xsl:output method="text"/>

  <!-- Get country of corpus from filename -->
  <xsl:variable name="country"
                select="replace(base-uri(), 
                        '.*ParlaMint-([A-Z]{2}(-[A-Z0-9]{1,3})?)[^/]*', 
                        '$1')"/>
  
  <xsl:template match="text()"/>
  <xsl:template match="@*"/>
  
  <xsl:template match="/">
    <xsl:if test="not($country eq 'BG' or $country eq 'GR' or $country eq 'UA')">
      <xsl:message terminate="yes" select="concat('FATAL ERROR: Script meant only for BG, GR, UA, not ', $country)"/>
    </xsl:if>
    <xsl:variable name="output">
      <xsl:apply-templates select="//tei:listPerson | //tei:listOrg"/>
    </xsl:variable>
    <xsl:for-each select="distinct-values(tokenize($output, '&#10;'))">
      <xsl:value-of select="."/>
      <xsl:text>&#10;</xsl:text>
    </xsl:for-each>
  </xsl:template>
    
  <xsl:template match="tei:persName">
    <xsl:if test="not(../tei:persName[@xml:lang = 'en'])">
      <xsl:apply-templates/>
    </xsl:if>
  </xsl:template>

  <!-- It's persName that has a sibling, not its children! -->
  <xsl:template match="tei:persName/tei:*">
    <xsl:variable name="lang" select = "ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang"/>
    <xsl:if test="$lang != 'en'">
      <xsl:if test="tei:*">
	<xsl:message terminate="yes" select="concat('FATAL ERROR: nested element in ', name(), ': ', tei:*[1]/name())"/>
      </xsl:if>
      <xsl:value-of select="normalize-space(.)"/>
      <xsl:text>&#10;</xsl:text>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="tei:orgName">
    <xsl:variable name="lang" select="ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang"/>
    <xsl:variable name="full" select="@full"/>
    <xsl:variable name="str" select="normalize-space(.)"/>
    <xsl:choose>
      <xsl:when test="not(tei:*)">
	<!-- Element must have text and 
	     not be in English or already transliterated and
	     not already have a translation to English or transliteration -->
	<xsl:if test="$str and 
		      not($lang = 'en' or ends-with($lang, '-Latn')) and
		      not(../tei:orgName[@full = $full][@xml:lang = 'en'] or 
		      ../tei:orgName[@full = $full][ends-with(@xml:lang, '-Latn')])">
	  <xsl:value-of select="$str"/>
	  <xsl:text>&#10;</xsl:text>
	</xsl:if>
      </xsl:when>
      <xsl:otherwise>
	<xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tei:education | tei:occupation | tei:roleName | tei:placeName | tei:label">
    <xsl:variable name="lang" select="ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang"/>
    <xsl:variable name="element" select="name()"/>
    <xsl:variable name="str" select="normalize-space(.)"/>
    <xsl:choose>
      <xsl:when test="not(tei:*)">
	<!-- Element must have text and 
	     not be in English or already transliterated and
	     not already have a translation to English or transliteration -->
	<xsl:if test="$str and 
		      not($lang = 'en' or ends-with($lang, '-Latn')) and
		      not(../tei:*[name() = $element][@xml:lang = 'en'] or 
		      ../tei:*[name() = $element][ends-with(@xml:lang, '-Latn')])">
	  <xsl:value-of select="$str"/>
	  <xsl:text>&#10;</xsl:text>
	</xsl:if>
      </xsl:when>
      <xsl:otherwise>
	<xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
</xsl:stylesheet>
