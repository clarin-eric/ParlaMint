# ParlaMint directory for samples of country XX (Kingdom of Testing)

- Language hr (Croatian)

## Documentation

### Characteristics of the national parliament

The Croatian Parliament (Sabor) is the unicameral legislative body of the Republic of Croatia. The Sabor is composed of 151 members elected to a four-year term on the basis of direct, universal and equal suffrage by secret ballot. Seats are allocated according to the Croatian Parliament electoral districts: 140 members of the parliament are elected in multi-seat constituencies. An additional three seats are reserved for the diaspora and Croats in Bosnia and Herzegovina, while national minorities have eight places reserved in parliament. The Sabor is presided over by a Speaker and her/his deputies.

### Data source and acquisition

Croatian corpus of parliamentary debates covers debates in the Croatian parliament (Sabor) from 2003 to 2022. It includes all transcripts of parliamentary debates publically available on Sabor’s official website (https://edoc.sabor.hr/Fonogrami.aspx). Speeches were collected using a scraper programmed in R programming language. The scraper first collected all unique links to parliamentary debates and then accessed them iteratively in order to extract raw speeches as well as metadata associated with them. Apart from the speech itself, the name of a speaker, and her/his political affiliation (party), the scraper also returned information on the date, term, session, and agenda point being discussed. To further populate the textual data with meta-information contextualizing collected speeches, another scraper was programmed for collecting publically available biographical information about the Croat MPs. The primary source of information was the official website of Sabor which contains basic information on date and place of birth, the term an MP served, gender, education, occupation, and political activity for most MPs (https://www.sabor.hr/hr/zastupnici). Missing information was added manually from other publicly available sources. The speeches from 2003-2020 were collected as a part of an ERC-funded project ELWar (https://zenodo.org/record/6521643).

### Data encoding process

The data were initially structured in four different parts:
- a table with transcriptions and their utterance IDs,
- a table with metadata on specific utterance IDs, including the ID of the speaker, date, term, house, speaker role and party,
- a table linking speaker ID with their personal data (e.g., their date and place of birth, education, party)
- a table describing parties, their abbreviation, full names, chairs, their coalition composition in specific terms, coalition vs. opposition statuses, and more.

The first two resources were used during the construction of the component TEI documents, while the last two were encoded in the root TEI. The data were checked for inconsistencies and imputed as best as possible using government sources (e.g. http://www.sabor.hr/) and independent projects (e.g. https://parlametar.hr/).

The data were read and cleaned using the python pandas library, after which a component XML template had been prepared. Day-level grouped data were packaged into a TEI-compatible format using the xmltree Python library, and inserted into the template. The root TEI document was prepared in a similar way, with the goal of encoding members of the parliament and the parties present in the data.

Finally, a regex + xmltree pipeline was run over the data to detect transcriber comments in the transcripts and to encode them in the TEI format as different types of notes, interruptions, gaps, or applause.

### Corpus-specific metadata

There are no metadata available beyond what is common for all corpora.

### Structure

There are no additional TEI elements beyond what is described in the ParlaMint schema.

### Linguistic annotation

For annotating the Croatian corpus, the standard language models for Croatian of the CLASSLA-Stanza pipeline (https://pypi.org/project/classla/) were used. On the level of morphosyntactic annotation for this corpus MULTEXT-East annotations (http://nl.ijs.si/ME/V6/msd/html/msd-hbs.html) are made available as well.
