<?xml version='1.0' encoding='UTF-8'?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:et="http://nl.ijs.si/et" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xsl tei et xs xi"
  version="2.0">
  
  <!-- File with TSV data -->
  <xsl:param name="tsv"/>

  <xsl:output method="xml" indent="yes" omit-xml-declaration="no"/>
  <xsl:preserve-space elements="catDesc"/>

  <xsl:key name="id" match="tei:item" use="@xml:id"/>
  
  <!-- Parse TSV into a list with -->
  <xsl:variable name="map">
    <xsl:variable name="tsv" select="unparsed-text($tsv, 'UTF-8')"/>
    <list>
      <xsl:for-each select="tokenize($tsv, '&#10;')">
	<xsl:if test="matches(., '\t')">
	  <item xml:id="{substring-before(., '&#9;')}">
	    <xsl:value-of select="normalize-space(substring-after(., '&#9;'))"/>
	  </item>
	</xsl:if>
      </xsl:for-each>
    </list>
  </xsl:variable>
  
  <xsl:template match="/">
    <xsl:text>&#10;</xsl:text>
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="*">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="@*">
    <xsl:copy/>
  </xsl:template>
  
  <xsl:template match="tei:category">
    <xsl:variable name="id" select="@xml:id"/>
    <xsl:variable name="item" select="key('id', $id, $map)"/>
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="$item/self::tei:item">
	<xsl:attribute name="n" select="$item"/>
      </xsl:if>
      <xsl:apply-templates select="tei:catDesc"/>
      <xsl:choose>
	<xsl:when test="tei:category">
	  <xsl:apply-templates select="tei:category"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:call-template name="subcat">
	    <xsl:with-param name="id" select="concat(@xml:id, 'n')"/>
	  </xsl:call-template>
	  <xsl:call-template name="subcat">
	    <xsl:with-param name="id" select="concat(@xml:id, 'nn')"/>
	  </xsl:call-template>
	  <xsl:call-template name="subcat">
	    <xsl:with-param name="id" select="concat(@xml:id, 'p')"/>
	  </xsl:call-template>
	  <xsl:call-template name="subcat">
	    <xsl:with-param name="id" select="concat(@xml:id, 'pp')"/>
	  </xsl:call-template>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template name="subcat">
    <xsl:param name="id"/>
    <xsl:param name="catDesc" select="tei:catDesc"/>
    <xsl:variable name="item" select="key('id', $id, $map)"/>
    <xsl:choose>
      <!-- Subcategory plus already exists -->
      <xsl:when test="tei:category[@xml:id = $id]">
	<xsl:message select="concat('ERROR: weird situaton with ', $id, ' for catDesc ', $catDesc)"/>
      </xsl:when>
      <!-- We don't have the subcategory in the taxonomy yet but there are tags that need it -->
      <xsl:when test="$item/self::tei:item">
	<category xml:id="{$id}">
	  <xsl:if test="$item/self::tei:item">
	    <xsl:attribute name="n" select="$item"/>
	  </xsl:if>
	  <catDesc>
	    <term>
	      <xsl:value-of select="replace(replace($id, 'p', '+'), 'n', '-')"/>
	    </term>
	    <xsl:value-of select="normalize-space($catDesc/tei:term/following-sibling::text())"/>
	    <xsl:choose>
	      <xsl:when test="ends-with($id, 'ppp') or ends-with($id, 'nnn')">, superlative</xsl:when>
	      <xsl:when test="ends-with($id, 'pp' ) or ends-with($id, 'nn' )">, comparative</xsl:when>
	      <xsl:otherwise>
		<xsl:message select="concat('ERROR: bad new category ', $id, ' for catDesc ', $catDesc)"/>
		<xsl:text>, ???</xsl:text>
	      </xsl:otherwise>
	    </xsl:choose>
	  </catDesc>
	</category>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
