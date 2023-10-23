# Samples of the ParlaMint-EE corpus

- Country: EE (Estonia)
- Languages: et (Estonian)

## Documentation

### Characteristics of the national parliament

Estonia has a unicameral parliament, which is elected through proportional representation every four years. Only political parties can set up lists of candidates at elections (also single independent candidates can run, but no independent candidate has ever been successful at parliamentary elections) and elected MPs from the same electoral list can form parliamentary factions (groups). If an MP leaves a faction, he or she is not allowed to join another party faction and will remain officially unaffiliated until the end of the parliamentary term.

The work of the parliament is divided into a spring and autumn session - the former lasts from the second week of January until the third week of June and the latter from the second week of September until the third week of December. Within each session three weeks of sittings are followed by a week off. Parliamentary sittings take place from Monday to Thursday. Wednesday also includes an info-session, where the MPs can ask questions from members of government. Extraordinary sessions can take place outside of the spring and autumn session.

The Estonian transcripts contain texts from the regular sessions as well as extraordinary sessions. Sittings, where legislative work takes place, are also distinguished from info sessions, which serve a function of parliamentary oversight. The party affiliation of members of parliament is identified according to their faction membership.

### Data source and acquisition

The data for the transcripts was downloaded from the official website of the parliament using the search engine for the transcripts (https://stenogrammid.riigikogu.ee/). The search engine was used to obtain links to individual transcripts, which were then downloaded. The data that can be obtained from the search engine contains the date and time, the agenda item and the name of the speaker. Spelling mistakes in the names of the speakers were amended and the names were harmonised across the corpus (e.g. the same people were sometimes referred to using different combinations of their first names). The names of the members of government who spoke in parliament as well as other guest speakers also contained their job title in the transcripts, which was removed during data cleaning. Chairmen and deputy-chairmen of the parliament were also identified in the transcripts by the use of job titles in their names. This information was recorded separately and the job title removed from their name.

Information from the website of the parliament about the compositions of parliament was used to determine the faction affiliation of each MP. Their date of birth was available from information about candidates that has been published on the website of the National Electoral Committee (https://www.valimised.ee/). The gender of MPs was added manually. Party affiliation of members of the government who spoke in parliament as well as their date of birth and gender were also added using information available from the website of the government (https://valitsus.ee/).

The Estonian data included in ParlaMint II covers a time period from 2011-04-04 to 2022-06-17.

### Data encoding process

The starting file for data encoding was a single json file that contained the processed transcripts as well as all the information about the speakers. As a first stage, the json file was chunked according to date, next all date files were processed individually. A special tool was developed for processing json files, see
https://github.com/nemeek/parlamintee .
Linguistic annotation and NER tagging was done with EstNLTK (ver. 1.6.9b) using Stanza (ver. 1.3.0) see https://github.com/estnltk/estnltk/.

### Corpus-specific metadata

In addition to the required metadata, the corpus contains the birth date of the MPs, it identifies members of government and provides their party affiliation, gender as well as date of birth. Each piece of text in the data set also contains the link to the original transcript on the website of the Riigikogu.

### Structure

No additional elements and attributes were used besides the ParlaMint schema.

### Linguistic annotation

In the lemma attribute, components of compound words are separated with underscore.

Example:

```XML
<w xml:id="ParlaMint-EE_2015-01-12_U1-P1.4.1" lemma="üle_andmine" msd="UPosTag=NOUN|Case=Gen|Number=Sing" pos="S">Üleandmise</w>.
```

The part-of-speech attributes (“pos”) are encoded in a language-specific way, for documentation see https://cl.ut.ee/ressursid/morfo-systeemid/ (CG part-of-speech, subcategories with UD annotation in “msd” attributes). UD part-of-speech info is encoded to “msd” attribute as value of UPosTag.

Example:

```XML
 <w xml:id="ParlaMint-EE_2015-01-12_U8-P1.4.21" lemma="avatum" msd="UPosTag=ADJ|Case=Tra|Degree=Cmp|Number=Sing" pos="A">avatumaks</w>
```

There are no named entities besides persons, organisations, and locations.
