# ParlaMint: Comparable Parliamentary Corpora

The [CLARIN ParlaMint
project](https://www.clarin.eu/content/parlamint-towards-comparable-parliamentary-corpora)
aims to create linguistically annotated comparable parliamentary
corpora for a number of countries/languages. The corpora are to be
encoded to a common schema, which is a specialisation of the
[Parla-CLARIN
recommendations](https://clarin-eric.github.io/parla-clarin/).

This project is meant for hosting the schema and samples of the developing ParlaMint corpora, in
order to perform validation of the encoding, and to have a forum for reporting problems via
GitHub issues.

Each country has a dedicated directory for its samples, which should ultimately contain at least
four files:

* ParlaMint-XX.xml: Corpus root file for the "plain text" sample, which XIncludes its component
  file(s)

* ParlaMint-XX_zzz.xml: at least one "plain text" sample corpus component file

* ParlaMint-XX.ana.xml: Corpus root file for the linguistically annotated sample, which
  XIncludes the component file(s)

* ParlaMint-XX_zzz.ana.xml: at least one linguistically annotated sample corpus component file

As examples pls. see the files for version 1 of the corpus, i.e. the BG, HR, PL, SI directories.

The [Schema](Schema/) folder contains the schemas for validating the
four types of files present in the corpora. The README in this
directory provides more information.

The [Scripts](Scripts/) folder contains some possibly useful XSLT scripts.
