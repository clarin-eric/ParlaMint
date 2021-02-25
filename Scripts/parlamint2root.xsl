<?xml version="1.0"?>
<!-- Take template for root ParlaMint corpus file and add info from XIncluded roots -->
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:tei="http://www.tei-c.org/ns/1.0" 
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:et="http://nl.ijs.si/et" 
  exclude-result-prefixes="#all"
  version="2.0">

  <xsl:variable name="today" select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>
  <xsl:output method="xml" indent="yes"/>
  
  <xsl:variable name="docs">
    <list>
      <xsl:for-each select="//xi:include">
	<!-- We need "../" as the this XSLT is in Scripts! -->
	<item>
	  <xsl:value-of select="concat('../', @href)"/>
	</item>
      </xsl:for-each>
    </list>
  </xsl:variable>

  <xsl:template match="tei:titleStmt/tei:respStmt[last()]">
    <xsl:copy-of select="."/>
    <xsl:for-each select="$docs//tei:item">
      <xsl:for-each select="document(.)/tei:teiCorpus">
	<xsl:variable name="corpus" select="@xml:id"/>
	<xsl:for-each select="tei:teiHeader//tei:titleStmt/tei:respStmt">
	  <xsl:copy>
	    <xsl:for-each select="tei:persName[not(@xml:lang) or @xml:lang = 'en']">
	      <xsl:copy>
		<xsl:value-of select="."/>
	      </xsl:copy>
	    </xsl:for-each>
	    <xsl:for-each select="tei:resp[@xml:lang='en']">
	      <xsl:copy>
		<xsl:value-of select="concat($corpus, ': ', .)"/>
	      </xsl:copy>
	    </xsl:for-each>
	  </xsl:copy>
	</xsl:for-each>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>
    
  <xsl:template match="tei:publicationStmt/tei:date">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="when" select="$today"/>
      <xsl:value-of select="$today"/>
    </xsl:copy>
  </xsl:template>
    
  <xsl:template match="tei:extent">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:comment>These numbers do not reflect the size of the sample!</xsl:comment>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tei:tagsDecl">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:comment>These numbers do not reflect the size of the sample!</xsl:comment>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tei:revisionDesc">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <change when="{$today}"><name>Tomaž Erjavec</name>: Made sample.</change>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
    
  <xsl:template match="tei:*">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="@*">
    <xsl:copy/>
  </xsl:template>

</xsl:stylesheet>
