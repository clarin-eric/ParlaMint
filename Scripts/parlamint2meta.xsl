<?xml version="1.0"?>
<!-- Transform one ParlaMint file to a TSV file with its metadata. -->
<!-- Includes header row, cf. template for tei:TEI -->
<!-- Needs the file with corpus teiHeader giving the speaker, party etc. info as the "hdr" parameter -->
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

    <xsl:import href="parlamint-lib.xsl"/>
    
    <xsl:output method="text" encoding="utf-8"/>
  
    <!-- Store sub title, if it exists, otherwise main title -->
    <xsl:variable name="title">
      <xsl:variable name="titles" select="/tei:TEI/tei:teiHeader/tei:fileDesc/
					  tei:titleStmt/tei:title"/>
      <xsl:choose>
	<xsl:when test="$titles[@type='sub']
			[ancestor-or-self::tei:*[@xml:lang][1][@xml:lang='en']]">
	  <xsl:value-of select="$titles[@type='sub']
				[ancestor-or-self::tei:*[@xml:lang][1][@xml:lang='en']]
				[1]"/>
	</xsl:when>
	<xsl:when test="$titles[@type='sub']">
	  <xsl:value-of select="$titles[@type='sub'][1]"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$titles[1]"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
  <xsl:template match="tei:TEI">
    <xsl:text>ID&#9;</xsl:text>
    <xsl:text>Title&#9;</xsl:text>
    <xsl:text>From&#9;</xsl:text>
    <xsl:text>To&#9;</xsl:text>
    <xsl:text>House&#9;</xsl:text>
    <xsl:text>Term&#9;</xsl:text>
    <xsl:text>Session&#9;</xsl:text>
    <xsl:text>Meeting&#9;</xsl:text>
    <xsl:text>Sitting&#9;</xsl:text>
    <xsl:text>Agenda&#9;</xsl:text>
    <xsl:text>Subcorpus&#9;</xsl:text>
    <xsl:text>Speaker_role&#9;</xsl:text>
    <xsl:text>Speaker_type&#9;</xsl:text>
    <xsl:text>Speaker_party&#9;</xsl:text>
    <xsl:text>Speaker_party_name&#9;</xsl:text>
    <xsl:text>Party_status&#9;</xsl:text>
    <xsl:text>Speaker_name&#9;</xsl:text>
    <xsl:text>Speaker_gender&#9;</xsl:text>
    <xsl:text>Speaker_birth</xsl:text>
    <!--xsl:text>Tokens</xsl:text-->
    <xsl:text>&#10;</xsl:text>
    <xsl:apply-templates select=".//tei:u"/>
  </xsl:template>
  
  <xsl:template match="tei:u">
    <!-- Text metadata -->
    <xsl:value-of select="concat(@xml:id, '&#9;')"/>
    <xsl:value-of select="concat($title, '&#9;')"/>
    <xsl:value-of select="concat($date-from, '&#9;')"/>
    <xsl:value-of select="concat($date-to, '&#9;')"/>
    <xsl:value-of select="concat($house, '&#9;')"/>
    <xsl:value-of select="concat($term, '&#9;')"/>
    <xsl:value-of select="concat($session, '&#9;')"/>
    <xsl:value-of select="concat($meeting, '&#9;')"/>
    <xsl:value-of select="concat($sitting, '&#9;')"/>
    <xsl:value-of select="concat($agenda, '&#9;')"/>
    <xsl:value-of select="concat($subcorpus, '&#9;')"/>
    <!-- Speaker metadata -->
    <xsl:value-of select="concat(et:u-role(@ana), '&#9;')"/>
    <xsl:choose>
      <xsl:when test="not(@who)">
	<xsl:text>-&#9;</xsl:text>
	<xsl:text>-&#9;</xsl:text>
	<xsl:text>-&#9;</xsl:text>
	<xsl:text>-&#9;</xsl:text>
	<xsl:text>-&#9;</xsl:text>
	<xsl:text>-&#9;</xsl:text>
	<xsl:text>-</xsl:text>
      </xsl:when>
      <xsl:otherwise>
	<xsl:variable name="speaker" select="key('idr', @who, $rootHeader)"/>
	<xsl:if test="not(normalize-space($speaker))">
	  <xsl:message terminate="yes">
	    <xsl:text>FATAL: Can't find speaker for </xsl:text>
	    <xsl:value-of select="@who"/>
	    <xsl:text> in </xsl:text>
	    <xsl:value-of select="@xml:id"/>
	  </xsl:message>
	</xsl:if>
	<xsl:value-of select="concat(et:speaker-type($speaker), '&#9;')"/>
	<xsl:value-of select="concat(et:speaker-party($speaker, 'abb'), '&#9;')"/>
	<xsl:value-of select="concat(et:speaker-party($speaker, 'yes'), '&#9;')"/>
	<xsl:value-of select="concat(et:party-status($speaker), '&#9;')"/>
	<xsl:value-of select="concat(et:format-name($speaker//tei:persName[1]), '&#9;')"/>
	<xsl:choose>
	  <xsl:when test="$speaker/tei:sex">
	    <xsl:value-of select="$speaker/tei:sex/@value"/>
	  </xsl:when>
	  <xsl:otherwise>-</xsl:otherwise>
	</xsl:choose>
	<xsl:text>&#9;</xsl:text>
	<xsl:choose>
	  <xsl:when test="$speaker/tei:birth">
	    <xsl:value-of select="replace($speaker/tei:birth/@when, '-.+', '')"/>
	  </xsl:when>
	  <xsl:otherwise>-</xsl:otherwise>
	</xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
    <!-- Speech sizes -->
    <!--xsl:value-of select="count(.//tei:w) + count(.//tei:pc)"/-->
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

</xsl:stylesheet>
