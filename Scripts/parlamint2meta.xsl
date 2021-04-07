<?xml version="1.0"?>
<!-- Transform one ParlaMint file to a TSV file with its metadata. -->
<!-- Needs the file with corpus teiHeader as a parameter -->
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

  <xsl:output method="text" encoding="utf-8"/>
  
  <!-- File with corpus teiHeader for information about taxonomies, persons, parties -->
  <xsl:param name="hdr"/>

  <!-- Output labels for MPs and guests -->
  <xsl:param name="mp-label">MP</xsl:param>
  <xsl:param name="guest-label">notMP</xsl:param>

  <xsl:key name="id" match="tei:*" use="@xml:id"/>
  <!-- Key which directly finds local references -->
  <xsl:key name="idr" match="tei:*" use="concat('#', @xml:id)"/>

  <xsl:variable name="today-iso" select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>

  <xsl:variable name="teiHeader">
    <xsl:if test="not(doc-available($hdr))">
      <xsl:message terminate="yes">
	<xsl:text>TEI header file </xsl:text>
	<xsl:value-of select="$hdr"/>
	<xsl:text> not found!</xsl:text>
      </xsl:message>
    </xsl:if>
     <xsl:copy-of select="document($hdr)"/>
  </xsl:variable>

  <xsl:variable name="title">
    <xsl:variable name="titles" select="/tei:TEI/tei:teiHeader/tei:fileDesc/
					tei:titleStmt/tei:title"/>
    <xsl:choose>
      <xsl:when test="$titles[@type='sub']
		      [ancestor-or-self::tei:*[@xml:lang][1][@xml:lang='en']]">
	<xsl:value-of select="$titles[@type='sub']
			      [ancestor-or-self::tei:*[@xml:lang][1][@xml:lang='en']]
			      [1]"/>
      </xsl:when>
      <xsl:when test="$titles[@type='sub']">
	<xsl:value-of select="$titles[@type='sub'][1]"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$titles[1]"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <xsl:variable name="date-from">
    <xsl:variable name="d" select="/tei:TEI/tei:teiHeader//tei:settingDesc//tei:date"/>
    <xsl:choose>
      <xsl:when test="$d/@when">
	<xsl:value-of select="$d/@when"/>
      </xsl:when>
      <xsl:when test="$d/@from">
	<xsl:value-of select="$d/@from"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:message terminate="yes">
	  <xsl:text>Can't find TEI date(s) in settingDesc of input file!</xsl:text>
	</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="date-to">
    <xsl:variable name="d" select="/tei:TEI/tei:teiHeader//tei:settingDesc//tei:date"/>
    <xsl:choose>
      <xsl:when test="$d/@when">
	<xsl:value-of select="$d/@when"/>
      </xsl:when>
      <xsl:when test="$d/@to">
	<xsl:value-of select="$d/@to"/>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>
  
  <xsl:variable name="term">
    <xsl:call-template name="meeting">
      <xsl:with-param name="ref">parla.term</xsl:with-param>
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="session">
    <xsl:call-template name="meeting">
      <xsl:with-param name="ref">parla.session</xsl:with-param>
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="meeting">
    <xsl:call-template name="meeting">
      <xsl:with-param name="ref">parla.meeting</xsl:with-param>
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="sitting">
    <xsl:call-template name="meeting">
      <xsl:with-param name="ref">parla.sitting</xsl:with-param>
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="agenda">
    <xsl:call-template name="meeting">
      <xsl:with-param name="ref">parla.agenda</xsl:with-param>
    </xsl:call-template>
  </xsl:variable>
  
  <xsl:variable name="subcorpus">
    <xsl:for-each select="tokenize(tei:TEI/@ana, ' ')">
      <xsl:if test="key('idr', ., $teiHeader)/
		    ancestor::tei:taxonomy/tei:desc/tei:term = 'Subcorpora'">
	<xsl:value-of select="key('idr', ., $teiHeader)//tei:catDesc
			      [ancestor-or-self::tei:*[@xml:lang][1][@xml:lang='en']]
			      /tei:term"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>
  
  <xsl:template match="@*"/>
  <xsl:template match="text()"/>

  <xsl:template match="tei:TEI">
    <xsl:text>ID&#9;</xsl:text>
    <xsl:text>Title&#9;</xsl:text>
    <xsl:text>From&#9;</xsl:text>
    <xsl:text>To&#9;</xsl:text>
    <xsl:text>Term&#9;</xsl:text>
    <xsl:text>Session&#9;</xsl:text>
    <xsl:text>Meeting&#9;</xsl:text>
    <xsl:text>Sitting&#9;</xsl:text>
    <xsl:text>Agenda&#9;</xsl:text>
    <xsl:text>Subcorpus&#9;</xsl:text>
    <xsl:text>Speaker_role&#9;</xsl:text>
    <xsl:text>Speaker_type&#9;</xsl:text>
    <xsl:text>Speaker_party&#9;</xsl:text>
    <xsl:text>Speaker_party_name&#9;</xsl:text>
    <xsl:text>Speaker_name&#9;</xsl:text>
    <xsl:text>Speaker_gender&#9;</xsl:text>
    <xsl:text>Speaker_birth</xsl:text>
    <!--xsl:text>Tokens</xsl:text-->
    <xsl:text>&#10;</xsl:text>
    <xsl:apply-templates select=".//tei:u"/>
  </xsl:template>
  
  <xsl:template match="tei:u">
    <!-- Text metadata -->
    <xsl:value-of select="concat(@xml:id, '&#9;')"/>
    <xsl:value-of select="concat($title, '&#9;')"/>
    <xsl:value-of select="concat($date-from, '&#9;')"/>
    <xsl:value-of select="concat($date-to, '&#9;')"/>
    <xsl:value-of select="concat($term, '&#9;')"/>
    <xsl:value-of select="concat($session, '&#9;')"/>
    <xsl:value-of select="concat($meeting, '&#9;')"/>
    <xsl:value-of select="concat($sitting, '&#9;')"/>
    <xsl:value-of select="concat($agenda, '&#9;')"/>
    <xsl:value-of select="concat($subcorpus, '&#9;')"/>
    <!-- Speaker metadata -->
    <xsl:value-of select="concat(et:u-role(@ana), '&#9;')"/>
    <xsl:choose>
      <xsl:when test="not(@who)">
	<xsl:text>-&#9;</xsl:text>
	<xsl:text>-&#9;</xsl:text>
	<xsl:text>-&#9;</xsl:text>
	<xsl:text>-&#9;</xsl:text>
	<xsl:text>-&#9;</xsl:text>
	<xsl:text>-</xsl:text>
      </xsl:when>
      <xsl:otherwise>
	<xsl:variable name="speaker" select="key('idr', @who, $teiHeader)"/>
	<xsl:if test="not(normalize-space($speaker))">
	  <xsl:message terminate="yes">
	    <xsl:text>Can't find speaker for </xsl:text>
	    <xsl:value-of select="@who"/>
	  </xsl:message>
	</xsl:if>
	<xsl:value-of select="concat(et:speaker-type($speaker), '&#9;')"/>
	<xsl:value-of select="concat(et:speaker-party($speaker, 'init'), '&#9;')"/>
	<xsl:value-of select="concat(et:speaker-party($speaker, 'yes'), '&#9;')"/>
	<xsl:value-of select="concat(et:format-name($speaker//tei:persName[1]), '&#9;')"/>
	<xsl:choose>
	  <xsl:when test="$speaker/tei:sex">
	    <xsl:value-of select="$speaker/tei:sex/@value"/>
	  </xsl:when>
	  <xsl:otherwise>-</xsl:otherwise>
	</xsl:choose>
	<xsl:text>&#9;</xsl:text>
	<xsl:choose>
	  <xsl:when test="$speaker/tei:birth">
	    <xsl:value-of select="replace($speaker/tei:birth/@when, '-.+', '')"/>
	  </xsl:when>
	  <xsl:otherwise>-</xsl:otherwise>
	</xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
    <!-- Speech sizes -->
    <!--xsl:value-of select="count(.//tei:w) + count(.//tei:pc)"/-->
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <!-- NAMED TEMPLATES -->

  <!-- Number of a certain type of meeting -->
  <xsl:template name="meeting">
    <xsl:param name="ref"/>
    <xsl:variable name="result">
      <xsl:variable name="idref" select="concat('#', $ref)"/>
      <xsl:for-each select="//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:meeting">
	<xsl:variable name="n" select="@n"/>
	<xsl:for-each select="tokenize(@ana, ' ')">
	  <xsl:if test="starts-with(., $idref)">
	    <xsl:value-of select="$n"/>
	  </xsl:if>
	</xsl:for-each>
      </xsl:for-each>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="normalize-space($result)">
	<xsl:value-of select="$result"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:text>-</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
    
  <!-- FUNCTIONS -->

  <!-- Format the name of a person from persName -->
  <xsl:function name="et:format-name">
    <xsl:param name="persName"/>
    <xsl:variable name="surnames">
      <xsl:for-each select="$persName/tei:surname">
	<xsl:value-of select="."/>
	<xsl:if test="following-sibling::tei:surname">
	  <xsl:text>&#32;</xsl:text>
	</xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="forenames">
      <xsl:for-each select="$persName/tei:forename">
	<xsl:value-of select="."/>
	<xsl:if test="following-sibling::tei:forename">
	  <xsl:text>&#32;</xsl:text>
	</xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="normalize-space($surnames) and normalize-space($forenames)">
	<xsl:value-of select="concat($surnames, ', ', $forenames)"/>
      </xsl:when>
      <xsl:when test="normalize-space($surnames)">
	<xsl:value-of select="normalize-space($surnames)"/>
      </xsl:when>
      <xsl:when test="normalize-space($forenames)">
	<xsl:value-of select="normalize-space($surnames)"/>
      </xsl:when>
      <xsl:when test="$persName/tei:term">
	<xsl:value-of select="concat('@', $persName/tei:term, '@')"/>
      </xsl:when>
      <xsl:when test="normalize-space($persName)">
	<xsl:value-of select="$persName"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:message>
	  <xsl:text>ERROR: empty persName for </xsl:text>
	  <xsl:value-of select="$persName"/>
	</xsl:message>
	<xsl:text>-</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- Output the role of the speaker from the taxonomy -->
  <!-- e.g. "#regular #topic.144_403_M" -->
  <xsl:function name="et:u-role" as="xs:string">
    <xsl:param name="ana"/>
    <xsl:for-each select="tokenize($ana, ' ')">
      <xsl:if test="key('idr', ., $teiHeader)/
		    ancestor::tei:taxonomy/tei:desc/tei:term = 'Types of speakers'">
	<xsl:value-of select="key('idr', ., $teiHeader)//tei:catDesc
			      [ancestor-or-self::tei:*[@xml:lang][1][@xml:lang='en']]
			      /tei:term"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:function>

  <!-- Output if the speaker is an MP or merely a 'visitor'
       when speaking (= check global $date-from and $date-to) -->
  <xsl:function name="et:speaker-type" as="xs:string">
    <xsl:param name="speaker" as="element(tei:person)"/>
    <xsl:variable name="mp" select="$speaker/tei:affiliation[@role='MP']"/>
    <xsl:variable name="type">
      <xsl:for-each select="$mp/self::tei:affiliation">
	<xsl:choose>
	  <xsl:when test="@from and @to">
	    <xsl:if test="et:between-dates($date-from, @from, @to) and
			  et:between-dates($date-to, @from, @to)">
	      <xsl:value-of select="$mp-label"/>
	    </xsl:if>
	  </xsl:when>
	  <xsl:when test="@from">
	    <xsl:if test="et:between-dates($date-from, @from, $today-iso) and
			  et:between-dates($date-to, @from, $today-iso)">
	      <xsl:value-of select="$mp-label"/>
	    </xsl:if>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of select="$mp-label"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:for-each>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="normalize-space($type)">
	<xsl:if test="$type ne $mp-label">
	  <xsl:message>
	    <xsl:text>ERROR: multiple MP for </xsl:text>
	    <xsl:value-of select="$speaker/@xml:id"/>
	    <xsl:text> on </xsl:text>
	    <xsl:value-of select="concat($date-from, ' - ', $date-to, ': ', $type)"/>
	  </xsl:message>
	</xsl:if>
	<xsl:value-of select="$type"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$guest-label"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- Output the name of the party (or parties!) the speaker belongs to when speaking -->
  <xsl:function name="et:speaker-party" as="xs:string">
    <xsl:param name="speaker" as="element(tei:person)"/>
    <!-- Output full ('yes') or abbreviated ('init') name of the party -->
    <xsl:param name="full" as="xs:string"/>
    <!-- Collect all affiliation references where the speaker is a member and are in 
	 the correct time-frame for the speech -->
    <xsl:variable name="refs">
      <xsl:variable name="tmp">
	<xsl:for-each select="$speaker/tei:affiliation
			      [@role='member' or @role='candidateMP' or 
			      @role='president' or @role='vicePresident' or @role='secretary']">
	  <xsl:choose>
	    <xsl:when test="@from and @to">
	      <xsl:if test="et:between-dates($date-from, @from, @to) and
			    et:between-dates($date-to, @from, @to)">
		<xsl:value-of select="@ref"/>
	      </xsl:if>
	    </xsl:when>
	    <xsl:when test="@from">
	      <xsl:if test="et:between-dates($date-from, @from, $today-iso) and
			    et:between-dates($date-to, @from, $today-iso)">
		<xsl:value-of select="@ref"/>
	      </xsl:if>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:value-of select="@ref"/>
	    </xsl:otherwise>
	  </xsl:choose>
	  <xsl:text>&#32;</xsl:text>
	</xsl:for-each>
      </xsl:variable>
      <!--xsl:if test="contains(normalize-space($tmp), ' ')">
	<xsl:message>
	  <xsl:text>WARN: more than one party for </xsl:text>
	  <xsl:value-of select="$speaker/@xml:id"/>
	  <xsl:text> on </xsl:text>
	  <xsl:value-of select="concat($date-from, ' - ', $date-to, ': ', $tmp)"/>
	</xsl:message>
      </xsl:if-->
      <xsl:value-of select="normalize-space($tmp)"/>
    </xsl:variable>
    <xsl:variable name="politicalParties">
      <xsl:variable name="tmp">
	<xsl:for-each select="tokenize($refs, ' ')">
	  <xsl:variable name="party" select="key('idr', ., $teiHeader)[@role='politicalParty']"/>
	  <xsl:call-template name="party-name">
	    <xsl:with-param name="party" select="$party"/>
	    <xsl:with-param name="full" select="$full"/>
	  </xsl:call-template>
	  <xsl:text>;</xsl:text>
	</xsl:for-each>
      </xsl:variable>
      <xsl:value-of select="replace($tmp, ';$', '')"/>
    </xsl:variable>
    <xsl:variable name="politicalGroups">
      <xsl:variable name="tmp">
	<xsl:for-each select="tokenize($refs, ' ')">
	  <xsl:variable name="party" select="key('idr', ., $teiHeader)[@role='politicalGroup']"/>
	  <xsl:call-template name="party-name">
	    <xsl:with-param name="party" select="$party"/>
	    <xsl:with-param name="full" select="$full"/>
	  </xsl:call-template>
	  <xsl:text>;</xsl:text>
	</xsl:for-each>
      </xsl:variable>
      <xsl:value-of select="replace($tmp, ';$', '')"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="normalize-space($politicalGroups)">
	<xsl:value-of select="$politicalGroups"/>
      </xsl:when>
      <xsl:when test="normalize-space($politicalParties)">
	<xsl:value-of select="$politicalParties"/>
      </xsl:when>
      <xsl:otherwise>-</xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- Return the name of the party -->
  <xsl:template name="party-name">
    <xsl:param name="party"/>
    <xsl:param name="full"/>
    <xsl:choose>
      <!-- Try original language name first -->
      <xsl:when test="$party/tei:orgName[@full=$full]
		      [ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang != 'en']">
	<xsl:value-of select="$party/tei:orgName[@full=$full]
			      [ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang != 'en']"/>
      </xsl:when>
      <!-- Then try English name -->
      <xsl:when test="$party/tei:orgName[@full=$full]
		      [ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang = 'en']">
	<xsl:value-of select="$party/tei:orgName[@full=$full]
			      [ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang = 'en']"/>
      </xsl:when>
      <!-- Then fall-back on ID -->
      <xsl:when test="$full = 'init' and $party/@xml:id">
	<xsl:message>
	  <xsl:text>WARN: party without short name </xsl:text>
	  <xsl:value-of select="$party/@xml:id"/>
	</xsl:message>
	<!-- Shorten if possible -->
	<xsl:value-of select="replace($party/@xml:id, '.+?\.' , '')"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <!-- Is the first date between the following two? -->
  <xsl:function name="et:between-dates" as="xs:boolean">
    <xsl:param name="date" as="xs:string"/>
    <xsl:param name="from" as="xs:string"/>
    <xsl:param name="to" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="xs:date(et:fix-date($date)) &gt;= xs:date(et:fix-date($from)) and
	              xs:date(et:fix-date($date)) &lt;= xs:date(et:fix-date($to))">
	<xsl:value-of select="true()"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="false()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- Fix too long or too short dates a la "2013-10-26T14:00:00" or "2018-02" -->
  <xsl:function name="et:fix-date">
    <xsl:param name="date"/>
    <xsl:choose>
      <xsl:when test="matches($date, '^\d\d\d\d-\d\d-\d\dT.+$')">
	<xsl:value-of select="substring-before($date, 'T')"/>
      </xsl:when>
      <xsl:when test="matches($date, '^\d\d\d\d-\d\d-\d\d$')">
	<xsl:value-of select="$date"/>
      </xsl:when>
      <xsl:when test="matches($date, '^\d\d\d\d-\d\d$')">
	<!--xsl:message>
	  <xsl:text>WARN: short date </xsl:text>
	  <xsl:value-of select="$date"/>
	</xsl:message-->
	<xsl:value-of select="concat($date, '-01')"/>
      </xsl:when>
      <xsl:when test="matches($date, '^\d\d\d\d$')">
	<!--xsl:message>
	  <xsl:text>WARN: short date </xsl:text>
	  <xsl:value-of select="$date"/>
	</xsl:message-->
	<xsl:value-of select="concat($date, '-01-01')"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:message terminate="yes">
	  <xsl:text>ERROR: bad date </xsl:text>
	  <xsl:value-of select="$date"/>
	</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
</xsl:stylesheet>
