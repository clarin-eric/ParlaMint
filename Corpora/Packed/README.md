# ParlaMint Corpora Packed

This directory contains the complete ParlaMint corpora release, packed for distribution in a CLARIN repository.

Note that the complete corpora are much to large to be stored on GitHub, so all of the data files are gitignored.

The following files are part of this directory,
where XX corresponds to the ISO 3166 code of the country or autonomous region:

* `ParlaMint-XX.tgz`: The "plain text" version of a ParlaMint corpus, which includes
   the "plain text" ParlaMint TEI corpus (`ParlaMint-XX.TEI/`),
   and the corpus converted to plain text files with TSV per-speech metadata (`ParlaMint-XX.txt/`)
* `ParlaMint-XX.ana.tgz`:  The "plain text" version of a ParlaMint corpus, which includes
   the linguistically analysed ParlaMint TEI corpus (`ParlaMint-XX.TEI.ana/`),
   the corpus converted to CoNLL-U  with TSV per-speech metadata (`ParlaMint-XX.conllu/`),
   and vertical files (`ParlaMint-XX.vert/`)

The files above are also present with the -en suffix (e.g. `ParlaMint-TE-en.tgz`) which contain the corpora
that have been machine translated to English.
