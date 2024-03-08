# ParlaMint directory for samples of country HU (Hungary)

- Languages: hu (Hungarian)

## Documentation


### Characteristics of the national parliament

The National Assembly is the unicameral legislative body of Hungary, with 199 members, 12 advocates for nationalities and a chairman.

The current, second version of the ParlaMint-HU corpus contains the minutes of the National Assembly from 2014 to 2022, comprising terms 7, 8, and the spring session of term 9 of the Third Republic. The documents of the corpus thus range from 2014-05-06 to 2022-06-14, containing the official textual transcriptions of 514 sittings in this period.

While the first version of ParlaMint-HU was confined to interpellations, the present corpus includes all types of speeches and verbal exchanges of the National Assembly. These equal to 104,115 speeches, comprising 1,540,325 sentences and 32,353,437 tokens (27,533,236 words and 4,820,201 punctuation marks).

### Data source and acquisition

The source data were downloaded from the official website of the Hungarian National Assembly (https://www.parlament.hu/) as txt files.
Metadata were gathered manually from official sources, primarily the website of the National Assembly. Other sources include Magyar Közlöny (the official periodical of Hungary that publishes new laws, appointments, etc.), parties’ official websites, and various newspapers (e.g., for dates of resignations).

### Data encoding process

We manually normalised the texts before processing. Speakers’ names were unified and are included in their current form used for public appearances. This is in order to avoid having false doubles (due to name change) or forms that are official for the persons but are not publicly used.

Some speeches between 2014-2022 were held in languages other than Hungarian. These are the languages used by the representative of the German nationality in Hungary, and by advocates of other nationalities (Slovakian, Slovenian, Serbian, Bulgarian, Ukrainian, etc.) living in Hungary. In total, we identified 213 such segments. These segments were not linguistically analysed.

The presiding chairman’s technical remarks are marked with ELNÖK ‘president’ as the speaker in the original txt. The exact person behind this role could not always be detected based on the text itself, therefore, we needed to collect the chairmen for all sessions manually. To do this, we used the data available on the official website of the National Assembly.

Data processing and encoding was carried out using Python scripts. Each source txt already covered one sitting, so we kept this structure. For extraordinary sittings, a separate file was created. We split the text into speeches, and the speeches into segments and notes. For (seg), the paragraphs of the original texts on the official National Assembly website were used. Speakers and transcription notes were detected, and the latter were categorised into TEI note types using regular expressions primarily. Occurrences of double starting or ending parentheses were uniformly changed to single parentheses. Segments were given a unique id, and id-segment pairs served as input for HuSpacy, the linguistic analyser. HuSpacy’s output was converted into the required XML structure using another Python script. As the XML generator worked required the source files to follow a quite rigid format, input files had to be formatted accordingly before encoding.

### Corpus-specific metadata

We decided not to use any part of the first ParlaMint-HU corpus and instead created everything new. We collected each MP’s committee positions for the period covered by the corpus, and ’party joining dates’ in case of ongoing party affiliations that have started before 2014. For judges and individuals operating irrespective of parliamentary terms, we added the start dates of their relevant appointments. Whenever possible, we included a detailed version of secretaryOfState’s role names in English and Hungarian, as these are highly specific and variable across parliamentary terms and even under the same ministry. For each sitting in each separate file, we provided links to the video and the text of that sitting available on the National Assembly website.

We did not add any roles to the list provided in the project. However, we would like to note to future users of the corpus that the ’junior notary/secretary’ and ’senior chairperson’ roles (both only relevant on the first day of each parliamentary term) are only included as notes, and were otherwise merged into ’secretary’ and ’chairperson’.

In total, we collected metadata for all 426 speakers appearing in the Hungarian National Assembly between May 2014 and June 2022, representing 91 organisations. We decided not to indicate speakers being commissioners of the state and/or members of parliamentary subcommittees.

### Structure


We did not use any TEI structural elements/attributes going beyond what’s described in the ParlaMint schema.

### Linguistic annotation

For the linguistic annotation of the corpus we used HuSpaCy (https://github.com/huspacy/huspacy), an industrial strength language processing pipeline for Hungarian. We chose this solution as the models in HuSpaCy have the highest accuracy among the language processing pipelines available for the Hungarian language, and because HuSpaCy contains all the modules needed in the ParlaMint linguistic annotation process and could create the required output. We used the CNN-based hu_core_news_lg model, achieving a good balance between accuracy and processing speed. This default model provides tokenization, sentence splitting, part-of-speech tagging (UD labels w/ detailed morphosyntactic features), lemmatization, dependency parsing and named entity recognition as well.

HuSpaCy was able to create all the four categories of named entities required by ParlaMint II. A small modification was applied to the output of the parser: named entities consisting of only one token were labelled with `1-<category>` instead of `B-<category>`.

In some cases the NER output was erroneous and needed manual correction as it did not pass the validation. Otherwise, HuSpaCy provided us with a largely accurate linguistic analysis of the data.
