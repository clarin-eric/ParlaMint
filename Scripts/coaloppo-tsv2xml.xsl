<?xml version="1.0"?>
<!-- Convert TSV of coalition/opposition info into <affiliation> elements for the ParlaMint corpora -->
<!-- Checks the validity of the data agains the ParlaMint corpora -->
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
  <xsl:param name="sheet"/>
  <xsl:output method="xml" indent="yes"/>
  
  <!-- Transform TSV into a XML variable -->
  <xsl:variable name="input">
    <xsl:variable name="data" select="unparsed-text($sheet,'UTF-8')"/>
    <list>
      <xsl:for-each select="tokenize($data, '\n')">
	<xsl:variable name="line" select="."/>
	<xsl:if test="not(starts-with($line, 'country'))">
	  <xsl:analyze-string select="$line"
			      regex="^(.*)&#9;(.*)&#9;(.*)&#9;(.*)&#9;(.*)$">
	    <xsl:matching-substring>
	      <xsl:variable name="country" select="normalize-space(regex-group(1))"/>
	      <xsl:variable name="role" select="normalize-space(regex-group(2))"/>
	      <xsl:variable name="from" select="replace(
						replace(
						normalize-space(regex-group(3)),
						'-(\d)-', '-0$1-'),
						'-(\d)$', '-0$1')"/>
	      <xsl:variable name="to" select="replace(
					      replace(
					      normalize-space(regex-group(4)),
					      '-(\d)-', '-0$1-'),
					      '-(\d)$', '-0$1')"/>
	      <xsl:variable name="parties" select="normalize-space(regex-group(5))"/>
	      <xsl:choose>
		<xsl:when test="not(matches($country, '^[A-Z][A-Z]$'))">
		  <xsl:message select="concat('ERROR: bad country ', $country)"/>
		</xsl:when>
		<xsl:when test="$from and $from != '-' and not(matches($from, '\d\d\d\d-\d\d-\d\d'))">
		  <xsl:message select="concat('ERROR ', $country, ': from = ', $from)"/>
		</xsl:when>
		<xsl:when test="$to and $to != '-' and not(matches($to, '\d\d\d\d-\d\d-\d\d'))">
		  <xsl:message select="concat('ERROR ' , $country, ': to = ', $to)"/>
		</xsl:when>
		<xsl:when test="$role != 'coalition' and $role != 'opposition'">
		  <xsl:message select="concat('WARN ', $country, ': role = ', $role, ', skipping!')"/>
		</xsl:when>
		<xsl:otherwise>
		  <item>
		    <country>
		      <xsl:value-of select="$country"/>
		    </country>
		    <name>
		      <xsl:if test="$role != 'coalition' and $role != 'opposition'">
			<xsl:message select="concat('WARN ', $country, ': role = ', $role, ' hmmm')"/>
		      </xsl:if>
		      <xsl:value-of select="$role"/>
		    </name>
		    <from>
		      <xsl:if test="$from != '' and $from != '-'">
			<xsl:value-of select="$from"/>
		      </xsl:if>
		    </from>
		    <to>
		      <xsl:if test="$to != '' and $to != '-'">
			<xsl:value-of select="$to"/>
		      </xsl:if>
		    </to>
		    <xsl:for-each select="tokenize($parties, ' ')">
		      <party>
			<xsl:value-of select="."/>
		      </party>
		    </xsl:for-each>
		  </item>
		</xsl:otherwise>
	      </xsl:choose>
	    </xsl:matching-substring>
	    <xsl:non-matching-substring>
	      <xsl:message select="concat('ERROR: bad line ', $line)"/>
	    </xsl:non-matching-substring>
	  </xsl:analyze-string>
	</xsl:if>
      </xsl:for-each>
    </list>
  </xsl:variable>

  <!-- Gather listOrgs from all corpus roots -->
  <xsl:variable name="listOrgs">
    <xsl:variable name="path" select="replace(base-uri(), '/[^/]+$', '/')"/>
    <list>
      <xsl:for-each select="//xi:include">
	<xsl:variable name="country" select="replace(@href, 'ParlaMint-([A-Z]{2}(-[A-Z0-9]{1,3})?)(-[a-z]{2,3})?\.xml', '$1')"/>
	<xsl:variable name="listOrg" select="document(concat($path, @href))//tei:listOrg"/>
	<item>
	  <country>
	    <xsl:value-of select="$country"/>
	  </country>
	  <xsl:copy-of select="$listOrg/tei:org"/>
	</item>
      </xsl:for-each>
    </list>
  </xsl:variable>
  
  <xsl:template match="/">
    <xsl:variable name="relations">
      <xsl:for-each select="$input//tei:item">
	<xsl:sort select="tei:country"/>
	<xsl:variable name="item" select="."/>
	<relation n="{tei:country}" name="{tei:name}">
	  <xsl:variable name="parties">
	    <xsl:for-each select="tei:party">
	      <xsl:choose>
		<xsl:when test="key('id', ., $listOrgs)">
		  <xsl:value-of select="concat('#', ., ' ')"/>
		</xsl:when>
		<xsl:otherwise>
		  <xsl:message select="concat('ERROR ', $item/tei:country, ': ',
				       $item/tei:name, ' party = ', ., ' between ', 
				       $item/tei:from, ' - ', $item/tei:to)"/>
		</xsl:otherwise>
	      </xsl:choose>
	    </xsl:for-each>
	  </xsl:variable>
	  <xsl:choose>
	    <xsl:when test="tei:name = 'coalition'">
	      <xsl:attribute name="mutual" select="normalize-space($parties)"/>
	    </xsl:when>
	    <xsl:when test="tei:name = 'opposition'">
	      <xsl:attribute name="active" select="normalize-space($parties)"/>
	      <xsl:attribute name="passive">
		<xsl:variable name="government"
			      select="$listOrgs//tei:item[tei:country = $item/tei:country]/
				      tei:org[@role = 'government']/@xml:id"/>
		<xsl:choose>
		  <xsl:when test="$government != ''">
		    <xsl:value-of select="concat('#', $government)"/>
		  </xsl:when>
		  <xsl:otherwise>
		    <xsl:variable name="gov-ref" select="concat('government.', $item/tei:country)"/>
		    <xsl:message select="concat('WARN: adding fake government ', $gov-ref, 
					 ' ref for ', $item/tei:country, ' opposition')"/>
		    <xsl:value-of select="concat('#', $gov-ref)"/>
		  </xsl:otherwise>
		</xsl:choose>
	      </xsl:attribute>
	    </xsl:when>
	  </xsl:choose>
	  <xsl:if test="normalize-space(tei:from)">
	    <xsl:attribute name="from" select="tei:from"/>
	  </xsl:if>
	  <xsl:if test="normalize-space(tei:to)">
	    <xsl:attribute name="to" select="tei:to"/>
	  </xsl:if>
	  <!-- Add term when coalition/opposition active -->
	  <xsl:variable name="term">
	    <xsl:variable name="terms" select="$listOrgs//tei:item[tei:country = $item/tei:country]/
					       tei:org[@role = 'parliament']/tei:listEvent"/>
	    <xsl:for-each select="$terms/tei:event">
	      <xsl:if test="et:between-dates($item/tei:from, @from, @to) and 
			    et:between-dates($item/tei:to, @from, @to)">
		<xsl:value-of select="concat('#', @xml:id, ' ')"/>
	      </xsl:if>
	    </xsl:for-each>
	  </xsl:variable>
	  <xsl:if test="normalize-space($term)">
	    <xsl:attribute name="ana" select="normalize-space($term)"/>
	  </xsl:if>
	</relation>
      </xsl:for-each>
    </xsl:variable>
    <listRelation>
      <xsl:for-each-group select="$relations/tei:relation" group-by="@n">
	<listRelation n="{current-grouping-key()}">
	  <xsl:for-each select="current-group()">
	    <xsl:copy>
	      <xsl:copy-of select="@*[name() != 'n']"/>
	    </xsl:copy>
	  </xsl:for-each>
	</listRelation>
      </xsl:for-each-group>
    </listRelation>
  </xsl:template>
  
  <!-- Is the first date between the following two? -->
  <xsl:function name="et:between-dates" as="xs:boolean">
    <xsl:param name="date" as="xs:string?"/>
    <xsl:param name="from" as="xs:string?"/>
    <xsl:param name="to" as="xs:string?"/>
    <xsl:choose>
      <xsl:when test="not(normalize-space($date))">
	<xsl:value-of select="true()"/>
      </xsl:when>
      <xsl:when test="not(normalize-space($from) or normalize-space($to))">
	<xsl:value-of select="true()"/>
      </xsl:when>
      <xsl:when test="not(normalize-space($from)) and xs:date($date) &lt;= xs:date($to)">
	<xsl:value-of select="true()"/>
      </xsl:when>
      <xsl:when test="not(normalize-space($to)) and xs:date($date) &gt;= xs:date($from)">
	<xsl:value-of select="true()"/>
      </xsl:when>
      <xsl:when test="xs:date($date) &gt;= xs:date($from) and xs:date($date) &lt;= xs:date($to)">
	<xsl:value-of select="true()"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="false()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
</xsl:stylesheet>
