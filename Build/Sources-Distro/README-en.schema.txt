                        Comparable parliamentary corpora
                               ParlaMint ZZ
      Parla-CLARIN and ParlaMint schemas with conversion scripts
                         
         Citation, documentation, download, and licence available from
                       YY

This directory contains:

1. The Parla-CLARIN schema and documentation, archived from
   https://github.com/clarin-eric/parla-clarin. This schema was used
   as the overall frame in which the ParlaMint corpora were encoded,
   and is, in this context, useful mostly for its documentation that
   can be found in the Parla-CLARIN/docs directory.

2. The ParlaMint schemas, which were made just for ParlaMint corpora
   and attempt to maximally constrain the encoding to be exactly that
   as used by the ParlaMint. More about these below.
   
3. Some XSLT scripts in directory bin/ that can be used to convert
   ParlaMint TEI encoded files into other formats, such as plain text,
   CoNLL-U and vertical files.

ParlaMint schemas

The ParlaMint schemas are available in RelaxNG XML format (.rng),
RelaxNG compact format (.rnc) and in the W3C Schema language
(.xsd). As ParlaMint corpora are too large to be validated as one
document, and, furthermore, exist in two versions (the "plain text"
one, and the linguistically annotated one) there are four schemas for
validation:
   
- ParlaMint-TEI, used to validate component (TEI rooted) files of a
  ParlaMint corpus. This schema also contains most of the definitions
  that are imported by the other schemas.

- ParlaMint-teiCorpus, used to validate the top-level (teiCorpus
  rooted) file of a ParlaMint corpus. The file should contain
  XIncludes of the corpus components.
     
- ParlaMint-TEI.ana, used to validate component (TEI rooted) files of
  the linguistically annotated version of a ParlaMint corpus.

- ParlaMint-teiCorpus.ana, used to validate the top-level (teiCorpus
  rooted) file of the linguistically annotated version of a ParlaMint
  corpus.

For validating the ParlaMint corpus of country XX using standard
ParlaMint names for directories and files, a validation run under Unix
using jing installed at /usr/share/java/ would be:

$ java -jar /usr/share/java/jing.jar ParlaMint-teiCorpus.rng     ParlaMint-XX/ParlaMint-XX.xml
$ java -jar /usr/share/java/jing.jar ParlaMint-TEI.rng           ParlaMint-XX/ParlaMint-XX_*.xml
$ java -jar /usr/share/java/jing.jar ParlaMint-teiCorpus.ana.rng ParlaMint-XX.ana/ParlaMint-XX.ana.xml
$ java -jar /usr/share/java/jing.jar ParlaMint-TEI.ana.rng       ParlaMint-XX.ana/ParlaMint-XX_*ana.xml
