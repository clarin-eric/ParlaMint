# ParlaMint directory for samples of country BE (Belgium)

- Languages: fr (French), nl (Dutch)


## Documentation

### Characteristics of the national parliament

The Belgian Federal Parliament is the bicameral parliament of Belgium. It consists of the Chamber of Representatives (https://www.dekamer.be/) and the Senate (https://www.senate.be).

The current corpus consists of transcripts of the plenary sessions and the committee meetings of the Chamber of Representatives.

The plenary assembly is the assembly of 150 directly elected representatives of the people.

Its main tasks(https://www.dekamer.be/kvvcr/showpage.cfm?section=/pri/competence&language=nl&story=competence.xml) are to monitor government policy and public finance and to control legislation; together with the Senate, the Chamber is responsible for the Constitution and legislation concerning the organisation of the State. For all other legislation, the Chamber alone is competent.

The committees prepare the work of the plenary, which allows it to work more efficiently and quickly. Draft laws and proposals (bills, motions for resolutions, proposals to set up a committee of enquiry, proposals to revise the Constitution) are presented, discussed, possibly amended and voted on. The report of the discussion and the text adopted by the committee are then submitted to the plenary. Besides preparing the legislative work, the committees also exercise control over the government through interpellations and oral questions.

### Data source and acquisition

The source data were obtained by scraping from the parliamentary website (https://www.dekamer.be/). It consists of HTML apparently exported from Microsoft Word.

Further details can be found in the corpus headers and in the table below:

| Period | 2015-2020 |
| :----  |:---- |
| Size | 356 plenary sessions, 1335 committee meetings, 148425 speeches, 32563557 tokens  |
| Language | Mainly mixed French and Dutch (55% French, 45% Dutch, measured in annotated tokens). Several hundreds of German utterances.
| Source format |HTML apparently exported from Microsoft word |
| Data harvesting | Scraping from the parliamentary website (https://www.dekamer.be/) |
| Availability | Public domain; Available from CLARIN website as part and INT Language resource repository.
Handles: http://hdl.handle.net/11356/1388 for the unannoted corpus, http://hdl.handle.net/11356/1405 for the linguistically annotated corpus. |


### Data encoding process

The conversion consists of several steps to transform and enrich the html source.

- The first step was to transform the html to xml, omitting irrelevant html tags and keeping the meaningful elements.
- The second step consists of a set of regex-based search and replace actions on the xml to prepare the transformation to TEI with two XSLT stylesheets.
- In the last step we added a language detection with a Python script, as we discovered that this module did a better job than the original MS Word language recognition in some cases.

The main challenges were related to the unstructured nature of the source data. We had to deal with many inconsistencies in the use of html elements, classes and styles. It was a challenging task to recognize the beginning and ending of the speeches and to separate them into monolingual segments.

### Structure

The dependency parser sometimes trips over long sentences (200 tokens or more, mostly enumerations). They are annotated as follows:
```XML
<gap reason="editorial">
  <desc>Sentence could not be parsed: [sentence]</desc>
</gap>
```

### Linguistic annotation

The linguistic processing involves universal dependencies PoS and dependency relations, lemma, and four-class (PER, LOC, ORG, MISC) named entity recognition. The process for the BE corpus consists of:

- Language identification, consisting of a combination of the Microsoft Office language identification present in the source documents and the python language identification module langdetect (https://pypi.org/project/langdetect/).
- Tokenization (Dutch and French) and Tagging/Lemmatizing (Dutch only) by means of an INT in-house tagger based on Support Vector Machines, which supports TEI input and output.
- Dependency parsing and NER, using the trankit (https://github.com/nlp-uoregon/trankit) universal dependencies pipeline.
- Post-processing to conform to the strict Parlamint Schema, to generate the corpus header from the metadata database and the component files, and to remove incorrectly identified named entities in the first position of sentences for French.
