# ParlaMint directory for samples of country IS (Iceland)

- Language is (Icelandic)

## Documentation

### Characteristics of the national parliament

The corpus contains the minutes of the National Parliament of Iceland for the period 20.01 2015 - 16.06.2022. The Icelandic Parliament is unicameral with a multi-party political system.
Data source and acquisition

The data and the metadata was downloaded from the parliament website, www.althingi.is.  Each speech is contained by one html-file. For each speaker there are two html files, one containing information such as name and date of birth while the other one contains information about party affiliations, to which constituency he or she belonged and status (MP or minister) for different periods. The speeches were not manually corrected.

### Data encoding process

The metadata was all stored in various database tables while the texts for the speeches, that had been retrieved from html-files, were saved as txt-files. A special python-script was created from scratch to create the xml-files, with the help of TeiWriter, a python script that was made specially for the compilation of The Icelandic Gigaword Corpus to convert python dictionaries to xml-files. The script reads the metadata from the database and inserts in a dictionary item, that is a representation of the TEI-header as described by the ParlaMint scheme. The script reads the speeches from the text file and looks for special marks that indicate interruptions of any kind, and creates a dictionary item for each utterance. The dictionary items are then sent to TeiWriter that writes out the xml files, both for the TEI and the teiCorpus elements.

To create the annotated files, the xml-files were sent to three different python scripts. The first script tokenized the content of `<seg>` and split the text into sentences and tokens. Each token was lemmatized and pos-tagged. The second script read the xml-files with the tokens and sent the text through the Icelandic implementation of UD-pipe. The last script used a BERT-model to add NE-tags (https://github.com/bennigeir/NER). Finally a script was used to update the statistics (`<tagsDecl>` and `<extent>`) and inserted information in `<respStmt>` and `<appInfo>` for the annotated files.

### Corpus-specific metadata

Four of the taxonomies used in ParlaMint-IS are corpus-specific.
- Information about constituencies are listed and then referred to in the affiliation-tag for each speaker.
- There are eleven categories listed (such as Industries and Economic Management) and each one has several subcategories.
- Topics discussed are listed. Each topic refers to one or more of the categories mentioned above. Each speech (u-tag) refers to one topic (if applicable).
- All the ministries are listed and then referred to in the affiliations of those speaker that were minister during the period covered by the corpus.

Since each speech is located in a special html-file on the website, we added a source attribute to the u-tag, where the value is the url to the speech.

### Structure

We did not use any TEI structural elements/attributes going beyond what’s described in the ParlaMint schema.

### Linguistic annotation

For the UD annotation we did not use any specific linguistic annotation. The text was, on the other hand, also pos-tagged with ABL-tagger (http://hdl.handle.net/20.500.12537/98). The results it gives are sometimes more detailed, and not necessarily the same as the UD-pipe, since the accuracy of the ABL-tagger is quite higher. The tagset used is available at http://hdl.handle.net/20.500.12537/39.
