<?xml version='1.0' encoding='UTF-8'?>
<!-- Insert minister affiliations from TSV into the TEI root file 
     Note that all existing minister affiliations in TEI and removed
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  exclude-result-prefixes="fn tei">
  <!-- File with TSV data -->
  <xsl:param name="tsv"/>
  
  <xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="no"/>

  <xsl:key name="id" match="tei:*" use="@xml:id"/>
  
  <xsl:variable name="profileDesc" select="tei:teiCorpus/tei:teiHeader/tei:profileDesc"/>
  
  <!-- NOTE: we have to discuss how to name "regions" in setting! -->
  <xsl:variable name="corpusCountry" select="$profileDesc/
					     tei:settingDesc/tei:setting/tei:name
				       [@type = 'country' or @type = 'region']/@key
				       "/>
  <!-- Parse TSV into a 
       listPerson/person[@xml:id]/affiliation
       [@role='minister']
       [@from][@to]
       [@ref][@ana] 
       structure -->
  <xsl:variable name="data">
    <listPerson>
      <xsl:variable name="text" select="unparsed-text($tsv, 'UTF-8')"/>
      <xsl:for-each select="tokenize($text, '\n')">
	<xsl:if test="matches(., '\t') and not(matches(., '^Country'))">
	  <person>
	    <xsl:analyze-string select="." regex="^(.*)\t(.*)\t(.*)\t(.*)\t(.*)\t(.*)\t(.*)$">
	      <xsl:matching-substring>
		<xsl:variable name="country" select="regex-group(1)"/>
		<xsl:variable name="personID" select="regex-group(2)"/>
		<xsl:variable name="role" select="regex-group(3)"/>
		<xsl:variable name="from" select="regex-group(4)"/>
		<xsl:variable name="to" select="regex-group(5)"/>
		<xsl:variable name="ref" select="regex-group(6)"/>
		<xsl:variable name="ana" select="regex-group(7)"/>

		<xsl:if test = '$country != $corpusCountry'>
		  <xsl:message terminate="yes"
			       select="concat('FATAL: TEI corpus country = ', $corpusCountry, 
				       ' does not match TSV country = ', $country,
				       ' in TSV line&#10;', .)"/>
		</xsl:if>
		<xsl:if test = "not(key('id', $personID, $profileDesc)/self::tei:person)">
		  <xsl:message terminate="yes"
			       select="concat('FATAL: No person ', $personID, 
				       ' found in TEI corpus! TSV is:&#10;', .)"/>
		</xsl:if>
		<xsl:attribute name="xml:id" select="$personID"/>
		<xsl:if test = "$role != 'minister'">
		  <xsl:message terminate="yes"
			       select="concat('FATAL: Role ', $role, 
				       ' does not match minister! TSV is:&#10;', .)"/>
		</xsl:if>
		<affiliation role="minister">
		  <!-- Re-insert # in references to IDs for affiliation/@ref -->
		  <xsl:if test="normalize-space($ref) and $ref != '-'">
		    <xsl:attribute name="ref" select="concat('#', $ref)"/>
		  </xsl:if>
		  <xsl:if test="normalize-space($from) and $from != '-'">
		    <xsl:attribute name="from" select="$from"/>
		  </xsl:if>
		  <xsl:if test="normalize-space($to) and $to != '-'">
		    <xsl:attribute name="to" select="$to"/>
		  </xsl:if>
		  <!-- Re-insert # in references to IDs for affiliation/@ana -->
		  <xsl:if test="normalize-space($ana) and $ana != '-'">
		    <xsl:attribute name="ana" select="concat('#', replace($ana, ' ', ' #'))"/>
		  </xsl:if>
		</affiliation>
              </xsl:matching-substring>
	      <xsl:non-matching-substring>
		<xsl:message terminate="yes"
			     select="concat('FATAL: Bad line in TSV: ', .)"/>
	      </xsl:non-matching-substring>
	    </xsl:analyze-string>
	  </person>
	</xsl:if>
      </xsl:for-each>
    </listPerson>
  </xsl:variable>

  <xsl:template match="/">
    <xsl:text>&#10;</xsl:text>
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="tei:listPerson/tei:person">
    <!-- Get affiliation info from TSV for this person, if it exists -->
    <xsl:variable name="minister" select="key('id', @xml:id, $data)"/>
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
      <xsl:if test="$minister/self::tei:person">
	<xsl:message select="concat('INFO: Inserting new minister affiliation(s) for ', @xml:id)"/>
	<xsl:copy-of select="$minister/tei:affiliation"/>
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <!-- Remove old ministers from TEI -->
  <xsl:template match="tei:affiliation[@role = 'minister']">
    <xsl:message select="concat('INFO: Removing old minister affiliation for ', 
			 parent::tei:person/@xml:id)"/>
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
</xsl:stylesheet>
