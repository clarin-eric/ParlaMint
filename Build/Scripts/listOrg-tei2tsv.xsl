<?xml version="1.0"?>
<!-- Outoput information on ParlaMint organisations as TSV file -->
<!-- Expects ParlaMint.xml (for all corpora) or ParlaMint-XX.xml (for one corpus) as input -->
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:tei="http://www.tei-c.org/ns/1.0" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:et="http://nl.ijs.si/et" 
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all"
  version="2.0">

  <xsl:import href="parlamint-lib.xsl"/>
  
  <xsl:output method="text"/>
  
  <xsl:template match="text()"/>
  <xsl:template match="tei:*">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="/">
    <xsl:call-template name="header-row"/>
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="tei:teiCorpus[@xml:id = 'ParlaMint' or @xml:id = 'ParlaMint.ana']">
    <xsl:for-each select="xi:include">
      <xsl:apply-templates select="document(@href)/tei:teiCorpus"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="tei:teiCorpus">
    <!-- Top level @xml:id should contain name of country or region -->
    <xsl:variable name="country"
                  select="replace(@xml:id, 
                          '.*ParlaMint-([A-Z]{2}(-[A-Z0-9]{1,3})?)', 
                          '$1')"/>
    <xsl:variable name="lang" select="@xml:lang" as="xs:string"/>
    <xsl:message select="concat('INFO: Converting ', @xml:id, 
                         ' (', $country, '/', $lang, ') to metadata TSV')"/>
    <!-- Expand the teiHeader so that it includes taxonomies and all elements have @xml:lang -->
    <xsl:variable name="document">
      <xsl:apply-templates mode="expand" select="//tei:teiHeader">
        <xsl:with-param name="lang" select="$lang"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:apply-templates select="$document//tei:listOrg">
      <xsl:with-param name="country" select="$country"/>
      <xsl:with-param name="lang" select="$lang"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="tei:listOrg">
    <xsl:param name="country"/>
    <xsl:param name="lang"/>
    <xsl:apply-templates select=".//tei:org">
      <xsl:with-param name="country" select="$country"/>
      <xsl:with-param name="lang" select="$lang"/>
    </xsl:apply-templates>
  </xsl:template>
    
  <xsl:template match="tei:org">
    <xsl:param name="country"/>
    <xsl:param name="lang"/>
    <xsl:variable name="AbbrName">
      <xsl:call-template name="orgName">
        <xsl:with-param name="org" select="."/>
        <xsl:with-param name="full">abb</xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="FullName">
      <xsl:call-template name="orgName">
        <xsl:with-param name="org" select="."/>
        <xsl:with-param name="full">yes</xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="Orientation-LR">
      <xsl:variable name="orientation" select="tei:state[@type = 'politicalOrientation']"/>
      <xsl:choose>
        <xsl:when test="$orientation/tei:state[@type = 'Wikipedia']">
          <xsl:value-of select="et:l10n($lang, 
                                key('idr', $orientation/tei:state[@type = 'Wikipedia']/@ana)
                                /tei:catDesc)/tei:term"/>
        </xsl:when>
        <xsl:when test="$orientation/tei:state[@type = 'encoder']">
          <xsl:value-of select="et:l10n($lang, 
                                key('idr', $orientation/tei:state[@type = 'encoder']/@ana)
                                /tei:catDesc)/tei:term"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>    
    <!-- Get Wikipedia URL from <idno> or <state> as fall-back -->
    <xsl:variable name="Wikipedia">
      <xsl:variable name="idnos" select="tei:idno[@type = 'URI' and @subtype = 'wikimedia']
                                         [contains(., 'wikipedia')]"/>
      <xsl:variable name="idno-en" select="$idnos[@xml:lang='en' or contains(., '/en.')]"/>
      <xsl:variable name="idno-xx" select="$idnos[@xml:lang=$lang or contains(., concat('/', $lang, '.'))]"/>
      <xsl:choose>
        <xsl:when test="$out-lang = 'en' and $idno-en">
          <xsl:value-of select="$idno-en"/>
        </xsl:when>
        <xsl:when test="$out-lang = 'xx' and $idno-xx">
          <xsl:value-of select="$idno-xx"/>
        </xsl:when>
        <xsl:when test=".//tei:state[@type = 'Wikipedia'][@source]">
          <xsl:value-of select=".//tei:state[@type = 'Wikipedia']/@source"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:value-of select="concat($country, '&#9;')"/>
    <xsl:value-of select="concat(@role, '&#9;')"/>
    <xsl:value-of select="concat(@xml:id, '&#9;')"/>
    <xsl:value-of select="concat(et:tsv-value($AbbrName), '&#9;')"/>
    <xsl:value-of select="concat(et:tsv-value($FullName), '&#9;')"/>
    <xsl:value-of select="concat(et:tsv-value(tei:event[tei:label = 'existence']/@from), '&#9;')"/>
    <xsl:value-of select="concat(et:tsv-value(tei:event[tei:label = 'existence']/@to), '&#9;')"/>
    <xsl:value-of select="concat(et:tsv-value($Orientation-LR), '&#9;')"/>
    <xsl:value-of select="concat(et:tsv-value($Wikipedia), '&#9;')"/>
    <xsl:value-of select="et:tsv-value(tei:state[@type='CHES']/@key)"/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template name="header-row">
    <xsl:text>Country&#9;</xsl:text>
    <xsl:text>orgType&#9;</xsl:text>
    <xsl:text>orgID&#9;</xsl:text>
    <xsl:text>AbbrName&#9;</xsl:text>
    <xsl:text>FullName&#9;</xsl:text>
    <xsl:text>From&#9;</xsl:text>
    <xsl:text>To&#9;</xsl:text>
    <xsl:text>Orientation-LR&#9;</xsl:text>
    <xsl:text>Wikipedia&#9;</xsl:text>
    <xsl:text>CHES-ID</xsl:text>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
  
</xsl:stylesheet>
