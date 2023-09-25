<?xml version="1.0"?>
<!-- Library of templates for import into other ParlaMint scripts -->
<!-- PARTY AFFILIATION + NAME NEEDS TO BE UPDATED ACCORDING TO V3 ENCODING!!! -->
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:tei="http://www.tei-c.org/ns/1.0" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:mk="http://ufal.mff.cuni.cz/matyas-kopp"
  xmlns:et="http://nl.ijs.si/et"
  exclude-result-prefixes="#all"
  version="2.0">

  <!-- Which language the metadata should be output (where there is a choice)
       Legal values are:
       - xx (language of the corpus or fall-back option)
       - en (English or fall-back option)
  -->
  <xsl:param name="out-lang">xx</xsl:param>
  
  <!-- Filename of corpus root containing the corpus-wide metadata -->
  <xsl:param name="meta"/>

  <!-- Separator for multi-valued (parliamentary) "body" attribute; must have only one char --> 
  <xsl:param name="body-separator">|</xsl:param>
  
  <!-- Output label for MPs and non-MPs (in vertical and metadata output) --> 
  <xsl:param name="mp-label">MP</xsl:param>
  <xsl:param name="nonmp-label">notMP</xsl:param>
  
  <!-- Output label for Ministers and non-Ministers (in vertical and metadata output) -->
  <!-- Non-minister set to -, as not all corpora have ministers encoded yet -->
  <xsl:param name="minister-label">Minister</xsl:param>
  <xsl:param name="nonminister-label">notMinister</xsl:param>
  
  <!-- Output label for a coalition and opposition party (in vertical or metadata output) --> 
  <xsl:param name="coalition-label">Coalition</xsl:param>
  <xsl:param name="opposition-label">Opposition</xsl:param>
  
  <!-- Key in value of element ID -->
  <xsl:key name="id" match="tei:*" use="@xml:id"/>
  <!-- Key which directly finds local references -->
  <xsl:key name="idr" match="tei:*" use="concat('#', @xml:id)"/>

  <xsl:variable name="corpus-language" select="/tei:*/@xml:lang"/>
  
  <!-- Current date in ISO format -->
  <xsl:variable name="today-iso" select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>
  
  <!-- Date of a corpus component -->
  <xsl:variable name="at-date">
    <xsl:variable name="date" select="/tei:TEI/tei:teiHeader//tei:setting/tei:date"/>
    <xsl:if test="not($date/@when)">
      <xsl:message terminate="yes">
        <xsl:text>FATAL ERROR: Can't find TEI date/@when in setting of input file </xsl:text>
        <xsl:value-of select="/tei:TEI/@xml:id"/>
      </xsl:message>
    </xsl:if>
    <xsl:value-of select="$date/@when"/>
  </xsl:variable>
  
  <!-- Parliamentary body, term, session, meeting, sitting, agenda number or label of a corpus compoment -->
  <xsl:variable name="body">
    <xsl:call-template name="body"/>
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
  
  <!-- Subcorpus -->
  <xsl:variable name="subcorpus">
    <xsl:variable name="subcorpora">
      <xsl:for-each select="tokenize(/tei:TEI/@ana, ' ')">
	<xsl:if test="key('idr', ., $rootHeader)/
                      ancestor::tei:taxonomy/tei:desc/tei:term = 'Subcorpora'">
	  <!-- The category term of the tokenised @ana: -->
          <xsl:value-of select="et:l10n($corpus-language, key('idr', ., $rootHeader)/tei:catDesc)/tei:term"/>
	  <xsl:text>&#32;</xsl:text>
	</xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <!-- If component belongs to several subcorpora, retain only last one -->
    <xsl:choose>
      <xsl:when test="matches(normalize-space($subcorpora), '&#32;')">
	<xsl:value-of select="substring-after(normalize-space($subcorpora), '&#32;')"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="normalize-space($subcorpora)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <xsl:variable name="rootHeader">
    <xsl:choose>
      <xsl:when test="normalize-space($meta)">
        <xsl:if test="not(doc-available($meta))">
          <xsl:message terminate="yes">
            <xsl:text>FATAL ERROR: root document </xsl:text>
            <xsl:value-of select="$meta"/>
            <xsl:text> given as "meta" parameter not found !</xsl:text>
          </xsl:message>
        </xsl:if>
        <xsl:apply-templates mode="XInclude" select="document($meta)//tei:teiHeader">
	  <xsl:with-param name="lang" select="document($meta)/tei:*/@xml:lang"/>
	</xsl:apply-templates>
      </xsl:when>
      <xsl:when test="/tei:teiCorpus/tei:teiHeader">
        <xsl:apply-templates mode="XInclude" select="/tei:teiCorpus/tei:teiHeader"/>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>
  
  <!-- TEMPLATES WITH SPECIAL MODES -->

  <!-- Copy input element to output with XIncluding the files 
       ALSO: puts @xml:lang on all elements; the value is taken from the closest ancestor 
       or given as a paramter if the input does not have ancestor with @xml:lang i.e. root -->
  <xsl:template mode="XInclude" match="tei:*">
    <xsl:param name="lang" select="ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang"/>
    <xsl:variable name="thisLang" select="ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang"/>
    <xsl:copy>
      <xsl:apply-templates mode="XInclude" select="@*"/>
      <!-- Copy over language to every element, so we can immediatelly know which langauge it is in -->
      <xsl:attribute name="xml:lang">
	<xsl:choose>
	  <xsl:when test="normalize-space($thisLang)">
            <xsl:value-of select="$thisLang"/>
	  </xsl:when>
	  <xsl:otherwise>
            <xsl:value-of select="$lang"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:attribute>
      <xsl:apply-templates mode="XInclude">
	<xsl:with-param name="lang" select="$lang"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  <xsl:template mode="XInclude" match="xi:include">
    <xsl:apply-templates mode="XInclude" select="document(@href)"/>
  </xsl:template>
  <xsl:template mode="XInclude" match="@*">
    <xsl:copy/>
  </xsl:template>

  <!-- NAMED TEMPLATES -->

  <!-- Get the name of the parliamentary body from meeting elements, e.g. from this series:
       <meeting ana="#parla.term #parla.lower #parliament.PSP7" n="ps2013">ps2013</meeting>
       <meeting ana="#parla.meeting #parla.lower" n="ps2013/001">ps2013/001</meeting>
       <meeting ana="#parla.sitting #parla.lower" n="ps2013/001/01">ps2013/001/01</meeting>
       <meeting ana="#parla.agenda #parla.lower" n="ps2013/001/000">ps2013/001/000</meeting>
       or from this:
       <meeting corresp="#ParlaMint-FR-LOWER" ana="#parla.national #parla.lower #parla.term #parla.term.15">15e législature</meeting>
       <meeting corresp="#ParlaMint-FR-LOWER" ana="#parla.session #ParlaMint-FR-LOWER">Session ordinaire 2016-2017</meeting>
       <meeting corresp="#ParlaMint-FR-LOWER" ana="#parla.sitting #ParlaMint-FR-LOWER">124. séance</meeting>

       We compute the set of all references in meeting/@ana and type to match them with the taxonomy category that has
       parla.organization as the ancestor category ID.
  -->
  <xsl:template name="body">
    <xsl:variable name="titleStmt" select="//tei:teiHeader/tei:fileDesc/tei:titleStmt"/>
    <xsl:variable name="references">
      <xsl:for-each select="$titleStmt/tei:meeting">
	<xsl:value-of select="concat(@ana, ' ')"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="bodies">
      <xsl:variable name="bods">
	<xsl:for-each select="distinct-values(tokenize(normalize-space($references), ' '))">
	  <xsl:if test="key('idr', ., $rootHeader)[ancestor::tei:category[@xml:id = 'parla.organization']]">
            <xsl:variable name="body-en" select="et:l10n('en', key('idr', ., $rootHeader)/tei:catDesc)/tei:term"/>
            <xsl:variable name="body" select="et:l10n($corpus-language, key('idr', ., $rootHeader)/tei:catDesc)/tei:term"/>
	    <!-- We unfortunatelly need an explicit test if the reference we got is appropriate -->
	    <!-- This needs to be rethought! (e.g. 'National Parliament' might be better than 'Unicameralism' -->
	    <xsl:if test="$body-en = 'Unicameralism' or
			  $body-en = 'Upper house' or 
			  $body-en = 'Lower house' or 
			  $body-en = 'Committee'">
	      <xsl:if test="contains($body, $body-separator)">
		<xsl:message select="concat('ERROR: ', $body, ' should not contain ', $body-separator)"/>
	      </xsl:if>
	      <xsl:value-of select="$body"/>
	      <xsl:value-of select="$body-separator"/>
	    </xsl:if>
	  </xsl:if>
	</xsl:for-each>
      </xsl:variable>
      <!-- Backslash only if body-separator must be an escaped char (as is pipe)! -->
      <xsl:value-of select="replace($bods, concat('\', $body-separator, '$'), '')"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="normalize-space($bodies)">
	<xsl:value-of select="$bodies"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message select="concat('ERROR: cannot determine of which body the component ', 
			     replace(base-uri(), '.+/', ''), ' is a meeting of!')"/>
	<xsl:text>-</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Get @n from appropriate meeting type, e.g.
       <meeting n="7" corresp="#DZ" ana="#parla.term #DZ.7">7. mandat</meeting>
       <meeting n="1" corresp="#DZ" ana="#parla.meeting.regular">Redna</meeting>
       or
       <meeting ana="#parla.lower">Sejm</meeting>
       <meeting n="8-lower" ana="#parla.lower #parla.term">8. kadencja Sejmu</meeting>
       <meeting n="1-lower" ana="#parla.lower #parla.session">1. sesja Sejmu</meeting>
       <meeting n="1-lower" ana="#parla.lower #parla.sitting">1. dzień sesji Sejmu</meeting>
       or
       <meeting ana="#parla.term #parla.lower #parliament.PSP8" n="ps2017">ps2017</meeting>
       <meeting ana="#parla.meeting #parla.lower" n="ps2017/070">ps2017/070</meeting>
       <meeting ana="#parla.sitting #parla.lower" n="ps2017/070/01">ps2017/070/01</meeting>
       <meeting ana="#parla.agenda #parla.lower" n="ps2017/070/001">ps2017/070/001</meeting>
       
  -->
  <xsl:template name="meeting">
    <xsl:param name="ref"/>
    <xsl:variable name="result">
      <xsl:variable name="idref" select="concat('#', $ref)"/>
      <xsl:for-each select="//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:meeting">
	<!-- Maybe we should ignore @n and use l10n-ed content of the corresponding event content? -->
        <xsl:variable name="n" select="@n"/>
        <xsl:for-each select="tokenize(@ana, ' ')">
          <xsl:if test="starts-with(., $idref)">
            <xsl:value-of select="$n"/>
	    <xsl:text>///</xsl:text>
          </xsl:if>
        </xsl:for-each>
      </xsl:for-each>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="normalize-space($result)">
        <xsl:for-each select="distinct-values(tokenize(replace($result, '///$', ''), '///'))">
          <xsl:value-of select="."/>
	</xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>-</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
    
  <!-- FUNCTIONS -->

  <!-- Format the name of a person in a given point in time -->
  <!-- (a person can change their name, qualified by @from and @to) -->
  <xsl:function name="et:format-name-chrono">
    <xsl:param name="persNames"/>
    <xsl:param name="when"/>
    <xsl:variable name="persName">
      <xsl:for-each select="$persNames/self::tei:persName">
        <xsl:if test="et:between-dates($when, @from, @to)">
          <xsl:copy-of select="."/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="persNameLoc" select="et:l10n($corpus-language, $persName/tei:*)"/>
    <xsl:choose>
      <xsl:when test="not($persNameLoc)">
        <xsl:message select="concat('ERROR: empty persName from', $persNames[1], ' on ', $when)"/>
        <xsl:text>-</xsl:text>
      </xsl:when>
      <xsl:when test="$persNameLoc[2]">
        <xsl:message select="concat('ERROR: several persNames ', $persNameLoc,
                             ' on ', $when)"/>
        <xsl:value-of select="et:format-name($persNameLoc[1])"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="et:format-name($persNameLoc)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- Format the name of a person from persName -->
  <xsl:function name="et:format-name">
    <xsl:param name="persName"/>
    <xsl:choose>
      <xsl:when test="$persName/tei:forename[normalize-space(.)] or $persName/tei:surname[normalize-space(.)]">
	<xsl:value-of select="normalize-space(
                              string-join(
                              (
                              string-join($persName/tei:surname[not(@type='patronym')]/normalize-space(.),' '),
                              concat(
                              string-join($persName/tei:forename/normalize-space(.),' '),
                              ' ',
                              string-join($persName/tei:surname[@type='patronym']/normalize-space(.),' ')
                              )
                              )[normalize-space(.)],
                              ', ' ))"/>
      </xsl:when>
      <xsl:when test="$persName/tei:term">
	<xsl:value-of select="concat('@', $persName/tei:term, '@')"/>
      </xsl:when>
      <xsl:when test="normalize-space($persName)">
	<xsl:value-of select="$persName"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:message select="concat('ERROR: empty persName for ', $persName/@xml:id)"/>
	<xsl:text>-</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- Output the role of the speaker from the taxonomy -->
  <!-- e.g. "#regular #topic.144_403_M" -->
  <xsl:function name="et:u-role" as="xs:string">
    <xsl:param name="ana"/>
    <xsl:variable name="role">
      <xsl:for-each select="tokenize($ana, ' ')">
	<xsl:if test="key('idr', ., $rootHeader)/
                      ancestor::tei:taxonomy/tei:desc/tei:term = 'Types of speakers'">
          <xsl:value-of select="et:l10n($corpus-language, key('idr', ., $rootHeader)/tei:catDesc)/tei:term"/>
	</xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="normalize-space($role)">
	<xsl:value-of select="$role"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message select="concat('ERROR: no speaker role found in taxonony for ', $ana)"/>
	<xsl:text>unknown</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- Output appropriate label if the speaker is (not) an MP when speaking -->
  <xsl:function name="et:speaker-mp" as="xs:string">
    <xsl:param name="speaker" as="element(tei:person)"/>
    <xsl:variable name="mp">
      <xsl:variable name="refs" select="et:speaker-affiliations-refs($speaker)"/>
      <xsl:for-each select="distinct-values(tokenize($refs, ' '))">
        <xsl:if test="key('idr', ., $rootHeader)/@role='parliament'">parliament</xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="normalize-space($mp)">
        <xsl:value-of select="$mp-label"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$nonmp-label"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- Output appropriate label if the speaker is (not) a Minister when speaking -->
  <xsl:function name="et:speaker-minister" as="xs:string">
    <xsl:param name="speaker" as="element(tei:person)"/>
    <xsl:choose>
      <xsl:when test="$speaker/tei:affiliation[@role = 'minister']
		      [et:between-dates($at-date, @from, @to)]">
        <xsl:value-of select="$minister-label"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$nonminister-label"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- Output coalition/opposition of the speaker's party when speaking -->
  <xsl:function name="et:party-status" as="xs:string">
    <xsl:param name="speaker" as="element(tei:person)"/>
    <xsl:variable name="relations" select="$rootHeader//tei:relation
                                           [@name = 'coalition' or @name = 'opposition']"/>
    <xsl:choose>
      <xsl:when test="not($relations/self::tei:relation[@name='coalition'])">
        <xsl:message>ERROR: no coalition info found in corpus</xsl:message>
        <xsl:text>-</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="not($relations/self::tei:relation[@name = 'opposition'])">
	  <!-- We do not output warning here, as otherwise a huge number of such warnings our output.
	       Instead, validate-parlamint gives this warning only once for corpus
          <xsl:message>WARN: no opposition info found in corpus</xsl:message-->
        </xsl:if>
        <!-- Relation in the correct time-frame, should be only 1 -->
        <xsl:variable name="relation">
          <xsl:for-each select="$relations/self::tei:relation">
            <xsl:if test="et:between-dates($at-date, @from, @to)">
              <xsl:copy-of select="."/>
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>
        <!-- Is the organisation that the speaker is affiliated with in the
             coallition(s) / oppositions(s)? -->
        <!-- We don't check the type of organisation or the speaker's role in it, as we
             assume that this is "ok" -->
        <xsl:variable name="in-relations">
          <!-- Collect all affiliation references where the speaker is a member and are in
               the correct time-frame for the speech -->
          <xsl:variable name="org-refs" select="et:speaker-affiliations-refs($speaker)"/>
          <xsl:for-each select="$relation/tei:relation[@name = 'coalition']/tokenize(@mutual)">
            <xsl:variable name="relation-party" select="."/>
            <xsl:for-each select="tokenize($org-refs, ' ')">
              <xsl:if test="$relation-party = .">
                <xsl:value-of select="concat($coalition-label, '&#32;')"/>
              </xsl:if>
            </xsl:for-each>
          </xsl:for-each>
          <xsl:for-each select="$relation/tei:relation[@name = 'opposition']/tokenize(@active)">
            <xsl:variable name="relation-party" select="."/>
            <xsl:for-each select="tokenize($org-refs, ' ')">
              <xsl:if test="$relation-party = .">
                <xsl:value-of select="concat($opposition-label, '&#32;')"/>
              </xsl:if>
            </xsl:for-each>
          </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="in-relation">
          <xsl:for-each select="distinct-values(tokenize(normalize-space($in-relations)))">
            <xsl:value-of select="concat(., '&#32;')"/>
          </xsl:for-each>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="contains(normalize-space($in-relation), ' ')">
            <xsl:message>
              <xsl:text>ERROR: multiple party statuses for </xsl:text>
              <xsl:value-of select="$speaker/@xml:id"/>
              <xsl:text> on </xsl:text>
              <xsl:value-of select="concat($at-date, ': ',
                                    normalize-space($in-relation))"/>
            </xsl:message>
            <xsl:value-of select="substring-before($in-relation, ' ')"/>
          </xsl:when>
          <xsl:when test="normalize-space($in-relation)">
            <xsl:value-of select="normalize-space($in-relation)"/>
          </xsl:when>
          <xsl:otherwise>
	    <xsl:text>-</xsl:text>
	  </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- Output left-right orientation of the speaker's party when speaking -->
  <xsl:function name="et:party-orientation" as="xs:string">
    <xsl:param name="speaker" as="element(tei:person)"/>
    <!-- Collect all affiliation references where the speaker is a member and are in 
         the correct time-frame for the speech -->
    <xsl:variable name="refs" select="et:speaker-affiliations-refs($speaker)"/>
    <xsl:variable name="parliamentaryGroups">
      <xsl:for-each select="distinct-values(tokenize($refs, ' '))">
        <xsl:variable name="party" select="key('idr', ., $rootHeader)[@role='parliamentaryGroup']"/>
        <xsl:call-template name="party-orientation">
          <xsl:with-param name="party" select="$party"/>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="politicalParties">
      <xsl:for-each select="distinct-values(tokenize($refs, ' '))">
        <xsl:variable name="party" select="key('idr', ., $rootHeader)[@role='politicalParty']"/>
        <xsl:call-template name="party-orientation">
          <xsl:with-param name="party" select="$party"/>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="normalize-space($parliamentaryGroups)">
        <xsl:value-of select="replace($parliamentaryGroups, ';$', '')"/>
      </xsl:when>
      <xsl:when test="normalize-space($politicalParties)">
        <xsl:value-of select="replace($politicalParties, ';$', '')"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:text>-</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- Output the name of the party (or parties!) the speaker belongs to when speaking -->
  <xsl:function name="et:speaker-party" as="xs:string">
    <xsl:param name="speaker" as="element(tei:person)"/>
    <!-- Output full ('yes') or abbreviated ('abb') name of the party -->
    <xsl:param name="full" as="xs:string"/>
    <!-- Collect all affiliation references where the speaker is a member and are in 
         the correct time-frame for the speech -->
    <xsl:variable name="refs" select="et:speaker-affiliations-refs($speaker)"/>
    <xsl:variable name="parliamentaryGroups">
      <xsl:for-each select="distinct-values(tokenize($refs, ' '))">
        <xsl:variable name="party" select="key('idr', ., $rootHeader)[@role='parliamentaryGroup']"/>
        <xsl:call-template name="party-name">
          <xsl:with-param name="party" select="$party"/>
          <xsl:with-param name="full" select="$full"/>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="politicalParties">
      <xsl:for-each select="distinct-values(tokenize($refs, ' '))">
        <xsl:variable name="party" select="key('idr', ., $rootHeader)[@role='politicalParty']"/>
        <xsl:call-template name="party-name">
          <xsl:with-param name="party" select="$party"/>
          <xsl:with-param name="full" select="$full"/>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="normalize-space($parliamentaryGroups)">
        <xsl:value-of select="replace($parliamentaryGroups, ';$', '')"/>
      </xsl:when>
      <xsl:when test="normalize-space($politicalParties)">
        <xsl:value-of select="replace($politicalParties, ';$', '')"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:text>-</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- Output IDREFS to the speaker affiliations in the correct time-frame -->
  <xsl:function name="et:speaker-affiliations-refs" as="xs:string">
    <xsl:param name="speaker" as="element(tei:person)"/>
    <xsl:variable name="refs">
      <xsl:for-each select="$speaker/tei:affiliation
			    [@role='member' or @role='candidateMP' or
                            @role='president' or @role='vicePresident' or
			    @role='secretary' or @role='representative']">
        <xsl:if test="et:between-dates($at-date, @from, @to)">
          <xsl:value-of select="@ref"/>
          <xsl:text>&#32;</xsl:text>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <!--xsl:if test="contains(normalize-space($tmp), ' ')">
        <xsl:message>
        <xsl:text>WARN: more than one party for </xsl:text>
        <xsl:value-of select="$speaker/@xml:id"/>
        <xsl:text> on </xsl:text>
        <xsl:value-of select="concat($at-date, ': ', $tmp)"/>
        </xsl:message>
        </xsl:if-->
    <xsl:value-of select="normalize-space($refs)"/>
  </xsl:function>
  
  <!-- Return the name of the party -->
  <!-- if $party is empty, so it the result (it is not an error if this happens!) -->
  <xsl:template name="party-name">
    <xsl:param name="party"/>
    <xsl:param name="full"/>
    <xsl:variable name="orgName" select="et:l10n($corpus-language, $party/tei:orgName[@full=$full])"/>
    <xsl:choose>
      <xsl:when test="normalize-space($orgName)">
        <xsl:value-of select="$orgName"/>
        <xsl:text>;</xsl:text>
      </xsl:when>
      <xsl:when test="normalize-space($party)">
        <xsl:message select="concat('WARN: party ', $party/@xml:id, ' without orgName/@full = ', $full)"/>
        <!-- As a fall-back, return ID (i.e. the part of the ID after period for e.g. 'politicalParty.VCA') -->
        <xsl:value-of select="replace($party/@xml:id, '.+?\.' , '')"/>
        <xsl:text>;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text></xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Return the political orientation of the party, either from Wikipedia, or, if missing, encoder -->
  <xsl:template name="party-orientation">
    <xsl:param name="party"/>
    <xsl:variable name="orientation" select="$party/tei:state[@type = 'politicalOrientation']"/>
    <xsl:choose>
      <xsl:when test="$orientation/tei:state[@type = 'Wikipedia']">
	<xsl:value-of select="et:l10n($corpus-language, 
			      key('idr', $orientation/tei:state[@type = 'Wikipedia']/@ana, $rootHeader)/tei:catDesc)/tei:term"/>
      </xsl:when>
      <xsl:when test="$orientation/tei:state[@type = 'encoder']">
	<xsl:value-of select="et:l10n($corpus-language, 
			      key('idr', $orientation/tei:state[@type = 'encoder']/@ana, $rootHeader)/tei:catDesc)/tei:term"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <!-- Notes and incidents normalization - removing brackets and normalize spces-->
  <xsl:function name="mk:normalize-note" as="xs:string">
    <xsl:param name="noteIn" as="xs:string"/>
    <xsl:variable name="noteOut1" select="normalize-space($noteIn)"/>
    <!-- plain notes without any inner brackets of the same type-->
    <xsl:variable name="noteOut2" select="replace($noteOut1,'^\s*\[\s*([^\[\]]*?)\s*\][\s\.]*$','$1')"/>
    <xsl:variable name="noteOut3" select="replace($noteOut2,'^\s*/\s*([^/]*?)\s*/[\s\.]*$','$1')"/>
    <xsl:variable name="noteOut4" select="replace($noteOut3,'^\s*\(\s*([^\(\)]*?)\s*\)[\s\.]*$','$1')"/>
    <xsl:choose>
      <xsl:when test="$noteIn = $noteOut4"><xsl:value-of select="$noteOut4"/></xsl:when>
      <!-- make it recursive to make sure that double normalization has the same result -->
      <xsl:otherwise><xsl:value-of select="mk:normalize-note($noteOut4)"/></xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- Format number-->
  <xsl:function name="et:format-number" as="xs:string">
    <xsl:param name="lang" as="xs:string"/>
    <xsl:param name="quant"/>
    <xsl:variable name="form" select="format-number($quant, '###,###,###,###')"/>
    <xsl:choose>
      <xsl:when test="$lang = 'fr'">
        <xsl:value-of select="replace($form, ',', ' ')"/>
      </xsl:when>
      <xsl:when test="$lang = 'bg' or 
                      $lang = 'cs' or
                      $lang = 'hr' or
                      $lang = 'hu' or
                      $lang = 'is' or
                      $lang = 'it' or
                      $lang = 'lt' or
                      $lang = 'lv' or
                      $lang = 'pl' or
                      $lang = 'ro' or
                      $lang = 'sl' or
                      $lang = 'tr'
                      ">
        <xsl:value-of select="replace($form, ',', '.')"/>
      </xsl:when>
      <!-- Comma for thousands separator by default -->
      <xsl:otherwise>
        <xsl:value-of select="$form"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- Is the first date between the following two? -->
  <xsl:function name="et:between-dates" as="xs:boolean">
    <xsl:param name="date" as="xs:string"/>
    <xsl:param name="from" as="xs:string?"/>
    <xsl:param name="to" as="xs:string?"/>
    <xsl:choose>
      <xsl:when test="not(normalize-space($from) or normalize-space($to))">
        <xsl:value-of select="true()"/>
      </xsl:when>
      <xsl:when test="normalize-space($from) and normalize-space($to) and
                      xs:date(et:pad-date($date)) &gt;= xs:date(et:pad-date($from)) and
                      xs:date(et:pad-date($date)) &lt;= xs:date(et:pad-date($to))">
        <xsl:value-of select="true()"/>
      </xsl:when>
      <xsl:when test="not(normalize-space($from)) and normalize-space($to) and
                      xs:date(et:pad-date($date)) &lt;= xs:date(et:pad-date($to))" >
        <xsl:value-of select="true()"/>
      </xsl:when>
      <xsl:when test="normalize-space($from) and not(normalize-space($to)) and 
                      xs:date(et:pad-date($date)) &gt;= xs:date(et:pad-date($from))" >
        <xsl:value-of select="true()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="false()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- Fix too long or too short dates 
       a la "2013-10-26T14:00:00" or "2018" to xs:date e.g. 2018-01-01 -->
  <xsl:function name="et:pad-date">
    <xsl:param name="date"/>
    <xsl:choose>
      <xsl:when test="matches($date, '^\d\d\d\d-\d\d-\d\dT.+$')">
        <xsl:value-of select="substring-before($date, 'T')"/>
      </xsl:when>
      <xsl:when test="matches($date, '^\d\d\d\d-\d\d-\d\d$')">
        <xsl:value-of select="$date"/>
      </xsl:when>
      <xsl:when test="matches($date, '^\d\d\d\d-\d\d$')">
        <xsl:message>
          <xsl:text>WARN: short date </xsl:text>
          <xsl:value-of select="$date"/>
        </xsl:message>
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
  
  <!-- Output $toks as multivalued columns -->
  <xsl:function name="et:join-annotations">
    <xsl:param name="toks"/>
    <xsl:variable name="last" select="count($toks/tei:list)"/>
    <xsl:variable name="result">
      <!-- Counter through items -->
      <xsl:for-each select="$toks/tei:list[1]/tei:item">
        <xsl:variable name="i" select="position()"/>
        <xsl:variable name="feat">
          <xsl:for-each select="$toks/tei:list/tei:item[position() = $i]">
            <xsl:value-of select="."/>
            <xsl:text>|</xsl:text>
          </xsl:for-each>
        </xsl:variable>
        <!-- Snip off last | and remove duplicates (works only for 2 norm words) -->
        <xsl:value-of select="replace(
                              replace($feat, '\|$', ''),
                              '^(.+?)\|\1$', '$1')
                              "/>
        <xsl:text>&#9;</xsl:text>
      </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="replace($result, '&#9;$', '')"/>
  </xsl:function>
    
  <xsl:function name="et:output-annotations">
    <xsl:param name="token"/>
    <xsl:variable name="n" select="replace($token/@xml:id, '.+\.([^.]+)$', '$1')"/>
    <xsl:variable name="lemma">
      <xsl:choose>
        <xsl:when test="$token/@lemma">
          <xsl:value-of select="$token/@lemma"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="substring($token,1,1)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="ud-pos" select="replace(replace($token/@msd, 'UPosTag=', ''), '\|.+', '')"/>
    <xsl:variable name="ud-feats">
      <xsl:variable name="fs" select="replace($token/@msd, 'UPosTag=[^|]+\|?', '')"/>
      <xsl:choose>
        <xsl:when test="normalize-space($fs)">
          <!-- Change source pipe to whatever we have for multivalued attributes -->
          <xsl:value-of select="replace($fs, '\|', ' ')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text></xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <!-- Output token ID only if there is one -->
      <xsl:when test="normalize-space($n)">
	<xsl:sequence select="concat($lemma, '&#9;', $ud-pos, '&#9;', $ud-feats, '&#9;', $n)"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:sequence select="concat($lemma, '&#9;', $ud-pos, '&#9;', $ud-feats)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- Output the sibling element in $elements that is appropriate for output language (global $out-lang) -->
  <!-- $elements = 
          <orgName xml:lang="el" full="yes">Κοινοβούλιο της Ελλάδος</orgName>
          <orgName xml:lang="en" full="yes">Parliament of Greece</orgName>
       if $out-lang = xx result =
          <orgName xml:lang="el" full="yes">Κοινοβούλιο της Ελλάδος</orgName>
       if $out-lang = en result =
          <orgName xml:lang="en" full="yes">Parliament of Greece</orgName>

       $elements = 
         <orgName full="abb">Ν.Δ.</orgName>
         <orgName full="abb" xml:lang="el-Latn">N.D.</orgName>
       if $out-lang = xx result =
         <orgName full="abb">Ν.Δ.</orgName>
       if $out-lang = en result =
         <orgName full="abb" xml:lang="el-Latn">N.D.</orgName>

       The asssumption is that all elements in $elements have @xml:lang, i.e. have been processed with XInclude mode
  -->
  <xsl:function name="et:l10n">
    <xsl:param name="corpus-language"/>
    <xsl:param name="elements"/>
    <!-- Should never happen, as all meta elements should be marked for @xml:lang -->
    <xsl:if test="$elements[not(@xml:lang)]">
      <xsl:message terminate="yes" select="concat('FATAL ERROR: no @xml:lang at least in ', 
					   $elements[not(@xml:lang)][1])"/>
    </xsl:if>
    <!--xsl:message select="concat('DEBUG: out-lang = ', $out-lang, ', corpus language = ', $corpus-language)"/-->
    <!-- Original language -->
    <xsl:variable name="element-xx" select="$elements[@xml:lang = $corpus-language]"/>
    <!-- Latin spelling -->
    <xsl:variable name="element-lt" select="$elements[ends-with(@xml:lang, '-Latn')]"/>
    <!-- English -->
    <xsl:variable name="element-en" select="$elements[@xml:lang = 'en']"/>
    <!-- For (the only example in ParlaMint) the French spelling of a name in GR. -->
    <!-- Note that corpus-langauge can be "en" for MTed corpora, so we need to choose only one result -->
    <xsl:variable name="element-yy" select="$elements[not(@xml:lang = 'en' or
					    @xml:lang = $corpus-language or ends-with(@xml:lang, '-Latn'))][1]"/>
    <!-- If nothing else serves... -->
    <xsl:variable name="element-fb" select="$elements[1]"/>
    <xsl:choose>
      <xsl:when test="$out-lang = 'xx'">
	<xsl:choose>
	  <xsl:when test="normalize-space($element-xx[1])">
	    <xsl:copy-of select="$element-xx"/>
	  </xsl:when>
	  <xsl:when test="normalize-space($element-lt[1])">
	    <xsl:copy-of select="$element-lt"/>
	  </xsl:when>
	  <xsl:when test="normalize-space($element-yy[1])">
	    <xsl:copy-of select="$element-yy"/>
	  </xsl:when>
	  <xsl:when test="normalize-space($element-en[1])">
	    <xsl:copy-of select="$element-en"/>
	  </xsl:when>
	  <xsl:when test="normalize-space($element-fb[1])">
	    <xsl:copy-of select="$element-fb"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <!-- It is legitimate to get an empty $elements! -->
	    <xsl:text></xsl:text>
	    <!--xsl:message select="concat('ERROR: l10n cant find element in given parameter elements: ', 
				 $elements[1]/name(), ' / ', $elements)"/-->
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:when>
      <xsl:when test="$out-lang = 'en'">
	<xsl:choose>
	  <xsl:when test="normalize-space($element-en[1])">
	    <xsl:copy-of select="$element-en"/>
	  </xsl:when>
	  <xsl:when test="normalize-space($element-lt[1])">
	    <xsl:copy-of select="$element-lt"/>
	  </xsl:when>
	  <xsl:when test="normalize-space($element-yy[1])">
	    <xsl:copy-of select="$element-yy"/>
	  </xsl:when>
	  <xsl:when test="normalize-space($element-fb[1])">
	    <xsl:copy-of select="$element-fb"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <!-- It is legitimate to get an empty $elements! -->
	    <xsl:text></xsl:text>
	    <!--xsl:message select="concat('ERROR: l10n cant find element in given parameter elements for language ', 
				 $out-lang, ' and element ', $elements/name(), ':', $elements)"/-->
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:when>
      <xsl:otherwise>
	<xsl:message terminate="yes"
		     select="concat('FATAL ERROR: parameter out-lang should be xx or en, not ',
			     '&quot;', $out-lang, '&quot;')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
</xsl:stylesheet>
