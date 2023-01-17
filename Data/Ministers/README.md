# ParlaMint Ministers

This directory contains the TSV files and build invironment for inserting minister affiliations into
the ParlaMint corpora.

The current state of processing is:
* Source corpus already contains ministers: AT CZ DK GR HU IS NL NO PT SE SI TR
* Edited files: BE ES HR LT LV PL SI (TR)
* Not yet edited: BA BG RS

The directory contains the following types of files:
* ParlaMint_speakers-XX.tsv: complete list of speakers
* ParlaMint_ministers-XX.auto.tsv: automatically generated list of ministers
* ParlaMint_ministers-XX.edited.tsv: hand-edited list of ministers
* ParlaMint_ministers-XX.log: log of trying to merge the edited list of ministers into corpus
