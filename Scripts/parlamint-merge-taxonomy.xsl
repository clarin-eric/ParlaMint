<?xml version="1.0"?>
<!-- Insert translations of corpus-specific taxonomies into the ParlaMint-wide template taxonomy -->
<!-- Input it ParlaMint overall corpus root file, the XIncludes of which are followed until finding and gathering corpus-specific taxonomies -->
<!-- Parameter 'template' gives the template of the taxonomy file -->
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:tei="http://www.tei-c.org/ns/1.0" 
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:et="http://nl.ijs.si/et" 
  exclude-result-prefixes="#all"
  version="2.0">

  <!-- Name of file with template taxonomy -->
  <xsl:param name="template"/>
  
  <xsl:output method="xml" indent="yes"/>

  <xsl:key name="id" match="tei:*" use="@xml:id"/>

  <!-- Template taxonomy -->
  <xsl:variable name="template-taxonomy">
    <xsl:if test="not(doc-available($template))">
      <xsl:message terminate="yes" select="concat('FATAL ERROR: template file ', $template, ' not found')"/>
    </xsl:if>
    <xsl:copy-of select="document($template)"/>
  </xsl:variable>
  
  <!-- ID of template taxonomy -->
  <xsl:variable name="taxonomy-id" select="$template-taxonomy/tei:taxonomy/@xml:id"/>
  
  <xsl:template match="/">
    <!-- Collect all corpus taxonomies with the appropriate @xml:id -->
    <xsl:variable name="taxonomies">
      <xsl:for-each select="document(/tei:teiCorpus/xi:include/@href)/tei:teiCorpus">
	<xsl:variable name="corpus" select="@xml:id"/>
	<!--xsl:message select="concat('INFO: processing ', $corpus)"/-->
	<xsl:variable name="taxonomy">
	  <xsl:for-each select="tei:teiHeader/tei:encodingDesc/tei:classDecl/xi:include">
	    <xsl:copy-of select="document(@href)/tei:taxonomy[@xml:id = $taxonomy-id]"/>
	  </xsl:for-each>
	</xsl:variable>
	<xsl:if test="not($taxonomy/tei:taxonomy)">
	  <xsl:message select="concat('ERROR: ', $corpus, ' has no taxonomy for ', $taxonomy-id)"/>
	</xsl:if>
	<xsl:apply-templates mode="id" select="$taxonomy">
	  <xsl:with-param name="id" select="$corpus"/>
	</xsl:apply-templates>
      </xsl:for-each>
    </xsl:variable>
    <!-- Insert their non-English descriptions into the template taxonomy -->
    <xsl:apply-templates mode="insert" select="$template-taxonomy/tei:taxonomy">
      <xsl:with-param name="taxonomies" select="$taxonomies"/>
    </xsl:apply-templates>
    <!-- Check if corpus taxonomies have any categories not present in the template taxonomy -->
    <xsl:apply-templates mode="check" select="$taxonomies/tei:taxonomy//tei:category">
      <xsl:with-param name="template" select="$template-taxonomy"/>
    </xsl:apply-templates>
  </xsl:template>

  <!-- Insert taxonomy/desc -->
  <xsl:template mode="insert" match="tei:taxonomy">
    <xsl:param name="taxonomies"/>
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:variable name="desc-en" select="tei:desc[ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang = 'en']"/>
      <xsl:copy-of select="$desc-en"/>
      <xsl:for-each select="$taxonomies/tei:taxonomy">
	<xsl:variable name="corpus" select="@xml:id"/>
	<xsl:variable name="desc" >
	  <xsl:apply-templates mode="corpus-mark"
			       select="tei:desc[ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang != 'en']">
	    <xsl:with-param name="id" select="$corpus"/>
	  </xsl:apply-templates>
	</xsl:variable>
	<xsl:choose>
	  <xsl:when test="$desc/tei:desc">
	    <xsl:copy-of select="$desc"/>
	  </xsl:when>
	  <xsl:when test="not(matches($corpus, '-GB'))">
	    <xsl:message select="concat('WARN:  ', $corpus, ' is missing translation ', 
				 ' for taxonomy ', $taxonomy-id)"/>
	    <xsl:comment select="concat('Corpus ', $corpus, ' is missing translation of ', $desc-en/tei:term)"/>
	  </xsl:when>
	</xsl:choose>
      </xsl:for-each>
      <xsl:apply-templates mode="insert" select="tei:category">
	<xsl:with-param name="taxonomies" select="$taxonomies"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <!-- Insert category/catDesc -->
  <xsl:template mode="insert" match="tei:category">
    <xsl:param name="taxonomies"/>
    <xsl:variable name="category-id" select="@xml:id"/>
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:variable name="catDesc-en" select="tei:catDesc[ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang = 'en']"/>
      <xsl:copy-of select="$catDesc-en"/>
      <xsl:for-each select="$taxonomies/tei:taxonomy">
	<xsl:variable name="corpus" select="@xml:id"/>
	<xsl:variable name="category" select=".//tei:category[@xml:id = $category-id]"/>
	<xsl:choose>
	  <xsl:when test="$category/self::tei:category">
	    <xsl:variable name="catDesc">
	      <xsl:apply-templates mode="corpus-mark"
				   select="$category/tei:catDesc[ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang != 'en']">
		<xsl:with-param name="id" select="$corpus"/>
	      </xsl:apply-templates>
	    </xsl:variable>
	    <xsl:choose>
	      <xsl:when test="$catDesc/tei:catDesc">
		<xsl:copy-of select="$catDesc"/>
	      </xsl:when>
	      <xsl:when test="not(matches($corpus, '-GB'))">
		<xsl:message select="concat('WARN:  ', $corpus, ' is missing translation for category ', $category-id,  
				     ' for taxonomy ', $taxonomy-id)"/>
		<xsl:comment select="concat('Corpus ', $corpus, ' is missing translation of ', $catDesc-en/tei:term)"/>
	      </xsl:when>
	    </xsl:choose>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:message select="concat('WARN:  ', $corpus, ' does not contain standard category ', $category-id, 
				 ' for taxonomy ', $taxonomy-id)"/>
	    <xsl:comment select="concat('Corpus ', $corpus, ' is missing translation of ', $catDesc-en/tei:term)"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:for-each>
      <xsl:apply-templates mode="insert" select="tei:category">
	<xsl:with-param name="taxonomies" select="$taxonomies"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="insert" match="tei:*">
    <xsl:param name="taxonomies"/>
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates mode="insert">
	<xsl:with-param name="taxonomies" select="$taxonomies"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="check" match="tei:category">
    <xsl:param name="template"/>
    <xsl:variable name="corpus" select="ancestor::tei:taxonomy/@xml:id"/>
    <xsl:variable name="category-id" select="@xml:id"/>
    <xsl:if test="not(key('id', $category-id, $template))">
      <xsl:message select="concat('ERROR: ', $corpus, ' contains non-standard category ', $category-id,
			   ' for taxonomy ', $taxonomy-id)"/>
    </xsl:if>
  </xsl:template>
  
  <!-- Copy element, but give it as @n the ID of its corpus -->
  <xsl:template mode="corpus-mark" match="tei:*">
    <xsl:param name="id"/>
    <xsl:copy>
      <xsl:attribute name="n" select="$id"/>
      <xsl:attribute name="xml:lang" select="@xml:lang"/>
      <xsl:copy-of select="node()"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- Copy taxonomy, but give it the ID of its corpus, we need this for marking taxonomy/desc and category/catDesc -->
  <xsl:template mode="id" match="tei:taxonomy">
    <xsl:param name="id"/>
    <xsl:copy>
      <xsl:attribute name="xml:id" select="$id"/>
      <xsl:copy-of select="tei:*"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="@*">
    <xsl:copy/>
  </xsl:template>
  
  <xsl:template match="comment()"/>
</xsl:stylesheet>
