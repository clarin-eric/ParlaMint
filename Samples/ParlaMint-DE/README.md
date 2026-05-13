# README

## Note for ParlaMint

This directory contains a sample of an early beta version of ParlaMint-DE as an
advancement of the GermaParl corpus of parliamentary debates. This sample as
well as full versions of the current beta corpus are also made available on the
[ParlaMint-DE_beta repository](https://github.com/PolMine/ParlaMint-DE_beta) on
GitHub. The following README which introduces the corpus is taken from this
repository.

## Overview

This repository contains an early beta version of the advancement of GermaParl,
a corpus of plenary protocols of the German *Bundestag*, toward the ParlaMint
encoding schema (https://clarin-eric.github.io/ParlaMint/). Developed within
the [PolMine project](https://polmine.github.io), GermaParl as ParlaMint will
provide all plenary protocols of the German *Bundestag* between 1949 and 2025 in
a highly interoperable data format. Compared to previous releases of GermaParl,
the prospective ParlaMint-DE corpus will provide additional and more
fine-grained metadata for persons and organizations.

To learn more about the previous releases of GermaParl, please also see the Zenodo
page here: https://doi.org/10.5281/zenodo.3735140.

To learn more about the ParlaMint project, please see the project website
here: https://www.clarin.eu/parlamint.

While many features of ParlaMint are already included in this version, in the
current state, the corpus is neither fully consolidated nor validated against the
ParlaMint encoding guidelines yet. Missing metadata and annotations will be added
in future updates. Remaining issues are to be expected both in terms of the
encoding schema itself and data quality. Known issues will be reported via GitHub
and iterative improvements will be made available in this repository.

## Corpus

The corpus comprises of all plenary protocols of the German *Bundestag* between
September 1949 and March 2025. Initial protocol data has been retrieved from the
website of the German *Bundestag* in various data formats (unstructured XML, plain text,
PDF, structured XML). For most legislative periods, regular expressions are used
to identify individual utterances. Data is then transformed into a structured XML
format and enriched with additional metadata. The corpus preparation pipeline of
previous releases is discussed in more detail [here](https://polmine.github.io/GermaParl2/).

For the advancement toward ParlaMint, the corpus preparation pipeline described
above is advanced to account for the requirements of the shared encoding schema of ParlaMint.
To realize the new corpus structure, we retrieved shared taxonomy files found in this
repository from the "ParlaMint-DE" directory in the "Data" branch of the ParlaMint
GitHub repository (https://github.com/clarin-eric/ParlaMint/). We then added protocol
data, root file and metadata on persons and organizations as well as local
taxonomies.

## Data Sources

- Protocol Data has been retrieved from the website of the German *Bundestag*, most
importantly from the Open Data website here: https://www.bundestag.de/services/opendata.
- Information on Members of Parliament has been extracted from the "Stammdaten" file
of the German *Bundestag* which also can be found at https://www.bundestag.de/services/opendata.
- Date-specific information on the party affiliation of Members of Parliament for
the time span of 1949 to 2017 is extracted from the Parliaments Day-by-Day Database
compiled by Turner-Zwinkels and colleagues. See https://doi.org/10.1111/lsq.12359
for the research article and https://doi.org/10.7910/DVN/PYGBDO for the dataset on
Harvard Dataverse. We extended the dataset for more recent legislative periods
(2017 - 2025) using Wikipedia.
- Metadata on other persons who are not Members of Parliament as well as metadata
on organizations has been retrieved from Wikipedia.
- Wikidata is used to retrieve identifiers for all persons as well as information
on gender for persons who are not Members of Parliament.

Also see `ParlaMint-DE-taxonomy-metadata_sources.xml` for additional information
on the source of metadata.

## Next Steps

Similar to other releases of GermaParl, we plan to release ParlaMint-DE on Zenodo,
using an open license (CC BY). We aim for a release in the near future, once
validation, the addition of missing metadata and linguistic annotation is complete.
