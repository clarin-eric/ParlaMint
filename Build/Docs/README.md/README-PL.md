# ParlaMint directory for samples of country PL (Poland)

- Language pl (Polish)

## Documentation

### Characteristics of the national parliament

The corpus contains the stenographic record of plenary sittings of the Sejm – the lower chamber of the parliament of the Republic of Poland (8th and 9th term of office) and Senate – the upper chamber (9th and 10th term of office). It is composed of two subcorpora: the reference subcorpus, with utterances between 2015-11-12 and 2019-10-31 and COVID subcorpus, between 2019-11-01 and 2022-06-30. Both subcorpora contain 690 files representing individual session days, 228k utterances and 36M words (additional statistics are available at the [NoSketch Engine corpus info page](https://www.clarin.si/noske/parlamint.cgi/corp_info?corpname=parlamint_pl&struct_attr_stats=1&subcorpora=1)).

### Data source and acquisition

The data and linguistic annotation was retrieved from the [Polish Parliamentary Corpus](https://www.clarin.si/noske/parlamint.cgi/corp_info?corpname=parlamint_pl&struct_attr_stats=1&subcorpora=1).

MP metadata (gender, birth date, political affiliations) was retrieved from the websites of [Sejm](http://www.sejm.gov.pl/) and [Senate](https://www.senat.gov.pl/). The speakers were assigned a role of chairman, regular or guest. All MPs were given the role of regular, even if they are speaking as PM, minister or someone else.

### Data encoding process

The data was converted to Parla-CLARIN format from its internal TEI P5 XML representation following the format of the [National Corpus of Polish](http://www.nkjp.pl). The conversion was performed with a set of Python scripts. Some errors in the original corpus were automatically corrected during conversion.

### Structure

Heuristics were used to convert event descriptions and comments into Parla-CLARIN types, mostly based on typical phrases used in the text:

| Event | Type | Typical phrases |
| :---- | :---- | :---- |
| `note` | vote | głosowanie nr |
| | time | przerwa, początek, koniec, wznowienie |
| | debate | na posiedzeniu, przewodnictwo, chwila ciszy, chwila przerwy |
| `kinesic` | applause | oklaski |
| | ringing | dzwonek, sygnał telefonu |
| | laughter | wesołość, śmiech |
| | signal | uderza laską, pokazuje |
| | playback | wyświetla, odtwarza, projekcja |
| `vocal` | noise | gwar, poruszenie, rozmowy na sali, uderza w pulpity |
| | shouting | skanduje, krzyczą |
| `gap` | reason: inaudible | poza mikrofonem, zakłócenia wypowiedzi, w tle, poza nagraniem, brak nagrania |
| `incident` | entering | wchodzi, przybywa, przybycie |
| | leaving | wychodzą |
| | action | wstają, włącza, wyłącza, wręcza, otrzymuje, odczytuje, trzyma, prezentuje, podaje, składa gratulacje |


### Linguistic annotation

The resource contains automatically created annotation of:

- utterance-level segmentation, tokenization and lemmatization produced with Morfeusz2
- disambiguated morphosyntactic description produced with Concraft2
- named entities produced with Liner2
- dependency structures produced with COMBO parser.

Named entities, originally following the model used by the National Corpus of Polish (NKJP), were converted from PPC annotation in the following way:

| NKJP | Parla-CLARIN | Comment |
| :---- | :---- | :---- |
| date | – | ignored |
| geogName | LOC | |
| orgName | ORG | |
| persName | PER | subtypes (forename, surname, addName) ignored |
| placeName | LOC | subtypes (district, settlement, region, country, bloc) ignored|
| time | – | ignored |

