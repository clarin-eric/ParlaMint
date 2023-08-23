# ParlaMint directory for samples of country LT (Lithuania)

-  Language lt (Lithuanian)

## Documentation

### Characteristics of the national parliament

The Seimas of the Republic of Lithuania (Lithuanian: Lietuvos Respublikos Seimas), or simply the Seimas (Lithuanian: \[sæ̠iˑmɐs\]), is a unicameral parliament of Lithuania. Its 141 members are elected for a four-year term, with 71 elected in single-member constituencies, and 70 elected in a nationwide vote based on open list multi-member proportional representation. Only parties are allowed to nominate lists of candidates for multi-member tier. However, non-party members (celebrities, important non-partisan politicians etc.) are usually included into the lists. Citizens not belonging to parties (independents) are allowed to nominate themselves in single-member districts. Consequently, a sizable share of MPs are independents (do not formally belong to parties). Therefore, parliamentary party groups (factions) are used for identifying MPs’ political affiliations in the corpus.

All the proceedings (recordings and transcripts of the debates) on the Seimas floor and related documentation (agendas, bills (including various supporting documentation) considered and minutes of the proceedings) as well as all the proceedings of the Board of the Seimas, committees and commissions are available for download and inspection from the Seimas web portal (www.lrs.lt). The most politically visible and commented on by the media are the Seimas floor debates. Therefore, transcripts of these debates constitute the texts included into the corpus.

### Data source and acquisition

Transcripts of the Seimas floor debates (in digital format) are freely available from the official website of the Seimas (www.lrs.lt). Data was automatically scraped from the official document search site of the Seimas: https://e-seimas.lrs.lt/portal/documentSearch/lt. We entered the period (2012-11-16 – 2020-11-10), and the type of document (“Stenograma”) and the search engine retrieved a total of 876 transcripts in MS Word (*.doc / *.docx) format. The list was then manually cross-checked with the list available on the main [Seimas website](www.lrs.lt/sip/portal.show?p_r=35727) and no additional transcripts were found. Thus, the corpus consists of 876 transcripts of the Seimas floor debates. These documents have a total of 244835 speeches (with 390179 segments in them) and 14780871 word units in aggregate.

Timespan of the corpus - the last two terms of the Seimas: 2012-11-16 - 2016-11-10 and 2016-11-14 - 2020-11-10.

The retrieved files had to be converted into textual data files (plain text format) to be processed with text analytic tools. It should be noted that the entire data set is in Lithuanian; therefore, it was essential to preserve the UTF-8 encoding for further processing. It was a bit of a challenge as the downloaded files were in different formats, encodings. Therefore, we had to unify the data so that it could be processed automatically. Two converters were used: MultiDoc Converter (www.multidoc-converter.com/en/index.html) and EmEditor (www.emeditor.com).

Metadata about MPs were collected from the open data portal of the Seimas: www.lrs.lt/sip/portal.show?p_r=35391&p_k=1. However, some of the information was not available in these metadata (for example, MPs’ age) and was collected from the main Seimas web portal (www.lrs.lt) and other sources (this also involved some manual work). In total, 310 MPs were detected in the corpus and metadata for them generated.

### Data encoding process

The corpus was encoded into the ParlaMint format using custom Python scripts that read the input text documents (transcripts) and data (metadata about the MPs), transform them into the required structure, and output the ParlaMint XML. The corpus root (ParlaMint-LT) is composed and structured by hard-coding the desired output for the various XML elements in the Python source code. The corpus documents were encoded by parsing the input "embedded" XML documents into a DOM, traversing the documents, and applying the appropriate transformations from source to target elements. The speaker identifiers (which are available in the source documents) were mapped to the corpus root identifiers and kept consistent.

### Corpus-specific metadata

In general, a standard set of metadata was used for the corpus. However, it has to be noted that MP metadata contain detailed mapping (including temporal) of their political affiliations and positions within the Seimas internal institutions. At the same time, the other speakers (not MPs) are not described by any elaborate set of metadata. The only information available about them is that they are guest speakers.

### Structure

Mostly, structural elements/attributes included into the ParlaMint Schema were used. However, we added two role attributes (`@role`) to the organisation `<org>` element within the list of organizations element `<listOrg>` of the schema: `@role="conferenceOfChairs"` and @role="boardOfParliament". These two roles refer to governing institutions of the Seimas that are responsible for agenda formulation of the Seimas floor debates and solving/debating issues that arise in the proceeding of the Seimas (these two functions being only the most important ones). The Conference of chairs of parliamentary factions (@role="conferenceOfChairs") consists of chairs of parliamentary factions (party groups) as well as other representatives form parliamentary factions proportional to their size (roughly, 1 member of the Conference of chairs represents 10 members of a parliamentary faction). The Board of the Seimas (@role="boardOfParliament") is formed by MP voting. The Speaker of the Parliament (elected during the first meeting of the newly elected parliament) is the chair of the Board of the Seimas.

### Linguistic annotation

The processing was carried out by means of a Python script combining an XML parser module within the Spacy package (https://spacy.io). The annotation pipeline includes tokenization, sentence segmentation, lemmatization, UD part-of-speech and morphological tagging, UD dependency parsing and named entity recognition.