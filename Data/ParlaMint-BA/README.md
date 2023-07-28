# ParlaMint directory for samples of country BA (Bosnia and Herzegovina)

- Languages: bs (Bosnian)


## Documentation

### Characteristics of the national parliament

The Parliamentary Assembly of Bosnia and Herzegovina is the legislative body of Bosnia and Herzegovina. It consists of two chambers: The House of Representatives (42 members) and The House of Peoples (15 members). The parliament is elected every four years. The corpus contains unauthorized (but officially published) transcripts of parliamentary sessions from both houses. It covers the period of 1998-2022.

### Data source and acquisition

Transcripts of parliamentary debates were collected from the official website of the Parliamentary Assembly of Bosnia and Herzegovina and cover the period from 1998 to 2022. Records were originally stored as machine-readable PDF files with a loose structure and fluid form over different terms (https://www.parlament.ba/session/Read?ConvernerId=2; https://www.parlament.ba/session/Read?ConvernerId=1). Each document was parsed and text-mined using regular expressions (RegEx) in order to construct a proto-dataset with a simple structure having just two entries: a speaker (most often first and last name) and a speech (a string of text capturing transcribed spoken word in Bosnian-Croatian-Serbian). It was then further populated with meta-information assigned to its parent file – House of Parliament, date, and session number. Finally, the names of MPs were linked with their party affiliation and biographic information collected from the official website of the parliament (https://www.parlament.ba/delegate/list; https://www.parlament.ba/representative/list). Missing entries were filled manually based on an extensive online search. As raw text exported from PDF files does not contain any formatting tags, additional information on agenda points had to be extracted using regular expressions and checked manually. Agenda points were then used for identification of moderators. This was done for all terms with several rounds of cleaning and parsing. The speeches from 1998-2018 were collected as a part of an ERC-funded project ELWar (https://zenodo.org/record/6521063).

### Data encoding process

The data were initially structured in four different parts:

- a table with transcriptions and their utterance IDs,
- a table with metadata on specific utterance IDs, including the ID of the speaker, date, term, house, speaker role and party,
- a table linking speaker ID with their personal data (e.g., their date and place of birth, education, party)
- a table describing parties, their abbreviation, full names, chairs, their coalition composition in specific terms, coalition vs. opposition statuses, and more.

The first two resources were used during the construction of the component TEI documents, while the last two were encoded in the root TEI. The data were checked for inconsistencies and imputed as best as possible using government sources (e.g. parlament.ba) and independent projects (e.g. javnarasprava.ba).

The data were read and cleaned using the python pandas library, after which a component XML template had been prepared. Day-level grouped data were packaged into a TEI-compatible format using the xmltree Python library, and inserted into the template. The root TEI document was prepared in a similar way, with the goal of encoding members of the parliament and the parties present in the data.

Finally, a regex + xmltree pipeline was run over the data to detect transcriber comments in the transcripts and to encode them in the TEI format as different types of notes, interruptions, gaps, or applause.

### Corpus-specific metadata

There are no metadata available beyond what is common for all corpora.

### Structure

There are no additional TEI elements beyond what is described in the ParlaMint schema.

### Linguistic annotation

For annotating the Bosnian corpus, the standard language models for Croatian of the CLASSLA-Stanza pipeline (https://pypi.org/project/classla/) were used. On the level of morphosyntactic annotation for this corpus MULTEXT-East annotations (http://nl.ijs.si/ME/V6/msd/html/msd-hbs.html) are made available as well.