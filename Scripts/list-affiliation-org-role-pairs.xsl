<?xml version="1.0" encoding="UTF-8"?>
<!--  -->
<xsl:stylesheet 
    xmlns="http://www.tei-c.org/ns/1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:et="http://nl.ijs.si/et"
    xmlns:mk="http://ufal.mff.cuni.cz/matyas-kopp"
    exclude-result-prefixes="tei et mk"
    version="2.0">

  <xsl:import href="parlamint-lib.xsl"/>
  
  <xsl:output encoding="utf-8" method="text"/>
  
  <xsl:variable name="country" select="replace(replace(document-uri(/), 
				       '.+/([^/]+)\.xml', '$1'), 
				       'ParlaMint-([^._]+).*', '$1')"/>
  <xsl:template match="/">
    <xsl:apply-templates select="$rootHeader"/>
  </xsl:template>

  <xsl:template match="text()"/>
  <xsl:template match="tei:*">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="@*"/>


  <xsl:template match="tei:affiliation">
    <xsl:variable name="aff-role" select="./@role"/>
    <xsl:variable name="org-role" select="mk:get_org_role(./@ref)"/>
    <xsl:value-of select="mk:print_roles($aff-role,$org-role)"/>
  </xsl:template>


  <xsl:function name="mk:get_org_role">
    <xsl:param name="ref"/>
    <xsl:variable name="local-id" select="substring-after($ref,'#')"/>
    <xsl:choose>
      <xsl:when test="not($local-id)"/>
      <xsl:when test="key('idr', $ref, $rootHeader)/name()='org'">
        <xsl:variable name="org" select="key('idr', $ref, $rootHeader)"/>
        <xsl:choose>
          <xsl:when test="key('idr', $ref, $rootHeader)/@role">
	    <xsl:value-of select="key('idr', $ref, $rootHeader)/@role"/>
	  </xsl:when>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="mk:print_roles">
    <xsl:param name="aff"/>
    <xsl:param name="org"/>
    <xsl:message>
              <xsl:value-of select="$country"/>
              <xsl:text>&#32;</xsl:text>
              <xsl:value-of select="$aff"/>
              <xsl:text>&#32;</xsl:text>
              <xsl:value-of select="$org"/>
    </xsl:message>
  </xsl:function>

</xsl:stylesheet>
