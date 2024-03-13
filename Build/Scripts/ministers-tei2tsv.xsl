<?xml version="1.0"?>
<!-- Dump ministers from a ParlaMint corpus listOrg to TSV file -->
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:tei="http://www.tei-c.org/ns/1.0" 
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:et="http://nl.ijs.si/et" 
  exclude-result-prefixes="#all"
  version="2.0">

  <xsl:import href="parlamint-lib.xsl"/>
  
  <!-- Support XML file with listOrg data -->
  <xsl:param name="xml"/>
  
  <!-- How many template lines to output for corpora without any ministers -->
  <xsl:param name="maxLines">1</xsl:param>

  <xsl:output method="text"/>
  
  <xsl:variable name="listOrg">
    <xsl:if test="not(doc-available($xml))">
      <xsl:message terminate="yes" select="concat('FATAL: Cant find XML document ', $xml)"/>
    </xsl:if>
    <xsl:copy-of select="document($xml)/tei:listOrg"/>
  </xsl:variable>
  
  <xsl:variable name="govtID" select="$listOrg//tei:org[@role = 'government']/@xml:id"/>

  <!-- Top level listPerson/@xml:id should contain name of country or region -->
  <xsl:variable name="country"
                select="replace(/tei:*/@xml:id, 
                        '.*ParlaMint-([A-Z]{2}(-[A-Z0-9]{1,3})?).*', 
                        '$1')"/>
  
  <xsl:template match="text()"/>
  <xsl:template match="tei:*"/>

  <xsl:template match="/">
    <xsl:text>Country&#9;</xsl:text>
    <xsl:text>PersonID&#9;</xsl:text>
    <xsl:text>Role&#9;</xsl:text>
    <xsl:text>From&#9;</xsl:text>
    <xsl:text>To&#9;</xsl:text>
    <xsl:text>GovtTermID&#9;</xsl:text>
    <xsl:text>MinistryID&#9;</xsl:text>
    <xsl:text>orgName-xx&#9;</xsl:text>
    <xsl:text>orgName-en&#9;</xsl:text>
    <xsl:text>URL&#9;</xsl:text>
    <xsl:text>Comment&#10;</xsl:text>
    <xsl:variable name="row">
      <xsl:apply-templates select="//tei:listPerson/tei:person/
                                   tei:affiliation[@role = 'minister']">
        <xsl:with-param name="country" select="$country"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="normalize-space($row)">
        <xsl:value-of select="$row"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="1 to $maxLines">
          <xsl:value-of
	      select="concat($country, 
		      '&#9;', '-',
		      '&#9;', 'minister',
		      '&#9;', '-',
		      '&#9;', '-',
		      '&#9;', '-',
		      '&#9;', '-',
		      '&#9;', '-',
		      '&#9;', '-',
		      '&#9;', '-',
		      '&#9;', '-', 
		      '&#10;')"/>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
    
  <!-- Process 1 minister -->
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
    <!-- We have cases like
         <affiliation role="minister" ref="#GOV_LV" ana="#mstr.landbunadur #mstr.sjavarutvegur #GOV_LV.44">
           <roleName xml:lang="is">Sjávarútvegs- og landbúnaðarráðherra</roleName>
           <roleName xml:lang="en">Minister of Fisheries and Agriculture</roleName>
         </affiliation>
    -->
    <!-- Government term -->
    <xsl:variable name="root" select="/"/>
    <xsl:variable name="pointers" select="normalize-space(string-join(@ana | @ref, ' '))"/>
    <xsl:variable name="gov">
      <xsl:for-each select="tokenize($pointers, ' ')">
	<xsl:if test="key('idr', ., $listOrg)[self::tei:event]">
          <xsl:value-of select="replace(., '#', '')"/>
	</xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="normalize-space($gov)">
        <xsl:value-of select="string-join($gov, '+')"/>
      </xsl:when>
      <xsl:when test="tei:note">
        <xsl:value-of select="tei:note"/>
      </xsl:when>
      <xsl:otherwise>-</xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#9;</xsl:text>
    <!-- Ministry IDs -->
    <xsl:variable name="mini">
      <xsl:for-each select="tokenize($pointers, ' ')">
	<xsl:if test="key('idr', ., $listOrg)[self::tei:org[@role = 'ministry']]">
          <xsl:value-of select="replace(., '#', '')"/>
          <xsl:text>&#32;</xsl:text>
	</xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="normalize-space($mini)">
        <xsl:value-of select="replace(normalize-space($mini), '&#32;', '+')"/>
      </xsl:when>
      <xsl:otherwise>-</xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#9;</xsl:text>
    <xsl:variable name="orgName-xx"  select="tei:orgName[ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang != 'en']"/>
    <xsl:variable name="orgName-en"  select="tei:orgName[ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang = 'en']"/>
    <xsl:variable name="roleName-xx" select="tei:roleName[ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang != 'en']"/>
    <xsl:variable name="roleName-en" select="tei:roleName[ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang = 'en']"/>
    <!-- Minister of which ministry in local language -->
    <xsl:choose>
      <xsl:when test="tei:orgName">
	<xsl:choose>
	  <xsl:when test="$orgName-xx">
            <xsl:value-of select="normalize-space($orgName-xx[1])"/>
	  </xsl:when>
	  <xsl:otherwise>-</xsl:otherwise>
	</xsl:choose>
      </xsl:when>
      <xsl:when test="$roleName-xx">
        <xsl:message select="concat('WARN: ', $country, ' ministry affiliation has roleName, but script outputs orgName, so ignoring ', 
                             $roleName-xx[1])"/>
	<xsl:text>-</xsl:text>
      </xsl:when>
    </xsl:choose>
    <xsl:text>&#9;</xsl:text>
    <!-- Minister free text in English -->
    <xsl:choose>
      <xsl:when test="tei:orgName">
	<xsl:choose>
	  <xsl:when test="$orgName-en">
            <xsl:value-of select="normalize-space($orgName-en)"/>
	  </xsl:when>
	  <xsl:otherwise>-</xsl:otherwise>
	</xsl:choose>
      </xsl:when>
      <xsl:when test="$roleName-en">
        <xsl:message select="concat('WARN: ', $country, ' ministry affiliation has roleName, but script outputs orgName, so ignoring ', 
                             $roleName-en)"/>
	<xsl:text>-</xsl:text>
      </xsl:when>
    </xsl:choose>
    <xsl:text>&#9;</xsl:text>
    <!-- URL -->
    <xsl:choose>
      <xsl:when test="@source">
        <xsl:value-of select="@source"/>
      </xsl:when>
      <xsl:otherwise>-</xsl:otherwise>
    </xsl:choose>
    <!-- Comment -->
    <xsl:text>&#9;</xsl:text>
    <xsl:text>-</xsl:text>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
</xsl:stylesheet>
