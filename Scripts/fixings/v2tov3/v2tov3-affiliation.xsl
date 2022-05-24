<?xml version='1.0' encoding='UTF-8'?>
<!-- Fix bugs from ParlaMint V2 for V3 -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:et="http://nl.ijs.si/et"
  xmlns:mk="http://ufal.mff.cuni.cz/matyas-kopp"
  xmlns:saxon="http://saxon.sf.net/"
  exclude-result-prefixes="et mk fn xs tei saxon">


  <!-- Fixing affiliations -->
  <xsl:template match="tei:affiliation[not(text()) and not(@ref)]">
    <xsl:choose>
      <xsl:when test="@role='member'"><!-- BG -->
        <xsl:call-template name="error">
          <xsl:with-param name="severity">INFO</xsl:with-param>
          <xsl:with-param name="msg"><xsl:text>removing senseless affiliation (missing ref and text): </xsl:text> <xsl:apply-templates select="." mode="serialize"/></xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="orgRole" select="mk:person_role_to_org_role(./@role)"/>
        <xsl:variable name="org" select="./ancestor::tei:particDesc/tei:listOrg/tei:org[@role=$orgRole and @xml:id]"/>
        <xsl:choose>
          <xsl:when test="$orgRole=''">
            <xsl:call-template name="error">
              <xsl:with-param name="severity">ERROR</xsl:with-param>
              <xsl:with-param name="msg"><xsl:value-of select="@role" /> does not have implicit organization - impossible to determine correct affiliation</xsl:with-param>
            </xsl:call-template>
            <xsl:comment>removing affiliation - unable to determine @ref: <xsl:apply-templates select="." mode="serialize"/></xsl:comment>
          </xsl:when>
          <xsl:when test="count($org) = 1">
            <xsl:call-template name="error">
              <xsl:with-param name="severity">INFO</xsl:with-param>
              <xsl:with-param name="msg">adding reference to '<xsl:value-of select="$orgRole"/>' affiliation/@ref=#'<xsl:value-of select="$org/@xml:id"/>' to <xsl:apply-templates select="." mode="serialize"/></xsl:with-param>
            </xsl:call-template>
            <xsl:copy>
              <xsl:apply-templates select="@*[name() != 'ana']"/>
              <xsl:attribute name="ref">#<xsl:value-of select="$org/@xml:id"/></xsl:attribute>
              <xsl:call-template name="affiliation-ana"><xsl:with-param name="ref" select="concat('#',$org/@xml:id)"/></xsl:call-template>
            </xsl:copy>
            <xsl:variable name="implicated-role" select="mk:affiliation-implicated-role(@role,$orgRole)"/>
            <xsl:if test="not($implicated-role='')">
              <xsl:call-template name="error">
                <xsl:with-param name="severity">INFO</xsl:with-param>
                <xsl:with-param name="msg">adding implicated affiliation(role='<xsl:value-of select="$implicated-role"/>') to '<xsl:value-of select="$orgRole"/>'</xsl:with-param>
              </xsl:call-template>
              <xsl:copy>
                <xsl:apply-templates select="@*[name() != 'ana' and name() != 'role']"/>
                <xsl:attribute name="ref">#<xsl:value-of select="$org/@xml:id"/></xsl:attribute>
                <xsl:attribute name="role"><xsl:value-of select="$implicated-role"/></xsl:attribute>
                <xsl:call-template name="affiliation-ana"><xsl:with-param name="ref" select="concat('#',$org/@xml:id)"/></xsl:call-template>
              </xsl:copy>
            </xsl:if>
          </xsl:when>
          <xsl:when test="count($org)>1">
            <!-- NL-parliament -->
            <xsl:call-template name="error">
              <xsl:with-param name="severity">ERROR</xsl:with-param>
              <xsl:with-param name="msg"><xsl:value-of select="count($org)"/> <xsl:value-of select="$orgRole"/> organizations - impossible to determine correct affiliation</xsl:with-param>
            </xsl:call-template>
            <xsl:comment>removing affiliation - unable to determine @ref (multiple <xsl:value-of select="$orgRole"/> org): <xsl:apply-templates select="." mode="serialize"/></xsl:comment>
          </xsl:when>
          <xsl:otherwise>
            <!-- PL - missing parliament organization-->
            <xsl:call-template name="error">
              <xsl:with-param name="severity">ERROR</xsl:with-param>
              <xsl:with-param name="msg">missing <xsl:value-of select="$orgRole"/> organization</xsl:with-param>
            </xsl:call-template>
            <xsl:comment>removing affiliation - unable to determine @ref (missing <xsl:value-of select="$orgRole"/> org): <xsl:apply-templates select="." mode="serialize"/></xsl:comment>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

<!-- covered with other template
  <xsl:template match="tei:affiliation[text() and @ref]">
    <xsl:choose>
      <xsl:when test="$country = 'BG' and @ref='#NS' and contains(' MP chairman viceChairman', @role) and text()='депутат'">
        <xsl:copy>
          <xsl:apply-templates select="@*[name() != 'ana']"/>
          <xsl:call-template name="affiliation-ana"><xsl:with-param name="ref" select="@ref"/></xsl:call-template>
        </xsl:copy>
        <xsl:message>INFO: removing text from <xsl:value-of select="@role"/> (<xsl:value-of select="text()"/>) affiliation</xsl:message>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message><xsl:text>WARN: affiliation - ref+text: </xsl:text> <xsl:apply-templates select="." mode="serialize"/></xsl:message>
        <xsl:copy>
          <xsl:apply-templates select="@*[name() != 'ana']"/>
          <xsl:call-template name="affiliation-ana"><xsl:with-param name="ref" select="@ref"/></xsl:call-template>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
-->


  <xsl:template match="tei:affiliation[text() and not(@ref)]">
    <xsl:choose>
      <xsl:when test="$country = 'BG' and text()='депутат'">
        <xsl:copy>
          <xsl:apply-templates select="@*[not(name()='role')]"/>
          <xsl:attribute name="role"><xsl:value-of select="mk:affiliation-role-patch(@role,'parliament')"/></xsl:attribute>
          <xsl:attribute name="ref">#NS</xsl:attribute>
          <xsl:call-template name="affiliation-ana"><xsl:with-param name="ref" select="'#NS'"/></xsl:call-template>
        </xsl:copy>
        <xsl:call-template name="error">
          <xsl:with-param name="severity">INFO</xsl:with-param>
          <xsl:with-param name="msg">adding @ref='#NS' and removing text from <xsl:value-of select="@role"/> (<xsl:value-of select="text()"/>) affiliation</xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$country = 'BG' and @role='primeMinister' and text()='Министър-председател'">
        <xsl:copy>
          <xsl:apply-templates select="@*[not(name()='role')]"/>
          <xsl:attribute name="role"><xsl:value-of select="mk:affiliation-role-patch(@role,'government')"/></xsl:attribute>
          <xsl:attribute name="ref">#gov.IzvSv</xsl:attribute>
          <xsl:call-template name="affiliation-ana"><xsl:with-param name="ref" select="'#gov.IzvSv'"/></xsl:call-template>
        </xsl:copy>
        <xsl:call-template name="error">
          <xsl:with-param name="severity">INFO</xsl:with-param>
          <xsl:with-param name="msg"> adding @ref='#gov.IzvSv' and removing text from <xsl:value-of select="@role"/> (<xsl:value-of select="text()"/>) affiliation</xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="orgRole" select="mk:person_role_to_org_role(./@role)"/>
        <xsl:variable name="org" select="./ancestor::tei:particDesc/tei:listOrg/tei:org[@role=$orgRole and @xml:id]"/>
        <xsl:choose>
          <xsl:when test="$orgRole=''">
            <xsl:call-template name="error">
              <xsl:with-param name="severity">ERROR</xsl:with-param>
              <xsl:with-param name="msg"><xsl:value-of select="./@role"/> does not have implicit organization - impossible to determine correct affiliation</xsl:with-param>
            </xsl:call-template>
            <xsl:comment>removing affiliation - unable to determine @ref: <xsl:apply-templates select="." mode="serialize"/></xsl:comment>
          </xsl:when>
          <xsl:when test="count($org) = 1">
            <xsl:call-template name="error">
              <xsl:with-param name="severity">INFO</xsl:with-param>
              <xsl:with-param name="msg">adding reference to <xsl:value-of select="$orgRole"/> affiliation/@ref=#<xsl:value-of select="$org/@xml:id"/> to <xsl:apply-templates select="." mode="serialize"/></xsl:with-param>
            </xsl:call-template>
            <xsl:copy>
              <xsl:apply-templates select="@*[name() != 'ana' and name() != 'role']"/>
              <xsl:attribute name="role"><xsl:value-of select="mk:affiliation-role-patch(@role,$org/@role)"/></xsl:attribute>
              <xsl:attribute name="ref">#<xsl:value-of select="$org/@xml:id"/></xsl:attribute>
              <xsl:call-template name="affiliation-ana"><xsl:with-param name="ref" select="concat('#',$org/@xml:id)"/></xsl:call-template>
              <xsl:comment><xsl:apply-templates select="./text()" mode="serialize"/></xsl:comment>
            </xsl:copy>
            <xsl:variable name="implicated-role" select="mk:affiliation-implicated-role(@role,$orgRole)"/>
            <xsl:if test="not($implicated-role='')">
              <xsl:call-template name="error">
                <xsl:with-param name="severity">INFO</xsl:with-param>
                <xsl:with-param name="msg">adding implicated affiliation(role='<xsl:value-of select="$implicated-role"/>') to '<xsl:value-of select="$orgRole"/>'</xsl:with-param>
              </xsl:call-template>
              <xsl:copy>
                <xsl:apply-templates select="@*[name() != 'ana' and name() != 'role']"/>
                <xsl:attribute name="ref">#<xsl:value-of select="$org/@xml:id"/></xsl:attribute>
                <xsl:attribute name="role"><xsl:value-of select="$implicated-role"/></xsl:attribute>
                <xsl:call-template name="affiliation-ana"><xsl:with-param name="ref" select="concat('#',$org/@xml:id)"/></xsl:call-template>
              </xsl:copy>
            </xsl:if>
          </xsl:when>
          <xsl:when test="count($org)>1">
            <!-- NL-parliament -->
            <xsl:call-template name="error">
              <xsl:with-param name="severity">ERROR</xsl:with-param>
              <xsl:with-param name="msg"><xsl:value-of select="count($org)"/> <xsl:value-of select="$orgRole"/> organizations - impossible to determine correct affiliation</xsl:with-param>
            </xsl:call-template>
            <xsl:comment>removing affiliation - unable to determine @ref (multiple <xsl:value-of select="$orgRole"/> org): <xsl:apply-templates select="." mode="serialize"/></xsl:comment>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="error">
              <xsl:with-param name="severity">ERROR</xsl:with-param>
              <xsl:with-param name="msg">missing <xsl:value-of select="$orgRole"/> organization</xsl:with-param>
            </xsl:call-template>
            <xsl:comment>removing affiliation - unable to determine @ref (missing <xsl:value-of select="$orgRole"/> org): <xsl:apply-templates select="." mode="serialize"/></xsl:comment>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template match="tei:affiliation[@ref]">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="not(@ana)">
        <xsl:call-template name="affiliation-ana"><xsl:with-param name="ref" select="@ref"/></xsl:call-template>
      </xsl:if>
    </xsl:copy>
    <xsl:variable name="ref" select="@ref"/>
    <xsl:variable name="orgRole" select="./ancestor::tei:particDesc/tei:listOrg/tei:org[@xml:id=substring-after($ref,'#')]/@role"/>
    <xsl:variable name="role" select="mk:affiliation-role-patch(@role,$orgRole)"/>
    <xsl:variable name="implicated-role" select="mk:affiliation-implicated-role($role,$orgRole)"/>
    <xsl:if test="not($implicated-role='')">
      <xsl:variable name="implicated-affiliation" select="mk:affiliation-implicated-role-existence(./parent::tei:person,$implicated-role, $ref, mk:get_from(.), mk:get_to(.))"/>
      <xsl:choose>
        <xsl:when test="$implicated-affiliation">
          <xsl:call-template name="error">
            <xsl:with-param name="severity">INFO</xsl:with-param>
            <xsl:with-param name="msg">implicated affiliation(role='<xsl:value-of select="$implicated-role"/>') exists</xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="error">
            <xsl:with-param name="severity">INFO</xsl:with-param>
            <xsl:with-param name="msg">adding implicated affiliation(role='<xsl:value-of select="$implicated-role"/>') to '<xsl:value-of select="$orgRole"/>'</xsl:with-param>
          </xsl:call-template>
          <xsl:copy>
            <xsl:apply-templates select="@*[name() != 'role']"/>
            <xsl:attribute name="role"><xsl:value-of select="$implicated-role"/></xsl:attribute>
            <xsl:if test="not(@ana)">
              <xsl:call-template name="affiliation-ana"><xsl:with-param name="ref" select="$ref"/></xsl:call-template>
            </xsl:if>
          </xsl:copy>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <xsl:template match="text()[contains(' birth death affiliation ',concat(' ',parent::tei:*/local-name(),' '))]" priority="1">
    <xsl:call-template name="error">
      <xsl:with-param name="severity">INFO</xsl:with-param>
      <xsl:with-param name="msg">removing text content from <xsl:apply-templates select="./parent::tei:*" mode="serialize"/></xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="@role[./parent::tei:affiliation]" priority="1">
    <xsl:variable name="ref" select="./parent::tei:affiliation/@ref"/>
    <xsl:variable name="orgRole" select="./ancestor::tei:particDesc/tei:listOrg/tei:org[@xml:id=substring-after($ref,'#')]/@role"/>
    <xsl:variable name="role" select="mk:affiliation-role-patch(.,$orgRole)"/>
    <xsl:attribute name="role">
      <xsl:choose>
        <xsl:when test=". = 'MP'">member</xsl:when>
        <xsl:when test="$country = 'CZ' and . = 'candidateMP'">representative</xsl:when>
        <xsl:when test="not(. = $role)">
          <xsl:value-of select="$role"/>
          <xsl:call-template name="error">
            <xsl:with-param name="severity">INFO</xsl:with-param>
            <xsl:with-param name="msg">changing affiliation role from '<xsl:value-of select="."/>' to '<xsl:value-of select="$role"/>'</xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="@role[./parent::tei:org]" priority="1">
    <xsl:attribute name="role">
      <xsl:choose>
        <xsl:when test="not($country = 'CZ') and . = 'politicalParty'">parliamentaryGroup</xsl:when>
        <xsl:when test=". = 'politicalGroup'">parliamentaryGroup</xsl:when>
        <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>
  <!-- NAMED TEMPLATES -->
  <xsl:template name="affiliation-ana">
    <xsl:param name="ref"/>
    <xsl:if test="contains(' MP minister primeMinister ', concat(' ',./@role,' '))">
      <xsl:variable name="orgRole" select="mk:person_role_to_org_role(./@role)"/>
      <xsl:variable name="org" select="./ancestor::tei:particDesc/tei:listOrg/tei:org[@role=$orgRole and @xml:id=substring-after($ref,'#')]"/>

      <xsl:variable name="aff" select="."/>
      <xsl:variable name="from" select="mk:get_from($aff)"/>
      <xsl:variable name="to" select="mk:get_to($aff)"/>
      <xsl:if test="$org">
        <xsl:choose>
          <xsl:when test="$org/tei:listEvent/tei:event[xs:date($from) >= xs:date(mk:get_from(.)) and xs:date(mk:get_to(.)) >= xs:date($to)]">
            <xsl:variable name="event" select="$org/tei:listEvent/tei:event[xs:date($from) >= xs:date(mk:get_from(.)) and xs:date(mk:get_to(.)) >= xs:date($to)][last()]"/>
            <xsl:variable name="ana" select="concat('#',$event/@xml:id)"/>
            <xsl:choose>
              <xsl:when test="not(@ana)">
                <xsl:attribute name="ana">#<xsl:value-of select="$event/@xml:id"/></xsl:attribute>
                <xsl:call-template name="error">
                  <xsl:with-param name="severity">INFO</xsl:with-param>
                  <xsl:with-param name="msg">adding corresponding event to @ana: <xsl:apply-templates select="$event" mode="serialize"/></xsl:with-param>
                </xsl:call-template>
              </xsl:when>
<!--
              <xsl:when test="@ana != $ana">
                <xsl:attribute name="ana">#<xsl:value-of select="$event/@xml:id"/></xsl:attribute>
                <xsl:message>WARN: fixing corresponding event in @ana from '<xsl:value-of select="./@ana"/>' to '<xsl:value-of select="$ana"/>' </xsl:message>
              </xsl:when>
-->
              <xsl:otherwise>
                <xsl:apply-templates select="@ana"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="error">
              <xsl:with-param name="severity">ERROR</xsl:with-param>
              <xsl:with-param name="msg">INFO: unable to add corresponding event</xsl:with-param>
            </xsl:call-template>
            <xsl:comment>unable to add @ana - missing organization corresponding event</xsl:comment>
          </xsl:otherwise>

        </xsl:choose>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <!-- FUNCTIONS -->
  <xsl:function name="mk:person_role_to_org_role">
    <xsl:param name="role"/>
    <xsl:choose>

      <xsl:when test="$country = 'BG' and $role = 'minister'">government</xsl:when>
      <xsl:when test="$country = 'BG' and $role = 'primeMinister'">government</xsl:when>
      <xsl:when test="$country = 'BG' and $role = 'deputyMinister'"></xsl:when>
      <xsl:when test="$country = 'BG' and $role = 'deputyPrimeMinister'">government</xsl:when>
      <xsl:when test="$country = 'BG' and $role = 'chairman'"></xsl:when>
      <xsl:when test="$country = 'BG' and $role = 'viceChairman'"></xsl:when>
      <xsl:when test="$country = 'BG' and $role = 'presidentEP'"></xsl:when>
      <xsl:when test="$country = 'BG' and $role = 'secretary'"></xsl:when>
      <xsl:when test="$country = 'BG' and $role = 'headOfDepartment'"></xsl:when>
      <xsl:when test="$country = 'BG' and $role = 'deputyChief'"></xsl:when>
      <xsl:when test="$country = 'BG' and $role = 'director'"></xsl:when>
      <xsl:when test="$country = 'BG' and $role = 'viceDirector'"></xsl:when>
      <xsl:when test="$country = 'BG' and $role = 'candidateChairman'"></xsl:when>
      <xsl:when test="$country = 'BG' and $role = 'ombudsman'"></xsl:when>
      <xsl:when test="$country = 'BG' and $role = 'secretaryGeneral'"></xsl:when>
      <xsl:when test="$country = 'BG' and $role = 'prosecutorGeneral'"></xsl:when>
      <xsl:when test="$country = 'BG' and $role = 'vicePresident'"></xsl:when>
      <xsl:when test="$country = 'BG' and $role = 'constitutionalJudge'"></xsl:when>
      <xsl:when test="$country = 'BG' and $role = 'president'"></xsl:when>
      <xsl:when test="$country = 'BG' and $role = 'chiefInspector'"></xsl:when>
      <xsl:when test="$country = 'BG' and $role = 'commander'"></xsl:when>

      <xsl:when test="$country = 'DK' and $role = 'chairman'">parliament</xsl:when>
      <xsl:when test="$country = 'DK' and $role = 'viceChairman'">parliament</xsl:when>
      <xsl:when test="$country = 'DK' and $role = 'minister'">government</xsl:when>
      <xsl:when test="$country = 'DK' and $role = 'deputyMinister'">government</xsl:when>
      <xsl:when test="$country = 'DK' and $role = 'primeMinister'">government</xsl:when>

      <xsl:when test="$country = 'HR' and $role = 'MP'">parliament</xsl:when>

      <xsl:when test="$country = 'LT' and $role = 'chairperson'">parliament</xsl:when>
      <xsl:when test="$country = 'LT' and $role = 'viceChairman'">parliament</xsl:when>
      <xsl:when test="$country = 'LT' and $role = 'leader'"></xsl:when>

      <xsl:when test="$country = 'NL' and $role = 'chairperson'">parliament</xsl:when>
      <xsl:when test="$country = 'NL' and $role = 'primeMinister'">government</xsl:when>
      <xsl:when test="$country = 'NL' and $role = 'minister'">government</xsl:when>
      <xsl:when test="$country = 'NL' and $role = 'secretary'"></xsl:when>

      <xsl:when test="$country = 'PL' and $role = 'MP'">parliament</xsl:when>


      <xsl:when test="$role = 'MP'">parliament</xsl:when>
      <xsl:when test="$role = 'minister'">government</xsl:when>

      <xsl:otherwise>
        <xsl:text></xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="mk:affiliation-implicated-role">
    <xsl:param name="role"/>
    <xsl:param name="orgrole"/>
    <xsl:choose>
      <!-- parliament -->
      <xsl:when test="$role='president' and $orgrole='parliament'">member</xsl:when>
      <xsl:when test="$role='vicePresident' and $orgrole='parliament'">member</xsl:when>
      <!-- parliamentaryGroup -->
      <xsl:when test="$role='president' and $orgrole='parliamentaryGroup'">member</xsl:when>
      <xsl:when test="$role='vicePresident' and $orgrole='parliamentaryGroup'">member</xsl:when>
      <!-- government -->
      <xsl:when test="$role='president' and $orgrole='government'">member</xsl:when>
      <xsl:when test="$role='vicePresident' and $orgrole='government'">member</xsl:when>
      <xsl:when test="$role='minister' and $orgrole='government'">member</xsl:when>

      <!-- general organization - do nothing -->
      <xsl:otherwise><xsl:text/></xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="mk:affiliation-implicated-role-existence" as="node()*">
    <xsl:param name="person" as="node()"/>
    <xsl:param name="role"/>
    <xsl:param name="ref"/>
    <xsl:param name="from"/>
    <xsl:param name="to"/>
    <xsl:sequence select="$person/tei:affiliation[@role=$role and @ref=$ref and (($from >= mk:get_from(.) and mk:get_to(.) >= $from) or ($to >= mk:get_from(.) and mk:get_to(.) >= $to))]"/>
  </xsl:function>

  <xsl:function name="mk:affiliation-role-patch">
    <xsl:param name="role"/>
    <xsl:param name="orgrole"/>
    <xsl:choose>
      <!-- parliament -->
      <xsl:when test="contains(' president chairman ', mk:borders($role)) and $orgrole='parliament'">president</xsl:when>
      <xsl:when test="contains(' vicePresident viceChairman ', mk:borders($role)) and $orgrole='parliament'">vicePresident</xsl:when>
      <!-- parliamentaryGroup -->
      <xsl:when test="contains(' president chairman chairperson ', mk:borders($role)) and $orgrole='parliamentaryGroup'">president</xsl:when>
      <xsl:when test="contains(' vicePresident viceChairman ', mk:borders($role)) and $orgrole='parliamentaryGroup'">vicePresident</xsl:when>
      <!-- government -->
      <xsl:when test="contains(' president chairman primeMinister ', mk:borders($role)) and $orgrole='government'">president</xsl:when>
      <xsl:when test="contains(' vicePresident viceChairman deputyPrimeMinister ', mk:borders($role)) and $orgrole='government'">vicePresident</xsl:when>

      <!-- general organization - do nothing -->
      <xsl:otherwise><xsl:value-of select="$role"/></xsl:otherwise>
    </xsl:choose>
  </xsl:function>

</xsl:stylesheet>
