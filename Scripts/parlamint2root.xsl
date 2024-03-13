<?xml version="1.0"?>
<!-- Take template for root ParlaMint corpus file and add info from XIncluded roots -->
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:tei="http://www.tei-c.org/ns/1.0" 
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:et="http://nl.ijs.si/et" 
  xmlns:mk="http://ufal.mff.cuni.cz/matyas-kopp"
  exclude-result-prefixes="#all"
  version="3.0">

  <xsl:import href="parlamint-lib.xsl"/>

  <!-- Directory relative to location of this script, where the ParlaMint corpora are found -->
  <xsl:param name="base"/>
  <xsl:param name="type"/>
  <xsl:param name="isSample">0</xsl:param>


  <xsl:output method="xml" indent="yes"/>

  <xsl:variable name="corpusType" select="concat('ParlaMint:',$type)"/>
  <xsl:variable name="corpusTypeSuf">
    <xsl:choose>
      <xsl:when test="$corpusType = 'ParlaMint:TEI'"></xsl:when>
      <xsl:when test="$corpusType = 'ParlaMint:TEI.ana'">.ana</xsl:when>
      <xsl:when test="$corpusType = 'ParlaMint:en.TEI.ana'">-en.ana</xsl:when>
      <xsl:otherwise><xsl:message terminate="yes">Invalid or missing type '<xsl:value-of select="$type"/>'</xsl:message></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="corpusId" select="concat('ParlaMint',$corpusTypeSuf)"/>

  <xsl:variable name="docs">
    <xsl:choose>
      <xsl:when test="$isSample = '1'">
        <xsl:variable name="all-files">
          <xsl:for-each select="uri-collection(concat($base, '/?select=ParlaMint-*;recurse=yes'))">
            <item><xsl:value-of select="substring-after(.,replace($base,'^.*?/([^/]*)/?$','$1/'))"/></item>
          </xsl:for-each>
        </xsl:variable>
        <xsl:for-each select="distinct-values($all-files/tei:item/substring-before(text(),'/'))">
          <xsl:sort select="replace(.,'-en$','')"/>
          <xsl:if test=".">
            <xsl:variable name="relativePath" select="concat(.,'/',.,$corpusTypeSuf,'.xml')"/>
            <item href="{$relativePath}">
              <xsl:value-of select="concat($base,'/',$relativePath)"/>
            </item>
          </xsl:if>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="/tei:teiCorpus/tei:teiCorpus[mk:corresp(.)]/xi:include">
          <item href="{@href}">
            <xsl:value-of select="concat($base, '/', @href)"/>
          </item>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:template match="tei:teiHeader">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>

    <xsl:for-each select="$docs//tei:item">
        <xsl:choose>
          <xsl:when test="unparsed-text-available(.)">
            <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="{@href}"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:comment select="concat('$corpus root does not exist: ',@href)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
  </xsl:template>

  <xsl:template match="tei:teiCorpus/tei:teiCorpus"/>

  <xsl:template match="@xml:id[. = 'ParlaMint-rootTemplate']">
    <xsl:attribute name="xml:id" select="$corpusId"/>
  </xsl:template>


  <xsl:template match="tei:titleStmt/tei:respStmt[last()]">
    <xsl:copy-of select=".[mk:corresp(.)]"/>
    <xsl:for-each select="$docs//tei:item">
      <xsl:for-each select="mk:get-teiCorpus(.)">
        <xsl:variable name="id" select="@xml:id"/>
        <xsl:for-each select="tei:teiHeader//tei:titleStmt/tei:respStmt">
          <xsl:copy>
            <xsl:attribute name="corresp" select="concat('#', $id)"/>
            <xsl:for-each select="tei:persName[not(@xml:lang) or @xml:lang != 'bg']">
              <xsl:copy>
                <xsl:value-of select="."/>
              </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="tei:resp[ancestor-or-self::tei:*[@xml:lang][1][@xml:lang='en']]">
              <xsl:copy>
                <xsl:value-of select="."/>
              </xsl:copy>
            </xsl:for-each>
          </xsl:copy>
        </xsl:for-each>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="tei:title[mk:corresp(.)] | tei:publisher">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="ancestor-or-self::tei:*[@xml:lang][1][@xml:lang!='en']">
        <xsl:attribute name="xml:lang" select="ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang"/>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:titleStmt/tei:meeting">
    <xsl:for-each select="$docs//tei:item">
      <xsl:for-each select="mk:get-teiCorpus(.)">
        <xsl:variable name="id" select="@xml:id"/>
        <xsl:variable name="country-code" select="mk:country-code(@xml:id)"/>
        <xsl:for-each select="tei:teiHeader//tei:titleStmt/tei:meeting">
          <!--meeting ana="#parla.lower #parla.term" n="54">54-ste zittingsperiode</meeting-->
          <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="xml:lang" select="ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang"/>
            <xsl:attribute name="corresp" select="concat('#', $id)"/>
            <xsl:attribute name="ana">
              <xsl:variable name="ana">
                <xsl:for-each select="tokenize(@ana, ' ')">
                  <xsl:value-of select="concat(., '-', $country-code)"/>
                  <xsl:text>&#32;</xsl:text>
                </xsl:for-each>
              </xsl:variable>
              <xsl:value-of select="normalize-space($ana)"/>
            </xsl:attribute>
            <xsl:apply-templates/>
          </xsl:copy>
        </xsl:for-each>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="tei:publicationStmt/tei:date">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="when" select="$today-iso"/>
      <xsl:value-of select="format-date(current-date(), '[MNn] [D], [Y]')"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:titleStmt/tei:funder">
    <funder>
      <orgName>The CLARIN research infrastructure</orgName>
    </funder>
    <xsl:for-each select="$docs//tei:item">
      <xsl:for-each select="mk:get-teiCorpus(.)">
        <xsl:variable name="id" select="@xml:id"/>
        <xsl:variable name="funders">
          <xsl:for-each select="tei:teiHeader//tei:titleStmt/tei:funder">
            <xsl:if test="not(contains(., ' CLARIN '))">
              <xsl:copy-of select="tei:*[ancestor-or-self::tei:*[@xml:lang][1][@xml:lang='en']]"/>
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>
        <xsl:if test="normalize-space($funders)">
          <funder corresp="#{$id}">
            <xsl:copy-of select="$funders"/>
          </funder>
        </xsl:if>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="tei:extent">
    <xsl:copy>
      <xsl:variable name="corpora" select="count($docs/tei:item)"/>
      <measure unit="corpora" quantity="{format-number($corpora, '#')}">
        <xsl:value-of select="concat(format-number($corpora, '###,###,###'), ' corpora')"/>
      </measure>
      <!-- This number is the real number, but all else are fake!
      <xsl:variable name="text">
        <xsl:variable name="texts">
          <xsl:for-each select="$docs/tei:item/document(.)/tei:teiCorpus">
            <item>
              <xsl:value-of select="count(xi:include)"/>
            </item>
          </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="sum($texts/tei:item)"/>
      </xsl:variable>
      <measure unit="texts" quantity="{format-number($text, '#')}">
        <xsl:value-of select="concat(format-number($text, '###,###,###'), ' texts')"/>
      </measure-->
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:extent/tei:measure">
    <xsl:variable name="unit" select="@unit"/>
    <xsl:variable name="quants">
      <xsl:for-each select="$docs/tei:item/mk:get-teiCorpus(.)/tei:teiHeader//
                            tei:extent/tei:measure
                            [ancestor-or-self::tei:*[@xml:lang][1][@xml:lang='en']][@unit = $unit]">
        <xsl:copy>
          <xsl:apply-templates select="@unit"/>
          <xsl:apply-templates select="@quantity"/>
          <xsl:attribute name="corresp">
            <xsl:text>#</xsl:text>
            <xsl:value-of select="ancestor::tei:teiCorpus/@xml:id"/>
          </xsl:attribute>
          <xsl:apply-templates/>
        </xsl:copy>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="quant" select="sum($quants/tei:measure/@quantity)"/>
    <xsl:copy>
      <xsl:attribute name="unit" select="$unit"/>
      <xsl:attribute name="quantity" select="format-number($quant, '#')"/>
      <xsl:value-of select="concat(format-number($quant, '###,###,###'), ' ', $unit)"/>
    </xsl:copy>
    <xsl:copy-of select="$quants"/>
  </xsl:template>

  <xsl:template match="tei:tagUsage">
    <xsl:variable name="tagUsages">
      <xsl:for-each select="$docs/tei:item/mk:get-teiCorpus(.)/tei:teiHeader//
                            tei:tagsDecl//tei:tagUsage">
        <xsl:sort select="@gi"/>
        <xsl:copy>
          <xsl:apply-templates select="@gi"/>
          <xsl:apply-templates select="@occurs"/>
          <xsl:attribute name="corresp">
            <xsl:text>#</xsl:text>
            <xsl:value-of select="ancestor::tei:teiCorpus/@xml:id"/>
          </xsl:attribute>
          <xsl:apply-templates/>
        </xsl:copy>
      </xsl:for-each>
    </xsl:variable>
    <xsl:for-each select="$tagUsages/tei:tagUsage">
      <xsl:variable name="gi" select="@gi"/>
      <xsl:if test="not(following-sibling::tei:tagUsage[@gi = $gi])">
        <xsl:variable name="occurences">
          <xsl:for-each select="$tagUsages/tei:tagUsage[@gi = $gi]">
            <item>
              <xsl:value-of select="@occurs"/>
            </item>
          </xsl:for-each>
        </xsl:variable>
        <tagUsage gi="{$gi}" occurs="{format-number(sum($occurences/tei:item), '#')}"/>
      </xsl:if>
    </xsl:for-each>
    <xsl:copy-of select="$tagUsages"/>
  </xsl:template>

  <xsl:template match="tei:sourceDesc/tei:bibl">
    <xsl:for-each select="$docs/tei:item/mk:get-teiCorpus(.)">
      <xsl:sort select="@xml:id"/>
      <xsl:variable name="id" select="@xml:id"/>
      <listBibl>
        <xsl:attribute name="corresp" select="concat('#', @xml:id)"/>
        <head>
          <xsl:value-of select="@xml:id"/>
        </head>
        <xsl:variable name="nodes" select="tei:teiHeader//tei:sourceDesc/tei:bibl"/>
        <xsl:for-each select="$nodes">
          <bibl>
            <xsl:apply-templates/>
          </bibl>
        </xsl:for-each>
        <xsl:if test="not($nodes)"><xsl:comment select="concat($id,': missing bibl')"/></xsl:if>
      </listBibl>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="tei:editorialDecl/tei:*[mk:corresp(.)]">
    <xsl:variable name="name" select="name()"/>
    <xsl:copy>
      <xsl:for-each select="$docs//tei:item/mk:get-teiCorpus(.)">
        <xsl:variable name="id" select="@xml:id"/>
        <xsl:variable name="nodes" select="tei:teiHeader/tei:encodingDesc/
                              tei:editorialDecl/tei:*[name() = $name]/tei:p"/>
        <xsl:for-each select="$nodes">
          <xsl:copy>
            <xsl:attribute name="corresp" select="concat('#', $id)"/>
            <xsl:value-of select="."/>
          </xsl:copy>
        </xsl:for-each>
        <xsl:if test="not($nodes)"><xsl:comment select="concat($id,': missing editorialDecl/*')"/></xsl:if>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>

  <!-- This will not work with factorised taxonomies! -->
  <xsl:template match="tei:taxonomy">
    <xsl:variable name="id" select="@xml:id"/>
    <xsl:copy>
      <xsl:attribute name="xml:id" select="$id"/>
      <xsl:variable name="taxonomies">
        <xsl:for-each-group select="$docs/document(tei:item)/
                                    tei:teiCorpus/tei:teiHeader//tei:classDecl/
                                    tei:taxonomy[@xml:id = $id]/tei:category"
                            group-by="@xml:id">
          <xsl:variable name="country-code" select="mk:country-code(ancestor::tei:teiCorpus/@xml:id)"/>
          <category xml:id="{current-grouping-key()}">
            <xsl:for-each select="current-group()/tei:catDesc">
              <xsl:copy>
                <xsl:attribute name="corresp"
                               select="concat('#', ancestor::tei:teiCorpus/@xml:id)"/>
                <xsl:if test="ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang != 'en'">
                  <xsl:attribute name="xml:lang"
                                 select="ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang"/>
                </xsl:if>
                <xsl:apply-templates/>
              </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="current-group()/tei:category">
              <xsl:copy>
                <xsl:attribute name="corresp"
                               select="concat('#', ancestor::tei:teiCorpus/@xml:id)"/>
                <xsl:if test="ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang != 'en'">
                  <xsl:attribute name="xml:lang"
                                 select="ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang"/>
                </xsl:if>
                <xsl:apply-templates/>
              </xsl:copy>
            </xsl:for-each>
          </category>
        </xsl:for-each-group>
      </xsl:variable>
      <xsl:copy-of select="$taxonomies"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:category">
    <xsl:variable name="country-code" select="mk:country-code(ancestor::tei:teiCorpus/@xml:id)"/>
    <xsl:variable name="id" select="concat(@xml:id, '-', $country-code)"/>
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="xml:id" select="$id"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:appInfo[mk:corresp(.)]">
    <xsl:for-each select="$docs//tei:item/mk:get-teiCorpus(.)">
      <xsl:variable name="id" select="@xml:id"/>
      <xsl:variable name="nodes" select="tei:teiHeader/tei:encodingDesc/tei:appInfo"/>
      <xsl:for-each select="$nodes">
        <xsl:copy>
          <xsl:attribute name="corresp" select="concat('#', $id)"/>
          <xsl:apply-templates/>
        </xsl:copy>
      </xsl:for-each>
      <xsl:if test="not($nodes)"><xsl:comment select="concat($id,': missing appInfo')"/></xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="tei:settingDesc">
    <xsl:copy>
      <xsl:for-each select="$docs//tei:item/mk:get-teiCorpus(.)">
        <setting corresp="#{@xml:id}">
          <xsl:copy-of select="tei:teiHeader//tei:setting/tei:*"/>
        </setting>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:textClass">
    <xsl:copy>
      <xsl:for-each select="$docs//tei:item/mk:get-teiCorpus(.)">
        <xsl:variable name="id" select="@xml:id"/>
        <xsl:variable name="nodes" select=".//tei:textClass/tei:catRef"/>
        <xsl:for-each select="$nodes">
          <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="corresp" select="concat('#', $id)"/>
            <xsl:apply-templates/>
          </xsl:copy>
        </xsl:for-each>
        <xsl:if test="not($nodes)"><xsl:comment select="concat($id,': missing catRef')"/></xsl:if>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:langUsage">
    <xsl:for-each select="$docs//tei:item/mk:get-teiCorpus(.)">
      <xsl:variable name="id" select="@xml:id"/>
      <xsl:variable name="nodes" select=".//tei:langUsage"/>
      <xsl:for-each select="$nodes">
        <langUsage corresp="#{$id}">
          <xsl:copy-of select="tei:*"/>
        </langUsage>
      </xsl:for-each>
      <xsl:if test="not($nodes)"><xsl:comment select="concat($id,': missing langUsage')"/></xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="tei:change/@when">
    <xsl:attribute name="when" select="$today-iso"/>
  </xsl:template>

  <xsl:template match="*[mk:corresp(.)]" priority="-0.5">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="*" priority="-0.6"/>

  <xsl:template match="@*">
    <xsl:if test="name() != 'xml:lang' and . != 'en'">
      <xsl:copy/>
    </xsl:if>
  </xsl:template>
  <xsl:template match="@corresp">
    <xsl:variable name="val" select="normalize-space(replace(concat(' ',.),' ParlaMint:[^ ]*',''))"/>
    <xsl:if test="$val">
      <xsl:attribute name="{name()}" select="$val"/>
    </xsl:if>
  </xsl:template>


  <xsl:function name="mk:country-code">
    <xsl:param name="id"/>
    <xsl:value-of select="replace($id,'^ParlaMint-(.*?)(?:-en)?(?:.ana)?$','$1')"/>
  </xsl:function>

  <xsl:function name="mk:corresp">
    <xsl:param name="node"/>
    <xsl:choose>
      <xsl:when test="$node[not(@corresp) or not(contains(concat(' ',@corresp),' ParlaMint:')) or contains(concat(' ', @corresp,' '),concat(' ',$corpusType,' '))]">
        <xsl:sequence select="true()"/>
      </xsl:when>
      <xsl:otherwise><xsl:sequence select="false()"/></xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="mk:get-teiCorpus">
    <xsl:param name="path"/>
    <xsl:if test="unparsed-text-available($path)">
      <xsl:sequence select="document($path)/tei:teiCorpus"/>
    </xsl:if>
  </xsl:function>

</xsl:stylesheet>
