<?xml version="1.0"?>
<!-- Library of templates for import into other ParlaMint scripts -->
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

  <!-- In which language the metadata should be output (where there is a choice)
       Legal values are:
       - xx (language of the corpus or fall-back option)
       - en (English or fall-back option)
  -->
  <xsl:param name="out-lang">xx</xsl:param>
  
  <!-- Filename of corpus root containing the corpus-wide metadata -->
  <xsl:param name="meta"/>

  <!-- Separator for multi-valued attributes in vertical and TSV files; must have only one char! --> 
  <xsl:param name="multi-separator">|</xsl:param>

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
  
  <!-- Label for multilingual utterances -->
  <!-- Note that this label should be ideally translated into all (or at least those that have multilingual utterances, e.g. BE, UA) 
       the ParlaMint languages as well, i.e. "mul" should be in their langUsage -->
  <xsl:param name="multilingual-label">Multilingual</xsl:param>
  
  <!-- Key in value of element ID -->
  <xsl:key name="id" match="tei:*" use="@xml:id"/>
  <!-- Key which directly finds local references -->
  <xsl:key name="idr" match="tei:*" use="concat('#', @xml:id)"/>

  <xsl:variable name="text_id" select="replace(/tei:*/@xml:id, '\.ana', '')"/>
  
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
  
  <!-- Localised title of a corpus component: subtitle, if exists, otherwise main title -->
  <xsl:variable name="title">
    <xsl:variable name="titles">
      <xsl:apply-templates mode="expand" select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"/>
    </xsl:variable>
    <xsl:variable name="subtitles" select="et:l10n($corpus-language, $titles/tei:title[@type='sub'])"/>
    <xsl:variable name="main-title" select="et:l10n($corpus-language, $titles/tei:title[@type='main'])"/>
    <xsl:choose>
      <!-- Several subtitles in same language -->
      <xsl:when test="normalize-space($subtitles[2])">
        <xsl:variable name="joined-subtitles">
          <xsl:variable name="j-s">
            <xsl:for-each select="$subtitles/self::tei:*">
              <xsl:value-of select="concat(., $multi-separator)"/>
            </xsl:for-each>
          </xsl:variable>
          <xsl:value-of select="replace($j-s, '.$', '')"/>
        </xsl:variable>
        <xsl:message select="concat('INFO: Joining subtitles: ', $joined-subtitles, ' in ', /tei:*/@xml:id)"/>
        <xsl:value-of select="$joined-subtitles"/>
      </xsl:when>
      <xsl:when test="normalize-space($subtitles)">
        <xsl:value-of select="normalize-space($subtitles)"/>
      </xsl:when>
      <xsl:when test="normalize-space($main-title)">
        <!-- Remove [ParlaMint] stamp -->
        <xsl:value-of select="replace(normalize-space($main-title), '\s*\[.+\]$', '')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message select="concat('ERROR: cant find title for ', $text_id)"/>
        <xsl:text>-</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
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
          <xsl:text>,</xsl:text>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="replace($subcorpora, ',$', '')"/>
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
        <xsl:apply-templates mode="expand" select="document($meta)//tei:teiHeader">
          <xsl:with-param name="lang" select="document($meta)/tei:*/@xml:lang"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="/tei:teiCorpus/tei:teiHeader">
        <xsl:apply-templates mode="expand" select="/tei:teiCorpus/tei:teiHeader"/>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>
  
  <!-- TEMPLATES WITH SPECIAL MODES -->

  <!-- Copy input element to output but XInclude files and 
       put @xml:lang on all elements; the value is taken from the closest ancestor 
       or given as a parameter if the input does not have ancestor with @xml:lang -->
  <xsl:template mode="expand" match="tei:*">
    <xsl:param name="lang" select="ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang"/>
    <xsl:variable name="thisLang" select="ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang"/>
    <xsl:copy>
      <xsl:apply-templates mode="expand" select="@*"/>
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
      <xsl:apply-templates mode="expand">
        <xsl:with-param name="lang" select="$lang"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  <xsl:template mode="expand" match="xi:include">
    <xsl:param name="lang" select="ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang"/>
    <xsl:apply-templates mode="expand" select="document(@href)">
      <xsl:with-param name="lang" select="$lang"/>
    </xsl:apply-templates>
  </xsl:template>
  <xsl:template mode="expand" match="@*">
    <xsl:copy/>
  </xsl:template>
  <xsl:template mode="expand" match="text()">
    <xsl:value-of select="."/>
  </xsl:template>

  <!-- NAMED TEMPLATES -->

  <!-- Return the name of the langauge that the segments of the utterance are in -->
  <!-- In case the segments are in serveral langauges, the multilingual-label is output -->
  <!-- The assumption is that this template is called with tei:u as the context node -->
  <xsl:template name="u-langs">
    <xsl:variable name="defaultLang" select="ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang"/>
    <!-- Collect all the languages of utterance segments -->
    <xsl:variable name="langs">
      <xsl:variable name="lgs">
        <xsl:for-each select="tei:seg">
          <xsl:value-of select="@xml:lang"/>
          <xsl:text>&#32;</xsl:text>
        </xsl:for-each>
      </xsl:variable>
      <xsl:value-of select="distinct-values(tokenize(normalize-space($lgs)))"/>
    </xsl:variable>
    <xsl:choose>
      <!-- Segments not marked for language, so name of language of utterance -->
      <xsl:when test="not(normalize-space($langs))">
        <xsl:value-of select="et:l10n($corpus-language, 
                              $rootHeader//tei:langUsage/tei:language[@ident = $defaultLang])"/>
      </xsl:when>
      <!-- Multilingual content -->
      <xsl:when test="tokenize($langs)[2]">
        <xsl:value-of select="$multilingual-label"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="et:l10n($corpus-language, 
                              $rootHeader//tei:langUsage/tei:language[@ident = $langs])"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
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
              <xsl:if test="contains($body, $multi-separator)">
                <xsl:message select="concat('ERROR: ', $body, ' should not contain ', $multi-separator)"/>
              </xsl:if>
              <xsl:value-of select="$body"/>
              <xsl:value-of select="$multi-separator"/>
            </xsl:if>
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>
      <xsl:value-of select="replace($bods, '.$', '')"/>
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
  
  <!-- Output name of meeting with the given $ref in @ana, inputs are e.g.
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
    <xsl:variable name="component-id" select="/tei:TEI/@xml:id"/>
    <xsl:variable name="idref" select="concat('#', $ref)"/>
    <xsl:variable name="meetings">
      <xsl:apply-templates mode="expand" select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/
                                                 tei:meeting[contains(@ana, $idref)]"/>
    </xsl:variable>
    <!--xsl:message select="concat('DEBUG: 1 = ', $meetings/tei:meeting[1], ' 2 = ', $meetings/tei:meeting[2] )"/-->
    <xsl:choose>
      <!-- This type of meeting is undefined -->
      <xsl:when test="not($meetings/tei:meeting)">
        <xsl:text>-</xsl:text>
      </xsl:when>
      <xsl:when test="normalize-space($meetings/tei:meeting[1])">
        <xsl:value-of select="et:l10n($corpus-language, $meetings/tei:meeting)"/>
      </xsl:when>
      <xsl:when test="$meetings/tei:meeting[1]/@n">
        <xsl:value-of select="$meetings/tei:meeting[1]/@n"/>
      </xsl:when>
      <!-- Defined, but has neither text nor @n -->
      <xsl:otherwise>
        <xsl:message select="concat('ERROR: no meeting/text() or meeting/@n for ', $ref, ' in ', $component-id)"/>
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
                              string-join(
                                (
                                  $persName/tei:surname[not(@type='patronym')]
                                  |
                                  $persName/tei:nameLink[following-sibling::tei:*[1][local-name()='surname' or local-name()='nameLink']]
                                )/normalize-space(.),
                                ' '),
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
    <xsl:value-of select="et:speaker-mp($speaker,$at-date)"/>
  </xsl:function>
  <xsl:function name="et:speaker-mp" as="xs:string">
    <xsl:param name="speaker" as="element(tei:person)"/>
    <xsl:param name="when" as="xs:string"/>
    <xsl:variable name="mp">
      <xsl:variable name="refs" select="et:speaker-affiliations-refs($speaker,$when)"/>
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
    <xsl:value-of select="et:speaker-minister($speaker,$at-date)"/>
  </xsl:function>
  <xsl:function name="et:speaker-minister" as="xs:string">
    <xsl:param name="speaker" as="element(tei:person)"/>
    <xsl:param name="when" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="$speaker/tei:affiliation[@role = 'minister']
                      [et:between-dates($when, @from, @to)]">
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
    <xsl:value-of select="et:party-status($speaker,$at-date)"/>
  </xsl:function>
  <xsl:function name="et:party-status" as="xs:string">
    <xsl:param name="speaker" as="element(tei:person)"/>
    <xsl:param name="when" as="xs:string"/>
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
            <xsl:if test="et:between-dates($when, @from, @to)">
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
          <xsl:variable name="org-refs" select="et:speaker-affiliations-refs($speaker,$when)"/>
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
              <xsl:value-of select="concat($when, ': ',
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
    <xsl:value-of select="et:party-orientation($speaker,$at-date)"/>
  </xsl:function>
  <xsl:function name="et:party-orientation" as="xs:string">
    <xsl:param name="speaker" as="element(tei:person)"/>
    <xsl:param name="when" as="xs:string"/>
    <!-- Collect all affiliation references where the speaker is a member and are in 
         the correct time-frame for the speech -->
    <xsl:variable name="refs" select="et:speaker-affiliations-refs($speaker,$when)"/>
    <!-- Orientations of all gathered parliamentary groups -->
    <!-- The speaker should be a member of only one, but in practice sometimes isn't -->
    <xsl:variable name="parliamentaryGroupOrientations">
      <xsl:variable name="orientations">
        <xsl:for-each select="distinct-values(tokenize($refs, ' '))">
          <xsl:variable name="party" select="key('idr', ., $rootHeader)[@role='parliamentaryGroup']"/>
          <xsl:if test="normalize-space($party)">
            <xsl:call-template name="party-orientation">
              <xsl:with-param name="party" select="$party"/>
            </xsl:call-template>
            <xsl:text>;</xsl:text>
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>
      <xsl:variable name="uniqOrientations">
        <xsl:for-each select="distinct-values(tokenize($orientations, ';'))">
          <xsl:value-of select="."/>
          <xsl:text>;</xsl:text>
        </xsl:for-each>
      </xsl:variable>
      <xsl:value-of select="replace(
                            replace($uniqOrientations, ';+$', ''),
                            '^;+', '')"/>
    </xsl:variable>
    <xsl:variable name="politicalPartyOrientation">
      <xsl:variable name="orientations">
        <xsl:for-each select="distinct-values(tokenize($refs, ' '))">
          <xsl:variable name="party" select="key('idr', ., $rootHeader)[@role='politicalParty']"/>
          <xsl:if test="normalize-space($party)">
            <xsl:call-template name="party-orientation">
              <xsl:with-param name="party" select="$party"/>
            </xsl:call-template>
            <xsl:text>;</xsl:text>
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>
      <xsl:variable name="uniqOrientations">
        <xsl:for-each select="distinct-values(tokenize($orientations, ';'))">
          <xsl:value-of select="."/>
          <xsl:text>;</xsl:text>
        </xsl:for-each>
      </xsl:variable>
      <xsl:value-of select="replace(
                            replace($uniqOrientations, ';+$', ''),
                            '^;+', '')"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="normalize-space($parliamentaryGroupOrientations)">
        <xsl:value-of select="$parliamentaryGroupOrientations"/>
        <!--xsl:message select="concat('INFO PG: ', $refs, ' // ', $parliamentaryGroupOrientations)"/-->
      </xsl:when>
      <xsl:when test="normalize-space($politicalPartyOrientation)">
        <xsl:value-of select="$politicalPartyOrientation"/>
        <!--xsl:message select="concat('INFO PP: ', $refs, ' // ', $parliamentaryGroupOrientations)"/-->
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>-</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- Output the name of the party (or parties!) the speaker belongs to when speaking -->
  <xsl:function name="et:speaker-party" as="xs:string">
    <xsl:param name="speaker" as="element(tei:person)"/>
    <xsl:param name="full" as="xs:string"/>
    <xsl:value-of select="et:speaker-party($speaker,$full,$at-date)"/>
  </xsl:function>
  <xsl:function name="et:speaker-party" as="xs:string">
    <xsl:param name="speaker" as="element(tei:person)"/>
    <!-- Output full ('yes') or abbreviated ('abb') name of the party -->
    <xsl:param name="full" as="xs:string"/>
    <xsl:param name="when" as="xs:string"/>
    <!-- Collect all affiliation references where the speaker is a member and are in 
         the correct time-frame for the speech -->
    <xsl:variable name="refs" select="et:speaker-affiliations-refs($speaker,$when)"/>
    <xsl:variable name="parliamentaryGroups">
      <xsl:for-each select="distinct-values(tokenize($refs, ' '))">
        <xsl:variable name="party" select="key('idr', ., $rootHeader)[@role='parliamentaryGroup']"/>
        <xsl:if test="$party/self::tei:org">
          <xsl:call-template name="orgName">
            <xsl:with-param name="org" select="$party"/>
            <xsl:with-param name="full" select="$full"/>
          </xsl:call-template>
          <xsl:text>;</xsl:text>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="politicalParties">
      <xsl:for-each select="distinct-values(tokenize($refs, ' '))">
        <xsl:variable name="party" select="key('idr', ., $rootHeader)[@role='politicalParty']"/>
        <xsl:if test="$party/self::tei:org">
          <xsl:call-template name="orgName">
            <xsl:with-param name="org" select="$party"/>
            <xsl:with-param name="full" select="$full"/>
          </xsl:call-template>
          <xsl:text>;</xsl:text>
        </xsl:if>
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
    <xsl:value-of select="et:speaker-affiliations-refs($speaker,$at-date)"/>
  </xsl:function>
  <xsl:function name="et:speaker-affiliations-refs" as="xs:string">
    <xsl:param name="speaker" as="element(tei:person)"/>
    <xsl:param name="when" as="xs:string"/>
    <xsl:variable name="refs">
      <xsl:for-each select="$speaker/tei:affiliation
                            [@role='member' or @role='candidateMP' or
                            @role='president' or @role='vicePresident' or
                            @role='secretary' or @role='representative']">
        <xsl:if test="et:between-dates($when, @from, @to)">
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
  
  <!-- Return the name(s) of an organisation in $out-lang -->
  <!-- if $party is empty, so it the result (it is not an error if this happens!) -->
  <xsl:template name="orgName">
    <xsl:param name="org"/>
    <xsl:param name="full"/>
    <xsl:param name="lang" select="$corpus-language"/>
    <xsl:variable name="orgName" select="et:l10n($lang, $org/tei:orgName[@full=$full])"/>
    <xsl:choose>
      <xsl:when test="$orgName[2]">
        <xsl:message select="concat('WARN: organisation ', $org/@xml:id, ' with two orgName/@full = ', $full, 
                             ': outputting only the last one!')"/>
        <xsl:value-of select="$orgName[last()]"/>
      </xsl:when>
      <xsl:when test="normalize-space($orgName)">
        <xsl:value-of select="$orgName"/>
      </xsl:when>
      <xsl:when test="normalize-space($org)">
        <xsl:message select="concat('WARN: organisation ', $org/@xml:id, ' without orgName/@full = ', $full)"/>
        <!-- As a fall-back, return ID (i.e. the part of the ID after period for e.g. 'politicalParty.VCA') -->
        <xsl:value-of select="replace($org/@xml:id, '.+?\.' , '')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text></xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Return the political orientation of the party, either from Wikipedia, or, if missing, encoder -->
  <xsl:template name="party-orientation">
    <xsl:param name="party"/>
    <xsl:param name="lang" select="$corpus-language"/>
    <xsl:variable name="orientation" select="$party/tei:state[@type = 'politicalOrientation']"/>
    <xsl:choose>
      <xsl:when test="$orientation/tei:state[@type = 'Wikipedia']">
        <xsl:value-of select="et:l10n($lang, 
                              key('idr', $orientation/tei:state[@type = 'Wikipedia']/@ana, $rootHeader)
                              /tei:catDesc)/tei:term"/>
      </xsl:when>
      <xsl:when test="$orientation/tei:state[@type = 'encoder']">
        <xsl:value-of select="et:l10n($lang, 
                              key('idr', $orientation/tei:state[@type = 'encoder']/@ana, $rootHeader)
                              /tei:catDesc)/tei:term"/>
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

  <!-- test if two affiliations are comparable - same ref + role + roleName + ana -->
  <xsl:function name="mk:is-comparable">
    <xsl:param name="aff1"/>
    <xsl:param name="aff2"/>
    <xsl:choose>
      <xsl:when test="$aff1[@to][@from][@to &lt; @from]"><xsl:sequence select="false()"/></xsl:when> <!-- invalid date range -->
      <xsl:when test="$aff2[@to][@from][@to &lt; @from]"><xsl:sequence select="false()"/></xsl:when> <!-- invalid date range -->
      <xsl:when test="not($aff1/@ref = $aff2/@ref)"><xsl:sequence select="false()"/></xsl:when>
      <xsl:when test="not($aff1/@role = $aff2/@role)"><xsl:sequence select="false()"/></xsl:when>
      <!-- IMPROVE: sort content -->
      <xsl:when test="not($aff1/@ana) and $aff2/@ana"><xsl:sequence select="false()"/></xsl:when>
      <xsl:when test="$aff1/@ana and not($aff2/@ana)"><xsl:sequence select="false()"/></xsl:when>

      <xsl:when test="$aff1/@ana and $aff2/@ana and not($aff1/@ana = $aff2/@ana)"><xsl:sequence select="false()"/></xsl:when>

      <xsl:when test="$aff1/@role = 'member' and $aff2/@role = 'member'"><xsl:sequence select="true()"/></xsl:when> <!-- skipping the rest of validations if member -->

      <xsl:when test="$aff1/tei:roleName and not($aff2/tei:roleName)"><xsl:sequence select="false()"/></xsl:when>
      <xsl:when test="not($aff1/tei:roleName) and $aff2/tei:roleName"><xsl:sequence select="false()"/></xsl:when>
      <xsl:when test="$aff1/tei:roleName and $aff2/tei:roleName and not($aff1/tei:roleName/text() = $aff2/tei:roleName/text())"><xsl:sequence select="false()"/></xsl:when>
      <xsl:otherwise><xsl:sequence select="true()"/></xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- test if two elements has overlapping from-to ranges -->
  <xsl:function name="mk:is-overlapping">
    <xsl:param name="aff1"/>
    <xsl:param name="aff2"/>
    <xsl:choose>
      <xsl:when test="$aff1/@from and et:between-dates($aff1/@from,$aff2/@from,$aff2/@to)"><xsl:sequence select="true()"/></xsl:when>
      <xsl:when test="$aff1/@to and et:between-dates($aff1/@to,$aff2/@from,$aff2/@to)"><xsl:sequence select="true()"/></xsl:when>
      <xsl:when test="$aff2/@from and et:between-dates($aff2/@from,$aff1/@from,$aff1/@to)"><xsl:sequence select="true()"/></xsl:when>
      <xsl:when test="$aff2/@to and et:between-dates($aff2/@to,$aff1/@from,$aff1/@to)"><xsl:sequence select="true()"/></xsl:when>
      <xsl:when test="not($aff1/@from or $aff1/@to or $aff2/@from or $aff2/@to)"><xsl:sequence select="true()"/></xsl:when>
      <xsl:otherwise><xsl:sequence select="false()"/></xsl:otherwise>
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
                      xs:date(et:norm-date($date)) &gt;= xs:date(et:norm-date($from)) and
                      xs:date(et:norm-date($date)) &lt;= xs:date(et:norm-date($to))">
        <xsl:value-of select="true()"/>
      </xsl:when>
      <xsl:when test="not(normalize-space($from)) and normalize-space($to) and
                      xs:date(et:norm-date($date)) &lt;= xs:date(et:norm-date($to))" >
        <xsl:value-of select="true()"/>
      </xsl:when>
      <xsl:when test="normalize-space($from) and not(normalize-space($to)) and 
                      xs:date(et:norm-date($date)) &gt;= xs:date(et:norm-date($from))" >
        <xsl:value-of select="true()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="false()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- Normalize too long or too short dates 
       a la "2013-10-26T14:00:00" or "2018" to xs:date e.g. 2018-01-01 -->
  <xsl:function name="et:norm-date">
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
    <xsl:variable name="ud-pos">
      <xsl:choose>
        <xsl:when test="$token/@msd">
          <xsl:value-of select="replace(replace($token/@msd, 'UPosTag=', ''), '\|.+', '')"/>
        </xsl:when>
        <xsl:otherwise>-</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="ud-feats">
      <xsl:variable name="fs" select="replace($token/@msd, 'UPosTag=[^|]+\|?', '')"/>
      <xsl:choose>
        <xsl:when test="normalize-space($fs)">
          <!-- Change source pipe to whatever we have for multivalued attributes -->
          <xsl:value-of select="replace($fs, '\|', ' ')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>-</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- Part 1 are standard attributes of word -->
    <xsl:variable name="part1" select="concat($lemma, '&#9;', $ud-pos, '&#9;', $ud-feats, '&#9;')"/>
    <!-- Part 2 are semantic attributes, only relevant for MTed USAS-tagged corpora -->
    <xsl:variable name="part2">
      <xsl:if test="$token/@function and $token/@ana">
        <xsl:value-of select="concat(
                              et:sem('usas', $token), '&#9;', 
                              et:sem('ids', $token), '&#9;', 
                              et:sem('glosses', $token), '&#9;')"/>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="part3">
      <xsl:choose>
        <xsl:when test="normalize-space($n)">
          <xsl:value-of select="$n"/>
        </xsl:when>
        <xsl:otherwise>-</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="concat($part1, $part2, $part3)"/>
  </xsl:function>

  <!-- Returns the USAS semantic information form @function or @ana about an element -->
  <!-- What is returned dependes of the value of $type -->
  <xsl:function name="et:sem">
    <xsl:param name="type"/>
    <xsl:param name="element"/>
    <xsl:choose>
      <!-- Return @function -->
      <xsl:when test="$type = 'usas'">
        <xsl:value-of select="$element/@function"/>
      </xsl:when>
      <!-- Return the IDs that @ana refer, remove extended pounter prefix -->
      <xsl:when test="$type = 'ids'">
        <xsl:value-of select="replace($element/@ana, '\p{L}+:', '')"/>
      </xsl:when>
      <!-- Return the term form the taxonomy -->
      <xsl:when test="$type = 'terms'">
        <xsl:variable name="terms">
          <xsl:for-each select="tokenize($element/@ana, ' ')">
            <!-- Here we a) assume that the catDesc is only in English and b) that the extended pointer resolves to a local reference -->
            <xsl:value-of select="key('id', substring-after(., ':'), $rootHeader)/tei:catDesc/tei:term"/>
            <xsl:value-of select="$multi-separator"/>
          </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="replace($terms, '.$', '')"/>
      </xsl:when>
      <!-- Return the term form the taxonomy -->
      <xsl:when test="$type = 'glosses'">
        <xsl:variable name="glosses">
          <xsl:for-each select="tokenize($element/@ana, ' ')">
            <!-- Here we a) assume that the catDesc is only in English and b) that the extended pointer resolves to a local reference -->
            <xsl:value-of select="key('id', substring-after(., ':'), $rootHeader)/normalize-space(tei:catDesc)"/>
            <xsl:value-of select="$multi-separator"/>
          </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="replace($glosses, '.$', '')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message select="concat('ERROR: wrong type ', $type, ' for function et:sem')"/>
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
    <xsl:param name="lang"/>
    <xsl:param name="elements"/>
    <!-- Should never happen, as all meta elements should be marked for @xml:lang -->
    <xsl:if test="$elements[not(@xml:lang)]">
      <xsl:message terminate="yes" select="concat('FATAL ERROR: no @xml:lang at least in ', 
                                           $elements[not(@xml:lang)][1])"/>
    </xsl:if>
    <!--xsl:message select="concat('DEBUG: out-lang = ', $out-lang, ', corpus language = ', $lang)"/-->
    <!-- Original language -->
    <xsl:variable name="element-xx" select="$elements[@xml:lang = $lang]"/>
    <!-- Latin spelling -->
    <xsl:variable name="element-lt" select="$elements[ends-with(@xml:lang, '-Latn')]"/>
    <!-- English -->
    <xsl:variable name="element-en" select="$elements[@xml:lang = 'en']"/>
    <!-- For (the only example in ParlaMint) the French spelling of a name in GR. -->
    <!-- Note that corpus-langauge can be "en" for MTed corpora, so we need to choose only one result -->
    <xsl:variable name="element-yy" select="$elements[not(@xml:lang = 'en' or
                                            @xml:lang = $lang or ends-with(@xml:lang, '-Latn'))][1]"/>
    <!-- If nothing else serves we take first element as fall-back -->
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
  
  <!-- Return value of $input, if it exists, otherwise '-' -->
  <xsl:function name="et:tsv-value">
    <xsl:param name="input"/>
    <xsl:choose>
      <xsl:when test="normalize-space($input)">
        <xsl:value-of select="normalize-space($input)"/>
      </xsl:when>
      <xsl:otherwise>-</xsl:otherwise>
    </xsl:choose>
  </xsl:function>

</xsl:stylesheet>
