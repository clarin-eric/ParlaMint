# ParlaMint directory for samples of country FR (France)

- Language fr (French)

## Documentation

The corpus contains the minutes of public debates of the Assemblée nationale (National Assembly), which is the lower chamber of the bicameral French Parliament. All debates taking place within the 15th legislature of the Fifth Republic are included in the corpus, which covers the time period: June 2017 - March 2022.

Sittings (one or more per day) are held within an ordinary session, usually from October to June, except for the first year of the legislature, when they may start earlier. There are also extraordinary sessions in July and September. In addition, the two chambers (National Assembly and Senate) may gather within a Congrès du Parlement (Parliament Congress), for instance to listen to a statement of the President of the Republic.

The whole corpus contains 1562 files (approximately 50M words).

### Data source and acquisition

Our corpora are based on the open data available from the Assemblée Nationale’s site: http://data.assemblee-nationale.fr/

The source data is downloaded as a set of XML files encoded in an undocumented format.

### Data encoding process

The source data is converted to the ParlaMint format by means of a set of Python scripts and XSL transformations. A pipeline allows to generate a corpus based on initial and end sitting dates.

The scripts are derived from a previous version (independent of the ParlaCLARIN format), called TAPS, which was also TEI-based.

### Corpus-specific metadata

Some government roles, specific to France, have been added to the ParlaMint schema, e.g.:

- https://en.wikipedia.org/wiki/Minister_Delegate_(France)
- https://en.wikipedia.org/wiki/Minister_of_State
- https://en.wikipedia.org/wiki/Secretary_of_state
- Persons are described with additional metadata: birth place, occupation…

In France, for the affiliation of each MP, the relevant category is “parliamentary group” (as opposed to “political party”), since the affiliation to these groups may change during a legislature (as well as their naming).

Also, in France there is not an official concept of coalition. Instead, each group is generally clearly positioned as part either of the majority or the opposition.

### Linguistic annotation

The processing is carried out by means of a Python script combining an XML parser module with the Stanza NLP package (Qi et al. 2020; https://stanfordnlp.github.io/stanza/index.html). The annotation pipeline includes tokenization, sentence segmentation, lemmatization, UD part-of-speech and morphological tagging, UD dependency parsing and named entity recognition.
