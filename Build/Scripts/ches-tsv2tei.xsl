<?xml version='1.0' encoding='UTF-8'?>
<!-- Insert CHES meta-data on political parties from TSV file into <listOrg>.
     Input TSVs must have appropriate header row and be sorted by ParlaMint key of party (pm_id column), then year column
     Existing CHES meta-data in <listOrg> is removed.

     Fake example:
     TSV input:

     country	pm_id	ches_id	year	chesversion	lrgen
     AT	BZÖ	BZO	2006	2020.1	8.83
     AT	BZÖ	BZO	2010	2020.1	8.29	
     AT	BZÖ	BZO	2014	2020.1	7.80	7.20

     TEI input:
     <org xml:id="parliamentaryGroup.BZÖ" role="parliamentaryGroup" xml:lang="de">
      <orgName full="yes" xml:lang="de">Palamentsklub Bündnis Zukunft Österreich</orgName>
      <orgName full="yes" xml:lang="en">parliamentary group Alliance for the Future of Austria</orgName>
      <orgName full="abb">BZÖ</orgName>
      ...
     </org>
     
     TEI output:

     <org xml:id="parliamentaryGroup.BZÖ" role="parliamentaryGroup" xml:lang="de">
      <orgName full="yes" xml:lang="de">Palamentsklub Bündnis Zukunft Österreich</orgName>
      <orgName full="yes" xml:lang="en">parliamentary group Alliance for the Future of Austria</orgName>
      <orgName full="abb">BZÖ</orgName>
      ...
      <state type="CHES" key="BZO" from="2006" to="2018" source="https://www.chesdata.eu/s/1999-2019_CHES_dataset_meansv3.csv">
         <state type="variable" ana="#ches.lrgen">
            <state type="value" from="2006" to="2009" n="8.83"/>
            <state type="value" from="2010" to="2013" n="8.29"/>
            <state type="value" from="2014" to="2018" n="7.80"/>
        </state>
      </state>
     </org>
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

  <!-- Prefix used by CHES taxonomy -->
  <xsl:param name="CHES-prefix">#ches.</xsl:param>
  
  <!-- RegEx and source for CHES data country -->
  <xsl:param name="ches-source">
    <list type="gloss">
      <label>(AT|BA|BE|BG|CZ|DK|EE|ES|FI|FR|GB|GR|HR|HU|IT|LT|LV|NL|PL|PT|RO|RS|SE|SI)</label>
      <item>https://www.chesdata.eu/s/1999-2019_CHES_dataset_meansv3.csv</item>
      <label>(IS|NO|TR)</label>
      <item>https://www.chesdata.eu/s/CHES2019V3.csv</item>
    </list>
  </xsl:param>
  
  <!-- If CHES year is @from, then it holds until @to -->
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

  <!-- Top level listOrg/@xml:id should contain name of country or region -->
  <xsl:variable name="country"
                select="replace(/tei:*/@xml:id, 
                        '.*ParlaMint-([A-Z]{2}(-[A-Z0-9]{1,3})?).*', 
                        '$1')"/>
  
  <!-- Parse TSV into a listOrg/org/state structures with pm_id as orgName -->
  <xsl:variable name="data">
    <listOrg>
      <xsl:variable name="tsv" select="unparsed-text($tsv, 'UTF-8')"/>
      <xsl:variable name="table" select="et:tsv2table($tsv)"/>
      <xsl:for-each-group select="$table/tei:row" group-by="tei:cell[@type='pm_id']">
	<org>
	  <orgName type='ParlaMint'>
	    <xsl:value-of select="current-grouping-key()"/>
	  </orgName>
	  <xsl:variable name="rows" select="current-group()"/>
	  <xsl:variable name="country" select="$rows[1]/tei:cell[@type='country']"/>
	  <xsl:if test="$rows[1]/tei:cell[@type='ches_id'] != '-'">
	    <state type="CHES">
	      <xsl:attribute name="source">
                <xsl:variable name="source">
		  <xsl:for-each select="$ches-source//tei:label">
		    <xsl:if test="matches($country, .)">
                      <xsl:value-of select="following-sibling::tei:item[1]"/>
                      <xsl:text>&#32;</xsl:text>
		    </xsl:if>
		  </xsl:for-each>
                </xsl:variable>
                <xsl:value-of select="normalize-space($source)"/>
              </xsl:attribute>
              <!-- CHES time-qualified name of the party -->
	      <xsl:variable name="ches_name">
		<xsl:call-template name="ches-name">
		  <xsl:with-param name="rows" select="$rows"/>
		</xsl:call-template>
              </xsl:variable>
              <xsl:attribute name="key" select="$ches_name/tei:orgName"/>
              <xsl:attribute name="from" select="$ches_name/tei:orgName/@from"/>
              <xsl:attribute name="to" select="$ches_name/tei:orgName/@to"/>
	      <xsl:for-each select="$rows[1]/tei:cell">
		<!-- Columns we don't want in <state> -->
		<xsl:if test="@type != 'country' and @type != 'pm_id' and @type != 'ches_id' and @type != 'year'">
		  <xsl:call-template name="ches-variables">
		    <xsl:with-param name="type" select="@type"/>
		    <xsl:with-param name="rows" select="$rows"/>
		  </xsl:call-template>
		</xsl:if>
	      </xsl:for-each>
	    </state>
	  </xsl:if>
	</org>
      </xsl:for-each-group>
    </listOrg>
  </xsl:variable>
  
  <xsl:template match="/">
    <xsl:text>&#10;</xsl:text>
    <!-- For debugging:
    <xsl:copy-of select="$data"/-->
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="tei:org[@role = 'politicalParty' or @role = 'parliamentaryGroup']">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates mode="insert" select="."/>
    </xsl:copy>
  </xsl:template>

  <!-- Insert $data <state>s into <org> -->
  <xsl:template mode="insert" match="tei:org">
    <!-- We try to match pm_id to a ParlaMint organisation -->
    <xsl:variable name="abbr" select="tei:orgName[@full = 'abb' and 
                                      ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang != 'en'][1]"/>
    <xsl:variable name="abbr-lc" select="lower-case($abbr)"/>
    <!-- parliamentaryGroup.ANO.1108 -> ano.1108 -->
    <xsl:variable name="abbr-id" select="lower-case(
					 replace(
					 replace(
					 replace(
					 replace(@xml:id, 
					 'parliamentaryGroup\.', ''),
					 'politicalParty\.', ''),
					 'Party\.', ''),
					 'party\.', '')
					 )"/>
    <!-- ano.1108 -> ano -->
    <xsl:variable name="abbr-id2" select="replace($abbr-id, '\..*', '')"/>
    <xsl:variable name="found">
      <xsl:choose>
        <xsl:when test="key('abbr', $abbr-lc, $data)">
          <xsl:copy-of select="key('abbr', $abbr-lc, $data)"/>
        </xsl:when>
        <xsl:when test="key('abbr', $abbr-id, $data)">
          <xsl:copy-of select="key('abbr', $abbr-id, $data)"/>
        </xsl:when>
        <xsl:when test="key('abbr', $abbr-id2, $data)">
          <xsl:copy-of select="key('abbr', $abbr-id2, $data)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message select="concat('ERROR: For ', $country, ' cant find party ', 
                               @xml:id, ' (', $abbr, ') in CHES TSV')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:apply-templates select="tei:orgName"/>
    <!-- Remove prior CHES <state> elements -->
      <xsl:copy-of select="tei:*[not(self::tei:orgName or 
			   self::tei:state[@type = 'CHES']
			   )]"/>
      <xsl:copy-of select="$found//tei:state[@type = 'CHES']"/>
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
  
  <!-- Return year-qualified CHES name(s) of party -->
  <xsl:template name="ches-name">
    <xsl:param name="rows"/>
    <xsl:variable name="names">
      <xsl:for-each select="distinct-values($rows/self::tei:row/tei:cell[@type = 'ches_id'])">
	<xsl:value-of select="."/>
        <xsl:text>&#32;</xsl:text>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="froms">
      <xsl:for-each select="$rows/self::tei:row">
	<xsl:sort select="tei:cell[@type = 'year']"/>
	<xsl:value-of select="tei:cell[@type = 'year']"/>
        <xsl:text>&#32;</xsl:text>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="tos">
      <xsl:for-each select="$rows/self::tei:row">
	<xsl:sort select="tei:cell[@type = 'year']"/>
        <xsl:variable name="from" select="tei:cell[@type = 'year']"/>
        <xsl:value-of select="$ches-interval/tei:date[@from = $from]/@to"/>
        <xsl:text>&#32;</xsl:text>
      </xsl:for-each>
    </xsl:variable>
    <orgName full="abb" xml:lang="en">
      <xsl:attribute name="from" select="normalize-space(replace($froms, '^(\d+)&#32;.+$', '$1'))"/>
      <xsl:attribute name="to" select="normalize-space(replace($tos, '^.+&#32;(\d+)&#32;$', '$1'))"/>
      <xsl:value-of select="normalize-space($names)"/>
    </orgName>
  </xsl:template>

  <!-- Return state for CHES variable of type $type, values per year are in in state/state/@n @from, @to -->
  <xsl:template name="ches-variables">
    <xsl:param name="type"/>
    <xsl:param name="rows"/>
    <xsl:variable name="country" select="$rows[1]/tei:cell[@type='country']"/>
    <xsl:variable name="party" select="$rows[1]/tei:cell[@type='pm_id']"/>
    <state type="variable" ana="#ches.{@type}">
      <xsl:variable name="values-per-year">
	<xsl:for-each select="$rows">
	  <xsl:if test="tei:cell[@type = $type]">
	    <xsl:variable name="from" select="tei:cell[@type = 'year']"/>
            <xsl:variable name="to" select="$ches-interval/tei:date[@from = $from]/@to"/>
	    <state type="value" from="{$from}" to="{$to}" n="{tei:cell[@type = $type]}"/>
	  </xsl:if>
	</xsl:for-each>
      </xsl:variable>
      <xsl:variable name="years" select="count($values-per-year/tei:state)"/>
      <!--xsl:message select="concat('INFO: ', $country, ' ', $party, ' ', $years, 
			   ' years in CHES TSV ', $type)"/-->
      <!--xsl:if test="$years != 1 or $years = 4">
        <xsl:message select="concat('WARN: For ', $country, ' ', $party, ' only ', $years, 
		     ' years in CHES TSV')"/>
      </xsl:if-->
      <xsl:copy-of select="$values-per-year"/>
    </state>
  </xsl:template>
  
  <!-- Functions -->
  <xsl:function name="et:tsv2table">
    <xsl:param name="tsv"/>
    <xsl:variable name="labels" select="tokenize($tsv, '&#10;')[1]"/>
    <table>
      <xsl:for-each select="tokenize($tsv, '&#10;')">
	<xsl:if test="matches(., '\t') and not(matches(., '^COUNTRY', 'i'))">
	  <xsl:variable name="row" select="et:row2table($labels, .)"/>
	  <xsl:if test="$row/self::tei:cell[@type = 'pm_id'] != '-'">
	    <row>
	      <xsl:copy-of select="$row"/>
	    </row>
	  </xsl:if>
	</xsl:if>
      </xsl:for-each>
    </table>
  </xsl:function>

  <xsl:function name="et:row2table">
    <xsl:param name="labels"/>
    <xsl:param name="row"/>
    <xsl:variable name="head-label" select="replace($labels, '&#9;.+', '')"/>
    <xsl:variable name="head-row" select="replace($row, '&#9;.+', '')"/>
    <xsl:if test="normalize-space($labels)">
      <!-- We ignore CHES version (as implicit in state/@source) and attributes with empty values -->
      <xsl:if test="$head-label != 'chesversion' and 
		    normalize-space($head-row) and $head-row != '-' ">
	<cell>
	  <xsl:attribute name="type" select="$head-label"/>
	  <xsl:value-of select="$head-row"/>
	</cell>
      </xsl:if>
      <xsl:if test="contains($labels, '&#9;')">
	<xsl:copy-of select="et:row2table(substring-after($labels, '&#9;'), substring-after($row, '&#9;'))"/>
      </xsl:if>
    </xsl:if>
  </xsl:function>
  
</xsl:stylesheet>
