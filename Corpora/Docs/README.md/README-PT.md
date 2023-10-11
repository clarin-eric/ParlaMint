# ParlaMint directory for samples of country PT (Portugal)

- Languages: pt (Portuguese)

## Documentation

### Characteristics of the national parliament

The Portuguese Parliament is unicameral with a multi-party political system. The corpus contains the stenographic record of plenary sittings of the sessions of the Parliament of the Republic of Portugal (série I). Sessions are organized in four-years terms (“legislatura”). The corpus is composed of two subcorpora: the reference subcorpus, with sessions between 2015-01-01 and 2019-10-31 and the COVID subcorpus, between 2019-11-01 and 2022-03-22. Both subcorpora contain 704 files representing individual session days, 170,937 utterances and 17,646,821 words.


Diaries of the Parliament sessions

| | Reference corpus | Covid corpus |
| :--- | :--- | :--- |
| Legislature (Term of office) | XII (01.01.2015-22.10.2015) | XIV (01.11.2019-22.03.2022)|
| | XIII (23.10.2015-24.10.2019) | |
| | XIV (25.10.2019-31.10.2019) | |
| Session days | 499 | 205 |
| Number of utterances | 121,317 | 49,620 |
| Number of words | 11,689,806 | 5,957,015 |



### Data source and acquisition

The documents were retrieved from the official Portuguese Parliament site, which can be found at url https://www.parlamento.pt/DAR/Paginas/DAR1Serie.aspx. The documents were available in text, PDF and HTML format.

### Data encoding process

The session documents needed to be converted to the Parla-CLARIN XML format according to the ParlaMint guidelines. Such conversion was performed on the text version of the files using a set of bash, sed, awk and python scripts, developed specifically for the task, and correcting many systematic orthographical errors in the process. Errors which could not be automatically corrected were verified by checking the corresponding HTML version of the text file being analysed. An example of such cases were the segmentations of speech turns.

MP metadata (gender, birth date, death date, political affiliations) were retrieved from the parliament website. The speakers were assigned a role of chairman, regular or guest. All MPs were given the role of regular, even if they are speaking as Prime-Minister, Minister or other function.

### Corpus-specific metadata

Our corpus metadata did not require any extension to the original proposal.

### Structure

Our corpus did not require any extension to the original proposal.

### Linguistic annotation

Regarding tokenization and sentence segmentation, we used a revised version of the LX-tokenizer (http://lxcenter.di.fc.ul.pt/tools/en/LXTokenizerEN.html) which splits punctuation marks from words and detects sentence boundaries (Branco & Silva, 2003).

For POS-tagging we used the MBT tagger (Daelemans et al., 1996) trained over the CINTIL corpus (Barreto et al., 2006). We adapted the tagset to be conformant to the UD POS tags used in ParlaMint. The CINTIL corpus includes NER annotation.

We lemmatized the corpus with MBLEM (van den Bosch & Daelemans, 1999), that combines a dictionary lookup with a machine learning algorithm to produce lemmas. As a basis for the dictionary we used a list of wordform - POS-tag combinations mapped to lemmas. This list was produced in-house. The dictionary used in MBLEM contains 102,196 word forms combined with 27,860 lemmas, leading to 120,768 wordform-lemma combinations. The adaptation of the MBT tagger and MBLEM lemmatizer are described in Généreux et al. (2012).

Concerning UD syntactic annotations, we used the LX-UD dependency parser (https://portulanclarin.net/workbench/lx-udparser), adapted to the set of POS and relation types used in ParlaMint.
