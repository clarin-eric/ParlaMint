# ParlaMint directory for samples of country IT (Italy)

- Language it (Italian)

## Documentation

### Characteristics of the national parliament
The Italian Parliament is the bicameral parliament of the Italian Republic . It consists of the Senate (www.senato.it) and the Chamber of Deputies (www.camera.it).

The current corpus consists of transcripts of the plenary sessions of the Senate.

The plenary assembly is the assembly of 315 directly elected Senators. The elected senators must be over 40 years of age and are elected by Italian citizens aged 25 or older.

In addition to the elected senators, the former Presidents of the Republic are part of the Senate as senators for life, by right and subject to waiver, as well as up to five senators appointed autonomously by the President of the Republic for very high merits in social, scientific, artistic and literary fields.

Senators organise themselves into parliamentary groups according to the political party they belong to. A mixed group is foreseen for those senators whose formations do not reach the consistency of at least 10 members and for senators not enrolled in any component. Senators representing linguistic minorities can form a Group composed of at least five members. Senators for life, in the autonomy of their legitimacy, may not become part of any Group.

### Data source and acquisition

The covered time-span ranges from March 15th 2013 (beginning of 17th legislative term) to September 20th 2022 (end of 18th legislative term). The whole corpus consists of 1388 files, one for each plenary session.

The sessions in the corpus are marked as belonging to the COVID-19 period (starting with November 1st 2019, 304 files), or being ”reference” (before that date, 1084 files).

The documents for the requested periods were made available in bulk by the Information Technology Service of the Senate. The same documents can also be retrieved directly from the website of the Senate. The format of the original corpus is HTML.

Starting from 2018 the transcripts of the plenary sessions of the Senate are also published in the AkomaNtoso XML format. In order to uniformly cover all the required timeframe (including years before 2018) the HTML format was chosen as the source format for the whole corpus.

HTML files contain in fact additional annotations (for speeches, speakers) expressed by means of proprietary XML tags “embedded” in the HTML annotation.

Before the encoding, the original HTML corpus was pre-processed by extracting the “embedded” XML annotation and discarding (almost) every HTML annotation thus obtaining an intermediate XML corpus. Only paragraph `<p>` and italic `<i>` HTML tags are kept as they annotate segments and (potentially) incidents.

The “embedded” XML annotation of the original HTML corpus includes segmentation into utterances (tag `<INTERVENTO>`) and speaker annotation (tag `<ORATORE>`). Such original segmentation into utterances is kept in the ParlaMint-XML encoding. A small fraction (68/1388) of the obtained XML files required manual correction in order to force XML well-formedness for their subsequent DOM parsing.

In the future, the intermediate step of extraction of the “embedded” XML from HTML might not be needed given the availability of the source documents in AkomaNtoso XML.

From the original HTML corpus, only the transcripts of the speeches are kept for subsequent ParlaMint-XML encoding (tag `<RESSTEN>`, i.e. Resoconto Stenografico). Possible annex documents for the session are discarded in the current release.

Metadata about members of the Senate and on the political groups were obtained from the open data portal http://dati.senato.it.

### Data encoding process

The corpus was encoded in ParlaMint format by developing specific Java code to read the input documents and data, transform them in the required structure and write the ParlaMint-XML output.

The input was made of the aforementioned source “embedded” XML and of structured metadata tables in tsv (tab separated values). The reading, transformation and writing were implemented by means of Java XML DOM (Document Object Model) manipulation.

For the encoding of the corpus root (ParlaMint-IT), the required metadata about speakers and political groups were automatically obtained by querying the Senate Data portal dati.senato.it which exposes a SPARQL endpoint, and appropriately transformed in the target structures by means of DOM objects. For speakers who are not members of the Senate (mostly members of the government in charge who could either be members of the Chamber of Deputies or not members of Parliament at all) manual edit of their metadata was required by accessing their pages from the Senate website.

The rest of the corpus root is composed and structured by hard-coding in the Java source code the desired output for the different XML elements.

The encoding of the document corpus was accomplished by parsing into a DOM the input “embedded” XML documents, transversing the documents and applying the appropriate transformations from the source elements to the target elements.

Text not belonging to speeches is mapped into note elements. If possible, the type of the note is assigned through its “type” attribute. Note types used are “role”, “speaker”, “time”, “summary”, “voting”.

Incident annotations are taken among the italic `<i>` HTML annotation in the source files based on a heuristic on the content of the tagged text (list of keywords triggering indicent text). In a similar way the type of incidents (kinesic, vocal, incident and their type attribute) are annotated based on a heuristic analysis of their textual content.

The identifiers of the speakers (which are available in the source documents) are mapped to the identifiers used in the corpus root and kept consistent.


### Linguistic annotation

The linguistic annotation (sentence splitting, tokenization, parts-of-speech tagging and dependency parsing) was performed using the Italian model (italian-isdt-ud-2.5) of the STANZA pipeline (https://stanfordnlp.github.io/stanza/index.html).

The Named Entity annotation, differently from the previous versions of the corpus, was also carried out with STANZA using the newly available FBK Italian model (https://stanfordnlp.github.io/stanza/ner_models.html), which assigns three standard named entity tags, i.e. Person, Organization, Location.

Using the same pipeline for both linguistic annotation and NER allowed to avoid error-prone annotation alignment steps.