<?xml version="1.0"?>
<!-- Finalize the encoding of a ParlaMint corpus -->
<!-- Takes root file as input, and outputs it and all finalized component files to outDir:
     - set release date to today
     - set version to 2.0
     - get rid of spurious handle ref
     - get rid of spurious spaces
     - do extents and tagcounts, warn if changed
     - insert word extents from ana
     - do opposition relations if coalitions exists

Have separate finalize for ana: change UD terms for extended relations
-->
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:et="http://nl.ijs.si/et" 
  exclude-result-prefixes="xsl tei et xi"
  version="2.0">

  <xsl:param name="version">2.0</xsl:param>
  <xsl:param name="outDir">.</xsl:param>
  <xsl:param name="anaDir">.</xsl:param>


  <!-- The name of the corpus directory to output to, i.e. "ParlaMint-XX" -->
  <xsl:variable name="corpusDir" select="replace(base-uri(), 
					 '.*?([^/]+)/[^/]+\.[^/]+$', '$1')"/>

  <!-- Path from bin/ to component files -->
  <xsl:variable name="trueInDir">
    <xsl:text>../</xsl:text>
    <xsl:value-of select="$corpusDir"/>
  </xsl:variable>
  <xsl:variable name="trueAnaDir">
    <xsl:text>../</xsl:text>
    <xsl:value-of select="$anaDir"/>
  </xsl:variable>

  
  <xsl:variable name="today" select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>
  <xsl:output method="xml" indent="yes"/>
  <xsl:preserve-space elements="catDesc seg"/>
  
  <xsl:variable name="trueOutDir">
    <xsl:value-of select="$outDir"/>
    <xsl:text>/</xsl:text>
    <xsl:value-of select="$corpusDir"/>
  </xsl:variable>
  <xsl:variable name="outRoot">
    <xsl:value-of select="$trueOutDir"/>
    <xsl:text>/</xsl:text>
    <xsl:value-of select="replace(base-uri(), '.*?([^/]+)$', '$1')"/>
  </xsl:variable>

  <!-- Gather URIs of component xi + files and map to new files, incl. .ana files -->
  <xsl:variable name="docs">
    <xsl:for-each select="//xi:include">
      <item>
	<xi-orig>
	  <xsl:value-of select="@href"/>
	</xi-orig>
	<url-orig>
	  <xsl:value-of select="concat($trueInDir, '/', @href)"/>
	</url-orig>
	<url-new>
	  <xsl:value-of select="concat($trueOutDir, '/', @href)"/>
	</url-new>
	<url-ana>
	  <xsl:value-of select="concat($trueAnaDir, '/', replace(@href, '\.xml', '.ana.xml'))"/>
	</url-ana>
      </item>
      </xsl:for-each>
  </xsl:variable>
  
  <!-- Get number of speeches in component files -->
  <xsl:variable name="speech_n">
    <xsl:variable name="ns">
      <xsl:for-each select="$docs/tei:item/tei:url-orig/document(.)/tei:TEI/tei:teiHeader//
			    tei:extent/tei:measure[@xml:lang = 'en'][@unit = 'speeches']">
	<item>
	  <xsl:value-of select="@quantity"/>
	</item>
      </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="sum($ns/tei:item)"/>
  </xsl:variable>
  
  <!-- Get tagUsages in component files -->
  <xsl:variable name="tagUsages">
    <xsl:variable name="tUs">
      <xsl:for-each select="$docs/tei:item/document(tei:url-orig)/
			    tei:TEI/tei:teiHeader//tei:tagUsage">
	<xsl:sort select="@gi"/>
	<xsl:copy-of select="."/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:for-each select="$tUs/tei:tagUsage">
      <xsl:variable name="gi" select="@gi"/>
      <xsl:if test="not(following-sibling::tei:tagUsage[@gi = $gi])">
	<xsl:variable name="occurences">
	  <xsl:for-each select="$tUs/tei:tagUsage[@gi = $gi]">
	    <item>
	      <xsl:value-of select="@occurs"/>
	    </item>
	  </xsl:for-each>
	</xsl:variable>
        <tagUsage xmlns="http://www.tei-c.org/ns/1.0" gi="{$gi}"
		  occurs="{format-number(sum($occurences/tei:item), '#')}"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>
  
  <xsl:template match="/">
    <!-- Process component files -->
    <xsl:for-each select="$docs//tei:item">
      <xsl:message select="concat('INFO: ', tei:xi-orig, ' to ', tei:url-new)"/>
      <xsl:variable name="words">
	<xsl:choose>
	  <xsl:when test="doc-available(tei:url-ana)">
	    <xsl:value-of select="document(tei:url-ana)/tei:TEI/tei:teiHeader//
				  tei:extent/tei:measure[@unit='words'][1]/@quantity"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:message select="concat('ERROR ', /tei:TEI/@xml:id, 
				 ': cannot locate .ana file ', tei:url-ana)"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:variable>
      <xsl:result-document href="{tei:url-new}">
	<xsl:apply-templates mode="comp" select="document(tei:url-orig)/tei:TEI">
	  <xsl:with-param name="words" select="$words"/>
	</xsl:apply-templates>
      </xsl:result-document>
    </xsl:for-each>
    
    <!-- Output Root file -->
    <xsl:message>INFO: processing root </xsl:message>
    <xsl:result-document href="{$outRoot}">
      <xsl:apply-templates/>
    </xsl:result-document>
  </xsl:template>

  <xsl:template mode="comp" match="*">
    <xsl:param name="words"/>
    <xsl:copy>
      <xsl:apply-templates mode="comp" select="@*"/>
      <xsl:apply-templates mode="comp">
	<xsl:with-param name="words" select="$words"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  <xsl:template mode="comp" match="@*">
    <xsl:copy/>
  </xsl:template>

  <xsl:template mode="comp" match="tei:publicationStmt/tei:date">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="when" select="$today"/>
      <xsl:value-of select="format-date(current-date(), '[MNn] [D], [Y]')"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="comp" match="tei:extent/tei:measure[@unit='words']">
    <xsl:param name="words"/>
    <xsl:variable name="old-words" select="@quantity"/>
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="normalize-space($words)">
	<xsl:attribute name="quantity" select="$words"/>
	<xsl:if test="$old-words != $words">
	  <xsl:message select="concat('WARN ', /tei:TEI/@xml:id, 
			       ': replacing words ', $old-words, ' with ', $words)"/>
	</xsl:if>
	<xsl:value-of select="replace(., '\d+', $words)"/>
      </xsl:if>
    </xsl:copy>
  </xsl:template>  
  <xsl:template mode="comp" match="tei:editionStmt/tei:edition">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="$version != .">
	<xsl:message select="concat('WARN ', /tei:TEI/@xml:id, 
			     ': replacing version ', ., ' with ', $version)"/>
      </xsl:if>
      <xsl:value-of select="$version"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="comp" match="tei:publicationStmt[tei:idno]/
		       tei:pubPlace[tei:ref[matches(@target, 'hdl.handle.net')]]">
    <xsl:message select="concat('INFO ', /tei:TEI/@xml:id, 
			 ': deleting redundant handle pubPlace')"/>
  </xsl:template>
  
  <!-- Remove leading, trailing and multiple spaces -->
  <xsl:template mode="comp" match="text()[normalize-space(.)]">
    <xsl:variable name="str" select="replace(., '\s+', ' ')"/>
    <xsl:choose>
      <xsl:when test="(not(preceding-sibling::tei:*) and matches($str, '^ ')) and 
		      (not(following-sibling::tei:*) and matches($str, ' $'))">
	<xsl:value-of select="replace($str, '^ (.+?) $', '$1')"/>
      </xsl:when>
      <xsl:when test="not(preceding-sibling::tei:*) and matches($str, '^ ')">
	<xsl:value-of select="replace($str, '^ ', '')"/>
      </xsl:when>
      <xsl:when test="not(following-sibling::tei:*) and matches($str, ' $')">
	<xsl:value-of select="replace($str, ' $', '')"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$str"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- ROOT -->
  <xsl:template match="*">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="@*">
    <xsl:copy/>
  </xsl:template>
  
  <xsl:template match="tei:publicationStmt/tei:date">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="when" select="$today"/>
      <xsl:value-of select="format-date(current-date(), '[MNn] [D], [Y]')"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="tei:editionStmt/tei:edition">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="$version != .">
	<xsl:message select="concat('WARN ', /tei:TEI/@xml:id, 
			     ': replacing version ', ., ' with ', $version)"/>
      </xsl:if>
      <xsl:value-of select="$version"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="tei:revisionDesc">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <change when="{$today}"><name>Tomaž Erjavec</name>: Finalize encoding.</change>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:publicationStmt[tei:idno]/
		       tei:pubPlace[tei:ref[matches(@target, 'hdl.handle.net')]]">
    <xsl:message select="concat('INFO ', /tei:teiCorpus/@xml:id, 
			 ': deleting redundant pubPlace ', .)"/>
  </xsl:template>
  
  <xsl:template match="tei:measure[@unit='words']">
    <xsl:message>WARN: Word extent not yet implemented</xsl:message>
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tei:measure">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:variable name="quant">
	<xsl:choose>
	  <xsl:when test="@unit='sessions'">
	    <xsl:value-of select="count($docs/tei:item)"/>
	  </xsl:when>
	  <xsl:when test="@unit='speeches'">
	    <xsl:value-of select="$speech_n"/>
	  </xsl:when>
	</xsl:choose>
      </xsl:variable>
      <xsl:attribute name="quantity" select="format-number($quant, '#')"/>
      <xsl:variable name="formatted" select="format-number($quant, '###,###,###')"/>
      <xsl:choose>
	<xsl:when test="@xml:lang = 'es'">
	  <xsl:value-of select="replace(., '^\d+', $formatted)"/>
	</xsl:when>
	<xsl:when test="@xml:lang = 'en'">
	  <xsl:value-of select="replace(., '^\d+', replace($formatted, ',', '.'))"/>
	</xsl:when>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tei:tagsDecl/tei:namespace">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*"/>
      <xsl:copy-of copy-namespaces="no" select="$tagUsages"/>
    </xsl:copy>
  </xsl:template>
    
</xsl:stylesheet>
