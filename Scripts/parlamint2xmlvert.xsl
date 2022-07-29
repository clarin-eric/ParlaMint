<?xml version="1.0"?>
<!-- Transform one ParlaMint file to CQP vertical format.
     Note that the output is still in XML, and needs another polish. -->
<!-- Needs the file with corpus teiHeader as a parameter -->
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:fn="http://www.w3.org/2005/xpath-functions" 
    xmlns:et="http://nl.ijs.si/et"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xi="http://www.w3.org/2001/XInclude"
    exclude-result-prefixes="fn et tei xs xi"
    version="2.0">

  <xsl:output method="xml" encoding="utf-8" indent="no" omit-xml-declaration="yes"/>
  
  <!-- File with corpus teiHeader for information about taxonomies, persons, parties -->
  <xsl:param name="hdr"/>

  <!-- Output labels for MPs and guests -->
  <xsl:param name="mp-label">MP</xsl:param>
  <xsl:param name="guest-label">notMP</xsl:param>

  <!-- String to put at the start and end of "incidents", i.e. transcriber notes -->
  <xsl:param name="note-open">[</xsl:param>
  <xsl:param name="note-close">]</xsl:param>
  
  <xsl:variable name="today-iso" select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>

  <xsl:key name="id" match="tei:*" use="@xml:id"/>
  <!-- Key which directly finds local references -->
  <xsl:key name="idr" match="tei:*" use="concat('#', @xml:id)"/>

  <xsl:variable name="teiHeader">
    <xsl:if test="not(doc-available($hdr))">
      <xsl:message terminate="yes">
	<xsl:text>TEI header file </xsl:text>
	<xsl:value-of select="$hdr"/>
	<xsl:text> not found!</xsl:text>
      </xsl:message>
    </xsl:if>
     <xsl:copy-of select="document($hdr)"/>
  </xsl:variable>

  <xsl:variable name="date-from">
    <xsl:variable name="d" select="/tei:TEI/tei:teiHeader//tei:settingDesc//tei:date"/>
    <xsl:choose>
      <xsl:when test="$d/@when">
	<xsl:value-of select="$d/@when"/>
      </xsl:when>
      <xsl:when test="$d/@from">
	<xsl:value-of select="$d/@from"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:message terminate="yes">
	  <xsl:text>Can't find TEI date(s) in settingDesc of input file!</xsl:text>
	</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="date-to">
    <xsl:variable name="d" select="/tei:TEI/tei:teiHeader//tei:settingDesc//tei:date"/>
    <xsl:choose>
      <xsl:when test="$d/@when">
	<xsl:value-of select="$d/@when"/>
      </xsl:when>
      <xsl:when test="$d/@to">
	<xsl:value-of select="$d/@to"/>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>
  
  <xsl:template match="@*"/>
  <xsl:template match="text()"/>
  <xsl:template match="tei:*">
    <xsl:message>
      <xsl:text>WARN: unexpected element </xsl:text>
      <xsl:value-of select="name()"/>
      <xsl:value-of select="concat(' in ', ancestor::tei:TEI/@xml:id, ' : ', @xml:id)"/>
    </xsl:message>
  </xsl:template>

  <xsl:template match="tei:TEI">
    <xsl:variable name="text_id" select="replace(@xml:id, '\.ana', '')"/>
    <xsl:variable name="subcorpus">
      <xsl:for-each select="tokenize(@ana, ' ')">
	<xsl:if test="key('idr', ., $teiHeader)/
		      ancestor::tei:taxonomy/tei:desc/tei:term = 'Subcorpora'">
	  <xsl:value-of select="key('idr', ., $teiHeader)//tei:catDesc
				[ancestor-or-self::tei:*[@xml:lang][1][@xml:lang='en']]
				/tei:term"/>
	  </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="house">
      <xsl:call-template name="house"/>
    </xsl:variable>
    <xsl:variable name="term">
      <xsl:call-template name="meeting">
	<xsl:with-param name="ref">parla.term</xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="session">
      <xsl:call-template name="meeting">
	<xsl:with-param name="ref">parla.session</xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="meeting">
      <xsl:call-template name="meeting">
	<xsl:with-param name="ref">parla.meeting</xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="sitting">
      <xsl:call-template name="meeting">
	<xsl:with-param name="ref">parla.sitting</xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="agenda">
      <xsl:call-template name="meeting">
	<xsl:with-param name="ref">parla.agenda</xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="from" select="$date-from"/>
    <xsl:variable name="to" select="$date-to"/>
    <xsl:variable name="title">
      <xsl:variable name="titles" select="tei:teiHeader/tei:fileDesc/
					  tei:titleStmt/tei:title"/>
      <xsl:choose>
	<xsl:when test="$titles[@type='sub']
			[ancestor-or-self::tei:*[@xml:lang][1][@xml:lang='en']]">
	  <xsl:value-of select="$titles[@type='sub']
				[ancestor-or-self::tei:*[@xml:lang][1][@xml:lang='en']]
				[1]"/>
	</xsl:when>
	<xsl:when test="$titles[@type='sub']">
	  <xsl:value-of select="$titles[@type='sub'][1]"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="replace($titles[1], '\s*\[.+?\]$', '')"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:for-each select="tei:text/tei:body/tei:div/tei:*">
      <xsl:choose>
	<xsl:when test="self::tei:u">
	  <xsl:variable name="speech_id" select="replace(@xml:id, '\.ana', '')"/>
	  <speech id="{$speech_id}" text_id="{$text_id}"
		  subcorpus="{$subcorpus}"
		  house="{$house}" term="{$term}" session="{$session}"
		  meeting="{$meeting}" sitting="{$sitting}" agenda="{$agenda}"
		  from="{$from}" to="{$to}" title="{$title}">
	    <xsl:attribute name="speaker_role" select="et:u-role(@ana)"/>
	    <xsl:choose>
	    <xsl:when test="@who">
	      <xsl:variable name="speaker" select="key('idr', @who, $teiHeader)"/>
	      <xsl:attribute name="speaker_role" select="et:u-role(@ana)"/>
	      <xsl:attribute name="speaker_id" select="$speaker/@xml:id"/>
	      <xsl:attribute name="speaker_name" select="et:format-name($speaker//tei:persName[1])"/>
	      <xsl:attribute name="speaker_type" select="et:speaker-type($speaker)"/>
	      <xsl:attribute name="speaker_party" select="et:speaker-party($speaker, 'abb')"/>
	      <xsl:attribute name="speaker_party_name" select="et:speaker-party($speaker, 'yes')"/>
	      <xsl:attribute name="party_status" select="et:party-status($speaker)"/>
	      <xsl:attribute name="speaker_gender" select="$speaker/tei:sex/@value"/>
	      <xsl:attribute name="speaker_birth" select="replace($speaker/tei:birth/@when, '-.+', '')"/>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:attribute name="speaker_role"/>
	      <xsl:attribute name="speaker_id"/>
	      <xsl:attribute name="speaker_name"/>
	      <xsl:attribute name="speaker_type"/>
	      <xsl:attribute name="speaker_party"/>
	      <xsl:attribute name="speaker_party_name"/>
	      <xsl:attribute name="party_status"/>
	      <xsl:attribute name="speaker_gender"/>
	      <xsl:attribute name="speaker_birth"/>
	    </xsl:otherwise>
	    </xsl:choose>
	    <xsl:text>&#10;</xsl:text>
	    <xsl:apply-templates/>
	  </speech>
	  <xsl:text>&#10;</xsl:text>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:apply-templates select="."/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="tei:pb"/>
  
  <!-- Conflate head, note, gap and all "incidents" into <note> -->
  <xsl:template match="tei:head | tei:note | tei:gap | tei:vocal | tei:incident | tei:kinesic">
    <note>
      <xsl:attribute name="type">
	<xsl:choose>
	  <xsl:when test="self::tei:head">head</xsl:when>
	  <xsl:when test="self::tei:note[@type]">
	    <xsl:value-of select="@type"/>
	  </xsl:when>
	  <xsl:when test="self::tei:note">-</xsl:when>
	  <xsl:when test="@type">
	    <xsl:value-of select="concat(name(), ':', @type)"/>
	  </xsl:when>
	  <xsl:when test="@reason">
	    <xsl:value-of select="concat(name(), '::', @reason)"/>
	  </xsl:when>
	</xsl:choose>
      </xsl:attribute>
      <xsl:attribute name="content">
	<xsl:value-of select="normalize-space(.)"/>
      </xsl:attribute>
    </note>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
  
  <xsl:template match="tei:seg">
    <p id="{@xml:id}">
      <!-- We add language attribute (needed for for BE, which has fr+nl) -->
      <xsl:variable name="lang-code" select="ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang"/>
      <xsl:attribute name="lang" select="$teiHeader//tei:langUsage/tei:language
					 [@ident=$lang-code]
					 [ancestor-or-self::tei:*[@xml:lang][1][@xml:lang='en']]"/>
      <xsl:text>&#10;</xsl:text>
      <xsl:apply-templates/>
    </p>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="tei:name">
    <xsl:choose>
      <xsl:when test="ancestor::tei:name">
	<xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:copy>
	  <xsl:copy-of select="@type"/>
	  <xsl:text>&#10;</xsl:text>
	  <xsl:apply-templates/>
	</xsl:copy>
	<xsl:text>&#10;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Used by CZ, currently ignored -->
  <xsl:template match="tei:date | tei:time | 
		       tei:num | tei:unit | 
		       tei:email | tei:ref">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="tei:s">
    <xsl:copy>
      <xsl:attribute name="id" select="@xml:id"/>
      <xsl:text>&#10;</xsl:text>
      <xsl:apply-templates/>
    </xsl:copy>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="tei:linkGrp"/>
  
  <!-- We have do deal with syntactic words, e.g.:

  <w xml:id="u1.p1.s1.w18">abych
    <w xml:id="u1.p1.s1.w19" lemma="aby" msd="UPosTag=SCONJ" norm="aby"/>
    <w xml:id="u1.p1.s1.w20" lemma="být" msd="UPosTag=AUX|Mood=Cnd" norm="bych"/>
  </w>

  <link ana="ud-syn:punct" target="#u1.p1.s1.w21 #u1.p1.s1.w17"/>
  <link ana="ud-syn:mark"  target="#u1.p1.s1.w21 #u1.p1.s1.w19"/>
  <link ana="ud-syn:aux"   target="#u1.p1.s1.w21 #u1.p1.s1.w20"/>

  Solution:
  - introduce normalised column (multi valued)
  - make all attributes multivalued 

  In theory there is also:
    <w norm="najlepši" lemma="lep">
      <w>nar</w>
      <w>lepši</w>
    </w>
   We do not cover this case!
  -->

  <!-- TOKENS -->
  <xsl:template match="tei:pc | tei:w">
    <!-- Output token -->
    <xsl:value-of select="concat(normalize-space(.),'&#9;')"/>
    <xsl:choose>
      <!-- For normalized words e.g.
 	<w xml:id="u1.p1.s1.w18">abych
	 <w xml:id="u1.p1.s1.w19" lemma="aby" msd="UPosTag=SCONJ" norm="aby"/>
	 <w xml:id="u1.p1.s1.w20" lemma="být" msd="UPosTag=AUX|Mood=Cnd" norm="bych"/>
	</w>
      -->
      <xsl:when test="normalize-space(text()[1]) and (tei:w or tei:pc)">
	<xsl:variable name="norms">
	  <xsl:for-each select="tei:w | tei:pc">
	    <xsl:value-of select="@norm"/>
	    <xsl:text>|</xsl:text>
	  </xsl:for-each>
	</xsl:variable>
	<xsl:value-of select="concat(replace($norms, '\|$', ''),'&#9;')"/>
	<xsl:variable name="toks">
	  <xsl:for-each select="tei:w | tei:pc">
	    <list>
	      <xsl:for-each select="tokenize(et:output-annotations(.), '&#9;')">
		<item>
		  <xsl:value-of select="."/>
		</item>
	      </xsl:for-each>
	    </list>
	  </xsl:for-each>
	</xsl:variable>
	<xsl:value-of select="et:join-annotations($toks)"/>
	<xsl:variable name="deps">
	  <xsl:for-each select="tei:w | tei:pc">
	    <list>
	      <xsl:variable name="annots">
		<xsl:call-template name="deps">
		  <xsl:with-param name="id" select="@xml:id"/>
		</xsl:call-template>
	      </xsl:variable>
	      <xsl:for-each select="tokenize($annots, '&#9;')">
		<item>
		  <xsl:value-of select="."/>
		</item>
	      </xsl:for-each>
	    </list>
	  </xsl:for-each>
	</xsl:variable>
	<xsl:text>&#9;</xsl:text>
	<xsl:value-of select="et:join-annotations($deps)"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="concat(., '&#9;', et:output-annotations(.), '&#9;')"/>
	<xsl:call-template name="deps"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#10;</xsl:text>
    <xsl:if test="@join = 'right' or @join='both' or
		  following::tei:*[self::tei:w or self::tei:pc][1]/@join = 'left' or
		  following::tei:*[self::tei:w or self::tei:pc][1]/@join = 'both'">
      <g/>
      <xsl:text>&#10;</xsl:text>
    </xsl:if>
  </xsl:template>

  <!-- NAMED TEMPLATES -->

  <!-- Get the name (Lower House, Upper house, -) of the house from meeting element, e.g.
       <meeting ana="#parla.term #parla.lower #parliament.PSP8" n="ps2017">ps2017</meeting>
       <meeting corresp="#PoGB" ana="#parla.upper #parla.meeting.regular"/>
       <meeting ana="#parla.meeting.regular" corresp="#NS" n="394">394 пленарно заседание</meeting>
  -->
  <xsl:template name="house">
    <xsl:param name="lower">Lower house</xsl:param>
    <xsl:param name="upper">Upper house</xsl:param>
    <xsl:param name="none"></xsl:param>
    <xsl:variable name="titleStmt" select="//tei:teiHeader/tei:fileDesc/tei:titleStmt"/>
    <xsl:variable name="is_lower">
      <xsl:for-each select="$titleStmt/tei:meeting">
	<xsl:for-each select="tokenize(@ana, ' ')">
	  <xsl:if test="key('idr', ., $teiHeader)/tei:catDesc[tei:term = $lower]">X</xsl:if>
	</xsl:for-each>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="is_upper">
      <xsl:for-each select="$titleStmt/tei:meeting">
	<xsl:for-each select="tokenize(@ana, ' ')">
	  <xsl:if test="key('idr', ., $teiHeader)/tei:catDesc[tei:term = $upper]">X</xsl:if>
	</xsl:for-each>
      </xsl:for-each>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="normalize-space($is_lower)">
	<xsl:value-of select="$lower"/>
      </xsl:when>
      <xsl:when test="normalize-space($is_upper)">
	<xsl:value-of select="$upper"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$none"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Get @n from appropriate meeting type, e.g.
       <meeting n="7" corresp="#DZ" ana="#parla.term #DZ.7">7. mandat</meeting>
       <meeting n="1" corresp="#DZ" ana="#parla.meeting.regular">Redna</meeting>
       or
       <meeting ana="#parla.lower">Sejm</meeting>
       <meeting n="8-lower" ana="#parla.lower #parla.term">8. kadencja Sejmu</meeting>
       <meeting n="1-lower" ana="#parla.lower #parla.session">1. sesja Sejmu</meeting>
       <meeting n="1-lower" ana="#parla.lower #parla.sitting">1. dzień sesji Sejmu</meeting>
       or
       <meeting ana="#parla.term #parla.lower #parliament.PSP8" n="ps2017">ps2017</meeting>
       <meeting ana="#parla.meeting #parla.lower" n="ps2017/070">ps2017/070</meeting>
       <meeting ana="#parla.sitting #parla.lower" n="ps2017/070/01">ps2017/070/01</meeting>
       <meeting ana="#parla.agenda #parla.lower" n="ps2017/070/001">ps2017/070/001</meeting>
       
  -->
  <xsl:template name="meeting">
    <xsl:param name="ref"/>
    <xsl:variable name="result">
      <xsl:variable name="idref" select="concat('#', $ref)"/>
      <xsl:for-each select="//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:meeting">
	<xsl:variable name="n" select="@n"/>
	<xsl:for-each select="tokenize(@ana, ' ')">
	  <xsl:if test="starts-with(., $idref)">
	    <xsl:value-of select="$n"/>
	  </xsl:if>
	</xsl:for-each>
      </xsl:for-each>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="normalize-space($result)">
	<xsl:value-of select="$result"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:text></xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
    
  <xsl:template name="deps">
    <xsl:param name="type">UD-SYN</xsl:param>
    <xsl:param name="id" select="@xml:id"/>
    <xsl:variable name="s" select="ancestor::tei:s"/>
    <xsl:choose>
      <xsl:when test="$s/tei:linkGrp[@type=$type]">
	<xsl:variable name="link"
		      select="$s/tei:linkGrp[@type=$type]/tei:link
			      [ends-with(@target, concat(' #', $id))]"/>
	<xsl:if test="not(normalize-space($link/@ana))">
	  <xsl:message>
	    <xsl:text>ERROR: no syntactic link for token </xsl:text>
	    <xsl:value-of select="concat(ancestor::tei:TEI/@xml:id, ':', @xml:id)"/>
	  </xsl:message>
	</xsl:if>
	<!-- Syntactic relation is the English term in the UD-SYN taxonomy -->
	<xsl:variable name="relation" select="substring-after($link/@ana,':')"/>
	<xsl:value-of select="key('id', $relation, $teiHeader)//tei:term
			      [ancestor-or-self::tei:*[@xml:lang][1][@xml:lang='en']]"/>
	<xsl:variable name="target" select="key('id', replace($link/@target,'#(.+?) #.*','$1'))"/>
	<xsl:choose>
	  <xsl:when test="$target/self::tei:s">
	    <xsl:text>&#9;-&#9;-&#9;-&#9;-</xsl:text>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of select="concat('&#9;', et:output-annotations($target))"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:when>
      <xsl:otherwise>
	<xsl:message>
	  <xsl:text>ERROR: no linkGroup for sentence </xsl:text>
	  <xsl:value-of select="ancestor::tei:s/@xml:id"/>
	</xsl:message>
	<xsl:text>&#9;-&#9;-&#9;-&#9;-</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- FUNCTIONS -->

  <!-- Format the name of a person from persName -->
  <xsl:function name="et:format-name">
    <xsl:param name="persName"/>
    <xsl:variable name="surnames">
      <xsl:for-each select="$persName/tei:surname">
	<xsl:value-of select="."/>
	<xsl:if test="following-sibling::tei:surname">
	  <xsl:text>&#32;</xsl:text>
	</xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="forenames">
      <xsl:for-each select="$persName/tei:forename">
	<xsl:value-of select="."/>
	<xsl:if test="following-sibling::tei:forename">
	  <xsl:text>&#32;</xsl:text>
	</xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="normalize-space($surnames) and normalize-space($forenames)">
	<xsl:value-of select="concat($surnames, ', ', $forenames)"/>
      </xsl:when>
      <xsl:when test="normalize-space($surnames)">
	<xsl:value-of select="normalize-space($surnames)"/>
      </xsl:when>
      <xsl:when test="normalize-space($forenames)">
	<xsl:value-of select="normalize-space($surnames)"/>
      </xsl:when>
      <xsl:when test="$persName/tei:term">
	<xsl:value-of select="concat('@', $persName/tei:term, '@')"/>
      </xsl:when>
      <xsl:when test="normalize-space($persName)">
	<xsl:value-of select="$persName"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:message>
	  <xsl:text>ERROR: empty persName!</xsl:text>
	</xsl:message>
	<xsl:text></xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- Output the role of the speaker from the taxonomy -->
  <!-- e.g. "#regular #topic.144_403_M" -->
  <xsl:function name="et:u-role" as="xs:string">
    <xsl:param name="ana"/>
    <xsl:for-each select="tokenize($ana, ' ')">
      <xsl:if test="key('idr', ., $teiHeader)/
		    ancestor::tei:taxonomy/tei:desc/tei:term = 'Types of speakers'">
	<xsl:value-of select="key('idr', ., $teiHeader)//tei:catDesc
			      [ancestor-or-self::tei:*[@xml:lang][1][@xml:lang='en']]
			      /tei:term"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:function>

  <!-- Output if the speaker is an MP or merely a 'visitor'
       when speaking (= check global $date-from and $date-to) -->
  <xsl:function name="et:speaker-type" as="xs:string">
    <xsl:param name="speaker" as="element(tei:person)"/>
    <xsl:variable name="mp" select="$speaker/tei:affiliation[@role='MP']"/>
    <xsl:variable name="type">
      <xsl:for-each select="$mp/self::tei:affiliation">
	<xsl:choose>
	  <xsl:when test="@from and @to">
	    <xsl:if test="et:between-dates($date-from, @from, @to) and
			  et:between-dates($date-to, @from, @to)">
	      <xsl:value-of select="$mp-label"/>
	    </xsl:if>
	  </xsl:when>
	  <xsl:when test="@from">
	    <xsl:if test="et:between-dates($date-from, @from, $today-iso) and
			  et:between-dates($date-to, @from, $today-iso)">
	      <xsl:value-of select="$mp-label"/>
	    </xsl:if>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of select="$mp-label"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:for-each>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="normalize-space($type)">
	<xsl:if test="$type ne $mp-label">
	  <xsl:message>
	    <xsl:text>ERROR: multiple MP for </xsl:text>
	    <xsl:value-of select="$speaker/@xml:id"/>
	    <xsl:text> on </xsl:text>
	    <xsl:value-of select="concat($date-from, ' - ', $date-to, ': ', $type)"/>
	  </xsl:message>
	</xsl:if>
	<xsl:value-of select="$type"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$guest-label"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- Output coalition/opposition/- of the speaker's party when speaking -->
  <xsl:function name="et:party-status" as="xs:string">
    <xsl:param name="speaker" as="element(tei:person)"/>
    <xsl:variable name="relations" select="$teiHeader//tei:relation
					   [@name='coalition' or @name='opposition']"/>
    <xsl:choose>
      <!-- Corpus does not have coalition / opposition) info -->
      <xsl:when test="not($relations/self::tei:relation)"><xsl:text></xsl:text></xsl:when>
      <xsl:otherwise>
	<!-- Relation in the correct time-frame, should be only 1 -->
	<xsl:variable name="relation">
	  <xsl:for-each select="$relations/self::tei:relation">
	    <xsl:choose>
	      <xsl:when test="@from and @to">
		<xsl:if test="et:between-dates($date-from, @from, @to) and
			      et:between-dates($date-to, @from, @to)">
		  <xsl:copy-of select="."/>
		</xsl:if>
	      </xsl:when>
	      <xsl:when test="@from">
		<xsl:if test="et:between-dates($date-from, @from, $today-iso) and
			      et:between-dates($date-to, @from, $today-iso)">
		  <xsl:copy-of select="."/>
		</xsl:if>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:copy-of select="."/>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:for-each>
	</xsl:variable>
	<!-- Is the organisation that the speaker is affiliated with in the 
	     coallition(s) / oppositions(s)? -->
	<!-- We don't check the type of organisation of the speaker's role in it, as we 
	     assume that this is "ok" -->
	<xsl:variable name="in-relation">
	  <!-- Collect all affiliation references where the speaker is a member and are in 
	       the correct time-frame for the speech -->
	  <xsl:variable name="org-refs" select="et:speaker-affiliations-refs($speaker)"/>
	  <xsl:for-each select="$relation/tei:relation[@name = 'coalition']/tokenize(@mutual)">
	    <xsl:variable name="relation-party" select="."/>
	    <xsl:for-each select="tokenize($org-refs, ' ')">
	      <xsl:if test="$relation-party = .">Coalition </xsl:if>
	    </xsl:for-each>
	  </xsl:for-each>
	  <xsl:for-each select="$relation/tei:relation[@name = 'opposition']/tokenize(@active)">
	    <xsl:variable name="relation-party" select="."/>
	    <xsl:for-each select="tokenize($org-refs, ' ')">
	      <xsl:if test="$relation-party = .">Opposition </xsl:if>
	    </xsl:for-each>
	  </xsl:for-each>
	</xsl:variable>
	<xsl:choose>
	  <xsl:when test="contains(normalize-space($in-relation), ' ')">
	    <xsl:message>
	      <xsl:text>ERROR: multiple party statuses for </xsl:text>
	      <xsl:value-of select="$speaker/@xml:id"/>
	      <xsl:text> on </xsl:text>
	      <xsl:value-of select="concat($date-from, ' - ', $date-to, ': ', 
				    normalize-space($in-relation))"/>
	    </xsl:message>
	    <xsl:value-of select="substring-before($in-relation, ' ')"/>
	  </xsl:when>
	  <xsl:when test="normalize-space($in-relation)">
	    <xsl:value-of select="normalize-space($in-relation)"/>
	  </xsl:when>
	  <xsl:otherwise><xsl:text></xsl:text></xsl:otherwise>
	</xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- Output the name of the party (or parties!) the speaker belongs to when speaking -->
  <xsl:function name="et:speaker-party" as="xs:string">
    <xsl:param name="speaker" as="element(tei:person)"/>
    <!-- Output full ('yes') or abbreviated ('abb') name of the party -->
    <xsl:param name="full" as="xs:string"/>
    <!-- Collect all affiliation references where the speaker is a member and are in 
	 the correct time-frame for the speech -->
    <xsl:variable name="refs" select="et:speaker-affiliations-refs($speaker)"/>
    <xsl:variable name="politicalGroups">
      <xsl:for-each select="distinct-values(tokenize($refs, ' '))">
	<xsl:variable name="party" select="key('idr', ., $teiHeader)[@role='politicalGroup']"/>
	<xsl:call-template name="party-name">
	  <xsl:with-param name="party" select="$party"/>
	  <xsl:with-param name="full" select="$full"/>
	</xsl:call-template>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="politicalParties">
      <xsl:for-each select="distinct-values(tokenize($refs, ' '))">
	<xsl:variable name="party" select="key('idr', ., $teiHeader)[@role='politicalParty']"/>
	<xsl:call-template name="party-name">
	  <xsl:with-param name="party" select="$party"/>
	  <xsl:with-param name="full" select="$full"/>
	</xsl:call-template>
      </xsl:for-each>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="normalize-space($politicalGroups)">
	<xsl:value-of select="replace($politicalGroups, ';$', '')"/>
      </xsl:when>
      <xsl:when test="normalize-space($politicalParties)">
	<xsl:value-of select="replace($politicalParties, ';$', '')"/>
      </xsl:when>
      <xsl:otherwise><xsl:text></xsl:text></xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- Output IDREFS to the speaker affiliations in the correct time-frame -->
  <xsl:function name="et:speaker-affiliations-refs" as="xs:string">
    <xsl:param name="speaker" as="element(tei:person)"/>
    <xsl:variable name="refs">
      <xsl:for-each select="$speaker/tei:affiliation
			    [@role='member' or @role='candidateMP' or 
			    @role='president' or @role='vicePresident' or @role='secretary']">
	<xsl:choose>
	  <xsl:when test="@from and @to">
	    <xsl:if test="et:between-dates($date-from, @from, @to) and
			  et:between-dates($date-to, @from, @to)">
	      <xsl:value-of select="@ref"/>
	    </xsl:if>
	  </xsl:when>
	  <xsl:when test="@from">
	    <xsl:if test="et:between-dates($date-from, @from, $today-iso) and
			  et:between-dates($date-to, @from, $today-iso)">
	      <xsl:value-of select="@ref"/>
	    </xsl:if>
	  </xsl:when>
	  <xsl:otherwise>
	      <xsl:value-of select="@ref"/>
	  </xsl:otherwise>
	</xsl:choose>
	<xsl:text>&#32;</xsl:text>
      </xsl:for-each>
    </xsl:variable>
    <!--xsl:if test="contains(normalize-space($tmp), ' ')">
	<xsl:message>
	<xsl:text>WARN: more than one party for </xsl:text>
	<xsl:value-of select="$speaker/@xml:id"/>
	<xsl:text> on </xsl:text>
	<xsl:value-of select="concat($date-from, ' - ', $date-to, ': ', $tmp)"/>
	</xsl:message>
	</xsl:if-->
    <xsl:value-of select="normalize-space($refs)"/>
  </xsl:function>
  
  <!-- Return the name of the party -->
  <xsl:template name="party-name">
    <xsl:param name="party"/>
    <xsl:param name="full"/>
    <xsl:choose>
      <!-- Non-English name first -->
      <xsl:when test="$party/tei:orgName[@full=$full]
		      [ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang != 'en']">
	<xsl:value-of select="$party/tei:orgName[@full=$full]
			      [ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang != 'en']"/>
	<xsl:text>;</xsl:text>
      </xsl:when>
      <!-- then English name -->
      <xsl:when test="$party/tei:orgName[@full=$full]
		      [ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang = 'en']">
	<xsl:value-of select="$party/tei:orgName[@full=$full]
			      [ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang = 'en']"/>
	<xsl:text>;</xsl:text>
      </xsl:when>
      <xsl:when test="normalize-space($party)">
	<xsl:message>
	  <xsl:text>WARN: party without proper name </xsl:text>
	  <xsl:value-of select="$party/@xml:id"/>
	</xsl:message>
	<!-- Shorten the ID if possible -->
	<xsl:value-of select="replace($party/@xml:id, '.+?\.' , '')"/>
	<xsl:text>;</xsl:text>
      </xsl:when>
      <xsl:otherwise><xsl:text></xsl:text></xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
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
  
  <!-- Output $toks as multivalued columns -->
  <xsl:function name="et:join-annotations">
    <xsl:param name="toks"/>
    <xsl:variable name="last" select="count($toks/tei:list)"/>
    <xsl:variable name="result">
      <!-- Counter through items -->
      <xsl:for-each select="$toks/tei:list[1]/tei:item">
	<xsl:variable name="i" select="position()"/>
	<xsl:variable name="feat">
	  <xsl:for-each select="$toks/tei:list/tei:item[position() = $i]">
	    <xsl:value-of select="."/>
	    <xsl:text>|</xsl:text>
	  </xsl:for-each>
	</xsl:variable>
	<!-- Snip off last | and remove duplicates (works only for 2 norm words) -->
	<xsl:value-of select="replace(
			      replace($feat, '\|$', ''),
			      '^(.+?)\|\1$', '$1')
			      "/>
	<xsl:text>&#9;</xsl:text>
      </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="replace($result, '&#9;$', '')"/>
  </xsl:function>
    
  <xsl:function name="et:output-annotations">
    <xsl:param name="token"/>
    <xsl:variable name="n" select="replace($token/@xml:id, '.+\.([^.]+)$', '$1')"/>
    <xsl:variable name="lemma">
      <xsl:choose>
	<xsl:when test="$token/@lemma">
	  <xsl:value-of select="$token/@lemma"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="substring($token,1,1)"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="ud-pos" select="replace(replace($token/@msd, 'UPosTag=', ''), '\|.+', '')"/>
    <xsl:variable name="ud-feats">
      <xsl:variable name="fs" select="replace($token/@msd, 'UPosTag=[^|]+\|?', '')"/>
      <xsl:choose>
	<xsl:when test="normalize-space($fs)">
	  <!-- Change source pipe to whatever we have for multivalued attributes -->
	  <xsl:value-of select="replace($fs, '\|', ' ')"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:text></xsl:text>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:sequence select="concat($lemma, '&#9;', $ud-pos, '&#9;', $ud-feats, '&#9;', $n)"/>
  </xsl:function>

</xsl:stylesheet>
