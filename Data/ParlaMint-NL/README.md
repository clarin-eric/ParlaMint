# ParlaMint directory for samples of country NL (The Netherlands)

- Language nl (Dutch)

## Documentation

### Characteristics of the national parliament

In the Netherlands, a bicameral multi-party legislative system is in place, with two houses. The Upper House is made up of 75 members, and the Lower House is made up of 150 members. The corpus contains documents from both the Eerste Kamer (Upper House) and the Tweede Kamer (Lower House). The corpus totals 6100 files, where 701 documents belong to the Upper House and 5399 documents are from the Lower House.

In the source files, documents from the 'Eerste Kamer' are denoted by 'eerstekamer' in the filename, and the 'Tweede Kamer' files are denoted by 'tweedekamer' in the filename. All files in the corpus have the date of the meeting as their filename, and if there were multiple meetings on one day, a suffix with the number of the meeting is added to the filename.

The documents in the corpus range from 16-04-2014 to 12-07-2022, with the reference part of the corpus ranging from 16-04-2014 to 30-09-2019, and the covid part of the corpus ranging from 01-10-2019 till 12-07-2022. The corpus contains 6100 documents.

The dominant type of meeting in the corpus is the debate type.  Besides this the corpus also contains several documents regarding ceremonies and commemorative events, which are marked with their respective types in the TEI files themselves. To keep as much information from the original files, the title of the meeting (if there was one) is added to the text section of each file inside of a ‘note’ tag.

### Data source and acquisition

The parliamentary documents used for the construction of the corpus were already available in XML format through the 'officielebekendmaking.nl' system which has an ftp server containing the relevant files (bestanden.officielebekendmakingen.nl), so the xml files from 2015-2020 were downloaded from this server.

As the downloaded documents did not include specific metadata for speakers, this had to be gathered from different sources. The documents from the ftp server did include the names of speakers, so we had to acquire more detailed metadata for each of the speakers so that we could include that into the root file of the corpus. We acquired the metadata for the speakers through different sources. For speakers from the parliament we used the Opendata API (https://opendata.tweedekamer.nl), the official records of the Eerste Kamer (https://www.eerstekamer.nl/alle_leden) and the official records of the Tweede Kamer(https://www.tweedekamer.nl/kamerleden_en_commissies/alle_kamerleden). As this only contained information on current members, information about members that was still missing was retrieved from Wikipedia, for most guests very limited metadata is available.

The obtained metadata was automatically linked with the speakers annotated in the XML documents through a Python script. There were some spelling mistakes with names in the XML files which had to be manually corrected before they could be linked to the appropriate metadata record.

For the second phase of the ParlaMint project, a substantial amount of metadata was added for the speakers. 541 out of 588 speakers now have information on their date and place of birth, with the birthplace also having a geographic link via GeoNames. Apart from this 559 of the 588 speakers also have a WikiPedia page linked to them, that was automatically retrieved using WikiData. Some sanity checks on the dates of birth were performed to ensure correct links and deal with ambiguity. For 309 speakers, information on their membership to one of the two chambers was also automatically added.

The metadata was also updated to contain the information on the 12 ministries currently existing in the Dutch government, with their respective affiliations for the head of that ministry and the secretary of that ministry linked to the person metadata.

Apart from the updates to the speaker metadata and the addition of the ministries, the party list was updated with new parties, and wikipedia links were also added to the parties.

After the collection of the data, filtering of the types of documents that should be included into the final corpus took place. Because of a lack of a unified format in the voting sessions in the Parliament, these voting sessions were not included.

The endings and openings of meetings were also removed from the dataset, as they included no actual speeches but just a time of opening  and closing, the ‘regeling van werkzaamheden’ were kept, as they often contained discussions between members about the contents of meetings.

### Data encoding process

Because the source texts were already in xml format, the conversion to the TEI format was relatively straightforward. The conversion of the XML files was done using the Oxygen XML editor. The conversion was done in two passes.

The first pass converted the data into the TEI format, removing incompatible pieces of the original format or moving them into the right place according to the TEI standard.  This script was also used to clean the data, as there were some unicode characters in the data that were causing some problems later on in the conversion. After the XSLT scripts, the metadata was linked to the speakers in the files with a Python script.

The first XSLT script converted the original XML file into the TEI format, the second conversion script was run after this to collect the metadata from the first converted version which had to be included in the file header.

(such as the number of words in the file, the number of `<seg>` tags, etc), as well as adding the right ID's to each seg/u element. The approach of doing the conversion in two phases was chosen because it turned out to be difficult to simultaneously filter the original file and collect the resulting counts for the result. The XSLT scripts that were used for the conversion, as well as the python scripts for collecting metadata and a notebook showing the conversion process are available on github.
(https://github.com/RubenvanHeusden/ParlaMintNLConversionCode).

### Corpus-specific metadata

For a decent number of the parliament members their time in office has been added to the speaker metadata. Regarding the government level metadata, information about the oppositions/coalitions for the different governments is also available in the corpus root files.

### Structure

No additional structural elements/attributes going beyond the ParlaMint Schema were used.

### Linguistic annotation

(Largely similar to the Linguistic Annotation process of the Belgian/French Team)

The linguistic processing involves universal dependencies PoS and dependency relations, lemma, and four-class (PER, LOC, ORG, MISC) named entity recognition. The process for the NL corpus consists of:

- Tokenization (Dutch) and Tagging/Lemmatizing (Dutch only) by means of an INT in-house tagger based on Support Vector Machines, which supports TEI input and output.
- Dependency parsing and NER, using the trankit (https://github.com/nlp-uoregon/trankit) universal dependencies pipeline.
- Post-processing to conform to the strict Parlamint Schema, to generate the corpus header from the metadata database and the component files.

#### Performance of the Named Entity Recognition system

As part of the project, the performance of the Named Entity Recognition system that was used to annotate the meetings with NE labels was evaluated. For this evaluation, roughly 2000 sentences were manually annotated. These sentences contained about 1800 tokens that were labeled as (part of) an entity. For evaluation the BILOU format for annotating NER was used. For the scoring of the model the precision recall and F1, weighted over classes, were reported. The model achieved a precision of 86%, recall of 85% and an F1 score of 86%. When investigating the model’s performance it was found that the MISC category proved difficult for the model to classify, although the amount of samples for MISC in the evaluation dataset was also quite limited, so this low performance may be taken with a grain of salt.

