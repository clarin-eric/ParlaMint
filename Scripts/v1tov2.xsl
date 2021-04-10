<?xml version='1.0' encoding='UTF-8'?>
<!-- Fix bugs from ParlaMint V1 for V2 -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:et="http://nl.ijs.si/et"
  exclude-result-prefixes="et fn tei">
  <xsl:output indent="yes"/>
  <xsl:strip-space elements="*"/>
  <xsl:preserve-space elements="tei:change tei:seg"/>

  <xsl:param name="version">2.0</xsl:param>
  <xsl:param name="handle">http://hdl.handle.net/11356/1388</xsl:param>
  <xsl:param name="handle-ana">http://hdl.handle.net/11356/1405</xsl:param>
  <xsl:param name="change">
    <change when="{$today-iso}"><name>Tomaž Erjavec</name>: Fixes for Version 2.</change>
  </xsl:param>
  <xsl:variable name="today-iso" select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>
  <xsl:variable name="id" select="replace(document-uri(/), '.+/([^/]+)\.xml', '$1')"/>
  <xsl:variable name="lang" select="/tei:*/@xml:lang"/>
  
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
    <xsl:text>&#10;</xsl:text>
    <xsl:apply-templates/>
  </xsl:template>

  <!-- STAMP -->
  <xsl:template match="tei:editionStmt/tei:edition">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:value-of select="$version"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:idno[@type='wikimedia']">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="type">URI</xsl:attribute>
      <xsl:attribute name="subtype" select="@type"/>
      <xsl:value-of select="."/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tei:idno[@type='handle']">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="type">URI</xsl:attribute>
      <xsl:attribute name="subtype">handle</xsl:attribute>
      <xsl:choose>
	<xsl:when test="$type = 'txt'">
	  <xsl:value-of select="$handle"/>
	</xsl:when>
	<xsl:when test="$type = 'ana'">
	  <xsl:value-of select="$handle-ana"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:message terminate="yes">WHAT!?</xsl:message>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tei:ref[matches(., 'hdl.handle.net')]">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:choose>
	<xsl:when test="$type = 'txt'">
	  <xsl:attribute name="target" select="$handle"/>
	  <xsl:value-of select="$handle"/>
	</xsl:when>
	<xsl:when test="$type = 'ana'">
	  <xsl:attribute name="target" select="$handle-ana"/>
	  <xsl:value-of select="$handle-ana"/>
	</xsl:when>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:publicationStmt/tei:date">
    <xsl:copy>
      <xsl:attribute name="when" select="$today-iso"/>
      <xsl:value-of select="$today-iso"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- Put in <revisionDesc> if there is none in the teiHeader -->
  <xsl:template match="tei:teiHeader">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
      <xsl:if test="not(tei:revisionDesc)">
	<revisionDesc>
	  <xsl:copy-of select="$change"/>
	</revisionDesc>
      </xsl:if>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="tei:revisionDesc">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:copy-of select="$change"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
    
  <!-- FIX -->

  <xsl:template match="tei:teiCorpus/tei:teiHeader//
		       tei:titleStmt/tei:title[@type = 'main'][@xml:lang='en']">
    <xsl:variable name="country" select="replace($id, 'ParlaMint-(..).*', '$1')"/>
    <xsl:variable name="ana">
      <xsl:if test="ends-with($id, '.ana')">.ana</xsl:if>
    </xsl:variable>
    <xsl:variable name="stamp" select="concat('[ParlaMint' , $ana, ']')"/>
    <xsl:if test="not(matches($country, '^[A-Z][A-Z]$'))">
      <xsl:message terminate="yes" select="concat('ERROR ', $id, ': bad top ID ', $stamp)"/>
    </xsl:if>
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:choose>
	<xsl:when test="not(matches(., 
			concat('^[^ ]+ parliamentary corpus ', $id, ' ', $stamp, '$')))">
	  <xsl:variable name="new" select="concat(replace(., '(.+?) .+', '$1'),
					   ' parliamentary corpus ',
					   replace($id, '\.ana', ''), ' ', $stamp
					   )"/>
	  <xsl:message select="concat('WARN ', $id, ': replacing main title ', ., ' with ', $new)"/>
	  <xsl:value-of select="$new"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="."/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="tei:TEI/tei:teiHeader//tei:titleStmt/tei:title[@type = 'main'][@xml:lang='en']">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:choose>
	<xsl:when test="matches(., 'Parliamentary Corpus')">
	  <xsl:variable name="new" select="replace(., 'Parliamentary Corpus', 'parliamentary corpus')"/>
	  <xsl:message select="concat('WARN ', $id, ': replacing main title ', ., ' with ', $new)"/>
	  <xsl:value-of select="$new"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="."/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>
  
  <!-- Add language to title if missing -->
  <xsl:template match="tei:TEI/tei:teiHeader//tei:sourceDesc//tei:title[not(@xml:lang='en')]
		       [contains(., 'Minutes')]">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="xml:lang">en</xsl:attribute>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <!-- Just noticed redundant pubPlace, as we have:
       <publicationStmt>
         <idno type="handle">http://hdl.handle.net/11356/1388</idno>
         <pubPlace>
           <ref target="http://hdl.handle.net/11356/1345">http://hdl.handle.net/11356/1345</ref>
         </pubPlace>
  -->
  <xsl:template match="tei:publicationStmt[tei:idno]/
		       tei:pubPlace[tei:ref[matches(@target, 'hdl.handle.net')]]">
    <xsl:message select="concat('WARN ', $id, ': deleting redundant pubPlace ', .)"/>
  </xsl:template>

  <!-- <orgName> without @full
       https://github.com/clarin-eric/ParlaMint/issues/1
  -->
  <xsl:template match="tei:org/tei:orgName[not(@full)]">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:message select="concat('WARN ', $id, ': adding @full=yes to ', .)"/>
      <xsl:attribute name="full">yes</xsl:attribute>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <!-- Root id != file name for .ana. files 
       https://github.com/clarin-eric/ParlaMint/issues/2      
  -->
  <xsl:template match="tei:teiCorpus | tei:TEI">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="@xml:id != $id">
	<xsl:attribute name="xml:id" select="$id"/>
	<xsl:message select="concat('WARN: changing root ID ', @xml:id, ' to ', $id)"/>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <!-- Wrong language in prefixDef/@ident="mte" for SI
       https://github.com/clarin-eric/ParlaMint/issues/7
  -->
  <xsl:template match="tei:teiCorpus[@xml:lang='sl']/tei:teiHeader//tei:prefixDef[@ident='mte']">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="replacementPattern">
	<xsl:text>http://nl.ijs.si/ME/V6/msd/tables/msd-fslib-sl.xml#$1</xsl:text>
      </xsl:attribute>
      <xsl:message select="concat('WARN ', $id, ': changing SI MTE prefixDef')"/>
      <p xml:lang="en">
	<xsl:value-of select="replace(., 'Serbocroatian', 'Slovenian')"/>
      </p>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:prefixDef/tei:p[not(@xml:lang)]">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:message select="concat('WARN ', $id, ': giving @xml:lang=en to p with ', .)"/>
      <xsl:attribute name="xml:lang">en</xsl:attribute>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <!-- Bad affiliation/@role values in BG
       https://github.com/clarin-eric/ParlaMint/issues/8
  -->
  <xsl:template match="tei:affiliation/@role">
    <xsl:variable name="role">
      <xsl:choose>
	<xsl:when test=". = 'deputyPrimeMinster'">deputyPrimeMinister</xsl:when>
	<xsl:when test=". = 'candidate-chairman'">candidateChairman</xsl:when>
	<xsl:when test=". = 'chair-of-parliament'">chairman</xsl:when>
	<xsl:when test=". = 'chairperson'">chairman</xsl:when>
	<xsl:when test=". = 'head-of-department'">headOfDepartment</xsl:when>
	<xsl:when test=". = 'prosecutor-general'">prosecutorGeneral</xsl:when>
	<xsl:when test=". = 'vice-chairman'">viceChairman</xsl:when>
	<xsl:when test=". = 'vice-chair-of-parliament'">viceChairman</xsl:when>
	<xsl:when test=". = 'vice-director'">viceDirector</xsl:when>
	<xsl:when test=". = 'vice-president'">vicePresident</xsl:when>
	<xsl:otherwise>
	  <xsl:if test="matches(., '[_-]')">
	    <xsl:message terminate="yes"
			 select="concat('ERROR ', $id, ': uncaught bad affiliation/@role = ', .)"/>
	  </xsl:if>
	  <xsl:value-of select="."/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:attribute name="role">
      <xsl:if test=". != $role">
	<xsl:message select="concat('WARN ', $id, ': changing role from ', . , ' to ', $role)"/>
      </xsl:if>
      <xsl:value-of select="$role"/>
    </xsl:attribute>
  </xsl:template>
  
  <!-- Bad org/@role values
       https://github.com/clarin-eric/ParlaMint/issues/9
       https://github.com/clarin-eric/ParlaMint/issues/54
  -->
  <xsl:template match="tei:org/@role">
    <xsl:variable name="role">
      <xsl:choose>
	<xsl:when test=". = 'political_party'">politicalParty</xsl:when>
	<xsl:when test=". = 'ethnic_communities'">ethnicCommunity</xsl:when>
	<xsl:when test=". = 'independet'">independent</xsl:when>
	<xsl:otherwise>
	  <xsl:if test="matches(., '[_-]')">
	    <xsl:message terminate="yes"
			 select="concat('ERROR ', $id, ': uncaught bad org/@role = ', .)"/>
	  </xsl:if>
	  <xsl:value-of select="."/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:attribute name="role">
      <xsl:if test=". != $role">
	<xsl:message select="concat('WARN ', $id, ': changing role from ', . , ' to ', $role)"/>
      </xsl:if>
      <xsl:value-of select="$role"/>
    </xsl:attribute>
  </xsl:template>
  
  <!-- Bad English translation
       https://github.com/clarin-eric/ParlaMint/issues/12
  -->
  <xsl:template match="tei:teiCorpus[@xml:lang='bg']//tei:event/tei:label[. = 'Term 7']">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:message select="concat('WARN ', $id, ': giving better translation for ', .)"/>
      <xsl:text>Term 43</xsl:text>
    </xsl:copy>
  </xsl:template>

  <!-- Fix BG language codes and add Latin transliteration where missing 
  -->
  <xsl:template match="tei:langUsage[$lang ='bg']">
    <xsl:copy>
      <language ident="bg-Latn" xml:lang="en">Bulgarian in Latin script</language>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="tei:persName[$lang ='bg']">
    <xsl:copy>
      <xsl:attribute name="xml:lang">
	<xsl:choose>
	  <xsl:when test="not(@xml:lang)">bg</xsl:when>
	  <xsl:when test="@xml:lang = 'bg'">bg</xsl:when>
	  <xsl:when test="@xml:lang = 'en'">bg-Latn</xsl:when>
	</xsl:choose>
      </xsl:attribute>
      <xsl:apply-templates/>
    </xsl:copy>
    <xsl:if test="@xml:lang = 'bg' and 
		  not(following-sibling::tei:persName[@xml:lang='en'])">
      <xsl:variable name="enName">
	<xsl:choose>
	  <xsl:when test="tei:*">
	    <xsl:message select="concat('WARN ', $id, ': adding Latn to ', 
				 ancestor::tei:person/@xml:id)"/>
	    <xsl:for-each select="tei:*">
	      <xsl:copy>
		<xsl:value-of select="et:bg2en(.)"/>
	      </xsl:copy>
	    </xsl:for-each>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:message select="concat('WARN ', $id, ': adding Latn to ', .)"/>
	    <xsl:value-of select="et:bg2en(.)"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:variable>
      <xsl:copy>
	<xsl:attribute name="xml:lang">bg-Latn</xsl:attribute>
	<xsl:copy-of select="$enName"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>
  
  <!-- u/@who is now optional, get rid of Anonymous speaker
       https://github.com/clarin-eric/ParlaMint/issues/29
  -->
  <xsl:template match="tei:listPerson/tei:person[
		       @xml:id = 'Anonymous' or 
		       @xml:id = 'anonymous' or 
		       @xml:id = 'Anon' or 
		       @xml:id = 'anon' or 
		       @xml:id = 'Unknown' or 
		       @xml:id = 'unknown'
		       ]">
    <xsl:message select="concat('WARN ', $id, ': removing anonymous person ', @xml:id)"/>
  </xsl:template>
  
  <xsl:template match="tei:u[
		       @who = '#Anonymous' or 
		       @who = '#anonymous' or 
		       @who = '#Anon' or 
		       @who = '#anon' or 
		       @who = '#Unknown' or 
		       @who = '#unknown'
		       ]">
    <xsl:choose>
      <xsl:when test="tei:seg">
	<xsl:message select="concat('WARN ', $id, ': removing anonymous u/@who for ', @xml:id)"/>
	<xsl:copy>
	  <xsl:apply-templates select="@*[not(name() = 'who')]"/>
	  <xsl:apply-templates/>
	</xsl:copy>
      </xsl:when>
      <xsl:otherwise>
	<xsl:message select="concat('WARN ', $id, ': removing anonymous u with no segs ', @xml:id)"/>
	<xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- This type value is no loger valid, just remove it -->
  <!--xsl:template match="tei:kinesic/@type[.='kinesic']"/-->
  
  <!-- Change UD synt. roles in link/@ana so they use : not _
       https://github.com/clarin-eric/ParlaMint/issues/27
  -->
  <!-- This does NOT work, as you can't have colons in xsl:ID!! -->
  <!--xsl:template match="tei:linkGrp/tei:link/@ana">
    <xsl:attribute name="ana">
      <xsl:text>ud-syn:</xsl:text>
      <xsl:value-of select="replace(substring-after(., ':'), '_', ':')"/>
    </xsl:attribute>
  </xsl:template>
  <xsl:template match="tei:taxonomy[@xml:id='UD-SYN']/tei:category/@xml:id">
    <xsl:attribute name="xml:id" select="replace(., '_', ':')"/>
  </xsl:template-->
  
  <!-- Add text/@ana, actually missing only on SI!
       https://github.com/clarin-eric/ParlaMint/issues/24
  -->
  <xsl:template match="tei:text[not(@ana)]">
    <xsl:variable name="subcorpus">
      <xsl:choose>
	<xsl:when test="contains(ancestor::tei:TEI/@ana, '#reference')">#reference</xsl:when>
	<xsl:when test="contains(ancestor::tei:TEI/@ana, '#covid')">#covid</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:message select="concat('WARN ', $id, ': giving text/@ana = ', $subcorpus, ' to ', $id)"/>
      <xsl:attribute name="ana" select="$subcorpus"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <!-- add @pos to w and pc (and other stuff!)
       https://github.com/clarin-eric/ParlaMint/issues/47
       So, BG, which has local tagset in msd has to be changed from
       <w lemma="налице" msd="UPosTag=ADV|Degree=Pos|XPosTag=Dm">Налице</w>
       to
       <w lemma="налице" pos="Dm" msd="UPosTag=ADV|Degree=Pos">Налице</w>
       Also:
       - get rid of PL bug: msd="UPosTag=|PUNCT|PunctType=Colo"
       - sort features, but with UPosTag first
  -->
  <xsl:template match="tei:w | tei:pc">
    <xsl:copy>
      <!-- This one is to correct PL bug -->
      <xsl:variable name="msd" select="replace(@msd, 'UPosTag=\|', 'UPosTag=')"/>
      <xsl:variable name="upos" select="replace($msd, '.*(UPosTag=[^|]+).*', '$1')"/>
      <xsl:variable name="xpos">
	<xsl:if test="contains($msd, 'XPosTag')">
	  <xsl:value-of select="replace($msd, '.*XPosTag=([^|]+).*', '$1')"/>
	</xsl:if>
      </xsl:variable>
      <xsl:variable name="ufeats" select="replace(
					  replace($msd, 
					  'UPosTag=[^|]+\|?', ''),
					  '\|?XPosTag=[^|]+', '')
					  "/>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="msd">
	<xsl:choose>
	  <xsl:when test="normalize-space($ufeats)">
	    <xsl:value-of select="concat($upos, '|', et:sort_feats($ufeats))"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of select="$upos"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:attribute>
      <xsl:if test="normalize-space($xpos)">
	<xsl:attribute name="pos" select="$xpos"/>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <!-- Remove leading, trailing and multiple spaces -->
  <xsl:template match="text()[normalize-space(.)]">
    <xsl:choose>
      <xsl:when test="(not(preceding-sibling::tei:*) and matches(., '^ ')) and 
		      (not(following-sibling::tei:*) and matches(., ' $'))">
	<xsl:message select="concat('WARN ', $id, ': removing leading and trailing space in ', .)"/>
	<xsl:value-of select="replace(., '^ +(.+?) +$', '$1')"/>
      </xsl:when>
      <xsl:when test="not(preceding-sibling::tei:*) and matches(., '^ ')">
	<xsl:message select="concat('WARN ', $id, ': removing leading space in ', .)"/>
	<xsl:value-of select="replace(., '^ +', '')"/>
      </xsl:when>
      <xsl:when test="not(following-sibling::tei:*) and matches(., ' $')">
	<xsl:message select="concat('WARN ', $id, ': removing trailing space in ', .)"/>
	<xsl:value-of select="replace(., ' +$', '')"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="replace(., '  +', ' ')"/>
      </xsl:otherwise>
    </xsl:choose>
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
  
  <xsl:function name="et:sort_feats">
    <xsl:param name="feats"/>
    <xsl:variable name="sorted">
      <xsl:for-each select="tokenize($feats, '\|')">
	<xsl:sort select="lower-case(.)" order="ascending"/>
	<xsl:value-of select="."/>
	<xsl:text>|</xsl:text>
      </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="replace($sorted, '\|$', '')"/>
  </xsl:function>
  
  <xsl:function name="et:bg2en">
    <xsl:param name="str"/>
    <xsl:variable name="bg"
		  select="
			  replace(
			  replace(
			  replace(
			  replace(
			  replace(
			  replace(
			  replace(
			  replace(
			  replace(
			  replace(
			  replace(
			  replace(
			  replace(
			  replace(
			  replace(
			  replace(
			  translate($str, 
			  'ъабвгдезиклмнопрстфйхуЪАБВГДЕЗИКЛМНОПРСТФЙХУ',
			  'aabvgdeziklmnoprstfyhuAABVGDEZIKLMNOPRSTFYHU'),
			  'ю', 'ju'),
			  'ж', 'zh'),
			  'ч', 'ch'),
			  'ш', 'sh'),
			  'щ', 'sht'),
			  'ц', 'ts'),
			  'я', 'ya'),
			  'ь', 'yo'),
			  'Ю', 'Ju'),
			  'Ж', 'Zh'),
			  'Ч', 'Ch'),
			  'Ш', 'Sh'),
			  'Щ', 'Sht'),
			  'Ц', 'Ts'),
			  'Я', 'Ya'),
			  'Ь', 'Yo')
			  "/>
    <xsl:if test="normalize-space(replace($bg, '[A-Za-z-]', ''))">
      <xsl:message select="concat('FATAL ', $id, ': transliteration ', $bg)"/>
    </xsl:if>
    <xsl:value-of select="$bg"/>
  </xsl:function>
</xsl:stylesheet>
