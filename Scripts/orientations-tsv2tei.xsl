<?xml version='1.0' encoding='UTF-8'?>
<!-- Insert political orientation of parties from TSV file into a root or listOrg file.
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

  <xsl:param name="check-urls" xs:as="boolean" select="true()"/>
  
  <!-- Prefix used by orientation taxonomy -->
  <xsl:param name="orientation-prefix">#orientation.</xsl:param>
  
  <!-- RE and source for CHES data country -->
  <xsl:param name="ches-source">
    <list type="gloss">
      <label>(AT|BA|BE|BG|CZ|DK|EE|ES|FI|FR|GB|GR|HR|HU|IT|LT|LV|NL|PL|PT|RO|RS|SE|SI)</label>
      <item>https://www.chesdata.eu/s/1999-2019_CHES_dataset_meansv3.csv</item>
      <label>(IS|NO|TR)</label>
      <item>https://www.chesdata.eu/s/CHES2019V3.csv</item>
    </list>
  </xsl:param>
  
  <!-- If CHES LRGEN < $ches-left then orientation is taken to be Left -->
  <!-- If CHES LRGEN > $ches-right then orientation is taken to be Right -->
  <!-- Otherwise orientation is taken to be Centre -->
  <xsl:param name="ches-left">4.50</xsl:param>
  <xsl:param name="ches-right">5.50</xsl:param>

  <!-- If CHES year is @from, then it holds untill @to year -->
  <xsl:param name="ches-interval">
    <date from="1999" to="2001"/>
    <date from="2002" to="2005"/>
    <date from="2006" to="2009"/>
    <date from="2010" to="2013"/>
    <date from="2014" to="2018"/>
    <date from="2019" to="2019"/>
  </xsl:param>

  <xsl:output method="xml" indent="yes" omit-xml-declaration="no"/>
  
  <!-- @type = 'ParlaMint' is the ParlaMint name of the party found in TSV -->
  <xsl:key name="abbr" match="tei:org" use="lower-case(tei:orgName[@type = 'ParlaMint'])"/>

  <!-- Get country of corpus from filename -->
  <xsl:variable name="corpusCountry"
		select="replace(base-uri(), 
			'.+ParlaMint-([A-Z]{2}(-[A-Z0-9]{1,3})?).*', 
			'$1')"/>
  
  <!-- Parse TSV into a listOrg/org/state structures with pm_id as orgName[@full="abb"] -->
  <!-- We still need to take care of doubled Wiki lines and that Wiki URL is given only once! -->
  <xsl:variable name="data">
    <xsl:variable name="temp">
      <listOrg>
	<xsl:variable name="text" select="unparsed-text($tsv, 'UTF-8')"/>
	<xsl:for-each select="tokenize($text, '&#10;')">
	  <xsl:if test="matches(., '\t') and not(matches(., '^COUNTRY', 'i'))">
	    <xsl:call-template name="parse-line">
	      <xsl:with-param name="line" select="."/>
	    </xsl:call-template>
	  </xsl:if>
	</xsl:for-each>
      </listOrg>
    </xsl:variable>
    <xsl:call-template name="uniq-orgs">
      <xsl:with-param name="listOrg" select="$temp"/>
    </xsl:call-template>
  </xsl:variable>
  
  <xsl:template match="/">
    <!--xsl:copy-of select="$data"/-->
    <xsl:text>&#10;</xsl:text>
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="tei:listOrg[tei:org[@role = 'politicalParty' or @role = 'parliamentaryGroup']]">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:copy-of select="tei:org[not(@role = 'politicalParty' or @role = 'parliamentaryGroup')]"/>
      <xsl:variable name="parties">
	<xsl:apply-templates mode="insert"
			     select="tei:org[@role = 'politicalParty' or @role = 'parliamentaryGroup']"/>
      </xsl:variable>
      <xsl:message>
	<xsl:text>INFO: For </xsl:text>
	<xsl:value-of select="$corpusCountry"/>
	<xsl:text> </xsl:text>
	<xsl:value-of select="count($parties/tei:org[tei:state[@type='politicalOrientation']])"/>
	<xsl:text>/</xsl:text>
	<xsl:value-of select="count($parties/tei:org)"/>
	<xsl:text> assigned political orientation: </xsl:text>
	<xsl:value-of select="count($parties/tei:org
			      [tei:state[@subtype='CHES'] and tei:state[@subtype='Wikipedia']])"/>
	<xsl:text> both + </xsl:text>
	<xsl:value-of select="count($parties/tei:org
			      [not(tei:state[@subtype='CHES']) and tei:state[@subtype='Wikipedia']])"/>
	<xsl:text> Wikipedia + </xsl:text>
	<xsl:value-of select="count($parties/tei:org
			      [tei:state[@subtype='CHES'] and not(tei:state[@subtype='Wikipedia'])])"/>
	<xsl:text> CHES</xsl:text>
      </xsl:message>
      <xsl:copy-of select="$parties"/>
    </xsl:copy>
  </xsl:template>

  <!-- Insert <state>s from $data into <org>, mark those covered with @n = $ches_id -->
  <xsl:template mode="insert" match="tei:org">
    <xsl:variable name="abbr" select="lower-case(tei:orgName[@full = 'abb' and 
				      ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang != 'en'][1])"/>
    <!-- parliamentaryGroup.ANO.1108 -> ano.1108 -->
    <xsl:variable name="abbr-id" select="lower-case(replace(@xml:id, '.*?\.', ''))"/>
    <!-- ano.1108 -> ano -->
    <xsl:variable name="abbr-id2" select="replace($abbr-id, '\..*', '')"/>
    <xsl:variable name="found">
      <xsl:choose>
	<xsl:when test="key('abbr', $abbr, $data)">
	  <xsl:copy-of select="key('abbr', $abbr, $data)"/>
	</xsl:when>
	<xsl:when test="key('abbr', $abbr-id, $data)">
	  <xsl:copy-of select="key('abbr', $abbr-id, $data)"/>
	</xsl:when>
	<xsl:when test="key('abbr', $abbr-id2, $data)">
	  <xsl:copy-of select="key('abbr', $abbr-id2, $data)"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:message select="concat('ERROR: For ', $corpusCountry, ' cant find pm_id in TSV for ', 
			       $abbr, ' with ID ', @xml:id)"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:copy-of select="tei:orgName"/>
      <!-- Remove prior <state> elements -->
      <xsl:copy-of select="tei:*[not(self::tei:orgName or self::tei:state)]"/>
      <xsl:copy-of select="$found//tei:state"/>
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

  <!-- Named templates -->
  
  <!-- Parse data line into an <org> -->
  <xsl:template name="parse-line">
    <xsl:param name="line" select="."/>
    <!-- Get rid of quotes left over from Excel or similar -->
    <xsl:variable name="clean-line"
		  select="replace(
			  replace(
			  replace(
			  replace(
			  replace(
			  replace(
			  replace($line, 
			  '&#9;&quot;', '&#9;'),
			  '&quot;&#9;', '&#9;'),
			  '^&quot;', ''),
			  '&quot;$', ''),
			  '&quot;&quot;', '&quot;'),
			  '&#x00A0;', ' '),
			  '&#xFEFF;', '')
			  "/>
    <xsl:analyze-string select="$clean-line"
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
	<xsl:if test="normalize-space($pm_id) and $pm_id != '0'">
	  <xsl:call-template name="parse-orientation">
	    <xsl:with-param name="country" select="normalize-space($country)"/>
	    <!-- We lower case the pm_id and match on that! -->
	    <xsl:with-param name="pm_id" select="lower-case(normalize-space($pm_id))"/>
	    <xsl:with-param name="ches_id" select="normalize-space($ches_id)"/>
	    <xsl:with-param name="year" select="normalize-space($year)"/>
	    <xsl:with-param name="lrgen" select="normalize-space($lrgen)"/>
	    <xsl:with-param name="lr" select="normalize-space($lr)"/>
	    <xsl:with-param name="url" select="normalize-space($url)"/>
	    <xsl:with-param name="comment" select="normalize-space($comment)"/>
	  </xsl:call-template>
	</xsl:if>
      </xsl:matching-substring>
      <xsl:non-matching-substring>
	<xsl:message terminate="yes"
		     select="concat('FATAL: Bad line in TSV: ', .)"/>
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:template>
  
  <!-- Parse cells into an <org> -->
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
      <orgName type="ParlaMint" full="abb">
	<xsl:value-of select="$pm_id"/>
      </orgName>
      <xsl:if test="normalize-space($ches_id) and $ches_id != '0'">
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
	    <xsl:value-of select="et:lrgen2orientation(xs:decimal($lrgen))"/>
	  </xsl:attribute>
	  <xsl:attribute name="from" select="$year"/>
	  <xsl:variable name="to" select="$ches-interval/tei:date[@from = $year]/@to"/>
	  <xsl:if test="normalize-space($to) and $year &lt; $to">
	    <xsl:attribute name="to" select="$to"/>
	  </xsl:if>
	  <label>
	    <orgName full="abb">
	      <xsl:value-of select="$ches_id"/>
	    </orgName>
	  </label>
	</state>
      </xsl:if>
      <xsl:if test="normalize-space($lr) and $lr != '0'">
	<state type="politicalOrientation" subtype="unknown">
	  <xsl:if test="normalize-space($url) and $url != '0'">
	    <!-- Doesn't work?!
	    <xsl:if test="$check-urls and not(unparsed-text-available(encode-for-uri($url)))">
		<xsl:message select="concat('ERROR: the URL ', $url, 
				     ' is not valid for ', $country, '/', $pm_id)"/>
	    </xsl:if>
	    -->
	    <xsl:attribute name="source" select="$url"/>
	  </xsl:if>
	  <xsl:attribute name="ana">
	    <xsl:value-of select="$orientation-prefix"/>
	    <xsl:value-of select="$lr"/>
	  </xsl:attribute>
	  <xsl:if test="normalize-space($comment) and $comment != '0'">
	    <note xml:lang="en">
	      <xsl:value-of select="$comment"/>
	    </note>
	  </xsl:if>
	</state>
      </xsl:if>
    </org>
  </xsl:template>
  
  <!-- Merge organisations with same abbrev and give Wikipedia URLs to those missing them -->
  <xsl:template name="uniq-orgs">
    <xsl:param name="listOrg"/>
    <listOrg>
      <xsl:for-each select="$listOrg//tei:org">
	<xsl:variable name="abbrev" select="tei:orgName[@type = 'ParlaMint']"/>
	<xsl:if test="not(preceding-sibling::tei:org[tei:orgName[@type = 'ParlaMint'] = $abbrev])">
	  <xsl:variable name="others"
			select="following-sibling::tei:org[tei:orgName[@type = 'ParlaMint'] = $abbrev]"/>
	  <xsl:copy>
	    <xsl:copy-of select="tei:orgName"/>
	    <!-- Collect CHES -->
	    <xsl:copy-of select="tei:state[@subtype = 'CHES']"/>
	    <xsl:copy-of select="$others/tei:state[@subtype = 'CHES']"/>
	    <!-- Wikis and other sources -->
	    <xsl:variable name="lr" select="tei:state[@subtype = 'unknown']/@ana"/>
	    <xsl:variable name="url" select="tei:state[@subtype = 'unknown']/@source"/>
	    <xsl:variable name="comment" select="tei:state/tei:note"/>
	    <xsl:if test="normalize-space($lr)">
	      <state type="politicalOrientation">
		<xsl:choose>
		  <xsl:when test="normalize-space($url)">
		    <xsl:attribute name="subtype">Wikipedia</xsl:attribute>
		    <xsl:attribute name="source" select="$url"/>
		    <xsl:attribute name="ana" select="$lr"/>
		  </xsl:when>
		  <xsl:otherwise>
		    <xsl:attribute name="subtype">unknown</xsl:attribute>
		    <xsl:attribute name="ana" select="$lr"/>
		  </xsl:otherwise>
		</xsl:choose>
		<xsl:copy-of select="$comment"/>
	      </state>
	    </xsl:if>
	  </xsl:copy>
	</xsl:if>
      </xsl:for-each>
    </listOrg>
  </xsl:template>
    
  <!-- Functions -->
  
  <!-- Change numeric LRGEN to party orientation -->
  <!-- We use 3 labels, and this is libable to change! -->
  <xsl:function name="et:lrgen2orientation" xs:as="string">
    <xsl:param name="lrgen" xs:as="decimal"/>
    <xsl:choose>
      <xsl:when test="$lrgen &lt; $ches-left">L</xsl:when>
      <xsl:when test="$lrgen &gt; $ches-right">R</xsl:when>
      <xsl:otherwise>C</xsl:otherwise>
    </xsl:choose>
  </xsl:function>
</xsl:stylesheet>
