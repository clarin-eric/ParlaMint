<?xml version="1.0"?>
<!-- Prepare a ParlaMint corpus for a release, i.e. fix known and automatically fixable errors in the source corpus -->
<!-- The script can be used for both corpora in original langauge(s) or for its MTed variant -->
<!-- Input is either lingustically analysed (.TEI.ana) or "plain text" (.TEI) corpus root file XIncluding the corpus components
     Note that .TEI still needs access to .TEI.ana as that it where it takes its word measures
     Output is the corresponding .TEI / TEI.ana corpus root and corpus components, in the dicrectory given in the outDir parameter
     If .TEI is processed, the corresponding TEI.ana directory should be given in the anaDir parameter
     STDERR gives a detailed log of changes.

     Changes to root file:
     - delete old and now redundant pubPlace
     - delete non-standard extent/measures
     - insert textClass if missing
     - remove anonymous/unknown speaker (BG, BE, SE)
     - fix some corpus-dependent (GB) orgs and affiliations 
     - fix bad URL idno @type and @subtype
     - fix sprurious spaces in text content (multiple, leading and trailing spaces)
     - merge overlapping affiliations
     - remove affiliations where to < from

     Changes to component files:
     - delete non-standard extent/measures
     - add meeting reference to corpus specific parliamentary body of the meeting, if missing
     - change #parla.meeting.unregistered to #parla.meeting (IS)
     - change badly formed title (RS)
     - change div/@type for divs without utterances
     - remove empty utterances, segments, notes
     - assign IDs to segments without them
     - in .ana remove body name tag if name contains no words
     - in .ana remove sentences without tokens
     - in .ana change tag from <w> to <pc> for punctuation
     - in .ana change UPoS tag from - to X
     - in .ana change lemma tag from empty or _ to normalised form or wordform, lower-cased if not PROPN
     - in .ana change root syntactic dependency to dep, if node is not sentence root
     - in .ana change <PAD> syntactic dependency to dep
     - in .ana change obl:loc syntactic dependency to obl
     - fix sprurious spaces in text content (multiple, leading and trailing spaces)
-->
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:mk="http://ufal.mff.cuni.cz/matyas-kopp"
  xmlns:et="http://nl.ijs.si/et" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xsl tei et mk xs xi"
  version="2.0">

  <xsl:import href="parlamint-lib.xsl"/>
  
  <!-- Directories must have absolute paths or relative to the location of this script -->
  <xsl:param name="outDir">.</xsl:param>
  <xsl:param name="anaDir">.</xsl:param>
  
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
  
  <!-- Is this an MTed corpus? Set $mt to name of MTed language (or to empty, if not MTed) -->
  <xsl:param name="mt">
    <xsl:if test="matches($country-code, '-[a-z]{2,3}$')">
      <xsl:value-of select="replace($country-code, '.+-([a-z]{2,3})$', '$1')"/>
    </xsl:if>
  </xsl:param>
  
  <!-- parameters for partial processing, root file is processed after processing the last component file -->
  <xsl:param name="chunkStart">0</xsl:param>
  <xsl:param name="chunkSize">0</xsl:param> <!-- 0 means process all -->
  
  <xsl:output method="xml" indent="yes"/>
  <xsl:preserve-space elements="catDesc seg"/>

  <!-- Input directory -->
  <xsl:variable name="inDir" select="replace(base-uri(), '(.*)/.*', '$1')"/>
  <!-- The name of the corpus directory to output to, i.e. "ParlaMint-XX" -->
  <xsl:variable name="corpusDir" select="replace(base-uri(), 
                                         '.*?([^/]+)/[^/]+\.[^/]+$', '$1')"/>

  <!-- note's content that do not produce warning -->
  <xsl:variable name="allowedNotes" select="tokenize('.. ... .... … ? !')"/>
  <!-- Output root file -->
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
      </item>
      </xsl:for-each>
  </xsl:variable>

  <!-- docs to process in chunk -->
  <xsl:variable name="docsChunk">
    <xsl:copy-of select="$docs//tei:item[xs:integer(@position) gt xs:integer($chunkStart) and (xs:integer(@position) le $chunkStart + $chunkSize or $chunkSize = 0)]"/>  
  </xsl:variable> 

  <xsl:template match="/">
    <xsl:message select="concat('INFO Starting to process ', tei:teiCorpus/@xml:id)"/>
    <xsl:message>
      <xsl:text>INFO Starting to process component files</xsl:text>
      <xsl:if test="xs:integer($chunkSize) = 0 or xs:integer($chunkStart) gt 0">
        <xsl:text> from </xsl:text>
        <xsl:value-of select="$docsChunk//tei:item[1]/@position"/>
        <xsl:text> to </xsl:text>
        <xsl:value-of select="$docsChunk//tei:item[last()]/@position"/> 
      </xsl:if>
    </xsl:message>
    <!-- Process component files -->
    <xsl:for-each select="$docsChunk//tei:item">
      <xsl:variable name="this" select="tei:xi-orig"/>
      <xsl:message select="concat('INFO Processing [',@position,'] ', $this)"/>
      <xsl:result-document href="{tei:url-new}">
	<xsl:choose>
	  <!-- Process factorised parts of corpus root teiHeader as if they were root -->
	  <xsl:when test="@type = 'factorised'">
            <xsl:apply-templates mode="root" select="document(tei:url-orig)"/>
	  </xsl:when>
	  <!-- Process component -->
	  <xsl:when test="@type = 'component'">
            <xsl:apply-templates mode="comp" select="document(tei:url-orig)/tei:TEI"/>
	  </xsl:when>
	</xsl:choose>
      </xsl:result-document>
    </xsl:for-each>
    <xsl:if test="$docsChunk//tei:item[last()]/@position = count($docs//tei:item)">
      <xsl:text>STATUS: Processed last chunk</xsl:text> <!-- Do not change this message !!! -->
      <!-- Output Root file -->
      <xsl:message select="concat('INFO processing root ', tei:teiCorpus/@xml:id)"/>
      <xsl:result-document href="{$outRoot}">
        <xsl:apply-templates mode="root"/>
      </xsl:result-document>
    </xsl:if>
  </xsl:template>

  <xsl:template match="* | @*">
    <xsl:message terminate="yes">All templates must have mode comp or root!</xsl:message>
  </xsl:template>
  
  <!-- Finalizing root file -->
  
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
        <xsl:copy-of select="."/>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>

  <xsl:template mode="root" match="tei:revisionDesc">
    <xsl:copy>
      <xsl:apply-templates mode="root" select="@*"/>
      <change when="{$today-iso}">parlamint2release script: Fix some identifiable erros for the release.</change>
      <xsl:apply-templates mode="root" select="*"/>
    </xsl:copy>
  </xsl:template>

  <!-- We remove individually inserted non-speech and non-word measures as we don't trust them -->
  <xsl:template mode="root" match="tei:extent/tei:measure[@unit != 'speeches' and @unit != 'words']"/>
    
  <xsl:template mode="root" match="tei:langUsage/tei:language">
    <xsl:copy>
      <xsl:apply-templates mode="root" select="@*"/>
      <xsl:variable name="okName" select="concat(upper-case(substring(., 1, 1)), lower-case(substring(., 2)))"/>
      <xsl:choose>
	<!-- English names of languages should be in title case -->
	<xsl:when test="ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang = 'en' and . != $okName">
	  <xsl:value-of select="$okName"/>
	  <xsl:message select="concat('WARN ', ancestor-or-self::tei:*[@xml:id][1]/@xml:id, 
                               ': changing language name from ', ., ' to ', $okName)"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="normalize-space(.)"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="root" match="tei:person">
    <xsl:choose>
      <!-- Remove anonymous speaker -->
      <xsl:when test="@xml:id='Anonymous' or @xml:id='anonymous' or @xml:id='unknown'">
        <xsl:message select="concat('WARN ', /tei:*/@xml:id,
           ': removing anonymous speaker from listPerson ', @xml:id)"/>
      </xsl:when>
      <!-- Processing the rest -->
      <xsl:otherwise>
        <xsl:variable name="affiliations">
          <xsl:apply-templates select="* | comment() | text()" mode="affiliations"/>
        </xsl:variable>
        <xsl:copy>
          <xsl:apply-templates select="@*" mode="root"/>
          <xsl:apply-templates select="* | comment() | text()" mode="person">
            <xsl:with-param name="affiliations" select="$affiliations"/>
          </xsl:apply-templates>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
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
  <xsl:template mode="root" match="tei:org[@role='politicalParty']">
    <xsl:if test="$country-code != 'GB' or (@xml:id != 'party.S' and @xml:id != 'party.LS')">
      <xsl:copy>
        <xsl:apply-templates mode="root" select="@*"/>
        <xsl:apply-templates mode="root"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>
  
  <xsl:template mode="root" match="tei:idno">
    <xsl:copy>
      <xsl:apply-templates mode="root" select="@*"/>
      <xsl:choose>
	<!-- AT: <idno type="parlament.gv.at" xml:lang="de">https://www.parlament.gv.at/WWER/PAD_01018/index.shtml</idno> -->
        <!-- IS: <idno type="URL">http://www.althingi.is/altext/cv/is/?nfaerslunr=1471</idno> -->
	<xsl:when test="contains(@type, 'parlament') or contains(@type, 'althingi.is')">
	  <xsl:attribute name="type">URI</xsl:attribute>
	  <xsl:attribute name="subtype">parliament</xsl:attribute>
	  <xsl:message select="concat('WARN ', ancestor-or-self::tei:*[@xml:id][1]/@xml:id, 
                               ': fixing idno (sub)type of parliament for ', .)"/>
	</xsl:when>
	<!-- BG: <idno type="wikimedia">https://www.bulnao.government.bg/bg/articles/gorica-gryncharova-kozhareva-1440</idno> -->
	<xsl:when test="contains(., 'government') and not(@type = 'URI' and @subtype = 'government')">
	  <xsl:attribute name="type">URI</xsl:attribute>
	  <xsl:attribute name="subtype">government</xsl:attribute>
	  <xsl:message select="concat('WARN ', ancestor-or-self::tei:*[@xml:id][1]/@xml:id, 
                               ': fixing idno (sub)type for government for ', .)"/>
	</xsl:when>
        <!-- e.g. TR: <idno type="URI" subtype="wikidata">https://www.wikidata.org/entity/Q108248939</idno> -->
	<xsl:when test="(contains(., 'wikipedia') or contains(., 'wikimedia') or contains(., 'wikidata'))
                        and not(@type = 'URI' and @subtype = 'wikimedia')">
	  <xsl:attribute name="type">URI</xsl:attribute>
	  <xsl:attribute name="subtype">wikimedia</xsl:attribute>
	  <xsl:message select="concat('WARN ', ancestor-or-self::tei:*[@xml:id][1]/@xml:id, 
                               ': fixing idno (sub)type for wikipedia for ', .)"/>
	</xsl:when>
        <!-- BG: <idno type="wikimedia">https://www.comdos.bg/Състав на комисията/evtim kostadinov kostadinov</idno> -->
	<xsl:when test="@type = 'wikimedia' and not(contains(., 'wiki'))">
	  <xsl:attribute name="type">URI</xsl:attribute>
	  <xsl:message select="concat('WARN ', ancestor-or-self::tei:*[@xml:id][1]/@xml:id, 
                               ': fixing idno (sub)type for URI for ', .)"/>
	</xsl:when>
	<xsl:when test="@type = 'url' or @type = 'URL'">
	  <xsl:attribute name="type">URI</xsl:attribute>
	  <xsl:message select="concat('WARN ', ancestor-or-self::tei:*[@xml:id][1]/@xml:id, 
                               ': fixing idno type from url to URI for ', .)"/>
        </xsl:when>
	<xsl:when test="@type = 'URI' and @subtype = 'contact' and contains(., 'parliament')">
	  <xsl:attribute name="type">URI</xsl:attribute>
	  <xsl:attribute name="subtype">parliament</xsl:attribute>
	  <xsl:message select="concat('WARN ', ancestor-or-self::tei:*[@xml:id][1]/@xml:id, 
                               ': fixing idno subtype from contact to parliament for ', .)"/>
        </xsl:when>
      </xsl:choose>
      <xsl:value-of select="normalize-space(.)"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template mode="root" match="tei:meeting">
    <xsl:copy>
      <xsl:apply-templates mode="root" select="@*"/>
      <xsl:if test="not(contains(@ana, 'parla.upper') or contains(@ana, 'parla.lower') or contains(@ana, 'parla.committee'))">
	<!-- In NO corpus each meeting contains yearFrom-yearTo info, which we need -->
	<xsl:variable name="toYear-NO" select="substring-after(., '-')"/>
	<xsl:choose>
	  <!-- Quasi-bicameral to 2009, then unicameral -->
          <xsl:when test="$country-code = 'NO' and 
			  $toYear-NO &lt;= '2009'">
	    <xsl:attribute name="ana" select="normalize-space(concat('#parla.upper #parla.lower ', @ana))"/>
	  </xsl:when>
          <xsl:when test="$country-code = 'NO'">
	    <xsl:attribute name="ana" select="normalize-space(concat('#parla.uni ', @ana))"/>
	  </xsl:when>
          <xsl:when test="$country-code = 'GB' and 
			  not(contains(@ana, '#parla.upper') and contains(@ana, '#parla.lower'))">
	    <xsl:attribute name="ana" select="normalize-space(concat('#parla.upper #parla.lower ', @ana))"/>
	  </xsl:when>
	  <!-- Used by IS, but common taxonomy doesn't have this category of meetings -->
          <xsl:when test="$country-code = 'IS' and
			  contains(@ana, '#parla.meeting.unregistered')">
	    <xsl:attribute name="ana" select="replace(@ana, '#parla.meeting.unregistered', '#parla.meeting')"/>
	  </xsl:when>
	</xsl:choose>
	<xsl:apply-templates mode="root"/>
      </xsl:if>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="root" match="tei:affiliation[@role='member']">
    <xsl:copy>
      <xsl:apply-templates mode="root" select="@*"/>
      <xsl:if test="$country-code = 'GB' and (@ref = '#party.S' or @ref = '#party.LS')">
        <xsl:attribute name="role">speaker</xsl:attribute>
        <xsl:attribute name="ref">
          <xsl:if test="@ref = '#party.S'">#parla.lower</xsl:if>
          <xsl:if test="@ref = '#party.LS'">#parla.upper</xsl:if>
        </xsl:attribute>
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <xsl:template mode="root" match="text()">
    <xsl:choose>
      <xsl:when test="not(../tei:*)">
	<xsl:if test="starts-with(., '\s') or ends-with(., '\s')">
	  <xsl:message select="concat('WARN ', ancestor-or-self::tei:*[@xml:id][1]/@xml:id, 
                               ': removing spurious space from ', .)"/>
	</xsl:if>
	<xsl:value-of select="normalize-space(.)"/>
      </xsl:when>
      <xsl:when test="preceding-sibling::tei:* and following-sibling::tei:*">
	<xsl:value-of select="."/>
      </xsl:when>
      <xsl:when test="preceding-sibling::tei:*">
	<xsl:if test="ends-with(., '\s')">
	  <xsl:message select="concat('WARN ', /tei:*/@xml:id, 
                               ': removing trailing space from ', .)"/>
	</xsl:if>
	<xsl:value-of select="replace(., '\s+$', '')"/>
      </xsl:when>
      <xsl:when test="following-sibling::tei:*">
	<xsl:if test="starts-with(., '\s')">
	  <xsl:message select="concat('WARN ', /tei:*/@xml:id, 
                               ': removing starting space from ', .)"/>
	</xsl:if>
	<xsl:value-of select="replace(., '^\s+', '')"/>
      </xsl:when>
      <xsl:otherwise>
	  <xsl:message terminate="yes" select="concat('FATAL ERROR ', /tei:*/@xml:id, 
                               ': strange situation with ', .)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Processing persons: fix missing sex and fix affiliations -->
  <xsl:template match="tei:*[not(name()='affiliation')] | comment() | text()" mode="person">
    <xsl:apply-templates select="." mode="root"/>
    <xsl:if test="self::tei:persName and not(following-sibling::tei:persName)">
      <!-- Insert missing sex after last persName -->
      <xsl:if test="not(following-sibling::tei:sex)">
        <sex value="U"/>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:affiliation[@to &lt; @from]" mode="person">
    <xsl:message>
      <xsl:text>WARN: removing affiliation</xsl:text>
      <xsl:if test="parent::tei:person/@xml:id">
        <xsl:text> [</xsl:text>
        <xsl:value-of select="parent::tei:person/@xml:id"/>
      </xsl:if>
      <xsl:text>]</xsl:text>
      <xsl:text> role=</xsl:text>
      <xsl:value-of select="@role"/>
      <xsl:text> ref=</xsl:text>
      <xsl:value-of select="@ref"/>
      <xsl:if test="@ana">
        <xsl:text> ana=</xsl:text>
        <xsl:value-of select="@ana"/>
      </xsl:if>
      <xsl:text>: attribute to=</xsl:text>
      <xsl:value-of select="@to"/>
      <xsl:text> is before from=</xsl:text>
      <xsl:value-of select="@from"/>
    </xsl:message>
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
          <xsl:apply-templates select="@*" mode="root"/>
          <xsl:apply-templates mode="root"/>
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
    <xsl:message>
      <xsl:text>WARN: merging affiliations</xsl:text>
      <xsl:if test="parent::tei:person/@xml:id">
        <xsl:text> [</xsl:text>
        <xsl:value-of select="parent::tei:person/@xml:id"/>
      </xsl:if>
      <xsl:text>]</xsl:text>
      <xsl:text> role=</xsl:text>
      <xsl:value-of select="@role"/>
      <xsl:text> ref=</xsl:text>
      <xsl:value-of select="@ref"/>
      <xsl:if test="@ana">
        <xsl:text> ana=</xsl:text>
        <xsl:value-of select="@ana"/>
      </xsl:if>
      <xsl:text>: (</xsl:text>
      <xsl:value-of select="concat(@from,'--',@to)"/>
      <xsl:text>)  +  (</xsl:text>
      <xsl:value-of select="concat($extend/@from,'--',$extend/@to)"/>
      <xsl:text>)</xsl:text>
    </xsl:message>
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="affiliation-merge">
        <xsl:with-param name="extend" select="$extend"/>
      </xsl:apply-templates>
      <xsl:apply-templates mode="root"/>
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
      <xsl:when test="xs:date(et:norm-date($extend/@*[name() = $attr]))  >= xs:date(et:norm-date(.)) ">
        <xsl:choose>
          <xsl:when test="$attr = 'from'"><xsl:copy/></xsl:when>
          <xsl:otherwise><xsl:apply-templates select="$extend/@*[name() = $attr]" mode="root"/></xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <!-- extend/@  <=  @ -->
      <xsl:when test="$attr = 'from'"><xsl:apply-templates select="$extend/@*[name() = $attr]" mode="root"/></xsl:when>
      <xsl:otherwise><xsl:copy/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- Finalizing component files -->
  <xsl:template mode="comp" match="*">
    <xsl:copy>
      <xsl:apply-templates mode="comp" select="@*"/>
      <xsl:apply-templates mode="comp"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template mode="comp" match="@*">
    <xsl:copy/>
  </xsl:template>

  <!-- Set correct ID of component -->
  <xsl:template mode="comp" match="tei:TEI/@xml:id">
    <xsl:variable name="id" select="replace(base-uri(), '^.*?([^/]+)\.xml$', '$1')"/>
    <xsl:attribute name="xml:id" select="$id"/>
    <xsl:if test=". != $id">
      <xsl:message select="concat('WARN ', @xml:id, ': fixing TEI/@xml:id to ', $id)"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template mode="comp" match="text()">
    <xsl:apply-templates mode="root" select="."/>
  </xsl:template>

  <xsl:template mode="comp" match="tei:titleStmt/tei:title[@type = 'main']">
    <xsl:copy>
      <xsl:apply-templates mode="comp" select="@*"/>
      <xsl:variable name="stamp" select="concat('ParlaMint-', $country-code)"/>
      <xsl:choose>
        <!-- Error in RS main title: "Srpski parlamentarni korpus ParlaMint-RS-T8, Zasedanje 4 [ParlaMint.ana]" -->
        <xsl:when test="starts-with($country-code, 'RS') and matches(., concat($stamp, '-T\d+'))">
          <xsl:variable name="term" select="replace(., concat('.*', $stamp, '-(T\d+),.+'), '$1')"/>
          <xsl:variable name="title" select="replace(
                                             replace(., concat($stamp, '-', $term), $stamp),
                                             '(, .+?) ', concat('$1', ' ', $term, ' '))"/>
          <xsl:message select="concat('WARN: changing title ', ., ' to ', $title)"/>
          <xsl:value-of select="$title"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates mode="comp"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>
  
  <!-- We remove individually inserted non-speech and non-word measures as we don't trust them -->
  <xsl:template mode="comp" match="tei:extent/tei:measure[@unit != 'speeches' and @unit != 'words']"/>

  <!-- Some specific corpora are missing reference to the parliamentary body of the meeting, add it -->
  <!-- Note that add-common-content takes care of this too in a more general setting -->
  <xsl:template mode="comp" match="tei:meeting">
    <!-- GB, need to fix:
         <meeting corresp="#parliament.HC" ana="#parla.meeting.regular"/>
         <meeting n="55" corresp="#parliament.HC" ana="#parla.term #PoGB.55"/>
         <meeting n="2015-01-05" corresp="#parliament.HC" ana="#parla.lower #parla.sitting"/>
         to
         <meeting n="55" corresp="#parliament.HC" ana="#parla.term #PoGB.55"/>
         <meeting n="2015-01-05" corresp="#parliament.HC" ana="#parla.lower #parla.meeting.regular #parla.sitting"/>
    -->
    <xsl:choose>
      <xsl:when test="not(@n or normalize-space(.))">
        <xsl:choose>
          <xsl:when test="../tei:meeting[@n]">
            <xsl:message select="concat('WARN ', /tei:TEI/@xml:id, 
                                 ': meeting without @n or content, will add @ana=', @ana, 
                                 ' into another meeting element.')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message select="concat('ERROR ', /tei:TEI/@xml:id, 
                                 ': meeting without @n or content!')"/>
            <xsl:copy-of select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates mode="comp" select="@*"/>
          <xsl:variable name="ana">
            <!-- BE uses their own special category for commitee meetings, change to common category -->
            <!-- IS uses their own special category for "unregistered" meetings, change to common category -->
            <xsl:variable name="ana1" select="replace(
				              replace(@ana, 'parla\.meeting\.committee', 'parla.committee'),
				              'parla\.meeting\.unregistered', 'parla.meeting')"/>
            <!-- Insert parliament body type if missing -->
            <xsl:variable name="ana2">
	      <xsl:if test="not(contains($ana1, 'parla.uni') or 
                            contains($ana1, 'parla.upper') or contains($ana1, 'parla.lower') or 
                            contains($ana1, 'parla.committee'))">
	        <xsl:variable name="title" select="/tei:TEI/tei:teiHeader//tei:titleStmt/
					           tei:title[@type='main']
					           [ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang='en']"/>
	        <xsl:variable name="body">
	          <xsl:choose>
                    <xsl:when test="$country-code = 'GB' and contains($title, 'Commons')">#parla.lower</xsl:when>
                    <xsl:when test="$country-code = 'GB' and contains($title, 'Lords')">#parla.upper</xsl:when>
                    <xsl:when test="contains($title, 'Lower House')">#parla.lower</xsl:when>
                    <xsl:when test="contains($title, 'Upper House')">#parla.upper</xsl:when>
	            <!-- Otherwise should be taken care of by add-commmon-content -->
	            <xsl:otherwise><xsl:text></xsl:text></xsl:otherwise>
	          </xsl:choose>
	        </xsl:variable>
	        <xsl:if test="normalize-space($body)">
                  <xsl:message select="concat('WARN ', /tei:*/@xml:id,
				       ': inserting ', $body, ' into meeting/@ana ', $ana1)"/>
	          <xsl:value-of select="concat($body, '&#32;')"/>
	        </xsl:if>
	      </xsl:if>
	      <xsl:value-of select="$ana1"/>
            </xsl:variable>
            <!-- GB, need to fix:
                 <meeting corresp="#parliament.HC" ana="#parla.meeting.regular"/>
                 <meeting n="55" corresp="#parliament.HC" ana="#parla.term #PoGB.55"/>
                 <meeting n="2015-01-05" corresp="#parliament.HC" ana="#parla.lower #parla.sitting"/>
                 to
                 <meeting n="55" corresp="#parliament.HC" ana="#parla.term #PoGB.55"/>
                 <meeting n="2015-01-05" corresp="#parliament.HC" ana="#parla.lower #parla.meeting.regular #parla.sitting"/>
            -->
            <xsl:variable name="bad-meeting" select="../tei:meeting[not(@n or normalize-space(.))]"/>
            
            <xsl:choose>
              <!-- Just do it for sitting, this is not general, but enough for GB -->
              <xsl:when test="contains($ana2, 'parla.sitting') and $bad-meeting/self::tei:meeting">
                <xsl:variable name="bad-ana" select="$bad-meeting/@ana"/>
                <xsl:if test="not(contains(@ana, $bad-ana))">
                  <xsl:message select="concat('WARN ', /tei:TEI/@xml:id, 
                                       ': adding @ana=', $bad-ana, ' into sitting.')"/>
	          <xsl:value-of select="concat($ana2, '&#32;', $bad-ana)"/>
                </xsl:if>
              </xsl:when>
              <xsl:otherwise>
	        <xsl:value-of select="$ana2"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:attribute name="ana" select="$ana"/>
          <xsl:apply-templates mode="comp"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Used only by FI, but even here bugs in such linkage, so, remove -->
  <xsl:template mode="comp" match="tei:u/@prev">
    <xsl:message select="concat('WARN: removing u/@prev from ', ../@xml:id)"/>
  </xsl:template>
  <xsl:template mode="comp" match="tei:u/@next">
    <xsl:message select="concat('WARN: removing u/@next from ', ../@xml:id)"/>
  </xsl:template>

  <!-- Remove @who for anonymous speakers -->
  <xsl:template mode="comp" match="tei:u/@who[. = '#Anonymous' or . = '#anonymous' or . = '#unknown']">
    <xsl:message select="concat('WARN ', /tei:*/@xml:id,
			 ': removing @who = ', ., ' from utterance ', ../@xml:id)"/>
  </xsl:template>
    
  <!-- Change div/@type="debateSection" to "commentSection" if div contains no utterances -->
  <xsl:template mode="comp" match="tei:div[@type='debateSection'][not(tei:u)]">
    <xsl:message select="concat('WARN ', /tei:TEI/@xml:id, 
                         ': no utterances in div/@type=debateSection, ',
			 'replacing with commentSection')"/>

    <xsl:copy>
      <xsl:apply-templates mode="root" select="@*"/>
      <xsl:attribute name="type">commentSection</xsl:attribute>
      <xsl:apply-templates mode="comp"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- Remove empty notes -->
  <xsl:template mode="comp" match="tei:note[not(normalize-space(.) or tei:*)]">
    <xsl:message select="concat('WARN ', /tei:TEI/@xml:id, 
                         ': removing empty note in ', ancestor-or-self::tei:*[@xml:id][1]/@xml:id)"/>
  </xsl:template>

  <!-- Normalize nonempty notes and (description of) incidents -->
  <xsl:template mode="comp" match="tei:note[normalize-space(.) and not(./element())] | tei:desc">
    <xsl:variable name="textIn" select="normalize-space(.)"/>
    <xsl:variable name="textOut" select="mk:normalize-note($textIn)"/>
    <!-- Remove this message, as there are too many of them -->
    <!--xsl:if test="$textIn != $textOut">
      <xsl:message select="concat('WARN ', /tei:TEI/@xml:id,
                         ': de-bracketing ',
                         parent::tei:*/local-name(),'/',local-name(),
                         ' &quot;',$textIn,'&quot;')"/>
    </xsl:if-->
    <!-- Do not warn about punct only notes, as there are too many such warnings and they can't be fixed: -->
    <!--xsl:if test="not(normalize-space( replace($textOut, '[^\p{Lu}\p{Lt}\p{Ll}0-9]',' ')))
                 and not($allowedNotes[. = normalize-space($textOut)])">
      <xsl:message select="concat('WARN ', /tei:TEI/@xml:id,
                         ': ',
                         parent::tei:*/local-name(),'/',local-name(),
                         ' in ',ancestor-or-self::tei:*[@xml:id][1]/@xml:id,' has strange content &quot;',$textIn,'&quot;')"/>
    </xsl:if-->

    <xsl:copy>
      <xsl:apply-templates mode="root" select="@*"/>
      <xsl:value-of select="$textOut"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template mode="comp" match="tei:note[./element()] ">
    <xsl:variable name="textIn" select="normalize-space(.)"/>
    <xsl:variable name="textOut" select="mk:normalize-note($textIn)"/>
    <xsl:if test="$textIn != $textOut">
      <!-- Comments can contain mixed content (text - time - text) -->
      <xsl:message select="concat('WARN ', /tei:TEI/@xml:id,
                           ': for ', ancestor-or-self::tei:*[@xml:id][1]/@xml:id, 
			   ' skipping comment normalization ', normalize-space(.))"/>
    </xsl:if>
    <xsl:copy>
      <xsl:apply-templates mode="comp" select="@*"/>
      <xsl:apply-templates mode="comp"/>
    </xsl:copy>
  </xsl:template>

  <!-- BG uses <incident type="incident"> and <kinesic type="kinesic">, remove such useless @type -->
  <xsl:template mode="comp" match="tei:incident | tei:kinesic | tei:vocal">
    <xsl:copy>
      <xsl:variable name="tag" select="name()"/>
      <xsl:choose>
        <xsl:when test="@type = $tag">
          <xsl:message select="concat('WARN ', /tei:TEI/@xml:id, 
                               ': removing useless ', $tag, '/@type=', $tag, ' in ', ancestor-or-self::tei:*[@xml:id][1]/@xml:id)"/>
          <xsl:apply-templates mode="comp" select="@*[not(name() = 'type')]"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates mode="comp" select="@*"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates mode="comp"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- EE uses u/@ana = '#deputy_chair', but common taxonomy does not have this category -->
  <xsl:template mode="comp" match="tei:u/@ana[. = '#deputy_chair']">
    <xsl:attribute name="ana">#chair</xsl:attribute>
  </xsl:template>

  <!-- FR uses u/@ana = '#government', but common taxonomy does not have this category -->
  <xsl:template mode="comp" match="tei:u/@ana[. = '#government']">
    <xsl:attribute name="ana">#regular</xsl:attribute>
  </xsl:template>

  <!-- FR uses u/@ana = '#unknown', but common taxonomy does not have this category -->
  <xsl:template mode="comp" match="tei:u/@ana[. = '#unknown']">
    <xsl:attribute name="ana">#guest</xsl:attribute>
  </xsl:template>

  <!-- Bug where an utterance contains no elements, remove utterance -->
  <xsl:template mode="comp" match="tei:u">
    <xsl:variable name="segs">
      <xsl:apply-templates mode="comp"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$segs/tei:*">
	<xsl:copy>
	  <xsl:apply-templates mode="comp" select="@*"/>
	  <xsl:copy-of select="$segs"/>
	</xsl:copy>
      </xsl:when>
      <xsl:otherwise>
	<xsl:message select="concat('WARN ', /tei:TEI/@xml:id, 
                             ': removing utterance without content for ', ancestor-or-self::tei:*[@xml:id][1]/@xml:id)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Bug where a segment contains no elements, remove segment -->
  <xsl:template mode="comp" match="tei:seg[not(normalize-space(.) or .//tei:*)]">
    <xsl:message select="concat('WARN ', /tei:TEI/@xml:id, 
                         ': removing segment without content for ', ancestor-or-self::tei:*[@xml:id][1]/@xml:id)"/>
  </xsl:template>
  
  <!-- Give IDs to segs without them (if u has ID, otherwise complain) -->
  <xsl:template mode="comp" match="tei:seg">
    <xsl:copy>
      <xsl:apply-templates mode="comp" select="@*"/>
      <xsl:choose>
        <xsl:when test="@xml:id"/>
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
      
  <!-- Bug where a sentence contains no tokens, remove sentence -->
  <xsl:template mode="comp" match="tei:s[not(.//tei:w or .//tei:pc)]">
    <xsl:message select="concat('WARN ', /tei:TEI/@xml:id, 
                         ': removing sentence without tokens for ', ancestor-or-self::tei:*[@xml:id][1]/@xml:id)"/>
    <!-- If sentence contains notes or similar, keep these but not link group -->
    <xsl:if test="tei:*">
      <xsl:apply-templates mode="comp" select="tei:*[not(self::tei:linkGrp)]"/>
    </xsl:if>
  </xsl:template>
  
  <!-- Bug where a name contains no words, but only punctuation or a transcriber comment: remove <name> tag -->
  <xsl:template mode="comp" match="tei:body//tei:name[not(.//tei:w or .//tei:pc[not(matches(., '^\p{P}+$'))])]">
    <xsl:message select="concat('WARN ', /tei:TEI/@xml:id, 
                         ': removing name tag as ', normalize-space(.), 
			 ' contains no w elements for ', ancestor-or-self::tei:*[@xml:id][1]/@xml:id)"/>
    <xsl:apply-templates mode="comp"/>
  </xsl:template>
  
  <!-- Processing tools also make various formal mistakes on words, here we try to fix them -->
  <xsl:template mode="comp" match="tei:w">
    <xsl:choose>
      <!-- Bug where punctuation is encoded as a word: change <w> to <pc> -->
      <xsl:when test="contains(@msd, 'UPosTag=PUNCT') and matches(., '^\p{P}+$')">
	<!-- Do not output warning, as there are typically too many of them -->
	<!--xsl:message select="concat('WARN: changing word ', ., ' to punctuation for ', @xml:id)"/-->
	<pc>
	  <xsl:apply-templates mode="comp" select="@*[name() != 'lemma']"/>
	  <xsl:apply-templates mode="comp"/>
	</pc>
      </xsl:when>
      <!-- IL has wrongly annotated punctations as a symbol-->
      <xsl:when test="@lemma='' and @msd = 'UPosTag=SYM' ">
        <xsl:message select="concat('WARN: changing symbol(UPosTag=SYM) ', ., ' to punctuation for ', @xml:id)"/>
	<pc>
          <xsl:attribute name="msd">UPosTag=PUNCT</xsl:attribute>
	        <xsl:apply-templates mode="comp" select="@*[name() != 'lemma' and name() != 'pos' and name() != 'msd']"/>
	        <xsl:apply-templates mode="comp"/>
	      </pc>
      </xsl:when>
      <!-- Bug where syntactic word contains just one word: remove outer word and preserve annotations -->
      <xsl:when test="tei:w[tei:w] and not(tei:w[tei:*[2]])">
        <xsl:message select="concat('WARN ', /tei:TEI/@xml:id,
                             ': removing useless syntactic word ', @xml:id)"/>
        <xsl:copy>
          <xsl:apply-templates mode="comp" select="tei:w/@*[name() != 'norm']"/>
          <xsl:value-of select="normalize-space(.)"/>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates mode="comp" select="@*"/>
          <xsl:apply-templates mode="comp"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Bug where UPosTag is set to "-": change to "X" -->
  <xsl:template mode="comp" match="tei:w/@msd[contains(., 'UPosTag=-')]">
    <xsl:attribute name="msd">
      <xsl:message select="concat('WARN ', /tei:TEI/@xml:id, 
                           ': changing UPosTag=- to UPosTag=X for ', ../@xml:id)"/>
      <xsl:value-of select="replace(., 'UPosTag=-', 'UPosTag=X')"/>
    </xsl:attribute>
  </xsl:template>
  
  <!-- Bug where lemma is empty or "_": change to @norm, if it exists, else to text() of the word -->
  <xsl:template mode="comp" match="tei:w/@lemma[not(normalize-space(.)) or . = '_']">
    <xsl:variable name="message" select="concat('WARN ', /tei:TEI/@xml:id,  ': changing bad lemma ', ., ' to ')"/>
    <xsl:variable name="location" select="concat(' in ', ../@xml:id)"/>
    <xsl:attribute name="lemma">
      <xsl:choose>
        <xsl:when test="../@norm">
          <xsl:message select="concat($message, '@norm ', ../@norm, $location)"/>
          <xsl:value-of select="../@norm"/>
        </xsl:when>
        <xsl:when test="../contains(@msd, 'UPosTag=PROPN')">
          <xsl:message select="concat($message, 'PROPN token ', ../text(), $location)"/>
          <xsl:value-of select="../text()"/>
	</xsl:when>
        <xsl:otherwise>
          <xsl:message select="concat($message, 'lower-cased token ', lower-case(../text()), $location)"/>
          <xsl:value-of select="lower-case(../text())"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>
  
  <!-- Bug in STANZA, sometimes several tokens have root dependency -->
  <!-- We set those that have root but do not point to sentence ID to "dep" -->
  <xsl:template mode="comp" match="tei:linkGrp[@type = 'UD-SYN']/tei:link[@ana='ud-syn:root']">
    <xsl:copy>
      <xsl:variable name="root-ref" select="concat('#', ancestor::tei:s/@xml:id)"/>
      <xsl:attribute name="ana">
	<xsl:choose>
	  <xsl:when test="$root-ref = substring-before(@target, ' ')">ud-syn:root</xsl:when>
	  <xsl:otherwise>
            <xsl:message select="concat('WARN ', ancestor::tei:s/@xml:id, 
                               ': replacing ud-syn:root with ud-syn:dep for non-root dependency')"/>
	    <xsl:text>ud-syn:dep</xsl:text>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:attribute>
      <xsl:apply-templates mode="root" select="@target"/>
    </xsl:copy>
  </xsl:template>

  <!-- Bug in STANZA, sometimes synt. relation is "<PAD>" -->
  <!-- We set it to general dependency "dep" -->
  <xsl:template mode="comp" match="tei:linkGrp[@type = 'UD-SYN']/tei:link[@ana='ud-syn:&lt;PAD&gt;']">
    <xsl:copy>
      <xsl:attribute name="ana">
        <xsl:message select="concat('WARN ', ancestor::tei:s/@xml:id, 
                               ': replacing ud-syn:&lt;PAD&gt; with ud-syn:dep')"/>
	<xsl:text>ud-syn:dep</xsl:text>
      </xsl:attribute>
      <xsl:apply-templates mode="comp" select="@target"/>
    </xsl:copy>
  </xsl:template>

  <!-- Bug in DK, using obsolete obl:loc dependency -->
  <!-- We set it to "advmod:lmod", although this will produce errors when UPOS of token is not ADV 
  cf. https://github.com/clarin-eric/ParlaMint/issues/737 -->
  <xsl:template mode="comp" match="tei:linkGrp[@type = 'UD-SYN']/tei:link[@ana='ud-syn:obl_loc']">
    <xsl:copy>
      <xsl:attribute name="ana">
        <xsl:message select="concat('WARN ', ancestor::tei:s/@xml:id, 
                               ': replacing ud-syn:obl_loc with ud-syn:advmod_lmod')"/>
	<xsl:text>ud-syn:advmod_lmod</xsl:text>
      </xsl:attribute>
      <xsl:apply-templates mode="comp" select="@target"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
