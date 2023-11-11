# Samples of the ParlaMint-DK corpus

- Country: DK (Denmark)
- Language: da (Danish)

## Documentation

### Characteristics of the national parliament

The corpus contains proof written Hansards of the sittings in the Danish Parliament, Folketinget, 2014-10-07 to 2022-06-07. The Danish Parliament is unicameral with a multi-party political system.

The corpus is organised with one meeting per file and marked for the parliamentary year (which always begins on the first Tuesday in October at 12.00 o’clock PM and ends on the same date at the same time the following year). The corpus contains 947 TEI files representing 398610 utterances (speeches). Moreover, the corpus consists of 40,950,171 tokens. After tokenization, the annotated corpus contains 47,058,777 tokens, of these 40,797,585 are  words (w elements)  and 6,261,192 punctuation signs (pc elements).  Additional statistics are available at the NoSketch Engine corpus info page.

### Data source and acquisition

The data, in  well structured xml format, was downloaded from the open data ftp server at the Danish Parliament site:  ftp://oda.ft.dk/ODAXML/Referat/. Metadata describing the MPs (gender, birth date, and political affiliations) were retrieved from the parliament website. The speakers were assigned a role of chairman or regular, and MPs were given the role of “MP”, “minister” or “primeMinister”.

### Data encoding process

The xml files were converted into TEI format by a perl script. Only the part of the information of the xml coded Hansards that was allowed for in the ParlaMint Schema was transformed to TEI. However, the timing of each utterance is  encoded in the utterance’s xml:id.
The TEI encoded unannotated corpus was sent through a Text Tonsorium workflow in batches of one or two year's worth of parliamentary sessions, or about 100-250 files at a time. The workflow had eleven steps, including four steps that did the actual annotation:

1. tokenization and segmentation
2. Named Entity recognition (based on manually written rules, using list of person names, country names, and organization names)
3. UDPipe 1 using Universal Dependencies 2.5 Models producing lemmas, part of speech tags, morphosyntactic descriptions and syntactic dependencies.
4. CSTlemma, producing lemmas.

The lemma output from UDPipe had two problems that were overcome by replacing UDPipe's lemma output by the output from CSTlemma. The first problem was the low quality of the UDPipe lemmas, and the other problem was that UDPipe often seemed to apply a lemmatization rule that was pertinent to a different word class than the word class implied by the part of speech tag, which also was predicted by UDPipe. We instructed CSTlemma to only apply lemmatization rules that were in agreement with the part of speech tags predicted by the UDPipe software, even if those tags were wrong.

The Text Tonsorium is open source software that can be downloaded from https://github.com/kuhumcst/. Most of the third party software, such as UDPipe, must be installed from their original sources. Running instances of the Text Tonsorium are accessible at https://clarin.dk/clarindk/tools-texton.jsp.

The tools in Text Tonsorium are run in the following order to process the ParlaMint_DK TEI-files:

- TEI tokenizer, sentence extractor, token extractor, TEI-segmenter, udpipe, Anno-splitter, CSTlemma, Anno-splitter, Anno-splitter, CSTner and TEI annotator.

### Disclaimer to the English translation

Note that the automatically produced translation to English contains errors typical of neural machine translation, which also includes factual errors even when a high level of fluency is achieved, and any manual or automatic usage of this corpus should take the machine translation limitations into account. 

In the Danish data the names of the parties and the Parliament (Folketinget) are translated literally, and in different ways. However, the party names are correct in the metadata and these can be used for studies and statistics.

Furthermore, there seem to be problems after some abbreviations ending in punctuation mark, where the MT system inserts unlrelated texts into the translation, e.g. "President. - I call the Group of the European People's Party (ChristianDemocratic Group)" or "by Mr de la Malène and others, on behalf of the Group of the European People's Party (Christian-Democratic Group)".
