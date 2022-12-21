<?xml version="1.0"?>
<!-- Dump all ministers in ParlaMint corpora as TSV files, one per corpus -->
<!-- Takes as input the ParlaMint root file with XIncludes to all the ParlaMint corpora -->
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:tei="http://www.tei-c.org/ns/1.0" 
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:et="http://nl.ijs.si/et" 
  exclude-result-prefixes="#all"
  version="2.0">

  <xsl:import href="parlamint-lib.xsl"/>
  
  <!-- Path to where the corpora can be found -->
  
  <!-- Directory where the output TSV files are written to -->
  <xsl:param name="outDir">../Data/Ministers</xsl:param>
  
  <!-- Prefix and sufix for output files -->
  <xsl:param name="outFilePrefix">ParlaMint_ministers-</xsl:param>
  <xsl:param name="outFileSuffix">.auto.tsv</xsl:param>
  
  <!-- How many template lines to output for corpora without any ministers -->
  <xsl:param name="maxLines">1</xsl:param>

  <xsl:template match="text()"/>
  <xsl:template match="tei:*"/>
  
  <xsl:template match="/">
    <xsl:variable name="path" select="replace(base-uri(), '(.+)/.+', '$1')"/>
    <xsl:for-each select="/tei:teiCorpus/xi:include">
      <!-- We need to prefix $path to @href to point to the actual location of corpus roots -->
      <xsl:variable name="href" select="concat($path, '/', @href)"/>
      <xsl:variable name="country" select="replace(@href, 
                                           '.+ParlaMint-([A-Z]{2}(-[A-Z0-9]{1,3})?).*', 
                                           '$1')"/>
      <xsl:message select="concat('INFO: Reading ', $country)"/>
      <xsl:variable name="teiHeader">
	<xsl:apply-templates mode="XInclude" select="document($href)//tei:teiHeader">
	  <xsl:with-param name="lang" select="document($href)/tei:*/@xml:lang"/>
	</xsl:apply-templates>
      </xsl:variable>
      <xsl:variable name="outFile" select="concat($outDir, '/', 
                                           $outFilePrefix, $country, $outFileSuffix)"/>
      <xsl:message select="concat('INFO: Creating ', $outFile)"/>
      <xsl:result-document href="{$outFile}" method="text">
        <xsl:text>Country&#9;PersonID&#9;Role&#9;From&#9;To&#9;Gov.&#9;Ministry&#9;Name-xx&#9;Name-en&#9;URL&#9;Comment&#10;</xsl:text>
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
          <xsl:when test="normalize-space($row)">
            <xsl:value-of select="$row"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:for-each select="1 to $maxLines">
              <xsl:value-of select="concat($country, '&#9;', '-', '&#9;', 'minister', '&#9;', 
                '-', '&#9;', '-', '&#9;', '-', '&#9;', '-', '&#9;', '-', '&#9;', '-', '&#9;', '-', '&#9;', '-', '&#10;')"/>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:result-document>
    </xsl:for-each>
  </xsl:template>
    
  <!-- Process 1 minister -->
  <xsl:template match="tei:affiliation[@role = 'minister']">
    <xsl:param name="country"/>
    <!-- Take the @xml:lang of top-most element as local language -->
    <xsl:variable name="lang" select="ancestor::tei:*[@xml:lang][last()]/@xml:lang"/>
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
    <!-- 2.1 != 3.0 but stylesheet should work for both (for now) -->
    <!-- We have cases like
	 2.1
	 <affiliation role="minister" ref="#GOV_LV.44" ana="#mstr.landbunadur #mstr.sjavarutvegur">
           Sjávarútvegs- og landbúnaðarráðherra
         </affiliation>
	 3.0
         <affiliation role="minister" ref="#GOV_LV" ana="#mstr.landbunadur #mstr.sjavarutvegur #GOV_LV.44">
           <roleName xml:lang="is">Sjávarútvegs- og landbúnaðarráðherra</roleName>
           <roleName xml:lang="en">Minister of Fisheries and Agriculture</roleName>
         </affiliation>
    -->
    <!-- Government term -->
    <xsl:variable name="root" select="/"/>
    <xsl:variable name="pointers" select="string-join(@ana | @ref, ' ')"/>
    <xsl:variable name="gov">
      <xsl:for-each select="tokenize($pointers, ' ')">
	<xsl:if test="key('idr', ., $root)[self::tei:event]">
          <xsl:value-of select="replace(., '#', '')"/>
	</xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="normalize-space($gov)">
        <xsl:value-of select="string-join($gov, '+')"/>
      </xsl:when>
      <xsl:otherwise>-</xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#9;</xsl:text>
    <!-- Ministry IDs -->
    <xsl:variable name="mini">
      <xsl:for-each select="tokenize($pointers, ' ')">
	<xsl:if test="key('idr', ., $root)[self::tei:org[@role = 'ministry']]">
          <xsl:value-of select="replace(., '#', '')"/>
	</xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="normalize-space($mini)">
        <xsl:value-of select="string-join($mini, '+')"/>
      </xsl:when>
      <xsl:otherwise>-</xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#9;</xsl:text>
    <!-- Minister of which ministry in local language -->
    <xsl:choose>
      <!-- How it is done in ParlaMint 3.* -->
      <xsl:when test="tei:roleName">
	<xsl:choose>
	  <xsl:when test="tei:roleName[@xml:lang = $lang]">
            <xsl:value-of select="tei:roleName[@xml:lang = $lang]"/>
	  </xsl:when>
	  <xsl:otherwise>-</xsl:otherwise>
	</xsl:choose>
      </xsl:when>
      <!-- How it is done in ParlaMint 2.* -->
      <xsl:when test="normalize-space(.) and ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang = $lang">
        <xsl:value-of select="."/>
      </xsl:when>
      <xsl:otherwise>-</xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#9;</xsl:text>
    <!-- Minister free text in English -->
    <xsl:choose>
      <!-- How it is done in ParlaMint 3.* -->
      <xsl:when test="tei:roleName">
	<xsl:choose>
	  <xsl:when test="tei:roleName[ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang = 'en']">
            <xsl:value-of select="tei:roleName[ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang = 'en']"/>
	  </xsl:when>
	  <xsl:otherwise>-</xsl:otherwise>
	</xsl:choose>
      </xsl:when>
      <!-- How it is done in ParlaMint 2.* -->
      <xsl:when test="normalize-space(.) and ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang = 'en'">
        <xsl:value-of select="."/>
      </xsl:when>
      <xsl:otherwise>-</xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#9;</xsl:text>
    <xsl:choose>
      <xsl:when test="@source">
        <xsl:value-of select="@source"/>
      </xsl:when>
      <xsl:otherwise>-</xsl:otherwise>
    </xsl:choose>
    <!-- URL, NOT YET IMPLEMENTED! -->
    <xsl:text>&#9;</xsl:text>
    <xsl:text>-</xsl:text>
    <!-- Comment -->
    <xsl:text>&#9;</xsl:text>
    <xsl:text>-</xsl:text>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
</xsl:stylesheet>
