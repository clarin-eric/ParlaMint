<?xml version="1.0"?>
<!-- Transform one ParlaMint file to CQP vertical format.
     Note that the output is still in XML, and needs another polish. -->
<!-- Needs the file with corpus teiHeader as the value of the "meta" parameter -->
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

  <xsl:import href="parlamint-lib.xsl"/>
  
  <xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>

  <!-- Do we want the syntactic dependency and head attributes? -->
  <xsl:param name="nosyntax"/>
  
  <!-- String to put at the start and end of "incidents", i.e. transcriber notes -->
  <xsl:param name="note-open">[</xsl:param>
  <xsl:param name="note-close">]</xsl:param>

  <xsl:template match="@*"/>
  <xsl:template match="text()"/>
  <xsl:template match="tei:*">
    <xsl:message>
      <xsl:text>WARN: unexpected element </xsl:text>
      <xsl:value-of select="name()"/>
      <xsl:value-of select="concat(' in ', ancestor::tei:TEI/@xml:id, ' : ', @xml:id)"/>
    </xsl:message>
  </xsl:template>

  <xsl:template match="tei:TEI">
    <xsl:message select="concat('INFO: Converting ', @xml:id, ' to vertical')"/>
    <xsl:apply-templates  select="tei:text/tei:body/tei:div[tei:u]/tei:*"/>
  </xsl:template>
  
  <xsl:template match="tei:div/tei:u">
    <xsl:variable name="speech_id" select="replace(@xml:id, '\.ana', '')"/>
    <xsl:variable name="lang">
      <xsl:call-template name="u-langs"/>
    </xsl:variable>
    <speech id="{$speech_id}" text_id="{$text_id}"
            subcorpus="{$subcorpus}" lang="{$lang}" body="{$body}"
            term="{$term}" session="{$session}" meeting="{$meeting}" sitting="{$sitting}" agenda="{$agenda}"
            date="{$at-date}" title="{$title}">
      <xsl:attribute name="speaker_role" select="et:u-role(@ana)"/>
      <xsl:choose>
        <xsl:when test="key('idr', @who, $rootHeader)/@xml:id">
          <xsl:variable name="speaker" select="key('idr', @who, $rootHeader)"/>
          <xsl:variable name="gender">
            <xsl:choose>
              <xsl:when test="$speaker/tei:sex/@value">
                <xsl:value-of select="$speaker/tei:sex/@value"/>
              </xsl:when>
              <xsl:otherwise>-</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:variable name="birth">
            <xsl:choose>
              <xsl:when test="$speaker/tei:birth/@when">
                <xsl:value-of select="replace($speaker/tei:birth/@when, '-.+', '')"/>
              </xsl:when>
              <xsl:otherwise>-</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:attribute name="speaker_id" select="$speaker/@xml:id"/>
          <xsl:attribute name="speaker_name" select="et:format-name-chrono(
                                                     $speaker//tei:persName, 
                                                     $at-date)"/>
          <xsl:attribute name="speaker_mp" select="et:speaker-mp($speaker)"/>
          <xsl:attribute name="speaker_minister" select="et:speaker-minister($speaker)"/>
          <xsl:attribute name="speaker_party" select="et:speaker-party($speaker, 'abb')"/>
          <xsl:attribute name="speaker_party_name" select="et:speaker-party($speaker, 'yes')"/>
          <xsl:attribute name="party_status" select="et:party-status($speaker)"/>
          <xsl:attribute name="party_orientation" select="et:party-orientation($speaker)"/>
          <xsl:attribute name="speaker_gender" select="$gender"/>
          <xsl:attribute name="speaker_birth" select="$birth"/>
        </xsl:when>
        <!-- A speaker that does not have a corresponding <person> element -->
        <xsl:when test="normalize-space(@who)">
          <xsl:message select="concat('ERROR: cannot find person ', @who, ' for ', $text_id)"/>
        </xsl:when>
        <!-- No @who, legit if speaker is unknown -->
        <xsl:otherwise>
          <xsl:attribute name="speaker_id"/>
          <xsl:attribute name="speaker_name"/>
          <xsl:attribute name="speaker_party"/>
          <xsl:attribute name="speaker_party_name"/>
          <xsl:attribute name="party_status"/>
          <xsl:attribute name="speaker_gender"/>
          <xsl:attribute name="speaker_birth"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>&#10;</xsl:text>
      <xsl:apply-templates/>
    </speech>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
  
  <xsl:template match="tei:pb"/>
  
  <!-- Conflate head, note, gap and all "incidents" into <note> -->
  <xsl:template match="tei:head | tei:note | tei:gap | tei:vocal | tei:incident | tei:kinesic">
    <note>
      <xsl:attribute name="type">
        <xsl:choose>
          <xsl:when test="self::tei:head">head</xsl:when>
          <xsl:when test="self::tei:note[@type]">
            <xsl:value-of select="@type"/>
          </xsl:when>
          <xsl:when test="self::tei:note">-</xsl:when>
          <xsl:when test="@type">
            <xsl:value-of select="concat(name(), ':', @type)"/>
          </xsl:when>
          <xsl:when test="@reason">
            <xsl:value-of select="concat(name(), '::', @reason)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat(name(), ':-')"/> 
          </xsl:otherwise>        
        </xsl:choose>
      </xsl:attribute>
      <xsl:attribute name="content">
        <xsl:value-of select="normalize-space(.)"/>
      </xsl:attribute>
    </note>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
  
  <xsl:template match="tei:seg">
    <p id="{@xml:id}">
      <xsl:variable name="lang-code" select="ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang"/>
      <xsl:attribute name="lang" select="et:l10n($corpus-language, 
                                         $rootHeader//tei:langUsage/tei:language[@ident = $lang-code])"/>
      <xsl:text>&#10;</xsl:text>
      <xsl:apply-templates/>
    </p>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <!-- MWEs with semantic information -->
  <xsl:template match="tei:phr[@type = 'sem']">
    <xsl:copy>
      <xsl:attribute name="usas_tags" select="et:sem('usas', .)"/>
      <xsl:attribute name="usas_cats" select="et:sem('ids', .)"/>
      <xsl:attribute name="usas_glosses" select="et:sem('glosses', .)"/>
      <xsl:text>&#10;</xsl:text>
      <xsl:apply-templates/>
    </xsl:copy>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="tei:name">
    <xsl:choose>
      <xsl:when test="ancestor::tei:name">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:copy-of select="@type"/>
          <xsl:text>&#10;</xsl:text>
          <xsl:apply-templates/>
        </xsl:copy>
        <xsl:text>&#10;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Used by CZ, currently ignored -->
  <xsl:template match="tei:date | tei:time | 
                       tei:num | tei:unit | 
                       tei:email | tei:ref">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="tei:s">
    <xsl:copy>
      <xsl:attribute name="id" select="@xml:id"/>
      <xsl:text>&#10;</xsl:text>
      <xsl:apply-templates/>
    </xsl:copy>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="tei:linkGrp"/>
  
  <!-- We have do deal with syntactic words, e.g.:

  <w xml:id="u1.p1.s1.w18">abych
    <w xml:id="u1.p1.s1.w19" lemma="aby" msd="UPosTag=SCONJ" norm="aby"/>
    <w xml:id="u1.p1.s1.w20" lemma="být" msd="UPosTag=AUX|Mood=Cnd" norm="bych"/>
  </w>

  <link ana="ud-syn:punct" target="#u1.p1.s1.w21 #u1.p1.s1.w17"/>
  <link ana="ud-syn:mark"  target="#u1.p1.s1.w21 #u1.p1.s1.w19"/>
  <link ana="ud-syn:aux"   target="#u1.p1.s1.w21 #u1.p1.s1.w20"/>

  Solution:
  - introduce normalised column (multi valued)
  - make all attributes multivalued 

  In theory there is also:
    <w norm="najlepši" lemma="lep">
      <w>nar</w>
      <w>lepši</w>
    </w>
   We do not cover this case!
  -->

  <!-- TOKENS -->
  <xsl:template match="tei:pc | tei:w">
    <!-- Output token -->
    <xsl:value-of select="concat(normalize-space(.),'&#9;')"/>
    <xsl:choose>
      <!-- For normalized words e.g.
        <w xml:id="u1.p1.s1.w18">abych
         <w xml:id="u1.p1.s1.w19" lemma="aby" msd="UPosTag=SCONJ" norm="aby"/>
         <w xml:id="u1.p1.s1.w20" lemma="být" msd="UPosTag=AUX|Mood=Cnd" norm="bych"/>
        </w>
      -->
      <xsl:when test="normalize-space(text()[1]) and (tei:w or tei:pc)">
        <xsl:variable name="norms">
          <xsl:for-each select="tei:w | tei:pc">
            <xsl:value-of select="@norm"/>
            <xsl:text>|</xsl:text>
          </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="concat(replace($norms, '\|$', ''),'&#9;')"/>
        <xsl:variable name="toks">
          <xsl:for-each select="tei:w | tei:pc">
            <list>
              <xsl:for-each select="tokenize(et:output-annotations(.), '&#9;')">
                <item>
                  <xsl:value-of select="."/>
                </item>
              </xsl:for-each>
            </list>
          </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="et:join-annotations($toks)"/>
        <xsl:if test="not(normalize-space($nosyntax))">
          <xsl:variable name="deps">
            <xsl:for-each select="tei:w | tei:pc">
              <list>
                <xsl:variable name="annots">
                  <xsl:call-template name="deps">
                    <xsl:with-param name="id" select="@xml:id"/>
                  </xsl:call-template>
                </xsl:variable>
                <xsl:for-each select="tokenize($annots, '&#9;')">
                  <item>
                    <xsl:value-of select="."/>
                  </item>
                </xsl:for-each>
              </list>
            </xsl:for-each>
          </xsl:variable>
          <xsl:text>&#9;</xsl:text>
          <xsl:value-of select="et:join-annotations($deps)"/>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat(., '&#9;', et:output-annotations(.))"/>
        <xsl:if test="not(normalize-space($nosyntax))">
          <xsl:text>&#9;</xsl:text>
          <xsl:call-template name="deps"/>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#10;</xsl:text>
    <xsl:if test="@join = 'right' or @join='both' or
                  following::tei:*[self::tei:w or self::tei:pc][1]/@join = 'left' or
                  following::tei:*[self::tei:w or self::tei:pc][1]/@join = 'both'">
      <g/>
      <xsl:text>&#10;</xsl:text>
    </xsl:if>
  </xsl:template>

  <!-- NAMED TEMPLATES -->

  <xsl:template name="deps">
    <xsl:param name="type">UD-SYN</xsl:param>
    <xsl:param name="id" select="@xml:id"/>
    <xsl:variable name="s" select="ancestor::tei:s"/>
    <xsl:choose>
      <xsl:when test="$s/tei:linkGrp[@type=$type]">
        <!-- We need to take only the first link, in case of errros in linkGrp (two links with same token in FI) -->
        <xsl:variable name="link"
                      select="$s/tei:linkGrp[@type=$type]/tei:link
                              [ends-with(@target, concat(' #', $id))][1]"/>
        <xsl:choose>
          <xsl:when test="not(normalize-space($link/@ana))">
            <xsl:message>
              <xsl:text>ERROR: no syntactic link for token </xsl:text>
              <xsl:value-of select="concat(ancestor::tei:TEI/@xml:id, ':', @xml:id)"/>
            </xsl:message>
            <xsl:text>-&#9;-&#9;-&#9;-&#9;-</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <!-- Syntactic relation is the English term in the UD-SYN taxonomy -->
            <xsl:variable name="relation" select="substring-after($link/@ana, ':')"/>
            <xsl:value-of select="et:l10n($corpus-language, key('id', $relation, $rootHeader)/tei:catDesc)/tei:term"/>
            <xsl:variable name="target" select="key('id', replace($link/@target,'#(.+?) #.*', '$1'))"/>
            <xsl:choose>
              <xsl:when test="$target/self::tei:s">
                <xsl:text>&#9;-&#9;-&#9;-&#9;-</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="concat('&#9;', et:output-annotations($target))"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>
          <xsl:text>ERROR: no linkGroup for sentence </xsl:text>
          <xsl:value-of select="ancestor::tei:s/@xml:id"/>
        </xsl:message>
        <xsl:text>&#9;-&#9;-&#9;-&#9;-</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
