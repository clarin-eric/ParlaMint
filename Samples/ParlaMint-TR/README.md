# ParlaMint directory for samples of country TR (Turkey)

- Language tr (Turkish)


## Documentation

### Characteristics of the national parliament

The current parliamentary system in Turkey is a unicameral system (there have been periods of bicameral systems in the past). The political system is a multi-party system. There are no official “political groups”, however, since 2018 parties make alliances during elections, which may affect their relations in the parliament as well. The current version of the corpus contains transcripts of debates in the last four terms (from 24 to 27) of the Grand National Assembly of Turkey (Turkish: Türkiye Büyük Millet Meclisi), which is approximately 50 million words recorded in  1341 sessions from June 2011 to December 2022.

### Data source and acquisition

The data is scraped from the official web page of the parliament (https://www.tbmm.gov.tr/). The transcripts for this period are published as HTML documents. The data is downloaded using GNU wget, and extracted from the HTML files using Beautiful Soup, and lxml libraries (Python). Except for the default processing built into these libraries (for encoding correction, HTML cleanup), no other preprocessing was applied.

### Data encoding process

The data is first converted to CoNLL-U files using custom scripts (available at https://github.com/coltekin/ParlaMint-TR). The CoNLL-U files created in this step contain all metadata extracted from the original transcripts as custom sentence-level comments. The names in transcripts are matched against the list of parliament members of the corresponding terms  on Wikipedia. For most of the other speakers, the data is entered manually as best as possible.
All linguistic annotations and metadata were recorded in the CoNLL-U format, and converted to ParlaMint TEI (script available in the URL given above).

### Corpus-specific metadata

Current version of the corpus contains the sex, the date/place of birth, and when available Wikipedia, Wikidata and Twitter linksfor regular speakers. The corpus also encodes the constituencies of the parliament members. Changes to party affiliations are documented during the time period of the corpus. Otherwise, the start of party affiliation is left unspecified.

### Structure

Only the standard TEI structure is used.

### Linguistic annotation

Tokenization, and morphological processing (lemmatization, PoS tagging, morphology) was done using TRMorph (https://github.com/coltekin/TRmorph), which provides UD-style analysis. The syntactic analyses were done using the Steps parser (https://github.com/boschresearch/steps-parser) trained on the UD_Turkish-BOUN treebank. The named entities are obtained using  a free RNN-based tool on GitHub  (https://github.com/snnclsr/ner).
