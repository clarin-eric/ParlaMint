<?xml version="1.0"?>
<!-- Convert relevant parts of a notes file to XML -->
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
  
  <xsl:param name="notesFile"/>
  <xsl:param name="target-lang">en</xsl:param>
  
  <xsl:output method="xml" indent="yes"/>
  <xsl:key name="n" use="@n" match="tei:item"/>

  <xsl:variable name="notes">
    <xsl:variable name="data" select="unparsed-text($notesFile, 'UTF-8')"/>
    <!--xsl:message terminate="yes" select="concat('FATAL ERROR: note file ', $notesFile, ' has ', $data)"/-->
    <!--xsl:if test="not(doc-available($notesFile))">
      <xsl:message terminate="yes" select="concat('FATAL ERROR: note file ', $notesFile, ' not found!')"/>
    </xsl:if-->
    <list xmlns="http://www.tei-c.org/ns/1.0">
      <xsl:for-each select="tokenize($data, '\n')">
        <xsl:variable name="line" select="."/>
        <xsl:analyze-string select="$line"
                            regex="^(.*)&#9;(.*)&#9;(.*)&#9;(.*)&#9;(.*)&#9;(.*)&#9;(.*)$">
          <xsl:matching-substring>
            <!--xsl:variable name="orig"  select="et:prep(regex-group(3))"/-->
            <xsl:variable name="orig"  select="regex-group(3)"/>
            <!--xsl:variable name="trans" select="et:prep(regex-group(6))"/-->
            <xsl:variable name="trans" select="regex-group(6)"/>
	    <xsl:if test="$orig != 'content'"> <!-- Skip header row -->
	      <item n="{replace(mk:normalize-note($orig), '\s', '')}">
		<xsl:value-of select="mk:normalize-note(et:fix($orig, $trans))"/>
	      </item>
	    </xsl:if>
	  </xsl:matching-substring>
	</xsl:analyze-string>
      </xsl:for-each>
    </list>
  </xsl:variable>

  <!-- Discard possible description in native language if an English one is already available -->
  <xsl:template match="tei:body//tei:*[tei:desc[@xml:lang='en']]">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:copy-of select="tei:desc[@xml:lang = 'en']"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tei:body//tei:note | tei:body//tei:desc">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:variable name="id" select="ancestor-or-self::tei:*[@xml:id][1]/@xml:id"/>
      <xsl:variable name="orig" select="normalize-space(.)"/>
      <xsl:variable name="trans" select="key('n', replace(mk:normalize-note($orig), '\s', ''), $notes)[1]"/>
      <xsl:choose>
	<xsl:when test="normalize-space($trans)">
	  <xsl:attribute name="xml:lang" select="$target-lang"/>
	  <xsl:value-of select="$trans"/>
	</xsl:when>
	<xsl:when test="not(normalize-space($orig))">
	  <xsl:message select="concat('WARN: Empty comment in ', $id)"/>
	</xsl:when>
	<xsl:when test="contains($orig, 'Sentence could not be parsed: ')">
	  <xsl:message select="concat('WARN: In ', $id, ' no translation for unparsed comment ', $orig)"/>
	  <xsl:attribute name="xml:lang" select="ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang"/>
	  <xsl:value-of select="$orig"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:message select="concat('ERROR: In ', $id, ' no translation for comment ', $orig)"/>
	  <xsl:value-of select="concat('???', $orig, '???')"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="text()">
    <xsl:value-of select="."/>
  </xsl:template>
  <xsl:template match="@*">
    <xsl:copy/>
  </xsl:template>
  <xsl:template match="tei:*">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <!-- Copy over original if translation is obvious nonsense or shorten it if longer (by factor $factor) than the original
       as this is usually a bug in the translation -->
  <xsl:function name="et:fix">
    <xsl:param name="str1"/>
    <xsl:param name="str2"/>
    <xsl:variable name="factor">3</xsl:variable>
    <xsl:choose>
      <!-- If original note just digits, punctuation and spaces but translated isn't, then just copy over original -->
      <!-- For cases such as "17:04:02" -> "♪ It's all right, it's all right, it's all right" -->
      <xsl:when test="matches($str1, '^[\p{N}\p{P}\p{Zs}]+$') and not(matches($str2, '^[\p{N}\p{P}\p{Zs}]+$'))">
	<xsl:value-of select="$str1"/>
      </xsl:when>
      <!-- If translated note is much longer than original, cut translation -->
      <xsl:when test="string-length($str2) &gt; ($factor * string-length($str1))">
	<!-- Remove the message as the resulting long is huge and it also slows down processing -->
	<!--xsl:message select="concat('WARN: Shortening too long translation ', $str2)"/-->
	<xsl:value-of select="replace(substring($str2, 1, ($factor * string-length($str1))),
			      '(.+) .+', '$1 ……')"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$str2"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- Old function to prepare the notes by de-escaping quotes -->
  <!-- No longer needed, in fact, it now causes bugs -->
  <xsl:function name="et:prep">
    <xsl:param name="str"/>
    <xsl:value-of select="replace(
			  replace(
			  replace($str, 
			  '^&quot;', ''),
			  '&quot;$', ''),
			  '&quot;&quot;', '&quot;')
			  "/>
  </xsl:function>
  
</xsl:stylesheet>
