<?xml version="1.0"?>
<!-- Take root corpus file and output sample in $outDir directory -->
<!-- Script retains first and last component file, and first and last $Range utterances in them -->
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:tei="http://www.tei-c.org/ns/1.0" 
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:et="http://nl.ijs.si/et" 
  exclude-result-prefixes="#all"
  version="2.0">

  <!-- Output directory for samples -->
  <xsl:param name="outDir"/>
  
  <!-- How many TEI files to take -->
  <xsl:param name="Files">5</xsl:param>

  <!-- How many utterances to select from start and end of component files -->
  <xsl:param name="Range">2</xsl:param>

  <!-- Location of the GitHub project containing the output files -->
  <xsl:param name="GitHub-project">https://github.com/clarin-eric/ParlaMint</xsl:param>
  
  <xsl:variable name="today" select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>

  <!-- Select first and last XInclude components -->
  <xsl:variable name="components">
    <xsl:variable name="n" select="count(/tei:teiCorpus/xi:include)"/>
    <xsl:message select="concat('INFO: from ', $n , ' files  selecting ~', $Files, ' files:')"/>
    <xsl:for-each select="//xi:include">
      <xsl:if test="(position()-1) mod floor($n div $Files) = 1">
	<xsl:message select="concat('INFO: selecting file ', @href)"/>
	<xsl:text>&#10;   </xsl:text>
	<xsl:copy-of select="."/>
      </xsl:if>
    </xsl:for-each>
    <xsl:text>&#10;</xsl:text>
  </xsl:variable>

  <xsl:output method="xml" indent="no"/>
  
  <xsl:template match="/">
    <!-- Output root file -->
    <xsl:variable name="inFile" select="replace(document-uri(/), '.+/([^/]+$)', '$1')"/>
    <xsl:result-document href="{$outDir}/{$inFile}" method="xml">
      <xsl:text>&#10;</xsl:text>
      <xsl:apply-templates/>
    </xsl:result-document>
    <!-- Output component file samples -->
    <xsl:variable name="inDir" select="replace(document-uri(/), '/[^/]+$', '')"/>
    <xsl:for-each select="$components/xi:include">
      <xsl:result-document href="{$outDir}/{@href}" method="xml">
	<xsl:apply-templates mode="component" select="document(concat($inDir, '/', @href))"/>
      </xsl:result-document>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template mode="component" match="/">
    <xsl:text>&#10;</xsl:text>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:teiCorpus">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <!-- Fix error from V1: ID != file name for .ana. files -->
      <xsl:attribute name="xml:id" select="replace(document-uri(/), '.+/([^/]+)\.xml', '$1')"/>
      <xsl:text>&#10;   </xsl:text>
      <xsl:apply-templates select="tei:teiHeader"/>
      <xsl:copy-of select="$components"/>
    </xsl:copy>
  </xsl:template>
    
  <xsl:template match="tei:TEI">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <!-- Fix error from V1: ID != file name for .ana. files -->
      <xsl:attribute name="xml:id" select="replace(document-uri(/), '.+/([^/]+)\.xml', '$1')"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
    
  <xsl:template match="tei:titleStmt/tei:title[@type='main']">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:value-of select="replace(., '\]', ' SAMPLE]')"/>
    </xsl:copy>
  </xsl:template>
    
  <xsl:template match="tei:publicationStmt/tei:pubPlace"/>
  <xsl:template match="tei:publicationStmt/tei:idno[@type='handle']">
    <idno type="URL">
      <xsl:value-of select="$GitHub-project"/>
    </idno>
    <xsl:text>&#10;            </xsl:text>
    <pubPlace>
      <ref target="{$GitHub-project}">
	<xsl:value-of select="$GitHub-project"/>
      </ref>
    </pubPlace>
  </xsl:template>
    
  <xsl:template match="tei:publicationStmt/tei:date">
    <xsl:copy>
      <xsl:attribute name="when" select="$today"/>
      <xsl:value-of select="$today"/>
    </xsl:copy>
  </xsl:template>
    
  <xsl:template match="tei:sourceDesc">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:text>&#10;            </xsl:text>
      <bibl>
	<title>Multilingual comparable corpora of parliamentary debates ParlaMint 1.0</title>
	<xsl:copy-of select="ancestor::tei:teiHeader//tei:publicationStmt/tei:idno[@type='handle']"/>
      </bibl>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
    
  <xsl:template match="tei:extent | tei:tagsDecl">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:comment>These numbers do not reflect the size of the sample!</xsl:comment>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tei:revisionDesc">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:text>&#10;         </xsl:text>
      <change when="{$today}"><name>Tomaž Erjavec</name>: Made sample.</change>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
    
  <!-- Here we pick the first and last $Range utterances and all
       immediatelly preceding and intervening other elements -->
  <xsl:template match="tei:div[@type='debateSection']">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates>
	<xsl:with-param name="to" select="tei:u[position() = $Range]/@xml:id"/>
      </xsl:apply-templates>
      <xsl:text>&#10;            </xsl:text>
      <gap reason="editorial"><desc xml:lang="en">SAMPLING</desc></gap>
      <xsl:text>&#10;            </xsl:text>
      <xsl:apply-templates>
	<xsl:with-param name="from">
	  <xsl:variable name="all" select="count(tei:u)"/>
	  <xsl:value-of select="tei:u[position() = $all - ($Range - 1)]/@xml:id"/>
	</xsl:with-param>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tei:div[@type='debateSection']/node()">
    <xsl:param name="from">0</xsl:param>
    <xsl:param name="to">0</xsl:param>
    <xsl:if test="($from = '0' and (self::tei:* | following-sibling::tei:*)[@xml:id = $to]) or 
		  ($to   = '0' and (self::tei:* | preceding-sibling::tei:*)[@xml:id = $from])">
      <xsl:choose>
	<xsl:when test="self::tei:*">
	  <xsl:copy>
	    <xsl:apply-templates select="@*"/>
	    <xsl:apply-templates/>
	  </xsl:copy>
	</xsl:when>
	<xsl:when test="self::text()">
	  <xsl:value-of select="."/>
	</xsl:when>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <!-- Fix error from V1: missing @full -->
  <xsl:template match="tei:org/tei:orgName[not(@full)]">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="full">yes</xsl:attribute>
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
