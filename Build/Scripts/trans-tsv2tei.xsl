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
  <xsl:key name="orig" match="tei:item" use="@n"/>
  
  <!-- Get country of corpus from filename -->
  <xsl:variable name="country"
                select="replace(base-uri(), 
                        '.+ParlaMint-([A-Z]{2}(-[A-Z0-9]{1,3})?).*', 
                        '$1')"/>
  
  <xsl:variable name="data">
    <list>
      <xsl:variable name="tsv" select="unparsed-text($tsv, 'UTF-8')"/>
      <xsl:for-each select="tokenize($tsv, '&#10;')">
	<xsl:if test="matches(., '\t')">
	  <item n="{substring-before(., '&#9;')}">
	    <xsl:value-of select="substring-after(., '&#9;')"/>
	  </item>
	</xsl:if>
      </xsl:for-each>
    </list>
  </xsl:variable>
  
  <xsl:template match="/">
    <xsl:text>&#10;</xsl:text>
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="tei:orgName[not(tei:*)]">
    <xsl:variable name="default-lang" select="ancestor::tei:*[@xml:lang][1]/@xml:lang"/>
    <xsl:variable name="lang" select="ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang"/>
    <xsl:variable name="full" select="@full"/>
    <xsl:variable name="str" select="normalize-space(.)"/>
    <xsl:choose>
      <!-- Element must have text and 
	   not be in English or already transliterated and
	   not already have a translation to English or transliteration -->
      <xsl:when test="$str and 
		      not($lang != $default-lang or ends-with($lang, '-Latn')) and
		      not(../tei:orgName[@full = $full][@xml:lang != $default-lang] or 
		      ../../tei:orgName[@full = $full][ends-with(@xml:lang, '-Latn')])">
	<xsl:choose>
	  <!-- String is already in Latin, error with language identficication or original! -->
	  <xsl:when test="matches($str, '[A-Za-z]')">
	    <xsl:message select="concat('ERROR: &quot;', $str, '&quot; in orgName ', $full, 
				 ' marked as ', $lang, ' but script is (also) Latin, fixing language to ', 
				 concat($lang, '-Latn'))"/>
	    <xsl:copy>
	      <xsl:apply-templates select="@*"/>
	      <xsl:attribute name="xml:lang" select="concat($lang, '-Latn')"/>
	      <xsl:value-of select="$str"/>
	    </xsl:copy>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:copy-of select="."/>
	    <xsl:variable name="trans" select="key('orig', $str, $data)"/>
	    <xsl:message select="concat('INFO: transliterating orgName ', $full, ' &quot;', $str, '&quot; to &quot;', $trans, '&quot;')"/>
	    <xsl:comment>ADDED:</xsl:comment>
	    <xsl:copy>
	      <xsl:apply-templates select="@*"/>
	      <xsl:attribute name="xml:lang" select="concat($lang, '-Latn')"/>
	      <xsl:value-of select="$trans"/>
	    </xsl:copy>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:when>
      <xsl:otherwise>
	<xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tei:education | tei:occupation | tei:roleName | tei:placeName | tei:label">
    <xsl:choose>
      <xsl:when test="not(tei:*)">
	<xsl:variable name="default-lang" select="ancestor::tei:*[@xml:lang][1]/@xml:lang"/>
	<xsl:variable name="lang" select="ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang"/>
	<xsl:variable name="element" select="name()"/>
	<xsl:variable name="str" select="normalize-space(.)"/>
	<xsl:choose>
	  <!-- Element must have text and 
	       not be in English or already transliterated and
	       not already have a translation to English or transliteration -->
	  <xsl:when test="$str and 
			  not($lang != $default-lang  or ends-with($lang, '-Latn')) and
			  not(../tei:*[name() = $element][@xml:lang != $default-lang ] or 
			  ../tei:*[name() = $element][ends-with(@xml:lang, '-Latn')])">
	    <xsl:choose>
	      <!-- String is already in Latin, error with language identficication or original! -->
	      <xsl:when test="matches($str, '[A-Za-z]')">
		<xsl:message select="concat('ERROR: &quot;', $str, '&quot; in ', $element, 
				     ' marked as ', $lang, ' but script is (also) Latin, fixing language to ', 
				     concat($lang, '-Latn'))"/>
		<xsl:copy>
		  <xsl:apply-templates select="@*"/>
		  <xsl:attribute name="xml:lang" select="concat($lang, '-Latn')"/>
		  <xsl:value-of select="$str"/>
		</xsl:copy>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:copy-of select="."/>
		<xsl:variable name="trans" select="key('orig', $str, $data)"/>
		<xsl:message select="concat('INFO: transliterating ', $element, ' &quot;', $str, '&quot; to &quot;', $trans, '&quot;')"/>
		<xsl:comment>ADDED:</xsl:comment>
		<xsl:copy>
		  <xsl:apply-templates select="@*"/>
		  <xsl:attribute name="xml:lang" select="concat($lang, '-Latn')"/>
		  <xsl:value-of select="$trans"/>
		</xsl:copy>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:copy-of select="."/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:when>
      <xsl:otherwise>
	<xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tei:persName">
    <xsl:variable name="default-lang" select="ancestor::tei:*[@xml:lang][1]/@xml:lang"/>
    <xsl:variable name="lang" select="$default-lang"/>
    <xsl:variable name="element" select="name()"/>
    <xsl:choose>
      <!-- Element must not be in English or already transliterated and
	   not already have a translation to English or transliteration -->
      <xsl:when test="not($lang != $default-lang or ends-with($lang, '-Latn')) and
		      not(../tei:*[name() = $element][@xml:lang != $default-lang ] or 
		      ../tei:*[name() = $element][ends-with(@xml:lang, '-Latn')])">
	<xsl:choose>
	  <!-- Element content is already in Latin, error with language identficication or original! -->
	  <xsl:when test="matches(., '[A-Za-z]')">
	    <xsl:message select="concat('ERROR: &quot;', normalize-space(.), '&quot; in ', $element, 
				 ' marked as ', $lang, ' but script is (also) Latin, fixing language to ', 
				 concat($lang, '-Latn'))"/>
	    <xsl:copy>
	      <xsl:apply-templates select="@*"/>
	      <xsl:attribute name="xml:lang" select="concat($lang, '-Latn')"/>
	      <xsl:apply-templates/>
	    </xsl:copy>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:copy-of select="."/>
	    <xsl:apply-templates mode="trans" select="."/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:when>
      <xsl:otherwise>
	<xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template mode="trans" match="tei:persName">
    <xsl:variable name="lang" select="ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang"/>
    <!--xsl:comment>ADDED:</xsl:comment-->
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="xml:lang" select="concat($lang, '-Latn')"/>
      <xsl:apply-templates mode="trans"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template mode="trans" match="tei:*">
    <xsl:variable name="str" select="normalize-space(.)"/>
    <xsl:variable name="element" select="name()"/>
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:variable name="trans" select="key('orig', $str, $data)"/>
      <xsl:message select="concat('INFO: transliterating ', $element, ' &quot;', $str, '&quot; to &quot;', $trans, '&quot;')"/>
      <!-- GR has all caps names, which is ugly! -->
      <xsl:value-of select="et:capital-case($trans)"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="*">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="*|text()|comment()"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="@*|comment()">
    <xsl:copy/>
  </xsl:template>

  <xsl:function name="et:capital-case">
    <xsl:param name="str"/>
    <xsl:variable name="init" select="substring($str, 1, 1)"/>
    <xsl:variable name="tail" select="substring($str, 2)"/>
    <xsl:value-of select="concat(upper-case($init), lower-case($tail))"/>
  </xsl:function>
</xsl:stylesheet>
