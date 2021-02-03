<?xml version='1.0' encoding='UTF-8'?>
<!-- Xtra validation of ParlaMint corpus -->
<!-- Input should be root corpus file -->
<!-- 
     Check top title
     Check handle
     Check shape of component filenames
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  exclude-result-prefixes="tei xi">

  <xsl:variable name="id" select="/tei:*/@xml:id"/>
  
  <xsl:template match="tei:title[@type = 'main'][@xml:lang='en']">
    <xsl:if test="not(matches(. , '[^ ]+ parliamentary corpus ParlaMint-...* \[ParlaMint.*]$'))">
      <xsl:call-template name="error">
	<xsl:with-param name="msg">Bad main title</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
    
  <xsl:template match="tei:date">
    <xsl:choose>
      <xsl:when test="parent::tei:publicationStmt">
	<!-- Edition date is now today -->
	<xsl:copy>
	  <xsl:attribute name="when" select="$today-iso"/>
	  <xsl:value-of select="$today-iso"/>
	</xsl:copy>
      </xsl:when>
      <xsl:when test="not(normalize-space(.))">
	<!-- Add text into date if without -->
	<xsl:copy>
	  <xsl:apply-templates select="@*"/>
	  <xsl:choose>
	    <xsl:when test="@when">
	      <xsl:value-of select="@when"/>
	      <xsl:message>
		<xsl:text>WARN: adding text to empty date </xsl:text>
		<xsl:value-of select="concat(@when, ' in ',
				      ancestor-or-self::tei:*[@xml:id][1]/@xml:id)"/>
	      </xsl:message>
	    </xsl:when>
	    <xsl:when test="@from">
	      <xsl:message>
		<xsl:text>WARN: adding text to date </xsl:text>
		<xsl:value-of select="concat(@from, ' - ', @to, ' in ',
				      ancestor-or-self::tei:*[@xml:id][1]/@xml:id)"/>
	      </xsl:message>
	      <xsl:value-of select="concat(@from, ' - ', @to)"/>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:text>ERROR: no temporal attributes on date!</xsl:text>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:copy>
      </xsl:when>
      <xsl:otherwise>
	<xsl:copy>
	  <xsl:apply-templates select="@*"/>
	  <xsl:apply-templates/>
	</xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
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
    
  <!-- Add fake word extent if missing alltogether  -->
  <xsl:template match="tei:extent[not(tei:measure[@unit='words'])]">
    <xsl:message>
      <xsl:text>INFO: adding fake extent/measure[@unit='words']</xsl:text>
      <xsl:value-of select="concat(' in ', ancestor-or-self::tei:*[@xml:id][1]/@xml:id)"/>
    </xsl:message>
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
      <xsl:variable name="lang" select="ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang"/>
      <xsl:if test="$lang != 'bg'">
	<xsl:message terminate="yes">
	  <xsl:text>FATAL: strange language for addind word extent: </xsl:text>
	  <xsl:value-of select="concat($lang, ' in ', ancestor-or-self::tei:*[@xml:id][1]/@xml:id)"/>
	</xsl:message>
      </xsl:if>
      <measure quantity="0" unit="words" xml:lang="{$lang}">0 думи</measure>
      <measure quantity="0" unit="words" xml:lang="en">0 words</measure>
    </xsl:copy>
  </xsl:template>
    
  <xsl:template match="tei:titleStmt//tei:respStmt[1]">
    <xsl:if test="not(preceding-sibling::tei:*[1]/self::tei:meeting)">
      <xsl:message>
	<xsl:text>WARN: adding PL meeting info </xsl:text>
	<xsl:value-of select="concat(., ' in ', ancestor-or-self::tei:*[@xml:id][1]/@xml:id)"/>
      </xsl:message>
      <meeting n="8-lower" ana="#parla.lower #parla.term">8. kadencja Sejmu</meeting>
      <meeting n="9-lower" ana="#parla.lower #parla.term">9. kadencja Sejmu</meeting>
      <meeting n="9-upper" ana="#parla.upper #parla.term">9. kadencja Senatu</meeting>
      <meeting n="10-upper" ana="#parla.upper #parla.term">10. kadencja Senatu</meeting>
    </xsl:if>
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <!-- Add normalization if missing. -->
  <xsl:template match="tei:editorialDecl/tei:correction">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
    <xsl:if test="not(following-sibling::tei:normalization)">
      <normalization>
	<xsl:message>
	  <xsl:text>WARN: inserting editorialDecl/normalization</xsl:text>
	  <xsl:value-of select="concat(' in ', ancestor-or-self::tei:*[@xml:id][1]/@xml:id)"/>
	</xsl:message>
	<p xml:lang="en">Text has not been normalised, except for spacing.</p>
      </normalization>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="tei:setting[not(tei:date)]">
    <xsl:message>
      <xsl:text>WARN: inserting setting/date</xsl:text>
      <xsl:value-of select="concat(' in ', ancestor-or-self::tei:*[@xml:id][1]/@xml:id)"/>
    </xsl:message>
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
      <xsl:copy-of select="ancestor::tei:teiHeader//tei:sourceDesc//tei:date[1]"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tei:listOrg/tei:org/tei:orgName[not(@full)]">
    <xsl:message>
      <xsl:text>WARN: inserting orgName/@type="full"</xsl:text>
      <xsl:value-of select="concat(' for ', ., ' in ', ancestor-or-self::tei:*[@xml:id][1]/@xml:id)"/>
    </xsl:message>
    <xsl:copy>
      <xsl:attribute name="full">yes</xsl:attribute>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tei:taxonomy/tei:desc[not(tei:term)]">
    <xsl:message>
      <xsl:text>WARN: adding term to taxonomy/desc: &quot;</xsl:text>
      <xsl:value-of select="concat(., '&quot; in ', ancestor-or-self::tei:*[@xml:id][1]/@xml:id)"/>
    </xsl:message>
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <term>
	<xsl:apply-templates/>
      </term>
    </xsl:copy>
  </xsl:template>
    
  <xsl:template match="tei:catDesc[not(tei:term)]">
    <xsl:message>
      <xsl:text>WARN: adding term to catDesc: &quot;</xsl:text>
      <xsl:value-of select="concat(., '&quot; in ', ancestor-or-self::tei:*[@xml:id][1]/@xml:id)"/>
    </xsl:message>
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <term>
	<xsl:apply-templates/>
      </term>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tei:category/tei:desc">
    <xsl:message>
      <xsl:text>WARN: changing category/desc into category/catDesc: &quot;</xsl:text>
      <xsl:value-of select="concat(., '&quot; in ', ancestor-or-self::tei:*[@xml:id][1]/@xml:id)"/>
    </xsl:message>
    <catDesc>
      <xsl:apply-templates select="@*"/>
      <xsl:choose>
	<xsl:when test="tei:term">
	  <xsl:apply-templates/>
	</xsl:when>
	<xsl:otherwise>
	  <term>
	    <xsl:apply-templates/>
	  </term>
	</xsl:otherwise>
      </xsl:choose>
    </catDesc>
  </xsl:template>
  
  <!-- Reorder so that all have the same -->
  <xsl:template match="tei:sourceDesc/tei:bibl">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="tei:title"/>
      <xsl:apply-templates select="tei:edition"/>
      <xsl:apply-templates select="tei:publisher"/>
      <xsl:apply-templates select="tei:idno"/>
      <xsl:apply-templates select="tei:date"/>
      <xsl:if test="tei:*[not(self::tei:title or self::tei:edition or
		    self::tei:publisher or self::tei:idno or self::tei:date)]">
	<xsl:message>
	  <xsl:text>ERROR: sourceDesc/bibl contains strange elements </xsl:text>
	  <xsl:value-of select="concat(' in ', ancestor-or-self::tei:*[@xml:id][1]/@xml:id)"/>
	</xsl:message>
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:person/tei:persName[not(tei:*)]">
    <xsl:message>
      <xsl:text>WARN: adding term to bare-text persName </xsl:text>
      <xsl:value-of select="concat(' in ', ancestor-or-self::tei:*[@xml:id][1]/@xml:id)"/>
    </xsl:message>
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <term>
	<xsl:apply-templates/>
      </term>
    </xsl:copy>
  </xsl:template>
  
  <!-- Remove doubled party affiliations -->
  <xsl:template match="tei:person/tei:affiliation
		       [@role='member'][not(@from or @to)]">
    <xsl:variable name="ref" select="@ref"/>
    <xsl:choose>
    <xsl:when test="not(following-sibling::tei:affiliation
		  [@role='member'][not(@from or @to)][@ref = $ref])">
      <xsl:copy>
	<xsl:apply-templates select="@*"/>
	<xsl:apply-templates/>
      </xsl:copy>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message>
	<xsl:text>WARN: removing duplicate party affiliation for </xsl:text>
	<xsl:value-of select="concat(@ref, ' in ', ancestor-or-self::tei:*[@xml:id][1]/@xml:id)"/>
    </xsl:message>
    </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:birth[not(@when or @notBefore or @notAfter)]">
    <xsl:message>
      <xsl:text>WARN: removing birth witout @when: </xsl:text>
      <xsl:value-of select="concat(., ' in ', ancestor-or-self::tei:*[@xml:id][1]/@xml:id)"/>
    </xsl:message>
  </xsl:template>
  
  <xsl:template match="tei:sex">
    <xsl:if test="not(preceding-sibling::tei:*[1]/self::tei:sex)">
      <xsl:copy>
	<xsl:apply-templates select="@*"/>
	<xsl:choose>
	  <xsl:when test="ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang != 'sl'">
	    <xsl:value-of select="."/>
	  </xsl:when>
	  <xsl:when test="@value = 'M'">moški</xsl:when>
	  <xsl:when test="@value = 'F'">ženski</xsl:when>
	  <xsl:when test="@value = 'U'">neznan</xsl:when>
	  <xsl:otherwise>
	    <xsl:message>
	      <xsl:text>ERROR: Bad sex/@value: </xsl:text>
	      <xsl:value-of select="@value"/>
	    </xsl:message>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:copy>
    </xsl:if>
  </xsl:template>
    
  <xsl:template match="tei:roleName">
    <xsl:copy>
      <!-- Do not copy attributes, in particular @type! -->
      <xsl:choose>
	<xsl:when test="@lang != 'sl'">
	  <xsl:value-of select="."/>
	</xsl:when>
	<xsl:when test="matches(., 'mag\.', 'i')">mag.</xsl:when>
	<xsl:when test="matches(., 'dr\.', 'i')">dr.</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="normalize-space(.)"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>
    
  <xsl:template match="tei:surname | tei:forename
		       | tei:placeName
		       | tei:education | tei:occupation">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:choose>
	<xsl:when test="tei:*">
	  <xsl:apply-templates/>
	</xsl:when>
	<xsl:when test="starts-with(., ' ') or ends-with(., ' ') or matches(., '  +')">
	  <xsl:message>
	    <xsl:text>WARN: removing bad spaces in </xsl:text>
	    <xsl:value-of select="concat(name(), ' : &quot;', ., '&quot;')"/>
	  </xsl:message>
	  <xsl:value-of select="normalize-space(.)"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="normalize-space(.)"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>
    
  <xsl:template match="tei:org[not(@role)]">
    <xsl:copy>
      <xsl:message>
	<xsl:text>WARN: inserting org/@role='government': </xsl:text>
	<xsl:value-of select="concat(., ' in ', ancestor-or-self::tei:*[@xml:id][1]/@xml:id)"/>
      </xsl:message>
      <xsl:attribute name="role">government</xsl:attribute>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:placeName/@key">
    <xsl:message>
      <xsl:text>WARN: changing placeName/@key to placeName/@ref: </xsl:text>
      <xsl:value-of select="concat(., ' in ', ancestor-or-self::tei:*[@xml:id][1]/@xml:id)"/>
    </xsl:message>
    <xsl:attribute name="ref" select="."/>
  </xsl:template>

  <!-- BODY FIXES -->
  <xsl:template match="tei:seg">
    <xsl:choose>
      <xsl:when test="normalize-space(.)">
	<xsl:copy>
	  <xsl:apply-templates select="@*"/>
	  <xsl:apply-templates/>
	</xsl:copy>
      </xsl:when>
      <xsl:otherwise>
	<xsl:message>
	  <xsl:text>WARN: removing empty segment </xsl:text>
	  <xsl:value-of select="concat(ancestor::tei:u/@xml:id, ':', @xml:id)"/>
	</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Raise up edge incidents one level, out of seg; skip seg if then empty -->
  <xsl:template match="tei:seg[tei:vocal | tei:incident | tei:kinesic | tei:note]">
    <xsl:variable name="front-incidents">
      <xsl:apply-templates mode="gather-front"
			   select="tei:vocal | tei:incident | tei:kinesic | tei:note"/>
    </xsl:variable>
    <xsl:if test="$front-incidents/tei:*">
      <xsl:message>
	<xsl:text>INFO: moving front </xsl:text>
	<xsl:value-of select="concat($front-incidents/tei:*[1]/name(), ' out of seg ',
			      ancestor::tei:u/@xml:id, ':', @xml:id)"/>
      </xsl:message>
      <xsl:copy-of select="$front-incidents"/>
    </xsl:if>
    <xsl:variable name="content">
      <xsl:apply-templates/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$content/tei:*">
	<xsl:copy>
	  <xsl:apply-templates select="@*"/>
	  <xsl:copy-of select="$content"/>
	</xsl:copy>
      </xsl:when>
      <xsl:when test="$content/tei:* or normalize-space($content)">
	<xsl:copy>
	  <xsl:apply-templates select="@*"/>
	  <xsl:value-of select="normalize-space($content)"/>
	</xsl:copy>
      </xsl:when>
      <xsl:otherwise>
	<xsl:message>
	  <xsl:text>INFO: skipping empty segment </xsl:text>
	  <xsl:value-of select="@xml:id"/>
	</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:variable name="back-incidents">
      <xsl:apply-templates mode="gather-back"
			   select="tei:vocal | tei:incident | tei:kinesic | tei:note"/>
    </xsl:variable>
    <xsl:if test="$back-incidents/tei:*">
      <xsl:message>
	<xsl:text>INFO: moving back </xsl:text>
	<xsl:value-of select="concat($back-incidents/tei:*[1]/name(), ' out of seg ',
			      ancestor::tei:u/@xml:id, ':', @xml:id)"/>
      </xsl:message>
      <xsl:copy-of select="$back-incidents"/>
    </xsl:if>
  </xsl:template>
  <xsl:template match="tei:seg/tei:vocal | tei:seg/tei:incident
		       | tei:seg/tei:kinesic | tei:seg/tei:note">
    <xsl:if test="preceding-sibling::text()[normalize-space(.)] and
		  following-sibling::text()[normalize-space(.)]">
      <xsl:copy>
	<xsl:apply-templates select="@*"/>
	<xsl:apply-templates/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>

  <xsl:template mode="gather-front" match="tei:*">
    <xsl:if test="not(preceding-sibling::text()[normalize-space(.)])">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>
  <xsl:template mode="gather-back" match="tei:*">
    <xsl:if test="not(following-sibling::text()[normalize-space(.)])">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>
  
  <!-- Add @key for Bulgarian -->
  <xsl:template match="tei:name[@type='country'][not(@key)]">
    <xsl:message>
      <xsl:text>WARN: add name/@key to to </xsl:text>
      <xsl:value-of select="concat(., ' in ', ancestor-or-self::tei:*[@xml:id][1]/@xml:id)"/>
    </xsl:message>
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:if test=". != 'Bulgaria'">
	<xsl:message terminate="yes">WTF?</xsl:message>
      </xsl:if>
      <xsl:attribute name="key">BG</xsl:attribute>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <!-- Remove speeches witout speaker -->
  <xsl:template match="tei:u[not(@who and normalize-space(@who) and @who != '#')]">
    <xsl:message>
      <xsl:text>ERROR: u </xsl:text>
      <xsl:value-of select="concat(@xml:id, ' without @who, removing!')"/>
    </xsl:message>
  </xsl:template>

  <!-- Remove orphan text (in sl and bg) -->
  <xsl:template match="tei:u/text()[normalize-space(.)]">
    <xsl:message>
      <xsl:text>ERROR: orphan text in u </xsl:text>
      <xsl:value-of select="concat(ancestor::tei:u/@xml:id, ', removing ', .)"/>
    </xsl:message>
  </xsl:template>

  <xsl:template match="tei:incident/@type[. = 'бреак']">
    <xsl:message>
      <xsl:text>WARN: changing incident/@type from </xsl:text>
      <xsl:value-of select="concat(. , ' to break in ', ancestor-or-self::tei:*[@xml:id][1]/@xml:id)"/>
    </xsl:message>
    <xsl:attribute name="type">break</xsl:attribute>
  </xsl:template>
  
  <!-- Remove orphan desc (in -bg) -->
  <xsl:template match="tei:u/tei:desc | tei:seg/tei:desc | tei:s/tei:desc">
    <xsl:message>
      <xsl:text>WARN: removing orphan desc: </xsl:text>
      <xsl:value-of select="concat(., ' in ', ancestor-or-self::tei:*[@xml:id][1]/@xml:id)"/>
    </xsl:message>
  </xsl:template>

  <!-- Strip space in incident desc, make sure it doesn't contain any elements -->
  <xsl:template match="tei:vocal/tei:desc | tei:incident/tei:desc | tei:kinesic/tei:desc
		       | tei:gap/tei:desc">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="tei:*">
	<xsl:message>
	  <xsl:text>desc should not contain any elements: found </xsl:text>
	  <xsl:value-of select="concat(tei:*[1]/name(), ' in ',
				ancestor-or-self::tei:*[@xml:id][1]/@xml:id)"/>
	</xsl:message>
      </xsl:if>
      <!-- In Bulgarian incident descs still have brackets in them -->
    <xsl:value-of select="normalize-space(
			  replace(replace(., '^\s*\(', ''), '\)\s*$', ''))"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="text()">
    <xsl:if test="normalize-space(.)">
      <xsl:if test="not(preceding-sibling::tei:*) and matches(., '^ ')">
	<xsl:call-template name="error">
	  <xsl:with-param name="msg" select="concat('Leading space in ', .)"/>
      </xsl:call-template>
      </xsl:if>
      <xsl:if test="not(following-sibling::tei:*) and matches(., ' $')">
	<xsl:call-template name="error">
	  <xsl:with-param name="msg" select="concat('Trailing space in ', .)"/>
	</xsl:call-template>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  
  <!-- Replace multiple and varied white-space with one space -->
  <xsl:template match="text()">
    <xsl:value-of select="replace(., '\s+', ' ')"/>
  </xsl:template>

  <xsl:template name="error">
    <xsl:param name="msg">WHAT??</xsl:param>
    <xsl:message>
      <xsl:text>ERROR </xsl:text>
      <xsl:value-of select="$id"/>
      <xsl:text> :</xsl:text>
      <xsl:value-of select="$msg"/>
    </xsl:message>
  </xsl:template>
  
</xsl:stylesheet>
