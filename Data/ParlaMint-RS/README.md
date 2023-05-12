# ParlaMint directory for samples of country RS (Serbia)

- Languages: sr (Serbian)



## Documentation

### Characteristics of the national parliament

The National Assembly is the unicameral legislative body of Serbia. The assembly consists of 250 deputies elected under proportional electoral system for four years. Deputies then elect the speaker of the house and her/his deputies. The National Assembly exercises supreme legislative power. It adopts and amends the Constitution, elects Government, and appoints top state officials. Despite the position of the National Assembly in the political system of Serbia, its role is strongly affected by its relation to the office of the president. As the directly elected president has always been able to retain his position in the party hierarchy, the electoral system with closed electoral lists and weak intra-party democracy created a power structure under which the head of state can easily control the parliamentary majority, the government, and the debate on legislative proposals.

### Data source and acquisition

The corpus consists of a stenographic transcription of parliamentary sessions collected automatically using a scraper programmed in R programming language. The data were collected from the website of a non-profit project Open Parliament (Otvoreni parlament), which digitalizes and maps the records the Assembly publishes (https://otvoreniparlament.rs/transkript). The corpus covers the period of 1997-2022. The scraper first collected all unique links to parliamentary debates and then accessed them iteratively in order to extract raw speeches as well as metadata associated with them. The website provides information on the name of the speaker and her/his political affiliation (party), the date of speech, term, session, and agenda point discussed. On top of that, an additional database contextualizing speeches was constructed. The main source of biographical information on elected MPs was the official website of the National Assembly (http://www.parlament.gov.rs/national-assembly/composition/members-of-parliament/current-legislature.487.html). Missing data was added manually from publicly available online sources. Short textual bios (if available) were parsed using string manipulation into separate entries. The database contains the date and place of birth, term, gender, education, and occupation. Although the corpus quality is relatively high, several structural challenges need to be acknowledged. First, the character of debates does not allow easily assigning agenda points to a set of speeches. The way how moderators manage the debates leads to an often chaotic system of discussions and voting. The problem was more apparent in the early days when a very authoritative moderating style prevailed. Second, because of the size of the parliament (250 MPs), the debates appear to be less developed when it comes to the complexity of the recorded discussion. Put differently, due to the size of the legislative body, more people can contribute to the debate, which makes it more scattered and less focused. Finally, the character of the regime of Serbia reflects upon the overall role of the parliament in the legislative process. Authoritarian tendencies of part of the ruling elites make the National Assembly play only a secondary role in Serbian democracy. Especially recently, debates have become a reflection of the political dominance of the ruling coalitions led by the Serbian Progressive Party and its leader and the current Serbian president Aleksandar Vučić. The speeches from 1997-2020 were collected as a part of an ERC-funded project ELWar (https://zenodo.org/record/6521795).

### Data encoding process

The data were initially structured in four different parts:

- a table with transcriptions and their utterance IDs,
- a table with metadata on specific utterance IDs, including the ID of the speaker, date, term, house, speaker role and party,
- a table linking speaker ID with their personal data (e.g., their date and place of birth, education, party)
- a table describing parties, their abbreviation, full names, chairs, their coalition composition in specific terms, coalition vs. opposition statuses, and more.

The first two resources were used during the construction of the component TEI documents, while the last two were encoded in the root TEI. The data were checked for inconsistencies and imputed as best as possible using government sources (e.g. http://www.parlament.gov.rs/) and independent projects (e.g. https://otvoreniparlament.rs/).

The data were read and cleaned using the python pandas library, after which a component XML template had been prepared. Day-level grouped data were packaged into a TEI-compatible format using the xmltree Python library, and inserted into the template. The root TEI document was prepared in a similar way, with the goal of encoding members of the parliament and the parties present in the data.

Finally, a regex + xmltree pipeline was run over the data to detect transcriber comments in the transcripts and to encode them in the TEI format as different types of notes, interruptions, gaps, or applause.

### Corpus-specific metadata

There are no metadata available beyond what is common for all corpora.

### Structure

There are no additional TEI elements beyond what is described in the ParlaMint schema.

### Linguistic annotation

For annotating the Serbian corpus, the more robust, nonstandard language models for Serbian of the CLASSLA-Stanza pipeline (https://pypi.org/project/classla/) were used. On the level of morphosyntactic annotation for this corpus MULTEXT-East annotations (http://nl.ijs.si/ME/V6/msd/html/msd-hbs.html) are made available as well.
