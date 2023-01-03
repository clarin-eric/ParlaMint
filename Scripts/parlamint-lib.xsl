<?xml version="1.0"?>
<!-- Library of templates for import into other ParlaMint scripts -->
<!-- PARTY AFFILIATION + NAME NEEDS TO BE UPDATED ACCORDING TO V3 ENCODING!!! -->
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:tei="http://www.tei-c.org/ns/1.0" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:et="http://nl.ijs.si/et" 
  exclude-result-prefixes="#all"
  version="2.0">

  <!-- Filename of corpus root containing the corpus-wide metadata -->
  <xsl:param name="meta"/>

  <!-- Output label for MPs and non-MPs (in vertical or metadata output) --> 
  <xsl:param name="mp-label">MP</xsl:param>
  <xsl:param name="nonmp-label">notMP</xsl:param>
  
  <!-- Output label for a coalition and opposition party (in vertical or metadata output) --> 
  <xsl:param name="coalition-label">Coalition</xsl:param>
  <xsl:param name="opposition-label">Opposition</xsl:param>
  
  <!-- Key in value of element ID -->
  <xsl:key name="id" match="tei:*" use="@xml:id"/>
  <!-- Key which directly finds local references -->
  <xsl:key name="idr" match="tei:*" use="concat('#', @xml:id)"/>

  <xsl:variable name="corpus-language" select="/tei:TEI/@xml:lang"/>
  
  <!-- Current date in ISO format -->
  <xsl:variable name="today-iso" select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>
  
  <!-- $date-from and $date-to of a corpus component (assumed at XML root) -->
  <!-- Typically are identical, but not necessarily -->
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
          <xsl:text>FATAL: Can't find TEI date-from in settingDesc of input file </xsl:text>
          <xsl:value-of select="/tei:TEI/@xml:id"/>
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
      <xsl:otherwise>
        <xsl:message terminate="yes">
          <xsl:text>FATAL: Can't find TEI date-to in settingDesc of input file </xsl:text>
          <xsl:value-of select="/tei:TEI/@xml:id"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <!-- House, term, session, meeting, sitting, agenda number or label of a corpus compoment -->
  <xsl:variable name="house">
    <xsl:call-template name="house"/>
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
  
  <!-- COVID / reference subcorpus -->
  <xsl:variable name="subcorpus">
    <xsl:for-each select="tokenize(/tei:TEI/@ana, ' ')">
      <xsl:if test="key('idr', ., $rootHeader)/
                    ancestor::tei:taxonomy/tei:desc/tei:term = 'Subcorpora'">
        <xsl:value-of select="key('idr', ., $rootHeader)//tei:catDesc
                              [ancestor-or-self::tei:*[@xml:lang][1][@xml:lang='en']]
                              /tei:term"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>
  
  <xsl:variable name="rootHeader">
    <xsl:choose>
      <xsl:when test="normalize-space($meta)">
        <xsl:if test="not(doc-available($meta))">
          <xsl:message terminate="yes">
            <xsl:text>FATAL: root document </xsl:text>
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

  <!-- Get the name (Lower House, Upper house, -) of the house from meeting element, e.g.
       <meeting ana="#parla.term #parla.lower #parliament.PSP8" n="ps2017">ps2017</meeting>
       <meeting corresp="#PoGB" ana="#parla.upper #parla.meeting.regular"/>
       <meeting ana="#parla.meeting.regular" corresp="#NS" n="394">394 пленарно заседание</meeting>
  -->
  <xsl:template name="house">
    <xsl:param name="lower">Lower house</xsl:param>
    <xsl:param name="upper">Upper house</xsl:param>
    <xsl:param name="none"></xsl:param>
    <xsl:variable name="titleStmt" select="//tei:teiHeader/tei:fileDesc/tei:titleStmt"/>
    <xsl:variable name="is_lower">
      <xsl:for-each select="$titleStmt/tei:meeting">
        <xsl:for-each select="tokenize(@ana, ' ')">
          <xsl:if test="key('idr', ., $rootHeader)/tei:catDesc[tei:term = $lower]">X</xsl:if>
        </xsl:for-each>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="is_upper">
      <xsl:for-each select="$titleStmt/tei:meeting">
        <xsl:for-each select="tokenize(@ana, ' ')">
          <xsl:if test="key('idr', ., $rootHeader)/tei:catDesc[tei:term = $upper]">X</xsl:if>
        </xsl:for-each>
      </xsl:for-each>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="normalize-space($is_lower)">
        <xsl:value-of select="$lower"/>
      </xsl:when>
      <xsl:when test="normalize-space($is_upper)">
        <xsl:value-of select="$upper"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$none"/>
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
        <xsl:text></xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
    
  <!-- FUNCTIONS -->

  <!-- Format the name of a person in a given point in time -->
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
    <xsl:choose>
      <!-- Two names in different languages / scripts, we choose the
           Latin script if possible, othewise first -->
      <xsl:when test="$persName/tei:persName[2] and 
                      $persName/tei:persName[1]/@xml:lang != $persName/tei:persName[2]/@xml:lang">
        <xsl:choose>
          <xsl:when test="ends-with($persName/tei:persName[1]/@xml:lang, 'Latn')">
            <xsl:value-of select="et:format-name($persName/tei:persName[1])"/>
          </xsl:when>
          <xsl:when test="ends-with($persName/tei:persName[2]/@xml:lang, 'Latn')">
            <xsl:value-of select="et:format-name($persName/tei:persName[2])"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="et:format-name($persName/tei:persName[1])"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$persName/tei:persName[2]">
        <xsl:message select="concat('ERROR: several persNames ', $persName,
                             ' on ', $when)"/>
        <xsl:value-of select="et:format-name($persName/tei:persName[1])"/>
      </xsl:when>
      <xsl:when test="not($persName/tei:persName)">
        <xsl:message select="concat('ERROR: empty persName ',
                             'on ', $when)"/>
        <xsl:text></xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="et:format-name($persName/tei:persName)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
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
        <xsl:message select="concat('ERROR: empty persName for ', $persName/@xml:id)"/>
        <xsl:text></xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- Output the role of the speaker from the taxonomy -->
  <!-- e.g. "#regular #topic.144_403_M" -->
  <xsl:function name="et:u-role" as="xs:string">
    <xsl:param name="ana"/>
    <!--xsl:message terminate="yes" select="concat('THIS: ', $rootHeader)"/-->
    <xsl:for-each select="tokenize($ana, ' ')">
      <xsl:if test="key('idr', ., $rootHeader)/
                    ancestor::tei:taxonomy/tei:desc/tei:term = 'Types of speakers'">
        <xsl:value-of select="key('idr', ., $rootHeader)//tei:catDesc
                              [ancestor-or-self::tei:*[@xml:lang][1][@xml:lang='en']]
                              /tei:term"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:function>

  <!-- Output appropriate label if the speaker is (not) an MP when speaking -->
  <xsl:function name="et:speaker-type" as="xs:string">
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
  
  <!-- Output coalition/opposition of the speaker's party when speaking -->
  <xsl:function name="et:party-status" as="xs:string">
    <xsl:param name="speaker" as="element(tei:person)"/>
    <xsl:variable name="relations" select="$rootHeader//tei:relation
                                           [@name='coalition' or @name='opposition']"/>
    <xsl:choose>
      <xsl:when test="not($relations/self::tei:relation[@name='coalition'])">
        <xsl:message>ERROR: no coalition info found in corpus</xsl:message>
        <xsl:text></xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="not($relations/self::tei:relation[@name='opposition'])">
          <xsl:message>WARN: no opposition info found in corpus</xsl:message>
        </xsl:if>
        <!-- Relation in the correct time-frame, should be only 1 -->
        <xsl:variable name="relation">
          <xsl:for-each select="$relations/self::tei:relation">
            <xsl:if test="et:between-dates($date-from, @from, @to) and
                          et:between-dates($date-to,   @from, @to)">
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
              <xsl:value-of select="concat($date-from, ' - ', $date-to, ': ',
                                    normalize-space($in-relation))"/>
            </xsl:message>
            <xsl:value-of select="substring-before($in-relation, ' ')"/>
          </xsl:when>
          <xsl:when test="normalize-space($in-relation)">
            <xsl:value-of select="normalize-space($in-relation)"/>
          </xsl:when>
          <xsl:otherwise><xsl:text></xsl:text></xsl:otherwise>
        </xsl:choose>
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
      <xsl:otherwise><xsl:text></xsl:text></xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- Output IDREFS to the speaker affiliations in the correct time-frame -->
  <xsl:function name="et:speaker-affiliations-refs" as="xs:string">
    <xsl:param name="speaker" as="element(tei:person)"/>
    <xsl:variable name="refs">
      <xsl:for-each select="$speaker/tei:affiliation
                            [@role='member' or @role='candidateMP' or
                            @role='president' or @role='vicePresident' or @role='secretary']">
        <xsl:if test="et:between-dates($date-from, @from, @to) and
                      et:between-dates($date-to, @from, @to)">
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
        <xsl:value-of select="concat($date-from, ' - ', $date-to, ': ', $tmp)"/>
        </xsl:message>
        </xsl:if-->
    <xsl:value-of select="normalize-space($refs)"/>
  </xsl:function>
  
  <!-- Return the name of the party -->
  <xsl:template name="party-name">
    <xsl:param name="party"/>
    <xsl:param name="full"/>
    <xsl:variable name="name-local"
                  select="$party/tei:orgName[@full=$full]
                          [ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang != 'en']"/>
    <xsl:variable name="name-en"
                  select="$party/tei:orgName[@full=$full]
                          [ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang = 'en']"/>
    <xsl:choose>
      <!-- Non-English name first -->
      <xsl:when test="normalize-space($name-local)">
        <xsl:value-of select="concat($name-local, ';')"/>
      </xsl:when>
      <!-- then English name -->
      <xsl:when test="normalize-space($name-en)">
        <xsl:value-of select="concat($name-en, ';')"/>
      </xsl:when>
      <xsl:when test="normalize-space($party)">
        <xsl:message>
          <xsl:text>WARN: party without proper name </xsl:text>
          <xsl:value-of select="$party/@xml:id"/>
        </xsl:message>
        <!-- Shorten the ID if possible -->
        <xsl:value-of select="replace($party/@xml:id, '.+?\.' , '')"/>
        <xsl:text>;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text></xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
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
    <xsl:sequence select="concat($lemma, '&#9;', $ud-pos, '&#9;', $ud-feats, '&#9;', $n)"/>
  </xsl:function>

</xsl:stylesheet>
