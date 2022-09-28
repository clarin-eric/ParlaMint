<?xml version='1.0' encoding='UTF-8'?>
<!-- Insert political orientation of parties from TSV file into a root file.
     Note that all existing political orientation of parties in TEI is removed
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
  
  <!-- File with TSV data -->
  <xsl:param name="tsv"/>

  <!-- Prefix used by orientation taxonomy -->
  <xsl:param name="orientation-prefix">#orientation.</xsl:param>
  
  <!-- RE and source for CHES data country -->
  <xsl:param name="ches-source">
    <list type="gloss">
      <label>(AT|BA|BE|BG|CZ|DK|EE|ES|FI|FR|GB|GR|HR|HU|IT|LT|LV|NL|PL|PT|RO|RS|SE|SI)</label>
      <item>https://www.chesdata.eu/s/CHES2019V3.csv</item>
      <label>(IS|NO|TR)</label>
      <item>https://www.chesdata.eu/s/1999-2019_CHES_dataset_meansv3.csv</item>
    </list>
  </xsl:param>
  <xsl:param name="ches-interval">
    <date from="1999" to="2001"/>
    <date from="2002" to="2005"/>
    <date from="2006" to="2009"/>
    <date from="2010" to="2013"/>
    <date from="2014" to="2018"/>
    <date from="2019" to="2019"/>
  </xsl:param>
  
  <xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="no"/>
  <xsl:key name="id" match="tei:*" use="@xml:id"/>
  <xsl:variable name="profileDesc" select="tei:teiCorpus/tei:teiHeader/tei:profileDesc"/>
  
  <xsl:variable name="corpusCountry"
		select="$profileDesc/
			tei:settingDesc/tei:setting/tei:name
			[@type = 'country' or @type = 'region']/@key"/>
  
  <!-- Parse TSV into a listOrg/org/state structure with pm_id as orgName[@full="init"] -->
  <!-- We still need to take care of doubled Wiki lines and that Wiki URL is given only once! -->
  <xsl:variable name="data">
    <listOrg>
      <xsl:variable name="text" select="unparsed-text($tsv, 'UTF-8')"/>
      <xsl:for-each select="tokenize($text, '&#10;')">
	<xsl:if test="matches(., '\t') and not(matches(., '^COUNTRY', 'i'))">
	  <xsl:analyze-string select="."
			      regex="^([^\t]+)\t([^\t]+)\t([^\t]+)\t([^\t]*)\t([^\t]*)\t?([^\t]*)\t?([^\t]*)\t?([^\t]*).*">
	    <xsl:matching-substring>
	      <xsl:variable name="country" select="regex-group(1)"/>
	      <xsl:variable name="pm_id" select="regex-group(2)"/>
	      <xsl:variable name="ches_id" select="regex-group(3)"/>
	      <xsl:variable name="year" select="regex-group(4)"/>
	      <xsl:variable name="lrgen" select="regex-group(5)"/>
	      <xsl:variable name="lr" select="regex-group(6)"/>
	      <xsl:variable name="url" select="regex-group(7)"/>
	      <xsl:variable name="comment" select="regex-group(8)"/>
	      <xsl:if test = '$country != $corpusCountry'>
		<xsl:message terminate="yes"
			     select="concat('FATAL: TEI corpus country = ', $corpusCountry, 
				     ' does not match TSV country = ', $country,
				     ' in TSV line&#10;', .)"/>
	      </xsl:if>
	      <xsl:if test="normalize-space($pm_id) and $pm_id != '0')">
		<xsl:call-template name="parse-orientation">
		  <xsl:with-param name="country" select="$country"/>
		  <xsl:with-param name="pm_id" select="$pm_id"/>
		  <xsl:with-param name="ches_id" select="$ches_id"/>
		  <xsl:with-param name="year" select="$year"/>
		  <xsl:with-param name="lrgen" select="$lrgen"/>
		  <xsl:with-param name="lr" select="$lr"/>
		  <xsl:with-param name="url" select="$url"/>
		  <xsl:with-param name="comment" select="$comment"/>
		</xsl:call-template>
	      </xsl:if>
            </xsl:matching-substring>
	    <xsl:non-matching-substring>
	      <xsl:message terminate="yes"
			   select="concat('FATAL: Bad line in TSV: ', .)"/>
	    </xsl:non-matching-substring>
	  </xsl:analyze-string>
	</xsl:if>
      </xsl:for-each>
    </listOrg>
  </xsl:variable>
  
  <xsl:template match="/">
    <xsl:copy-of select="$data"/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
  
  <xsl:template match="tei:listPerson/tei:person">
    <!-- Get affiliation info from TSV for this person, if it exists -->
    <xsl:variable name="minister" select="key('id', @xml:id, $data)"/>
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
      <xsl:if test="$minister/self::tei:person">
	<xsl:message select="concat('INFO: Inserting minister affiliation(s) for ', @xml:id)"/>
	<xsl:for-each select="$minister/tei:affiliation">
	  <xsl:message select="concat('INFO: Inserting affiliation ', 
			       @ana, ' from ', @from, ' to ', @to)"/>
	  <xsl:copy-of select="."/>
	</xsl:for-each>
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <!-- Remove old ministers from TEI -->
  <xsl:template match="tei:affiliation[@role = 'minister']">
    <xsl:message select="concat('INFO: Removing minister affiliation for ', 
			 parent::tei:person/@xml:id, ': ', @ana, ' from ', @from, ' to ', @to)"/>
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

  <!-- Parse TSV line into an <org> -->
  <xsl:template name="parse-orientation">
    <xsl:param name="country"/>
    <xsl:param name="pm_id"/>
    <xsl:param name="ches_id"/>
    <xsl:param name="year"/>
    <xsl:param name="lrgen"/>
    <xsl:param name="lr"/>
    <xsl:param name="url"/>
    <xsl:param name="comment"/>
    <org>
      <orgName full="init">
	<xsl:value-of select="$pm_id"/>
      </orgName>
      <xsl:if test="normalize-space($ches_id) and $ches_id != '0')">
	<state type="politicalOrientation" subtype="CHES">
	  <xsl:attribute name="source">
	    <xsl:for-each select="$ches-source//tei:label">
	      <xsl:if test="matches($country, .)">
		<xsl:value-of select="following-sibling::tei:item[1]"/>
	      </xsl:if>
	    </xsl:for-each>
	  </xsl:attribute>
	  <xsl:attribute name="n" select="$lrgen"/>
	  <xsl:attribute name="ana">
	    <xsl:value-of select="$orientation-prefix"/>
	    <xsl:value-of select="et:lrgen2orientation($lrgen)"/>
	  </xsl:attribute>
	  <xsl:attribute name="from" select="$year"/>
	  <xsl:attribute name="to" select="$ches-interval/tei:date[@from = $year]/@to"/>
	</state>
      </xsl:if>
      <xsl:if test="normalize-space($lr) and $lr != '0')">
	<state type="politicalOrientation" subtype="unknown">
	  <xsl:if test="normalize-space($url) and $url != '0')">
	    <xsl:attribute name="source" select="$url"/>
	  </xsl:if>
	  <xsl:attribute name="ana">
	    <xsl:value-of select="$orientation-prefix"/>
	    <xsl:value-of select="et:check-lr($lr)"/>
	  </xsl:attribute>
	  <xsl:if test="normalize-space($comment) and $comment != '0')">
	    <xsl:value-of select="$comment"/>
	  </xsl:if>
	</state>
      </xsl:if>
    </org>
  </xsl:template>
  
  <!-- Check if LR label is correct -->
  <xsl:function name="et:check-lr" xs:as="string">
    <xsl:param name="lr"/>
    <xsl:choose>
      <xsl:when test="$lr = 'FL'">FL</xsl:when>
      <xsl:when test="$lr = 'LLF'">LLF</xsl:when>
      <xsl:when test="$lr = 'L'">L</xsl:when>
      <xsl:when test="$lr = 'CL'">CL</xsl:when>
      <xsl:when test="$lr = 'CLL'">CLL</xsl:when>
      <xsl:when test="$lr = 'CCL'">CCL</xsl:when>
      <xsl:when test="$lr = 'C'">C</xsl:when>
      <xsl:when test="$lr = 'CCR'">CCR</xsl:when>
      <xsl:when test="$lr = 'CRR'">CRR</xsl:when>
      <xsl:when test="$lr = 'CR'">CR</xsl:when>
      <xsl:when test="$lr = 'R'">R</xsl:when>
      <xsl:when test="$lr = 'RRF'">RRF</xsl:when>
      <xsl:when test="$lr = 'FR'">FR</xsl:when>
      <xsl:otherwise>
	<xsl:message select="concat('ERROR: bad value for LR orientation: ', $lr)"/>
	<xsl:text>XX</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- Change numeric LRGEN to party orientation -->
  <!-- We use 3 labels, and this is libable to change! -->
  <xsl:function name="et:lrgen2orientation" xs:as="string">
    <xsl:param name="lrgen" xs:as="integer"/>
    <xsl:choose>
      <xsl:when test="$lrgen &lt; 4.50">L</xsl:when>
      <xsl:when test="$lrgen &gt; 5.50">R</xsl:when>
      <xsl:otherwise>C</xsl:otherwise>
    </xsl:choose>
  </xsl:function>
</xsl:stylesheet>
