<?xml version='1.0' encoding='UTF-8'?>
<!-- Xtra validation of ParlaMint affiliations and organizations -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:mk="http://ufal.mff.cuni.cz/matyas-kopp"
  exclude-result-prefixes="tei xi">

  <xsl:import href="parlamint-lib.xsl"/>
  
  <xsl:output method="text"/>

  <xsl:template match="/tei:teiCorpus">
    <xsl:apply-templates select="$rootHeader"/>
  </xsl:template>
  
  <xsl:template match="tei:affiliation">
    <xsl:variable name="personId" select="./parent::tei:person/@xml:id"/>
    <xsl:variable name="person" select="./parent::tei:person"/>
    <xsl:variable name="ref" select="@ref"/>
    <xsl:variable name="role" select="@role"/>
    <xsl:variable name="from" select="mk:get_from(.)"/>
    <xsl:variable name="to" select="mk:get_to(.)"/>
    <xsl:variable name="ana" select="@ana"/>
    <xsl:variable name="text" select="./text()[normalize-space(.)]"/>

    <xsl:if test="$text">
      <xsl:call-template name="affiliation-error">
        <xsl:with-param name="ident">02</xsl:with-param>
        <xsl:with-param name="msg">
          <xsl:text>Contains text value'</xsl:text>
          <xsl:value-of select="$text"/><xsl:text>'</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>

    <xsl:choose>
      <xsl:when test="$ref">
        <xsl:variable name="affWith" select="./ancestor::tei:particDesc//*[@xml:id = substring-after($ref,'#')]"/>
        <xsl:choose>
          <xsl:when test="$affWith/local-name()='org'"> <!-- affiliation with organization -->
            <xsl:variable name="orgFrom" select="mk:get_org_from($affWith)"/>
            <xsl:variable name="orgTo" select="mk:get_org_to($affWith)"/>
            <xsl:variable name="affFrom" select="mk:fix_date($from,'-01-01','T00:00:00')"/>
            <xsl:variable name="affTo" select="mk:fix_date($to,'-12-31','T23:59:59')"/>
            <xsl:variable name="roleNames" select="concat('|',
                                                          string-join('|',
                                                               ./roleName/concat(./ancestor-or-self::*/@xml:lang[1],
                                                                                 '=',
                                                                                text()
                                                                                )
                                                              ),
                                                          '|'
                                                          )"/>


            <!-- overlapping affiliations with same role and same organization -->
            <xsl:variable name="aff-duplicit" select="following-sibling::tei:affiliation
                                                        [@role=$role]
                                                        [@ref = $ref]
                                                        [mk:contains(., 'roleName', $roleNames)]
                                                        [$from=mk:get_from(.) and $to = mk:get_to(.)][1]"/>
            <xsl:variable name="aff-day-overlap" select="following-sibling::tei:affiliation
                                                        [@role=$role]
                                                        [@ref = $ref]
                                                        [not(@ana) or @ana = $ana]
                                                        [mk:contains(., 'roleName', $roleNames)]
                                                        [$from=mk:get_to(.) or $to = mk:get_from(.)][1]"/>
            <xsl:variable name="aff-cover" select="(preceding-sibling::tei:affiliation,following-sibling::tei:affiliation)
                                                        [@role=$role]
                                                        [@ref = $ref]
                                                        [not(@ana) or @ana = $ana]
                                                        [mk:contains(., 'roleName', $roleNames)]
                                                        [$from >= mk:get_from(.) and  mk:get_to(.) >= $to and not($from = mk:get_from(.) and $to = mk:get_to(.))][1]"/>
            <xsl:variable name="aff-overlap" select="following-sibling::tei:affiliation
                                                        [@role=$role]
                                                        [@ref = $ref]
                                                        [not(@ana) or @ana = $ana]
                                                        [mk:contains(., 'roleName', $roleNames)]
                                                        [($from > mk:get_from(.) and  mk:get_to(.) > $from) or ($to > mk:get_from(.) and  mk:get_to(.) > $to)][1]"/>
            <xsl:choose>
              <xsl:when test="$aff-duplicit">
                <xsl:call-template name="affiliation-error-overlap">
                  <xsl:with-param name="ident">01</xsl:with-param>
                  <xsl:with-param name="severity">ERROR</xsl:with-param>
                  <xsl:with-param name="msg">is duplicated by</xsl:with-param>
                  <xsl:with-param name="aff-overlaps" select="$aff-duplicit"/>
                </xsl:call-template>
              </xsl:when>
              <xsl:when test="$aff-day-overlap"> <!-- one day overlap -->
                <xsl:call-template name="affiliation-error-overlap">
                  <xsl:with-param name="ident">01</xsl:with-param>
                  <xsl:with-param name="severity">INFO</xsl:with-param>
                  <xsl:with-param name="msg">has one day overlap with</xsl:with-param>
                  <xsl:with-param name="aff-overlaps" select="aff-day-overlap"/>
                </xsl:call-template>
              </xsl:when>
              <xsl:when test="$aff-cover"> <!-- inside other affiliation -->
                <xsl:call-template name="affiliation-error-overlap">
                  <xsl:with-param name="ident">01</xsl:with-param>
                  <xsl:with-param name="severity">ERROR</xsl:with-param>
                  <xsl:with-param name="msg">is inside</xsl:with-param>
                  <xsl:with-param name="aff-overlaps" select="$aff-cover"/>
                </xsl:call-template>
              </xsl:when>
              <xsl:when test="$aff-overlap">
                <xsl:call-template name="affiliation-error-overlap">
                  <xsl:with-param name="ident">01</xsl:with-param>
                  <xsl:with-param name="severity">
                    <xsl:choose>
                      <xsl:when test="$role = 'member'">ERROR</xsl:when>
                      <xsl:otherwise>WARN</xsl:otherwise>
                    </xsl:choose>
                  </xsl:with-param>
                  <xsl:with-param name="msg">has multiple days overlap with</xsl:with-param>
                  <xsl:with-param name="aff-overlaps" select="$aff-overlap"/>
                </xsl:call-template>
              </xsl:when>
            </xsl:choose>
            <!-- -->

            <xsl:call-template name="check-in-event">
              <xsl:with-param name="refs"><xsl:value-of select="@ana"/></xsl:with-param>
              <xsl:with-param name="date"><xsl:value-of select="$affFrom"/></xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="check-in-event">
              <xsl:with-param name="refs"><xsl:value-of select="@ana"/></xsl:with-param>
              <xsl:with-param name="date"><xsl:value-of select="$affTo"/></xsl:with-param>
            </xsl:call-template>

            <!-- test if affiliation correspond to organization existence -->
            <xsl:if test="$orgFrom > $affFrom ">
              <xsl:call-template name="error">
                <xsl:with-param name="ident">08</xsl:with-param>
                <xsl:with-param name="severity">WARN</xsl:with-param>
                <xsl:with-param name="msg">
                  <xsl:text>Affiliate from date (</xsl:text>
                  <xsl:value-of select="$affFrom"/>
                  <xsl:text>) is </xsl:text>
                  <xsl:value-of select="xs:duration(xs:dateTime($orgFrom) - xs:dateTime($affFrom))"/>
                  <xsl:text> before </xsl:text>
                  <xsl:value-of select="$affWith/@xml:id"/>
                  <xsl:text> organization beginning (</xsl:text>
                  <xsl:value-of select="$orgFrom"/>
                  <xsl:text>) </xsl:text>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:if>
            <xsl:if test="affTo > $orgTo ">
              <xsl:call-template name="error">
                <xsl:with-param name="ident">07</xsl:with-param>
                <xsl:with-param name="severity">WARN</xsl:with-param>
                <xsl:with-param name="msg">
                  <xsl:text>Affiliate to date (</xsl:text>
                  <xsl:value-of select="$affTo"/>
                  <xsl:text>) is </xsl:text>
                  <xsl:value-of select="xs:duration(xs:dateTime($affTo) - xs:dateTime($orgTo))"/>
                  <xsl:text>after </xsl:text>
                  <xsl:value-of select="$affWith/@xml:id"/>
                  <xsl:text> organization ending (</xsl:text>
                  <xsl:value-of select="$orgTo"/>
                  <xsl:text>) </xsl:text>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:if>

            <xsl:variable name="role-msg" select="mk:affiliation-role-test(@role,$affWith/@role)"/>
            <xsl:if test="not($role-msg = 'PASS')">
              <xsl:call-template name="affiliation-error">
                <xsl:with-param name="ident"><xsl:value-of select="substring-before($role-msg,':')"/></xsl:with-param>
                <xsl:with-param name="severity"><xsl:value-of select="substring-after(substring-before($role-msg,')'),':')"/></xsl:with-param>
                <xsl:with-param name="msg"><xsl:text>Non-standard role '</xsl:text><xsl:value-of select="@role"/><xsl:text>' - </xsl:text><xsl:value-of select="substring-after($role-msg,')')"/></xsl:with-param>
              </xsl:call-template>
            </xsl:if>

            <xsl:variable name="implicated-role" select="mk:affiliation-implicated-role(@role,$affWith/@role)"/>
            <xsl:if test="not($implicated-role = '')">
              <xsl:variable name="implicated-affiliation" select="$person/tei:affiliation[@role=$implicated-role and @ref=$ref and $from>=mk:get_from(.) and mk:get_to(.)>=$to ]"/>
              <xsl:if test="not($implicated-affiliation)">
                <xsl:variable name="severity">
                  <xsl:choose>
                    <xsl:when test="mk:is-obligatory('org',$affWith/@role)">ERROR</xsl:when>
                    <xsl:otherwise>WARN</xsl:otherwise>
                  </xsl:choose>
                </xsl:variable>
                <xsl:call-template name="affiliation-error">
                  <xsl:with-param name="ident">18</xsl:with-param>
                  <xsl:with-param name="severity"><xsl:value-of select="$severity"/></xsl:with-param>
                  <xsl:with-param name="msg"><xsl:text>Missing implicated affiliation role '</xsl:text><xsl:value-of select="$implicated-role"/><xsl:text>'</xsl:text></xsl:with-param>
                </xsl:call-template>
              </xsl:if>
            </xsl:if>


          </xsl:when>
          <xsl:when test="not($affWith)"> <!-- ref contain reference inside current corpus file -->
            <xsl:call-template name="error">
              <xsl:with-param name="ident">03</xsl:with-param>
              <xsl:with-param name="msg">
                <xsl:text>Wrong affiliation ref=</xsl:text>
                <xsl:value-of select="@ref"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise> <!-- affiliation is not with organization -->
            <xsl:call-template name="affiliation-error">
              <xsl:with-param name="ident">04</xsl:with-param>
              <xsl:with-param name="msg">
                <xsl:text>Affiliation with </xsl:text>
                <xsl:value-of select="$affWith/local-name()" />
                <xsl:text> element</xsl:text>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="affiliation-error">
          <xsl:with-param name="ident">05</xsl:with-param>
          <xsl:with-param name="msg">
            <xsl:text>Missing reference</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <xsl:template match="tei:org">
    <xsl:if test="not(@role)">
      <xsl:call-template name="error">
        <xsl:with-param name="ident">09</xsl:with-param>
        <xsl:with-param name="msg">
          <xsl:text>Organisation without role for </xsl:text>
          <xsl:value-of select="."/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="@role='parliament' and not( (contains(mk:borders(@ana),' #parla.national ') or contains(mk:borders(@ana),' #parla.regional ')) and (contains(mk:borders(@ana),' #parla.uni ') or contains(mk:borders(@ana),' #parla.lower ') or contains(mk:borders(@ana),' #parla.upper '))) ">
      <xsl:call-template name="error">
        <xsl:with-param name="ident">19</xsl:with-param>
        <xsl:with-param name="msg">
          <xsl:text>Parliament organization without geo-political(#parla.national/#parla.regional) or chamber(#parla.uni/#parla.lower/#parla.upper) classification</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="@xml:id">
        <!-- organization without affiliation -->
        <xsl:variable name="orgId" select="@xml:id"/>
        <xsl:variable name="affCnt" select="count(./ancestor::tei:particDesc//tei:affiliation[@ref = concat('#',$orgId)])"/>
        <xsl:variable name="affCnt-no-from-to"
                      select="count(./ancestor::tei:particDesc//tei:affiliation[@ref = concat('#',$orgId) and not(@from) and not(@to)])"/>

        <xsl:call-template name="error">
          <xsl:with-param name="ident">10</xsl:with-param>
          <xsl:with-param name="severity">INFO</xsl:with-param>
          <xsl:with-param name="msg">
            <xsl:text>Total number of affiliations with </xsl:text>
            <xsl:value-of select="$orgId"/>
            <xsl:text>: </xsl:text>
            <xsl:value-of select="$affCnt"/>
          </xsl:with-param>
        </xsl:call-template>

        <xsl:if test="$affCnt > 0 and $affCnt-no-from-to > 0">
          <xsl:call-template name="error">
            <xsl:with-param name="ident">20</xsl:with-param>
            <xsl:with-param name="severity">
              <xsl:choose>
                <xsl:when test="contains(' parliament government ', @role) and ($affCnt-no-from-to div $affCnt > 0.5)">ERROR</xsl:when> <!-- more than 50% are covering whole period -->
                <xsl:otherwise>INFO</xsl:otherwise>
              </xsl:choose>
            </xsl:with-param>
            <xsl:with-param name="msg">
            <xsl:text>Total number of whole-corpus-period-covering affiliations with </xsl:text>
            <xsl:value-of select="$orgId"/>
            <xsl:text>: </xsl:text>
            <xsl:value-of select="$affCnt-no-from-to"/>
            <xsl:value-of select="concat(' (',format-number(100 * $affCnt-no-from-to div $affCnt,'0.00'),'%)')"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>

        <xsl:if test="$affCnt = 0">
          <xsl:call-template name="error">
            <xsl:with-param name="ident">10</xsl:with-param>
            <xsl:with-param name="severity">
              <xsl:choose>
                <xsl:when test="mk:is-obligatory('org',./@role) and @role != 'parliamentaryGroup'">ERROR</xsl:when>
                <xsl:otherwise>WARN</xsl:otherwise>
              </xsl:choose>
            </xsl:with-param>
            <xsl:with-param name="msg">
              <xsl:value-of select="@role"/>
              <xsl:text>-role organisation without affiliation: #</xsl:text>
              <xsl:value-of select="@xml:id"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="error">
          <xsl:with-param name="ident">11</xsl:with-param>
          <xsl:with-param name="msg">
            <xsl:text>Organisation has not id </xsl:text>
            <xsl:apply-templates select="." mode="serialize"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>

    <!-- government and parliament has "terms" events -->
    <!-- parliament has ana -->
    <!-- events in organization match its existence ??? -->
  </xsl:template>


  <xsl:template match="tei:particDesc">
    <xsl:apply-templates/>
    <!-- test parliament existence -->
    <xsl:call-template name="org-role-cnt">
      <xsl:with-param name="role">parliament</xsl:with-param>
      <xsl:with-param name="min">1</xsl:with-param>
    </xsl:call-template>
    <!-- test government existence -->
    <xsl:call-template name="org-role-cnt">
      <xsl:with-param name="role">government</xsl:with-param>
      <xsl:with-param name="min">1</xsl:with-param>
      <xsl:with-param name="max">1</xsl:with-param>
    </xsl:call-template>
    <!-- test parliamentaryGroup existence -->
    <xsl:call-template name="org-role-cnt">
      <xsl:with-param name="role">parliamentaryGroup</xsl:with-param>
      <xsl:with-param name="min">1</xsl:with-param>
    </xsl:call-template>
    <!-- affiliation statistics -->
    <!-- total number of affiliations -->
    <xsl:call-template name="error">
      <xsl:with-param name="severity">INFO</xsl:with-param>
      <xsl:with-param name="msg">
        <xsl:text>Total number of affiliations </xsl:text>
        <xsl:value-of select="count(.//tei:affiliation)"/>
      </xsl:with-param>
    </xsl:call-template>
    <!-- affiliations by role -->
    <xsl:call-template name="error">
      <xsl:with-param name="severity">INFO</xsl:with-param>
      <xsl:with-param name="msg">
        <xsl:text>Total number of NO-role affiliations </xsl:text>
        <xsl:value-of select="count(.//tei:affiliation[not(@role)])"/>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:variable name="roles" select=".//tei:affiliation/@role"/>
    <xsl:variable name="particDesc" select="."/>
    <xsl:for-each select="distinct-values(data($roles))">
      <xsl:variable name="role" select="."/>
        <xsl:for-each select="$particDesc"><!-- changing context back to particDesc -->
        <xsl:call-template name="error">
          <xsl:with-param name="severity">INFO</xsl:with-param>
          <xsl:with-param name="msg">
            <xsl:text>Total number of '</xsl:text>
            <xsl:value-of select="$role"/>
            <xsl:text>' role affiliations </xsl:text>
            <xsl:value-of select="count(.//tei:affiliation[@role=$role])"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="check-in-event">
    <xsl:param name="refs"/>
    <xsl:param name="date"/>
    <xsl:choose>
      <xsl:when test="not($refs) or $refs = ''"/>
      <xsl:when test="not($date)"/>
      <xsl:otherwise>
        <xsl:variable name="newRefs" select="substring-after($refs,' ')"/>
        <xsl:variable name="actRef" select="substring-after(substring-before(concat($refs,' '),' '),'#')"/>
        <xsl:variable name="eventNode" select="./ancestor::tei:particDesc//tei:event[@xml:id = $actRef]"/>
        <xsl:if test="$eventNode">
          <xsl:variable name="eventFrom" select="mk:fix_date(mk:get_from($eventNode),'-01-01','T00:00:00')" />
          <xsl:variable name="eventTo" select="mk:fix_date(mk:get_to($eventNode),'-12-31','T23:59:59')" />
          <xsl:if test="($eventFrom > $date or $date > $eventTo) and $eventTo >= $eventFrom">
            <xsl:call-template name="error">
              <xsl:with-param name="ident">13</xsl:with-param>
              <xsl:with-param name="severity">WARN</xsl:with-param>
              <xsl:with-param name="msg">
                <xsl:text>Event #</xsl:text>
                <xsl:value-of select="$actRef"/>
                <xsl:text> (</xsl:text>
                <xsl:value-of select="$eventFrom"/>
                <xsl:text> ...  </xsl:text>
                <xsl:value-of select="$eventTo"/>
                <xsl:text>) corresponding to affiliation don't cover affiliation date </xsl:text>
                <xsl:value-of select="$date"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:if>
        </xsl:if>
        <xsl:call-template name="check-in-event">
          <xsl:with-param name="refs"><xsl:value-of select="$newRefs"/></xsl:with-param>
          <xsl:with-param name="date"><xsl:value-of select="$date"/></xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="org-role-cnt">
    <xsl:param name="min">0</xsl:param>
    <xsl:param name="max">-1</xsl:param>
    <xsl:param name="role"/>
    <xsl:param name="severity">ERROR</xsl:param>
    <xsl:variable name="cnt" select="count(.//tei:org[@role=$role])"/>
    <xsl:call-template name="error">
      <xsl:with-param name="ident">12</xsl:with-param>
      <xsl:with-param name="severity">
        <xsl:choose>
          <xsl:when test="$min > $cnt or ($max >=0 and $cnt > $max) "><xsl:value-of select="$severity"/></xsl:when>
          <xsl:otherwise>INFO</xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
      <xsl:with-param name="msg">
        <xsl:text>Total number of organizations with </xsl:text>
        <xsl:value-of select="$role"/>
        <xsl:text> role: </xsl:text>
        <xsl:value-of select="$cnt"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="text()"/>

  <xsl:template name="affiliation-error">
    <xsl:param name="msg">???</xsl:param>
    <xsl:param name="severity">ERROR</xsl:param>
    <xsl:param name="ident">??</xsl:param>
    <xsl:variable name="personId" select="./parent::tei:person/@xml:id"/>
    <xsl:call-template name="error">
      <xsl:with-param name="severity">
        <xsl:value-of select="$severity"/>
      </xsl:with-param>
      <xsl:with-param name="ident">
        <xsl:value-of select="$ident"/>
      </xsl:with-param>
      <xsl:with-param name="msg">
        <xsl:value-of select="$msg"/>
        <xsl:text> in </xsl:text>
        <xsl:value-of select="$personId"/>
        <xsl:text> affiliation </xsl:text>
        <xsl:apply-templates select="." mode="serialize"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="affiliation-error-overlap">
    <xsl:param name="msg">???</xsl:param>
    <xsl:param name="severity">ERROR</xsl:param>
    <xsl:param name="ident">??</xsl:param>
    <xsl:param name="aff-overlaps"/>
    <xsl:variable name="personId" select="./parent::tei:person/@xml:id"/>
    <xsl:call-template name="error">
      <xsl:with-param name="severity">
        <xsl:value-of select="$severity"/>
      </xsl:with-param>
      <xsl:with-param name="ident">
        <xsl:value-of select="$ident"/>
      </xsl:with-param>
      <xsl:with-param name="msg">
        <xsl:text>affiliation collision: (</xsl:text>
        <xsl:value-of select="mk:get_from(.)"/>
        <xsl:text> --- </xsl:text>
        <xsl:value-of select="mk:get_to(.)"/>
        <xsl:text>) </xsl:text>
        <xsl:value-of select="$msg"/>
        <xsl:text> (</xsl:text>
        <xsl:value-of select="mk:get_from($aff-overlaps)"/>
        <xsl:text> --- </xsl:text>
        <xsl:value-of select="mk:get_to($aff-overlaps)"/>
        <xsl:text>) affiliation </xsl:text>
        <xsl:if test="$aff-overlaps/@LINE">
          <xsl:text>(line:</xsl:text>
          <xsl:value-of select="$aff-overlaps/@LINE"/>
          <xsl:text>) </xsl:text>
        </xsl:if>
        <xsl:value-of select="@role"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="@ref"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>


  <xsl:template name="error">
    <xsl:param name="msg">???</xsl:param>
    <xsl:param name="severity">ERROR</xsl:param>
    <xsl:param name="ident">??</xsl:param>
    <xsl:message>
      <xsl:value-of select="$severity"/>
      <xsl:text>[</xsl:text>
      <xsl:value-of select="$ident"/>
      <xsl:text>]&#32;</xsl:text>
      <xsl:value-of select="./ancestor-or-self::tei:*[starts-with(@xml:id,'ParlaMint-')][1]/@xml:id"/>
      <xsl:if test="./@LINE">
        <xsl:text>:</xsl:text>
        <xsl:value-of select="./@LINE"/>
      </xsl:if>
      <xsl:text>&#32;</xsl:text>
      <xsl:value-of select="$msg"/>
    </xsl:message>
  </xsl:template>



  <xsl:template match="*" mode="serialize">
    <xsl:text>[</xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:apply-templates select="@*" mode="serialize" />
    <xsl:choose>
        <xsl:when test="node()">
            <xsl:text>]</xsl:text>
            <xsl:apply-templates mode="serialize" />
            <xsl:text>[/</xsl:text>
            <xsl:value-of select="name()"/>
            <xsl:text>]</xsl:text>
        </xsl:when>
        <xsl:otherwise>
            <xsl:text> /]</xsl:text>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="@*[not(name()='LINE')]" mode="serialize">
    <xsl:text> </xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:text>="</xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>"</xsl:text>
</xsl:template>

<xsl:template match="@LINE" mode="serialize"></xsl:template>

<xsl:template match="text()" mode="serialize">
    <xsl:value-of select="."/>
</xsl:template>


  <xsl:function name="mk:affiliation-role-test">
    <xsl:param name="role"/>
    <xsl:param name="orgrole"/>
    <xsl:choose>
      <!-- TODO: extend rules -->
      <xsl:when test="contains(' MP primeMinister chairman viceChairman ', $role)">14:ERROR)not allowed in any context</xsl:when>
      <xsl:when test="$orgrole = 'parliament' and contains(' minister deputyMinister ', mk:borders($role))">15:ERROR)invalid affiliation role with parliament organization</xsl:when>
      <xsl:when test="$orgrole = 'parliament' and not(contains(' head member deputyHead replacement ', mk:borders($role)))">15:WARN)consider changing affiliation role with parliament organization</xsl:when>
      <xsl:when test="$orgrole = 'government' and not(contains(' head member deputyHead minister deputyMinister ', mk:borders($role)))">16:WARN)consider changing affiliation role with government organization</xsl:when>
      <xsl:when test="$orgrole = 'parliamentaryGroup' and not(contains(' head deputyHead member ', mk:borders($role)))">17:WARN)consider changing affiliation role with parliamentary group organization</xsl:when>
      <xsl:otherwise>PASS</xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="mk:affiliation-implicated-role">
    <xsl:param name="role"/>
    <xsl:param name="orgrole"/>
    <xsl:choose>
      <!-- parliament -->
      <xsl:when test="$role='head' and $orgrole='parliament'">member</xsl:when>
      <xsl:when test="$role='deputyHead' and $orgrole='parliament'">member</xsl:when>
      <!-- parliamentaryGroup -->
      <xsl:when test="$role='head' and $orgrole='parliamentaryGroup'">member</xsl:when>
      <xsl:when test="$role='deputyHead' and $orgrole='parliamentaryGroup'">member</xsl:when>
      <!-- government -->
      <xsl:when test="$role='head' and $orgrole='government'">member</xsl:when>
      <xsl:when test="$role='deputyHead' and $orgrole='government'">member</xsl:when>
      <xsl:when test="$role='minister' and $orgrole='government'">member</xsl:when>

      <!-- general organization -->
      <xsl:when test="$role='head'">member</xsl:when>
      <xsl:when test="$role='deputyHead'">member</xsl:when>
      <xsl:otherwise><xsl:text/></xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="mk:is-obligatory">
    <xsl:param name="elem"/>
    <xsl:param name="role"/>
    <xsl:choose>
      <xsl:when test="$elem='org' and $role='parliament'"><xsl:sequence select="true()"/></xsl:when>
      <xsl:when test="$elem='org' and $role='government'"><xsl:sequence select="true()"/></xsl:when>
      <xsl:when test="$elem='org' and $role='parliamentaryGroup'"><xsl:sequence select="true()"/></xsl:when>
      <xsl:otherwise><xsl:sequence select="false()"/></xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="mk:get_org_from">
    <xsl:param name="org"/>
    <xsl:choose>
      <xsl:when test="$org//tei:event/@*[contains(' from when ',mk:borders(name()))]"><xsl:value-of select="min($org//tei:event/@*[contains(' from when ',mk:borders(name()))]/xs:dateTime(mk:fix_date(.,'-01-01','T00:00:00')))"/></xsl:when>
      <xsl:otherwise>1500-01-01T00:00:00</xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="mk:get_org_to">
    <xsl:param name="org"/>
    <xsl:choose>
      <xsl:when test="$org//tei:event/@*[contains(' to when ',mk:borders(name()))]"><xsl:value-of select="max($org//tei:event/@*[contains(' to when ',mk:borders(name()))]/xs:dateTime(mk:fix_date(.,'-12-31','T23:59:59')))"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="$org/ancestor::tei:teiHeader//tei:publicationStmt/tei:date/@when/xs:dateTime(mk:fix_date(.,'-12-31','T23:59:59'))"/></xsl:otherwise>
    </xsl:choose>
  </xsl:function>


  <xsl:function name="mk:get_from">
    <xsl:param name="node"/>
    <xsl:choose>
      <xsl:when test="$node/@from"><xsl:value-of select="$node/@from"/></xsl:when>
      <xsl:when test="$node/@when"><xsl:value-of select="$node/@when"/></xsl:when>
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
      <xsl:when test="$node/@when"><xsl:value-of select="$node/@when"/></xsl:when>
      <xsl:when test="$node/ancestor::tei:teiHeader//tei:publicationStmt/tei:date/@when"><xsl:value-of select="$node/ancestor::tei:teiHeader//tei:publicationStmt/tei:date/@when"/></xsl:when>
      <xsl:when test="$node
                       and $node/ancestor::tei:teiHeader//tei:sourceDesc/tei:bibl[1]/tei:date
                       and not($node/parent::tei:bibl/parent::tei:sourceDesc/parent::tei:fileDesc)">
        <xsl:value-of select="mk:get_to($node/ancestor::tei:teiHeader//tei:sourceDesc/tei:bibl[1]/tei:date)"/>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="$node/ancestor::tei:teiHeader//tei:publicationStmt/tei:date/@when"/></xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="mk:fix_date">
    <xsl:param name="date"/>
    <xsl:param name="fixDate"/>
    <xsl:param name="fixTime"></xsl:param>
    <xsl:choose>
      <xsl:when test="string-length($date) = 4"><xsl:value-of select="concat($date,$fixDate,$fixTime)"/></xsl:when>
      <xsl:when test="string-length($date) = 10"><xsl:value-of select="concat($date,$fixTime)"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="$date"/></xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="mk:borders">
    <xsl:param name="str"/>
    <xsl:value-of select="concat(' ',$str,' ')"/>
  </xsl:function>

  <xsl:function name="mk:contains">
    <xsl:param name="node"/>
    <xsl:param name="elem-name"/>
    <xsl:param name="text-content"/>
    <xsl:variable name="cnt-elem" select="count($node/*[name() = $elem-name])"/>
    <xsl:choose>
      <xsl:when test="not($node/*[name() = $elem-name])"><xsl:sequence select="true()"/></xsl:when>
      <xsl:when test="$node/*[name() = $elem-name] and $elem-name = '||'"><xsl:sequence select="true()"/></xsl:when>
      <xsl:when test="count($node/*[name() = $elem-name]
                             [contains($text-content,
                                        concat('|',ancestor-or-self/@xml:lang[1],'=',text(),'|')
                                      )]
                          ) = $cnt-elem"><xsl:sequence select="true()"/></xsl:when>
      <xsl:otherwise><xsl:sequence select="false()"/></xsl:otherwise>
    </xsl:choose>
  </xsl:function>
</xsl:stylesheet>
