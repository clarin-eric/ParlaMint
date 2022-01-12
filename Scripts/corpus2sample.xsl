<?xml version="1.0"?>
<!-- Take root corpus file and output sample in $outDir directory -->
<!-- Script retains first and last component file, and first and last $Range utterances in them -->
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:tei="http://www.tei-c.org/ns/1.0" 
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:et="http://nl.ijs.si/et" 
  exclude-result-prefixes="#all"
  version="2.0">

  <!-- Output directory for samples -->
  <xsl:param name="outDir"/>
  
  <!-- Revision responsible person  -->
  <xsl:param name="revRespPers">Tomaž Erjavec</xsl:param>

  <!-- How many TEI files to take -->
  <xsl:param name="Files">3</xsl:param>

  <!-- How many utterances to select from start and end of component files -->
  <xsl:param name="Range">2</xsl:param>

  <!-- Location of the GitHub project containing the output files -->
  <xsl:param name="GitHub-project">https://github.com/clarin-eric/ParlaMint</xsl:param>
  
  <xsl:variable name="today" select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>

  <!-- Select $Files XInclude components -->
  <xsl:variable name="components">
    <xsl:variable name="n" select="count(/tei:teiCorpus/xi:include)"/>
    <xsl:choose>
      <!-- When too few files -->
      <xsl:when test="$n &lt;= $Files + 1">
        <xsl:message select="concat('INFO: from ', $n , ' files  selecting all of them: ')"/>
        <xsl:for-each select="//xi:include">
          <xsl:message select="concat('INFO: selecting file ', @href)"/>
          <xsl:copy-of select="."/>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message select="concat('INFO: from ', $n , ' files  selecting ~', $Files, ' files:')"/>
      <xsl:for-each select="//xi:include">
        <xsl:if test="(position()-1) mod floor($n div $Files) = 1">
          <xsl:message select="concat('INFO: selecting file ', @href)"/>
          <xsl:copy-of select="."/>
        </xsl:if>
      </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:output method="xml" indent="yes"/>
  
  <xsl:template match="/">
    <!-- Output root file -->
    <xsl:variable name="inFile" select="replace(document-uri(/), '.+/([^/]+$)', '$1')"/>
    <xsl:result-document href="{$outDir}/{$inFile}" method="xml">
      <xsl:apply-templates/>
    </xsl:result-document>
    <!-- Output component file samples -->
    <xsl:variable name="inDir" select="replace(document-uri(/), '/[^/]+$', '')"/>
    <xsl:for-each select="$components/xi:include">
      <!-- Get rid of subdirectories if in original -->
      <xsl:variable name="href" select="replace(@href, '.+/', '')"/>
      <xsl:result-document href="{$outDir}/{$href}" method="xml">
        <xsl:apply-templates mode="component" select="document(concat($inDir, '/', @href))"/>
      </xsl:result-document>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template mode="component" match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:teiCorpus">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="tei:teiHeader"/>
      <xsl:for-each select="$components/xi:include">
        <xi:include href="{replace(@href, '.+/', '')}"/>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>

    <xsl:template match="tei:teiHeader">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
      <xsl:if test="not(./tei:revisionDesc)">
        <revisionDesc>
          <xsl:call-template name="revisionSample"/>
        </revisionDesc>
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:titleStmt/tei:title[@type='main']">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:value-of select="replace(., '( SAMPLE)?\]', ' SAMPLE]')"/>
    </xsl:copy>
  </xsl:template>
    
  <xsl:template match="tei:publicationStmt/tei:date">
    <xsl:copy>
      <xsl:attribute name="when" select="$today"/>
      <xsl:value-of select="$today"/>
    </xsl:copy>
  </xsl:template>
    
  <!-- This make a "proper" sample, but is confusing for those that
       take the samples as a model of how to prepare their corpora 
  <xsl:template match="tei:publicationStmt/tei:pubPlace"/>
  <xsl:template match="tei:publicationStmt/tei:idno[@type='handle']">
    <idno type="URL">
      <xsl:value-of select="$GitHub-project"/>
    </idno>
    <pubPlace>
      <ref target="{$GitHub-project}">
        <xsl:value-of select="$GitHub-project"/>
      </ref>
    </pubPlace>
  </xsl:template>
  <xsl:template match="tei:sourceDesc">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <bibl>
        <title>Multilingual comparable corpora of parliamentary debates ParlaMint 1.0</title>
        <xsl:copy-of select="ancestor::tei:teiHeader//tei:publicationStmt/tei:idno[@type='handle']"/>
      </bibl>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  -->
  
  <xsl:template match="tei:extent | tei:tagsDecl">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:comment>These numbers do not reflect the size of the sample!</xsl:comment>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tei:revisionDesc">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:call-template name="revisionSample"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template name="revisionSample">
    <change when="{$today}"><name><xsl:value-of select="$revRespPers"/></name>: Made sample.</change>
  </xsl:template>
  <!-- Here we pick the first and last $Range utterances and all
       immediatelly preceding and intervening other elements -->
  <xsl:template match="tei:body">
    <xsl:variable name="all" select="count(//tei:u)"/>
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:variable name="to">
        <xsl:choose>
          <!-- If there is too few <u>s in the document -->
          <xsl:when test="$all &lt; $Range">
            <xsl:value-of select="(.//tei:u)[last()]/@xml:id"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="(.//tei:u)[position() = $Range]/@xml:id"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="from">
        <xsl:choose>
          <!-- If there is too few <u>s in the document -->
          <xsl:when test="$all &lt; 2 * $Range">0</xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="(.//tei:u)[position() = $all - ($Range - 1)]/@xml:id"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:apply-templates>
        <xsl:with-param name="from" select="$from"/>
        <xsl:with-param name="to" select="$to"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tei:div[@type='debateSection']">
    <xsl:param name="from">0</xsl:param>
    <xsl:param name="to">0</xsl:param>
    <!--xsl:message select="concat('SELECTING ', /tei:TEI/@xml:id, ': ', $to, ' AND ', $from)"/-->
    <xsl:variable name="div">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:variable name="incipit">
          <xsl:apply-templates>
            <xsl:with-param name="to" select="$to"/>
          </xsl:apply-templates>
        </xsl:variable>
        <xsl:variable name="explicit">
          <xsl:apply-templates>
            <xsl:with-param name="from" select="$from"/>
          </xsl:apply-templates>
        </xsl:variable>
        <xsl:if test="$incipit/tei:*">
          <xsl:copy-of select="$incipit"/>
          <gap reason="editorial"><desc xml:lang="en">SAMPLING</desc></gap>
        </xsl:if>
        <xsl:copy-of select="$explicit"/>
      </xsl:copy>
    </xsl:variable>
    <xsl:if test="$div//tei:u">
      <xsl:copy-of select="$div"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="tei:div[@type='debateSection']/node()">
    <xsl:param name="from">0</xsl:param>
    <xsl:param name="to">0</xsl:param>
    <xsl:if test="($from = '0' and (self::tei:* | following::tei:*)[@xml:id = $to]) or 
                  ($to   = '0' and (self::tei:* | preceding::tei:*)[@xml:id = $from])">
      <xsl:choose>
        <xsl:when test="self::tei:gap[@reason='editorial' and ./tei:desc/text() = 'SAMPLING']" /> <!-- don't copy gap/desc SAMPLING -->
        <xsl:when test="self::tei:*">
          <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/>
          </xsl:copy>
        </xsl:when>
        <xsl:when test="self::text()">
          <xsl:value-of select="."/>
        </xsl:when>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:*">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="@*">
    <xsl:copy/>
  </xsl:template>

</xsl:stylesheet>
