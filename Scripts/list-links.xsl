<?xml version="1.0" encoding="UTF-8"?>
<!--  -->
<xsl:stylesheet 
    xmlns="http://www.tei-c.org/ns/1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:et="http://nl.ijs.si/et"
    xmlns:mk="http://ufal.mff.cuni.cz/matyas-kopp"
    exclude-result-prefixes="tei et mk"
    version="2.0">

  <xsl:import href="parlamint-lib.xsl"/>
  
  <xsl:output encoding="utf-8" method="text"/>
  
  <xsl:variable name="id" select="/tei:*/@xml:id"/>
  <xsl:variable name="type" select="/tei:*/name()"/>
  <xsl:variable name="listPrefix">
    <xsl:copy-of select="$rootHeader//tei:listPrefixDef"/>
  </xsl:variable>
  <xsl:variable name="country" select="replace(replace(document-uri(/), 
				       '.+/([^/]+)\.xml', '$1'), 
				       'ParlaMint-([^._]+).*', '$1')"/>

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="text()"/>

  <xsl:template match="tei:*">
    <xsl:apply-templates select="@*"/>
    <xsl:apply-templates/>
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
    <xsl:variable name="attr" select="./name()"/>
    <xsl:variable name="elem" select="./../name()"/>
    <xsl:for-each select="tokenize(.,' ')">
      <xsl:variable name="ptr" select="."/>
      <xsl:variable name="local-id" select="et:ref2id($ptr,$listPrefix)"/>
      <xsl:choose>
        <xsl:when test="matches($ptr, '^https?:') or matches($ptr, '^mailto:') or matches($ptr, '^ftps?:')">
          <xsl:value-of select="mk:print_link($elem,$attr,'url','-',$ptr)"/>
        </xsl:when>
        <xsl:when test="not(normalize-space($local-id))"/>
        <xsl:when test="key('id', $local-id, $rootHeader)">
          <xsl:value-of select="mk:print_link($elem, $attr, 'local',
				key('id', $local-id, $rootHeader)/name(),$ptr)"/>
        </xsl:when>
        <xsl:when test="$rootHeader and key('id', $local-id, $rootHeader)">
          <xsl:value-of select="mk:print_link($elem, $attr, 'external',
				key('id', $local-id, $rootHeader)/name(), $ptr)"/>
        </xsl:when>
      </xsl:choose>
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


  <xsl:function name="mk:print_link">
    <xsl:param name="fromEl"/>
    <xsl:param name="fromAt"/>
    <xsl:param name="targetPlace"/>
    <xsl:param name="toEl"/>
    <xsl:param name="ptr"/>
    <xsl:message>
              <xsl:value-of select="$country"/>
              <xsl:text>&#32;</xsl:text>
              <xsl:value-of select="$type"/>
              <xsl:text>&#32;</xsl:text>
              <xsl:value-of select="$fromAt"/>
              <xsl:text>&#32;</xsl:text>
              <xsl:value-of select="$fromEl"/>
              <xsl:text>&#32;</xsl:text>
              <xsl:value-of select="$toEl"/>
              <xsl:text>&#32;</xsl:text>
              <xsl:value-of select="$targetPlace"/>
              <xsl:text>&#32;</xsl:text>
              <xsl:value-of select="$ptr"/>
    </xsl:message>
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
