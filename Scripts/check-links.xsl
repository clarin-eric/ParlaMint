<?xml version="1.0" encoding="UTF-8"?>
<!-- Checks if all references in a TEI document have a corresponding @xml:id -->
<!-- As parameter "meta" you can specify the root file with teiHeader for corpora that 
     are too large to load as a single XML document
     The script can be run like this, assuming one has Saxon HE available at /usr/share/java/ 
     and that the program is run from the root repo directory:
     $ java -jar /usr/share/java/saxon-he.jar meta=../ParlaMint-SI/ParlaMint-SI.xml \
       -xsl:check-links.xsl ../ParlaMint-SI/ParlaMint-SI_2014-08-01_SDZ7-Redna-01.xml
-->
<xsl:stylesheet 
    xmlns="http://www.tei-c.org/ns/1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:et="http://nl.ijs.si/et"
    xmlns:tei="http://www.tei-c.org/ns/1.0" 
    exclude-result-prefixes="tei et" 
    version="2.0">

  <xsl:param name="meta"/>
  
  <xsl:output encoding="utf-8" method="text"/>
  <xsl:key name="id" match="tei:*" use="@xml:id"/>
  
  <xsl:variable name="id" select="/tei:*/@xml:id"/>
  
  <xsl:variable name="teiHeader">
    <xsl:if test="normalize-space($meta) and not(doc-available($meta))">
      <xsl:message terminate="yes">
	<xsl:text>ERROR: meta document </xsl:text>
	<xsl:value-of select="$meta"/>
	<xsl:text> not available!</xsl:text>
      </xsl:message>
    </xsl:if>
    <xsl:copy-of select="document($meta)//tei:teiHeader"/>
  </xsl:variable>
  <xsl:variable name="primary" select="/"/>
  <xsl:variable name="listPrefix">
    <xsl:choose>
      <xsl:when test="//tei:teiHeader//tei:listPrefixDef">
	<xsl:copy-of select="//tei:teiHeader//tei:listPrefixDef"/>
      </xsl:when>
      <xsl:when test="$teiHeader//tei:listPrefixDef">
	<xsl:copy-of select="$teiHeader//tei:listPrefixDef"/>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>

  <xsl:template match="/">
    <!--xsl:call-template name="error">
      <xsl:with-param name="severity">INFO</xsl:with-param>
      <xsl:with-param name="msg" select="concat('Checking links in ', 
					 replace(base-uri(), '.+/', ''))"/>
    </xsl:call-template-->
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="text()"/>
  <xsl:template match="tei:*">
    <xsl:apply-templates select="@*"/>
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="@xml:lang">
    <xsl:variable name="lang" select="."/>
    <xsl:if test="(//tei:teiHeader and not(//tei:teiHeader//tei:language[@ident = $lang]))
		  and
		  not($teiHeader//tei:language[@ident = $lang])">
      <xsl:call-template name="error">
	<xsl:with-param name="msg" select="concat('No language definition for ', 
					   parent::tei:*/name(), '/@xml:lang = ', $lang)"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="@*"/>
  <xsl:template match="@active | @adj | @adjFrom | @adjTo | @ana | @calendar | @change |
		       @children | @class | @code | @copyOf | @corresp | @datcat | @datingMethod |
		       @datingPoint | @decls | @domains | @edRef | @end | @exclude | @fVal |
		       @facs | @feats | @filter | @follow | @fromUnit | @given | @hand |
		       @inst | @lemmaRef | @location | @mergedIn | @mutual | @new | @next | @nymRef |
		       @origin | @parent | @parts | @passive | @perf | @period | @prev | @ref |
		       @rendition | @require | @resp | @sameAs | @scheme | @scriptRef | @select |
		       @since | @source | @spanTo | @start | @synch | @target | @targetEnd | 
		       @toUnit | @toWhom | @unitRef | @uri | @url | @valueDatcat | @where |
		       @who | @wit">
    <xsl:variable name="message">
      <xsl:text>ERROR: Can't find local id for </xsl:text>
      <xsl:value-of select="parent::tei:*[1]/name()"/>
      <xsl:text>/@</xsl:text>
      <xsl:value-of select="name()"/>
      <xsl:text>="</xsl:text>
      <xsl:value-of select="."/>
      <xsl:text>"</xsl:text>
    </xsl:variable>
    <xsl:for-each select="tokenize(.,' ')">
      <xsl:variable name="local-id" select="et:ref2id(.,$listPrefix)"/>
      <xsl:if test="normalize-space($local-id)">
	<!--xsl:message>
	    <xsl:value-of select="concat('Info: link ', ., ' local ',$local-id)"/>
	</xsl:message-->
	<xsl:choose>
	  <xsl:when test="not(normalize-space($local-id))"/>
	  <xsl:when test="key('id', $local-id, $primary)"/>
	  <xsl:when test="$teiHeader and key('id', $local-id, $teiHeader)"/>
	  <xsl:otherwise>
	    <xsl:call-template name="error">
	      <xsl:with-param name="msg" select="$message"/>
	    </xsl:call-template>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:function name="et:ref2id">
    <xsl:param name="ptr"/>
    <xsl:param name="listPrefix"/>
    <xsl:choose>
      <!-- Empty pointer -->
      <xsl:when test="not(normalize-space($ptr))">
	<xsl:call-template name="error">
	  <xsl:with-param name="msg">Empty pointer!</xsl:with-param>
	</xsl:call-template>
      </xsl:when>
      <!-- Local pointer -->
      <xsl:when test="matches($ptr, '^#.+')">
	<xsl:value-of select="substring-after($ptr, '#')"/>
      </xsl:when>
      <!-- URL, return nothing -->
      <xsl:when test="matches($ptr, '^https?:') or matches($ptr, '^mailto:') 
		      or matches($ptr, '^ftps?:')">
      </xsl:when>
      <!-- Extended TEI pointer -->
      <xsl:when test="contains($ptr, ':')">
	<xsl:variable name="prefix" select="substring-before($ptr, ':')"/>
	<xsl:variable name="prefixDef" select="$listPrefix//tei:prefixDef[@ident=$prefix]"/>
	<xsl:choose>
	  <xsl:when test="not($prefixDef)">
	    <xsl:call-template name="error">
	      <xsl:with-param name="msg">
		<xsl:text>Extended pointer </xsl:text>
		<xsl:value-of select="$ptr"/>
		<xsl:text> but no prefixDef for prefix </xsl:text>
		<xsl:value-of select="$prefix"/>
		<xsl:text> found!</xsl:text>
	      </xsl:with-param>
	    </xsl:call-template>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:variable name="id" select="substring-after($ptr, ':')"/>
	    <xsl:variable name="xml-ptr"
			  select="replace($id, $prefixDef/@matchPattern, $prefixDef/@replacementPattern)"/>
	    <xsl:value-of select="et:ref2id($xml-ptr, $listPrefix)"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:when>
      <!-- Local filename with extension -->
      <xsl:when test="matches($ptr, '\.....?$')"/>
      <!-- Probably forgotten hash -->
      <xsl:otherwise>
	<xsl:call-template name="error">
	  <xsl:with-param name="msg">
	  <xsl:text>Strange pointer '</xsl:text>
	  <xsl:value-of select="$ptr"/>
	  <xsl:text>'</xsl:text>
	  </xsl:with-param>
	</xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:template name="error">
    <xsl:param name="msg">???</xsl:param>
    <xsl:param name="severity">ERROR</xsl:param>
    <xsl:message>
      <xsl:value-of select="$severity"/>
      <xsl:text>&#32;</xsl:text>
      <xsl:value-of select="$id"/>
      <xsl:text>: </xsl:text>
      <xsl:value-of select="$msg"/>
    </xsl:message>
  </xsl:template>

</xsl:stylesheet>
