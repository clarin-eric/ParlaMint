<?xml version="1.0"?>
<!-- Make TSV/LaTeX table with overview info on metadata of the ParlaMint corpora: -->
<!-- basic stats on type of parliament, size of corpus-->
<!-- Input is main ParlaMint corpus root ParlaMint.xml (with XIncludes to the individial corpus roots) -->
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

  <xsl:import href="parlamint-lib.xsl"/>
  
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
  <xsl:param name="preamble">\begin{tabular*}{\textwidth}{@{\extracolsep\fill}lcccllrrr@{}}&#10;</xsl:param>
  <!-- Either format -->
  <xsl:param name="header-row">
    <xsl:if test="matches($mode, 'tex', 'i')">\toprule&#10;</xsl:if>
    <xsl:text>ID</xsl:text> <!-- ISO country code -->
    <xsl:value-of select="$col-sep"/>
    <xsl:text>Lang</xsl:text> <!-- ISO language code(s) used (predominantly) -->
    <xsl:value-of select="$col-sep"/>
    <xsl:text>Bodies</xsl:text>  <!-- Unicameral, Lower house, Upper house, Committes -->
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
    <xsl:if test="matches($mode, 'tex', 'i')">\midrule&#10;</xsl:if>
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
        <xsl:message terminate="yes">FATAL ERROR: parameter 'mode' should be either TSV of TeX.</xsl:message>
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
      <xsl:text>\botrule&#10;\end{tabular*}&#10;</xsl:text>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="tei:teiHeader">
    <xsl:param name="corpus"/>
    <!--xsl:message select="concat('INFO: Corpus ', $corpus)"/-->
    <!-- Corpus -->
    <xsl:value-of select="replace($corpus, '^.+?-', '')"/>
    <xsl:value-of select="$col-sep"/>
    <!-- Languages -->
    <xsl:variable name="languages">
      <xsl:for-each select=".//tei:langUsage[@corresp=$corpus]/tei:language">
        <xsl:variable name="lang" select="ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang"/>
        <xsl:if test="$lang = 'en' and 
                      not(@ident = 'en' and $corpus != '#ParlaMint-GB') and

                      not(@ident = 'de'  and $corpus = '#ParlaMint-BE') and
                      not(@ident = 'und' and $corpus = '#ParlaMint-BE') and

                      not(@ident = 'bg-Latn' and $corpus = '#ParlaMint-BG') and
                      not(@ident = 'fr' and $corpus = '#ParlaMint-BG') and
                      not(@ident = 'es' and $corpus = '#ParlaMint-BG') and

                      not(@ident = 'fr' and $corpus = '#ParlaMint-GR') and

                      not(@ident != 'hu' and $corpus = '#ParlaMint-HU')
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
      <!-- PT has bug, cf. https://github.com/clarin-eric/ParlaMint/issues/828 -->
      <xsl:for-each select=".//tei:textClass/tei:catRef[
                            @scheme='#ParlaMint-taxonomy-parla.legislature' or @scheme='#Parliament'
                            ][@corresp=$corpus]
                            /tokenize(@target, ' ')">
        <xsl:choose>
          <xsl:when test=". = '#parla.uni'">uni+</xsl:when>
          <xsl:when test=". = '#parla.lower'">low+</xsl:when>
          <xsl:when test=". = '#parla.upper'">upp+</xsl:when>
          <xsl:when test=". = '#parla.committee'">com+</xsl:when>
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
      <xsl:copy-of select=".//tei:settingDesc/tei:setting[@corresp=$corpus]/tei:date"/>
    </xsl:variable>
    <xsl:variable name="from" select="et:norm-date($date/tei:date/@from)"/>
    <xsl:variable name="to" select="et:norm-date($date/tei:date/@to)"/>
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

</xsl:stylesheet>
