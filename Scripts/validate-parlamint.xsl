<?xml version='1.0' encoding='UTF-8'?>
<!-- Xtra validation of ParlaMint corpus -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  exclude-result-prefixes="tei xi">

  <xsl:import href="parlamint-lib.xsl"/>
  
  <xsl:output method="text"/>

  <xsl:variable name="fileName" select="replace(base-uri(), '^.*?([^/]+\.xml)$', '$1')"/>
  <xsl:variable name="id" select="/tei:*/@xml:id"/>
  <xsl:variable name="idTemplate" select="'ParlaMint-[A-Z]{2}(-[A-Z0-9]{1,3})?(-[a-z]{2,3})?'"/>
  
  <xsl:variable name="type">
    <xsl:choose>
      <xsl:when test="matches($fileName, concat($idTemplate,'\.ana\.xml$'))">ana</xsl:when>
      <xsl:when test="matches($fileName, concat($idTemplate,'_.+\.ana\.xml$'))">ana</xsl:when>
      <xsl:when test="matches($fileName, concat($idTemplate,'\.xml$'))">txt</xsl:when>
      <xsl:when test="matches($fileName, concat($idTemplate,'_.+\.xml$'))">txt</xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="error">
          <xsl:with-param name="msg" select="concat('Bad filename ', $fileName)"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <xsl:variable name="level">
    <xsl:choose>
      <xsl:when test="matches($fileName, concat($idTemplate,'_'))">component</xsl:when>
      <xsl:when test="matches($fileName, concat($idTemplate,'(\.ana)?\.xml$'))">root</xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="error">
          <xsl:with-param name="msg" select="concat('Bad filename ', $fileName)"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <xsl:template match="tei:teiCorpus">
    <xsl:if test="not($fileName = concat($id, '.xml'))">
      <xsl:call-template name="error">
        <xsl:with-param name="msg">teiCorpus/@xml:id does not match filename</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="$level != 'root'">
      <xsl:call-template name="error">
        <xsl:with-param name="msg">Wrong ID of teiCorpus</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="$type = 'txt' and not(matches($id, $idTemplate))">
      <xsl:call-template name="error">
        <xsl:with-param name="msg">
          <xsl:text>teiCorpus ID should match ParlaMint-{ISO3166}(-{ISO639})?</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="$type = 'ana' and not(matches($id, concat($idTemplate,'\.ana')))">
      <xsl:call-template name="error">
        <xsl:with-param name="msg">
          <xsl:text>teiCorpus ID should match ParlaMint-{ISO3166}(-{ISO639})?.ana</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:variable name="rootHeader">
      <xsl:apply-templates mode="XInclude" select="//tei:teiHeader"/>
    </xsl:variable>
    <xsl:for-each select="./tei:teiHeader//xi:include">
      <xsl:variable name="incl">
        <xsl:apply-templates mode="XInclude" select="."/>
      </xsl:variable>
      <xsl:variable name="incl-id"><xsl:value-of select="$incl/tei:*/@xml:id"/></xsl:variable>
      <xsl:variable name="incl-lang"><xsl:value-of select="$incl/tei:*/@xml:lang"/></xsl:variable>
      <xsl:if test="not(@href = concat($incl-id,'.xml'))">
        <xsl:call-template name="error">
          <xsl:with-param name="msg">
            <xsl:value-of select="concat(@href,'/@xml:id=&quot;',$incl-id,'&quot; does not match filename')"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="$incl-lang=''">
        <xsl:call-template name="error">
          <xsl:with-param name="msg">
            <xsl:value-of select="concat(@href,'/@xml:lang is missing')"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>

    </xsl:for-each>
    <xsl:apply-templates select="$rootHeader"/>
  </xsl:template>
  
  <xsl:template match="tei:TEI">
    <xsl:if test="not($fileName = concat($id, '.xml'))">
      <xsl:call-template name="error">
        <xsl:with-param name="msg">TEI/@xml:id does not match filename</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="$level != 'component'">
      <xsl:call-template name="error">
        <xsl:with-param name="msg">Wrong TEI ID</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="not(matches($id, concat('^',$idTemplate,'_[0-9]{4}-[01][0-9]-[0123][0-9](-[-a-zA-Z0-9]+)?(\.ana)?$')))">
        <xsl:call-template name="error">
          <xsl:with-param name="msg">
            <xsl:text>TEI ID should match ParlaMint-{ISO3166}(-{ISO639})?_{YYYY-MM-DD}(-[-a-zA-Z0-9]+)?(\.ana)?</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="matches($id, '_.+_')">
        <xsl:call-template name="error">
          <xsl:with-param name="severity">WARN</xsl:with-param>
          <xsl:with-param name="msg">
            <xsl:text>TEI ID should have only one underscore</xsl:text>
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
    
  <xsl:template match="tei:titleStmt">
    <xsl:variable name="title" select="tei:title[@type = 'main']
                                       [ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang = 'en']"/>
    <xsl:variable name="title-prefix">[^ ]+( [^ ]+)? parliamentary corpus <xsl:value-of select="$idTemplate"/></xsl:variable>
    <xsl:variable name="title-suffix">
      <xsl:choose>
        <xsl:when test="/tei:teiCorpus and $type = 'txt'"> \[ParlaMint( SAMPLE)?\]$</xsl:when>
        <xsl:when test="/tei:teiCorpus and $type = 'ana'"> \[ParlaMint\.ana( SAMPLE)?\]$</xsl:when>
        <xsl:when test="/tei:TEI and $type = 'txt'">,? .+ \[ParlaMint( SAMPLE)?\]$</xsl:when>
        <xsl:when test="/tei:TEI and $type = 'ana'">,? .+ \[ParlaMint\.ana( SAMPLE)?\]$</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="title-pattern" select="concat($title-prefix, $title-suffix)"/>
    <xsl:if test="not(matches($title, $title-pattern))">
      <xsl:call-template name="error">
        <xsl:with-param name="msg" select="concat('Bad main title ', $title, 
                                           ' (should match ', $title-pattern, ')')"/>
      </xsl:call-template>
    </xsl:if>
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
    <xsl:if test="matches(., 'hdl.handle.net') and 
                  not(@type='handle' or @subtype='handle')">
      <xsl:call-template name="error">
        <xsl:with-param name="msg">handle URLs should be idno[@(sub)type='handle']</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="tei:date | tei:time">
    <xsl:if test="not(@when or @from or @to or @ana)">
      <xsl:call-template name="error">
        <xsl:with-param name="msg">Missing temporal or pointing attribute on date</xsl:with-param>
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
  
  <!--xsl:template match="tei:person">
    <xsl:variable name="id">
      <xsl:variable name="names">
        <xsl:variable name="persName">
          <xsl:choose>
            <xsl:when test="tei:persName[@xml:lang = 'en']">
              <xsl:copy-of select="tei:persName[@xml:lang = 'en']"/>
            </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="tei:persName[1]"/>
          </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:for-each select="$persName//tei:surname">
          <xsl:value-of select="."/>
        </xsl:for-each>
        <xsl:value-of select="$persName//tei:forename[1]"/>
      </xsl:variable>
      <xsl:value-of select="replace($names, '[\p{P}\p{S}\p{Z}]', '')"/>
    </xsl:variable>
    <xsl:variable name="id2" select="concat($id, replace(tei:birth/@when, '-.+', ''))"/>
    <xsl:if test="@xml:id != $id and @xml:id != $id2">
      <xsl:call-template name="error">
        <xsl:with-param name="severity">WARN</xsl:with-param>
        <xsl:with-param name="msg">
          <xsl:text>Person ID </xsl:text>
          <xsl:value-of select="@xml:id"/>
          <xsl:text> could be </xsl:text>
          <xsl:value-of select="$id"/>
          <xsl:if test="$id != $id2">
            <xsl:text> (or, if ambiguous, </xsl:text>
            <xsl:value-of select="$id2"/>
            <xsl:text>)</xsl:text>
          </xsl:if>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template-->
  
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
  
  <xsl:template match="tei:u">
    <xsl:choose>
      <xsl:when test="not(@who)">
        <!--xsl:call-template name="error">
          <xsl:with-param name="severity">INFO</xsl:with-param>
          <xsl:with-param name="msg">
            <xsl:text>Element u without @who </xsl:text>
            <xsl:value-of select="@xml:id"/>
          </xsl:with-param>
        </xsl:call-template-->
      </xsl:when>
      <xsl:when test="not(normalize-space(@who))">
        <xsl:call-template name="error">
          <xsl:with-param name="msg">
            <xsl:text>Element u with empty @who </xsl:text>
            <xsl:value-of select="@xml:id"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="not(starts-with(@who, '#')) or contains(@who, ' ')">
        <xsl:call-template name="error">
          <xsl:with-param name="msg">
            <xsl:text>Element u with ill-formed @who </xsl:text>
            <xsl:value-of select="@xml:id"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
    <xsl:if test="text()[normalize-space(.)]">
      <xsl:call-template name="error">
        <xsl:with-param name="msg">
          <xsl:text>Orphan text in u </xsl:text>
          <xsl:value-of select="@xml:id"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="tei:w | tei:pc">
    <xsl:if test="@msd and not(starts-with(@msd, 'UPosTag='))">
      <xsl:call-template name="error">
        <xsl:with-param name="msg" select="concat('Token @msd value should start with UPosTag= in ', 
                                           @xml:id)"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="tei:linkGrp[@type='UD-SYN']/tei:link">
    <xsl:if test="@ana = 'ud-syn:root'">
      <!-- Leave this error to be reported by CoNLL-U validation -->
      <!-- xsl:variable name="head" select="substring-after(
                                        substring-before(@target, ' '),
                                        '#')"/>
      <xsl:if test="$head != ancestor::tei:s/@xml:id">
        <xsl:variable name="token" select="substring-after(@target, ' ')"/>
        <xsl:call-template name="error">
          <xsl:with-param name="severity">WARN</xsl:with-param>
          <xsl:with-param name="msg"
                          select="concat('UD root relation should have sentence ID as its head for ', 
                                  $token, ' head = ', $head, ' sent ID = ', ancestor::tei:s/@xml:id)"/>
        </xsl:call-template>
      </xsl:if-->
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
