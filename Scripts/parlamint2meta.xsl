<?xml version="1.0"?>
<!-- Transform one ParlaMint file to a TSV file with its metadata. -->
<!-- Includes header row, cf. template for tei:TEI -->
<!-- Needs the file with corpus teiHeader giving the speaker, party etc. info as the "meta" parameter -->
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
  
  <xsl:template match="tei:TEI">
    <xsl:message select="concat('INFO: Converting ', @xml:id, ' to metadata TSV')"/>
    <xsl:text>Text_ID&#9;</xsl:text>
    <xsl:text>ID&#9;</xsl:text>
    <xsl:text>Title&#9;</xsl:text>
    <xsl:text>Date&#9;</xsl:text>
    <xsl:text>Body&#9;</xsl:text>
    <xsl:text>Term&#9;</xsl:text>
    <xsl:text>Session&#9;</xsl:text>
    <xsl:text>Meeting&#9;</xsl:text>
    <xsl:text>Sitting&#9;</xsl:text>
    <xsl:text>Agenda&#9;</xsl:text>
    <xsl:text>Subcorpus&#9;</xsl:text>
    <xsl:text>Lang&#9;</xsl:text>
    <xsl:text>Speaker_role&#9;</xsl:text>
    <xsl:text>Speaker_MP&#9;</xsl:text>
    <xsl:text>Speaker_minister&#9;</xsl:text>
    <xsl:text>Speaker_party&#9;</xsl:text>
    <xsl:text>Speaker_party_name&#9;</xsl:text>
    <xsl:text>Party_status&#9;</xsl:text>
    <xsl:text>Party_orientation&#9;</xsl:text>
    <xsl:text>Speaker_ID&#9;</xsl:text>
    <xsl:text>Speaker_name&#9;</xsl:text>
    <xsl:text>Speaker_gender&#9;</xsl:text>
    <xsl:text>Speaker_birth</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:apply-templates select=".//tei:u"/>
  </xsl:template>
  
  <xsl:template match="tei:u">
    <xsl:variable name="lang">
      <xsl:call-template name="u-langs"/>
    </xsl:variable>
    <!-- Text metadata -->
    <xsl:value-of select="concat($text_id, '&#9;')"/>
    <xsl:value-of select="concat(@xml:id, '&#9;')"/>
    <xsl:value-of select="concat($title, '&#9;')"/>
    <xsl:value-of select="concat($at-date, '&#9;')"/>
    <xsl:value-of select="concat($body, '&#9;')"/>
    <xsl:value-of select="concat($term, '&#9;')"/>
    <xsl:value-of select="concat($session, '&#9;')"/>
    <xsl:value-of select="concat($meeting, '&#9;')"/>
    <xsl:value-of select="concat($sitting, '&#9;')"/>
    <xsl:value-of select="concat($agenda, '&#9;')"/>
    <xsl:value-of select="concat($subcorpus, '&#9;')"/>
    <xsl:value-of select="concat($lang, '&#9;')"/>
    <!-- Speaker metadata -->
    <xsl:value-of select="concat(et:u-role(@ana), '&#9;')"/>
    <xsl:variable name="speaker" select="key('idr', @who, $rootHeader)"/>
    <xsl:choose>
      <xsl:when test="not(@who or normalize-space($speaker))">
        <xsl:if test="@who and not(normalize-space($speaker))">
          <xsl:message select="concat('ERROR: Cant find speaker for ', @who, ' in ', @xml:id)"/>
        </xsl:if>
        <xsl:text>-&#9;</xsl:text>
        <xsl:text>-&#9;</xsl:text>
        <xsl:text>-&#9;</xsl:text>
        <xsl:text>-&#9;</xsl:text>
        <xsl:text>-&#9;</xsl:text>
        <xsl:text>-&#9;</xsl:text>
        <xsl:text>-&#9;</xsl:text>
        <xsl:text>-&#9;</xsl:text>
        <xsl:text>-&#9;</xsl:text>
        <xsl:text>-</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat(et:speaker-mp($speaker), '&#9;')"/>
        <xsl:value-of select="concat(et:speaker-minister($speaker), '&#9;')"/>
        <xsl:value-of select="concat(et:speaker-party($speaker, 'abb'), '&#9;')"/>
        <xsl:value-of select="concat(et:speaker-party($speaker, 'yes'), '&#9;')"/>
        <xsl:value-of select="concat(et:party-status($speaker), '&#9;')"/>
        <xsl:value-of select="concat(et:party-orientation($speaker), '&#9;')"/>
        <xsl:value-of select="concat(substring-after(@who, '#'), '&#9;')"/>
        <xsl:value-of select="concat(et:format-name-chrono($speaker//tei:persName, $at-date), '&#9;')"/>
        <xsl:value-of select="concat(et:tsv-value($speaker/tei:sex/@value), '&#9;')"/>
        <xsl:value-of select="et:tsv-value(replace($speaker/tei:birth/@when, '-.+', ''))"/>
      </xsl:otherwise>
    </xsl:choose>
    <!-- Speech sizes? -->
    <!--xsl:value-of select="count(.//tei:w) + count(.//tei:pc)"/-->
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
  
</xsl:stylesheet>
