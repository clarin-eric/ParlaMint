<?xml version='1.0' encoding='UTF-8'?>
<!-- Insert minister affiliations from TSV into the the listPersons file
     Note that all existing minister affiliations in TEI are removed!
-->
<xsl:stylesheet
    version="2.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xi="http://www.w3.org/2001/XInclude"
    xmlns:et="http://nl.ijs.si/et" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xsl tei et xs xi">
  
  <xsl:import href="parlamint-lib.xsl"/>
  
  <!-- File with TSV data -->
  <xsl:param name="tsv"/>
  
  <!-- Support XML file with listOrg data -->
  <xsl:param name="xml"/>
  
  <xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="no"/>

  <!-- Top level listPerson/@xml:id should contain name of country or region -->
  <xsl:variable name="corpusCountry"
                select="replace(/tei:*/@xml:id, 
                        '.*ParlaMint-([A-Z]{2}(-[A-Z0-9]{1,3})?).*', 
                        '$1')"/>

  <xsl:variable name="listPerson" select="//tei:listPerson"/>
  <xsl:variable name="listOrg">
    <xsl:if test="not(doc-available($xml))">
      <xsl:message terminate="yes" select="concat('FATAL: Cant find XML document ', $xml)"/>
    </xsl:if>
    <xsl:copy-of select="document($xml)/tei:listOrg"/>
  </xsl:variable>
  <xsl:variable name="govtID" select="$listOrg//tei:org[@role = 'government']/@xml:id"/>
  
  <!-- Parse TSV into a 
       listPerson/person[@xml:id]/affiliation[@role='minister']@from][@to][@ref][@ana] structure -->
  <xsl:variable name="data">
    <listPerson>
      <!-- Read in TSV and get rid of spurious quote characters -->
      <xsl:variable name="text" select="replace(
					replace(
					replace(
					unparsed-text($tsv, 'UTF-8'),
					'[&#9;&#10;]&#34;', '$1'),
					'&#34;[&#9;&#10;]', '$1'),
					'&#34;&#34;', '&#34;')
					"/>
      <xsl:for-each select="tokenize($text, '&#10;')">
        <xsl:if test="matches(., '\t') and not(matches(., '^Country'))">
          <xsl:analyze-string select="."
                              regex="^([^\t]+)\t([^\t]+)\t([^\t]+)\t([^\t]*)\t([^\t]*)\t?([^\t]*)\t?([^\t]*)\t?([^\t]*)\t?([^\t]*)\t?([^\t]*).*">
            <xsl:matching-substring>
              <xsl:variable name="country" select="normalize-space(regex-group(1))"/>
              <xsl:variable name="personID" select="normalize-space(regex-group(2))"/>
              <xsl:variable name="role" select="normalize-space(regex-group(3))"/>
              <xsl:variable name="from" select="normalize-space(regex-group(4))"/>
              <xsl:variable name="to" select="normalize-space(regex-group(5))"/>
              <xsl:variable name="govtTermID" select="normalize-space(regex-group(6))"/>
              <xsl:variable name="ministryID" select="normalize-space(regex-group(7))"/>
              <xsl:variable name="orgName-xx" select="normalize-space(regex-group(8))"/>
              <xsl:variable name="orgName-en" select="normalize-space(regex-group(9))"/>
              <xsl:variable name="url" select="normalize-space(regex-group(10))"/>
              <xsl:variable name="comment" select="normalize-space(regex-group(11))"/>
              <xsl:if test = '$country != $corpusCountry'>
                <xsl:message terminate="yes"
                             select="concat('FATAL ERROR: TEI corpus country = ', $corpusCountry, 
                                     ' does not match TSV country = ', $country,
                                     ' in TSV line&#10;', .)"/>
              </xsl:if>
              <xsl:if test = "$role != 'minister'">
                <xsl:message terminate="yes"
                             select="concat('FATAL ERROR: Role ', $role, 
                                     ' does not match minister! TSV is:&#10;', .)"/>
              </xsl:if>
              <xsl:choose>
                <xsl:when test = "not(key('id', $personID, $listPerson))">
                  <xsl:message terminate="no"
                               select="concat('WARN: TSV person ', $personID, 
                                       ' not found in TEI corpus, skipping!')"/>
                </xsl:when>
                <xsl:otherwise>
                  <!--xsl:message select="concat('INFO: Found minister ', $personID)"/-->
                  <xsl:call-template name="parse-minister">
                    <xsl:with-param name="personID" select="$personID"/>
                    <xsl:with-param name="from" select="$from"/>
                    <xsl:with-param name="to" select="$to"/>
                    <xsl:with-param name="govtTermID" select="$govtTermID"/>
                    <xsl:with-param name="ministryID" select="$ministryID"/>
                    <xsl:with-param name="orgName-xx" select="$orgName-xx"/>
                    <xsl:with-param name="orgName-en" select="$orgName-en"/>
                    <xsl:with-param name="url" select="$url"/>
                  </xsl:call-template>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
              <xsl:message terminate="yes"
                           select="concat('FATAL ERROR: Bad line in TSV: ', .)"/>
            </xsl:non-matching-substring>
          </xsl:analyze-string>
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
        <xsl:variable name="id" select="@xml:id"/>
        <xsl:for-each select="$minister/tei:affiliation">
          <xsl:message select="concat('INFO: Inserting affiliation ', @role, ' for ', $id, 
                               ' from &#34;', @from, '&#34; to &#34;', @to, '&#34;')"/>
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

  <xsl:template name="parse-minister">
    <xsl:param name="personID"/>
    <xsl:param name="from"/>
    <xsl:param name="to"/>
    <xsl:param name="govtTermID"/>
    <xsl:param name="ministryID"/>
    <xsl:param name="orgName-xx"/>
    <xsl:param name="orgName-en"/>
    <xsl:param name="url"/>
    <person xml:id="{$personID}">
      
      <!-- Check if $from, $to exists and are well formed, if so, they get put in $from-ok, $to-ok -->
      <xsl:variable name="from-ok">
        <xsl:if test="et:has-content($from)">
	  <xsl:choose>
	    <xsl:when test="$from castable as xs:date">
              <xsl:value-of select="$from"/>
	    </xsl:when>
	    <xsl:otherwise>
              <xsl:message select="concat('ERROR: Date from &#34;', $from, '&#34; is not a proper date.')"/>
	    </xsl:otherwise>
	  </xsl:choose>
        </xsl:if>
      </xsl:variable>
      <xsl:variable name="to-ok">
        <xsl:if test="et:has-content($to)">
	  <xsl:choose>
	    <xsl:when test="$to castable as xs:date">
              <xsl:value-of select="$to"/>
	    </xsl:when>
	    <xsl:otherwise>
              <xsl:message select="concat('ERROR: Date to &#34;', $to, '&#34; is not a proper date.')"/>
	    </xsl:otherwise>
	  </xsl:choose>
        </xsl:if>
      </xsl:variable>

      <!-- Insert that they are - by definition - a member of the governemnt -->
      <xsl:choose>
        <xsl:when test="normalize-space($govtID)">
          <affiliation role="member" ref="{concat('#', $govtID)}">
            <xsl:if test="normalize-space($from-ok)">
              <xsl:attribute name="from" select="$from-ok"/>
            </xsl:if>
            <xsl:if test="normalize-space($to-ok)">
              <xsl:attribute name="to" select="$to-ok"/>
            </xsl:if>
          </affiliation>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>ERROR: Government ID not found in TEI corpus!</xsl:message>
        </xsl:otherwise>
      </xsl:choose>
      
      <!-- Impicit check if $govtTermID in fact corresponds to an ID -->
      <xsl:variable name="govtEvent">
        <xsl:if test="normalize-space($govtTermID)">
          <xsl:value-of select="key('id', $govtTermID, $listOrg)/self::tei:event/@xml:id"/>
        </xsl:if>
      </xsl:variable>
      
      <affiliation role="minister">
        <xsl:if test="normalize-space($from-ok)">
          <xsl:attribute name="from" select="$from-ok"/>
        </xsl:if>
        <xsl:if test="normalize-space($to-ok)">
          <xsl:attribute name="to" select="$to-ok"/>
        </xsl:if>

        <!-- Everything that goes in @ref -->
        <xsl:variable name="ref">
          <!-- Ref to government org -->
          <xsl:if test="normalize-space($govtID)">
            <xsl:value-of select="concat('#', $govtID)"/>
          </xsl:if>
          <xsl:text>&#32;</xsl:text>

          <!-- Referece to the ministry org, if it exists -->
          <xsl:if test="et:has-content($ministryID)">
	    <xsl:variable name="miniOrg" select="key('id', $ministryID, $listOrg)/tei:org/@xml:id"/>
	    <xsl:choose>
	      <xsl:when test="normalize-space($miniOrg)">
		<xsl:value-of select="concat('#', normalize-space($miniOrg))"/>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:message select="concat('ERROR: Cant find ministry &#34;', 
                                     $ministryID, '&#34; in listOrg header, ignoring!')"/>
	      </xsl:otherwise>
	    </xsl:choose>
          </xsl:if>
        </xsl:variable>
        <xsl:if test="normalize-space($ref)">
	  <xsl:attribute name="ref" select="normalize-space($ref)"/>
        </xsl:if>

        <!-- Source URL, if it exists -->
        <xsl:if test="et:has-content($url)">
          <xsl:attribute name="source" select="$url"/>
        </xsl:if>
        
        <!-- The term of the government, if it exists -->
        <xsl:if test="et:has-content($govtTermID)">
          <xsl:choose>
            <xsl:when test="normalize-space($govtEvent)">
              <xsl:attribute name="ana" select="concat('#', $govtEvent)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:message select="concat('WARN: Cant find government term with ID &#34;', 
                                   $govtTermID, '&#34; in listOrg, inserting as note.')"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>

        <!-- Name of ministry in source language and English, if it exists -->
        <xsl:if test="et:has-content($orgName-xx)">
          <orgName full="yes">
            <xsl:value-of select="$orgName-xx"/>
          </orgName>
        </xsl:if>
        <xsl:if test="et:has-content($orgName-en)">
          <orgName full="yes" xml:lang="en">
            <xsl:value-of select="$orgName-en"/>
          </orgName>
        </xsl:if>
	<xsl:if test="et:has-content($govtTermID) and not(normalize-space($govtEvent))">
	  <note type="period">
            <xsl:value-of select="$govtTermID"/>
	  </note>
	</xsl:if>
      </affiliation>

    </person>
  </xsl:template>
  
  <xsl:function name="et:has-content" as="xs:boolean">
    <xsl:param name="str" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="not(normalize-space($str))">
        <xsl:value-of select="false()"/>
      </xsl:when>
      <xsl:when test="$str = '-'">
        <xsl:value-of select="false()"/>
      </xsl:when>
      <xsl:when test="$str = '0'">
        <xsl:value-of select="false()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="true()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

</xsl:stylesheet>
