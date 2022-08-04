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


  <xsl:template match="tei:affiliation[not(@ref) or 
		       ($country = 'LV' and @role='MP') or ($country = 'NL' and @role='MP')]">
    <xsl:choose>
      <xsl:when test="@role='member' and not(text())">
        <xsl:call-template name="error">
          <xsl:with-param name="severity">INFO</xsl:with-param>
          <xsl:with-param name="msg">
	    <xsl:text>removing senseless affiliation (missing ref and text): </xsl:text>
	    <xsl:apply-templates select="." mode="serialize"/>
	  </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$country = 'BG' and text()='депутат'">
        <xsl:variable name="role" select="mk:affiliation-role-patch(@role,'parliament')"/>
        <xsl:copy>
          <xsl:apply-templates select="@*[not(name()='role')]"/>
          <xsl:attribute name="role"><xsl:value-of select="$role"/></xsl:attribute>
          <xsl:attribute name="ref">#NS</xsl:attribute>
          <xsl:call-template name="affiliation-ana">
	    <xsl:with-param name="ref" select="'#NS'"/>
	  </xsl:call-template>
          <xsl:call-template name="affiliation-roleName">
	    <xsl:with-param name="newRole" select="$role"/>
	    <xsl:with-param name="orgRole" select="'parliament'"/>
	  </xsl:call-template>
        </xsl:copy>
        <xsl:call-template name="error">
          <xsl:with-param name="severity">INFO</xsl:with-param>
          <xsl:with-param name="msg">
	    <xsl:text>adding @ref='#NS' and removing text from </xsl:text>
	    <xsl:value-of select="@role"/>
	    <xsl:text> (</xsl:text>
	    <xsl:value-of select="text()"/>
	    <xsl:text>) affiliation</xsl:text>
	  </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$country = 'BG' and @role='primeMinister' and text()='Министър-председател'">
        <xsl:variable name="role" select="mk:affiliation-role-patch(@role,'government')"/>
        <xsl:copy>
          <xsl:apply-templates select="@*[not(name()='role')]"/>
          <xsl:attribute name="role"><xsl:value-of select="$role"/></xsl:attribute>
          <xsl:attribute name="ref">#gov.IzvSv</xsl:attribute>
          <xsl:call-template name="affiliation-ana">
	    <xsl:with-param name="ref" select="'#gov.IzvSv'"/>
	  </xsl:call-template>
          <xsl:call-template name="affiliation-roleName">
	    <xsl:with-param name="newRole" select="$role"/>
	    <xsl:with-param name="orgRole" select="'government'"/>
	  </xsl:call-template>
        </xsl:copy>
        <xsl:call-template name="error">
          <xsl:with-param name="severity">INFO</xsl:with-param>
          <xsl:with-param name="msg">
	    <xsl:text> adding @ref='#gov.IzvSv' and removing text from </xsl:text>
	    <xsl:value-of select="@role"/>
	    <xsl:text> (</xsl:text>
	    <xsl:value-of select="text()"/>
	    <xsl:text>) affiliation</xsl:text>
	  </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="orgRole" select="mk:person_role_to_org_role(./@role)"/>
        <xsl:variable name="org" select="./ancestor::tei:particDesc/tei:listOrg/
					 tei:org[@role=$orgRole and @xml:id]"/>
        <xsl:choose>
          <xsl:when test="$orgRole=''">
            <xsl:call-template name="error">
              <xsl:with-param name="severity">ERROR</xsl:with-param>
              <xsl:with-param name="msg">
	        <xsl:value-of select="./@role"/>
	        <xsl:text> does not have implicit organization - impossible to determine correct affiliation</xsl:text>
	      </xsl:with-param>
            </xsl:call-template>
            <xsl:comment>
	      <xsl:text>removing affiliation - unable to determine @ref: </xsl:text>
	      <xsl:apply-templates select="." mode="serialize"/>
	    </xsl:comment>
          </xsl:when>
          <xsl:when test="count($org) = 1">
            <xsl:variable name="role" select="mk:affiliation-role-patch(@role,$org/@role)"/>
            <xsl:call-template name="error">
              <xsl:with-param name="severity">INFO</xsl:with-param>
              <xsl:with-param name="msg">adding reference to <xsl:value-of select="$orgRole"/> affiliation/@ref=#<xsl:value-of select="$org/@xml:id"/> to <xsl:apply-templates select="." mode="serialize"/></xsl:with-param>
            </xsl:call-template>
            <xsl:copy>
              <xsl:apply-templates select="@*[name() != 'ana' and name() != 'role']"/>
              <xsl:attribute name="role"><xsl:value-of select="$role"/></xsl:attribute>
              <xsl:attribute name="ref">#<xsl:value-of select="$org/@xml:id"/></xsl:attribute>
              <xsl:call-template name="affiliation-ana"><xsl:with-param name="ref" select="concat('#',$org/@xml:id)"/></xsl:call-template>
              <xsl:if test="text()"><xsl:comment><xsl:apply-templates select="./text()" mode="serialize"/></xsl:comment></xsl:if>
              <xsl:call-template name="affiliation-roleName"><xsl:with-param name="newRole" select="$role"/><xsl:with-param name="orgRole" select="$orgRole"/></xsl:call-template>
            </xsl:copy>
            <xsl:variable name="implied-role" select="mk:affiliation-implied-role($role,$orgRole)"/>
            <xsl:if test="not($implied-role='')">
              <xsl:variable name="implied-affiliation" select="mk:affiliation-implied-role-existence(./parent::tei:person,$implied-role, concat('#',$org/@xml:id), mk:get_from(.), mk:get_to(.))"/>
              <xsl:choose>
                <xsl:when test="$implied-affiliation">
                  <xsl:call-template name="error">
                    <xsl:with-param name="severity">INFO</xsl:with-param>
                    <xsl:with-param name="msg">implied affiliation(role='<xsl:value-of select="$implied-role"/>') exists</xsl:with-param>
                  </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:call-template name="error">
                    <xsl:with-param name="severity">INFO</xsl:with-param>
                    <xsl:with-param name="msg">adding implied affiliation(role='<xsl:value-of select="$implied-role"/>') to '<xsl:value-of select="$orgRole"/>'</xsl:with-param>
                  </xsl:call-template>
                  <xsl:copy>
                    <xsl:apply-templates select="@*[name() != 'ana' and name() != 'role']"/>
                    <xsl:attribute name="ref">#<xsl:value-of select="$org/@xml:id"/></xsl:attribute>
                    <xsl:attribute name="role"><xsl:value-of select="$implied-role"/></xsl:attribute>
                    <xsl:call-template name="affiliation-ana"><xsl:with-param name="ref" select="concat('#',$org/@xml:id)"/></xsl:call-template>
                    <xsl:call-template name="affiliation-roleName"><xsl:with-param name="newRole" select="$implied-role"/><xsl:with-param name="orgRole" select="$orgRole"/></xsl:call-template>
                  </xsl:copy>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:if>
          </xsl:when>
          <xsl:when test="count($org)>1">
            <!-- NL-parliament -->
            <xsl:call-template name="error">
              <xsl:with-param name="severity">ERROR</xsl:with-param>
              <xsl:with-param name="msg"><xsl:value-of select="count($org)"/> <xsl:value-of select="$orgRole"/> organizations - impossible to determine correct affiliation</xsl:with-param>
            </xsl:call-template>
            <xsl:comment>removing affiliation - unable to <xsl:choose><xsl:when test="@ref">fix</xsl:when><xsl:otherwise>determine</xsl:otherwise></xsl:choose> @ref (multiple <xsl:value-of select="$orgRole"/> org): <xsl:apply-templates select="." mode="serialize"/></xsl:comment>
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

  <xsl:template match="tei:affiliation[$country = 'IS' and matches(@ref,'^#GOV_LV.[0-9]*$')]">
    <xsl:variable name="ref" select="@ref"/>
    <xsl:variable name="role" select="mk:affiliation-role-patch(@role,'government')"/>
    <xsl:variable name="implied-role" select="mk:affiliation-implied-role($role,'government')"/>
    <xsl:copy>
      <xsl:apply-templates select="@role"/>
      <xsl:attribute name="ref">#GOV_LV</xsl:attribute>
      <xsl:apply-templates select="@from"/>
      <xsl:apply-templates select="@to"/>
      <xsl:attribute name="ana" select="normalize-space(concat(@ref,' ',@ana))"/>
      <xsl:call-template name="affiliation-roleName"><xsl:with-param name="newRole" select="$role"/><xsl:with-param name="orgRole" select="'government'"/></xsl:call-template>
    </xsl:copy>
    <xsl:copy>
      <xsl:attribute name="role" select="$implied-role"/>
      <xsl:attribute name="ref">#GOV_LV</xsl:attribute>
      <xsl:apply-templates select="@from"/>
      <xsl:apply-templates select="@to"/>
      <xsl:attribute name="ana" select="@ref"/>
      <xsl:call-template name="affiliation-roleName"><xsl:with-param name="newRole" select="$implied-role"/><xsl:with-param name="orgRole" select="'government'"/></xsl:call-template>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:affiliation[$country = 'IT' and matches(@ref,'^#GOV\.[A-Z]*\.[0-9]*$')]">
    <xsl:variable name="ref" select="@ref"/>
    <xsl:variable name="role" select="mk:affiliation-role-patch(@role,'government')"/>
    <xsl:variable name="implied-role" select="mk:affiliation-implied-role($role,'government')"/>
    <xsl:copy>
      <xsl:apply-templates select="@role"/>
      <xsl:attribute name="ref">#GOV</xsl:attribute>
      <xsl:apply-templates select="@from"/>
      <xsl:apply-templates select="@to"/>
      <xsl:attribute name="ana" select="@ref"/>
      <xsl:call-template name="affiliation-roleName"><xsl:with-param name="newRole" select="$role"/><xsl:with-param name="orgRole" select="'government'"/></xsl:call-template>
    </xsl:copy>
    <xsl:if test="not($implied-role='')">
      <xsl:copy>
        <xsl:attribute name="role" select="$implied-role"/>
        <xsl:attribute name="ref">#GOV</xsl:attribute>
        <xsl:apply-templates select="@from"/>
        <xsl:apply-templates select="@to"/>
        <xsl:attribute name="ana" select="@ref"/>
        <xsl:call-template name="affiliation-roleName"><xsl:with-param name="newRole" select="$implied-role"/><xsl:with-param name="orgRole" select="'government'"/></xsl:call-template>
      </xsl:copy>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:affiliation[@ref and not($country = 'LV' and @role='MP') and not($country = 'NL' and @role='MP') and not($country = 'IS' and matches(@ref,'^#GOV_LV.[0-9]*$')) and not($country = 'IT' and matches(@ref,'^#GOV\.[A-Z]*\.[0-9]*$'))]">
    <xsl:variable name="ref" select="@ref"/>
    <xsl:variable name="orgRole" select="./ancestor::tei:particDesc/tei:listOrg/tei:org[@xml:id=substring-after($ref,'#')]/@role"/>
    <xsl:variable name="role" select="mk:affiliation-role-patch(@role,$orgRole)"/>
    <xsl:variable name="implied-role" select="mk:affiliation-implied-role($role,$orgRole)"/>
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="not(@ana)">
        <xsl:call-template name="affiliation-ana"><xsl:with-param name="ref" select="@ref"/></xsl:call-template>
      </xsl:if>
      <xsl:call-template name="affiliation-roleName"><xsl:with-param name="newRole" select="$role"/><xsl:with-param name="orgRole" select="$orgRole"/></xsl:call-template>
    </xsl:copy>
    <xsl:if test="not($implied-role='')">
      <xsl:variable name="implied-affiliation" select="mk:affiliation-implied-role-existence(./parent::tei:person,$implied-role, $ref, mk:get_from(.), mk:get_to(.))"/>
      <xsl:choose>
        <xsl:when test="$implied-affiliation">
          <xsl:call-template name="error">
            <xsl:with-param name="severity">INFO</xsl:with-param>
            <xsl:with-param name="msg">implied affiliation(role='<xsl:value-of select="$implied-role"/>') exists</xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="error">
            <xsl:with-param name="severity">INFO</xsl:with-param>
            <xsl:with-param name="msg">adding implied affiliation(role='<xsl:value-of select="$implied-role"/>') to '<xsl:value-of select="$orgRole"/>'</xsl:with-param>
          </xsl:call-template>
          <xsl:copy>
            <xsl:apply-templates select="@*[name() != 'role']"/>
            <xsl:attribute name="role"><xsl:value-of select="$implied-role"/></xsl:attribute>
            <xsl:if test="not(@ana)">
              <xsl:call-template name="affiliation-ana"><xsl:with-param name="ref" select="$ref"/></xsl:call-template>
            </xsl:if>
            <xsl:call-template name="affiliation-roleName"><xsl:with-param name="newRole" select="$implied-role"/><xsl:with-param name="orgRole" select="$orgRole"/></xsl:call-template>
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
    <xsl:variable name="orgRole" select="./ancestor::tei:particDesc/tei:listOrg/tei:org[.//@xml:id=substring-after($ref,'#')]/@role"/> <!-- use organization id or any descendatn(usually event) -->
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

  <xsl:template match="tei:org[$country = 'SI' and @role='independent' and @xml:id='party.NeP']" priority="1"/>
  <xsl:template match="tei:affiliation[$country = 'SI' and @ref='#party.NeP']" priority="1"/>

  <xsl:template match="tei:org[$country = 'GR' and @role='independent' and @xml:id='party.ΑΝΕΞΑΡΤΗΤΟΙ_ΕΚΤΟΣ_ΚΟΜΜΑΤΟΣ']" priority="1"/>
  <xsl:template match="tei:affiliation[$country = 'GR' and @ref='#party.ΑΝΕΞΑΡΤΗΤΟΙ_ΕΚΤΟΣ_ΚΟΜΜΑΤΟΣ']" priority="1"/>

  <xsl:template match="tei:org[$country = 'GR' and @role='independent' and @xml:id='party.ΕΞΩΚΟΙΝΟΒΟΥΛΕΥΤΙΚΟΣ']" priority="1"/>
  <xsl:template match="tei:affiliation[$country = 'GR' and @ref='#party.ΕΞΩΚΟΙΝΟΒΟΥΛΕΥΤΙΚΟΣ']" priority="1"/>

  <xsl:template match="tei:org">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="@role='parliament'">
        <xsl:variable name="ana">
          <xsl:choose>
            <xsl:when test="contains(' BE FR ',mk:borders($country))">#parla.national #parla.lower</xsl:when>
            <xsl:when test="contains('  ',mk:borders($country))">#parla.national #parla.upper</xsl:when>
            <xsl:when test="contains(' BG DK GR IS LT LV TR ',mk:borders($country))">#parla.national #parla.uni</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:if test="$ana != ''">
          <xsl:attribute name="ana" select="$ana"/>
        </xsl:if>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>


  <xsl:template match="@role[./parent::tei:org]" priority="1">
    <xsl:attribute name="role">
      <xsl:choose>
	<!-- do not fix bicameral with both houses -->
        <xsl:when test="($country = 'GB' or $country = 'NL' or $country = 'PL') and . = 'politicalParty'">
          <xsl:value-of select="."/>
        </xsl:when>
        <xsl:when test="not($country = 'CZ') and . = 'politicalParty'">parliamentaryGroup</xsl:when>
        <xsl:when test="$country = 'SI' and . = 'independent'">parliamentaryGroup</xsl:when>
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
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template name="affiliation-roleName">
    <xsl:param name="newRole"><xsl:value-of select="./@role"/></xsl:param>
    <xsl:param name="orgRole"/>
    <xsl:variable name="roleName" select="mk:affiliation-roleName-default(@role, $newRole, $orgRole)"/>
    <xsl:choose>
      <!-- copy current roleName elements -->
      <xsl:when test="tei:roleName">
        <xsl:apply-templates select="tei:roleName"/>
      </xsl:when>
      <!-- copy text content into roleName element -->
      <xsl:when test="normalize-space(text())">
        <xsl:element name="roleName"><xsl:value-of select="text()"/></xsl:element>
      </xsl:when>
      <!-- use default value if any -->
      <xsl:when test="$roleName">
        <xsl:element name="roleName">
          <xsl:attribute name="xml:lang">en</xsl:attribute>
          <xsl:value-of select="$roleName"/>
        </xsl:element>
      </xsl:when>
    </xsl:choose>
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

  <xsl:function name="mk:affiliation-implied-role">
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

  <xsl:function name="mk:affiliation-implied-role-existence" as="node()*">
    <xsl:param name="person" as="node()"/>
    <xsl:param name="role"/>
    <xsl:param name="ref"/>
    <xsl:param name="from"/>
    <xsl:param name="to"/>
    <xsl:sequence select="$person/tei:affiliation[mk:affiliation-role-patch(@role,'')=$role and @ref=$ref and $from >= mk:get_from(.) and mk:get_to(.) >= $to]"/>
  </xsl:function>

  <xsl:function name="mk:affiliation-role-patch">
    <xsl:param name="role"/>
    <xsl:param name="orgrole"/>
    <xsl:choose>
      <!-- government - specific -->
      <xsl:when test="contains(' primeMinister ', mk:borders($role)) and $orgrole='government'">head</xsl:when>
      <xsl:when test="contains(' deputyPrimeMinister ', mk:borders($role)) and $orgrole='government'">deputyHead</xsl:when>
      <xsl:when test="contains(' ministerOfState ', mk:borders($role)) and $orgrole='government'">minister</xsl:when>

      <!-- ministry - specific -->
      <xsl:when test="contains(' deputyMinister ', mk:borders($role)) and $orgrole='ministry'">minister</xsl:when>

      <xsl:when test="contains(' president chairman chairperson speaker headOfDelegation leader presidentEP director headOfDepartment chiefInspector commander ', mk:borders($role))">head</xsl:when>
      <xsl:when test="contains(' vicePresident viceChairman viceDirector deputyChief ', mk:borders($role))">deputyHead</xsl:when>
      <xsl:when test="contains(' MP presidiumMember ', mk:borders($role))">member</xsl:when>
      <xsl:when test="contains(' candidateMP ', mk:borders($role))">representative</xsl:when>
      <xsl:when test="contains(' substituteMP ', mk:borders($role))">replacement</xsl:when>

      <xsl:otherwise><xsl:value-of select="$role"/></xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="mk:affiliation-roleName-default">
    <xsl:param name="old"/>
    <xsl:param name="new"/>
    <xsl:param name="org"/>
    <xsl:choose>
      <xsl:when test="$org = 'parliament' and $new='member'">MP</xsl:when>
      <xsl:when test="$org != 'parliament' and $org and $new='member'">Member</xsl:when>
      <xsl:when test="$old = 'MP' and $new='member'">MP</xsl:when>
      <xsl:when test="$new = 'member'">Member</xsl:when>
      <xsl:when test="$old = 'presidiumMember'">Presidium Member</xsl:when>
      <xsl:when test="$old = 'president'">President</xsl:when>
      <xsl:when test="$old = 'chairman'">Chair Person</xsl:when>
      <xsl:when test="$old = 'chairperson'">Chair Person</xsl:when>
      <xsl:when test="$old = 'speaker'">Speaker</xsl:when>
      <xsl:when test="$old = 'headOfDelegation'">Head of Delegation</xsl:when>
      <xsl:when test="$old = 'leader'">Leader</xsl:when>
      <xsl:when test="$old = 'presidentEP'">President of EP</xsl:when>
      <xsl:when test="$old = 'primeMinister'">Prime Minister</xsl:when>
      <xsl:when test="$old = 'director'">Director</xsl:when>
      <xsl:when test="$old = 'headOfDepartment'">Head of Department</xsl:when>
      <xsl:when test="$old = 'chiefInspector'">Chief Inspector</xsl:when>
      <xsl:when test="$old = 'commander'">Commander</xsl:when>
      <xsl:when test="$old = 'vicePresident'">Vice President</xsl:when>
      <xsl:when test="$old = 'viceChairman'">Vice Chairman</xsl:when>
      <xsl:when test="$old = 'viceDirector'">Vice Director</xsl:when>
      <xsl:when test="$old = 'deputyChief'">Deputy Chief</xsl:when>
      <xsl:when test="$old = 'deputyPrimeMinister'">Deputy Prime Minister</xsl:when>
      <xsl:when test="$old = 'candidateMP'">Candidate MP</xsl:when>
      <xsl:when test="$old = 'minister'">Minister</xsl:when>
      <xsl:when test="$old = 'ministerOfState'">Minister of State</xsl:when>
      <xsl:when test="$old = 'deputyMinister'">Deputy Minister</xsl:when>
      <xsl:when test="$new = 'secretary'">Secretary</xsl:when>
      <xsl:when test="$old = 'substituteMP'">Substitute MP</xsl:when>
      <xsl:when test="$old = 'replacement'">Replacement</xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:function>
</xsl:stylesheet>
