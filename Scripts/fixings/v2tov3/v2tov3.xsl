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
  <xsl:output indent="yes"/>
  <xsl:strip-space elements="*"/>
  <xsl:preserve-space elements="tei:change tei:seg"/>

  <xsl:param name="version">3.0a</xsl:param>
  <xsl:param name="change">
    <change when="{$today-iso}"><name>Matyáš Kopp</name>: Fixes for Version 3.</change>
  </xsl:param>
  <xsl:variable name="today-iso" select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>
  <xsl:variable name="id" select="replace(document-uri(/), '.+/([^/]+)\.xml', '$1')"/>
  <xsl:variable name="lang" select="/tei:*/@xml:lang"/>
  <xsl:variable name="country" select="replace($id, 'ParlaMint-([^._]+).*', '$1')"/>

  <xsl:variable name="type">
    <xsl:choose>
      <xsl:when test="matches($id, '^ParlaMint-..\.ana$')">ana</xsl:when>
      <xsl:when test="matches($id, '^ParlaMint-..$')">txt</xsl:when>
      <xsl:when test="matches($id, '^ParlaMint-.._.+\.ana$')">ana</xsl:when>
      <xsl:when test="matches($id, '^ParlaMint-.._.+$')">txt</xsl:when>
      <xsl:otherwise>
	<xsl:message select="concat('ERROR ', $id, ': bad root ID ', $id)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <xsl:template match="/">
    <!--xsl:message>
      <xsl:text>INFO: converting </xsl:text>
      <xsl:value-of select="tei:*/@xml:id"/>
    </xsl:message-->
    <!--xsl:text>&#10;</xsl:text-->
    <xsl:apply-templates/>
  </xsl:template>

  <!-- STAMP -->
  <xsl:template match="tei:editionStmt/tei:edition">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:value-of select="$version"/>
    </xsl:copy>
  </xsl:template>


  <xsl:template match=" tei:idno[@type='URI' and @subtype='wikimedia' and contains(./text(), 'wikipedia.org')] | tei:idno[@type='URI' and @subtype and contains(./text(), concat(@subtype,'.') ) ] | tei:idno[@type='URI' and not(@subtype) and contains(./text(), 'github.com' ) ] ">
    <xsl:copy>
      <xsl:apply-templates select="@* | * | text() | comment()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:idno[not(text())]">
    <xsl:message>
      <xsl:text>ERROR: empty string in idno: </xsl:text> <xsl:apply-templates select="." mode="serialize"/>
    </xsl:message>
    <xsl:next-match/>
  </xsl:template>

  <xsl:template match="tei:bibl/tei:idno[contains(./text(), 'parlametar.bg') and $country='BG']">
    <xsl:message>
      <xsl:text>INFO: removing parlameter idno: </xsl:text> <xsl:apply-templates select="." mode="serialize"/>
    </xsl:message>
  </xsl:template>

  <xsl:template match="tei:idno[$country='IS' and text() = 'www.athingi.is']">
    <xsl:message>
      <xsl:text>INFO: fixing idno url: </xsl:text> <xsl:apply-templates select="." mode="serialize"/>
    </xsl:message>
    <idno type="URI" subtype="parliament">https://www.althingi.is/</idno>
  </xsl:template>

  <xsl:template match="tei:idno">
    <xsl:copy>
      <xsl:apply-templates select="@*[not(contains(' type subtype ', local-name()))]"/>
      <xsl:if test="@type and @type=upper-case(@type) and not(contains(' URI URL ', @type))">
        <xsl:message>
          <xsl:text>ERROR: unexpected value idno/@type=</xsl:text> <xsl:value-of select="@type"/>
        </xsl:message>
      </xsl:if>
      <xsl:attribute name="type">URI</xsl:attribute>
      <xsl:choose>
        <!-- BE -->
        <xsl:when test="$country='BE' and contains(./text(), 'www.dekamer.be')">
          <xsl:attribute name="subtype">parliament</xsl:attribute>
        </xsl:when>
        <xsl:when test="$country='BE' and contains(./text(), 'wikipedia.org')">
          <xsl:attribute name="subtype">wikimedia</xsl:attribute>
        </xsl:when>

        <!-- BG -->
        <xsl:when test="$country='BG' and contains(./text(), 'parliament.bg')">
          <xsl:attribute name="subtype">parliament</xsl:attribute>
        </xsl:when>
        <xsl:when test="$country='BG' and contains(./text(), 'parlametar.bg') and ./parent::tei:bibl">
          <xsl:message>
            <xsl:text>ERROR: parlametar should be removes</xsl:text> <xsl:apply-templates select="./parent::*" mode="serialize"/>
          </xsl:message>
        </xsl:when>
        <xsl:when test="$country='BG' and (contains(./text(), 'government.bg') or contains(./text(), 'comdos.bg'))">
          <xsl:message>
            <xsl:text>WARN: removing idno/@subtype </xsl:text> <xsl:apply-templates select="." mode="serialize"/>
          </xsl:message>
        </xsl:when>
        <xsl:when test="$country='BG' and (contains(./text(), 'kalinveliov.com') or contains(./text(), 'aop.bg/'))">
          <xsl:message>
            <xsl:text>WARN: no subtype</xsl:text>
          </xsl:message>
        </xsl:when>
        <!-- CZ -->
        <xsl:when test="$country='CZ' and contains(./text(), 'psp.cz')">
          <xsl:attribute name="subtype">parliament</xsl:attribute>
        </xsl:when>
        <xsl:when test="$country='CZ' and contains(./text(), 'vlada.cz')">
          <xsl:attribute name="subtype">government</xsl:attribute>
        </xsl:when>
        <xsl:when test="$country='CZ' and contains(./text(), 'github') and @type='URL'"/>
        <xsl:when test="$country='CZ' and @subtype='personal'">
          <!-- no fixture - just copy attribute -->
          <xsl:apply-templates select="@subtype"/>
        </xsl:when>

        <!-- DK -->
        <xsl:when test="$country='DK' and contains(./text(), 'www.ft.dk')">
          <xsl:attribute name="subtype">parliament</xsl:attribute>
        </xsl:when>
        <xsl:when test="$country='DK' and contains(./text(), 'wikipedia.org')">
          <xsl:attribute name="subtype">wikimedia</xsl:attribute>
        </xsl:when>

        <!-- ES -->
        <xsl:when test="$country='ES' and contains(./text(), 'www.congreso.es')">
          <xsl:attribute name="subtype">parliament</xsl:attribute>
        </xsl:when>

        <!-- FR -->
        <xsl:when test="$country='FR' and contains(./text(), 'assemblee-nationale.fr')">
          <xsl:attribute name="subtype">parliament</xsl:attribute>
        </xsl:when>
        <xsl:when test="$country='FR' and contains(./text(), 'wikipedia.org')">
          <xsl:attribute name="subtype">wikimedia</xsl:attribute>
        </xsl:when>

        <!-- GB -->
        <xsl:when test="$country='GB' and contains(./text(), 'parliament.uk')"> <!-- [hansard-api,hansard,members].parliament.uk -->
          <xsl:attribute name="subtype">parliament</xsl:attribute>
        </xsl:when>

        <!-- HR -->
        <xsl:when test="$country='HR' and contains(./text(), 'www.sabor.hr')">
          <xsl:attribute name="subtype">parliament</xsl:attribute>
        </xsl:when>
        <xsl:when test="$country='HR' and contains(./text(), 'https://parlametar.hr')">
          <xsl:attribute name="subtype">bussiness</xsl:attribute>
        </xsl:when>

        <!-- HU skipping-->

        <!-- IS -->
        <xsl:when test="$country='IS' and contains(./text(),'althingi.is')">
          <xsl:attribute name="subtype">parliament</xsl:attribute>
        </xsl:when>
        <xsl:when test="$country='IS' and contains(./text(), 'wikipedia.org')">
          <xsl:attribute name="subtype">wikimedia</xsl:attribute>
        </xsl:when>

        <!-- IT -->
        <xsl:when test="$country='IT' and contains(./text(), 'senato.it')">
          <xsl:attribute name="subtype">parliament</xsl:attribute>
        </xsl:when>
        <xsl:when test="$country='IT' and contains(./text(), 'wikipedia.org')">
          <xsl:attribute name="subtype">wikimedia</xsl:attribute>
        </xsl:when>

        <!-- LT -->
        <xsl:when test="$country='LT' and contains(./text(), 'lrs.lt')">
          <xsl:attribute name="subtype">parliament</xsl:attribute>
        </xsl:when>
        <xsl:when test="$country='LT' and contains(./text(), 'wikipedia.org')">
          <xsl:attribute name="subtype">wikimedia</xsl:attribute>
        </xsl:when>

        <!-- LV -->
        <xsl:when test="$country='LV' and contains(./text(), 'www.saeima.lv')">
          <xsl:attribute name="subtype">parliament</xsl:attribute>
        </xsl:when>
        <xsl:when test="$country='LV' and contains(./text(), 'wikipedia.org')">
          <xsl:attribute name="subtype">wikimedia</xsl:attribute>
        </xsl:when>

        <!-- NL -->
        <xsl:when test="$country='NL' and contains(./text(), 'www.eerstekamer.nl')">
          <xsl:attribute name="subtype">parliament</xsl:attribute>
        </xsl:when>
        <xsl:when test="$country='NL' and contains(./text(), 'www.tweedekamer.nl')">
          <xsl:attribute name="subtype">parliament</xsl:attribute>
        </xsl:when>
        <xsl:when test="$country='NL' and contains(./text(), 'wikipedia.org')">
          <xsl:attribute name="subtype">wikimedia</xsl:attribute>
        </xsl:when>

        <!-- PL -->
        <xsl:when test="$country='PL' and contains(./text(), 'www.senat.gov.pl')">
          <xsl:attribute name="subtype">parliament</xsl:attribute>
        </xsl:when>
        <xsl:when test="$country='PL' and contains(./text(), 'www.sejm.gov.pl')">
          <xsl:attribute name="subtype">parliament</xsl:attribute>
        </xsl:when>

        <!-- SI -->
        <xsl:when test="$country='SI' and contains(./text(), 'www.dz-rs.si')">
          <xsl:attribute name="subtype">parliament</xsl:attribute>
        </xsl:when>

        <!-- TR -->
        <xsl:when test="$country='TR' and contains(./text(), 'www.tbmm.gov.tr')">
          <xsl:attribute name="subtype">parliament</xsl:attribute>
        </xsl:when>
        <xsl:when test="$country='TR' and contains(./text(), 'wikidata.org')">
          <xsl:attribute name="subtype">wikidata</xsl:attribute>
        </xsl:when>
        <xsl:when test="$country='TR' and contains(./text(), 'wikipedia.org')">
          <xsl:attribute name="subtype">wikimedia</xsl:attribute>
        </xsl:when>

        <!-- no country specific fix -->
        <xsl:when test="contains(' wikidata facebook twitter tiktok instagram ',concat(' ',@type,' '))">
          <xsl:message><xsl:text>WARN: ussing all lang patch (orgs) idno/@subtype </xsl:text> <xsl:apply-templates select="." mode="serialize"/></xsl:message>
          <xsl:attribute name="subtype" select="@type"/>
        </xsl:when>
        <xsl:when test="contains(concat(' ',@sub,' ',@subtype), ' wiki') and @subtype != 'wikimedia'">
          <xsl:message><xsl:text>WARN: ussing all lang patch (wiki) idno/@subtype </xsl:text> <xsl:apply-templates select="." mode="serialize"/></xsl:message>
          <xsl:attribute name="subtype">wikimedia</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message terminate="no"><xsl:text>ERROR otherwise </xsl:text> <xsl:value-of select="$country"/><xsl:text> </xsl:text><xsl:apply-templates select="." mode="serialize"/></xsl:message>
          <!-- no fixture - just copy attribute -->
          <xsl:apply-templates select="@subtype"/>
        </xsl:otherwise>
      </xsl:choose>
      <!--xsl:attribute name="subtype" select="@type"/-->
      <xsl:value-of select="."/>
    </xsl:copy>
  </xsl:template>


  <!-- Fixing affiliations -->
  <xsl:template match="tei:affiliation[not(text()) and not(@ref)]">
    <xsl:choose>
      <xsl:when test="@role='member'"><!-- BG -->
        <xsl:message>
          <xsl:text>INFO: removing senseless affiliation (missing ref and text): </xsl:text> <xsl:apply-templates select="." mode="serialize"/>
        </xsl:message>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="orgRole" select="mk:person_role_to_org_role(./@role)"/>
        <xsl:variable name="org" select="./ancestor::tei:particDesc/tei:listOrg/tei:org[@role=$orgRole and @xml:id]"/>
        <xsl:choose>
          <xsl:when test="$orgRole=''">
            <xsl:message><xsl:value-of select="concat('ERROR: ',./@role,' does not have implicit organization - impossible to determine correct affiliation')"/></xsl:message>
            <xsl:comment>removing affiliation - unable to determine @ref: <xsl:apply-templates select="." mode="serialize"/></xsl:comment>
          </xsl:when>
          <xsl:when test="count($org) = 1">
            <xsl:message>
              <xsl:value-of select="concat('INFO: adding reference to ',$orgRole, ' affiliation/@ref=#',$org/@xml:id,' to ')"/>
              <xsl:apply-templates select="." mode="serialize"/>
            </xsl:message>
            <xsl:copy>
              <xsl:apply-templates select="@*[name() != 'ana']"/>
              <xsl:attribute name="ref">#<xsl:value-of select="$org/@xml:id"/></xsl:attribute>
              <xsl:call-template name="affiliation-ana"><xsl:with-param name="ref" select="concat('#',$org/@xml:id)"/></xsl:call-template>
            </xsl:copy>
          </xsl:when>
          <xsl:when test="count($org)>1">
            <!-- NL-parliament -->
            <xsl:message><xsl:value-of select="concat('ERROR: ',count($org),' ',$orgRole,' organizations - impossible to determine correct affiliation')"/></xsl:message>
            <xsl:comment>removing affiliation - unable to determine @ref (multiple <xsl:value-of select="$orgRole"/> org): <xsl:apply-templates select="." mode="serialize"/></xsl:comment>
          </xsl:when>
          <xsl:otherwise>
            <!-- PL - missing parliament organization-->
            <xsl:message><xsl:value-of select="concat('ERROR: missing ',$orgRole,' organization')"/></xsl:message>
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
          <xsl:apply-templates select="@*"/>
          <xsl:attribute name="ref">#NS</xsl:attribute>
          <xsl:call-template name="affiliation-ana"><xsl:with-param name="ref" select="'#NS'"/></xsl:call-template>
        </xsl:copy>
        <xsl:message>INFO: adding @ref='#NS' and removing text from <xsl:value-of select="@role"/> (<xsl:value-of select="text()"/>) affiliation</xsl:message>
      </xsl:when>
      <xsl:when test="$country = 'BG' and @role='primeMinister' and text()='Министър-председател'">
        <xsl:copy>
          <xsl:apply-templates select="@*"/>
          <xsl:attribute name="ref">#gov.IzvSv</xsl:attribute>
          <xsl:call-template name="affiliation-ana"><xsl:with-param name="ref" select="'#gov.IzvSv'"/></xsl:call-template>
        </xsl:copy>
        <xsl:message>INFO: adding @ref='#gov.IzvSv' and removing text from <xsl:value-of select="@role"/> (<xsl:value-of select="text()"/>) affiliation</xsl:message>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="orgRole" select="mk:person_role_to_org_role(./@role)"/>
        <xsl:variable name="org" select="./ancestor::tei:particDesc/tei:listOrg/tei:org[@role=$orgRole and @xml:id]"/>
        <xsl:choose>
          <xsl:when test="$orgRole=''">
            <xsl:message><xsl:value-of select="concat('ERROR: ',./@role,' does not have implicit organization - impossible to determine correct affiliation')"/></xsl:message>
            <xsl:comment>removing affiliation - unable to determine @ref: <xsl:apply-templates select="." mode="serialize"/></xsl:comment>
          </xsl:when>
          <xsl:when test="count($org) = 1">
            <xsl:message>
              <xsl:value-of select="concat('INFO: adding reference to ',$orgRole, ' affiliation/@ref=#',$org/@xml:id,' to ')"/>
              <xsl:apply-templates select="." mode="serialize"/>
            </xsl:message>
            <xsl:copy>
              <xsl:apply-templates select="@*[name() != 'ana']"/>
              <xsl:attribute name="ref">#<xsl:value-of select="$org/@xml:id"/></xsl:attribute>
              <xsl:call-template name="affiliation-ana"><xsl:with-param name="ref" select="concat('#',$org/@xml:id)"/></xsl:call-template>
              <xsl:comment><xsl:apply-templates select="./text()" mode="serialize"/></xsl:comment>
            </xsl:copy>
          </xsl:when>
          <xsl:when test="count($org)>1">
            <!-- NL-parliament -->
            <xsl:message><xsl:value-of select="concat('ERROR: ',count($org),' ',$orgRole,' organizations - impossible to determine correct affiliation')"/></xsl:message>
            <xsl:comment>removing affiliation - unable to determine @ref (multiple <xsl:value-of select="$orgRole"/> org): <xsl:apply-templates select="." mode="serialize"/></xsl:comment>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message><xsl:value-of select="concat('ERROR: missing ',$orgRole,' organization')"/></xsl:message>
            <xsl:comment>removing affiliation - unable to determine @ref (missing <xsl:value-of select="$orgRole"/> org): <xsl:apply-templates select="." mode="serialize"/></xsl:comment>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:affiliation[@ref]">
    <xsl:message>AFFILIATION <xsl:apply-templates select="." mode="serialize"/></xsl:message>
    <xsl:copy>
      <xsl:apply-templates select="@*[name() != 'ana']"/>
      <xsl:call-template name="affiliation-ana"><xsl:with-param name="ref" select="@ref"/></xsl:call-template>
    </xsl:copy>
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

<xsl:template match="@*" mode="serialize">
    <xsl:text> </xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:text>="</xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>"</xsl:text>
</xsl:template>

<xsl:template match="text()" mode="serialize">
    <xsl:value-of select="."/>
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
            <xsl:variable name="event" select="$org/tei:listEvent/tei:event[xs:date($from) >= xs:date(mk:get_from(.)) and xs:date(mk:get_to(.)) >= xs:date($to)]"/>
            <xsl:variable name="ana" select="concat('#',$event/@xml:id)"/>
            <xsl:choose>
              <xsl:when test="not(@ana)">
                <xsl:attribute name="ana">#<xsl:value-of select="$event/@xml:id"/></xsl:attribute>
                <xsl:message>INFO: adding corresponding event to @ana: <xsl:apply-templates select="$event" mode="serialize"/></xsl:message>
              </xsl:when>
              <xsl:when test="@ana != $ana">
                <xsl:message>WARN: fixing corresponding event in @ana from '<xsl:value-of select="./@ana"/>' to '<xsl:value-of select="$ana"/>' </xsl:message>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates select="@ana"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message>ERROR: unable to add corresponding event</xsl:message>
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

      <xsl:otherwise><xsl:message>ERROR: ===== <xsl:value-of select="$country"/> === unknown role: <xsl:value-of select="$role"/></xsl:message></xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="mk:get_from">
    <xsl:param name="node"/>
    <xsl:choose>
      <xsl:when test="$node/@from"><xsl:value-of select="$node/@from"/></xsl:when>
      <xsl:when test="$node/@when"><xsl:value-of select="$node/@from"/></xsl:when>
      <xsl:when test="$node and not($node/parent::tei:bibl/parent::tei:sourceDesc/parent::tei:fileDesc)">
        <xsl:value-of select="mk:get_from($node/ancestor::tei:teiHeader//tei:sourceDesc/tei:bibl[1]/tei:date)"/>
      </xsl:when>
      <xsl:otherwise>1900-01-01</xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="mk:get_to">
    <xsl:param name="node"/>
    <xsl:choose>
      <xsl:when test="$node/@to"><xsl:value-of select="$node/@to"/></xsl:when>
      <xsl:when test="$node/@when"><xsl:value-of select="$node/@to"/></xsl:when>
      <xsl:when test="$node and not($node/parent::tei:bibl/parent::tei:sourceDesc/parent::tei:fileDesc)">
        <xsl:value-of select="mk:get_to($node/ancestor::tei:teiHeader//tei:sourceDesc/tei:bibl[1]/tei:date)"/>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="$node/ancestor::tei:teiHeader//tei:publicationStmt/tei:date/@when"/></xsl:otherwise>
    </xsl:choose>
  </xsl:function>

</xsl:stylesheet>
