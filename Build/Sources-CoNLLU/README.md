# ParlaMint Corpora Master Sources-MT

This directory contains the source CoNLL-U (and TSV, for notes) files for preparing the MTed version of the ParlaMint corpora.
Note that the complete corpora are much to large to be stored on GitHub, so the data files are gitignored.

The following files and subdirectories are part of this directory,
where XX corresponds to the ISO 3166 code of the country or autonomous region:

* `ParlaMint-XX-en`: CoNLL-U files of speeches which are produced by the MT + linguistic annotation pipeline
* `ParlaMint-XX-en.sem`: CoNLL-U files which have additional semantic tagging
* `ParlaMint-XX-en-notes.tsv`: A lexicon of all transcriber notes together with the element and element type that they appeared in,
  the original texts, and the text translated to English.
