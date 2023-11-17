# Samples of the ParlaMint-UA corpus

- Country: UA (Ukraine)
- Languages: uk (Ukrainian), ru (Russian)

## Documentation

### Characteristics of the national parliament

The Verhkovna Rada of Ukraine (Ukrainian: Верховна Рада України, lit. the Supreme Council of Ukraine, VR or Rada for short) is the unicameral parliament of Ukraine, with members elected to a five-year term. There have been nine terms (convocations) of the Rada in modern Ukrainian history, with the 6th, 8th and 9th Radas elected at snap parliamentary elections. The Rada comprises 450 Members of Parliament (Ukrainian: народні депутати, or people’s deputies). However, elections for the constituencies situated in the occupied parts of Donetsk and Luhansk Oblasts as well as Crimea have not been held since Russia’s aggression in 2014, which resulted in electing only 423 MPs for the 8th Rada and 424 MPs for the 9th Rada. The current election system is mixed, with 50 % of seats distributed under party lists and 50 % of seats won in single-member constituencies.

Parliamentary meetings during one term are grouped into several sessions. Each first session of a newly convoked Rada is presided over by members of a temporary presidium, until a Chairperson (Ukrainian: Голова Верховної Ради, lit. Head of the Verhkovna Rada), a First Deputy Chairperson (Ukrainian: Перший заступник Голови Верховної Ради, lit. First Deputy Head of the Verhkovna Rada) and a Deputy Chairperson (Ukrainian: заступник Голови Верховної Ради, lit. Deputy Head of the Verhkovna Rada) are elected from among its ranks. In circumstances where the post of President of Ukraine becomes vacant, the Chairman of the Rada becomes acting head of state with limited authority, which was the case in February–June 2014.

Commonly there may be one or two parliamentary meetings per day (a morning and an evening sitting).

Although the official working language of the Rada is Ukrainian, some speeches during parliamentary proceedings between 2012 and 2023 were held in languages other than Ukrainian. All the speeches delivered by foreign guests were recorded in their translation into Ukrainian in the source texts. However, utterances by Ukrainian MPs and government officials that were produced in Russian were recorded in Russian. Total utterances in Russian comprise about 2% in the source texts, with most of them occurring before mid-2019, when the Law on Protecting the Functioning of the Ukrainian Language as the State Language came into effect.

The political system in Ukraine is multi-party, with 349 political parties on record at the country's Single Registry as of 1 January 2020. Contemporary political parties in Ukraine tend not to have clear-cut ideologies and centre around civilizational and geostrategic orientations, individual politicians or business interests. Also, renaming and rebranding political parties ahead of elections is not unusual. Parties that break the 5% electoral threshold form factions in the parliament. MPs elected on party lists may be either members of the respective parties or be nominated by those parties without membership. Parliamentary groups may consist of MPs who left a parliamentary faction, members of different political parties or independent politicians. An MP may be a member of only one parliamentary faction or group at a time.


### Data source and acquisition

The ParlaMint-UA corpus contains proceedings for the 7th, 8th and 9th terms of the Rada between 12 December 2012 and 24 February 2023. Archived records of all plenary sittings are available through the open data portal at the Rada site in HTM format (https://data.rada.gov.ua/open/data/plenary/page5/sp?int) under the CC BY 4.0 licence.

The metadata related to MPs were in part retrieved from the Rada website and in part gathered manually from official sources including the Central Election Commission of Ukraine, the official periodical of the Rada and other open data sources. Metadata related to Cabinet members and guest speakers were gathered manually from the current sites of the Cabinet of Ministers of Ukraine and the Rada, archived copies of webpages from the sites of the Rada, the Cabinet of Ministers of Ukraine, and the President of Ukraine as well as various open data sources including NGOs’ websites, mass and social media, and Wikipedia.

Since Chapel Hill expert surveys do not include Ukraine, the metadata on political orientation of the Ukrainian parties was obtained from Wikipedia, if available, and other sources including party webpages as well as analytical reports and publications by Ukrainian think tanks and research institutes.


### Data encoding process

No correction of source texts was performed. Spaces were normalized. Sequences of dots were replaced with a single dot. Adjected notes were joined. Opening and closing parentheses were moved into notes if missing. Regular apostrophes were replaced with soft apostrophes, which are used in the Ukrainian language. No end-of-line hyphens were present in the source. Quotation marks have been left in the text and are not explicitly marked up. The texts were segmented into utterances (speeches) and segments (corresponding to paragraphs in the source transcription).

Language identification was based on expected frequencies for Ukrainian- and Russian-specific characters in the corpus (6.23 %(і) + 0.84 %(ї) + 0.39 %(є) + 0.01 %(ґ) = 7.47 % for Ukrainian, and 2.36 %(ы) + 0.36 %(э) + 0.2% (ё) + 0.02 %(ъ) = 2.94% for Russian), corpus-specific frequency word lists in Ukrainian and Russian, and Perl package Lingua::Identify::Any. A limitation of 250 characters was used for making decisions on language identification of shorter utterances based on Ukrainian-specific words, with a limitation of 100 characters for Russian-specific words.


### Corpus-specific metadata

The extended affiliation role “acting” was used for government officials who were appointed to serve in the role of a minister or a deputy minister on an interim basis but not to hold a respective office. Patronymic names were included as a surname type. The category of regular speakers embraced not only MPs and members of the Cabinet of Ministers but also deputy ministers who may speak in the Rada on behalf of the ministries they represent.

Also, metadata on all MPs from the 4th, 5th and 6th terms were stored, while they were available, with the intention to eventually include proceedings from the previous terms into the ParlaMint-UA corpus.

### Structure

There are no additional TEI structural elements beyond what is described in the ParlaMint schema.

### Linguistic annotation
POS tagging, lemmatization and dependency parsing were done with UDPipe 2 (http://ufal.mff.cuni.cz/udpipe/2) with ukrainian-iu-ud-2.10-220711 and russian-syntagrus-ud-2.10-220711 models.

The Ukrainian NER model was trained and deployed as part of the NameTag service (http://lindat.mff.cuni.cz/services/nametag/), with https://github.com/lang-uk/ner-uk dataset (data folder) used for training. We would like to thank [Jana Strakova](https://ufal.mff.cuni.cz/jana-strakova) for training the Ukrainian NER tool.

### Disclaimer to the English translation

Note that the automatically produced translation to English contains errors typical of neural machine translation, which also includes factual errors even when a high level of fluency is achieved, and any manual or automatic usage of this corpus should take the machine translation limitations into account.
