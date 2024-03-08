# ParlaMint directory for samples of country NO (Norway)

- Language no (Norwegian)

## Documentation


### Characteristics of the national parliament

ParlaMint-NO contains transcripts from 1. October 1998 to 12. May 2022. This includes the transcript from the entirety of the parliamentary sessions from 1998-1999 to 2020-2021 as well as most of the 2021-2022 term.

Norway uses a parliamentary system of government. The parliament consists of one chamber. Before 2009 this chamber was divided into two departments, where one (“Odelstinget”) would sometimes act as a lower chamber, and the other (“Lagtinget”) would sometimes act as an upper chamber. During this period the transcripts are divided into categories of “lower”, “upper” and “joint”. The majority of transcripts fall in the “joint” categories. After 2009 the corpus contains transcripts of plenary meetings.


The electoral system is very rigorous: There is no system for snap elections. There are few mechanisms for the removal of MPs. MPs are also not allowed to resign.


MP’s language form: The transcripts are in the two language forms of written Norwegian: Bokmål or Nynorsk. Members have the option to choose which language form they will be transcribed to  . The form used is therefore not necessarily a reflection of the form closest to the speech of the MP.

### Data source and acquisition

The Norwegian parliament makes its transcripts available as XML through its API. Very little processing was necessary before the start of encoding. In a few cases there were errors in the source XML that needed to be corrected manually. Pre 2016 transcripts are encoded using a different schema than later transcripts. From 2016 the speakers are identified with id codes. Before 2016 only by name.


Metadata on MP were collected from the same API and from Wikidata.

### Data encoding process

We used a combination of XSLT and Python to convert the source XML to ParlaMint. Scripts are on GitHub here. For the Linguistic annotation we used a Spacy model trained on Norsk dependenstrebank (NDT) (Norwegian Dependency Treebank).

### Corpus-specific metadata

No

### Structure

No

### Linguistic annotation

The Norwegian corpus was processed using Spacy and the NB-BERT-base model. Spacy is a popular, open-source Python library for advanced Natural Language Processing (NLP) tasks. It provides powerful tools for text processing and analysis, including named entity recognition, part-of-speech tagging, dependency parsing, and more. SpaCy is designed to be fast, efficient, and user-friendly, making it a popular choice among NLP researchers and developers.

NB-BERT-base is a general BERT-base model built on the large digital collection at the National Library of Norway. This model is based on the same architecture as BERT Cased multilingual model, and is trained on a wide variety of Norwegian texts from the last 200 years. The model supports both Bokmål and Nynorsk, the two written standards of Norwegian. Only one annotation run was necessary, despite the corpus containing text in both.

The fine-tuning was performed on two datasets: the Norwegian Dependency Treebank and NorNe - Norwegian Named Entities. The Norwegian Dependency Treebank is a manually annotated corpus that includes morphological features, syntactic functions, and hierarchical structure. The annotation is done using dependency grammar and contains approximately 300,000 tokens each for Bokmål and Nynorsk. The NorNE corpus consists of the same texts as the Norwegian Dependency Treebank but is additionally tagged with named entities.

Finally, the model was deployed with the aid of a Python script that utilized the Spacy library for language processing and the lxml library for handling XML.