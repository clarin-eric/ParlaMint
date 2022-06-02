<?xml version='1.0' encoding='UTF-8'?>
<!-- Fix duplicated and overlapping affiliations -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:et="http://nl.ijs.si/et"
  xmlns:mk="http://ufal.mff.cuni.cz/matyas-kopp"
  xmlns:saxon="http://saxon.sf.net/"
  exclude-result-prefixes="et mk fn xs tei saxon">
  <xsl:output indent="yes"/>
  <xsl:strip-space elements="*"/>
  <xsl:preserve-space elements="tei:change tei:seg"/>



  <xsl:template match="tei:person">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="*|comment()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:affiliation[preceding-sibling::tei:affiliation]"/>
  <xsl:template match="tei:affiliation[not(preceding-sibling::tei:affiliation)]"> <!-- first affiliation node -->
<xsl:message>AFFILIATION CNT <xsl:value-of select="count(../tei:affiliation)"/></xsl:message>

    <xsl:for-each select="../tei:affiliation">
        <xsl:variable name="ref" select="@ref"/>
        <xsl:variable name="role" select="@role"/>
        <xsl:variable name="from" select="mk:get_from(.)"/>
        <xsl:variable name="to" select="mk:get_to(.)"/>
        <xsl:variable name="ana" select="@ana"/>
        <xsl:variable name="text" select="normalize-space(./tei:roleName/text())"/>

        <xsl:variable name="aff-duplicit-diff-ana" select="following-sibling::tei:affiliation
                                                  [@role='member'][@role=$role]
                                                  [@ref = $ref]
                                                  [@ana != $ana]
                                                  [not(./tei:roleName/text()) or normalize-space(./tei:roleName/text()) = $text]
                                                  [$from=mk:get_from(.) and $to = mk:get_to(.)]"/>
        <xsl:choose>
          <!-- ========= remove: ========= -->
          <!-- duplicity is before - remove -->
          <xsl:when test="preceding-sibling::tei:affiliation
                                                  [@role='member'][@role=$role]
                                                  [@ref = $ref]
                                                  [not(./tei:roleName/text()) or normalize-space(./tei:roleName/text()) = $text]
                                                  [$from=mk:get_from(.) and $to = mk:get_to(.)]">
            <xsl:message>removing: <xsl:copy-of select="."/> - affiliation is duplicit</xsl:message>
          </xsl:when>
          <!-- affiliation period is inside other affiliation period - remove -->
          <xsl:when test="(preceding-sibling::tei:affiliation,following-sibling::tei:affiliation)
                                                  [@role=$role]
                                                  [@ref = $ref]
                                                  [not(@ana) or @ana = $ana]
                                                  [not(./tei:roleName/text()) or normalize-space(./tei:roleName/text()) = $text]
                                                  [$from >= mk:get_from(.) and  mk:get_to(.) >= $to and not($from = mk:get_from(.) and $to = mk:get_to(.))]">
            <xsl:message>removing: <xsl:copy-of select="."/> - affiliation is covered with other affiliation</xsl:message>
          </xsl:when>
          <!-- overlaping is before - remove -->
          <xsl:when test="preceding-sibling::tei:affiliation
                                                  [@role='member'][@role=$role]
                                                  [@ref = $ref]
                                                  [not(@ana) or @ana = $ana]
                                                  [not(./tei:roleName/text()) or normalize-space(./tei:roleName/text()) = $text]
                                                  [($from > mk:get_from(.) and  mk:get_to(.) > $from) or ($to > mk:get_from(.) and  mk:get_to(.) > $to)]">
            <xsl:message>removing: <xsl:copy-of select="."/> - preceding affiliation overlapping</xsl:message>
          </xsl:when>

          <!-- ========= preserve or modify: ========= -->
          <!-- duplicity is after - different ana -> merge -->
          <xsl:when test="$aff-duplicit-diff-ana">
            <xsl:variable name="ana" select="mk:unique_list(fn:string-join((@ana,$aff-duplicit-diff-ana/@ana),' '))"/>

            <xsl:message>modifying: <xsl:copy-of select="."/> - affiliation is duplicit - merging ana='<xsl:value-of select="$ana"/>'</xsl:message>
            <xsl:copy>
              <xsl:apply-templates select="@*[name() != 'ana']"/>
              <xsl:if test="$ana">
                <xsl:attribute name="ana" select="$ana"/>
              </xsl:if>
              <xsl:apply-templates select="*"/>
            </xsl:copy>
          </xsl:when>
          <!-- overlaping is following - extend -->
          <xsl:when test="following-sibling::tei:affiliation
                                                  [@role='member'][@role=$role]
                                                  [@ref = $ref]
                                                  [not(@ana) or @ana = $ana]
                                                  [not(./tei:roleName/text()) or normalize-space(./tei:roleName/text()) = $text]
                                                  [($from > mk:get_from(.) and  mk:get_to(.) > $from) or ($to > mk:get_from(.) and  mk:get_to(.) > $to)]">

            <xsl:variable name="new-interval" select="mk:get_overlapping_affiliations_interval(./parent::*,$role,$ref,$ana,$text,$from,$to)"/>
            <xsl:variable name="new-from" select="substring-before($new-interval,' ')"/>
            <xsl:variable name="new-to" select="substring-after($new-interval,' ')"/>
            <xsl:variable name="preceding-fixing-nodes"
                          select="preceding-sibling::tei:affiliation
                                                  [@role='member'][@role=$role]
                                                  [@ref = $ref]
                                                  [not(@ana) or @ana = $ana]
                                                  [not(./tei:roleName/text()) or normalize-space(./tei:roleName/text()) = $text]
                                                  [mk:get_from(.) >= $new-from and  $new-to >= mk:get_to(.)]"/>

            <xsl:choose>
              <xsl:when test="$preceding-fixing-nodes">
                <xsl:message>already fixed: <xsl:copy-of select="."/> - merge all overlapping affiliations. New period is <xsl:value-of select="concat($new-from,' --- ',$new-to)"/></xsl:message>
              </xsl:when>
              <xsl:otherwise>
                <xsl:message>modifying: <xsl:copy-of select="."/> - merge all overlapping affiliations. New period is <xsl:value-of select="concat($new-from,' --- ',$new-to)"/></xsl:message>
                <xsl:copy>
                  <xsl:apply-templates select="@*[not(contains(' from to ', mk:borders(./name())))]"/>
                  <xsl:attribute name="from" select="$new-from"/>
                  <xsl:attribute name="to" select="$new-to"/>
                  <xsl:apply-templates select="*"/>
                </xsl:copy>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <!-- otherwise - preserve -->
          <xsl:otherwise>
            <xsl:copy-of select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:template>


  <!-- COPY REST -->
  <xsl:template match="*">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@*">
    <xsl:copy/>
  </xsl:template>

  <xsl:template match="comment()">
    <xsl:copy/>
  </xsl:template>


  <xsl:function name="mk:unique_list">
    <xsl:param name="input"/>
    <xsl:variable name="uniq">
      <xsl:for-each select="distinct-values(tokenize(normalize-space($input), ' '))">
        <xsl:sort select="." order="ascending"/>
        <xsl:value-of select="."/>
        <xsl:text> </xsl:text>
      </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="replace($uniq, ' $', '')"/>
  </xsl:function>

  <xsl:function name="mk:get_overlapping_affiliations_interval">
    <xsl:param name="parent"/>
    <xsl:param name="role"/>
    <xsl:param name="ref"/>
    <xsl:param name="ana"/>
    <xsl:param name="text"/>
    <xsl:param name="from"/>
    <xsl:param name="to"/>
    <xsl:message><xsl:text>     </xsl:text>  <xsl:value-of select="concat($from,' --- ',$to)"/></xsl:message>
    <xsl:variable name="extend-iterval-node" select="$parent/tei:affiliations
                                                       [@role='member'][@role=$role]
                                                       [@ref = $ref]
                                                       [not(@ana) or @ana = $ana]
                                                       [not(./tei:roleName/text()) or normalize-space(./tei:roleName/text()) = $text]
                                                       [($from > mk:get_from(.) and  mk:get_to(.) > $from) or ($to > mk:get_from(.) and  mk:get_to(.) > $to)][1]"/>
    <xsl:message><xsl:text>     </xsl:text><xsl:copy-of select="$extend-iterval-node"/></xsl:message>
    <xsl:choose>
      <xsl:when test="$extend-iterval-node">
        <xsl:value-of select="mk:get_overlapping_affiliations_interval(
                                               $parent,
                                               $role,
                                               $ref,
                                               $ana,
                                               $text,
                                               mk:min_date($from,$extend-iterval-node/mk:get_from(.)),
                                               mk:max_date($to,$extend-iterval-node/mk:get_to(.))
                                            )"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat($from, ' ', $to)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>


  <xsl:function name="mk:min_date">
    <xsl:param name="d1"/>
    <xsl:param name="d2"/>
    <xsl:choose>
      <xsl:when test="mk:fix_date($d2,'-01-01','T00:00:00') > mk:fix_date($d2,'-01-01','T00:00:00') "><xsl:value-of select="$d1"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="$d2"/></xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="mk:max_date">
    <xsl:param name="d1"/>
    <xsl:param name="d2"/>
    <xsl:choose>
      <xsl:when test="mk:fix_date($d1,'-12-31','T23:59:59') > mk:fix_date($d2,'-12-31','T23:59:59') "><xsl:value-of select="$d1"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="$d2"/></xsl:otherwise>
    </xsl:choose>
  </xsl:function>


  <xsl:function name="mk:fix_date" as="xs:dateTime">
    <xsl:param name="date"/>
    <xsl:param name="fixDate"/>
    <xsl:param name="fixTime"></xsl:param>
    <xsl:choose>
      <xsl:when test="string-length($date) = 4"><xsl:value-of select="concat($date,$fixDate,$fixTime)"/></xsl:when>
      <xsl:when test="string-length($date) = 10"><xsl:value-of select="concat($date,$fixTime)"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="$date"/></xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="mk:get_from">
    <xsl:param name="node"/>
    <xsl:choose>
      <xsl:when test="$node/@from"><xsl:value-of select="$node/@from"/></xsl:when>
      <xsl:when test="$node/@when"><xsl:value-of select="$node/@from"/></xsl:when>
      <xsl:when test="$node
                        and $node/ancestor::tei:teiHeader//tei:sourceDesc/tei:bibl[1]/tei:date
                        and not($node/parent::tei:bibl/parent::tei:sourceDesc/parent::tei:fileDesc)">
        <xsl:value-of select="mk:get_from($node/ancestor::tei:teiHeader//tei:sourceDesc/tei:bibl[1]/tei:date)"/>
      </xsl:when>
      <xsl:otherwise>1500-01-01</xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="mk:get_to">
    <xsl:param name="node"/>
    <xsl:choose>
      <xsl:when test="$node/@to"><xsl:value-of select="$node/@to"/></xsl:when>
      <xsl:when test="$node/@when"><xsl:value-of select="$node/@to"/></xsl:when>
      <xsl:when test="$node
                       and $node/ancestor::tei:teiHeader//tei:sourceDesc/tei:bibl[1]/tei:date
                       and not($node/parent::tei:bibl/parent::tei:sourceDesc/parent::tei:fileDesc)">
        <xsl:value-of select="mk:get_to($node/ancestor::tei:teiHeader//tei:sourceDesc/tei:bibl[1]/tei:date)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$node/ancestor::tei:teiHeader//tei:publicationStmt/tei:date/@when"/></xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="mk:borders">
    <xsl:param name="str"/>
    <xsl:value-of select="concat(' ',$str,' ')"/>
  </xsl:function>

</xsl:stylesheet>
