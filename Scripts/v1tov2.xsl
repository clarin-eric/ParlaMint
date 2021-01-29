<?xml version='1.0' encoding='UTF-8'?>
<!-- Fix bugs from ParlaMint V1 for V2 -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  exclude-result-prefixes="fn tei">
  <xsl:output indent="yes"/>
  <xsl:strip-space elements="*"/>
  <xsl:preserve-space elements="tei:change tei:seg"/>

  <xsl:param name="version">2.0</xsl:param>
  <xsl:param name="handle">http://hdl.handle.net/11356/1388</xsl:param>
  <xsl:param name="change">
    <change when="{$today-iso}"><name>Tomaž Erjavec</name>: Small fixes for Version 2.</change>
  </xsl:param>
  <xsl:variable name="today-iso" select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>
  <xsl:variable name="id" select="/tei:*/@xml:id"/>
  
  <xsl:template match="/">
    <!--xsl:message terminate="yes">
      <xsl:text>INFO: converting </xsl:text>
      <xsl:value-of select="tei:*/@xml:id"/>
    </xsl:message-->
    <xsl:text>&#10;</xsl:text>
    <xsl:apply-templates/>
  </xsl:template>

  <!-- STAMP -->
  <xsl:template match="tei:editionStmt/tei:edition">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:value-of select="$version"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:idno[@type='handle']">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:value-of select="$handle"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:publicationStmt/tei:date">
    <xsl:copy>
      <xsl:attribute name="when" select="$today-iso"/>
      <xsl:value-of select="$today-iso"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- Put in <revisionDesc> if there is none in the teiHeader -->
  <xsl:template match="tei:teiHeader">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
      <xsl:if test="not(tei:revisionDesc)">
	<revisionDesc>
	  <xsl:copy-of select="$change"/>
	</revisionDesc>
      </xsl:if>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="tei:revisionDesc">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:copy-of select="$change"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
    
  <!-- FIX -->

  <!-- <orgName> without @full
       https://github.com/clarin-eric/ParlaMint/issues/1
  -->
  <xsl:template match="tei:org/tei:orgName[not(@full)]">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:message select="concat('WARN ', $id, ': adding @full=yes to ', .)"/>
      <xsl:attribute name="full">yes</xsl:attribute>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <!-- Root id != file name for .ana. files 
       https://github.com/clarin-eric/ParlaMint/issues/2      
  -->
  <xsl:template match="tei:teiCorpus | tei:TEI">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:variable name="id" select="replace(document-uri(/), '.+/([^/]+)\.xml', '$1')"/>
      <xsl:if test="@xml:id != $id">
	<xsl:attribute name="xml:id" select="$id"/>
	<xsl:message select="concat('WARN: changing root ID ', @xml:id, ' to ', $id)"/>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <!-- Wrong language in prefixDef/@ident="mte" for SI
       https://github.com/clarin-eric/ParlaMint/issues/7
  -->
  <xsl:template match="tei:teiCorpus[@xml:lang='sl']/tei:teiHeader//tei:prefixDef[@ident='mte']">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="replacementPattern">
	<xsl:text>http://nl.ijs.si/ME/V6/msd/tables/msd-fslib-sl.xml#$1</xsl:text>
      </xsl:attribute>
      <xsl:message select="concat('WARN ', $id, ': changing SI MTE prefixDef')"/>
      <p xml:lang="en">
	<xsl:value-of select="replace(., 'Serbocroatian', 'Slovenian')"/>
      </p>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:prefixDef/tei:p[not(@xml:lang)]">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:message select="concat('WARN ', $id, ': giving @xml:lang=en to p with ', .)"/>
      <xsl:attribute name="xml:lang">en</xsl:attribute>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <!-- Bad affiliation/@role values in BG
       https://github.com/clarin-eric/ParlaMint/issues/8
  -->
  <xsl:template match="tei:affiliation/@role">
    <xsl:variable name="role">
      <xsl:choose>
	<xsl:when test=". = 'deputyPrimeMinster'">deputyPrimeMinister</xsl:when>
	<xsl:when test=". = 'candidate-chairman'">candidateChairman</xsl:when>
	<xsl:when test=". = 'chair-of-parliament'">chairman</xsl:when>
	<xsl:when test=". = 'chairperson'">chairman</xsl:when>
	<xsl:when test=". = 'head-of-department'">headOfDepartment</xsl:when>
	<xsl:when test=". = 'prosecutor-general'">prosecutorGeneral</xsl:when>
	<xsl:when test=". = 'vice-chairman'">viceChairman</xsl:when>
	<xsl:when test=". = 'vice-chair-of-parliament'">viceChairman</xsl:when>
	<xsl:when test=". = 'vice-director'">viceDirector</xsl:when>
	<xsl:when test=". = 'vice-president'">vicePresident</xsl:when>
	<xsl:otherwise>
	  <xsl:if test="matches(., '[_-]')">
	    <xsl:message terminate="yes"
			 select="concat('ERROR ', $id, ': uncaught bad affiliation/@role = ', .)"/>
	  </xsl:if>
	  <xsl:value-of select="."/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:attribute name="role">
      <xsl:if test=". != $role">
	<xsl:message select="concat('WARN ', $id, ': changing role from ', . , ' to ', $role)"/>
      </xsl:if>
      <xsl:value-of select="$role"/>
    </xsl:attribute>
  </xsl:template>
  
  <!-- Bad org/@role values
       https://github.com/clarin-eric/ParlaMint/issues/9
  -->
  <xsl:template match="tei:org/@role">
    <xsl:variable name="role">
      <xsl:choose>
	<xsl:when test=". = 'political_party'">politicalParty</xsl:when>
	<xsl:when test=". = 'ethnic_communities'">ethnicCommunity</xsl:when>
	<xsl:otherwise>
	  <xsl:if test="matches(., '[_-]')">
	    <xsl:message terminate="yes"
			 select="concat('ERROR ', $id, ': uncaught bad org/@role = ', .)"/>
	  </xsl:if>
	  <xsl:value-of select="."/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:attribute name="role">
      <xsl:if test=". != $role">
	<xsl:message select="concat('WARN ', $id, ': changing role from ', . , ' to ', $role)"/>
      </xsl:if>
      <xsl:value-of select="$role"/>
    </xsl:attribute>
  </xsl:template>
  
  <!-- Bad English translation
       https://github.com/clarin-eric/ParlaMint/issues/12
  -->
  <xsl:template match="tei:teiCorpus[@xml:lang='bg']//tei:event/tei:label[. = 'Term 7']">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:message select="concat('WARN ', $id, ': giving better translation for ', .)"/>
      <xsl:text>Term 43</xsl:text>
    </xsl:copy>
  </xsl:template>
  
  
  <!-- Add text/@ana
       https://github.com/clarin-eric/ParlaMint/issues/24
  -->
  <xsl:template match="tei:text[not(@ana)]">
    <xsl:variable name="subcorpus">
      <xsl:choose>
	<xsl:when test="contains(ancestor::tei:TEI/@ana, '#reference')">#reference</xsl:when>
	<xsl:when test="contains(ancestor::tei:TEI/@ana, '#covid')">#covid</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:message select="concat('WARN ', $id, ': giving text/@ana = ', $subcorpus, ' to ', $id)"/>
      <xsl:attribute name="ana" select="$subcorpus"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <!-- COPY REST -->
  <xsl:template match="*">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="@*">
    <xsl:copy/>
  </xsl:template>
  
</xsl:stylesheet>
