# Samples of the ParlaMint-IL corpus

- Country: IL (Israel)
- Language: he (Hebrew)

## Documentation

### Characteristics of the national parliament
The Knesset is the national parliament of Israel, composed of 120 elected members. It serves as the country’s legislative authority, responsible for passing laws, supervising the government, and debating national issues. Proceedings are held as:

- Plenary sessions (legislative debates, votes, government statements)
- Committee meetings (detailed policy discussion and oversight)

All sessions are conducted in Hebrew and transcribed by official stenographers. The ParlaMint-IL corpus covers:

- Plenary protocols from 1992–2025 (13th–25th Knessets)
- Committee protocols from 1998–2025 (15th–25th Knessets)


### Data source and acquisition
Raw protocols in Microsoft Word format, obtained directly in bulk from the Knesset Archives (also publicly available on the Knesset website).
Speaker metadata (name, gender, party/faction, role) compiled primarily from the Knesset website (https://main.knesset.gov.il) and Hebrew Wikipedia, with missing or ambiguous fields completed via the Open Knesset project (https://oknesset.org) and the Knesset ODATA API.

### Data encoding process
Each Word file was converted into TEI-compliant XML following ParlaMint conventions:
1. Segmentation
   - Split documents into `<u>` (utterance) elements
   - Numbered turns (consecutive utterances by one speaker) and sentences within each turn
2. Metadata annotation
   - Protocol-level: date, Knesset number, protocol ID, type (plenary/committee), title (if any)
   - Speaker-level: normalized name, unique speaker ID, gender, role (e.g., chairperson, minister), party/faction
3. Structural cleaning
   - Extracted session identifiers (protocol numbers, committee names, dates) via regex
   - Matched raw speaker strings to MK records using approximate string matching and temporal validation
   - Manual corrections to ensure TEI-schema compliance

### Linguistic annotation
Morpho-syntactic annotation
- A 5,000-sentence subset of Knesset data was manually annotated with UD-compliant trees.
- Starting from HebPipe seeds, we retrained a Trankit parser on a combined treebank (public UD + the manually annotated subset).
- The final model achieved >97 UAS and >98 UPOS and was applied to the entire corpus, performing tokenization, sentence segmentation, POS tagging, lemmatization, and morphological analysis in accordance with UD v2 for Hebrew.

Named-Entity Recognition
- Applied the DictaBERT-NER model (Shmidman et al., 2023b).
- Entities are classified into four ParlaMint types: PER, ORG, LOC, MISC, and encoded in TEI `<name>` elements.

All annotations were generated automatically without manual post-editing.

### Paper
For more details see:

Goldin, G. et al. (2025). The Knesset Corpus: An Annotated Corpus of Hebrew Parliamentary Proceedings. Language Resources and Evaluation. https://doi.org/10.1007/s10579-025-09833-4
