<?xml version='1.0' encoding='UTF-8'?>
<!--
  Input:
  Output:
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="tei">

  <xsl:output method="xml" indent="yes"/>
  <xsl:param name="langs"/><!-- languages to be added, if param missing, all languages except english is added -->
  <xsl:param name="parlamint"/> <!-- source of the translation ParlaMint-XX -->
  <xsl:param name="if-translation-exist">replace</xsl:param> <!-- skip -->
  <xsl:param name="translation-input"/> <!-- taxonomy with translation -->
  <xsl:variable name="languages" select="tokenize($langs, '\s+')"/>

  <xsl:variable name="template">
    <xsl:copy-of select="/"/>
  </xsl:variable>

  <xsl:variable name="translation">
    <xsl:if test="not(doc-available($translation-input))">
      <xsl:message terminate="yes" select="concat('FATAL ERROR: translation file ', $translation-input, ' not found')"/>
    </xsl:if>
    <xsl:copy-of select="document($translation-input)"/>
  </xsl:variable>

  <xsl:variable name="updated-languages">
    <xsl:choose>
      <xsl:when test="normalize-space($langs)">
        <xsl:for-each select="distinct-values(tokenize(normalize-space($langs),' '))">
          <xsl:if test="not(. = '-')">
            <item xml:lang="{.}"/>
          </xsl:if>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="distinct-values($translation//@xml:lang[not(.='en') and not(.='mul')])">
          <item xml:lang="{.}"/>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>


  <xsl:variable name="all-languages">
    <xsl:for-each select="distinct-values($template//@xml:lang[not(.='en') and not(.='mul')] | $updated-languages//@xml:lang)">
      <xsl:sort select="."/>
      <item xml:lang="{.}"/>
    </xsl:for-each>
  </xsl:variable>

  <xsl:template match="/">
    <xsl:message>INFO: languages to be added <xsl:value-of select="string-join($updated-languages/item/@xml:lang,' ')"/></xsl:message>
    <xsl:message>INFO: all languages <xsl:value-of select="string-join($all-languages/item/@xml:lang,' ')"/></xsl:message>
    <xsl:apply-templates select="$template" mode="template"/>
  </xsl:template>

  <xsl:template match="tei:taxonomy | tei:category" mode="template">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="(tei:catDesc | tei:desc )[@xml:lang = 'en']" mode="template"/>
      <xsl:apply-templates select="tei:category" mode="template"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:desc[@xml:lang = 'en'] | tei:catDesc[@xml:lang = 'en']" mode="template">
    <xsl:copy-of select="."/>
    <xsl:variable name="term" select="./descendant::tei:term/text()"/>
    <xsl:variable name="element-name" select="local-name()"/>
    <xsl:variable name="parent-template" select="./parent::tei:*"/>
    <xsl:variable name="id" select="$parent-template/@xml:id"/>
    <xsl:if test="not($id)">
      <xsl:message terminate="yes">ERROR: parent does not have id</xsl:message>
    </xsl:if>
    <xsl:variable name="parent-translation" select="$translation//tei:*[@xml:id = $id]"/>
    <xsl:if test="not($parent-translation)">
      <xsl:message>WARN: <xsl:value-of select="$id"/> not found in <xsl:value-of select="$translation-input"/></xsl:message>
    </xsl:if>
    <xsl:for-each select="$all-languages/item">
      <xsl:variable name="lang" select="@xml:lang"/>
      <xsl:variable name="element-template" select="$parent-template/tei:*[@xml:lang = $lang
                                                                           and local-name() = $element-name
                                                                           ][1]"/>
      <xsl:variable name="element-translation" select="$parent-translation/tei:*[@xml:lang = $lang
                                                                                 and local-name() = $element-name
                                                                                 and $updated-languages/item[@xml:lang = $lang]
                                                                                 ][1]"/>
      <xsl:variable name="element-translation-skipped" select="$parent-translation/tei:*[@xml:lang = $lang
                                                                                 and local-name() = $element-name
                                                                                 and not($updated-languages/item[@xml:lang = $lang])
                                                                                 ][1]"/>
      <xsl:if test="$element-translation-skipped">
        <xsl:variable name="element-translation-skipped-fin"><xsl:apply-templates select="$element-translation-skipped" mode="translate"/></xsl:variable>
        <xsl:message>WARN: skipping translation of not allowed language <xsl:value-of select="$lang"/>: <xsl:apply-templates select="$element-translation-skipped-fin" mode="serialize"/></xsl:message>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="$element-translation and $element-template and $if-translation-exist = 'replace'">
          <xsl:variable name="element-template-serialized"><xsl:apply-templates select="$element-template" mode="serialize"/></xsl:variable>
          <xsl:variable name="element-translation-serialized">
            <xsl:variable name="element-translation-fin"><xsl:apply-templates select="$element-translation" mode="translate"/></xsl:variable>
            <xsl:apply-templates select="$element-translation-fin" mode="serialize"/>
          </xsl:variable>
          <xsl:if test="not($element-translation-serialized = $element-template-serialized)">
            <xsl:message>INFO: replacing existing <xsl:value-of select="$lang"/> transtation for <xsl:value-of select="$id"/></xsl:message>
            <xsl:message>INFO: old <xsl:value-of select="$element-template-serialized"/></xsl:message>
            <xsl:message>INFO: new <xsl:value-of select="$element-translation-serialized"/></xsl:message>
          </xsl:if>
          <xsl:apply-templates select="$element-translation" mode="translate"/>
        </xsl:when>
        <xsl:when test="$element-template">
          <xsl:if test="$element-translation and $if-translation-exist = 'skip'">
            <xsl:message>INFO: skipping replacing existing <xsl:value-of select="$lang"/> transtation for <xsl:value-of select="$id"/></xsl:message>
          </xsl:if>
          <xsl:copy-of select="$element-template"/>
        </xsl:when>
        <xsl:when test="$element-translation"><xsl:apply-templates select="$element-translation" mode="translate"/></xsl:when>
        <xsl:when test="$updated-languages/item[@xml:lang = $lang]">
          <xsl:comment>Corpus <xsl:value-of select="$parlamint"/> is missing <xsl:value-of select="$lang"/> translation of <xsl:value-of select="$term"/></xsl:comment>
          <xsl:message>WARN: missing <xsl:value-of select="$lang"/> translation for <xsl:value-of select="$id"/></xsl:message>
        </xsl:when>
      </xsl:choose>
      <xsl:for-each select="$parent-template/comment()[
                                       contains(.,concat('missing ',$lang,' translation'))
                                       and not( contains(.,concat($parlamint,' ')) )
                                      ]">
        <xsl:sort select="."/>
        <xsl:comment><xsl:value-of select="."/></xsl:comment>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="tei:*" mode="translate">
    <xsl:copy>
      <xsl:if test="$parlamint"><xsl:attribute name="n" select="$parlamint"/></xsl:if>
      <xsl:apply-templates select="@*[not(name()='n')]"/>
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


  <xsl:template match="*" mode="serialize">
    <xsl:variable name="e" select="."/>
    <xsl:text>[[</xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:for-each select="$e/@*/name()">
      <xsl:sort select="."/>
      <xsl:variable name="a" select="."/>
      <xsl:apply-templates select="$e/@*[name()=$a]" mode="serialize"/>
    </xsl:for-each>
    <xsl:text>]]</xsl:text>
    <xsl:apply-templates mode="serialize"/>
    <xsl:text>[[/</xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:text>]]</xsl:text>
  </xsl:template>
  <xsl:template match="@*" mode="serialize">
    <xsl:text> </xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:text>="</xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>"</xsl:text>
  </xsl:template>
  <xsl:template match="text()" mode="serialize">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>
</xsl:stylesheet>