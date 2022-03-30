<?xml version='1.0' encoding='UTF-8'?>
<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:eg="http://www.tei-c.org/ns/Examples"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:pm="ParlaMint"
    exclude-result-prefixes="xsl pm">
  <xsl:output indent="yes"/>

  <xsl:param name="tei_odd"/>

  <xsl:variable name="all_included_attrs" select="concat(' ',fn:string-join(/tei:schemaSpec/tei:classRef/@include,' '),' ')"/>

  <!-- print WARNING when exclude is used !!! -->

  <xsl:template match="tei:classRef[@include='']" />

  <xsl:template match="tei:attList[ancestor::tei:elementSpec[@ident]]">
    <xsl:copy>
      <xsl:apply-templates select="tei:attRef | tei:attDef | tei:attList | comment()"/>
      <!--delete all attributes that are listed in classRef/@include and not listed in attList-->
      <xsl:variable name="elem" select="./ancestor::tei:elementSpec[@ident][1]/@ident"/>
      <xsl:choose>
        <xsl:when test="./tei:attDef[@mode='delete']">
          <xsl:message>SKIPPING attribute modification: <xsl:value-of select="$elem"/></xsl:message>
        </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="pm:attPreserve" />
        <xsl:call-template name="attributes-to-delete">
          <xsl:with-param name="elem" select="$elem"/>
          <xsl:with-param name="ident" select="$elem"/>
          <xsl:with-param name="list" select="."/>
        </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="pm:attPreserve">
    <xsl:comment><xsl:value-of select="./ancestor::tei:elementSpec[@ident][1]/@ident"/>/@<xsl:value-of select="./@ident"/></xsl:comment>
  </xsl:template>

  <xsl:template match="tei:* | eg:*">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="tei:* | eg:* | text() | comment()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@*">
    <xsl:copy/>
  </xsl:template>

  <xsl:template match="comment()">
    <xsl:copy/>
  </xsl:template>

  <xsl:template name="attributes-to-delete">
    <xsl:param name="elem"/>
    <xsl:param name="ident"/>
    <xsl:param name="list"/>
    <xsl:for-each select="document($tei_odd)//tei:*[@ident=$ident]">
      <!-- check attributes -->
      <xsl:for-each select="./tei:attList/tei:attDef/@ident | ./tei:attList/tei:attRef/@name">
        <xsl:variable name="attr" select="." />
        <!--<xsl:if test="contains($all_included_attrs, concat(' ',$attr,' '))">-->
          <xsl:if test="not($list//tei:attDef[@ident=$attr] | $list//tei:attRef[@name=$attr] | $list//pm:attPreserve[@ident=$attr])">
            <xsl:message>REMOVING <xsl:value-of select="$elem"/>/@<xsl:value-of select="$attr"/></xsl:message>
            <xsl:element namespace="http://www.tei-c.org/ns/1.0" name="attDef">
              <xsl:attribute name="ident" select="$attr"/>
              <xsl:attribute name="mode" select="'delete'"/>
            </xsl:element>
          </xsl:if>
        <!--</xsl:if>-->
      </xsl:for-each>
      <xsl:for-each select="./tei:classes/tei:memberOf[@key]">
        <!-- check classes -->
        <xsl:call-template name="attributes-to-delete">
          <xsl:with-param name="elem" select="$elem"/>
          <xsl:with-param name="ident" select="./@key"/>
          <xsl:with-param name="list" select="$list"/>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>