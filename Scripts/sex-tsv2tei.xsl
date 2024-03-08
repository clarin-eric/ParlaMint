<?xml version='1.0' encoding='UTF-8'?>
<!-- Insert information about persons sex from TSV file into <listPerson>.
     Input TSVs must have appropriate header row
     Existing sex meta-data of persons in TSV are overwritten.

     Fake example:
     TSV input:

     country	id	surname	forename	sex
     BA	AhmetovićSadik	Sadik	Ahmetović	M
     BA	AjanovićEkrem	Ekrem	Ajanović	M

     TEI input:
     <person xml:id="AhmetovićSadik" n="RE171">
        <persName>
          <surname>Ahmetović</surname>
          <forename>Sadik</forename>
        </persName>
        ...
     </person>

     TEI output:
     <person xml:id="AhmetovićSadik" n="RE171">
        <persName>
          <surname>Ahmetović</surname>
          <forename>Sadik</forename>
        </persName>
        <sex value="M"/>
        ...
     </person>
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

  <xsl:output method="xml" indent="yes" omit-xml-declaration="no"/>
  
  <xsl:key name="person" match="tei:person" use="@xml:id"/>

  <xsl:variable name="country"
                select="replace(/tei:listPerson/@xml:id, 
                        '.+ParlaMint-([A-Z]{2}(-[A-Z0-9]{1,3})?).*', 
                        '$1')"/>
  
  <!-- Parse TSV into a listPerson/person/sex structures -->
  <xsl:variable name="data">
    <listPerson>
      <xsl:variable name="tsv" select="replace(unparsed-text($tsv, 'UTF-8'), '&#x0D;', '')"/>
      <xsl:variable name="table" select="et:tsv2table($tsv)"/>
      <xsl:for-each select="$table/tei:row">
	<xsl:variable name="country" select="tei:cell[@type='country']"/>
	<xsl:variable name="id" select="tei:cell[@type='id']"/>
	<xsl:variable name="sex" select="tei:cell[@type='sex']"/>
	<xsl:choose>
	  <xsl:when test="not(normalize-space($sex))">
            <xsl:message terminate="yes" select="concat('ERROR: For ', $country, ' ', $id, ' no sex info')"/>
	  </xsl:when>
	  <xsl:when test="not(matches($sex, '^[MFU]$'))">
            <xsl:message select="concat('ERROR: For ', $country, ' ', $id, ' bad sex value ', $sex)"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <person xml:id="{$id}">
              <sex value="{$sex}"/>
            </person>
          </xsl:otherwise>
	</xsl:choose>
      </xsl:for-each>
    </listPerson>
  </xsl:variable>
  
  <xsl:template match="/">
    <xsl:if test="not(unparsed-text-available($tsv))">
      <xsl:message select="concat('FATAL ERROR: TSV file ', $tsv, ' not found')"/>
    </xsl:if>
    <xsl:text>&#10;</xsl:text>
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="tei:listPerson/tei:person">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates mode="insert" select="."/>
    </xsl:copy>
  </xsl:template>

  <!-- Insert $data <sex>s into <person> -->
  <xsl:template mode="insert" match="tei:person">
    <xsl:variable name="id" select="@xml:id"/>
    <xsl:variable name="person" select="key('person', $id, $data)"/>
    <xsl:choose>
      <!-- If this person is in TSV -->
      <xsl:when test="$person/self::tei:person">
        <xsl:if test="tei:sex">
          <xsl:message select="concat('INFO: For person ', $id, ' removing sex ', tei:sex/@value)"/>
        </xsl:if>
        <xsl:message select="concat('INFO: For person ', $id, ' inserting sex ', $person/tei:sex/@value)"/>
        <xsl:apply-templates select="tei:persName"/>
        <xsl:copy-of select="$person/tei:sex"/>
        <xsl:apply-templates select="tei:*[not(self::tei:persName or self::tei:sex)]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
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
  <!-- Parse TSV file into a <table>, TSV should have header row which gives cell/@type values -->
  <xsl:function name="et:tsv2table">
    <xsl:param name="tsv"/>
    <xsl:variable name="labels" select="tokenize($tsv, '&#10;')[1]"/>
    <table>
      <xsl:for-each select="tokenize($tsv, '&#10;')">
	<xsl:if test="matches(., '\t') and not(matches(., '^country', 'i'))">
	  <xsl:variable name="row" select="et:row2table($labels, .)"/>
	  <row>
	    <xsl:copy-of select="$row"/>
	  </row>
	</xsl:if>
      </xsl:for-each>
    </table>
  </xsl:function>

  <!-- Parse TSV file row into <cell>s -->
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
