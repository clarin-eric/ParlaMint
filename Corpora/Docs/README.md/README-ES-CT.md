# ParlaMint directory for samples of country ES-CT (Catalonia)

- Languages: ca (Catalan), es (Spanish)

## Documentation

### Characteristics of the national parliament

The Parliament of Catalonia is the unicameral legislature of the autonomous community of Catalonia, Spain. The Parliament is currently made up of 135 members, known as deputies (diputats/deputats/diputados), who are elected for four-year terms chosen by universal suffrage in lists of four constituencies, corresponding to the Catalan provinces. For its functioning, the Parliament of Catalonia is divided into bodies: Presidency and Board, Board of Spokespersons', Committees, Plenary Assembly and Standing Committee. The Presiding board is composed of 7 members: 1 president, 2 vice-presidents and 4 secretaries. The President represents the whole of Parliament and is the person in charge of establishing and maintaining the order of the discussions and direct debates in particular during the Plenary Assembly sessions. The Plenary Assembly is the meeting of all the deputies.

The ParlaMint corpus of the Parliament of Catalonia was made of the transcriptions of the Plenary Assembly sessions in which the debates referring to the following list of functions have taken place. The Parliament of Catalonia:

- Elects the President of the Generalitat de Catalunya.
- Pass the Catalan legislation in the business of its competence.
- Pass the Budget of the Autonomous Community of Catalonia.
- Controls the action of the Government of Catalonia and the autonomous agencies, public companies and all other bodies answerable to it.

Catalan and Spanish are the languages most used by the deputies, although Aranese (a dialect of Occitan) is also used.

### Data source and acquisition

The transcriptions of the Plenary Assembly sessions were provided by the Departament d’Edicions del Parlament de Catalunya. The data was provided in two moments: in March 2021, for 200 files of transcripts between 2015 and 2020, and in September 2022, for 97 files of transcripts between 2021 and late August 2022. Each source file was named with the date, the number of the session and the number of the meeting. A session is meant to be the working time to cover a particular agenda. A meeting is meant to cover the session held in a single day. Some manual correction was done for the name of the second pack of files that did not follow the same naming as this encoding was used to name the files of the corpus.

The source files were provided as .docx files. The transcription of the speeches was delivered with additional information encoded in different style's metadata and transcriber's annotations in the form of notes.

Different Word styles were used by transcribers to encode information of the nature of the texts (for instance: Agenda, Summary, Introduction, Speeches); of the name of the speaker whose speech follows; and of the language of the speech (as identified by the spelling checker).

The notes that contained textual information about interruptions of the speech, their nature (applauses, noise, etc.) were extracted after a thorough analysis of the data, processed first as Panda's matrices and then converted into TEI-conformant Parlamint XML files. Note that first and second packs of documents differed in the format structure with the consequent refinement of the conversion python scripts.
Data encoding process

The docx files were parsed to create data matrices with Pandas. Data matrices were then converted into TEI-ParlaMint xml files. In addition to Pandas Xpython-dox was used to read the xml contained in the docx files, and xml.etree.ElementTree was used to read and build xml trees. More information about the analysis process is available in Pisani (2022) and  the documented scripts are publicly available in https://github.com/IULATERM-TRL-UPF/ParlaMint_ES-CT.

### Corpus-specific metadata

There is no metadata available going beyond what’s common for all corpora.

### Structure

There are no additional TEI elements beyond what’s described in the ParlaMint schema.

### Linguistic annotation

After testing different NLP libraries and pipelines that processed Catalan, lemmatization and PoS tagging was done with FreeLing PoS tagger v 4.2 (Padró & Stanilovsky, 2012) because it delivered better results. To use the same script, we also used FreeLing for annotating the Spanish parts. Nevertheless, tags and morphosyntactic descriptions were mapped to UD PoS tags and msd descriptions to follow ParlaMint guidelines. FreeLing was also the tool used to identify named entities. No special name mapping was needed for NER.

For dependency relations annotation, the Catalan and Spanish modules (version 220711) of the Universal Dependencies 2-10 models were used via the API to the REST service available in http://lindat.mff.cuni.cz services. In order to make it compatible with the FreeLing segmentation and tokenization, the input to the parser was the vertical format as produced by FreeLing.

### References

- Lluís Padró and Evgeny Stanilovsky. (2012) FreeLing 3.0: Towards Wider Multilinguality. Proceedings of the Language Resources and Evaluation Conference (LREC 2012) ELRA. Istanbul, Turkey. Tool info:  https://nlp.lsi.upc.edu/freeling/
- Marilina Pisani. (2022) Árboles, Gráficos y Matrices de Datos. Codificación en TEI de un Corpus de Interacciones Parlamentarias con Python. Final Master Thesis supervised by Núria Bel. Máster en Humanidades y Patrimonio Digitales. Universidad Autónoma de Barcelona.
