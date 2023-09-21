<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="tei xs" >
  <xsl:param name="outDir"/>
  <xsl:param name="prefix"/>
  <xsl:param name="skip"/>
  <xsl:param name="noAna"/>
  <xsl:param name="teiRoot"/>

  <xsl:output method="xml" indent="yes" encoding="UTF-8" />
  <xsl:preserve-space elements="catDesc seg"/>

  <!--xsl:import href="parlamint-lib.xsl"/-->

  <xsl:param name="taxonomies">NER UD-SYN parla.legislature speaker_types subcorpus politicalOrientation CHES</xsl:param>
  
  <xsl:variable name="pref">
    <xsl:choose>
      <xsl:when test="$prefix"><xsl:value-of select="$prefix"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="concat(replace(/tei:teiCorpus/@xml:id,'\.ana$',''),'-')"/></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="outRoot">
    <xsl:value-of select="$outDir"/>
    <xsl:text>/</xsl:text>
    <xsl:value-of select="replace(base-uri(), '.*/(.+)$', '$1')"/>
  </xsl:variable>

  <xsl:variable name="seenInTeiRoot">
    <xsl:if test="$teiRoot">
      <xsl:variable name="teiRootDoc" select="document($teiRoot)"/>
      <xsl:value-of select="concat(
                              string-join($teiRootDoc//tei:classDecl/xi:include/@href,' '),
                              ' ',
                              string-join($teiRootDoc//tei:classDecl/tei:taxonomy/@xml:id/concat(.,'.xml'),' '),
                              ' ',
                              string-join($teiRootDoc//tei:particDesc/xi:include/@href,' '),
                              ' ',
                              string-join($teiRootDoc//tei:particDesc/tei:*/@xml:id/concat(.,'.xml'),' '),
                              ' ')"/>
    </xsl:if>
  </xsl:variable>

  <xsl:variable name="inDir" select="replace(base-uri(), '(.*)/.*', '$1')"/>

  <xsl:template match="/">
    <xsl:message select="concat('INFO: Starting to process ', tei:teiCorpus/@xml:id)"/>
    <!-- Output Root file -->
    <xsl:message>INFO: processing root </xsl:message>
    <xsl:result-document href="{$outRoot}">
      <xsl:apply-templates/>
    </xsl:result-document>
  </xsl:template>

  <xsl:template match="tei:listPerson | tei:listOrg | tei:taxonomy">
    <xsl:variable name="is_common"
                  select=".[@xml:id and (
			  index-of(tokenize($taxonomies, '\s+'), @xml:id) or
                          index-of(tokenize($taxonomies, '\s+'), replace(@xml:id,'^.*taxonomy-(.+)(.ana)?','$1'))
                          )]"/>
    <xsl:variable name="no_id_change"
                  select=".[starts-with(@xml:id,'ParlaMint-')
                            and
                            contains(@xml:id,concat('-',local-name()))
                            ]"/>
    <xsl:variable name="fileid">
      <xsl:choose>
        <xsl:when test="$no_id_change">
          <xsl:value-of select="@xml:id" />
        </xsl:when>
        <xsl:when test="$is_common">
          <xsl:value-of select="concat('ParlaMint-',local-name(),@xml:id/concat('-',.))" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat($pref,local-name(),@xml:id/concat('-',.))" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="interfix">
      <xsl:if test="ends-with(base-uri(),'.ana.xml')
                   and not(contains($skip,concat($fileid,'.xml')))
                   and not(contains(concat($noAna,' ',replace($noAna,'ParlaMint-',$pref)),concat($fileid,'.xml')))
                   and not(contains($seenInTeiRoot,replace(concat($fileid,'.xml '),'^.*taxonomy-','' )))
                   and not($no_id_change)">.ana</xsl:if>
    </xsl:variable>

    <xsl:variable name="filename" select="concat($fileid,$interfix,'.xml')"/>
    <xsl:choose>
      <xsl:when test="contains($skip,concat($fileid,'.xml'))">
        <xsl:message select="concat('INFO: Skipping - file should exist: ',$fileid,'.xml')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="path" select="concat($outDir,'/',$filename)"/>
        <xsl:message select="concat('INFO: Saving ',local-name(), ' to ',$path)"/>
        <xsl:result-document href="{$path}" method="xml">
          <xsl:element name="{name()}">
            <xsl:if test="not(@xml:id = concat($fileid,$interfix))">
              <xsl:message select="concat('INFO: replacing xml:id &#34;',
				   @xml:id,'&#34; with ',concat($fileid,$interfix))"/>
            </xsl:if>
            <xsl:attribute name="xml:id" select="concat($fileid,$interfix)"/>
            <xsl:attribute name="xml:lang">
              <xsl:choose>
                <xsl:when test="$is_common">mul</xsl:when>
                <xsl:otherwise><xsl:value-of select="ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang"/></xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
            <xsl:copy-of select="./*" copy-namespaces="no"/>
          </xsl:element>
        </xsl:result-document>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:element name="xi:include" namespace="http://www.w3.org/2001/XInclude">
      <xsl:namespace name="xi" select="'http://www.w3.org/2001/XInclude'"/>
      <xsl:attribute name="href">
        <xsl:value-of select="$filename"/>
      </xsl:attribute>
    </xsl:element>
  </xsl:template>

  <xsl:template match="tei:classDecl/xi:include | tei:particDesc/xi:include">
    <xsl:variable name="pathIn" select="concat($inDir,'/',@href)"/>
    <xsl:variable name="pathOut" select="concat($outDir,'/',@href)"/>
    <xsl:message select="concat('INFO: Copying ',@href)"/>
    <xsl:result-document href="{$pathOut}" method="xml">
      <xsl:copy-of select="document($pathIn)"/>
    </xsl:result-document>
    <xsl:element name="xi:include" namespace="http://www.w3.org/2001/XInclude">
      <xsl:namespace name="xi" select="'http://www.w3.org/2001/XInclude'"/>
      <xsl:attribute name="href">
        <xsl:value-of select="./@href"/>
      </xsl:attribute>
    </xsl:element>
  </xsl:template>


  <xsl:template match="@scheme[. = '#parla.legislature']">
    <xsl:attribute name="scheme">#ParlaMint-taxonomy-parla.legislature</xsl:attribute>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
