<?xml version='1.0' encoding='UTF-8'?>
<!-- Insert Wiki meta-data on political parties from TSV file into <listOrg>.
     Input TSVs must have appropriate header row
     Existing CHES meta-data on such orientation in <listOrg> is removed.

     Fake example:
     TSV input:

     country	pm_id	lr	url	comment
     AT		BZÖ	RRF	https://en.wikipedia.org/wiki/Alliance_for_the_Future_of_Austria	Coalition of NHI and HKDU

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
      <state type="politicalOrientation">
         <state type="Wikipedia" source="https://en.wikipedia.org/wiki/Alliance_for_the_Future_of_Austria" ana="#political.CRR">
         <note xml:lang="en">Coalition of NHI and HKDU</note>
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

  <!-- Prefix used by political orientation taxonomy -->
  <xsl:param name="Orientation-prefix">#orientation.</xsl:param>

  <xsl:output method="xml" indent="yes" omit-xml-declaration="no"/>
  
  <!-- @type = 'ParlaMint' is the ParlaMint name of the party found in TSV -->
  <xsl:key name="abbr" match="tei:org" use="lower-case(tei:orgName[@type = 'ParlaMint'])"/>

  <xsl:variable name="country"
                select="replace(/tei:listOrg/@xml:id, 
                        '.+ParlaMint-([A-Z]{2}(-[A-Z0-9]{1,3})?).*', 
                        '$1')"/>
  
  <!-- Parse TSV into a listOrg/org/state structures with pm_id as orgName -->
  <xsl:variable name="data">
    <listOrg>
      <xsl:variable name="tsv" select="replace(unparsed-text($tsv, 'UTF-8'), '&#x0D;', '')"/>
      <xsl:variable name="table" select="et:tsv2table($tsv)"/>
      <xsl:for-each select="$table/tei:row">
	<xsl:variable name="country" select="tei:cell[@type='country']"/>
	<!-- UA now has hash mark in front of party name = party ID -->
	<xsl:variable name="pm_id" select="replace(tei:cell[@type='pm_id'], '^#', '')"/>
	<xsl:variable name="lr" select="tei:cell[@type='lr']"/>
	<xsl:variable name="url" select="tei:cell[@type='url']"/>
	<xsl:variable name="comment" select="tei:cell[@type='comment']"/>
	<org>
	  <orgName type='ParlaMint'>
	    <xsl:value-of select="$pm_id"/>
	  </orgName>
	  <xsl:variable name="lang" select="replace($url, 'https://(..)\.wikipedia.org.+', '$1')"/>
	  <xsl:if test="normalize-space($url)">
	    <xsl:if test="not(starts-with($url, 'http'))">
              <xsl:message select="concat('ERROR: For ', $country, ' ', $pm_id, ' bad URL ', $url)"/>
	    </xsl:if>
	    <idno type="URI" subtype="wikimedia">
	      <xsl:choose>
		<xsl:when test="string-length($lang) = 2">
		  <xsl:attribute name="xml:lang" select="$lang"/>
		</xsl:when>
		<xsl:otherwise>
		  <xsl:message select="concat('WARN: For ', $country, ' ', $pm_id, 
				       ' cant find language in URL ', $url)"/>
		</xsl:otherwise>
	      </xsl:choose>
	      <xsl:value-of select="$url"/>
	    </idno>
	  </xsl:if>
	  <xsl:choose>
	    <xsl:when test="not(normalize-space($lr))">
              <xsl:message select="concat('WARN: For ', $country, ' ', $pm_id, ' no orientation in Wiki TSV')"/>
	    </xsl:when>
	    <xsl:otherwise>
	      <state type="Wikipedia" source="{$url}" ana="{concat($Orientation-prefix, $lr)}">
		<xsl:if test="normalize-space($comment)">
		  <note xml:lang="en">
		    <xsl:value-of select="$comment"/>
		  </note>
		</xsl:if>
	      </state>
	    </xsl:otherwise>
	  </xsl:choose>
	</org>
      </xsl:for-each>
    </listOrg>
  </xsl:variable>
  
  <xsl:template match="/">
    <xsl:if test="not(unparsed-text-available($tsv))">
      <xsl:message select="concat('FATAL ERROR: TSV file ', $tsv, ' not found')"/>
    </xsl:if>
    <xsl:text>&#10;</xsl:text>
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
    <!-- We try to match pm_id to a ParlaMint organisation, trying different variants of the party name: abbreviation, shortened ID -->
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
                               $abbr, ' (', $abbr-id, ') in Wiki TSV')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:copy-of select="tei:*[not(self::tei:state or self::tei:listEvent)]"/>
    <!-- We cannot test if tei:idno = $found//tei:idno, as one can be mime-encoded, the other not -->
    <xsl:if test="not(tei:idno[matches(., 'wikipedia')])">
      <xsl:copy-of select="$found//tei:idno"/>
    </xsl:if>
    <xsl:copy-of select="tei:listEvent"/>
    <xsl:variable name="state">
      <!-- Copy over exsting political orientation info (except for Wikipedia or notes) -->
      <xsl:copy-of select="tei:state[@type = 'politicalOrientation']/tei:*
			   [not(self::tei:state[@type = 'Wikipedia'] or self::tei:note)]"/>
      <!-- And the newly added Wikipedia info -->
      <xsl:copy-of select="$found//tei:state"/>
    </xsl:variable>
    <xsl:if test="$state/tei:*">
      <state type="politicalOrientation">
	<xsl:copy-of select="$state"/>
      </state>
    </xsl:if>
    <!-- Remove prior political orientation elements -->
    <xsl:copy-of select="tei:state[not(@type = 'politicalOrientation')]"/>
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

  <!-- Functions -->
  <xsl:function name="et:tsv2table">
    <xsl:param name="tsv"/>
    <xsl:variable name="labels" select="tokenize($tsv, '&#10;')[1]"/>
    <table>
      <xsl:for-each select="tokenize($tsv, '&#10;')">
	<xsl:if test="matches(., '\t') and not(matches(., '^country', 'i'))">
	  <xsl:variable name="row" select="et:row2table($labels, .)"/>
	  <xsl:if test="$row/self::tei:cell[@type = 'pm_id'] != '0' and 
			$row/self::tei:cell[@type = 'pm_id'] != '-'">
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
      <xsl:if test="normalize-space($head-row) and $head-row != '-' and $head-row != '0' ">
	<cell>
	  <xsl:attribute name="type" select="$head-label"/>
	  <xsl:value-of select="normalize-space($head-row)"/>
	</cell>
      </xsl:if>
      <xsl:if test="contains($labels, '&#9;')">
	<xsl:copy-of select="et:row2table(substring-after($labels, '&#9;'), 
			     substring-after($row, '&#9;'))"/>
      </xsl:if>
    </xsl:if>
  </xsl:function>
  
</xsl:stylesheet>
