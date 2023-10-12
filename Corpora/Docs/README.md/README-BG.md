# ParlaMint directory for samples of country BG (Bulgaria)

- Language: bg (Bulgarian)

## Documentation

### Characteristics of the national parliament

The Bulgarian Parliament is unicameral. The political system is a multi-party system.

The corpus in its first phase contains plenary meetings from 2014-10-27 to 2020-07-31 and includes 717 documents or 19,096,761 words. The new data includes 2020-09-02 till 2022-07-29. These data have 204 documents.

The challenge with the new data was the fact that in 2021 there were three elections for Parliament - thus many parliaments with short lives.

### Data source and acquisition

The data was downloaded from the official page of Bulgarian National Assembly manually since the site does not allow the whole data to be automatically downloaded. Thus, it took about 2 months to get the data for 5 years (2015-2020) and 1 month to get the data for the last two years (2020-2022). The minutes for each day are represented in a single html file which was easy to convert to XML.

### Data encoding process

The conversion was performed in an incremental way. Initially, the data was converted into basic TEI XML and uploaded into the CLaRK system. Then, the Parla-CLARIN DTD was used for validation. However, this turned out to be too permissive, so additional constraint schemata were applied. Within CLaRK the conversion was done with the help of constraints (as implemented rules) and regular grammars for joining some elements. The speaker and incident data was extracted, classified and returned back into the texts with the appropriate features added.

For the speakers (mainly MPs) we collected information from the website of the parliament. Then the data was converted into XML person format defined by the Parla-CLARIN guide. For the speakers that were not part of the parliament at the time of corpus creation, we collected the data over the web (mainly from Wikipedia, websites of ministries, agencies and other institutions). For some of the guest speakers we ended up with very limited information.

One problem that required some manual work was the connection between the record of the speaker names and the speaker records. The main problems were misspellings of their names and ambiguities between the names.

For the TEI header component we prepared a parameterized version which was inserted into each meeting report document. Then the parameters were replaced with the actual data from the original XML document.

After the validation of each document within the CLaRK system with respect to the Parla-CLARIN dtd, the documents were exported and validated with respect to the Parla-CLARIN Relax NG Schema. The validation was performed with the help of Oxygen XML Editor. Some errors were found during this validation.

In Phase 2 of the project the previous part was improved with respect to the TEI format and metadata, errors were corrected, while also compiling the new data. This time github was extensively used for validation.

### Corpus-specific metadata

In addition to the actual debates there are Excel tables representing the voting results during the day. The voting results are not represented in the current version of the corpus, but they are downloaded and incorporated into the initial XML document for further processing and incorporation within the corpus.

### Structure

The corpus followed strictly the TEI elements/attributes that were needed at this stage.

### Linguistic annotation

For annotating the Bulgarian corpus the CLASSLA-Stanza pipeline (https://pypi.org/project/classla/) was used. Thus, it follows the UD morpho-syntactic schema. The NER module includes the traditional NEs: Person, Location, Organization and Misc. We would like to thank Nikola Ljubešić for training and running the tools.
