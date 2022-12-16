<?xml version="1.0"?>
<!-- Finalize the encoding of a ParlaMint corpus (Source language version) -->
<!-- Takes root file as input, and outputs it, any of its factorised pieces 
     and all finalized component files to outDir:
     - set release date to today
     - set version and handles for 3.0
     - set correct subcorpus
     - set English project description for ParlaMint II
     - calculate extents in component ana files, warn if changed
     - insert word extents from ana into plain version
     - insert tagcounts in root (taken from component files and not changed there!)
     - sundry checks and fixes, which give warning messages
-->
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:et="http://nl.ijs.si/et" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xsl tei et xs xi"
  version="2.0">

  <xsl:import href="parlamint-lib.xsl"/>
  
  <!-- Directories must have absolute paths! -->
  <xsl:param name="outDir">.</xsl:param>
  <xsl:param name="anaDir">.</xsl:param>
  
  <!-- Version and handle of the release -->
  <xsl:param name="version">3.0</xsl:param>
  <xsl:param name="handle-txt">http://hdl.handle.net/11356/1486</xsl:param>
  <xsl:param name="handle-ana">http://hdl.handle.net/11356/1488</xsl:param>
  
  <xsl:param name="covid-date" as="xs:date">2019-11-01</xsl:param>

  <!-- Type of corpus is 'txt' or 'ana' -->
  <xsl:param name="type">
    <xsl:choose>
      <xsl:when test="contains(/tei:teiCorpus/@xml:id, '.ana')">ana</xsl:when>
      <xsl:otherwise>txt</xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  
  <!-- County code take from the teiCorpus ID, country name from main English title -->
  <xsl:param name="country-code" select="replace(/tei:teiCorpus/@xml:id, 
                                         '.*?-([^._]+).*', '$1')"/>
  <xsl:param name="country-name" select="replace(/tei:teiCorpus/tei:teiHeader/
                                         tei:fileDesc/tei:titleStmt/
                                         tei:title[@type='main' and @xml:lang='en'],
                                         '([^ ]+) .*', '$1')"/>
  
  <!-- Project description for ParlaMint II -->
  <xsl:variable name="projectDesc-en">
    <p xml:lang="en"><ref target="https://www.clarin.eu/content/parlamint">ParlaMint</ref> is a
    project that aims to (1) create a multilingual set of comparable corpora of parliamentary
    proceedings uniformly encoded according to the
    <ref target="https://clarin-eric.github.io/ParlaMint/">ParlaMint encoding guidelines</ref>, 
    covering the period from 2015 to mid-2022; (2) add linguistic annotations to the corpora and
    machine-translate them to English; (3) make the corpora available through concordancers; and
    (4) build use cases in Political Sciences and Digital Humanities based on the corpus
    data.</p>
  </xsl:variable>
  
  <xsl:output method="xml" indent="yes"/>
  <xsl:preserve-space elements="catDesc seg"/>


  <!-- Input directory -->
  <xsl:variable name="inDir" select="replace(base-uri(), '(.*)/.*', '$1')"/>
  <!-- The name of the corpus directory to output to, i.e. "ParlaMint-XX" -->
  <xsl:variable name="corpusDir" select="replace(base-uri(), 
                                         '.*?([^/]+)/[^/]+\.[^/]+$', '$1')"/>

  <xsl:variable name="outRoot">
    <xsl:value-of select="$outDir"/>
    <xsl:text>/</xsl:text>
    <xsl:value-of select="$corpusDir"/>
    <xsl:text>/</xsl:text>
    <xsl:value-of select="replace(base-uri(), '.*/(.+)$', '$1')"/>
  </xsl:variable>

  <!-- Gather URIs of component xi + files and map to new files, incl. .ana files -->
  <xsl:variable name="docs">
    <xsl:for-each select="//xi:include">
      <item>
	<xsl:attribute name="type">
	  <xsl:choose>
	    <xsl:when test="ancestor::tei:teiHeader">factorised</xsl:when>
	    <xsl:otherwise>component</xsl:otherwise>
	  </xsl:choose>
	</xsl:attribute>
        <xi-orig>
          <xsl:value-of select="@href"/>
        </xi-orig>
        <url-orig>
          <xsl:value-of select="concat($inDir, '/', @href)"/>
        </url-orig>
        <url-new>
          <xsl:value-of select="concat($outDir, '/', $corpusDir, '/', @href)"/>
        </url-new>
        <url-ana>
          <xsl:value-of select="concat($anaDir, '/', replace(@href, '\.xml', '.ana.xml'))"/>
        </url-ana>
      </item>
      </xsl:for-each>
  </xsl:variable>
  
  <!-- Numbers of words in component .ana files -->
  <xsl:variable name="words">
    <xsl:for-each select="$docs/tei:item[@type = 'component']">
      <item n="{tei:xi-orig}">
        <xsl:choose>
          <!-- For .ana files, compute number of words -->
          <xsl:when test="$type = 'ana'">
            <xsl:value-of select="document(tei:url-orig)/
                                  count(//tei:w[not(parent::tei:w)])"/>
          </xsl:when>
          <!-- For plain files, take number of words from .ana files -->
          <xsl:when test="doc-available(tei:url-ana)">
            <xsl:value-of select="document(tei:url-ana)/tei:TEI/tei:teiHeader//
                                  tei:extent/tei:measure[@unit='words'][1]/@quantity"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:message select="concat('ERROR ', /tei:TEI/@xml:id, 
                                   ': cannot locate .ana file ', tei:url-ana)"/>
              <xsl:value-of select="number('0')"/>
            </xsl:otherwise>
          </xsl:choose>
        </item>
      </xsl:for-each>
  </xsl:variable>
  
  <!-- Numbers of speeches in component files -->
  <xsl:variable name="speeches">
    <xsl:for-each select="$docs/tei:item[@type = 'component']">
      <item>
        <xsl:value-of select="document(tei:url-orig)/tei:TEI/tei:teiHeader//
                              tei:extent/tei:measure[@unit = 'speeches'][1]/@quantity"/>
      </item>
    </xsl:for-each>
  </xsl:variable>

  <!-- Get tagUsages in component files -->
  <xsl:variable name="tagUsages">
    <xsl:variable name="tUs">
      <xsl:for-each select="$docs/tei:item[@type = 'component']/document(tei:url-orig)/
                            tei:TEI/tei:teiHeader//tei:tagUsage">
        <xsl:sort select="@gi"/>
        <xsl:copy-of select="."/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:for-each select="$tUs/tei:tagUsage">
      <xsl:variable name="gi" select="@gi"/>
      <xsl:if test="not(following-sibling::tei:tagUsage[@gi = $gi])">
        <xsl:variable name="occurences">
          <xsl:for-each select="$tUs/tei:tagUsage[@gi = $gi]">
            <item>
              <xsl:value-of select="@occurs"/>
            </item>
          </xsl:for-each>
        </xsl:variable>
        <tagUsage xmlns="http://www.tei-c.org/ns/1.0" gi="{$gi}"
                  occurs="{format-number(sum($occurences/tei:item), '#')}"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>
  
  <xsl:template match="/">
    <xsl:message select="concat('INFO: Starting to process ', tei:teiCorpus/@xml:id)"/>
    <!-- Process component files -->
    <xsl:for-each select="$docs//tei:item">
      <xsl:variable name="this" select="tei:xi-orig"/>
      <xsl:message select="concat('INFO: Processing ', $this)"/>
      <xsl:result-document href="{tei:url-new}">
	<xsl:choose>
	  <!-- Copy over factorised parts of corpus root teiHeader -->
	  <xsl:when test="@type = 'factorised'">
            <xsl:copy-of select="document(tei:url-orig)"/>
	  </xsl:when>
	  <!-- Process component -->
	  <xsl:when test="@type = 'component'">
            <xsl:apply-templates mode="comp" select="document(tei:url-orig)/tei:TEI">
              <xsl:with-param name="words" select="$words/tei:item[@n = $this]"/>
            </xsl:apply-templates>
	  </xsl:when>
	</xsl:choose>
      </xsl:result-document>
    </xsl:for-each>
    <!-- Output Root file -->
    <xsl:message>INFO: processing root </xsl:message>
    <xsl:result-document href="{$outRoot}">
      <xsl:apply-templates/>
    </xsl:result-document>
  </xsl:template>

  <xsl:template mode="comp" match="*">
    <xsl:param name="words"/>
    <xsl:copy>
      <xsl:apply-templates mode="comp" select="@*"/>
      <xsl:apply-templates mode="comp">
        <xsl:with-param name="words" select="$words"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  <xsl:template mode="comp" match="@*">
    <xsl:copy/>
  </xsl:template>

  <xsl:template mode="comp" match="tei:TEI/@ana | tei:text/@ana">
    <xsl:variable name="id" select="ancestor::tei:TEI/@xml:id"/>
    <xsl:variable name="date" select="ancestor::tei:TEI/tei:teiHeader//tei:setting/tei:date"/>
    <xsl:variable name="date-from">
      <xsl:choose>
        <xsl:when test="$date/@when">
          <xsl:value-of select="$date/@when"/>
        </xsl:when>
        <xsl:when test="$date/@from">
          <xsl:value-of select="$date/@from"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message select="concat('ERROR ', $id, ': no date in setting!')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:attribute name="ana">
      <xsl:variable name="ref">
        <xsl:for-each select="tokenize(., ' ')">
          <xsl:choose>
            <xsl:when test=". = '#reference' and 
                            $covid-date &lt;= $date-from">
              <xsl:text>#covid</xsl:text>
              <xsl:message select="concat('WARN ', $id, 
                               ': fixing subcorpus to covid for date ', $date-from)"/>
            </xsl:when>
            <xsl:when test=". = '#covid' and 
                            $covid-date &gt; $date-from">
              <xsl:text>#reference</xsl:text>
              <xsl:message select="concat('WARN ', $id, 
                               ': fixing subcorpus to reference for date ', $date-from)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="."/>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:text>&#32;</xsl:text>
        </xsl:for-each>
      </xsl:variable>
      <xsl:value-of select="normalize-space($ref)"/>
    </xsl:attribute>
  </xsl:template>
  
  <!-- Same as for root -->
  <xsl:template mode="comp" match="tei:publicationStmt/tei:date">
    <xsl:apply-templates select="."/>
  </xsl:template>
  <xsl:template mode="comp" match="tei:editionStmt/tei:edition">
    <xsl:apply-templates select="."/>
  </xsl:template>
  <xsl:template mode="comp" match="tei:projectDesc/tei:p[@xml:lang = 'en']">
    <xsl:apply-templates select="."/>
  </xsl:template>
  <xsl:template mode="comp" match="tei:idno[contains(., 'http://hdl.handle.net/11356/')]">
    <xsl:apply-templates select="."/>
  </xsl:template>
  <xsl:template mode="comp" match="tei:publicationStmt[tei:idno]/
                       tei:pubPlace[tei:ref[matches(@target, 'hdl.handle.net')]]">
    <xsl:apply-templates select="."/>
  </xsl:template>
  
  <xsl:template mode="comp" match="tei:extent/tei:measure[@unit='words']">
    <xsl:param name="words"/>
    <xsl:variable name="old-words" select="@quantity"/>
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="normalize-space($words) and $words != '0'">
        <xsl:attribute name="quantity" select="$words"/>
        <xsl:if test="$old-words != $words">
          <xsl:message select="concat('WARN ', /tei:TEI/@xml:id, 
                               ': replacing words ', $old-words, ' with ', $words)"/>
        </xsl:if>
        <xsl:value-of select="replace(., '.+ ', concat(
                            et:format-number(ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang, $words), 
                            ' '))"/>
      </xsl:if>
    </xsl:copy>
  </xsl:template>  

  <!-- Give IDs to segs without them (if u has ID, otherwise complain) -->
  <xsl:template mode="comp" match="tei:seg[not(@xml:id)]">
    <xsl:copy>
      <xsl:apply-templates mode="comp" select="@*"/>
      <xsl:choose>
        <xsl:when test="parent::tei:u/@xml:id">
          <xsl:attribute name="xml:id">
            <xsl:value-of select="parent::tei:u/@xml:id"/>
            <xsl:text>.</xsl:text>
            <xsl:number/>
          </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message select="concat('ERROR ', /tei:TEI/@xml:id, 
                               ': seg without ID but utterance also has no ID!')"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates mode="comp"/>
    </xsl:copy>
  </xsl:template>
      

  <!-- Bug in STANZA, sometimes a word lemma is set to "_" -->
  <!-- We set lemma to @norm, if it exists, else to text() of the word -->
  <xsl:template mode="comp" match="tei:w/@lemma[. = '_']">
    <xsl:attribute name="lemma">
      <xsl:choose>
        <xsl:when test="../@norm">
          <xsl:message select="concat('WARN ', /tei:TEI/@xml:id, 
                               ': changing _ lemma to @norm ', ../@norm, ' in ', ../@xml:id)"/>
          <xsl:value-of select="../@norm"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message select="concat('WARN ', /tei:TEI/@xml:id, 
                               ': changing _ lemma to token ', ../text(), ' in ', ../@xml:id)"/>
          <xsl:value-of select="../text()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>
  

  <!-- Finalizing ROOT -->
  
  <xsl:template match="*">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="@*">
    <xsl:copy/>
  </xsl:template>
  
  <xsl:template match="tei:teiCorpus">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="tei:*"/>
      <xsl:for-each select="xi:include">
        <!-- Don't sort by date, as otherwise if one date has more than one file,
             the order inside the date will be random; rather, just sort on @href -->
        <!--xsl:sort select="replace(@href, '.+?_(\d\d\d\d-\d\d-\d\d).*', '$1')"/-->
        <xsl:sort select="@href"/>
        <xsl:copy-of select="."/>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tei:measure[@unit='sessions' or @unit='speeches' or @unit='words']">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:variable name="quant">
        <xsl:choose>
          <xsl:when test="@unit='sessions'">
            <xsl:value-of select="count($docs/tei:item[@type = 'component'])"/>
          </xsl:when>
          <xsl:when test="@unit='speeches'">
            <xsl:value-of select="sum($speeches/tei:item[@type = 'component'])"/>
          </xsl:when>
          <xsl:when test="@unit='words'">
            <xsl:value-of select="sum($words/tei:item[@type = 'component'])"/>
          </xsl:when>
        </xsl:choose>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="normalize-space($quant)">
          <xsl:attribute name="quantity" select="format-number($quant, '#')"/>
          <xsl:value-of select="replace(., '.+ ', concat(
                                et:format-number(ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang, $quant), 
                                ' '))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message select="concat('ERROR ', /tei:TEI/@xml:id, 
                               ': no count for measure ', @unit)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>
  

  <xsl:template match="tei:publicationStmt/tei:date">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="when" select="$today-iso"/>
      <xsl:value-of select="$today-iso"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tei:editionStmt/tei:edition">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="$version != .">
        <!--xsl:message select="concat('INFO ', /tei:TEI/@xml:id, 
                             ': replacing version ', ., ' with ', $version)"/-->
      </xsl:if>
      <xsl:value-of select="$version"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tei:projectDesc/tei:p[@xml:lang = 'en']">
    <xsl:copy-of select="$projectDesc-en"/>
  </xsl:template>
  
  <xsl:template match="tei:revisionDesc">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="*"/>
      <change when="{$today-iso}"><name>parlamint2final.xsl</name>: Finalize corpus.</change>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:idno[contains(., 'http://hdl.handle.net/11356/')]">
    <idno subtype="handle" type="URI">
      <xsl:choose>
        <xsl:when test="$type = 'txt'">
          <xsl:value-of select="$handle-txt"/>
        </xsl:when>
        <xsl:when test="$type = 'ana'">
          <xsl:value-of select="$handle-ana"/>
        </xsl:when>
      </xsl:choose>
    </idno>
  </xsl:template>

  <xsl:template match="tei:tagsDecl/tei:namespace">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*"/>
      <xsl:copy-of copy-namespaces="no" select="$tagUsages"/>
    </xsl:copy>
  </xsl:template>
    
  <!-- Format number-->
  <xsl:function name="et:format-number" as="xs:string">
    <xsl:param name="lang" as="xs:string"/>
    <xsl:param name="quant"/>
    <xsl:variable name="form" select="format-number($quant, '###,###,###,###')"/>
    <xsl:choose>
      <xsl:when test="$lang = 'fr'">
        <xsl:value-of select="replace($form, ',', ' ')"/>
      </xsl:when>
      <xsl:when test="$lang = 'bg' or 
                      $lang = 'cs' or
                      $lang = 'hr' or
                      $lang = 'hu' or
                      $lang = 'is' or
                      $lang = 'it' or
                      $lang = 'lt' or
                      $lang = 'lv' or
                      $lang = 'pl' or
                      $lang = 'ro' or
                      $lang = 'sl' or
                      $lang = 'tr'
                      ">
        <xsl:value-of select="replace($form, ',', '.')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$form"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
</xsl:stylesheet>
