# ParlaMint directory for samples of country ES-CN (Canary Islands)
- Languages: es (Spanish)

## Documentation
### Characteristics of the national parliament
The Parliament of the Canary Islands is the legislative body of the autonomous community of the Canary Islands, Spain. It is composed of 70 members who are elected every four years through a proportional representation system. The Parliament is responsible for enacting legislation and overseeing the actions of the regional government. 
Wikipedia

The Parliament has a unicameral structure with a multi-party political system. It is presided over by a President elected by the members of Parliament (MPs). The President’s role is to ensure that the rules of procedure are followed and to facilitate debate and discussion among the members. MPs are organised in parliamentary groups, which represent their respective parties or coalitions; members not attached to a specific group sit in the Mixed Parliamentary Group. 
Parlamento de Canarias

The Parliament, located in Santa Cruz de Tenerife, meets in plenary and committee sittings. The ParlaMint-ES-CN corpus includes the records of plenary meetings spanning from term 3 to term 10 (1991–2021), with a total of 954 .xml and .ana files representing individual sittings.

### Data source and acquisition
Data was collected directly from the Parliament of the Canary Islands (Parlamento de Canarias), which publishes online the literal transcriptions of all speeches, agreements, votes, incidents, and declarations that take place during plenary sittings. These transcriptions are publicly available on the Parliament’s official website: https://www.parcan.es.

The transcriptions of parliamentary proceedings are published directly in PDF format, which constitutes the official and final version of each plenary sitting. These PDF documents were downloaded and converted to UTF-8 plain text to enable processing and corpus construction. The resulting texts were then used to generate the TEI-XML files conforming to the ParlaMint encoding guidelines.

No prior manual correction of speaker names was performed before encoding. Speaker identification and normalisation were instead handled during the automatic processing stage. Metadata on legislative periods, governments, and speakers (including MPs and members of the regional government, who may freely intervene in plenary sessions) was retrieved from the official Parliament website and complemented with publicly available information from Wikipedia and other online sources.

### Data encoding process
The corpus was encoded in ParlaMint format using dedicated C# scripts that use several modules and functions from different libraries. Regular expressions were used to split the text into different parts, such as speakers and their interventions, lines containing transcriber’s notes, dates, etc. The scripts also include functions that are used to find unknown speakers and try to correct misspelled names (in relation to the previously collected metadata), assign speaker roles, process text by splitting it into numbered interventions and paragraphs, identify and classify notes, etc.

### Corpus-specific metadata
No metadata was collected beyond what is common for all corpora.

### Structure
No additional TEI elements were used beyond what is described in the ParlaMint schema.

### Linguistic annotation
Lemmatisation, Part-of-Speech (PoS) tagging and dependency parsing were carried out using UDPipe 2 (http://ufal.mff.cuni.cz/udpipe/2), with the spanish-gsd-ud-2.15-241121 model. The tool provides full Universal Dependencies (UD)–compliant outputs, including UPOS, FEATS, HEAD and DEPREL annotations.

Named Entity Recognition (NER) was performed using NameTag 3 (http://ufal.mff.cuni.cz/nametag/3), with the nametag3-multilingual-conll-250203 model. The recognised entities were integrated into the ParlaMint XML structure as <name> elements following the TEI and ParlaMint conventions.

Both tools were applied to the entire corpus automatically, ensuring consistency in sentence segmentation, token alignment and dependency structure across all documents. The resulting annotation follows the Universal Dependencies v2.15 guidelines for Spanish.
