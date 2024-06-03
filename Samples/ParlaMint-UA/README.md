# Samples of the ParlaMint-UA corpus

- Country: UA (Ukraine)
- Languages: uk (Ukrainian), ru (Russian)

## Documentation

### Characteristics of the national parliament

The Verhkovna Rada of Ukraine (Ukrainian: Верховна Рада України, lit. the Supreme Council of Ukraine, VR or Rada for short) is the unicameral parliament of Ukraine, with members elected to a five-year term. There have been nine terms (convocations) of the Rada in modern Ukrainian history, with the 6th, 8th and 9th Radas elected at snap parliamentary elections. The Rada comprises 450 Members of Parliament (Ukrainian: народні депутати, or people’s deputies). However, elections for the constituencies situated in the occupied parts of Donetsk and Luhansk Oblasts as well as Crimea have not been held since Russia’s aggression in 2014, which resulted in electing only 423 MPs for the 8th Rada and 424 MPs for the 9th Rada. The current election system is mixed, with 50 % of seats distributed under party lists and 50 % of seats won in single-member constituencies.

Parliamentary meetings during one term are grouped into several sessions. Each first session of a newly convoked Rada is presided over by members of a temporary presidium, until a Chairperson (Ukrainian: Голова Верховної Ради, lit. Head of the Verhkovna Rada), a First Deputy Chairperson (Ukrainian: Перший заступник Голови Верховної Ради, lit. First Deputy Head of the Verhkovna Rada) and a Deputy Chairperson (Ukrainian: заступник Голови Верховної Ради, lit. Deputy Head of the Verhkovna Rada) are elected from among its ranks. In circumstances where the post of President of Ukraine becomes vacant, the Chairman of the Rada becomes acting head of state with limited authority, which was the case in February–June 2014.

Commonly there may be one or two parliamentary meetings per day (a morning and an evening sitting).

Although the official working language of the Rada is Ukrainian, some speeches during the parliamentary proceedings on record were be held in other languages. All the speeches delivered by foreign guests in languages other than Ukrainian were recorded in their translation into Ukrainian in the source texts. However, utterances by Ukrainian MPs and government officials that were produced in Russian were recorded in Russian. With language identification done at the sentence level in the ParlaMint-UA 4.1 corpus, tokens in Ukrainian comprise 94% and tokens in Russian comprise 6% in the source texts. Instances of using Russian in the Verkhovna Rada occurred mostly before mid-2019, when the Law on Protecting the Functioning of the Ukrainian Language as the State Language came into effect.

The political system in Ukraine is multi-party, with 349 political parties on record at the country's Single Registry as of 1 January 2020. Contemporary political parties in Ukraine tend not to have clear-cut ideologies and centre around civilizational and geostrategic orientations, individual politicians or business interests. Also, renaming and rebranding political parties ahead of elections is not unusual. Parties that break the 5% electoral threshold form factions in the parliament. MPs elected on party lists may be either members of the respective parties or be nominated by those parties without membership. Parliamentary groups may consist of MPs who left a parliamentary faction, members of different political parties or independent politicians. An MP may be a member of only one parliamentary faction or group at a time. However, crossing the floor, i.e. formally changing one's political affiliation to a parliamentary faction or group different from the one an MP initially joined, is not exceptional in the Rada.


### Data source and acquisition

The ParlaMint-UA 4.1 corpus contains proceedings for the 4th, 5th, 6th, 7th, 8th and 9th terms of the Rada between 14 May 2002 and 10 November 2023. Archived records of all plenary sittings are available through the open data portal at the Rada site in HTM format (https://data.rada.gov.ua/open/data/plenary/page5/sp?int) under the CC BY 4.0 licence.

The metadata related to MPs were in part retrieved from the Rada website and in part gathered manually from official sources including the Central Election Commission of Ukraine, and Holos Ukrainy, which is the official periodical of the Rada, as well as from other open data sources. Metadata related to Cabinet members and guest speakers were gathered manually from the current sites of the Cabinet of Ministers of Ukraine and the Rada, archived copies of webpages from the sites of the Rada, the Cabinet of Ministers of Ukraine, and the President of Ukraine as well as various open data sources including NGOs’ websites, mass and social media, and Wikipedia.

Since Chapel Hill expert surveys do not include Ukraine, the metadata on political orientation of the Ukrainian parties was obtained from Wikipedia, if available, and other sources including party webpages as well as analytical reports and publications by Ukrainian think tanks and research institutes.


### Data encoding process

No correction of source texts was performed. Spaces were normalized. Sequences of dots were replaced with a single dot. Adjected notes were joined. Opening and closing parentheses were moved into notes if missing. Regular apostrophes were replaced with soft apostrophes, which are used in the Ukrainian language. No end-of-line hyphens were present in the source. Quotation marks have been left in the text and are not explicitly marked up. The texts were segmented into utterances (speeches) and segments (corresponding to paragraphs in the source transcription).

Language identification was done at the sentence level using the https://github.com/pemistahl/lingua-py library. The following language identification procedure was used:
1)	paragraphs were segmented into sentences with UDPipe1 and ukrainian-iu-ud-2.5-191206.udpipe model (language distinction was irrelevant at this stage, as it was assumed that overall sentence segmentation was the same in Ukrainian and Russian);
2)	the language of sentences was identified;
3)	adjected sentences were merged with the same language that was in the same paragraph to spans;
4)	udpipe annotation was done with the respective span models ukrainian-iu-ud-2.12-230717 and russian-syntagrus-ud-2.12-230717;
5)	paragraph language was set based on dominating token language (if equal, then Ukrainian).


### Corpus-specific metadata

The extended affiliation role “acting” was used for government officials who were appointed to serve in the role of a minister or a deputy minister on an interim basis but not to hold a respective office. Patronymic names were included as a surname type. The category of regular speakers embraced not only MPs and members of the Cabinet of Ministers but also deputy ministers who may speak in the Rada on behalf of the ministries they represent.


### Structure

There are no additional TEI structural elements beyond what is described in the ParlaMint schema.

### Linguistic annotation
POS tagging, lemmatization and dependency parsing were done with UDPipe 2 (http://ufal.mff.cuni.cz/udpipe/2) with ukrainian-iu-ud-2.12-230717 and russian-syntagrus-ud-2.12-230717 models.

The Ukrainian NER model was trained and deployed as part of the NameTag service (http://lindat.mff.cuni.cz/services/nametag/), with https://github.com/lang-uk/ner-uk dataset (data folder) used for training. We would like to thank [Jana Strakova](https://ufal.mff.cuni.cz/jana-strakova) for training the Ukrainian NER tool.
