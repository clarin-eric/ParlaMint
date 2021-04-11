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
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xsl tei et xs xi"
  version="2.0">

  <!-- Directories must have absolute paths! -->
  <xsl:param name="outDir">.</xsl:param>
  <xsl:param name="anaDir">.</xsl:param>
  <xsl:param name="version">2.0</xsl:param>
  <xsl:param name="type">
    <xsl:choose>
      <xsl:when test="contains(/tei:teiCorpus/@xml:id, '.ana')">ana</xsl:when>
      <xsl:otherwise>txt</xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:output method="xml" indent="yes"/>
  <xsl:preserve-space elements="catDesc seg"/>
  
  <!-- Input directory -->
  <xsl:variable name="inDir" select="replace(base-uri(), '(.*)/.*', '$1')"/>
  <!-- The name of the corpus directory to output to, i.e. "ParlaMint-XX" -->
  <xsl:variable name="corpusDir" select="replace(base-uri(), 
					 '.*?([^/]+)/[^/]+\.[^/]+$', '$1')"/>

  <xsl:variable name="today" select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>
  
  <xsl:variable name="outRoot">
    <xsl:value-of select="$outDir"/>
    <xsl:text>/</xsl:text>
    <xsl:value-of select="$corpusDir"/>
    <xsl:text>/</xsl:text>
    <xsl:value-of select="replace(base-uri(), '.*/(.+)$', '$1')"/>
  </xsl:variable>

  <!-- Gather URIs of component xi + files and map to new files, incl. .ana files -->
  <xsl:variable name="docs">
    <xsl:for-each select="//xi:include">
      <item>
	<xi-orig>
	  <xsl:value-of select="@href"/>
	</xi-orig>
	<url-orig>
	  <xsl:value-of select="concat($inDir, '/', @href)"/>
	</url-orig>
	<url-new>
	  <xsl:value-of select="concat($outDir, '/', $corpusDir, '/', @href)"/>
	</url-new>
	<url-ana>
	  <xsl:value-of select="concat($anaDir, '/', replace(@href, '\.xml', '.ana.xml'))"/>
	</url-ana>
      </item>
      </xsl:for-each>
  </xsl:variable>
  
  <!-- Numbers of words in component .ana files -->
  <xsl:variable name="words">
    <xsl:for-each select="$docs/tei:item">
      <item n="{tei:xi-orig}">
	<xsl:choose>
	  <xsl:when test="$type = 'ana'">
	    <xsl:value-of select="document(tei:url-orig)/tei:TEI/tei:text/
				  count(.//tei:w[not(parent::tei:w)])"/>
	    </xsl:when>
	  <xsl:when test="doc-available(tei:url-ana)">
	    <xsl:value-of select="document(tei:url-ana)/tei:TEI/tei:teiHeader//
				  tei:extent/tei:measure[@unit='words'][1]/@quantity"/>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:message select="concat('ERROR ', /tei:TEI/@xml:id, 
				   ': cannot locate .ana file ', tei:url-ana)"/>
	      <xsl:value-of select="number('0')"/>
	    </xsl:otherwise>
	  </xsl:choose>
	</item>
      </xsl:for-each>
  </xsl:variable>
  
  <!-- Numbers of speeches in component files -->
  <xsl:variable name="speeches">
    <xsl:for-each select="$docs/tei:item">
      <item>
	<xsl:value-of select="document(tei:url-orig)/tei:TEI/tei:teiHeader//
			      tei:extent/tei:measure[@unit = 'speeches'][1]/@quantity"/>
      </item>
    </xsl:for-each>
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
      <xsl:variable name="this" select="tei:xi-orig"/>
      <xsl:message select="concat('INFO: Processing ', $this)"/>
      <xsl:result-document href="{tei:url-new}">
	<xsl:apply-templates mode="comp" select="document(tei:url-orig)/tei:TEI">
	<xsl:with-param name="words" select="$words/tei:item[@n = $this]"/>
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
      <xsl:value-of select="replace(., '.+ ', concat(
			    et:format-number(ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang, $words), 
			    ' '))"/>
      </xsl:if>
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
	    <xsl:value-of select="sum($speeches/tei:item)"/>
	  </xsl:when>
	  <xsl:when test="@unit='words'">
	    <xsl:value-of select="sum($words/tei:item)"/>
	  </xsl:when>
	</xsl:choose>
      </xsl:variable>
      <xsl:attribute name="quantity" select="format-number($quant, '#')"/>
      <xsl:value-of select="replace(., '.+ ', concat(
			    et:format-number(ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang, $quant), 
			    ' '))"/>
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
  
  <xsl:template match="tei:taxonomy[@xml:id = 'UD-SYN']//tei:catDesc/tei:term">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:choose>
	<xsl:when test="contains(., '_')">
	  <xsl:message select="concat('WARN ', /tei:TEI/@xml:id, 
			       ': replacing _ in UD term ', .)"/>
	  <xsl:value-of select="replace(., '_', ':')"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:apply-templates/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
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
  
  <xsl:template match="tei:tagsDecl/tei:namespace">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*"/>
      <xsl:copy-of copy-namespaces="no" select="$tagUsages"/>
    </xsl:copy>
  </xsl:template>
    
  <!-- Insert the opposition parties -->
  <xsl:template match="tei:relation[@name='coalition']">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
    </xsl:copy>
    <relation name="opposition">
      <xsl:attribute name="mutual">
	<xsl:variable name="from-mandate" select="@from"/>
	<xsl:variable name="to-mandate">
	  <xsl:choose>
	    <xsl:when test="@to">
	      <xsl:value-of select="@to"/>
	    </xsl:when>
	    <xsl:otherwise>3000-01-01</xsl:otherwise>
	  </xsl:choose>
	</xsl:variable>
	<xsl:variable name="exclude" select="concat(@mutual, ' ')"/>
	<xsl:variable name="tmp">
	  <xsl:for-each select="ancestor::tei:listOrg//tei:org[@role='politicalParty']">
	    <xsl:if test="not(contains($exclude, concat('#', @xml:id, ' ')))">
	      <xsl:variable name="from-party" select="tei:event[tei:label = 'existence']/@from"/>
	      <xsl:variable name="to-party">
		<xsl:choose>
		  <xsl:when test="tei:event[tei:label = 'existence'][@to]">
		    <xsl:value-of select="tei:event[tei:label = 'existence']/@to"/>
		  </xsl:when>
		  <xsl:otherwise>3000-01-01</xsl:otherwise>
		</xsl:choose>
	      </xsl:variable>
	      <xsl:if test="et:between-dates($from-mandate, $from-party, $to-party)
			    and 
			    et:between-dates($to-mandate, $from-party, $to-party)">
		<xsl:value-of select="concat('#', @xml:id, ' ')"/>
	      </xsl:if>
	    </xsl:if>
	  </xsl:for-each>
	</xsl:variable>
	<xsl:value-of select="replace($tmp, ' $', '')"/>
      </xsl:attribute>
      <xsl:attribute name="from" select="@from"/>
      <xsl:if test="@to">
	<xsl:attribute name="to" select="@to"/>
      </xsl:if>
      <xsl:attribute name="ana" select="@ana"/>
    </relation>
  </xsl:template>
    
  <!-- Fix too long or too short dates a la "2013-10-26T14:00:00" or "2018-02" -->
  <xsl:function name="et:fix-date">
    <xsl:param name="date"/>
    <xsl:choose>
      <xsl:when test="matches($date, '^\d\d\d\d-\d\d-\d\dT.+$')">
	<xsl:value-of select="substring-before($date, 'T')"/>
      </xsl:when>
      <xsl:when test="matches($date, '^\d\d\d\d-\d\d-\d\d$')">
	<xsl:value-of select="$date"/>
      </xsl:when>
      <xsl:when test="matches($date, '^\d\d\d\d-\d\d$')">
	<xsl:value-of select="concat($date, '-01')"/>
      </xsl:when>
      <xsl:when test="matches($date, '^\d\d\d\d$')">
	<xsl:value-of select="concat($date, '-01-01')"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:message terminate="yes">
	  <xsl:text>ERROR: bad date </xsl:text>
	  <xsl:value-of select="$date"/>
	</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- Format number-->
  <xsl:function name="et:format-number" as="xs:string">
    <xsl:param name="lang" as="xs:string"/>
    <xsl:param name="quant"/>
    <xsl:variable name="form" select="format-number($quant, '###,###,###,###')"/>
    <xsl:choose>
      <xsl:when test="$lang = 'fr'">
	<xsl:value-of select="replace($form, ',', ' ')"/>
      </xsl:when>
      <xsl:when test="$lang = 'bg' or 
		      $lang = 'cs' or
		      $lang = 'hr' or
		      $lang = 'hu' or
		      $lang = 'is' or
		      $lang = 'it' or
		      $lang = 'lt' or
		      $lang = 'lv' or
		      $lang = 'pl' or
		      $lang = 'ro' or
		      $lang = 'sl' or
		      $lang = 'tr'
		      ">
	<xsl:value-of select="replace($form, ',', '.')"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$form"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- Is the first date between the following two? -->
  <xsl:function name="et:between-dates" as="xs:boolean">
    <xsl:param name="date" as="xs:string"/>
    <xsl:param name="from" as="xs:string"/>
    <xsl:param name="to" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="xs:date(et:fix-date($date)) &gt;= xs:date(et:fix-date($from)) and
		      xs:date(et:fix-date($date)) &lt;= xs:date(et:fix-date($to))">
	<xsl:value-of select="true()"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="false()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

</xsl:stylesheet>
