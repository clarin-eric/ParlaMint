<?xml version="1.0"?>
<!-- Output information on ParlaMint persons as TSV file -->
<!-- Expects ParlaMint.xml (for all corpora) or ParlaMint-XX.xml (for one corpus) as input -->
<!-- Note that all time-dependent information on persons (like their affiliation with parties) is ignored -->
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:tei="http://www.tei-c.org/ns/1.0" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:et="http://nl.ijs.si/et" 
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all"
  version="2.0">

  <xsl:import href="parlamint-lib.xsl"/>
  
  <xsl:output method="text"/>
  
  <xsl:template match="text()"/>
  <xsl:template match="tei:*">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="/">
    <xsl:call-template name="header-row"/>
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="tei:teiCorpus[@xml:id = 'ParlaMint' or @xml:id = 'ParlaMint.ana']">
    <xsl:for-each select="xi:include">
      <xsl:apply-templates select="document(@href)/tei:teiCorpus"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="tei:teiCorpus">
    <!-- Top level @xml:id should contain name of country or region -->
    <xsl:variable name="country"
                  select="replace(@xml:id, 
                          '.*ParlaMint-([A-Z]{2}(-[A-Z0-9]{1,3})?)', 
                          '$1')"/>
    <xsl:variable name="lang" select="@xml:lang" as="xs:string"/>
    <xsl:message select="concat('INFO: Converting ', @xml:id, 
                         ' (', $country, '/', $lang, ') to metadata TSV')"/>
    <!-- Expand the teiHeader so that it includes taxonomies and all elements have @xml:lang -->
    <xsl:variable name="document">
      <xsl:apply-templates mode="expand" select="//tei:teiHeader">
        <xsl:with-param name="lang" select="$lang"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:apply-templates select="$document//tei:listPerson">
      <xsl:with-param name="country" select="$country"/>
      <xsl:with-param name="lang" select="$lang"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="tei:listPerson">
    <xsl:param name="country"/>
    <xsl:param name="lang"/>
    <xsl:apply-templates select=".//tei:person">
      <xsl:with-param name="country" select="$country"/>
      <xsl:with-param name="lang" select="$lang"/>
    </xsl:apply-templates>
  </xsl:template>
    
  <xsl:template match="tei:person">
    <xsl:param name="country"/>
    <xsl:param name="lang"/>
    <!-- A person can have several names, either because they are witten in a different language or have different time-frames -->
    <!-- We take the last ones localised if time-frames are different, assuming they are most recent -->
    <xsl:variable name="PersName">
      <xsl:choose>
        <xsl:when test="tei:persName[@from or @to][2]">
          <xsl:copy-of select="et:l10n($lang, tei:persName[@from or @to][last()])"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="et:l10n($lang, tei:persName)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="Forename">
      <xsl:variable name="F">
        <xsl:for-each select="$PersName//tei:forename">
          <xsl:value-of select="concat(., '&#32;')"/>
        </xsl:for-each>
      </xsl:variable>
      <xsl:value-of select="replace(normalize-space($F), '&#32;', $multi-separator)"/>
    </xsl:variable>
    <xsl:variable name="Surname">
      <xsl:variable name="S">
        <xsl:for-each select="$PersName//tei:surname | $PersName//tei:nameLink">
          <xsl:value-of select="concat(., '&#32;')"/>
        </xsl:for-each>
      </xsl:variable>
      <xsl:value-of select="replace(normalize-space($S), '&#32;', $multi-separator)"/>
    </xsl:variable>
    <xsl:variable name="Minister-when">
      <xsl:variable name="M">
        <xsl:for-each select="tei:affiliation[@role='minister']">
          <xsl:sort select="@from"/>
          <xsl:value-of select="concat(et:date2interval(.), '&#32;')"/>
        </xsl:for-each>
      </xsl:variable>
      <xsl:value-of select="replace(normalize-space($M), '&#32;', $multi-separator)"/>
    </xsl:variable>    
    <xsl:variable name="MP-when">
      <xsl:variable name="M">
        <xsl:for-each select="tei:affiliation[@role='member']">
          <xsl:sort select="@from"/>
          <xsl:if test="key('idr', @ref)/@role='parliament'">
          <xsl:value-of select="concat(et:date2interval(.), '&#32;')"/>
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>
      <xsl:value-of select="replace(normalize-space($M), '&#32;', $multi-separator)"/>
    </xsl:variable>
    <!-- Affiliations that are valid for insertion into the parliamentaryGroup and politicalParty columns -->
    <xsl:variable name="affiliations" select="tei:affiliation[@role='member' or @role='representative']"/>
    <xsl:variable name="ParGroups">
      <xsl:call-template name="affiliation-orgs">
        <xsl:with-param name="affiliations" select="$affiliations"/>
        <xsl:with-param name="orgRole">parliamentaryGroup</xsl:with-param>
        <xsl:with-param name="lang" select="$lang"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="PolParties">
      <xsl:call-template name="affiliation-orgs">
        <xsl:with-param name="affiliations" select="$affiliations"/>
        <xsl:with-param name="orgRole">politicalParty</xsl:with-param>
        <xsl:with-param name="lang" select="$lang"/>
      </xsl:call-template>
    </xsl:variable>    
    <xsl:variable name="Sex" select="tei:sex/@value"/>
    <xsl:variable name="BirthDate" select="et:norm-date(tei:birth/@when)"/>
    <xsl:variable name="BirthPlace" select="et:l10n($lang, tei:birth/tei:placeName)"/>
    <xsl:variable name="DeathDate" select="et:norm-date(tei:death/@when)"/>
    <xsl:variable name="DeathPlace" select="et:l10n($lang, tei:death/tei:placeName)"/>
    <xsl:variable name="Education">
      <xsl:variable name="E">
        <xsl:for-each select="et:l10n($lang, tei:education)">
          <xsl:value-of select="concat(., '@@@')"/>
        </xsl:for-each>
      </xsl:variable>
      <xsl:value-of select="replace(replace($E, '@@@$', ''), '@@@', $multi-separator)"/>
    </xsl:variable>
    <xsl:variable name="Occupation">
      <xsl:variable name="O">
        <xsl:for-each select="et:l10n($lang, tei:occupation)">
          <xsl:value-of select="concat(., '@@@')"/>
        </xsl:for-each>
      </xsl:variable>
      <xsl:value-of select="replace(replace($O, '@@@$', ''), '@@@', $multi-separator)"/>
    </xsl:variable>
    <!-- Get Wikipedia URL from <idno> or <state> as fall-back; do not depend on @xml:lang but URL! -->
    <xsl:variable name="Wikipedia">
      <xsl:variable name="idnos" select="tei:idno[@type = 'URI' and @subtype = 'wikimedia']
                                         [contains(., 'wikipedia')]"/>
      <xsl:variable name="idno-en" select="$idnos[contains(., '/en.')]"/>
      <xsl:variable name="idno-xx" select="$idnos[contains(., concat('/', $lang, '.'))]"/>
      <xsl:choose>
        <xsl:when test="$out-lang = 'en' and $idno-en">
          <xsl:value-of select="$idno-en"/>
        </xsl:when>
        <xsl:when test="$out-lang = 'xx' and $idno-xx">
          <xsl:value-of select="$idno-xx"/>
        </xsl:when>
        <xsl:when test=".//tei:state[@type = 'Wikipedia'][@source]">
          <xsl:value-of select=".//tei:state[@type = 'Wikipedia']/@source"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="Official">
      <xsl:variable name="O">
        <xsl:for-each select="tei:idno[@type='URI' and (@subtype='government' or @subtype='parliament')]">
          <xsl:value-of select="concat(., '&#32;')"/>
        </xsl:for-each>
      </xsl:variable>
      <xsl:value-of select="replace(normalize-space($O), '&#32;', $multi-separator)"/>
    </xsl:variable>
    
    <xsl:value-of select="concat($country, '&#9;')"/>
    <xsl:value-of select="concat(@xml:id, '&#9;')"/>
    <xsl:value-of select="concat(et:tsv-value(et:format-name($PersName)), '&#9;')"/>
    <xsl:value-of select="concat(et:tsv-value($Forename), '&#9;')"/>
    <xsl:value-of select="concat(et:tsv-value($Surname), '&#9;')"/>
    <xsl:value-of select="concat(et:tsv-value($PersName//tei:roleName), '&#9;')"/>
    <xsl:value-of select="concat(et:tsv-value($Minister-when), '&#9;')"/>
    <xsl:value-of select="concat(et:tsv-value($MP-when), '&#9;')"/>
    <xsl:value-of select="concat(et:tsv-value($ParGroups), '&#9;')"/>
    <xsl:value-of select="concat(et:tsv-value($PolParties), '&#9;')"/>
    <xsl:value-of select="concat(et:tsv-value($Sex), '&#9;')"/>
    <xsl:value-of select="concat(et:tsv-value($BirthDate), '&#9;')"/>
    <xsl:value-of select="concat(et:tsv-value($BirthPlace), '&#9;')"/>
    <xsl:value-of select="concat(et:tsv-value($DeathDate), '&#9;')"/>
    <xsl:value-of select="concat(et:tsv-value($DeathPlace), '&#9;')"/>
    <xsl:value-of select="concat(et:tsv-value($Education), '&#9;')"/>
    <xsl:value-of select="concat(et:tsv-value($Occupation), '&#9;')"/>
    <xsl:value-of select="concat(et:tsv-value($Wikipedia), '&#9;')"/>
    <xsl:value-of select="concat(et:tsv-value($Official), '')"/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template name="header-row">
    <xsl:text>Country&#9;</xsl:text>
    <xsl:text>SpeakerID&#9;</xsl:text>
    <xsl:text>Name&#9;</xsl:text>
    <xsl:text>Forename&#9;</xsl:text>
    <xsl:text>Surname&#9;</xsl:text>
    <xsl:text>RoleName&#9;</xsl:text>
    <xsl:text>Minister&#9;</xsl:text>
    <xsl:text>MP&#9;</xsl:text>
    <xsl:text>Par. groups&#9;</xsl:text>
    <xsl:text>Pol. parties&#9;</xsl:text>
    <xsl:text>Sex&#9;</xsl:text>
    <xsl:text>Birth date&#9;</xsl:text>
    <xsl:text>Birth place&#9;</xsl:text>
    <xsl:text>Death date&#9;</xsl:text>
    <xsl:text>Death place&#9;</xsl:text>
    <xsl:text>Education&#9;</xsl:text>
    <xsl:text>Occupation&#9;</xsl:text>
    <xsl:text>Wikipedia URL&#9;</xsl:text>
    <xsl:text>Official URLs&#9;</xsl:text>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
  
  <xsl:template name="affiliation-orgs">
    <xsl:param name="affiliations"/>
    <xsl:param name="orgRole"/>
    <xsl:param name="lang"/>
    <xsl:variable name="orgNames">
      <xsl:for-each select="$affiliations/self::tei:affiliation">
        <xsl:variable name="org" select="key('idr', @ref)[@role=$orgRole]"/>
        <xsl:if test="$org[self::tei:org]">
          <xsl:variable name="name-abb">
            <xsl:call-template name="orgName">
              <xsl:with-param name="org" select="$org"/>
              <xsl:with-param name="full">abb</xsl:with-param>
              <xsl:with-param name="lang" select="$lang"/>
            </xsl:call-template>
          </xsl:variable>
          <xsl:value-of select="concat(et:tsv-value($name-abb), '#', $org/@xml:id, 
                                '[', et:date2interval(.), ']')"/>
          <xsl:text>@@@</xsl:text>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="replace(
                          string-join(
                          distinct-values(tokenize(replace($orgNames, '@@@$', ''), '@@@')), '@@@'),
                          '@@@', $multi-separator)"/>
  </xsl:template>
  
</xsl:stylesheet>
