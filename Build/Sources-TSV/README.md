# ParlaMint Sources-TSV

This directory contains the TSV metadata files and the top-level listPerson and listOrg XML files that this metadata should be added to,
along with the build environment (Makefile) for this metadata enrichment.
The output listPerson and listOrg files are written to ../Sources-TEI and overwrite these two files there.

Each ParlaMint-XX/ directory can contain the following:

## Source TEI files
The input ParlaMint XML files, must be present:
* `ParlaMint-XX-listOrg.xml`: the list of organisations
* `ParlaMint-XX-listPerson.xml`: the list of speakers

## TSV metadata files with minister affiliations
These TSV files are meant for inserting minister affiliations into ParlaMint speakers,
i.e. into `ParlaMint-XX-listPerson.xml`
and can contain the following files for country `XX`:
* `Ministers-XX.auto.tsv`: automatically generated list of ministers
* `Ministers-XX.edited.tsv`: hand-edited list of ministers
* `Ministers-XX.log`: log of trying to merge the hand-edited list of ministers into the listPerson

## TSV metadata files with CHES political orientations
These TSV files are meant for inserting CHES (Chappel Hill Survey) political orientations into ParlaMint organisations,
i.e. into ParlaMint-XX-listOrg.xml
and can contain the following files for country `XX`:
* `Orientation-XX.CHES.tsv`: automatically generated list of CHES variables from the source CSV files,
  together with the mapping of political party or parliamentary group IDs from CHES to those of ParlaMint

## TSV metadata files with Wiki political orientations
These TSV files are meant for inserting WikiPedia left-to-right political orientations into ParlaMint organisations,
i.e. into ParlaMint-XX-listOrg.xml
and can contain the following files for country `XX`:
* `Orientation-XX.Wiki.tsv`: hand-prepared list of left-to-right political orientations 
  together with the URL of the source Wikipedia page and optional comment

## TSV metadata files with encoder political orientations
These TSV files are meant for inserting encoder-determined WikiPedia left-to-right political orientations into ParlaMint organisations,
i.e. into ParlaMint-XX-listOrg.xml
and can contain the following files for country `XX`:
* `Orientation-XX.enco.tsv`: hand-prepared list of left-to-right political orientations 
  together with the ID of the encoder (should be defined in the corpus root file) and optional comment

## TSV metadata files with speaker sex (currently only BA, HR, SR)
These TSV files are meant for inserting missing or wrongly determined sex of ParlaMint speakers,
i.e. into `ParlaMint-XX-listPerson.xml`;
and can contain the following files for country `XX`:
* `Sex-XX.auto.tsv`: dump of all speakers with speaker ID, name and surname, and current sex, 'U' if missing
* `Sex-XX.fixed.tsv`: automatically or hand fixed list of the sex of speakers; columns are identical to the .auto version,
  and only the sex column should be changed.
