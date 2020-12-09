# ParlaMint validation schemas

The Parlamint XML schemas are meant for strict validation of the ParlaMint corpora, which
exist in two versions, the "plain text" one, and the linguistically annotated one. As the
corpora are typically too large to validate as a complete documument, the schemas are
divided into those for validating the corpus component files, with the TEI element as the
root, and the corpus root file, with the teiCorpus element as the root, and which then
XIncludes the corpus component files.

This gives four schemas for validation, however, note that the schemas import definitions
from each other, so they should be copied together. The schemas are the following:

* ParlaMint-TEI.rng: schema for validation of "plain text" corpus component files; also the
  schema that contains the common definitions
* ParlaMint-teiCorpus.rng: schema for validation of "plain text" corpus root file; it uses
  the definitions in ParlaMint-TEI.rng
* ParlaMint-TEI.ana.rng: schema for validation of linguistically annotated corpus component
  files; it uses the definitions in ParlaMint-TEI.rng
* ParlaMint-teiCorpus.ana.rng: schema for validation of linguistically annotated corpus root
  files it uses the definitions in ParlaMint-teiCorpus.rng

So, for the ParlaMint corpus of country XX using standard ParlaMint names for directories and
files, a validation run under Unix using jing installed at /usr/local/bin/ would be:

```
$ java -jar /usr/local/bin/jing.jar ParlaMint-teiCorpus.rng     ParlaMint-XX/ParlaMint-XX.xml
$ java -jar /usr/local/bin/jing.jar ParlaMint-TEI.rng           ParlaMint-XX/ParlaMint-XX_*.xml
$ java -jar /usr/local/bin/jing.jar ParlaMint-teiCorpus.ana.rng ParlaMint-XX.ana/ParlaMint-XX.ana.xml
$ java -jar /usr/local/bin/jing.jar ParlaMint-TEI.ana.rng       ParlaMint-XX.ana/ParlaMint-XX_*ana.xml
```

The schemas have also been converted with `trang` into other XML schema languages, i.e.
* .rnc (RelaxNG compact syntax)
* .xsd (W3C schema language)
