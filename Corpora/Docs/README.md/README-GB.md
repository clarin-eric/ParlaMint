# ParlaMint directory for samples of country GB (Great Britain)

- Language en (English)


## Documentation

### Characteristics of the national parliament

The Parliament of the United Kingdom comprises two houses, commons and lords. The corpus contains proceedings from the house of commons (lower) and the house of lords (upper) between 5th January 2015 to 21st July 2022. The corpus itself contains 670,912 contributions (utterances) from 1,951 members of parliament and peers across 2,209 meetings. The total size of the corpus is roughly 135 million words.

### Data source and acquisition

The source data for the corpus was downloaded from the UK Parliament’s Hansard API. Data for each houses’ meetings was retrieved by date in XML format. Metadata was cross-referenced from this source XML and the Parliamentary Open Data API was used to retrieve data, in RDF (Resource Description Framework) format, on both members and parties.

### Data encoding process

The encoding process was performed primarily using stylesheets (XSLT). To support this a processing pipeline with support for various corpus specific extension functions was created, called Kjede. The extensions functions support downloading of data, automatic ID reference extraction and downloading of associated metadata and heuristics to clean text and where possible identify kinesics and incidents within the source documents. The processing pipeline also contains a CoreNLP dependency to allow TEI encoded data to be annotated. A simple command-line application, with usage instructions, is available to process and parse further data if necessary.

### Corpus-specific metadata

Beyond the standard name and party affiliation for each member of parliament, additional information was also retrieved and encoded into TEI format. Where available members official portrait photos were included as figure links so they can be displayed wherever the corpus is used. All links to official contact information on the UK government websites are also included. Finally, where available, members' social media information (Facebook, Twitter handles etc.) were included.

### Structure

Utilising figure elements for member photos was added at our request to the ParlaMint schema.

### Linguistic annotation

Stanford CoreNLP was used for linguistic annotation. This by default provides part-of-speech tags in PennTreeBank format. These were converted to universal dependency POS tags based upon the mapping available on the UD website. All remaining morphological features and dependency parse graphs are already labeled using UD labels and were simply encoded into the TEI ParlaMint format.
