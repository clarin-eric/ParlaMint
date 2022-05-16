<?xml version="1.0" encoding="UTF-8"?>
<!--  -->
<xsl:stylesheet 
    xmlns="http://www.tei-c.org/ns/1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei"
    version="2.0">

  <xsl:output encoding="utf-8" method="text"/>
  <xsl:key name="id" match="tei:*" use="@xml:id"/>
  
  <xsl:variable name="id" select="/tei:*/@xml:id"/>
  <xsl:variable name="root" select="/"/>
  <xsl:variable name="country" select="replace(replace(document-uri(/), '.+/([^/]+)\.xml', '$1'), 'ParlaMint-([^._]+).*', '$1')"/>

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
      <xsl:variable name="local-id" select="substring-after(., '#')"/>
      <xsl:if test="$local-id">
        <xsl:choose>
          <xsl:when test="key('id', $local-id, $root)">
            <xsl:message>
              <xsl:value-of select="$country"/>
              <xsl:text>&#32;</xsl:text>
              <xsl:value-of select="$elem"/>
              <xsl:text>&#32;</xsl:text>
              <xsl:value-of select="$attr"/>
              <!--xsl:text>&#32;</xsl:text>
              <xsl:value-of select="$local-id"/-->
              <xsl:text>&#32;</xsl:text>
              <xsl:value-of select="key('id', $local-id, $root)/name()"/>
            </xsl:message>
          </xsl:when>
          <xsl:otherwise></xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
