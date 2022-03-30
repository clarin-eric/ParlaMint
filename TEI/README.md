# ParlaMint TEI

This directory contains the XML TEI ODD for the ParlaMint corpora and the derived XML schema in
RelaxNG, along with scripts for conversion and validation of the Parla-CLARIN TEI ODD schema and
supporting documents.

The ParlaMint ODD is split into two files:

* [ParlaMint.odd.xml](https://github.com/clarin-eric/ParlaMint/blob/main/TEI/ParlaMint.odd.xml)
  which contains the prose guidelines on the the structure and encoding of ParlaMint corpora. these
  are, with the TEI Stylesheets converted to HTML and available from the [ParlaMint GitHub
  pages](https://clarin-eric.github.io/ParlaMint/). This file XIncludes:

* [ParlaMint-schemaSpecs.odd.xml](https://github.com/clarin-eric/ParlaMint/blob/main/TEI/ParlaMint-schemaSpecs.odd.xml)
  which contains the formal ODD schema specifications for ParlaMint. It is, however, difficult to
  create an ODD schema that is as strict as needed for ParlaMint corpora. So, for actual
  validations, the specialised RelaxNG schemas developed for ParlaMint and available in the [Schema/
  directory](https://github.com/clarin-eric/ParlaMint/tree/main/Schema) should be used.

Note that in order to convert the ODD into HTML or RelaxNG, this directory should include the TEI
Stylesheets, which are, however .gitgnored. So, before using the conversions, the
[TEI Stylesheets](https://github.com/TEIC/Stylesheets) should be cloned into this directory.
