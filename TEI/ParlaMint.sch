<?xml version="1.0" encoding="utf-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
   <title>ISO Schematron rules</title>
   <!-- This file generated 2022-02-09T15:06:49Z by 'extract-isosch.xsl'. -->
   <!-- ********************* -->
   <!-- namespaces, declared: -->
   <!-- ********************* -->
   <!-- ********************* -->
   <!-- namespaces, implicit: -->
   <!-- ********************* -->
   <ns prefix="tei" uri="http://www.tei-c.org/ns/1.0"/>
   <!-- ************ -->
   <!-- constraints: -->
   <!-- ************ -->
   <pattern id="schematron-constraint-tei_clarin-div-divtype-1">
      <rule context="tei:div[@type = $div.types.debate]">
         <assert test="not(parent::tei:div[@type = $div.types.debate])">
                           A text division of type <value-of select="@type"/> should not occur inside div with type value <value-of select="parent::tei:div/@type"/>.
                        </assert>
      </rule>
   </pattern>
   <pattern>
      <let name="div.types.debate"
           value="('address', 'adjournment', 'administrationOfOath', 'communication', 'declarationOfVote', 'ministerialStatements', 'nationalInterest', 'noticesOfMotion', 'oralStatements', 'papers', 'petitions', 'prayers', 'proceduralMotions', 'pointOfOrder', 'personalStatements', 'questions', 'resolutions', 'rollCall', 'writtenStatements')"/>
   </pattern>
</schema>
