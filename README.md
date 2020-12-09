# ParlaMint: Comparable Parliamentary Corpora

The [ParlaMint](https://www.clarin.eu/content/parlamint-towards-comparable-parliamentary-corpora)
CLARIN-supported project aims to create linguistically annotated comparable parliamentary
corpora for a number of countries/languages. The corpora are to be encoded to a common
schema, which is a specialisation of the [Parla-CLARIN
recommendations](https://clarin-eric.github.io/parla-clarin/).

This project is meant for samples of the developing ParlaMint corpora, in order to perform
validation of the encoding, and to have a forum for reporting problems via GitHub issues.

Each country has a dedicated directory for its samples, which should ultimately contain 8 files:
* ParlaMint-XX.xml: Corpus root file for the "plain text" sample,
  which XIncludes 3 component files
* ParlaMint-XX_zzz.xml: 3 "plain text" corpus component files
* ParlaMint-XX.ana.xml: Corpus root file for the linguistically
  annotated sample, which XIncludes 3 component files
* ParlaMint-XX_zzz.ana.xml: 3 linguistically annotated corpus component
  files

Pls. see the files for the V1 of the corpus, i.e. BG, HR, PL, SI
directories.

The [Schema](Schema/) folder contains the schemas for validating the
four types of files present in the corpora. The README in this
directory provides more information.

The [Scripts](Scripts/) folder contains some possibly useful XSLT scripts.
