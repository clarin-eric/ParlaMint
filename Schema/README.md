# ParlaMint RelaxNG XML schemas

The Parlamint XML schemas are written directly in RelaxNG.  They specialise even further the
[ParlaMint TEI ODD schema](../TEI) to be able to better validate the ParlaMint corpora.

Each ParlaMint corpus is assumed to be marked by the country or region code and consist of:
* The root file, a teiCorpus rooted XML document, that consists of its teiHeader giving
significant metadata about the corpus and speakers, and XIncludes the component files;
possibly, some larger or common parts of the teiHeader are also stored separately (in
particular the taxonomies, list of organisations and of persons), and are XIncluded from
the corpus root. 
* TEI rooted component files, each with its teiHeader giving the date or dates, and possibly other
characterisics of the contained proceedings (e.g. house, sitting) and the actual transcript, annotated by
utterances and speaker IDs.

As the corpora are typically too large to validate and process with XSLT as complete documuments
(so, with XInclude), the RelaxNG schemas are separated into those for validating the TEI component
files, the teiCorpus root file, and the separated components of the corpus root teiHeader.

Each corpus also exists in the ".ana" version, which adds linguistic annotations.

This gives the following RelaxNG schemas for validation, however, note that the schemas import
definitions from each other, so they should be copied together. The schemas are the following:

* [ParlaMint-TEI.rng](ParlaMint-TEI.rng): for "plain text" corpus component files
* [ParlaMint-teiCorpus.rng](ParlaMint-teiCorpus.rng): for "plain text" corpus root file
* [ParlaMint-TEI.ana.rng](ParlaMint-TEI.ana.rng): for linguistically annotated corpus component files
* [ParlaMint-teiCorpus.ana.rng](ParlaMint-teiCorpus.ana.rng): for annotated corpus root file
* [ParlaMint-listPerson.rng](ParlaMint-listPerson.rng): for separately stored person list
* [ParlaMint-listOrg.rng](ParlaMint-listOrg.rng): for separately stored organisation list
* [ParlaMint-taxonomy.rng](ParlaMint-taxonomy.rng): for separately stored taxonomies
* [ParlaMint.rng](ParlaMint.rng): not meant to be used for validation, as it is a library of
definitions imported into other schemas.

So, for the ParlaMint corpus of country XX in the directory ParlaMint-XX/ and using standard
ParlaMint file names, validation using `jing` installed in `/usr/share/java/` would be:

```
$ java -jar /usr/share/java/jing.jar ParlaMint-teiCorpus.rng     ParlaMint-XX/ParlaMint-XX.xml
$ java -jar /usr/share/java/jing.jar ParlaMint-TEI.rng           ParlaMint-XX/ParlaMint-XX_*.xml
$ java -jar /usr/share/java/jing.jar ParlaMint-teiCorpus.ana.rng ParlaMint-XX/ParlaMint-XX.ana.xml
$ java -jar /usr/share/java/jing.jar ParlaMint-TEI.ana.rng       ParlaMint-XX/ParlaMint-XX_*.ana.xml
$ java -jar /usr/share/java/jing.jar ParlaMint-listPerson.rng    ParlaMint-XX/ParlaMint-XX-listPerson.xml
$ java -jar /usr/share/java/jing.jar ParlaMint-listOrg.rng       ParlaMint-XX/ParlaMint-XX-listOrg.xml
$ java -jar /usr/share/java/jing.jar ParlaMint-taxonomy.rng      ParlaMint-XX/ParlaMint-XX-taxonomy-*.xml
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

## Validation with XSLT and with make

RelaxNG schemas constrain the XML structure of the corpus but they do not check ID references or
content validity. This type of validation is performed by XSLT scripts in the [Scripts](../Scripts)
directory and should be performed (as, indeed should the XML schema validation itself) via the
`Makefile` in the main directory of this Git repository. Pls. see
[CONTRIBUTING.md](../CONTRIBUTING.md) for more information.
