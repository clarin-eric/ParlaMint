# ParlaMint directory for samples of country CZ (Czech Republic)

- Language: cs (Czech)

## Documentation

### Characteristics of the national parliament

The Parliament of the Czech Republic (PCR) consists of two chambers: the Lower House (Chamber of Deputies) and the Upper House (Senate). Joint Czech and Slovak Digital Parliamentary Library contains recordings of the Assemblies from the earliest time of their existence (since the 10th century) until the very last sitting of PCR. Since the establishment of the first parliament of the new Czechoslovak Republic in 1918 the available  documents are much more extensive.

The Parliament works in the periods (terms) between one general election and the next. Regular meetings are organized and they typically take place more than one day. Each meeting has its own agenda and an agenda item is discussed in speeches that can be made at more than one sitting. For every term, there is a “nest”-style site to publish voting records, stenographic protocols, audio files, parliamentary prints, parliamentary documents, resolutions, decisions, interpellations, and biographical data about the members of PCR, boards, committees, delegations (e.g., see the site for the 9th term of the current Chamber of Deputies).

The ParlaMint-CZ corpus contains the stenographic protocols of the Chamber of Deputies from the period  25th Nov 2013 - 18th Oct 2022.

### Data source and acquisition

We scraped the protocols from Joint Czech and Slovak Digital Parliamentary Library where the protocols are available for each meeting. Metadata about persons and organizations was extracted as a database dump (https://psp.cz/sqw/hp.sqw?k=1300). Metadata about members of the government was scraped from the website of the Czech Republic government.

### Data encoding process

1. We scrap the data using a Perl script directly into the TEI format and we
   - split the texts into agenda items discussed in one sitting
   - keep the original page-breaks (<pb>) and the url links in the source data
   - decode dates and times listed in the comments embedded in the texts
   - keep the links to the audio files and detect missing links to the audio files
   - detect the transcription notes given in brackets
2. We download the bibliographic metadata from the website of the Government. It can happen that a person has multiple ids in the original data sources. Therefore we fix it to have only one unique id for each person. The Government website lists dates of birth in persons’ CVs. That helps us to identify persons' records in the parliament database dump and thus the person ids are presented in the format ForenameSurname.birthyear. In addition we interlink the persons to various organizations (e.g., boards, committees, delegations). Compared to the previous version of the corpus, we have merged many organizations and converted the original organizations into events in the merged organizations.
3. We automatically categorize reporters’ notes using keywords and regexp search.
4. We linguistically annotate the texts and compute descriptive statistics from them (e.g., the number of words). We use the format of ParCzech project that is slightly richer than ParlaMint format. We run an XSLT transformation to convert the data into ParlaMint format.

### Corpus-specific metadata

- links to the source data (utterances, pages)
- links to the audio files that correspond to single source pages
- data on not only political parties, but other organizations as well
- records about members of parliament contain links to their personal web sites, facebook and official parliament photo

### Structure

We did not use any TEI structural elements/attributes going beyond what’s described in the ParlaMint schema.

### Linguistic annotation

- For the UD annotation we used UDPipe 2 with no specifics.
- For the NER annotation we used NameTag 2 (model czech-cnec2.0-200831) that classifies named-entities according to a two-level hierarchy of nested 46 named entities types and fourth complex container types (address, person name, bibliography citation, temporal expression). This rich taxonomy contains not only proper names but other entity types as well: <date> and <time> for time expressions, <unit> for units, <num> for different types of numbers, <ref> hypertext links, <email> for email addresses.
- We merged the NameTag categories into the four categories used in ParlaMint (PER/ORG/LOC/MISC). In the ParlaMint-CZ corpus, both categories are available: ParlaMint categories are used for proper names and they are stored in type attribute and the NameTag categories are stored in ana attribute.
