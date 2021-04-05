# ParlaMint validation schemas

The Parlamint XML schemas are currently written directly in RelaxNG.
They specialise the very general
[Parla-CLARIN](https://github.com/clarin-eric/ParlaMint) TEI schemas
for Parliamentary corpora so that they become much more interoperable.

Each ParlaMint corpus is assumed to be marked by the country code and consist of the
* root file, a teiCorpus rooted XML document, that consists of its teiHeader giving
significant metadata about the corpus and speakers, and XIncludes the component files; 
* TEI rooted component files, each with its teiHeader giving the date or dates, and possibly other
characterisics of the contained proceedings (e.g. house, sitting) and the actual transcript, annotated by
utterances and speaker IDs.

As the corpora can be too large to validate and process with XSLT as
complete documuments (so, with XInclude), the RelaxNG schemas are
separated into those for validating the TEI component files and the
teiCorpus root file.

Each corpus also exists in the ".ana" version, which adds linguistic
annotations.

This gives four schemas for validation, however, note that the schemas
import definitions from each other, so they should be copied
together. The schemas are the following:

* [ParlaMint-TEI.rng](ParlaMint-TEI.rng): validation of "plain text" corpus component files
* [ParlaMint-teiCorpus.rng](ParlaMint-teiCorpus.rng): "plain text" root files; imports ParlaMint-TEI.rng
* [ParlaMint-TEI.ana.rng](ParlaMint-TEI.ana.rng): linguistically annotated component
  files; imports ParlaMint-TEI.rng
* [ParlaMint-teiCorpus.ana.rng](ParlaMint-teiCorpus.ana.rng): annotated root
  files; imports ParlaMint-teiCorpus.rng

So, for the ParlaMint corpus of country XX using standard ParlaMint names for directories and
files, validation using `jing` installed at `/usr/share/java/` would be:

```
$ java -jar /usr/share/java/jing.jar ParlaMint-teiCorpus.rng     ParlaMint-XX/ParlaMint-XX.xml
$ java -jar /usr/share/java/jing.jar ParlaMint-TEI.rng           ParlaMint-XX/ParlaMint-XX_*.xml
$ java -jar /usr/share/java/jing.jar ParlaMint-teiCorpus.ana.rng ParlaMint-XX.ana/ParlaMint-XX.ana.xml
$ java -jar /usr/share/java/jing.jar ParlaMint-TEI.ana.rng       ParlaMint-XX.ana/ParlaMint-XX_*ana.xml
```

Note that - probably depending on Java version used - some implementations will
automatically do XInclude processing on the root files (i.e. ParlaMint-XX/ParlaMint-XX.xml
and ParlaMint-XX.ana/ParlaMint-XX.ana.xml), thus defeating the purpose of per-file
validation: the document becomes very large, and the files also won't validate because the
ParlaMint-teiCorpus schemas don't include elements from the component files. To explicitly
disable XInclude validation, you might use:

```
java -Dorg.apache.xerces.xni.parser.XMLParserConfiguration=org.apache.xerces.parsers.StandardParserConfiguration -jar /usr/share/java/jing.jar ...
```
Note also that more info about the technical aspects of the validation is available in the
[Parla-CLARIN Wiki](https://github.com/clarin-eric/parla-clarin/wiki/Validating-your-data).

The schemas have also been converted with `trang` into other XML schema languages, i.e.
* .rnc, i.e. RelaxNG compact syntax
* .xsd, i.e. W3C schema language (but note that not all restrictions of the original
  RelaxNG schema can be modelled in XSD)

## Validation with XSLT

RelaxNG schemas constrain the XML structure of the corpus, but they do not check the ID
references or more content harmonisation, e.g. that each root should have the main title
in English as e.g.  "Belgian parliamentary corpus ParlaMint-BE [ParlaMint]", or that it
isn't allowed to have leading or trailing whitespace, esp. in the metadata. Some of
these are checked by XSLT scripts in the [Scripts](../Scripts) directory.
