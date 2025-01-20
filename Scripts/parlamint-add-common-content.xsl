<?xml version="1.0"?>
<!-- Takes root file as input, and outputs fixed root and all component files to outDir.
     Input is "plain text" (.TEI) or lingustically analysed (.TEI.ana) corpus root file.
     Output is the corresponding .TEI or .TEI.ana in their final form for a particular release.
     The inserted or fixed data is either given as parameters with default values or 
     computed from the corpus.
     STDERR gives a detailed log of actions.
     The program:
     - sets current date as release date
     - sets version and handles
     - sets correct top level ID so it is the same as filename
     - sets main title ParlaMint stamp
     - sets correct references to date-dependent subcorpora (#reference, #covid, #war)
     - sets ParlaMint II English projectDesc
     - gives correct type and subtype to idno
     - calculates speech and word extents
     - calculates tagUsage
     - inserts bi- or uni-cameralism if missing
     - adds meeting reference to parliamentary body of the meeting, if missing
     - changes div/@type="debateSection" to ="commentSection" if div contains no utterances
     - removes spurious handle ref
     - removes spurious spaces
     - sorts XIncluded component files
-->
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:et="http://nl.ijs.si/et" 
  xmlns:mk="http://ufal.mff.cuni.cz/matyas-kopp"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xsl tei et mk xs xi"
  version="2.0">

  <xsl:import href="parlamint-lib.xsl"/>
  
  <!-- Directories must have absolute paths! -->
  <xsl:param name="outDir">.</xsl:param>
  <xsl:param name="anaDir">.</xsl:param>
  <xsl:param name="outHeaderDir">.</xsl:param>
  <xsl:param name="anaHeaderDir">.</xsl:param>
  <xsl:param name="reference-date" as="xs:date">2020-01-30</xsl:param>
  <xsl:param name="covid-date" as="xs:date">2020-01-31</xsl:param>
  <xsl:param name="war-date" as="xs:date">2022-02-24</xsl:param>

  <!-- We give fake values here, the calling program should set these parameters! -->
  <xsl:param name="version">3.0a</xsl:param>
  <xsl:param name="handle-txt">http://hdl.handle.net/11356/XXXX</xsl:param>
  <xsl:param name="handle-ana">http://hdl.handle.net/11356/XXXX</xsl:param>

  <!-- parameters for partial processing, root file is processed after processing the last component file -->
  <xsl:param name="chunkStart">0</xsl:param>
  <xsl:param name="chunkSize">0</xsl:param> <!-- 0 means process all -->

  <!-- Is this a linguistically annotated (ana) or plain text corpus (txt)? -->
  <xsl:param name="type">
    <xsl:choose>
      <xsl:when test="contains(/tei:teiCorpus/@xml:id, '.ana')">ana</xsl:when>
      <xsl:otherwise>txt</xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  <xsl:param name="country-code" select="replace(/tei:teiCorpus/@xml:id, 
                                         '.*?-([^._]+).*', '$1')"/>
  <xsl:param name="country-name" select="replace(/tei:teiCorpus/tei:teiHeader/
                                         tei:fileDesc/tei:titleStmt/
                                         tei:title[@type='main' and @xml:lang='en'],
                                         '([^ ]+) .*', '$1')"/>

  <!-- Is this an MTed corpus? $mt should be name of MTed language, or empty, if original corpus -->
  <xsl:param name="mt">
    <xsl:if test="matches($country-code, '-[a-z]{2,3}$')">
      <xsl:value-of select="replace($country-code, '.+-([a-z]{2,3})$', '$1')"/>
    </xsl:if>
  </xsl:param>
  
  <xsl:output method="xml" indent="yes"/>
  <xsl:preserve-space elements="catDesc seg"/>

  <!-- GOBAL VARIABLES -->
  
  <!-- Project description for ParlaMint II -->
  <xsl:variable name="projectDesc-en">
    <p xml:lang="en"><ref target="https://www.clarin.eu/parlamint">ParlaMint</ref> is a
    project that aims to (1) create a multilingual set of comparable corpora of parliamentary
    proceedings uniformly encoded according to the
    <ref target="https://clarin-eric.github.io/ParlaMint/">ParlaMint encoding guidelines</ref>, 
    covering the period from 2015 to mid-2022; (2) add linguistic annotations to the corpora and
    machine-translate them to English; (3) make the corpora available through concordancers; and
    (4) build use cases in Political Sciences and Digital Humanities based on the corpus
    data.</p>
  </xsl:variable>
  
  <xsl:variable name="houses">
    <xsl:choose>
      <xsl:when test="$country-code = 'AT'">
        <term>Legislature</term>
        <term>Bicameralism</term>
        <term>Lower house</term>
      </xsl:when>
      <xsl:when test="$country-code = 'BA'">
        <term>Legislature</term>
        <term>Unicameralism</term>
      </xsl:when>
      <xsl:when test="$country-code = 'BE'">
        <term>Legislature</term>
        <term>Bicameralism</term>
        <term>Lower house</term>
        <term>Committee</term>
      </xsl:when>
      <xsl:when test="$country-code = 'BG'">
        <term>Legislature</term>
        <term>Unicameralism</term>
      </xsl:when>
      <xsl:when test="$country-code = 'CZ'">
        <term>Legislature</term>
        <term>Bicameralism</term>
        <term>Lower house</term>
      </xsl:when>
      <xsl:when test="$country-code = 'DE'">
        <term>Legislature</term>
        <term>Bicameralism</term>
        <term>Lower house</term>
      </xsl:when>
      <xsl:when test="$country-code = 'DK'">
        <term>Legislature</term>
        <term>Unicameralism</term>
      </xsl:when>
      <xsl:when test="$country-code = 'EE'">
        <term>Legislature</term>
        <term>Unicameralism</term>
      </xsl:when>
      <xsl:when test="$country-code = 'ES'">
        <term>Legislature</term>
        <term>Bicameralism</term>
        <term>Lower house</term>
      </xsl:when>
      <xsl:when test="$country-code = 'ES-AN'">
        <term>Legislature</term>
        <term>Unicameralism</term>
      </xsl:when>
      <xsl:when test="$country-code = 'ES-CT'">
        <term>Legislature</term>
        <term>Unicameralism</term>
      </xsl:when>
      <xsl:when test="$country-code = 'ES-GA'">
        <term>Legislature</term>
        <term>Unicameralism</term>
      </xsl:when>
      <xsl:when test="$country-code = 'ES-PV'">
        <term>Legislature</term>
        <term>Unicameralism</term>
      </xsl:when>
      <xsl:when test="$country-code = 'FI'">
        <term>Legislature</term>
        <term>Unicameralism</term>
      </xsl:when>
      <xsl:when test="$country-code = 'FR'">
        <term>Legislature</term>
        <term>Bicameralism</term>
        <term>Lower house</term>
      </xsl:when>
      <xsl:when test="$country-code = 'GB'">
        <term>Legislature</term>
        <term>Bicameralism</term>
        <term>Lower house</term>
        <term>Upper house</term>
      </xsl:when>
      <xsl:when test="$country-code = 'GR'">
        <term>Legislature</term>
        <term>Unicameralism</term>
      </xsl:when>
      <xsl:when test="$country-code = 'HR'">
        <term>Legislature</term>
        <term>Unicameralism</term>
      </xsl:when>
      <xsl:when test="$country-code = 'HU'">
        <term>Legislature</term>
        <term>Unicameralism</term>
      </xsl:when>
      <xsl:when test="$country-code = 'IL'">
        <term>Legislature</term>
        <term>Unicameralism</term>
      </xsl:when>
      <xsl:when test="$country-code = 'IS'">
        <term>Legislature</term>
        <term>Unicameralism</term>
      </xsl:when>
      <xsl:when test="$country-code = 'IT'">
        <term>Legislature</term>
        <term>Bicameralism</term>
        <term>Upper house</term>
      </xsl:when>
      <xsl:when test="$country-code = 'LT'">
        <term>Legislature</term>
        <term>Unicameralism</term>
      </xsl:when>
      <xsl:when test="$country-code = 'LV'">
        <term>Legislature</term>
        <term>Unicameralism</term>
      </xsl:when>
      <xsl:when test="$country-code = 'NL'">
        <term>Legislature</term>
        <term>Bicameralism</term>
        <term>Lower house</term>
        <term>Upper house</term>
      </xsl:when>
      <!-- NO had two houses until 2009, then became unicameral; 
           If lower and upper house had a join meeting, this is also marked as unicameral (arguably wrong)
           Note that the titles do not distinguish between the three bodies, only the filenames do: -lower.xml, -upper.xml, .xml
      -->
      <xsl:when test="$country-code = 'NO'">
        <term>Legislature</term>
        <term>Bicameralism</term>
        <term>Lower house</term>
        <term>Upper house</term>
        <term>Unicameralism</term>
      </xsl:when>
      <xsl:when test="$country-code = 'PL'">
        <term>Legislature</term>
        <term>Bicameralism</term>
        <term>Lower house</term>
        <term>Upper house</term>
      </xsl:when>
      <xsl:when test="$country-code = 'PT'">
        <term>Legislature</term>
        <term>Unicameralism</term>
      </xsl:when>
      <xsl:when test="$country-code = 'RO'">
        <term>Legislature</term>
        <term>Bicameralism</term>
        <term>Lower house</term>
      </xsl:when>
      <xsl:when test="$country-code = 'RS'">
        <term>Legislature</term>
        <term>Unicameralism</term>
      </xsl:when>
      <xsl:when test="$country-code = 'RO'">
        <term>Legislature</term>
        <term>Bicameralism</term>
        <term>Lower house</term>
      </xsl:when>
      <xsl:when test="$country-code = 'SE'">
        <term>Legislature</term>
        <term>Unicameralism</term>
      </xsl:when>
      <xsl:when test="$country-code = 'SI'">
        <term>Legislature</term>
        <term>Bicameralism</term>
        <term>Lower house</term>
      </xsl:when>
      <xsl:when test="$country-code = 'SK'">
        <term>Legislature</term>
        <term>Unicameralism</term>
      </xsl:when>
      <xsl:when test="$country-code = 'TR'">
        <term>Legislature</term>
        <term>Unicameralism</term>
      </xsl:when>
      <xsl:when test="$country-code = 'UA'">
        <term>Legislature</term>
        <term>Unicameralism</term>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message select="concat('WARN: country ', $country-code, ' without houses info')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <xsl:variable name="house-refs">
    <xsl:variable name="taxos" select="$rootHeader//tei:taxonomy"/>
    <xsl:for-each select="$houses/tei:term">
      <xsl:variable name="term" select="."/>
      <xsl:variable name="term-id">
        <xsl:choose>
          <xsl:when test="$term = 'Legislature'">
            <xsl:value-of select="//$taxos
                                  [tei:desc[tei:term = $term]]
                                  /@xml:id"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$taxos//tei:category
                                  [tei:catDesc[tei:term = $term]]
                                  /@xml:id"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <ref>
        <xsl:attribute name="target">
          <xsl:if test="not(normalize-space($term-id))">
            <xsl:message select="concat('ERROR ', /tei:teiCorpus/@xml:id,
                                 ': cannot locate ID for ', $term)"/>
          </xsl:if>
          <xsl:text>#</xsl:text>
          <xsl:value-of select="$term-id"/>
        </xsl:attribute>
        <xsl:value-of select="$term"/>
      </ref>
    </xsl:for-each>
  </xsl:variable>
  
  <!-- Input directory -->
  <xsl:variable name="inDir" select="replace(base-uri(), '(.*)/.*', '$1')"/>
  <!-- The name of the corpus directory to output to, i.e. "ParlaMint-XX" -->
  <xsl:variable name="corpusDir" select="replace(base-uri(), 
                                         '.*?([^/]+)/[^/]+\.[^/]+$', '$1')"/>

  <xsl:variable name="today" select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>
  <xsl:variable name="outRoot">
    <xsl:value-of select="$outDir"/>
    <xsl:text>/</xsl:text>
    <xsl:value-of select="$corpusDir"/>
    <xsl:text>/</xsl:text>
    <xsl:value-of select="replace(base-uri(), '.*/(.+)$', '$1')"/>
  </xsl:variable>

  <!-- Gather URIs of XIncluded files map to new URIs incl. .ana files -->
  <xsl:variable name="docs">
    <xsl:for-each select="//xi:include">
      <item>
	<xsl:attribute name="type">
	  <xsl:choose>
	    <xsl:when test="ancestor::tei:teiHeader">factorised</xsl:when>
	    <xsl:otherwise>component</xsl:otherwise>
	  </xsl:choose>
	</xsl:attribute>
        <xsl:attribute name="position" select="position()"/>
        <xi-orig>
          <xsl:value-of select="@href"/>
        </xi-orig>
        <url-orig>
          <xsl:value-of select="concat($inDir, '/', @href)"/>
        </url-orig>
        <url-new>
          <xsl:value-of select="concat($outDir, '/', $corpusDir, '/', @href)"/>
        </url-new>
	<xsl:if test="not(ancestor::tei:teiHeader)">
          <url-ana>
            <xsl:value-of select="concat($anaDir, '/')"/>
	    <xsl:choose>
              <xsl:when test="$type = 'ana'">
		<xsl:value-of select="@href"/>
	      </xsl:when>
              <xsl:when test="$type = 'txt'">
		<xsl:value-of select="replace(@href, '\.xml', '.ana.xml')"/>
	      </xsl:when>
	    </xsl:choose>
          </url-ana>
          <url-ana-header>
            <xsl:value-of select="concat($anaHeaderDir, '/')"/>
            <xsl:choose>
              <xsl:when test="$type = 'ana'">
	              <xsl:value-of select="replace(@href, '\.ana\.xml', '.ana.header.xml')"/>
	            </xsl:when>
              <xsl:when test="$type = 'txt'">
	              <xsl:value-of select="replace(@href, '\.xml', '.ana.header.xml')"/>
	            </xsl:when>
	          </xsl:choose>
          </url-ana-header>
          <url-header>
            <xsl:value-of select="concat($outHeaderDir, '/', replace(@href, '\.xml', '.header.xml'))"/>
          </url-header>
  </xsl:if>
      </item>
    </xsl:for-each>
  </xsl:variable>

  <!-- docs to process in chunk -->
  <xsl:variable name="docsChunk">
  <xsl:message select="concat('INFO: Processing chunk from ', $chunkStart, ' to ', $chunkStart + $chunkSize)"/>
    <xsl:copy-of select="$docs//tei:item[mk:in-chunk(@position)]"/>  
  </xsl:variable>
  <!--
  <xsl:variable name="lastChunk" 
                select="$docsChunk//tei:item[last()]/@position = count($docs//tei:item)"/> -->
  <xsl:variable name="lastChunk" 
                select="$docs//tei:item[last()]/mk:in-chunk(@position)"/>
  <xsl:function name="mk:in-chunk" as="xs:boolean">
    <xsl:param name="position"/>
    <xsl:sequence select="if 
                          (xs:integer($position) gt xs:integer($chunkStart) and (xs:integer($position) le $chunkStart + $chunkSize or $chunkSize = 0)) 
                          then true() 
                          else false()"/>
  </xsl:function>

  <!-- Numbers of words in component files -->
  <xsl:variable name="words">
    <xsl:variable name="id" select="tei:teiCorpus/@xml:id"/>
    <xsl:for-each select="$docs/tei:item[@type = 'component' and ($lastChunk or mk:in-chunk(@position))]">
      <item n="{tei:xi-orig}">
        <xsl:choose>
          <!-- For .ana files, compute number of words -->
          <xsl:when test="$type = 'ana'">
            <xsl:choose>
              <xsl:when test="doc-available(tei:url-header)">
                <xsl:message select="concat('INFO: Using words from header file ', replace(tei:url-header,'.*/',''))"/>
                <xsl:value-of select="document(tei:url-header)//tei:extent/tei:measure[@unit='words'][1]/@quantity"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="document(tei:url-orig)/
                                      count(//tei:w[not(parent::tei:w)])"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <!-- For plain files, take number of words from .ana.header files -->
          <xsl:when test="doc-available(tei:url-ana-header)">
            <xsl:message select="concat('INFO: Using words from ana-header file ', replace(tei:url-ana-header,'.*/',''))"/>
            <xsl:value-of select="document(tei:url-ana-header)//tei:extent/tei:measure[@unit='words'][1]/@quantity"/>
          </xsl:when>
          <!-- For plain files, take number of words from .ana files -->
          <xsl:when test="doc-available(tei:url-ana)">
            <xsl:value-of select="document(tei:url-ana)/
                                  count(//tei:w[not(parent::tei:w)])"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:message select="concat('ERROR ', $id, 
                                   ': cannot locate .ana file ', tei:url-ana, 
				   ', extents will not be set in TEI!')"/>
              <xsl:value-of select="number('0')"/>
            </xsl:otherwise>
          </xsl:choose>
        </item>
      </xsl:for-each>
  </xsl:variable>
  
  <!-- Numbers of speeches in component files -->
  <xsl:variable name="speeches">
    <xsl:for-each select="$docs/tei:item[@type = 'component' and ($lastChunk or mk:in-chunk(@position))]">
      <item n="{tei:xi-orig}">
        <xsl:choose>
          <xsl:when test="doc-available(tei:url-header)">
            <xsl:message select="concat('INFO: Using speeches from header file ', replace(tei:url-header,'.*/',''))"/>
            <xsl:value-of select="document(tei:url-header)//tei:extent/tei:measure[@unit='speeches'][1]/@quantity"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="document(tei:url-orig)/count(//tei:u)"/>
          </xsl:otherwise>
        </xsl:choose>
      </item>
    </xsl:for-each>
  </xsl:variable>

  <!-- Calculated tagUsages in component files -->
  <xsl:variable name="tagUsages">
    <xsl:for-each select="$docs/tei:item[@type = 'component' and ($lastChunk or mk:in-chunk(@position))]">
      <item n="{tei:xi-orig}">
        <xsl:variable name="context-node" select="."/>
        <xsl:choose>
          <xsl:when test="doc-available(tei:url-header)">
            <xsl:message select="concat('INFO: Using tagUsage from header file ', replace(tei:url-header,'.*/',''))"/>
            <xsl:copy-of select="document(tei:url-header)//tei:tagUsage"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message select="concat('INFO: Compute tagUsage in ', replace(tei:url-orig,'.*/',''))"/>
            <xsl:for-each select="document(tei:url-orig)/
                                  distinct-values(tei:TEI/tei:text/descendant-or-self::tei:*/name())">
              <xsl:sort select="."/>
              <xsl:variable name="elem-name" select="."/>
              <xsl:element name="tagUsage">
                <xsl:attribute name="gi" select="$elem-name"/>
                <xsl:attribute name="occurs" select="$context-node/document(tei:url-orig)/
                                        count(tei:TEI/tei:text/descendant-or-self::tei:*[name()=$elem-name])"/>
              </xsl:element>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose> 
      </item>
    </xsl:for-each>
  </xsl:variable>

  <!-- TOP LEVEL TEMPLATE -->
  <xsl:template match="/">
    <xsl:message select="concat('INFO: Starting to add common content to ', tei:teiCorpus/@xml:id)"/>
    <!-- Process component files -->
    <xsl:message>
      <xsl:text>INFO Starting to process component files</xsl:text>
      <xsl:if test="xs:integer($chunkSize) = 0 or xs:integer($chunkStart) gt 0">
        <xsl:text> from </xsl:text>
        <xsl:value-of select="$docsChunk//tei:item[1]/@position"/>
        <xsl:text> to </xsl:text>
        <xsl:value-of select="$docsChunk//tei:item[last()]/@position"/> 
      </xsl:if>
    </xsl:message>
    <xsl:for-each select="$docsChunk//tei:item">
      <xsl:variable name="this" select="tei:xi-orig"/>
      <xsl:message select="concat('INFO: Processing [',@position,'] ', $this)"/>
      <xsl:choose>
        <!-- Process factorised parts of corpus root teiHeader as if they were root (to fix spacing) -->
        <xsl:when test="@type = 'factorised'">
          <xsl:result-document href="{tei:url-new}">
            <xsl:apply-templates mode="root" select="document(tei:url-orig)"/>
          </xsl:result-document>
        </xsl:when>
        <!-- Process component -->
        <xsl:when test="@type = 'component'">
          <xsl:variable name="componentContent">
            <xsl:apply-templates mode="comp" select="document(tei:url-orig)/tei:TEI">
              <xsl:with-param name="speeches" select="$speeches/tei:item[@n = $this]"/>
              <xsl:with-param name="words" select="$words/tei:item[@n = $this]"/>
              <xsl:with-param name="tagUsages" select="$tagUsages/tei:item[@n = $this]"/>
            </xsl:apply-templates>
          </xsl:variable>
          <xsl:result-document href="{tei:url-new}">
            <xsl:copy-of select="$componentContent"/>
          </xsl:result-document>
          <xsl:result-document href="{tei:url-header}">
            <xsl:apply-templates mode="header" select="$componentContent"/>
          </xsl:result-document>
        </xsl:when>
      </xsl:choose>
    </xsl:for-each>

    <xsl:if test="$lastChunk">
      <xsl:text>STATUS: Processed last chunk</xsl:text> <!-- Do not change this message !!! -->
      <!-- Output Root file -->
      <xsl:message>INFO: processing root </xsl:message>
      <xsl:result-document href="{$outRoot}">
        <xsl:apply-templates mode="root"/>
      </xsl:result-document>
    </xsl:if>
  </xsl:template>

  <xsl:template match="* | @*">
    <xsl:message terminate="yes">All templates must have mode comp or root!</xsl:message>
  </xsl:template>
  
  <!-- PROCESSING COMPONENTS -->
  
  <xsl:template mode="comp" match="tei:*">
    <xsl:param name="speeches"/>
    <xsl:param name="words"/>
    <xsl:param name="tagUsages"/>
    <xsl:copy>
      <xsl:apply-templates mode="comp" select="@*"/>
      <xsl:apply-templates mode="comp">
        <xsl:with-param name="speeches" select="$speeches"/>
        <xsl:with-param name="words" select="$words"/>
        <xsl:with-param name="tagUsages" select="$tagUsages"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  <xsl:template mode="comp" match="@*">
    <xsl:copy/>
  </xsl:template>

  <xsl:template mode="comp" match="tei:TEI/@xml:id">
    <xsl:variable name="id" select="replace(base-uri(), '^.*?([^/]+)\.xml$', '$1')"/>
    <xsl:attribute name="xml:id" select="$id"/>
    <xsl:if test=". != $id">
      <xsl:message select="concat('WARN ', @xml:id, 
                               ': fixing TEI/@xml:id to ', $id)"/>
    </xsl:if>
  </xsl:template>
  
  <!-- Set subcorpus or subcorpora info for component -->
  <xsl:template mode="comp" match="tei:TEI/@ana | tei:text/@ana">
    <xsl:variable name="id" select="ancestor::tei:TEI/@xml:id"/>
    <xsl:variable name="date" select="ancestor::tei:TEI/tei:teiHeader//tei:setting/tei:date/@when"/>
    <!-- Set subcorpus or subcorpora (needs to be space normalised!) -->
    <xsl:variable name="subcorpora">
      <xsl:if test="$reference-date &gt;= $date"> #reference </xsl:if>
      <xsl:if test="$covid-date &lt;= $date"> #covid </xsl:if>
      <xsl:if test="$war-date &lt;= $date"> #war </xsl:if>
    </xsl:variable>
    <xsl:variable name="ana">
      <!-- Ignore old subcorpus labels (but preserve the other labels) and insert new ones -->
      <xsl:for-each select="tokenize(., ' ')">
        <xsl:if test=". != '#reference' and  . != '#covid' and  . != '#war'">
	  <xsl:value-of select="."/>
	  <xsl:text>&#32;</xsl:text>
	</xsl:if>
      </xsl:for-each>
      <xsl:value-of select="normalize-space($subcorpora)"/>
    </xsl:variable>
    <xsl:if test="not(normalize-space($date))">
      <xsl:message select="concat('ERROR ', $id, ': no date in setting!')"/>
    </xsl:if>
    <xsl:attribute name="ana">
      <xsl:message select="concat('INFO ', $id, ': setting references ', $ana, ' for ', $date)"/>
      <xsl:value-of select="$ana"/>
    </xsl:attribute>
  </xsl:template>
  
  <!-- Same as for root -->
  <xsl:template mode="comp" match="tei:teiHeader//text()">
    <xsl:apply-templates mode="root" select="."/>
  </xsl:template>
  <xsl:template mode="comp" match="tei:titleStmt/tei:title[@type = 'main']">
    <xsl:apply-templates mode="root" select="."/>
  </xsl:template>
  <xsl:template mode="comp" match="tei:publicationStmt">
    <xsl:apply-templates mode="root" select="."/>
  </xsl:template>
  <xsl:template mode="comp" match="tei:editionStmt">
    <xsl:apply-templates mode="root" select="."/>
  </xsl:template>
  <xsl:template mode="comp" match="tei:idno">
    <xsl:apply-templates mode="root" select="."/>
  </xsl:template>
  <xsl:template mode="comp" match="tei:projectDesc">
    <xsl:apply-templates mode="root" select="."/>
  </xsl:template>
  <xsl:template mode="comp" match="tei:meeting">
    <xsl:apply-templates mode="root" select="."/>
  </xsl:template>
  
  <xsl:template mode="comp" match="tei:extent/tei:measure[@unit='speeches']">
    <xsl:param name="speeches"/>
    <xsl:variable name="old-speeches" select="@quantity"/>
    <xsl:copy>
      <xsl:apply-templates mode="comp" select="@*"/>
      <xsl:if test="normalize-space($speeches) and $speeches != '0'">
        <xsl:attribute name="quantity" select="$speeches"/>
        <xsl:if test="$old-speeches != $speeches">
          <xsl:message select="concat('WARN ', /tei:TEI/@xml:id, 
                               ': replacing speeches ', $old-speeches, ' with ', $speeches)"/>
        </xsl:if>
        <xsl:value-of select="replace(., '.+ ', concat(
                              et:format-number(ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang, $speeches), 
                              ' '))"/>
      </xsl:if>
    </xsl:copy>
  </xsl:template>  

  <xsl:template mode="comp" match="tei:extent/tei:measure[@unit='words']">
    <xsl:param name="words"/>
    <xsl:variable name="old-words" select="@quantity"/>
    <xsl:copy>
      <xsl:apply-templates mode="comp" select="@*"/>
      <xsl:if test="normalize-space($words) and $words != '0'">
        <xsl:attribute name="quantity" select="$words"/>
        <xsl:if test="$old-words != $words">
          <xsl:message select="concat('INFO ', /tei:*/@xml:id,
                               ': replacing words ', $old-words, ' with ', $words)"/>
        </xsl:if>
        <xsl:value-of select="replace(., '.+ ', concat(
                            et:format-number(ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang, $words),
                            ' '))"/>
      </xsl:if>
    </xsl:copy>
  </xsl:template>  

  <!-- Fix div/@type="debateSection" to ="commentSection" if div contains no utterances -->
  <xsl:template mode="comp" match="tei:div[@type='debateSection'][not(tei:u)]">
    <xsl:message select="concat('WARN ', /tei:TEI/@xml:id, 
                         ': no utterances in div/@type=debateSection, ',
			 'replacing with commentSection')"/>

    <xsl:copy>
      <xsl:apply-templates mode="comp" select="@*"/>
      <xsl:attribute name="type">commentSection</xsl:attribute>
      <xsl:apply-templates mode="comp"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="comp" match="tei:encodingDesc">
    <xsl:param name="tagUsages"/>
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates mode="comp" select="@*"/>
      <xsl:apply-templates mode="comp" select="./tei:projectDesc"/>
      <xsl:apply-templates mode="comp" select="./tei:editorialDecl"/>
      <xsl:call-template name="add-tagsDecl">
        <xsl:with-param name="tagUsages" select="$tagUsages"/>
      </xsl:call-template>
      <xsl:apply-templates mode="comp" select="./tei:classDecl"/>
      <xsl:apply-templates mode="comp" select="./tei:listPrefixDef"/>
      <xsl:apply-templates mode="comp" select="./tei:appInfo"/>
    </xsl:copy>
  </xsl:template>

  <!-- Silently give IDs to segs without them (if u has ID, otherwise complain) -->
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
      
  <!-- Silently give IDs to the various transcriber comments -->
  <xsl:template mode="comp" match="tei:head[not(@xml:id)] | 
				   tei:gap[not(@xml:id)] |
				   tei:note[not(@xml:id)] |
				   tei:vocal[not(@xml:id)] | 
				   tei:kinesic[not(@xml:id)] |
				   tei:incident[not(@xml:id)]">
    <xsl:copy>
      <xsl:apply-templates mode="comp" select="@*"/>
      <xsl:attribute name="xml:id">
	<xsl:value-of select="ancestor::tei:TEI/@xml:id"/>
        <xsl:text>.</xsl:text>
	<xsl:value-of select="name()"/>
        <xsl:number level="any" from="text"/>
      </xsl:attribute>
      <xsl:apply-templates mode="comp"/>
    </xsl:copy>
  </xsl:template>
  <!-- FILTERING COMPONENTS - HEADER -->
  <xsl:template mode="header" match="/tei:TEI/tei:text"/>
  <xsl:template mode="header" match="*">
    <xsl:copy>
      <xsl:apply-templates mode="header" select="@*"/>
      <xsl:apply-templates mode="header"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template mode="header" match="@*">
    <xsl:copy/>
  </xsl:template>  
  <!-- PROCESSING ROOT -->
  
  <xsl:template mode="root" match="*">
    <xsl:copy>
      <xsl:apply-templates mode="root" select="@*"/>
      <xsl:apply-templates mode="root"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template mode="root" match="@*">
    <xsl:copy/>
  </xsl:template>
  
  <xsl:template mode="root" match="tei:teiCorpus">
    <xsl:copy>
      <xsl:apply-templates mode="root" select="@*"/>
      <xsl:apply-templates mode="root" select="tei:*"/>
      <xsl:for-each select="xi:include">
        <xsl:sort select="@href"/>
        <xsl:copy-of select="."/>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="root" match="tei:teiCorpus/@xml:id">
    <xsl:variable name="id" select="replace(base-uri(), '^.*?([^/]+)\.xml$', '$1')"/>
    <xsl:attribute name="xml:id" select="$id"/>
    <xsl:if test=". != $id">
      <xsl:message select="concat('WARN ', @xml:id, 
                               ': fixing teiCorpus/@xml:id to ', $id)"/>
    </xsl:if>
  </xsl:template>
  
  <!-- Check main title if it has the correct stamp, and replace if not -->
  <xsl:template mode="root" match="tei:titleStmt/tei:title[@type = 'main']">
    <xsl:variable name="okStamp">
      <xsl:text>[ParlaMint</xsl:text>
      <xsl:if test="normalize-space($mt)">
	<xsl:value-of select="concat('-', $mt)"/>
      </xsl:if>
      <xsl:if test="$type = 'ana'">.ana</xsl:if>
      <xsl:text>]</xsl:text>
    </xsl:variable>
    <xsl:variable name="stamp" select="replace(., '.+(\[.+\])$', '$1')"/>
    <xsl:copy>
      <xsl:apply-templates mode="root" select="@*"/>
      <xsl:choose>
	<xsl:when test="$stamp = $okStamp">
	  <xsl:value-of select="normalize-space(.)"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="replace(., '(.+?)\s*\[.+\]$', concat('$1', ' ', $okStamp))"/>
          <xsl:message select="concat('WARN ', /tei:TEI/@xml:id, 
                               ': replacing title stamp ', $stamp, ' with ', $okStamp)"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="root" match="tei:extent">
    <xsl:copy>
      <xsl:apply-templates mode="root" select="@*"/>
      <!-- Schema does not allow "sessions", and it is not clear if this is the right term to use for the number of files anyway! -->
      <!--xsl:if test="not(tei:measure[@unit='sessions'])">
	<xsl:message select="concat('WARN ', /tei:teiCorpus/@xml:id, 
                             ': no root measure for sessions, adding it in English only!')"/>
	<xsl:call-template name="add-measure">
	  <xsl:with-param name="unit">sessions</xsl:with-param>
	  <xsl:with-param name="lang">en</xsl:with-param>
	</xsl:call-template>
      </xsl:if-->
      <xsl:if test="not(tei:measure[@unit='speeches'])">
	<xsl:message select="concat('WARN ', /tei:teiCorpus/@xml:id, 
                             ': no root measure for speeches, adding it in English only!')"/>
	<xsl:call-template name="add-measure">
	  <xsl:with-param name="unit">speeches</xsl:with-param>
	  <xsl:with-param name="lang">en</xsl:with-param>
	</xsl:call-template>
      </xsl:if>
      <xsl:if test="not(tei:measure[@unit='words'])">
	<xsl:message select="concat('WARN ', /tei:teiCorpus/@xml:id, 
                             ': no root measure for words, adding it in English only!')"/>
	<xsl:call-template name="add-measure">
	  <xsl:with-param name="unit">words</xsl:with-param>
	  <xsl:with-param name="lang">en</xsl:with-param>
	</xsl:call-template>
      </xsl:if>
      <xsl:apply-templates mode="root"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="root" match="tei:measure[@unit='sessions' or @unit='speeches' or @unit='words']">
    <xsl:call-template name="add-measure"/>
  </xsl:template>

  <!-- Add textClass if missing and houses information is present-->
  <xsl:template mode="root" match="tei:settingDesc">
    <xsl:copy>
      <xsl:apply-templates mode="root" select="@*"/>
      <xsl:apply-templates mode="root"/>
    </xsl:copy>
    <xsl:if test="not(../tei:textClass)">
      <xsl:choose>
        <xsl:when test="$houses/tei:term">
          <xsl:message>
            <xsl:value-of select="concat('INFO ', /tei:*/@xml:id,
                                  ': inserting textClass for')"/>
            <xsl:for-each select="$houses/tei:term">
              <xsl:value-of select="concat(' ', .)"/>
            </xsl:for-each>
          </xsl:message>
          <textClass>
            <catRef scheme="{$house-refs/tei:ref[. = 'Legislature']/@target}">
              <xsl:attribute name="target">
                <xsl:variable name="targets">
                  <xsl:for-each select="$house-refs/tei:ref">
                    <xsl:if test=". != 'Legislature'">
                      <xsl:value-of select="@target"/>
                      <xsl:text>&#32;</xsl:text>
                    </xsl:if>
                  </xsl:for-each>
                </xsl:variable>
                <xsl:value-of select="normalize-space($targets)"/>
              </xsl:attribute>
            </catRef>
          </textClass>
        </xsl:when>
        <xsl:otherwise>
            <xsl:message select="concat('ERROR ', /tei:teiCorpus/@xml:id,
                                 ': missing textClass and unable to add it automaticaly!')"/>
          <xsl:comment>textClass</xsl:comment>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <!-- If necessary, insert information on which parliamentary body having the meeting: 
       unicameralism, lower and/or upper (house), committe -->
  <!-- $house-refs give info on which is which and what they contain -->
  <!-- Some corpora have both houses, here we decide on the basis of the main title -->
  <xsl:template mode="root" match="tei:meeting">
    <xsl:copy>
      <xsl:apply-templates mode="root" select="@*"/>
      <!-- We need to collect all meeting/@ana values, so we wouldn't put the wrong body ref into one that is missing it
           as we can have e.g.
           <meeting corresp="#be_federal_parliament" ana="#parla.meeting.committee" n="ic001">Commissievergadering 001 van 17-07-2014</meeting>
           <meeting ana="#parla.term #period_54" corresp="#be_federal_parliament" n="54">Zittingperiode 54</meeting>
      -->
      <xsl:variable name="anas">
	<xsl:for-each select="../tei:meeting">
	  <xsl:value-of select="@ana"/>
	  <xsl:text>&#32;</xsl:text>
	</xsl:for-each>
      </xsl:variable>
      <!-- Note that we don't make any provision for inserting reference to commitee meeting! -->
      <xsl:if test="not(
		    contains($anas, 'parla.uni') or 
		    contains($anas, 'parla.upper') or contains($anas, 'parla.lower') or 
		    contains($anas, 'parla.committee')
		    )">
        <xsl:variable name="house">
          <xsl:choose>
	    <xsl:when test="$house-refs/tei:ref[. = 'Unicameralism']">
	      <xsl:copy-of select="$house-refs/tei:ref[. = 'Unicameralism']"/>
            </xsl:when>
            <xsl:when test="$house-refs/tei:ref[. = 'Lower house'] and
                            not($house-refs/tei:ref[. = 'Upper house'])">
	      <xsl:copy-of select="$house-refs/tei:ref[. = 'Lower house']"/>
            </xsl:when>
            <xsl:when test="$house-refs/tei:ref[. = 'Upper house'] and
                            not($house-refs/tei:ref[. = 'Lower house'])">
	      <xsl:copy-of select="$house-refs/tei:ref[. = 'Upper house']"/>
            </xsl:when>
            <xsl:otherwise>
	      <xsl:message terminate="yes" select="concat('FATAL ERROR: ', ancestor::tei:*[@xml:id][1]/@xml:id,
                                                   ': BAD HOUSES FOR COUNTRY IN THIS SCRIPT!')"/>
	    </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="normalize-space($house)">
            <xsl:variable name="refs">
	      <xsl:for-each select="$house/tei:ref">
                <xsl:value-of select="@target"/>
                <xsl:text>&#32;</xsl:text>
	      </xsl:for-each>
            </xsl:variable>
            <xsl:message select="concat('WARN ', /tei:*/@xml:id,
				 ': inserting ', $refs, 'into meeting/@ana ', @ana)"/>
            <xsl:attribute name="ana" select="concat($refs, @ana)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message terminate="yes" select="concat('FATAL ERROR: ', /tei:TEI/@xml:id,
						 ': COULD NOT FIND HOUSES FOR MEETING ELEMENT!')"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      <xsl:apply-templates mode="root"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="root" match="tei:publicationStmt/tei:date">
    <xsl:copy>
      <xsl:apply-templates mode="root" select="@*"/>
      <xsl:attribute name="when" select="$today-iso"/>
      <xsl:value-of select="$today-iso"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="root" match="tei:editionStmt/tei:edition">
    <xsl:copy>
      <xsl:apply-templates mode="root" select="@*"/>
      <xsl:if test="$version != .">
        <xsl:message select="concat('INFO ', /tei:*/@xml:id,
                             ': replacing version ', ., ' with ', $version)"/>
      </xsl:if>
      <xsl:value-of select="$version"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="root" match="tei:projectDesc">
    <xsl:copy>
      <xsl:apply-templates mode="root" select="@*"/>
      <xsl:choose>
	<xsl:when test="tei:p[@xml:lang = 'en']">
          <xsl:message select="concat('INFO ', ancestor-or-self::tei:*[@xml:id][1]/@xml:id,
                               ': replacing English project description')"/>
	</xsl:when>
	<xsl:otherwise>
          <xsl:message select="concat('INFO ', ancestor-or-self::tei:*[@xml:id][1]/@xml:id,
                               ': inserting English project description')"/>
	</xsl:otherwise>
      </xsl:choose>
      <xsl:copy-of select="$projectDesc-en"/>
      <xsl:apply-templates mode="root" select="tei:*[not(self::tei:p[@xml:lang = 'en'])]"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="root" match="tei:revisionDesc">
    <xsl:copy>
      <xsl:apply-templates mode="root" select="@*"/>
      <xsl:apply-templates mode="root" select="*"/>
      <change when="{$today-iso}">parlamint-add-common-content script: Adding common content.</change>
    </xsl:copy>
  </xsl:template>

  <xsl:template mode="root" match="tei:idno">
    <xsl:copy>
      <xsl:choose>
	<xsl:when test="ancestor::tei:publicationStmt and contains(., 'hdl.handle.net')">
	  <xsl:attribute name="type">URI</xsl:attribute>
	  <xsl:attribute name="subtype">handle</xsl:attribute>
	  <xsl:choose>
            <xsl:when test="$type = 'txt'">
              <xsl:value-of select="$handle-txt"/>
            </xsl:when>
            <xsl:when test="$type = 'ana'">
              <xsl:value-of select="$handle-ana"/>
            </xsl:when>
	  </xsl:choose>
	</xsl:when>
	<xsl:when test="ancestor::tei:sourceDesc">
	  <xsl:attribute name="type">URI</xsl:attribute>
	  <xsl:attribute name="subtype">parliament</xsl:attribute>
          <xsl:value-of select="normalize-space(.)"/>
	</xsl:when>
	<xsl:when test="@type and @subtype">
	  <xsl:attribute name="type" select="@type"/>
	  <xsl:attribute name="subtype" select="@subtype"/>
          <xsl:value-of select="normalize-space(.)"/>
	</xsl:when>
	<xsl:when test="@type">
	  <xsl:message select="concat('WARN ', /tei:*/@xml:id, 
                               ': idno without subtype, content is ', .)"/>
	  <xsl:attribute name="type" select="@type"/>
          <xsl:value-of select="normalize-space(.)"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:message select="concat('ERROR ', /tei:*/@xml:id, 
                               ': idno without type, content is ', .)"/>
          <xsl:value-of select="normalize-space(.)"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <xsl:template mode="root" match="tei:publicationStmt[tei:idno]/
                       tei:pubPlace[tei:ref[matches(@target, 'hdl.handle.net')]]">
    <xsl:message select="concat('WARN ', /tei:teiCorpus/@xml:id, 
                         ': deleting redundant pubPlace')"/>
  </xsl:template>

  <xsl:template mode="root" match="tei:encodingDesc">
    <xsl:variable name="tagUsagesSum">
    </xsl:variable>
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates mode="root" select="@*"/>
      <xsl:apply-templates mode="root" select="./tei:projectDesc"/>
      <xsl:apply-templates mode="root" select="./tei:editorialDecl"/>
      <xsl:call-template name="add-tagsDecl">
        <xsl:with-param name="tagUsages">
          <xsl:for-each select="distinct-values($tagUsages//@gi)">
            <xsl:sort select="."/>
            <xsl:variable name="elem-name" select="."/>
            <xsl:element name="tagUsage">
              <xsl:attribute name="gi" select="$elem-name"/>
              <xsl:attribute name="occurs" select="sum($tagUsages//*[@gi=$elem-name]/@occurs)"/>
            </xsl:element>
          </xsl:for-each>
         </xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates mode="root" select="./tei:classDecl"/>
      <xsl:apply-templates mode="root" select="./tei:listPrefixDef"/>
      <xsl:apply-templates mode="root" select="./tei:appInfo"/>
    </xsl:copy>
  </xsl:template>

  <!-- Insert government organisation if missing -->
  <xsl:template mode="root" match="tei:listOrg">
    <xsl:copy>
      <xsl:apply-templates mode="root" select="@*"/>
      <xsl:if test="not(.//tei:org[@role = 'government'])">
        <xsl:variable name="government-id" select="concat('government.' , $country-code)"/>
        <xsl:variable name="government-name" select="concat($country-name, ' Government')"/>
        <xsl:message select="concat('WARN ', /tei:teiCorpus/@xml:id,
                             ': inserting government organisation ', $government-name,
                             ' with ID ', $government-id)"/>
        <org xml:id="{$government-id}" role="government">
          <orgName xml:lang="en" full="yes">
            <xsl:value-of select="$government-name"/>
          </orgName>
        </org>
      </xsl:if>
      <xsl:apply-templates mode="root"/>
    </xsl:copy>
  </xsl:template>

  <!-- Remove @xml:lang from term (not needed, as superordiante catDesc should have @xml:lang -->
  <xsl:template mode="root" match="tei:catDesc/tei:term">
    <xsl:copy>
      <xsl:apply-templates mode="root" select="@*[name() != 'xml:lang']"/>
      <xsl:apply-templates mode="root"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- Remove leading, trailing and multiple spaces -->
  <xsl:template mode="root" match="text()[normalize-space(.)]">
    <xsl:variable name="str">
      <xsl:variable name="s" select="replace(., '\s+', ' ')"/>
      <xsl:choose>
	<xsl:when test="(not(preceding-sibling::tei:*) and starts-with($s, ' ')) and 
			(not(following-sibling::tei:*) and matches($s, ' $'))">
          <xsl:value-of select="replace($s, '^ (.+?) $', '$1')"/>
	</xsl:when>
	<xsl:when test="not(preceding-sibling::tei:*) and ends-with($s, ' ')">
          <xsl:value-of select="replace($s, '^ ', '')"/>
	</xsl:when>
	<xsl:when test="not(following-sibling::tei:*) and ends-with($s, ' ')">
          <xsl:value-of select="replace($s, ' $', '')"/>
	</xsl:when>
	<xsl:otherwise>
          <xsl:value-of select="$s"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test=". != $str ">
      <xsl:message select="concat('WARN ', /tei:*/@xml:id, 
                           ': removing spurious space from &quot;', replace(., '\s', '_'), '&quot;')"/>
    </xsl:if>
    <xsl:value-of select="$str"/>
  </xsl:template>
  
    <!-- Output root <measure> for a given $unit. 
	 If $lang is set, it is assumed that the unit measure is not present in input, so it has to be constructed from scratch 
    -->
    <xsl:template name="add-measure">
      <xsl:param name="unit" select="@unit"/>
      <xsl:param name="lang"/>
      <xsl:variable name="quant">
	<xsl:choose>
          <xsl:when test="$unit='sessions'">
            <xsl:value-of select="count($docs/tei:item[@type = 'component'])"/>
          </xsl:when>
          <xsl:when test="$unit='speeches'">
            <xsl:value-of select="sum($speeches/tei:item)"/>
          </xsl:when>
          <xsl:when test="$unit='words'">
            <xsl:value-of select="sum($words/tei:item)"/>
          </xsl:when>
	</xsl:choose>
      </xsl:variable>
      <xsl:variable name="quant-formatted"
		    select="et:format-number(ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang, $quant)"/>
      <xsl:choose>
	<xsl:when test="normalize-space($quant) and $quant != '0'">
	  <measure>
            <xsl:attribute name="unit" select="$unit"/>
            <xsl:attribute name="quantity" select="format-number($quant, '#')"/>
	    <xsl:attribute name="xml:lang">
	      <xsl:choose>
		<xsl:when test="normalize-space($lang)">
		  <xsl:value-of select="$lang"/>
		</xsl:when>
		<xsl:otherwise>
		  <xsl:value-of select="ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang"/>
		</xsl:otherwise>
	      </xsl:choose>
	    </xsl:attribute>
	    <xsl:choose>
	      <xsl:when test="normalize-space($lang)">
		<xsl:value-of select="concat($quant-formatted, ' ', $unit)"/>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:value-of select="replace(., '.+ ', concat($quant-formatted, ' '))"/>
	      </xsl:otherwise>
	    </xsl:choose>
	  </measure>
	</xsl:when>
	<xsl:otherwise>
          <xsl:message select="concat('ERROR ', /tei:*/@xml:id, 
                               ': no count for measure ', $unit)"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:template>
    
    <xsl:template name="add-tagsDecl">
      <xsl:param name="tagUsages"/>
      <xsl:variable name="context" select="./tei:tagsDecl/tei:namespace[@name='http://www.tei-c.org/ns/1.0']"/>
      <xsl:element name="tagsDecl">
	<xsl:element name="namespace">
          <xsl:attribute name="name">http://www.tei-c.org/ns/1.0</xsl:attribute>
          <xsl:for-each select="distinct-values(($tagUsages//@gi,$context//@gi))">
            <xsl:sort select="."/>
            <xsl:variable name="elem-name" select="."/>
            <xsl:variable name="new" select="$tagUsages//*:tagUsage[@gi=$elem-name]"/>
            <xsl:variable name="old" select="$context//*:tagUsage[@gi=$elem-name]"/>
            <xsl:choose>
              <xsl:when test="$new and not($old)">
		<xsl:message select="$context/concat('INFO ', /tei:*/@xml:id,
				     ': adding ',$elem-name,' tagUsage ', $new/@occurs)"/>
              </xsl:when>
              <xsl:when test="not($new) and $old">
		<xsl:message select="$context/concat('INFO ', /tei:*/@xml:id,
				     ': removing ',$elem-name,' tagUsage ', $old/@occurs)"/>
              </xsl:when>
              <xsl:when test="not($new/@occurs = $old/@occurs)">
		<xsl:message select="$context/concat('INFO ', /tei:*/@xml:id,
				     ': replacing ',$elem-name,' tagUsage ', $old/@occurs, ' with ', $new/@occurs)"/>
              </xsl:when>
              <xsl:when test="$new/@occurs = $old/@occurs">
		<!--xsl:message select="$context/concat('INFO ', /tei:*/@xml:id,
                    ': preserving ',$elem-name,' tagUsage ', $new/@occurs)"/-->
              </xsl:when>
            </xsl:choose>
	    <!-- Need to format the number again, otherwise output in scientific notation -->
	    <xsl:if test="$new">
	      <tagUsage gi="{$new/@gi}">
		<xsl:attribute name="occurs" select="format-number($new/@occurs, '#')"/>
	      </tagUsage>
	    </xsl:if>
          </xsl:for-each>
	</xsl:element>
      </xsl:element>
    </xsl:template>
    
  </xsl:stylesheet>
