# ParlaMint Sources-TSV

This directory contains the TSV metadata files and the top-level `listPerson` and `listOrg` XML files that this metadata should be added to,
along with the build environment (Makefile) for this metadata enrichment.
The output `listPerson` and `listOrg` files are written to [Sources-TEI](../Sources-TEI) and overwrite these two files there.

The envisioned work-flow for adding metadata is:
1. From the corpus in [Sources-TEI](../Sources-TEI)/ParlaMint-XX.TEI/ copy the
  `ParlaMint-XX-listPerson.xml` and `ParlaMint-XX-listOrg.xml` to [Sources-TSV](../Sources-TSV)/ParlaMint-XX/
2. For one of the defined layers for metadata addition (see below) run `make` with the appropriate target,
   e.g. `make generate-ministers CORPUS=XX' to initialise the appropriate automatically generated TSV file for this corpus
   (in this case [Sources-TSV](../Sources-TSV)/ParlaMint-XX/Ministers-XX.auto.tsv).
3. Copy this file to its edited variant, by substituting `.auto.` with `.edited.`.
   (in this case to [Sources-TSV](../Sources-TSV)/ParlaMint-XX/Ministers-XX.edited.tsv)
4. Edit the `.edited.` file and insert the required metadata without chaning the columns for country and
   person/organisation key.
5. Once finished, run `make insert-metadata CORPUS=XX`, which will insert the metadata in the `.edited.` TSV files
   into [Sources-TEI](../Sources-TEI)/ParlaMint-XX.TEI/ and [Sources-TEI](../Sources-TEI)/ParlaMint-XX.TEI.ana/
   `ParlaMint-XX-listPerson.xml` and/or `ParlaMint-XX-listOrg.xml` files.

To define a new type of metadata to insert, e.g. `zz`, the appropriate scripts need to be written and placed in
 [Build/Scripts](../Scripts/), in particular `zz-tei2tsv.xsl` and `zz-tsv2tei.xsl` (existing scripts can be of help),
 the script [add-metadata.pl](../Scripts/add-metadata.pl) and the [Makefile](Makefile) in this directory extended
 with the new scripts.

Each ParlaMint-XX/ directory can contain the following:

## Source TEI files
The input ParlaMint XML files, must be present:
* `ParlaMint-XX-listOrg.xml`: the list of organisations
* `ParlaMint-XX-listPerson.xml`: the list of speakers

## TSV metadata files with minister affiliations
These TSV files are meant for inserting minister affiliations into ParlaMint speakers,
i.e. into `ParlaMint-XX-listPerson.xml`
and can contain the following files for country `XX`:
* `Ministers-XX.auto.tsv`: automatically generated list of ministers from source corpus
* `Ministers-XX.edited.tsv`: hand-edited list of ministers
* `Ministers-XX.log`: log of trying to merge the hand-edited list of ministers into the listPerson

## TSV metadata files with CHES political orientations
These TSV files are meant for inserting CHES (Chappel Hill Survey) political orientations into ParlaMint organisations,
i.e. into ParlaMint-XX-listOrg.xml
and can contain the following files for country `XX`:
* `OrientationCHES-XX.edited.tsv`: generated list of CHES variables from the source CSV files,
  together with the mapping of political party or parliamentary group IDs from CHES to those of ParlaMint

## TSV metadata files with Wiki political orientations
These TSV files are meant for inserting WikiPedia left-to-right political orientations into ParlaMint organisations,
i.e. into ParlaMint-XX-listOrg.xml
and can contain the following files for country `XX`:
* `OrientationWiki-XX.auto.tsv`: automatically initialised list of left-to-right political orientations from source corpus
* `OrientationWiki-XX.edited.tsv`: hand-edited list of left-to-right political orientations 
  together with the URL of the source Wikipedia page and optional comment

## TSV metadata files with encoder political orientations
These TSV files are meant for inserting encoder-determined WikiPedia left-to-right political orientations into ParlaMint organisations,
i.e. into ParlaMint-XX-listOrg.xml
and can contain the following files for country `XX`:
* `OrientationEnco-XX.edited.tsv`: hand-edited list of left-to-right political orientations 
  together with the ID of the encoder (should be defined in the corpus root file) and optional comment

## TSV metadata files with speaker sex (currently only BA, HR, SR)
These TSV files are meant for inserting missing or wrongly determined sex of ParlaMint speakers,
i.e. into `ParlaMint-XX-listPerson.xml`;
and can contain the following files for country `XX`:
* `Sex-XX.auto.tsv`: dump of all speakers with speaker ID, name and surname, and current sex, 'U' if missing
* `Sex-XX.edited.tsv`: automatically or hand fixed list of the sex of speakers; columns are identical to the .auto version,
  and only the sex column should be changed. Contains only the U(nknown) gender persons from `Sex-XX.auto.tsv`;
  if it is empty, it means that all persons in source corpus have known gender.
