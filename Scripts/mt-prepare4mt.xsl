<?xml version="1.0"?>
<!-- Prepare a TEI corpus for insertion of MTed text -->
<!-- Input is lingustically analysed (.TEI.ana) corpus root file 
     with XIncludes for all corpus components
     Output is the corresponding .TEI.ana:
     - corpus root, 
     - needed factorised taxonomies, listPerson and listOrg
     - components
     All are in their text-less form (empty <s> elements) ready for insertion of translated sentences
     STDERR gives a detailed log of actions.
     The program:
     - changes the filenames, top-level IDs and main titles
     - adds MT-related respStmt, appInfo, prefixDef, change
     - moves notes and incidents out of sentences
     - removes text from sentences
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
  
  <!-- Directories must have absolute paths or relative to the location of this script -->
  <xsl:param name="outDir">.</xsl:param>
  
  <!-- Language code to which the corpus has been translated -->
  <xsl:param name="target-lang">en</xsl:param>
  <!-- Extended TEI prefix for source corpora -->
  <xsl:param name="mt-prefix">mt-src</xsl:param>
  
  <!-- Country code taken from the teiCorpus ID -->
  <xsl:param name="country-code" select="replace(/tei:teiCorpus/@xml:id, 
                                         '.*?-([^._]+).*', '$1')"/>
  <!-- Name of output corpus -->
  <xsl:param name="output-name" select="concat('ParlaMint-', $country-code, '-en')"/>
  
  <xsl:output method="xml" indent="yes"/>
  <xsl:preserve-space elements="catDesc seg note vocal kinesic incident gap"/>

  <!-- Input directory -->
  <xsl:variable name="inDir" select="replace(base-uri(), '(.*)/.*', '$1')"/>
  
  <xsl:variable name="outRoot" select="concat($outDir, '/', $output-name, '.ana.xml')"/>

  <xsl:variable name="change"><name>Tomaž Erjavec</name>: Generate TEI version of MTed corpus.</xsl:variable>
  <xsl:variable name="respStmt">
    <respStmt>
      <persName>Taja Kuzman</persName>
      <persName>Nikola Ljubešić</persName>
      <resp xml:lang="en">Machine translation to English and linguistic analysis of the translation</resp>
    </respStmt>
  </xsl:variable>

  <xsl:variable name="appInfo">
    <appInfo>
      <application ident="EasyNMT" version="2.0">
        <label>EasyNMT (OPUS-MT model)</label>
        <desc>
	  <xsl:text>Translation to English done with EasyNMT (</xsl:text>
	  <ref target="https://github.com/UKPLab/EasyNMT">https://github.com/UKPLab/EasyNMT</ref>
	  <xsl:text>) with OPUS-MT model </xsl:text>
	<!-- Used OPUS.MT models used: -->
	<xsl:choose>
	  <xsl:when test="$country-code = 'AT'">gmw</xsl:when>
	  <xsl:when test="$country-code = 'BA'">zls</xsl:when>
	  <xsl:when test="$country-code = 'BG'">bg</xsl:when>
	  <xsl:when test="$country-code = 'CZ'">cs</xsl:when>
	  <xsl:when test="$country-code = 'DK'">da</xsl:when>
	  <xsl:when test="$country-code = 'ES-CT'">roa</xsl:when>
	  <xsl:when test="$country-code = 'ES-GA'">itc</xsl:when>
	  <xsl:when test="$country-code = 'GR'">grk</xsl:when>
	  <xsl:when test="$country-code = 'HR'">zls</xsl:when>
	  <xsl:when test="$country-code = 'HU'">hu</xsl:when>
	  <xsl:when test="$country-code = 'IS'">is</xsl:when>
	  <xsl:when test="$country-code = 'IT'">it</xsl:when>
	  <xsl:when test="$country-code = 'LV'">bat</xsl:when>
	  <xsl:when test="$country-code = 'NL'">nl</xsl:when>
	  <xsl:when test="$country-code = 'NO'">gem</xsl:when>
	  <xsl:when test="$country-code = 'PL'">pl</xsl:when>
	  <xsl:when test="$country-code = 'PT'">itc</xsl:when>
	  <xsl:when test="$country-code = 'RS'">zls</xsl:when>
	  <xsl:when test="$country-code = 'SE'">sv</xsl:when>
	  <xsl:when test="$country-code = 'SI'">sla</xsl:when>
	  <xsl:when test="$country-code = 'TR'">tr</xsl:when>
	  <xsl:when test="$country-code = 'UA'">sla</xsl:when>
	</xsl:choose>
	<xsl:text> (</xsl:text>
	<ref target="https://github.com/Helsinki-NLP/Opus-MT">https://github.com/Helsinki-NLP/Opus-MT</ref>
	<xsl:text>)</xsl:text>
	</desc>
      </application>
      <application ident="Stanza" version="1.5">
        <label>Stanza</label>
        <desc>Tokenisation, PoS tagging, lemmatization, and NER annotation done with Stanza (<ref target="https://stanfordnlp.github.io/stanza/">https://stanfordnlp.github.io/stanza/</ref>) with the model for English. For NER the conll03 model with 4 NE classes was used.</desc>
      </application>
    </appInfo>
  </xsl:variable>
    
  <!-- We need to set prefixDef for root, and a different one for each component.
       For root it will be e.g. ../ParlaMint-XX.TEI.ana/ParlaMint-XX.ana.xml#$1
       For component it will be e.g. ../../ParlaMint-XX.TEI.ana/1996/ParlaMint-AT_1996-01-15-020-XX-NRSITZ-00001.ana.xml#$1
  -->
  <xsl:variable name="prefixDef">
    <prefixDef ident="{$mt-prefix}" matchPattern="(.+)" replacementPattern="XXX#$1">
      <p>Private URIs with this prefix point to aligned source elements of the MTed corpus.</p>
    </prefixDef>
  </xsl:variable>
  
  <!-- Gather URIs of component xi + files and map to new files, incl. .ana files -->
  <xsl:variable name="docs">
    <xsl:for-each select="//xi:include">
      <item>
	<xsl:variable name="file-type">
	  <xsl:choose>
	    <xsl:when test="ancestor::tei:teiHeader">factorised</xsl:when>
	    <xsl:otherwise>component</xsl:otherwise>
	  </xsl:choose>
	</xsl:variable>
	<xsl:attribute name="type" select="$file-type"/>
        <xi-orig>
          <xsl:value-of select="@href"/>
        </xi-orig>
        <url-orig>
          <xsl:value-of select="concat($inDir, '/', @href)"/>
        </url-orig>
        <url-new>
	  <!-- Give '-xx' extension for MTed files, but not to factorised files -->
	  <xsl:variable name="new-href">
	    <xsl:choose>
	      <xsl:when test="$file-type = 'factorised'">
		<xsl:value-of select="@href"/>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:value-of select="replace(@href, '_', concat('-', $target-lang, '_'))"/>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:variable>
	  <xsl:value-of select="concat($outDir, '/', $new-href)"/>
        </url-new>
      </item>
      </xsl:for-each>
  </xsl:variable>
  
  <xsl:template match="/">
    <xsl:message select="concat('INFO: Starting to process ', tei:teiCorpus/@xml:id)"/>
    <xsl:message>INFO: preparing root </xsl:message>
    <xsl:result-document href="{$outRoot}">
      <xsl:apply-templates>
	<!-- Corresponding file in original language -->
	<xsl:with-param name="corresp" select="replace(base-uri(), '.+/(.+/.+)', '../$1')"/>
      </xsl:apply-templates>
    </xsl:result-document>
    <!-- Process component files -->
    <xsl:for-each select="$docs//tei:item">
      <xsl:variable name="this" select="tei:xi-orig"/>
      <!-- We do not need the .ana taxonomies except ParlaMint-taxonomy-NER.ana.xml -->
      <xsl:if test="not(matches(tei:xi-orig, 'taxonomy.*\.ana')) or contains(tei:xi-orig, 'ParlaMint-taxonomy-NER.ana')">
	<xsl:message select="concat('INFO: Preparing ', @type, ' ', $this)"/>
	<xsl:result-document href="{tei:url-new}">
	  <xsl:choose>
	    <!-- Copy over factorised parts of corpus root teiHeader -->
	    <xsl:when test="@type = 'factorised'">
              <xsl:copy-of select="document(tei:url-orig)"/>
	    </xsl:when>
	    <!-- Process component -->
	    <xsl:when test="@type = 'component'">
              <xsl:apply-templates mode="comp" select="document(tei:url-orig)/tei:TEI">
		<!-- Corresponding file in original language -->
		<xsl:with-param name="corresp" select="replace(tei:url-orig, '.+/([^/]+/[^/]+/.+)', '../../$1')"/>
	      </xsl:apply-templates>
	    </xsl:when>
	  </xsl:choose>
	</xsl:result-document>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template mode="comp" match="*">
    <xsl:param name="corresp"/>
    <xsl:copy>
      <xsl:apply-templates mode="comp" select="@*"/>
      <xsl:apply-templates mode="comp">
	<xsl:with-param name="corresp" select="$corresp"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  <xsl:template mode="comp" match="@*">
    <xsl:copy/>
  </xsl:template>

  <xsl:template mode="comp" match="tei:TEI">
    <xsl:param name="corresp"/>
    <xsl:copy>
      <xsl:apply-templates mode="comp" select="@*"/>
      <xsl:attribute name="xml:lang" select="$target-lang"/>
      <xsl:attribute name="xml:id" select="replace(
					   replace(base-uri(), '^.*?([^/]+)\.xml$', '$1'),
					   '_', concat('-', $target-lang, '_'))"/>
      <xsl:attribute name="corresp" select="$corresp"/>
      <xsl:apply-templates mode="comp">
	<xsl:with-param name="corresp" select="$corresp"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="comp" match="tei:teiHeader">
    <xsl:param name="corresp"/>
    <xsl:copy>
      <xsl:apply-templates mode="comp" select="@*"/>
      <xsl:apply-templates mode="comp">
	<xsl:with-param name="corresp" select="$corresp"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  
  <!-- Same as for root -->
  <xsl:template mode="comp" match="tei:titleStmt/tei:title[@type = 'main']">
    <xsl:apply-templates select="."/>
  </xsl:template>
  <xsl:template mode="comp" match="tei:titleStmt/tei:respStmt">
    <xsl:apply-templates select="."/>
  </xsl:template>
  <xsl:template mode="comp" match="tei:publicationStmt/tei:date">
    <xsl:apply-templates select="."/>
  </xsl:template>
  
  <xsl:template mode="comp" match="tei:encodingDesc">
    <xsl:param name="corresp"/>
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
      <listPrefixDef>
	<xsl:apply-templates mode="comp" select="$prefixDef">
	  <xsl:with-param name="corresp" select="$corresp"/>
	</xsl:apply-templates>
      </listPrefixDef>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="comp" match="tei:revisionDesc">
    <xsl:apply-templates select="."/>
  </xsl:template>
  
  <xsl:template mode="comp" match="tei:prefixDef">
    <xsl:param name="corresp"/>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="replacementPattern" select="replace(@replacementPattern, 'XXX', $corresp)"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <!-- Give the corresp attribute to these elements -->
  <xsl:template mode="comp" match="tei:div | tei:u | tei:seg |
				   tei:head |tei:note | tei:gap | tei:vocal | tei:kinesic | tei:incident">
    <xsl:param name="corresp"/>
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="xml:lang" select="$target-lang"/>
      <!-- div does not necessarily have an ID -->
      <xsl:if test="@xml:id">
	<xsl:attribute name="corresp" select="concat($mt-prefix, ':', @xml:id)"/>
      </xsl:if>
      <xsl:apply-templates mode="comp"/>
    </xsl:copy>
  </xsl:template>

  <!-- Remove desc in English, in case there is a sister desc not in English -->
  <xsl:template mode="comp" match="tei:body//tei:desc">
    <xsl:if test="ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang != 'en' or
		  not(../tei:desc[ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang != 'en'])">
      <xsl:copy>
	<xsl:apply-templates select="@*"/>
	<xsl:apply-templates mode="comp"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>
  
  <!-- Strip text form <s> and move contained comment elements after <s/> -->
  <xsl:template mode="comp" match="tei:s">
    <xsl:variable name="content">
      <xsl:apply-templates mode="comp" select="tei:*"/>
    </xsl:variable>
    <xsl:copy>
      <xsl:apply-templates select="@*[name() != 'xml:lang']"/>
    </xsl:copy>
    <xsl:if test="$content/tei:*">
      <xsl:variable name="elements">
	<xsl:for-each select="$content/tei:*">
	  <xsl:value-of select="name()"/>
	  <xsl:text>&#32;</xsl:text>
	</xsl:for-each>
      </xsl:variable>
      <!--xsl:message select="concat('WARN: Moving ', $elements, 
			   'out of ', @xml:id, ' in ', ancestor::tei:TEI/@xml:id)"/-->
      <xsl:copy-of select="$content"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template mode="comp" match="tei:w"/>
  <xsl:template mode="comp" match="tei:pc"/>
  <xsl:template mode="comp" match="tei:linkGrp"/>
  <!-- NE elements: name, date, num -->
  <xsl:template mode="comp" match="tei:s/tei:*[.//tei:w or .//tei:pc]"/>
      
  <!-- Finalizing ROOT -->
  
  <xsl:template match="*">
    <xsl:param name="corresp"/>
    <xsl:copy>
      <xsl:apply-templates select="@*">
	<xsl:with-param name="corresp" select="$corresp"/>
      </xsl:apply-templates>
      <xsl:apply-templates>
	<xsl:with-param name="corresp" select="$corresp"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="@*">
    <xsl:copy/>
  </xsl:template>
  
  <xsl:template match="tei:teiCorpus">
    <xsl:param name="corresp"/>
    <xsl:copy>
      <xsl:apply-templates select="@*">
	<xsl:with-param name="corresp" select="$corresp"/>
      </xsl:apply-templates>
      <xsl:attribute name="xml:id" select="replace(
					   replace(base-uri(), '^.*?([^/]+)\.xml$', '$1'),
					   '\.', concat('-', $target-lang, '.'))"/>

      <xsl:attribute name="xml:lang" select="$target-lang"/>
      <xsl:attribute name="corresp" select="$corresp"/>
      <xsl:apply-templates select="tei:*">
	<xsl:with-param name="corresp" select="$corresp"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="xi:include"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:teiHeader">
    <xsl:param name="corresp"/>
    <xsl:copy>
      <xsl:apply-templates select="@*">
	<xsl:with-param name="corresp" select="$corresp"/>
      </xsl:apply-templates>
      <xsl:apply-templates>
	<xsl:with-param name="corresp" select="$corresp"/>
      </xsl:apply-templates>
      <xsl:if test="not(tei:revisionDesc)">
	<revisionDesc>
	  <change when="{$today-iso}"><xsl:copy-of select="$change"/></change>
	</revisionDesc>
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <!-- Root listPrefiDef has only the prefixDef for ud-syn, but MTed corpus does not have parses, so we remove it -->
  <xsl:template match="tei:listPrefixDef"/>
  
  <!-- Fix XIncluded to point to MTed components -->
  <xsl:template match="xi:include">
    <!-- We do not need the .ana taxonomies except ParlaMint-taxonomy-NER.ana.xml -->
    <xsl:if test="not(matches(@href, 'taxonomy.*\.ana')) or contains(@href, 'ParlaMint-taxonomy-NER.ana')">
      <xsl:copy>
	<xsl:attribute name="href">
	  <xsl:choose>
	    <xsl:when test="ancestor::tei:teiHeader">
	      <xsl:value-of select="@href"/>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:value-of select="replace(@href, '_', concat('-', $target-lang, '_'))"/>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:attribute>
      </xsl:copy>
    </xsl:if>
  </xsl:template>
  
  <!-- Give stamp for MTed corpus -->
  <xsl:template match="tei:titleStmt/tei:title[@type = 'main']">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:value-of select="replace(
			    replace(., 
			    '(.+?)\[.+\]$', 
			    concat('$1', '[ParlaMint-', $target-lang, '.ana]')
			    ),
			    concat('(.+?)', 'ParlaMint-', $country-code),
			    concat('$1', 'ParlaMint-', $country-code, '-en')
			    )"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- Add new responsibilities -->
  <xsl:template match="tei:titleStmt/tei:respStmt">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
    <xsl:if test="not(following-sibling::tei:respStmt)">
      <xsl:copy-of select="$respStmt"/>
    </xsl:if>
  </xsl:template>
  
  <!-- Give today's date, not really necessary and distro will do this as well -->
  <xsl:template match="tei:publicationStmt/tei:date">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="when" select="$today-iso"/>
      <xsl:value-of select="$today-iso"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tei:appInfo">
    <xsl:copy-of select="$appInfo"/>
  </xsl:template>
  
  <xsl:template match="tei:revisionDesc">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <change when="{$today-iso}"><xsl:copy-of select="$change"/></change>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tei:revisionDesc/tei:change/text()">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>
  
  <!-- Format number -->
  <xsl:function name="et:format-number" as="xs:string">
    <xsl:param name="lang" as="xs:string"/>
    <xsl:param name="quant"/>
    <xsl:variable name="form" select="format-number($quant, '###,###,###,###')"/>
    <xsl:choose>
      <!-- Spaces for thousands separator -->
      <xsl:when test="$lang = 'fr'">
        <xsl:value-of select="replace($form, ',', ' ')"/>
      </xsl:when>
      <!-- Period for thousands separator -->
      <xsl:when test="$lang = 'bg' or 
                      $lang = 'bs' or
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
                      $lang = 'sr' or
                      $lang = 'tr'
                      ">
        <xsl:value-of select="replace($form, ',', '.')"/>
      </xsl:when>
      <!-- Comma for thousands separator -->
      <xsl:otherwise>
        <xsl:value-of select="$form"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
</xsl:stylesheet>
