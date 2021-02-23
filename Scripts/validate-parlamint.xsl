<?xml version='1.0' encoding='UTF-8'?>
<!-- Xtra validation of ParlaMint corpus -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  exclude-result-prefixes="tei xi">

  <xsl:output method="text"/>
  
  <xsl:variable name="id" select="/tei:*/@xml:id"/>
  
  <xsl:variable name="type">
    <xsl:choose>
      <xsl:when test="matches(base-uri(), 'ParlaMint-..\.ana\.xml$')">ana</xsl:when>
      <xsl:when test="matches(base-uri(), 'ParlaMint-.._.+\.ana\.xml$')">ana</xsl:when>
      <xsl:when test="matches(base-uri(), 'ParlaMint-..\.xml$')">txt</xsl:when>
      <xsl:when test="matches(base-uri(), 'ParlaMint-.._.+\.xml$')">txt</xsl:when>
      <xsl:otherwise>
	<xsl:call-template name="error">
	  <xsl:with-param name="msg" select="concat('Bad filename ', base-uri())"/>
	</xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <xsl:variable name="level">
    <xsl:choose>
      <xsl:when test="matches(base-uri(), 'ParlaMint-.._')">component</xsl:when>
      <xsl:when test="matches(base-uri(), 'ParlaMint-..(\.ana)?\.xml$')">root</xsl:when>
      <xsl:otherwise>
	<xsl:call-template name="error">
	  <xsl:with-param name="msg" select="concat('Bad filename ', base-uri())"/>
	</xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <xsl:template match="tei:teiCorpus">
    <xsl:if test="base-uri() = concat($id, '.xml')">
      <xsl:call-template name="error">
	<xsl:with-param name="msg">teiCorpus/@xml:id does not match filename</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="$level != 'root'">
      <xsl:call-template name="error">
	<xsl:with-param name="msg">Wrong filename for teiCorpus root</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="$type = 'txt' and not(matches(base-uri(), 'ParlaMint-..'))">
      <xsl:call-template name="error">
	<xsl:with-param name="msg">
	  <xsl:text>Root filename should be ParlaMint-XX.xml</xsl:text>
	</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="$type = 'ana' and not(matches(base-uri(), 'ParlaMint-..\.ana'))">
      <xsl:call-template name="error">
	<xsl:with-param name="msg">
	  <xsl:text>Root filename should be ParlaMint-XX.ana.xml</xsl:text>
	</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="tei:TEI">
    <xsl:if test="base-uri() = concat($id, '.xml')">
      <xsl:call-template name="error">
	<xsl:with-param name="msg">TEI/@xml:id does not match filename</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="$level != 'component'">
      <xsl:call-template name="error">
	<xsl:with-param name="msg">Wrong filename for TEI component</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="not(matches(base-uri(), 'ParlaMint-.._'))">
	<xsl:call-template name="error">
	  <xsl:with-param name="msg">
	    <xsl:text>Component filenames should be ParlaMint-XX_...</xsl:text>
	  </xsl:with-param>
	</xsl:call-template>
      </xsl:when>
      <xsl:when test="matches(base-uri(), '_.+_')">
	<xsl:call-template name="error">
	  <xsl:with-param name="msg">
	    <xsl:text>Component filenames should have only one underscore</xsl:text>
	  </xsl:with-param>
	</xsl:call-template>
      </xsl:when>
    </xsl:choose>
    <xsl:variable name="subcorpus-TEI">
      <xsl:choose>
	<xsl:when test="contains(@ana, '#reference')">reference</xsl:when>
	<xsl:when test="contains(@ana, '#covid')">covid</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="subcorpus-text">
      <xsl:choose>
	<xsl:when test="contains(tei:text/@ana, '#reference')">reference</xsl:when>
	<xsl:when test="contains(tei:text/@ana, '#covid')">covid</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="not(normalize-space($subcorpus-TEI))">
      <xsl:call-template name="error">
	<xsl:with-param name="msg">TEI element should have #reference or #covid in @ana</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="not(normalize-space($subcorpus-text))">
	<xsl:call-template name="error">
	  <xsl:with-param name="msg">text element should have #reference or #covid in @ana</xsl:with-param>
	</xsl:call-template>
      </xsl:when>
      <xsl:when test="$subcorpus-TEI != $subcorpus-text">
	<xsl:call-template name="error">
	  <xsl:with-param name="msg">subcorpus values in TEI/@ana and text/@ana do not match</xsl:with-param>
	</xsl:call-template>
      </xsl:when>
    </xsl:choose>
    <xsl:apply-templates/>
  </xsl:template>
    
  <xsl:template match="tei:teiCorpus/tei:teiHeader//tei:title[@type = 'main'][@xml:lang='en']">
    <xsl:choose>
      <xsl:when test="$type = 'txt'">
	<xsl:if test="not(matches(., 
		      '[^ ]+ parliamentary corpus ParlaMint-.. \[ParlaMint( SAMPLE)?\]$', 
		      'i'))">
	  <xsl:call-template name="error">
	    <xsl:with-param name="msg" select="concat('Bad main corpus title ', .)"/>
	  </xsl:call-template>
	</xsl:if>
      </xsl:when>
      <xsl:when test="$type = 'ana'">
	<xsl:if test="not(matches(. , 
		      '[^ ]+ parliamentary corpus ParlaMint-.. \[ParlaMint\.ana( SAMPLE)?\]$'))">
	  <xsl:call-template name="error">
	    <xsl:with-param name="msg" select="concat('Bad main corpus title ', .)"/>
	  </xsl:call-template>
	</xsl:if>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="tei:TEI/tei:teiHeader//tei:title[@type = 'main'][@xml:lang='en']">
    <xsl:choose>
      <xsl:when test="$type = 'txt'">
	<xsl:if test="not(matches(., 
		      '[^ ]+ parliamentary corpus ParlaMint-..,? .+ \[ParlaMint( SAMPLE)?\]$'))">
	  <xsl:call-template name="error">
	    <xsl:with-param name="msg" select="concat('Bad txt component corpus title ', .)"/>
	  </xsl:call-template>
	</xsl:if>
      </xsl:when>
      <xsl:when test="$type = 'ana'">
	<xsl:if test="not(matches(., 
		      '[^ ]+ parliamentary corpus ParlaMint-..,? .+ \[ParlaMint\.ana( SAMPLE)?\]$'))">
	  <xsl:call-template name="error">
	    <xsl:with-param name="msg" select="concat('Bad ana component corpus title ', .)"/>
	  </xsl:call-template>
	</xsl:if>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
    
  <xsl:template match="tei:titleStmt">
    <xsl:if test="not(tei:meeting)">
      <xsl:call-template name="error">
	<xsl:with-param name="msg">Missing meeting elements in titleStmt</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="tei:extent">
    <xsl:if test="not(tei:measure[@unit='speeches'])">
      <xsl:call-template name="error">
	<xsl:with-param name="msg">Missing extent/measure[@unit='speeches'] in titleStmt</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="not(tei:measure[@unit='words'])">
      <xsl:call-template name="error">
	<xsl:with-param name="msg">Missing extent/measure[@unit='words'] in titleStmt</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:sourceDesc/tei:bibl[tei:date]">
    <xsl:variable name="date" select="replace($id, '-+_(\d\d\d\d-\d\d-\d\d).*', '$1')"/>
    <xsl:if test="$date != $id and tei:date/@when != $date">
      <xsl:call-template name="error">
	<xsl:with-param name="msg">sourceDesc//date does not match date in filename</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  <xsl:template match="tei:settingDesc">
    <xsl:variable name="date" select="replace($id, '-+_(\d\d\d\d-\d\d-\d\d).*', '$1')"/>
    <xsl:if test="$date != $id and tei:date/@when != $date">
      <xsl:call-template name="error">
	<xsl:with-param name="msg">settingDesc/date does not match date in filename</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="tei:idno">
    <xsl:if test="matches(., 'hdl.handle.net') and not(@type='handle')">
      <xsl:call-template name="error">
	<xsl:with-param name="msg">handle URLs should be idno[@type='handle']</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="tei:date">
    <xsl:if test="not(@when or @from or @to)">
      <xsl:call-template name="error">
	<xsl:with-param name="msg">Missing any temporal attribute on date</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
    
  <xsl:template match="tei:classDecl">
    <xsl:if test="not(tei:taxonomy[tei:desc/tei:term = 'Legislature'])">
      <xsl:call-template name="error">
	<xsl:with-param name="msg">Missing 'Legislature' taxonomy</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="not(tei:taxonomy[tei:desc/tei:term = 'Types of speakers'])">
      <xsl:call-template name="error">
	<xsl:with-param name="msg">Missing 'Types of speakers' taxonomy</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="not(tei:taxonomy[tei:desc/tei:term = 'Subcorpora'])">
      <xsl:call-template name="error">
	<xsl:with-param name="msg">Missing 'Subcorpora' taxonomy</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="$type = 'ana'">
      <xsl:if test="not(tei:taxonomy[tei:desc/tei:term = 'Named entities'])">
	<xsl:call-template name="error">
	  <xsl:with-param name="msg">Missing 'Named entities' taxonomy</xsl:with-param>
	</xsl:call-template>
      </xsl:if>
      <xsl:if test="not(tei:taxonomy[tei:desc/tei:term = 'UD syntactic relations'])">
	<xsl:call-template name="error">
	  <xsl:with-param name="msg">Missing 'UD syntactic relations' taxonomy</xsl:with-param>
	</xsl:call-template>
      </xsl:if>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="tei:listPrefixDef">
    <xsl:if test="not(tei:prefixDef[@ident = 'ud-syn'])">
      <xsl:call-template name="error">
	<xsl:with-param name="msg">Missing UD prefixDef</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="tei:person">
    <xsl:variable name="id">
      <xsl:variable name="names">
	<xsl:for-each select="tei:persName/tei:surname">
	  <xsl:value-of select="."/>
	</xsl:for-each>
	<!--xsl:for-each select="tei:persName/tei:forename">
	  <xsl:value-of select="."/>
	</xsl:for-each-->
	<xsl:value-of select="tei:persName/tei:forename[1]"/>
      </xsl:variable>
      <xsl:value-of select="replace($names, '[ -]', '')"/>
    </xsl:variable>
    <xsl:variable name="id2" select="concat($id, replace(tei:birth/@when, '-.+', ''))"/>
    <xsl:if test="@xml:id != $id and @xml:id != $id2">
      <xsl:call-template name="error">
	<xsl:with-param name="severity">WARN</xsl:with-param>
	<xsl:with-param name="msg">
	  <xsl:text>Person ID </xsl:text>
	  <xsl:value-of select="@xml:id"/>
	  <xsl:text> should be </xsl:text>
	  <xsl:value-of select="$id"/>
	  <xsl:if test="$id != $id2">
	    <xsl:text> (or, if ambiguous, </xsl:text>
	    <xsl:value-of select="$id2"/>
	    <xsl:text>)</xsl:text>
	  </xsl:if>
	</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="tei:person/tei:affiliation
		       [@role='member'][not(@from or @to)]">
    <xsl:variable name="ref" select="@ref"/>
    <xsl:if test="following-sibling::tei:affiliation
		  [@role='member'][not(@from or @to)][@ref = $ref]">
      <xsl:call-template name="error">
	<xsl:with-param name="msg">
	  <xsl:text>Duplicate party affiliation for </xsl:text>
	  <xsl:value-of select="@ref"/>
	</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
    
  <xsl:template match="tei:org[not(@role)]">
    <xsl:call-template name="error">
      <xsl:with-param name="msg">
	<xsl:text>Organisation without role for </xsl:text>
	<xsl:value-of select="."/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="tei:name[@type='country'][not(@key)]">
    <xsl:call-template name="error">
      <xsl:with-param name="msg">
	<xsl:text>Country without @key </xsl:text>
	<xsl:value-of select="."/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="tei:u[not(@who and normalize-space(@who) and @who != '#')]">
    <xsl:call-template name="error">
      <xsl:with-param name="severity">WARN</xsl:with-param>
      <xsl:with-param name="msg">
	<xsl:text>Element u without or with bad @who </xsl:text>
	<xsl:value-of select="@xml:id"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="tei:u/text()[normalize-space(.)]">
    <xsl:call-template name="error">
      <xsl:with-param name="msg">
	<xsl:text>Orphan text in u </xsl:text>
	<xsl:value-of select="@xml:id"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="tei:text">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="tei:u[@who]">
    <xsl:if test="not(matches(@who, '#[^ ]'))">
      <xsl:call-template name="error">
	<xsl:with-param name="msg">
	  <xsl:text>Bad value for u/@who </xsl:text>
	  <xsl:value-of select="@who"/>
	  <xsl:text> for </xsl:text>
	  <xsl:value-of select="@xml:id"/>
	</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="text()">
    <xsl:if test="not(parent::tei:p or parent::tei:change) and normalize-space(.)">
      <xsl:if test="not(preceding-sibling::tei:*) and matches(., '^ ')">
	<xsl:call-template name="error">
	  <xsl:with-param name="severity">WARN</xsl:with-param>
	  <xsl:with-param name="msg" select="concat('Leading space in ', ../name(), ': ', .)"/>
	</xsl:call-template>
      </xsl:if>
      <xsl:if test="not(following-sibling::tei:*) and matches(., ' $')">
	<xsl:call-template name="error">
	  <xsl:with-param name="severity">WARN</xsl:with-param>
	  <xsl:with-param name="msg" select="concat('Trailing space in ', ../name(), ': ', .)"/>
	</xsl:call-template>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="error">
    <xsl:param name="msg">???</xsl:param>
    <xsl:param name="severity">ERROR</xsl:param>
    <xsl:message>
      <xsl:value-of select="$severity"/>
      <xsl:text>&#32;</xsl:text>
      <xsl:value-of select="/tei:*/@xml:id"/>
      <xsl:text>: </xsl:text>
      <xsl:value-of select="$msg"/>
    </xsl:message>
  </xsl:template>
  
</xsl:stylesheet>
