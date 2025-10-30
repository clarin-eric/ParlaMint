# ParlaMint Build directory

This directory contains the build environemnt for a release, i.e. the input data sources, the output
distribution-ready corpora, and the dedicated scripts.

Note that the complete corpora are to large to be stored on GitHub, so most of the data files are gitignored.

Here you can find the following directories:

* [Sources-Orig/](Sources-Orig/): source ParlaMint TEI encoded corpora with missing metadata,
  which is taken from TSV files in [Sources-TSV/](Sources-TSV/) to produce full metadata files in [Sources-TEI/](Sources-TEI/)
* [Sources-TSV/](Sources-TSV/): extra TSV metadata and `listPerson` and `listOrg` XML files that this metadata should be added to,
  along with the build environment (Makefile) for this metadata enrichment
* [Sources-TEI/](Sources-TEI/): source ParlaMint TEI encoded corpora with full metadata
  (input to the release pipeline for ParlaMint)
* [Sources-Distro/](Sources-Distro/): supplementary documents included with a ParlaMint release
* [Sources-CoNLLU/](Sources-CoNLLU/): source CoNLL-U encoded corpora machine translated to English
  (input to the release pipeline for ParlaMint-en)
* [Taxonomies/](Taxonomies/): directory for development of common taxonomies
* [Makefile](Makefile): targets with the release pipeline
* [Scripts/](Scripts/): local scripts used for preparing a ParlaMint release
* [Logs/](Logs/): logs of the pipeline used to prepare a ParlaMint release
* [Distro/](Distro/): distribtion directory with corpora ready for a ParlaMint release
  (output of the release pipeline)
* [Packed/](Packed/): distribtion corpora packed (i.e. compressed) for a ParlaMint release on a CLARIN repository
* [Metadata/](Metadata/): automatically generated metadata of the corpus
* [Verts/](Verts/): distribtion vertical files joined together into one file per corpus, ready for importing to the concordancers
* [Test/](Test/): directory for test data, used for debugging the release pipeline
* [Temp/](Temp/): directory for temporary files, used in the release pipeline
