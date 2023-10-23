# Samples of the ParlaMint-SE corpus

- Country: SE (Sweden)
- Languages: sv (Swedish)

## Documentation

### Characteristics of the national parliament

The Swedish Parliament (Riksdagen) is unicameral with a multi-party political system. The corpus contains the stenographic record of plenary sittings of the sessions of the Swedish (Riksdagens protokoll). The corpus is composed of two subcorpora: the reference subcorpus, with sessions between 2015-09-15 and 2019-10-31 and the COVID subcorpus, between 2019-11-01 and 2022-05-07, which covers all full meetings of Riksdagen during the years 2015-2022. The corpus contains 938 .xml files and 938 .ana.xml files representing individual session days, 96,745 speeches and 29,197,567 words.

### Data source and acquisition

The data was acquired from the Riksdagen corpus repository https://github.com/welfare-state-analytics/riksdagen-corpus hosted on GitHub and maintained by the Westac project https://www.westac.se/en/. The data source of that project for the era 1990-2022 is Riksdagens Öppna Data (sv. for Riksagen’s Open Data) https://data.riksdagen.se/ .

### Data encoding process

The Riksdagen corpus stores their data in the Parla-Clarin format. This was used as a baseline, and adjustments were made to accommodate the stricter guidelines of the ParlaMint schema. The conversion was implemented in Python.

### Corpus-specific metadata

Our corpus metadata did not require any extension to the original proposal.

### Structure

Our corpus did not require any extension to the original proposal.

### Linguistic annotation

For the linguistic annotation process, we used the Sparv Pipeline https://spraakbanken.gu.se/sparv/ by Språkbanken Text https://spraakbanken.gu.se/ . As the output format of Sparv is different from the ParlaMint format, some extra processing was done in Python.

Additionally, some missing functionality was filled in with the Swedish BERT NER tool https://huggingface.co/KB/bert-base-swedish-cased-ner released by Kungliga Biblioteket https://www.kb.se/ . The NER tool did not support multi-word entities, so a heuristic was employed (adjacent named entities were merged if they had the same type).
