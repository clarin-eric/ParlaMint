# ParlaMint directory for samples of country ES-GA (Galicia)

- Languages: gl (Galician)

## Documentation

### Characteristics of the national parliament

The Galician Parliament is the legislative body of the autonomous community of Galicia, located in North-western Spain. It is composed of 75 members who are elected every four years through a proportional representation system. The Parliament is responsible for enacting legislation and overseeing the actions of the regional government.

The Galician Parliament has a unicameral structure with a multi-party political system. It is presided over by a President who is elected by the members of the Parliament (MPs). The President's role is to ensure that the rules of procedure are followed and to facilitate debate and discussion among the members. The MPs (in Galician, deputados/deputadas) are organized in parliamentary groups, which represent their respective parties or electoral coalitions. A parliamentary group is constituted by a minimum of five members. Members who are not affiliated with a specific parliamentary group comprise the Mixed Parliamentary Group.

The Parliament, located in Santiago de Compostela, meets in plenary and committee meetings. The ParlaMint-ES-GA corpus includes the records of plenary meetings spanning from term 9 to term 11 (2015 - 2022), with a total of 302 .xml and .ana files representing individual sittings.

### Data source and acquisition

Data was collected directly from the Galician Parliament, who publish [online](https://www.parlamentodegalicia.gal/) the literal transcription of all the speeches, agreements, votes, incidents and declarations that take place during plenary sittings. Committee meetings, on the other hand, are recorded in minutes that summarize the debates and voting.

The transcriptions of parliamentary proceedings go through several phases leading up to their publication on the Galician Parliament website: an initial draft in .doc or .docx format; a corrected second version in .doc or .docx format; and a final, publishing-ready text in PDF format. The first two versions of these texts were provided by the staff of the Galician Parliament. In order to build the corpus, we have used the second version, which coincides with the text publicly available on the Parliament website. These documents were converted to UTF-8 .txt format and used to obtain the TEI-xml files.

Before encoding, a semi-automatic correction of speaker names was performed to ensure the proper identification of speakers, that is, remove spelling mistakes and harmonise names and titles across the corpus. A list of chairpersons, identified in the transcripts solely by their title, was also established.

Files were also renamed in order to homogenise the nomenclature, identifying the number and date of the sitting.

Metadata about legislative periods, governments and speakers (both MPs and members of government, who have the right to intervene freely in plenary meetings) was retrieved from the websites of the Parliament and the Regional Government. Additional metadata was manually collected from public sources such as the Galician Wikipedia. Similarly, metadata regarding political parties was manually retrieved from sources such as the official websites of the respective parties.

### Data encoding process

The corpus was encoded in ParlaMint format using dedicated Python scripts that use several modules and functions from different libraries, including pandas, regex, and xml.dom. Regular expressions were used to split the text into different parts, such as speakers and their interventions, lines containing transcriber’s notes, dates, etc. The scripts also include functions that are used to find unknown speakers and try to correct misspelled names (in relation to the previously collected metadata), assign speaker roles, process text by splitting it into numbered interventions and paragraphs, identify and classify notes, etc.

Both the scripts used for .txt to ParlaMint TEI-xml conversion and those used for automatic linguistic annotation are publicly available at https://github.com/ILG-USC/ParlaMint-ES-GA.

### Corpus-specific metadata

No metadata was collected beyond what is common for all corpora.

### Structure

No additional TEI elements were used beyond what is described in the ParlaMint schema.

### Linguistic annotation

Sentence segmentation, tokenization, lemmatization and PoS tagging tasks were carried out with Freeling (version 4.2), using the provided Galician model. Freeling uses the EAGLES2 tagset which we converted to UD UPOS and FEATS.

Dependency parsing was done with UDPipe (version 1.3.1-dev) with model https://lindat.mff.cuni.cz/repository/xmlui/bitstream/handle/11234/1-3131/galician-treegal-ud-2.5-191206.udpipe?sequence=33&amp;isAllowed=y">galician-ctg-ud-2.5-191206.udpipe.

Named Entity Recognition was performed using the BERT model available at https://github.com/huggingface/transformers/tree/main/examples/pytorch/token-classification, trained with Corpus Técnico do Galego (CTG).