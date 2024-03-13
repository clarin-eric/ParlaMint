# ParlaMint Build directory

This directory contains the build environemnt for a release, i.e. the input data sources, the output
distribution-ready corpora, and the dedicated scripts.

Note that the complete corpora are to large to be stored on GitHub, so most of the data files are gitignored.

Here you can find the following directories:

* [Sources-TEI/](Sources-TEI/): source ParlaMint TEI encoded corpora
  (input to the release pipeline for ParlaMint)
* [Sources-MT/](Sources-MT/): source CoNLL-U encoded corpora machine translated to Enlgish
 (input to the release pipeline for ParlaMint-en)
* [Makefile](Makefile): targets with the release pipeline
* [bin/](bin/): local scripts used for preparing a ParlaMint release
* [Docs/](Docs/): supplementary documents included with a ParlaMint release
* [Logs/](Logs/): logs of the pipeline used to prepare a ParlaMint release
* [Distro/](Distro/): distribtion directory with corpora ready for a ParlaMint release
  (output of the release pipeline)
* [Packed/](Packed/): Master corpora packed (i.e. compressed) for a ParlaMint release on a CLARIN repository
* [Verts/](Verts/): Master vert files joined together into one file per corpus, ready for importing to the concordancers
* [Test/](Test/): Folder to test data, used for debugging the release pipeline
* [Temp/](Temp/): Folder for temporary files, used in the release pipeline
* [Metadata/](Metadata/): automatically generated metadata of the corpus
* [Taxonomies/](Taxonomies/): directory for development of common taxonomies
* [Ministers/](Ministers/): TSV files and build invironment for inserting minister affiliations into
  the ParlaMint corpora
* [Orientations/](Orientations/): TSV files for inserting political orientation of parliamentary groups
  and political parties minister affiliations into the ParlaMint corpora
