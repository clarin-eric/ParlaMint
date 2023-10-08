# ParlaMint directory for samples of country ES-PV (Basque Country)

- Languages: eu (Basque), es (Spanish)


## Documentation
ParlaMint is a project that aims to (1) create a multilingual set of comparable corpora of parliamentary proceedings uniformly encoded according to the Parla-CLARIN recommendations and covering the COVID-19 pandemic from November 2019 as well as the earlier period from 2015 to serve as a reference corpus; (2) process the corpora linguistically to add Universal Dependencies syntactic structures and Named Entity annotation; (3) make the corpora available through concordancers and Parlameter; and (4) build use cases in Political Sciences and Digital Humanities based on the corpus data.

### Characteristics of the national parliament
The Basque Parliament (Basque: Eusko Legebiltzarra, Spanish: Parlamento Vasco) is the legislative body of the Basque Autonomous Community of Spain and the elected assembly to which the Basque Government is responsible. 

The Parliament meets in the Basque capital, Vitoria-Gasteiz, although the first session of the modern assembly, as constituted by the Statute of Autonomy of the Basque Country, was held in Guernica – the symbolic centre of Basque freedoms – on 31 March 1980. 

It is composed of seventy-five deputies representing citizens from the three provinces of the Basque autonomous community. Each province (Álava, Gipuzkoa and Biscay) elects the same number of deputies. 

URL: https://www.legebiltzarra.eus


### Data source and acquisition
On March 9, 2021, the Basque Parliament Office adopted the decision to share the transcripts of the Basque Parliament (and their translations, when possible) to contribute to the creation of the Basque corpus in the ParlaMint project (Nº 2021/1887).

Minutes of the Basque Parliament, Term X, XI and XII (2015 - 2022).




### Data encoding process

The conversion consists of several steps to transform and enrich the html source.

- The first step was to transform the DOC to xml.
- The second step was to add a language detection with a Python script.

The main challenges were related to detect all the comments. Some of them, short texts comments are stil in the text. 

### Linguistic annotation

Part-of-Speech (PoS) analysis of Basque and Spanish sentences was conducted using 'udpipe2.pl' from the following service: http://lindat.mff.cuni.cz/services/udpipe.

A training process for a multilingual language model, xlm-roberta-large, involving fine-tuning it specifically for Basque and Spanish Named Entity Recognition and Classification (NERC) tasks, was conducted utilizing the following entity tags: PER (Person), LOC (Location), ORG (Organization), and MISC (Miscellaneous).
