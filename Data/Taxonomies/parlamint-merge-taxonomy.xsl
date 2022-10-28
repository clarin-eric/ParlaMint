<?xml version="1.0"?>
<!-- Insert translations for a corpus-specific taxonomy into the ParlaMint-wide taxonomy -->
<!-- Also check if the corpus-specific taxonomy fits the ParlaMint-wide one -->
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:tei="http://www.tei-c.org/ns/1.0" 
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:et="http://nl.ijs.si/et" 
  exclude-result-prefixes="#all"
  version="2.0">

  <xsl:param name="new"/>
  <!--xsl:import href="parlamint-lib.xsl"/-->
  
  <xsl:output method="xml" indent="yes"/>

  <xsl:key name="id" match="tei:*" use="@xml:id"/>

  <!-- ID of master taxonomy -->
  <xsl:variable name="taxo-id" select="/tei:taxonomy/@xml:id"/>
  
  <!-- Country code of new taxonomy -->
  <xsl:variable name="country" select="replace($new,
					   '.+ParlaMint-([A-Z-]+).*', '$1')"/>
  
  <!-- The taxonomy the translations of which should be merged -->
  <xsl:variable name="new-taxo">
    <xsl:copy-of select="document($new)//tei:taxonomy[@xml:id = $taxo-id]"/>
  </xsl:variable>

  <xsl:template match="tei:taxonomy">
    <xsl:if test="not($new-taxo)">
      <xsl:message terminate="yes"
		   select="concat('FATAL: In ', $country, ' 
			   no appropriate taxonomy found for ', $taxo-id)"/>
    </xsl:if>
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:call-template name="merge">
	<xsl:with-param name="master" select="tei:desc"/>
	<xsl:with-param name="new" select="$new-taxo/tei:taxonomy/tei:desc"/>
      </xsl:call-template>
      <xsl:variable name="categories">
	<xsl:apply-templates select="tei:category"/>
      </xsl:variable>
      <xsl:apply-templates mode="check" select="$new-taxo//tei:category">
	<xsl:with-param name="master" select="$categories"/>
      </xsl:apply-templates>
      <xsl:copy-of select="$categories"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:category">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:variable name="id" select="@xml:id"/>
      <xsl:variable name="new" select="key('id', $id, $new-taxo)/tei:catDesc"/>
      <xsl:choose>
	<xsl:when test="not($new)">
	  <xsl:message select="concat('WARNING: ', $country, 
			       ' taxonomy is missing category ', $id)"/>
	  <xsl:copy-of select="tei:catDesc"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:call-template name="merge">
	    <xsl:with-param name="master" select="tei:catDesc"/>
	    <xsl:with-param name="new" select="$new"/>
	  </xsl:call-template>
	</xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="tei:category"/>
    </xsl:copy>
  </xsl:template>

  <!-- Check if new taxonomy has categories not present in the master one -->
  <xsl:template mode="check" match="tei:category">
    <xsl:param name="master"/>
    <xsl:variable name="id" select="@xml:id"/>
    <xsl:if test="not(key('id', $id, $master))">
      <xsl:message select="concat('ERROR: ', $country, ' taxonomy has category ', $id,
			   ' which does not exist in the master taxonomy!')"/>
    </xsl:if>
  </xsl:template>
  
  <!-- Merge two sets of descriptions -->
  <xsl:template name="merge">
    <xsl:param name="master"/>
    <xsl:param name="new"/>
    <xsl:variable name="descriptions">
      <!-- Copy over existing descriptions, possibly updating some -->
      <xsl:for-each select="$master/self::tei:*">
	<xsl:variable name="lang-master" select="@xml:lang"/>
	<xsl:variable name="text-master" select="."/>
	<xsl:choose>
	  <xsl:when test="$lang-master = 'en'">
	    <xsl:copy-of select="."/>
	  </xsl:when>
	  <xsl:when test="$new/self::tei:*[@xml:lang = $lang-master]">
	    <xsl:variable name="text-new" select="$new/self::tei:*[@xml:lang = $lang-master]"/>
	    <xsl:choose>
	      <xsl:when test="normalize-space($text-master) = normalize-space($text-new)">
		<xsl:message select="concat('INFO: For ', $country, ' no change in text for: ',
				     normalize-space($text-new))"/> 
		<xsl:copy-of select="."/>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:message select="concat('INFO: changed text with ', $country, 
				     normalize-space($text-new))"/> 
		<xsl:copy-of select="$text-new"/>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:copy-of select="."/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:for-each>
      <!-- Add new descriptions -->
      <xsl:for-each select="$new/self::tei:*">
	<xsl:variable name="lang-new" select="@xml:lang"/>
      <xsl:variable name="text-new" select="."/>
      <xsl:choose>
	<xsl:when test="$lang-new = 'en'"/>
	<xsl:when test="$master/self::tei:*[@xml:lang = $lang-new]"/>
	<xsl:otherwise>
	  <!--xsl:message select="concat('INFO: ', $country, ' + language ', 
	      $lang-new, ' inserting new ', name(.), ': ',
	      normalize-space($text-new))"/--> 
	  <xsl:copy-of select="."/>
	</xsl:otherwise>
      </xsl:choose>
      </xsl:for-each>
    </xsl:variable>
    <!-- Now sort them, English first -->
    <xsl:copy-of select="$descriptions/tei:*[@xml:lang = 'en']"/>
    <xsl:for-each select="$descriptions/tei:*">
      <xsl:sort select="@xml:lang"/>
      <xsl:if test="@xml:lang != 'en'">
	<xsl:copy-of select="."/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
  
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
