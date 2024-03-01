<?xml version='1.0' encoding='UTF-8'?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:mk="http://ufal.mff.cuni.cz/matyas-kopp"
  exclude-result-prefixes="tei xs mk">

  <xsl:output method="xml" indent="yes"/>

  <xsl:template match="/">
    <xsl:apply-templates select="@*"/>
    <xsl:apply-templates/>
  </xsl:template>


  <xsl:template match="tei:person">
    <xsl:variable name="affiliations">
      <xsl:apply-templates select="* | comment() | text()" mode="affiliations"/>
    </xsl:variable>
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="* | comment() | text()" mode="person">
        <xsl:with-param name="affiliations" select="$affiliations"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>


  <xsl:template match="tei:*[not(name()='affiliation')] | comment() | text()" mode="person">
    <xsl:apply-templates select="."/>
  </xsl:template>

  <xsl:template match="tei:affiliation" mode="person">
    <xsl:param name="affiliations"/>
    <xsl:variable name="position" select="position()"/>
    <xsl:variable name="aff" select="$affiliations/tei:item[@n=$position]/tei:new/tei:affiliation[1]"/>
    <xsl:if test="not($affiliations/tei:item[@n=$position]/preceding-sibling::tei:item[mk:is-comparable($aff,tei:new/tei:affiliation[1]) and mk:is-overlapping($aff,tei:new/tei:affiliation[1])])">
      <xsl:copy-of select="$affiliations/tei:item[@n=$position]/tei:new/*"/>

    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:affiliation" mode="affiliations">
    <xsl:variable name="position" select="position()"/>
    <xsl:variable name="aff" select="."/>
    <xsl:variable name="similar-siblings" select="(preceding-sibling::tei:affiliation | following-sibling::tei:affiliation)[mk:is-comparable(.,$aff)]"/>
    <item n="{position()}">
      <orig>
        <xsl:copy>
          <xsl:apply-templates select="@*"/>
          <xsl:apply-templates/>
        </xsl:copy>
      </orig>
      <new>
        <xsl:apply-templates select="." mode="affiliation-extend">
          <xsl:with-param name="position" select="$position"/>
          <xsl:with-param name="extend-candidates" select="$similar-siblings"/>
        </xsl:apply-templates>
      </new>
    </item>
  </xsl:template>
  <xsl:template match="* | comment() | text()" mode="affiliations"/>

  <xsl:template match="tei:affiliation" mode="affiliation-extend">
    <xsl:param name="position"/>
    <xsl:param name="extend-candidates"/>
    <xsl:variable name="aff" select="."/>
    <xsl:variable name="extend">
      <xsl:apply-templates select="$aff" mode="affiliation-overlap">
        <xsl:with-param name="candidates" select="$extend-candidates"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="count($extend-candidates) = 0">
        <xsl:copy-of select="$aff"/>
      </xsl:when>
      <xsl:when test="$extend/tei:extend">
<!--
        <xsl:message>TODO EXTEND</xsl:message>
        <xsl:comment>TODO: check for duplicity</xsl:comment>

<xsl:message>CANDIDATES:<xsl:copy-of select="$extend-candidates"/></xsl:message>

<xsl:message>MERGE THIS:</xsl:message>
<xsl:message>AFFILIATION:<xsl:copy-of select="$aff"/></xsl:message>
<xsl:message>EXTEND:<xsl:copy-of select="$extend"/></xsl:message>
-->
        <xsl:variable name="aff-merged">
          <xsl:apply-templates select="$aff" mode="affiliation-merge">
            <xsl:with-param name="extend" select="$extend/tei:extend/*"/>
          </xsl:apply-templates>
        </xsl:variable>
        <!--
<xsl:message>MERGED===:<xsl:copy-of select="$aff-merged"/></xsl:message>
       -->
        <xsl:apply-templates select="$aff-merged" mode="affiliation-extend">
          <xsl:with-param name="position" select="$position"/>
          <xsl:with-param name="extend-candidates" select="$extend/tei:rest/*"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:comment>TODO: check for duplicity (fall back no other duplicity)</xsl:comment>
        <xsl:copy-of select="$aff"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:affiliation" mode="affiliation-overlap">
    <xsl:param name="candidates"/>
    <xsl:variable name="aff" select="."/>
    <xsl:variable name="first-aff" select="$candidates[1]"/>
    <xsl:choose>
      <xsl:when test="not($first-aff)"/>
      <xsl:when test="mk:is-overlapping($aff,$first-aff)">
        <extend><xsl:copy-of select="$first-aff"/></extend>
        <rest><xsl:copy-of select="$candidates[position()>1]"/></rest>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="sub-result">
          <xsl:apply-templates select="$aff" mode="affiliation-overlap">
            <xsl:with-param name="candidates" select="$candidates[position()>1]"/>
          </xsl:apply-templates>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$sub-result">
            <xsl:copy-of select="$sub-result/tei:extend"/>
            <rest>
              <xsl:copy-of select="$first-aff"/>
              <xsl:copy-of select="$sub-result/tei:rest/*"/>
            </rest>
          </xsl:when>
          <xsl:otherwise/><!--no extension => no output-->
        </xsl:choose>
      </xsl:otherwise>

    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:affiliation" mode="affiliation-merge">
    <xsl:param name="extend"/>
    <xsl:message>INFO: margin affiliations [<xsl:value-of select="./parent::tei:person/@xml:id"/>] role=<xsl:value-of select="@role"/> ref=<xsl:value-of select="@ref"/> ana=<xsl:value-of select="@ana"/>: (<xsl:value-of select="concat(@from,'--',@to)"/>)  +  (<xsl:value-of select="concat($extend/@from,'--',$extend/@to)"/>)</xsl:message>
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="affiliation-merge">
        <xsl:with-param name="extend" select="$extend"/>
      </xsl:apply-templates>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@*[not(name() = 'to') and not(name() = 'from') ]" mode="affiliation-merge">
    <xsl:param name="extend"/>
    <xsl:copy/>
  </xsl:template>

  <xsl:template match="@from | @to" mode="affiliation-merge">
    <xsl:param name="extend"/>
    <xsl:variable name="attr" select="name()"/>
    <xsl:choose>
      <xsl:when test="not($extend/@*[name() = $attr])"/>
      <!-- extend/@  >=  @ -->
      <xsl:when test="xs:date(mk:pad-date($extend/@*[name() = $attr]))  >= xs:date(mk:pad-date(.)) ">
        <xsl:choose>
          <xsl:when test="$attr = 'from'"><xsl:copy/></xsl:when>
          <xsl:otherwise><xsl:apply-templates select="$extend/@*[name() = $attr]"/></xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <!-- extend/@  <=  @ -->
      <xsl:when test="$attr = 'from'"><xsl:apply-templates select="$extend/@*[name() = $attr]"/></xsl:when>
      <xsl:otherwise><xsl:copy/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:*">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@*|text()|comment()">
    <xsl:copy/>
  </xsl:template>


  <xsl:function name="mk:is-comparable">
    <xsl:param name="aff1"/>
    <xsl:param name="aff2"/>
    <xsl:choose>
      <xsl:when test="not($aff1/@ref = $aff2/@ref)"><xsl:sequence select="false()"/></xsl:when>
      <xsl:when test="not($aff1/@role = $aff2/@role)"><xsl:sequence select="false()"/></xsl:when>
      <!-- IMPROVE: sort content -->
      <xsl:when test="not($aff1/@ana) and $aff2/@ana"><xsl:sequence select="false()"/></xsl:when>
      <xsl:when test="$aff1/@ana and not($aff2/@ana)"><xsl:sequence select="false()"/></xsl:when>

      <xsl:when test="$aff1/@ana and $aff2/@ana and not($aff1/@ana = $aff2/@ana)"><xsl:sequence select="false()"/></xsl:when>
      <xsl:when test="$aff1/tei:roleName and not($aff2/tei:roleName)"><xsl:sequence select="false()"/></xsl:when>
      <xsl:when test="not($aff1/tei:roleName) and $aff2/tei:roleName"><xsl:sequence select="false()"/></xsl:when>
      <xsl:when test="$aff1/tei:roleName and $aff2/tei:roleName and not($aff1/tei:roleName/text() = $aff2/tei:roleName/text())"><xsl:sequence select="false()"/></xsl:when>
      <xsl:otherwise><xsl:sequence select="true()"/></xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  <xsl:function name="mk:is-overlapping">
    <xsl:param name="aff1"/>
    <xsl:param name="aff2"/>
    <xsl:choose>
      <xsl:when test="$aff1/@from and mk:between-dates($aff1/@from,$aff2/@from,$aff2/@to)"><xsl:sequence select="true()"/></xsl:when>
      <xsl:when test="$aff1/@to and mk:between-dates($aff1/@to,$aff2/@from,$aff2/@to)"><xsl:sequence select="true()"/></xsl:when>
      <xsl:when test="$aff2/@from and mk:between-dates($aff2/@from,$aff1/@from,$aff1/@to)"><xsl:sequence select="true()"/></xsl:when>
      <xsl:when test="$aff2/@to and mk:between-dates($aff2/@to,$aff1/@from,$aff1/@to)"><xsl:sequence select="true()"/></xsl:when>
      <xsl:when test="not($aff1/@from or $aff1/@to or $aff2/@from or $aff2/@to)"><xsl:sequence select="true()"/></xsl:when>
      <xsl:otherwise><xsl:sequence select="false()"/></xsl:otherwise>
    </xsl:choose>
  </xsl:function>


  <!-- Is the first date between the following two? -->
  <xsl:function name="mk:between-dates" as="xs:boolean">
    <xsl:param name="date" as="xs:string"/>
    <xsl:param name="from" as="xs:string?"/>
    <xsl:param name="to" as="xs:string?"/>
    <xsl:choose>
      <xsl:when test="not(normalize-space($from) or normalize-space($to))">
        <xsl:value-of select="true()"/>
      </xsl:when>
      <xsl:when test="normalize-space($from) and normalize-space($to) and
                      xs:date(mk:pad-date($date)) &gt;= xs:date(mk:pad-date($from)) and
                      xs:date(mk:pad-date($date)) &lt;= xs:date(mk:pad-date($to))">
        <xsl:value-of select="true()"/>
      </xsl:when>
      <xsl:when test="not(normalize-space($from)) and normalize-space($to) and
                      xs:date(mk:pad-date($date)) &lt;= xs:date(mk:pad-date($to))" >
        <xsl:value-of select="true()"/>
      </xsl:when>
      <xsl:when test="normalize-space($from) and not(normalize-space($to)) and
                      xs:date(mk:pad-date($date)) &gt;= xs:date(mk:pad-date($from))" >
        <xsl:value-of select="true()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="false()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- Fix too long or too short dates
       a la "2013-10-26T14:00:00" or "2018" to xs:date e.g. 2018-01-01 -->
  <xsl:function name="mk:pad-date">
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
</xsl:stylesheet>