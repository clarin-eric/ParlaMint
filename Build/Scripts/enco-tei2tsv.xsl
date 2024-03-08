<?xml version="1.0"?>
<!-- Dump encoder entered political orientations to a TSV file -->
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:tei="http://www.tei-c.org/ns/1.0" 
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:et="http://nl.ijs.si/et" 
  exclude-result-prefixes="#all"
  version="2.0">

  <xsl:output method="text"/>

  <!-- Top level listOrg/@xml:id should contain name of country or region -->
  <xsl:variable name="country"
                select="replace(/tei:*/@xml:id, 
                        '.*ParlaMint-([A-Z]{2}(-[A-Z0-9]{1,3})?).*', 
                        '$1')"/>
  
  <xsl:template match="text()"/>
  <xsl:template match="tei:*"/>
  
  <xsl:template match="/">
    <xsl:text>country&#9;pm_id&#9;lr&#9;encoder&#9;comment&#10;</xsl:text>
    <xsl:apply-templates select="//tei:org[@role = 'politicalParty' or @role = 'parliamentaryGroup']">
      <xsl:sort/>
    </xsl:apply-templates>
  </xsl:template>
    
  <xsl:template match="tei:org">
    <xsl:value-of select="$country"/>
    <xsl:text>&#9;</xsl:text>
    <xsl:variable name="party-label">
      <xsl:variable name="lang" select="ancestor::tei:listOrg/@xml:lang"/>
      <xsl:variable name="abbr-id" select="lower-case(
					   replace(
					   replace(
					   replace(
					   replace(@xml:id, 
					   'parliamentaryGroup\.', ''),
					   'politicalParty\.', ''),
					   'Party\.', ''),
					   'party\.', '')
					   )"/>
      <xsl:variable name="abbr-id2" select="replace($abbr-id, '\..*', '')"/>
      <xsl:variable name="name-xx-abb" select="tei:orgName[@full = 'abb' or @full = 'init']
                                               [ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang = $lang]"/>
      <xsl:variable name="name-en-abb" select="tei:orgName[@full = 'abb' or @full = 'init']
                                               [ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang = 'en']"/>
      <xsl:if test="$name-xx-abb[2]">
        <xsl:message select="concat('ERROR: more than one abbrev party name in local language for ', 
                             @xml:id, ': ', $name-xx-abb[1], ' + ', $name-xx-abb[2])"/>
      </xsl:if>
      <xsl:if test="$name-en-abb[2]">
        <xsl:message select="concat('ERROR: more than one abbrev party name in English language for ', 
                             @xml:id, ': ', $name-en-abb[1], ' + ', $name-en-abb[2])"/>
      </xsl:if>
      <xsl:choose>
	<xsl:when test="normalize-space($name-xx-abb[1])">
	<xsl:value-of select="$name-xx-abb[1]"/>
	</xsl:when>
	<xsl:when test="normalize-space($name-en-abb[1])">
	  <xsl:value-of select="$name-en-abb[1]"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$abbr-id"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:value-of select="$party-label"/>
    <xsl:text>&#9;</xsl:text>
      
    <xsl:variable name="state">
      <xsl:choose>
	<!-- Old way of encoding this info -->
	<xsl:when test="tei:state[@type = 'politicalOrientation' and @subtype = 'unknown']">
	  <xsl:copy-of select="tei:state[@type = 'politicalOrientation' and @subtype = 'unknown']"/>
	</xsl:when>
	<!-- New way of encoding this info -->
	<xsl:when test="tei:state[@type = 'politicalOrientation']/tei:state[@type = 'encoder']">
	  <xsl:copy-of select="tei:state[@type = 'politicalOrientation']/tei:state[@type = 'encoder']"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:message select="concat('WARN: No encoder political orientation found for ', 
			       $country, ' ' , $party-label, ' (', @xml:id, ')')"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="et:output(replace($state/tei:state/@ana, '.+?\.', ''))"/>
    <xsl:text>&#9;</xsl:text>
    <xsl:choose>
      <xsl:when test="$state/tei:state/@source">
	<xsl:value-of select="et:output(replace($state/tei:state/@source, '#', ''))"/>
      </xsl:when>
      <xsl:when test="$country = 'BE' and $state/tei:state">GrietDepoorter</xsl:when>
      <xsl:when test="$country = 'PT' and $state/tei:state">AmáliaMendes</xsl:when>
      <xsl:otherwise>
	<xsl:if test="$state/tei:state">
	  <xsl:message select="concat('ERROR: No encoder ID found for ', 
			       $country, ' ' , $party-label, ' (', @xml:id, ')')"/>
	</xsl:if>
	<xsl:text>-</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#9;</xsl:text>
    <xsl:value-of select="et:output($state/tei:state/tei:note)"/>
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
