<?xml version="1.0"?>
<!-- Make TSV/LaTeX table with overview info of the ParlaMint corpora -->
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:fn="http://www.w3.org/2005/xpath-functions" 
    xmlns:et="http://nl.ijs.si/et"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xi="http://www.w3.org/2001/XInclude"
    exclude-result-prefixes="fn et tei xs xi"
    version="2.0">

  <xsl:output method="text" encoding="utf-8"/>

  <!-- What to output the table as -->
  <xsl:param name="mode">TeX</xsl:param>

  <!-- Mode dependent colon and line separators -->
  <xsl:variable name="col-sep">
    <xsl:choose>
      <xsl:when test="matches($mode, 'tex', 'i')">
	<xsl:text>&amp;</xsl:text>
      </xsl:when>
      <xsl:when test="matches($mode, 'tsv', 'i')">
	<xsl:text>&#9;</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="line-sep">
    <xsl:choose>
      <xsl:when test="matches($mode, 'tex', 'i')">
	<xsl:text>\\&#10;</xsl:text>
      </xsl:when>
      <xsl:when test="matches($mode, 'tsv', 'i')">
	<xsl:text>&#10;</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>
  
  <!-- If LaTeX -->
  <xsl:param name="preamble">\begin{tabular}{l|c|c|cllr|rr}&#10;</xsl:param>
  <xsl:param name="header-row">
    <xsl:text>ID</xsl:text> <!-- ISO country code -->
    <xsl:value-of select="$col-sep"/>
    <xsl:text>Lang</xsl:text> <!-- ISO language code(s) used (predominantly) -->
    <xsl:value-of select="$col-sep"/>
    <xsl:text>Houses</xsl:text>  <!-- Unicameral, Lower house, Upper house, Both -->
    <xsl:value-of select="$col-sep"/>
    <xsl:text>Ts</xsl:text>  <!-- Terms -->
    <xsl:value-of select="$col-sep"/>
    <xsl:text>From</xsl:text> <!-- Minimum date -->
    <xsl:value-of select="$col-sep"/>
    <xsl:text>To</xsl:text> <!-- Maximum date -->
    <xsl:value-of select="$col-sep"/>
    <xsl:text>Yrs</xsl:text>  <!-- Roughly how many years, e.g 5.3 -->
    <xsl:value-of select="$col-sep"/>
    <xsl:text>Mw/Yr</xsl:text> <!-- Average million words per year -->
    <xsl:value-of select="$col-sep"/>
    <xsl:text>Mw</xsl:text> <!-- Total mill. words -->
    <xsl:value-of select="$line-sep"/>
    <xsl:if test="matches($mode, 'tex', 'i')">\hline&#10;</xsl:if>
  </xsl:param>
  
  <xsl:template match="tei:teiCorpus">
    <xsl:choose>
      <xsl:when test="matches($mode, 'tex', 'i')">
	<xsl:value-of select="$preamble"/>
	<xsl:value-of select="$header-row"/>
      </xsl:when>
      <xsl:when test="matches($mode, 'tsv', 'i')">
	<xsl:value-of select="$header-row"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:message terminate="yes">Parameter 'mode' should be either TSV of TeX.</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
    
    <xsl:variable name="header" select="tei:teiHeader"/>
    <xsl:for-each select="xi:include">
      <xsl:apply-templates select="$header">
	<!-- The corpus IDREF, so we match to @corresp in elements -->
	<xsl:with-param name="corpus">
	  <xsl:text>#</xsl:text>
	  <xsl:value-of select="replace(
				replace(@href, '.+/', ''),
				'\.xml', '')"/>
	</xsl:with-param>
      </xsl:apply-templates>
    </xsl:for-each>
    <xsl:if test="matches($mode, 'tex', 'i')">
      <xsl:text>\end{tabular}&#10;</xsl:text>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="tei:teiHeader">
    <xsl:param name="corpus"/>
    <!-- Corpus -->
    <xsl:value-of select="replace($corpus, '.+-', '')"/>
    <xsl:value-of select="$col-sep"/>
    <!-- Languages -->
    <xsl:variable name="languages">
      <xsl:for-each select=".//tei:langUsage[@corresp=$corpus]/tei:language">
	<xsl:variable name="lang" select="ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang"/>
	<xsl:if test="($lang = 'en' and 
		      not(@ident = 'en' and $corpus != '#ParlaMint-GB') and
		      not(@ident = 'de' and $corpus = '#ParlaMint-BE') and
		      not(@ident = 'fr' and $corpus = '#ParlaMint-BG') and
		      not(@ident = 'bg-Latn' and $corpus = '#ParlaMint-BG'))
		      or (@ident != 'en' and $corpus = '#ParlaMint-HU')
		      or (@ident != 'en' and $corpus = '#ParlaMint-NL')
		      ">
	  <xsl:value-of select="@ident"/>
	  <xsl:text>+</xsl:text>
	</xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="replace($languages, '\+$', '')"/>
    <xsl:value-of select="$col-sep"/>
    <!-- Houses -->
    <xsl:variable name="houses">
      <xsl:for-each select=".//tei:textClass/tei:catRef[@scheme='#parla.legislature'][@corresp=$corpus]
			    /tokenize(@target, ' ')">
	<xsl:choose>
	  <xsl:when test=". = '#parla.uni'">unicameral</xsl:when>
	  <xsl:when test=". = '#parla.lower'">lower+</xsl:when>
	  <xsl:when test=". = '#parla.upper'">upper+</xsl:when>
	</xsl:choose>
      </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="replace($houses, '\+$', '')"/>
    <xsl:value-of select="$col-sep"/>
    <!-- Terms -->
    <xsl:variable name="terms" select="count(.//tei:titleStmt/tei:meeting[@corresp=$corpus]
				       [contains(@ana, 'parla.term')])"/>
    <xsl:choose>
      <xsl:when test="$terms = 0">-</xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$terms"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="$col-sep"/>
    <!-- From and To -->
    <xsl:variable name="date">
      <xsl:choose>
	<!-- LV has bug sitting and sourceDesc, have to insert it by hand! -->
	<xsl:when test="$corpus = '#ParlaMint-LV'">
	  <tei:date from="2014-11-04" to="2021-02-04"/>
	</xsl:when>
	<!-- BE, TR have bugs in sitting but not in sourceDesc -->
	<xsl:when test="$corpus = '#ParlaMint-BE' or $corpus = '#ParlaMint-TR'">
	  <xsl:copy-of select=".//tei:sourceDesc/tei:listBibl[@corresp=$corpus]/tei:bibl[1]/tei:date"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:copy-of select=".//tei:settingDesc/tei:setting[@corresp=$corpus]/tei:date"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="from" select="et:pad-date($date/tei:date/@from)"/>
    <xsl:variable name="to" select="et:pad-date($date/tei:date/@to)"/>
    <xsl:value-of select="replace($from, '-\d\d$', '')"/>
    <xsl:value-of select="$col-sep"/>
    <xsl:value-of select="replace($to, '-\d\d$', '')"/>
    <xsl:value-of select="$col-sep"/>
    <xsl:variable name="days" select="days-from-duration(xs:date($to) - xs:date($from))"/>
    <xsl:variable name="years" select="($days div 30) div 12"/>
    <xsl:value-of select="format-number($years, '##.#')"/>
    <xsl:value-of select="$col-sep"/>
    <xsl:variable name="words" select=".//tei:extent/tei:measure[@corresp=$corpus][@unit='words']
				       /@quantity"/>
    <xsl:value-of select="format-number(($words div 1000000) div $years, '0.00')"/>
    <xsl:value-of select="$col-sep"/>
    <xsl:value-of select="format-number($words div 1000000, '0.00')"/>
    <xsl:value-of select="$line-sep"/>
  </xsl:template>

  <!-- Fix too long or too short dates 
       a la "2013-10-26T14:00:00" or "2018" to xs:date e.g. 2018-01-01 -->
  <xsl:function name="et:pad-date">
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
  
</xsl:stylesheet>
