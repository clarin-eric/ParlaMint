<?xml version='1.0' encoding='UTF-8'?>
<!-- Insert minister affiliations from TSV into the TEI root file or directly into the listPersons file
     Note that all existing minister affiliations in TEI and removed
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  exclude-result-prefixes="fn tei">
  
  <xsl:import href="parlamint-lib.xsl"/>
  
  <!-- File with TSV data -->
  <xsl:param name="tsv"/>
  
  <xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="no"/>
  <xsl:variable name="profileDesc" select="$rootHeader//tei:profileDesc"/>
  
  <!-- NOTE: we have to discuss how to name "regions" in setting! -->
  <xsl:variable name="corpusCountry"
                select="$profileDesc/
                        tei:settingDesc/tei:setting/tei:name
                        [@type = 'country' or @type = 'region']/@key"/>
  
  <!-- Parse TSV into a 
       listPerson/person[@xml:id]/affiliation[@role='minister']@from][@to][@ref][@ana] 
       structure -->
  <xsl:variable name="data">
    <listPerson>
      <xsl:variable name="text" select="unparsed-text($tsv, 'UTF-8')"/>
      <xsl:for-each select="tokenize($text, '&#10;')">
        <xsl:if test="matches(., '\t') and not(matches(., '^Country'))">
          <xsl:analyze-string select="."
                              regex="^([^\t]+)\t([^\t]+)\t([^\t]+)\t([^\t]*)\t([^\t]*)\t?([^\t]*)\t?([^\t]*)\t?([^\t]*)\t?([^\t]*).*">
            <xsl:matching-substring>
              <xsl:variable name="country" select="regex-group(1)"/>
              <xsl:variable name="personID" select="regex-group(2)"/>
              <xsl:variable name="role" select="regex-group(3)"/>
              <xsl:variable name="from" select="regex-group(4)"/>
              <xsl:variable name="to" select="regex-group(5)"/>
              <xsl:variable name="government" select="regex-group(6)"/>
              <xsl:variable name="ministry" select="regex-group(7)"/>
              <xsl:variable name="name-xx" select="regex-group(8)"/>
              <xsl:variable name="name-en" select="regex-group(9)"/>
              <xsl:if test = '$country != $corpusCountry'>
                <xsl:message terminate="yes"
                             select="concat('FATAL: TEI corpus country = ', $corpusCountry, 
                                     ' does not match TSV country = ', $country,
                                     ' in TSV line&#10;', .)"/>
              </xsl:if>
              <xsl:if test = "$role != 'minister'">
                <xsl:message terminate="yes"
                             select="concat('FATAL: Role ', $role, 
                                     ' does not match minister! TSV is:&#10;', .)"/>
              </xsl:if>
              <xsl:choose>
                <xsl:when test = "not(key('id', $personID, $profileDesc)/self::tei:person)">
                  <xsl:message terminate="no"
                               select="concat('WARN: Person ', $personID, 
                                       ' not found in TEI corpus, skipping! TSV is:&#10;', .)"/>
                </xsl:when>
                <xsl:otherwise>
                  <!--xsl:message select="concat('INFO: Found minister ', $personID)"/-->
                  <xsl:call-template name="parse-minister">
                    <xsl:with-param name="personID" select="$personID"/>
                    <xsl:with-param name="from" select="$from"/>
                    <xsl:with-param name="to" select="$to"/>
                    <xsl:with-param name="government" select="$government"/>
                    <xsl:with-param name="ministry" select="$ministry"/>
                    <xsl:with-param name="name-xx" select="$name-xx"/>
                    <xsl:with-param name="name-en" select="$name-en"/>
                  </xsl:call-template>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
              <xsl:message terminate="yes"
                           select="concat('FATAL: Bad line in TSV: ', .)"/>
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

  <xsl:template name="parse-minister">
    <xsl:param name="personID"/>
    <xsl:param name="from"/>
    <xsl:param name="to"/>
    <xsl:param name="government"/>
    <xsl:param name="ministry"/>
    <xsl:param name="name-xx"/>
    <xsl:param name="name-en"/>
    <person xml:id="{$personID}">
      <affiliation role="minister">
        <!-- Re-insert # in references to IDs for affiliation/@ref -->
        <xsl:if test="normalize-space($from) and $from != '-'">
          <xsl:attribute name="from" select="$from"/>
        </xsl:if>
        <xsl:if test="normalize-space($to) and $to != '-'">
          <xsl:attribute name="to" select="$to"/>
        </xsl:if>
        <xsl:if test="normalize-space($government) and $government != '-'">
          <xsl:attribute name="ref">
            <xsl:variable name="org" select="key('id', $government, $profileDesc)/
                                             ancestor::tei:org/@xml:id"/>
            <xsl:choose>
              <xsl:when test = "not(normalize-space($org))">
                <xsl:message terminate="no"
                             select="concat('ERROR: Cant find government organisation for term ', 
                                     $government
                                     , .)"/>
                <!-- #, '! TSV is:&#10;' -->
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="concat('#', $org)"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
        </xsl:if>
        <xsl:if test="(normalize-space($government) and $government != '-') or
                      (normalize-space($ministry) and $ministry != '-')">
          <xsl:variable name="ana">
            <xsl:if test="normalize-space($government) and $government != '-'">
              <xsl:value-of select="concat('#', replace($government, ' ', ' #'))"/>
            </xsl:if>
            <xsl:text>&#32;</xsl:text>
            <xsl:if test="normalize-space($ministry) and $ministry != '-'">
              <xsl:value-of select="concat('#', replace($ministry, ' ', ' #'))"/>
            </xsl:if>
          </xsl:variable>
          <xsl:attribute name="ana" select="normalize-space($ana)"/>
        </xsl:if>
        <xsl:if test="(normalize-space($name-xx) and $name-xx != '-')">
          <roleName>
            <xsl:value-of select="normalize-space($name-xx)"/>
          </roleName>
        </xsl:if>
        <xsl:if test="(normalize-space($name-en) and $name-en != '-')">
          <roleName xml:lang="en">
            <xsl:value-of select="normalize-space($name-en)"/>
          </roleName>
        </xsl:if>
      </affiliation>
    </person>
  </xsl:template>
  
</xsl:stylesheet>
