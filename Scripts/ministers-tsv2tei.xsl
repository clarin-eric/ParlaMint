<?xml version='1.0' encoding='UTF-8'?>
<!-- Insert minister affiliations from TSV into the the listPersons file
     Note that all existing minister affiliations in TEI and removed
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
  
  <xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="no"/>

  <!-- Get country of corpus from filename -->
  <xsl:variable name="corpusCountry"
                select="replace(base-uri(), 
                        '.*ParlaMint-([A-Z]{2}(-[A-Z0-9]{1,3})?).*', 
                        '$1')"/>
  <xsl:variable name="listPerson" select="/tei:listPerson"/>
  
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
              <xsl:variable name="name-xx" select="normalize-space(regex-group(8))"/>
              <xsl:variable name="name-en" select="normalize-space(regex-group(9))"/>
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
                               select="concat('ERROR: Person ', $personID, 
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
                    <xsl:with-param name="name-xx" select="$name-xx"/>
                    <xsl:with-param name="name-en" select="$name-en"/>
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
        <xsl:message select="concat('INFO: Inserting minister affiliation(s) for &#34;', 
			     @xml:id, '&#34;')"/>
        <xsl:for-each select="$minister/tei:affiliation">
          <xsl:message select="concat('INFO: Inserting affiliation &#34;', 
                               @role, '&#34; from &#34;', @from, '&#34; to &#34;', 
			       @to, '&#34;')"/>
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
    <xsl:param name="name-xx"/>
    <xsl:param name="name-en"/>
    <xsl:param name="url"/>
    <person xml:id="{$personID}">
      <affiliation role="minister">
        <xsl:if test="et:has-content($from)">
	  <xsl:choose>
	    <xsl:when test="$from castable as xs:date">
              <xsl:attribute name="from" select="$from"/>
	    </xsl:when>
	    <xsl:otherwise>
              <xsl:message terminate="no"
                           select="concat('ERROR: Date &#34;', $from, '&#34; is not a proper date.')"/>
	    </xsl:otherwise>
	  </xsl:choose>
        </xsl:if>
        <xsl:if test="et:has-content($to)">
          <xsl:attribute name="to" select="$to"/>
        </xsl:if>
        <xsl:variable name="govtEvent" select="key('id', $govtTermID, $listPerson)/
                                               self::tei:event/@xml:id"/>
        <xsl:if test="et:has-content($govtTermID)">
          <xsl:choose>
            <xsl:when test = "not(normalize-space($govtEvent))">
              <xsl:message terminate="no"
                           select="concat('WARN: Cant find government term with ID &#34;', 
                                   $govtTermID, '&#34; in corpus header, inserting as note.')"/>
            </xsl:when>
            <xsl:otherwise>
	      <!-- Re-insert # in references to ID for affiliation/@ref -->
	      <xsl:attribute name="ref" select="concat('#', $govtEvent)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
        <xsl:if test="et:has-content($govtTermID) or 
                      et:has-content($ministryID)">
	  <xsl:variable name="govOrg" select="key('id', $govtTermID, $listPerson)/tei:org/@xml:id"/>
	  <xsl:variable name="miniOrg" select="key('id', $ministryID, $listPerson)/tei:org/@xml:id"/>
	  <xsl:variable name="ana">
            <xsl:if test="et:has-content($govtTermID)">
	      <xsl:if test="normalize-space($govOrg)">
		<xsl:value-of select="concat('#', normalize-space($govtTermID))"/>
	      </xsl:if>
            </xsl:if>
            <xsl:text>&#32;</xsl:text>
            <xsl:if test="et:has-content($ministryID)">
	      <xsl:choose>
		<xsl:when test="normalize-space($miniOrg)">
		  <xsl:value-of select="concat('#', normalize-space($miniOrg))"/>
		</xsl:when>
		<xsl:otherwise>
		  <xsl:message select="concat('ERROR: Cant find ministry &#34;', 
                                       $ministryID, '&#34; in corpus header, ignoring!')"/>
		</xsl:otherwise>
	      </xsl:choose>
            </xsl:if>
          </xsl:variable>
	  <xsl:if test="normalize-space($ana)">
            <xsl:attribute name="ana" select="normalize-space($ana)"/>
	  </xsl:if>
        </xsl:if>
        <xsl:if test="et:has-content($url)">
          <xsl:attribute name="source" select="$url"/>
        </xsl:if>
        <xsl:if test="et:has-content($name-xx)">
          <orgName full="yes">
            <xsl:value-of select="$name-xx"/>
          </orgName>
        </xsl:if>
        <xsl:if test="et:has-content($name-en)">
          <orgName full="yes" xml:lang="en">
            <xsl:value-of select="$name-en"/>
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
