<?xml version="1.0"?>
<!-- Finalize the encoding of a ParlaMint corpus (Source language version) -->
<!-- Takes root file as input, and outputs it and all finalized component files to outDir:
     - set release date to today
     - set version and handles for 2.1
     - set correct subcorpus
     - get rid of spurious handle ref
     - get rid of spurious spaces
     - insert government org, if missing
     - remove speaker "parties" from GB, and change affiliation for such speakers
     - insert bi- or uni-cameralism if missing
     - insert lower/upper house into bicameral meeting elements if missing
     - calculate extents in component ana files, warn if changed
     - insert word extents from ana into plain version
     - insert tagcounts in root (taken from component files and not changed there!)
     - fix UD terms for extended relations in .ana (i.e. substitute "_" with ":"
     - fix "_" lemmas for w elements (for IT)
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

  <!-- Directories must have absolute paths! -->
  <xsl:param name="outDir">.</xsl:param>
  <xsl:param name="anaDir">.</xsl:param>
  <xsl:param name="version">2.2</xsl:param>
  <xsl:param name="covid-date" as="xs:date">2019-11-01</xsl:param>
  <xsl:param name="handle-txt">http://hdl.handle.net/11356/XXXX</xsl:param>
  <xsl:param name="handle-ana">http://hdl.handle.net/11356/XXXX</xsl:param>
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
  
  <xsl:output method="xml" indent="yes"/>
  <xsl:preserve-space elements="catDesc seg"/>

  <xsl:variable name="houses">
    <xsl:choose>
      <xsl:when test="$country-code = 'BG'">
	<term>Unicameralism</term>
      </xsl:when>
      <xsl:when test="$country-code = 'DK'">
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
      <xsl:when test="$country-code = 'IS'">
	<term>Legislature</term>
	<term>Unicameralism</term>
      </xsl:when>
      <xsl:when test="$country-code = 'LT'">
	<term>Legislature</term>
	<term>Unicameralism</term>
      </xsl:when>
      <xsl:when test="$country-code = 'LV'">
	<term>Legislature</term>
	<term>Unicameralism</term>
      </xsl:when>
      <xsl:when test="$country-code = 'TR'">
	<term>Legislature</term>
	<term>Unicameralism</term>
      </xsl:when>
      <xsl:when test="$country-code = 'BE'">
	<term>Legislature</term>
	<term>Bicameralism</term>
	<term>Lower house</term>
      </xsl:when>
      <xsl:when test="$country-code = 'CZ'">
	<term>Legislature</term>
	<term>Bicameralism</term>
	<term>Lower house</term>
      </xsl:when>
      <xsl:when test="$country-code = 'ES'">
	<term>Legislature</term>
	<term>Bicameralism</term>
	<term>Lower house</term>
      </xsl:when>
      <xsl:when test="$country-code = 'ES-CT'">
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
      <xsl:when test="$country-code = 'IT'">
	<term>Legislature</term>
	<term>Bicameralism</term>
	<term>Upper house</term>
      </xsl:when>
      <xsl:when test="$country-code = 'NL'">
	<term>Legislature</term>
	<term>Bicameralism</term>
	<term>Lower house</term>
	<term>Upper house</term>
      </xsl:when>
      <xsl:when test="$country-code = 'PL'">
	<term>Legislature</term>
	<term>Bicameralism</term>
	<term>Lower house</term>
	<term>Upper house</term>
      </xsl:when>
      <xsl:when test="$country-code = 'SI'">
	<term>Legislature</term>
	<term>Bicameralism</term>
	<term>Lower house</term>
      </xsl:when>
      <xsl:when test="$country-code = 'RO'">
	<term>Legislature</term>
	<term>Bicameralism</term>
	<term>Lower house</term>
      </xsl:when>
      <xsl:otherwise>
	<xsl:message terminate="yes" select="concat('FATAL ', /tei:TEI/@xml:id, 
					     ': BAD COUNTRY!')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <xsl:variable name="house-refs">
    <xsl:variable name="taxos" select="//tei:taxonomy"/>
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

  <!-- Gather URIs of component xi + files and map to new files, incl. .ana files -->
  <xsl:variable name="docs">
    <xsl:for-each select="//xi:include">
      <item>
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
    <xsl:for-each select="$docs/tei:item">
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
    <xsl:for-each select="$docs/tei:item">
      <item>
	<xsl:value-of select="document(tei:url-orig)/tei:TEI/tei:teiHeader//
			      tei:extent/tei:measure[@unit = 'speeches'][1]/@quantity"/>
      </item>
    </xsl:for-each>
  </xsl:variable>

  <!-- Get tagUsages in component files -->
  <xsl:variable name="tagUsages">
    <xsl:variable name="tUs">
      <xsl:for-each select="$docs/tei:item/document(tei:url-orig)/
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
	<xsl:apply-templates mode="comp" select="document(tei:url-orig)/tei:TEI">
	<xsl:with-param name="words" select="$words/tei:item[@n = $this]"/>
	</xsl:apply-templates>
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
  
  <!-- Get rid of spurious .ana in eg.
       <title type="main" xml:lang="cs">Český parlamentní korpus ParlaMint-CZ, 
         2013-12-04 ps2013-002-01-000-000.ana [ParlaMint.ana]</title>
  -->
  <xsl:template mode="comp" match="tei:titleStmt/tei:title[@type='main']">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:value-of select="normalize-space(replace(., '\.ana ', ' '))"/>
    </xsl:copy>
  </xsl:template>

  <!-- Same as for root -->
  <xsl:template mode="comp" match="tei:publicationStmt/tei:date">
    <xsl:apply-templates select="."/>
  </xsl:template>
  <xsl:template mode="comp" match="tei:editionStmt/tei:edition">
    <xsl:apply-templates select="."/>
  </xsl:template>
  <xsl:template mode="comp" match="tei:idno[contains(., 'http://hdl.handle.net/11356/')]">
    <xsl:apply-templates select="."/>
  </xsl:template>
  <xsl:template mode="comp" match="tei:publicationStmt[tei:idno]/
		       tei:pubPlace[tei:ref[matches(@target, 'hdl.handle.net')]]">
    <xsl:apply-templates select="."/>
  </xsl:template>
  <xsl:template mode="comp" match="tei:meeting">
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
	  <xsl:message select="concat('INFO ', /tei:TEI/@xml:id, 
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
      
  <!-- Take care of syntactic words -->
  <xsl:template mode="comp" match="tei:w[tei:w]">
    <xsl:choose>
      <xsl:when test="tei:w[2]">
	<xsl:copy>
	  <xsl:apply-templates mode="comp" select="@*"/>
	  <xsl:apply-templates mode="comp"/>
	</xsl:copy>
      </xsl:when>
      <!-- Bad syntactic word with just one word, like:
           <w xml:id="ParlaMint-IT_2013-06-25-LEG17-Sed-50.seg160.23.39-39">gli
             <w xml:id="ParlaMint-IT_2013-06-25-LEG17-Sed-50.seg160.23.39"
                norm="gli" 
                lemma="il"
                pos="RD"
                msd="UPosTag=DET|Definite=Def|Gender=Masc|Number=Plur|PronType=Art"/>
           </w>
      -->
      <xsl:otherwise>
	<xsl:message select="concat('WARN ', /tei:TEI/@xml:id, 
			     ': removing useless syntactic word ', @xml:id)"/>
	<xsl:copy>
	  <xsl:apply-templates mode="comp" select="tei:w/@*[name() != 'norm']"/>
	  <xsl:value-of select="normalize-space(.)"/>
	</xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
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
  
  <!-- Remove leading, trailing and multiple spaces -->
  <xsl:template mode="comp" match="text()[normalize-space(.)]">
    <xsl:variable name="str" select="replace(., '\s+', ' ')"/>
    <xsl:choose>
      <xsl:when test="(not(preceding-sibling::tei:*) and matches($str, '^ ')) and 
		      (not(following-sibling::tei:*) and matches($str, ' $'))">
	<xsl:value-of select="replace($str, '^ (.+?) $', '$1')"/>
      </xsl:when>
      <xsl:when test="not(preceding-sibling::tei:*) and matches($str, '^ ')">
	<xsl:value-of select="replace($str, '^ ', '')"/>
      </xsl:when>
      <xsl:when test="not(following-sibling::tei:*) and matches($str, ' $')">
	<xsl:value-of select="replace($str, ' $', '')"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$str"/>
      </xsl:otherwise>
    </xsl:choose>
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
	<!-- Don't sort just by date, as otherwise if one date has more than one file,
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
	    <xsl:value-of select="count($docs/tei:item)"/>
	  </xsl:when>
	  <xsl:when test="@unit='speeches'">
	    <xsl:value-of select="sum($speeches/tei:item)"/>
	  </xsl:when>
	  <xsl:when test="@unit='words'">
	    <xsl:value-of select="sum($words/tei:item)"/>
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
  
  <xsl:template match="tei:taxonomy[@xml:id = 'UD-SYN']//tei:catDesc/tei:term">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:choose>
	<xsl:when test="contains(., '_')">
	  <xsl:message select="concat('WARN ', /tei:TEI/@xml:id, 
			       ': replacing _ in UD term ', .)"/>
	  <xsl:value-of select="replace(., '_', ':')"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:apply-templates/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>
  
  <!-- Add textClass if missing -->
  <xsl:template match="tei:settingDesc">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
    <xsl:if test="not(../tei:textClass)">
      <xsl:message>
	<xsl:value-of select="concat('INFO ', /tei:TEI/@xml:id, 
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
    </xsl:if>
  </xsl:template>

  <!-- Insert lower and/or upper (house) for bicameral ones -->
  <!-- $house-refs give info on whic is which and what they contain -->
  <!-- GB and NL have both, where we decide on the basis of the main title -->
  <xsl:template match="tei:meeting">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="$house-refs/tei:ref[. = 'Bicameralism'] and 
		    not(contains(@ana, 'parla.lower') or contains(@ana, 'parla.upper'))">
	<xsl:variable name="house">
	  <xsl:choose>
	    <xsl:when test="not($house-refs/tei:ref[. = 'Lower house']) and
			    not($house-refs/tei:ref[. = 'Upper house'])">
	      <xsl:message terminate="yes" select="concat('FATAL ', /tei:TEI/@xml:id, 
						   ': NO HOUSES!')"/>
	    </xsl:when>
	    <xsl:when test="$house-refs/tei:ref[. = 'Lower house'] and
			    not($house-refs/tei:ref[. = 'Upper house'])">
	      <xsl:copy-of select="$house-refs/tei:ref[. = 'Lower house']"/>
	    </xsl:when>
	    <xsl:when test="$house-refs/tei:ref[. = 'Upper house'] and
			    not($house-refs/tei:ref[. = 'Lower house'])">
	      <xsl:copy-of select="$house-refs/tei:ref[. = 'Upper house']"/>
	    </xsl:when>
	    <xsl:when test="$country-code = 'GB' and /tei:teiCorpus">
	      <xsl:copy-of select="$house-refs/tei:ref[. = 'Upper house']"/>
	      <xsl:copy-of select="$house-refs/tei:ref[. = 'Lower house']"/>
	    </xsl:when>
	    <xsl:when test="$country-code = 'GB' and 
			    contains(/tei:TEI/tei:teiHeader//tei:titleStmt
			    /tei:title[@type='main'],
			    'Commons')">
	      <xsl:copy-of select="$house-refs/tei:ref[. = 'Lower house']"/>
	    </xsl:when>
	    <xsl:when test="$country-code = 'GB' and 
			    contains(/tei:TEI/tei:teiHeader//tei:titleStmt
			    /tei:title[@type='main'],
			    'Lords')">
	      <xsl:copy-of select="$house-refs/tei:ref[. = 'Upper house']"/>
	    </xsl:when>
	    <xsl:when test="$country-code = 'NL' and 
			    contains(/tei:TEI/tei:teiHeader//tei:titleStmt
			    /tei:title[@type='main' and @xml:lang='en'],
			    'Lower House')">
	      <xsl:copy-of select="$house-refs/tei:ref[. = 'Lower house']"/>
	    </xsl:when>
	    <xsl:when test="$country-code = 'NL' and 
			    contains(/tei:TEI/tei:teiHeader//tei:titleStmt
			    /tei:title[@type='main' and @xml:lang='en'],
			    'Upper House')">
	      <xsl:copy-of select="$house-refs/tei:ref[. = 'Upper house']"/>
	    </xsl:when>
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
	    <xsl:message select="concat('INFO ', /tei:TEI/@xml:id, 
			     ': inserting ', $refs, 'into meeting/@ana')"/>
	    
	    <xsl:attribute name="ana" select="concat($refs, @ana)"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:message select="concat('ERROR ', /tei:TEI/@xml:id, 
				 ': dont know how to insert houses!')"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tei:publicationStmt/tei:date">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="when" select="$today"/>
      <xsl:value-of select="format-date(current-date(), '[MNn] [D], [Y]')"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tei:editionStmt/tei:edition">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="$version != .">
	<xsl:message select="concat('INFO ', /tei:TEI/@xml:id, 
			     ': replacing version ', ., ' with ', $version)"/>
      </xsl:if>
      <xsl:value-of select="$version"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tei:revisionDesc">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="*"/>
      <change when="{$today}"><name>Tomaž Erjavec</name>: Finalize encoding.</change>
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

  <xsl:template match="tei:publicationStmt[tei:idno]/
		       tei:pubPlace[tei:ref[matches(@target, 'hdl.handle.net')]]">
    <xsl:message select="concat('INFO ', /tei:teiCorpus/@xml:id, 
			 ': deleting redundant pubPlace')"/>
  </xsl:template>
  
  <xsl:template match="tei:tagsDecl/tei:namespace">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*"/>
      <xsl:copy-of copy-namespaces="no" select="$tagUsages"/>
    </xsl:copy>
  </xsl:template>
    
  <!-- Insert government organisation if missing -->
  <xsl:template match="tei:listOrg">
    <xsl:copy>
      <xsl:if test="not(ancestor::tei:particDesc//tei:org[@role = 'government'])">
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
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <!-- Remove the two "speaker" parties from GB, i.e. 
       <org role="politicalParty" xml:id="party.S">
         <orgName full="yes">Speaker</orgName>
         <orgName full="init">S</orgName>
       </org>
       <org role="politicalParty" xml:id="party.LS">
         <orgName full="yes">Lord Speaker</orgName>
         <orgName full="init">LS</orgName>
       </org>
  -->
  <xsl:template match="tei:org[@role='politicalParty']">
    <xsl:if test="$country-code != 'GB' or
      (@xml:id != 'party.S' and @xml:id != 'party.LS')">
      <xsl:copy>
	<xsl:apply-templates select="@*"/>
	<xsl:apply-templates/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="tei:affiliation[@role='member']">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="$country-code = 'GB' and 
		    (@ref = '#party.S' or @ref = '#party.LS')">
	<xsl:attribute name="role">speaker</xsl:attribute>
	<xsl:attribute name="ref">
	  <xsl:if test="@ref = '#party.S'">#parla.lower</xsl:if>
	  <xsl:if test="@ref = '#party.LS'">#parla.upper</xsl:if>
	</xsl:attribute>
      </xsl:if>
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
  
  <!-- Is the first date between the following two? -->
  <xsl:function name="et:between-dates" as="xs:boolean">
    <xsl:param name="date" as="xs:string"/>
    <xsl:param name="from" as="xs:string?"/>
    <xsl:param name="to" as="xs:string?"/>
    <xsl:choose>
      <xsl:when test="$from = '' and $to = ''">
	<xsl:value-of select="true()"/>
      </xsl:when>
      <xsl:when test="$from = '' and 
		      xs:date(et:pad-date($date)) &lt;= xs:date(et:pad-date($to))" >
	<xsl:value-of select="true()"/>
      </xsl:when>
      <xsl:when test="$to = '' and 
		      xs:date(et:pad-date($date)) &gt;= xs:date(et:pad-date($from))" >
	<xsl:value-of select="true()"/>
      </xsl:when>
      <xsl:when test="xs:date(et:pad-date($date)) &gt;= xs:date(et:pad-date($from)) and
	              xs:date(et:pad-date($date)) &lt;= xs:date(et:pad-date($to))">
	<xsl:value-of select="true()"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="false()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- Fix too long or too short dates 
       a la "2013-10-26T14:00:00" or "2018" to xs:date e.g. 2018-01-01 -->
  <xsl:function name="et:pad-date">
    <xsl:param name="date"/>
    <xsl:choose>
      <xsl:when test="matches($date, '^\d\d\d\d-\d\d-\d\dT.+$')">
	<xsl:value-of select="substring-before($date, 'T')"/>
      </xsl:when>
      <xsl:when test="matches($date, '^\d\d\d\d-\d\d-\d\d$')">
	<xsl:value-of select="$date"/>
      </xsl:when>
      <xsl:when test="matches($date, '^\d\d\d\d-\d\d$')">
	<!--xsl:message>
	  <xsl:text>WARN: short date </xsl:text>
	  <xsl:value-of select="$date"/>
	</xsl:message-->
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
