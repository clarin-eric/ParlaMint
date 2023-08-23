# ParlaMint directory for samples of country ES (Spain)

- Language es (Spanish)

## Documentation

### Characteristics of the national parliament

Spain’s Cortes Generales is a bicameral parliamentary system consisting of an Upper House (Senado) and a Lower House (Congreso de los Diputados). ParlaMint-ES contains transcripts of the Plenary Sessions of the latter Chamber from 01/01/2015 31/12/2020. This time span corresponds to the latter part of the 10th Legislature (13th December 2011- 12th January 2016); the whole 11th legislature (13th January 2016- 18th July 2016); the whole 12th legislature (19th July 2016-20th May 2019); the whole 13th legislature (21st May 2019- 2nd December 2019), and the 14th legislature (from 3rd December  up to the present date).

The Congreso de los Diputados has 350 members (or MPs). They are elected to represent  52 constituencies (for the fifty Spanish provinces and two autonomous cities). The electing method is that of D’hont-informed proportional representation. MPs serve four-year terms in political groups (which may be formed by several political parties). In fact, groups must have at least 15 MPs. A group can also be formed with only 5 MPs if their parties obtained at least 5% of the nationwide vote or 15% of the votes in their original  constituencies. MPs who cannot create a Group form the Mixed Group. The functions and organisation of the Congreso de los Diputados is explained in its website

ParlaMint-ES has been compiled and processed by the European Comparable and Parallel Corpus (ECPC) research group with funding from  the Spanish Ministry of Science and Innovation for the larger project Original, translated and interpreted representations of the refugee cris(e)s: methodological triangulation within corpus-based discourse studies (PID2019-108866RB-I00 / AEI / 10.13039/501100011033). ECPC has compiled other corpora with parliamentary proceedings from the House of Commons (from 2004-2014) and the European Parliament (2004-2011; in the Spanish and English versions). Conversion to ParlaMint framework would not have been possible without the expert aid of Tomaz Erjavec. Linguistic annotation (tokenization, lemmatization, POS, UD and NER) is the work of Luciana Dias de Macedo.

### Data source and acquisition

The source data were obtained by scraping from the parliamentary website (https://www.congreso.es). HTML files with a full day of interventions each were automatically downloaded together with individual html files with metadata for each MP.

### Data encoding process

The conversion work-flow has several stages:

- Work with parliamentary interventions:
   - Step 1: Cleaning of HTML to get rid of unnecessary noise.
   - Step 2: Conversion of HTML into the ECPC XML, by running regex-based scripts.
   - Step 3: Conversion of ECPC XML format into ParlaMint TEI, with scripts and schemas developed by Tomaz Erjavec (see https://github.com/clarin-eric/ParlaMint).
- Work with metadata:
   - Step 1: Cleaning of HTML to get rid of unnecessary noise.
   - Step 2: Conversion of HTML into ECPC XML, by running regex-based scripts.
   - Step 3: Merging of all metadata in a common txt file.
   - Step 4: Enriching parliamentary interventions (in ECPC XML format) with common txt file of metadata by using a perl script.

### Corpus-specific metadata

Apart from the common structure, original ECPC XML files contain:

- As part of speaker metadata:
   1. the specific role of ministers addressing the Chamber;
   2. the political groups (and not just parties) of the Congreso de los Diputados, for each legislature
   3. constituencies of all MPs
- As part of  intervention / speech metadata:
   4. The original page number of published Parliamentary records. This is not present in the ana.xml version of ParlaMint-ES (to avoid unnecessary noise).

### Linguistic annotation

For both UD and NER annotations of the 306 files, Luciana D. de Macedo used Stanza, a Python NLP package (https://stanfordnlp.github.io/stanza/). The model used for the UD annotation was AnCora, default for Spanish, which covered tokenization, PoS, lemmatization, and dependency parsing. While the NER annotation relied on CoNLL02, also the default model for Spanish, which provided PER, LOC, ORG, and MISC tags.

### Issues to report

First and foremost, ParlaMint annotation of compounds (especially verbs) with two (or more) enclitics is faulty. In the case of verbs, for example, annotation splits verb_and_first_enclitic and second enclitic. This issue cannot be solved automatically (at least right now) because there are different types of verbs in Spanish (reflexive, passive, pronominal) with different solutions for this problem.  We will report this problem to Stanza. At any rate, all cases of enclitic pronouns were tagged with an error flag in a separate version so we could have it for a future fix.

Some other issues we could report are these:

1. In some files, annotation failed due to the number of characters in segments when they specifically ended with a period. The solution we adopted was that we added a space before the period (this is clearly an issue with the annotator; maybe this should be reported to Stanza for improvement?).
2. Notes (such as <note>Aplausos</note>) in ParlaMint-ES can often be found in the middle of the parliamentary intervention. This is not the case for the rest of ParlaMint versions. So notes were finally extracted from inside the intervention and placed between interventions (like with the rest of Parlamint versions)..
3. In general, especially when there we faced compound names (with a conjunction, for example, in between), the annotator might split the name into two different NERs, for example:

```XML
 <name type="ORG">
        <w lemma="Ministerio" msd="UPosTag=PROPN" xml:id="ParlaMint-ES_2017-01-31-CD170131.u2.3.34">Ministerio</w>
        <w lemma="de" msd="UPosTag=ADP|AdpType=Prep" xml:id="ParlaMint-ES_2017-01-31-CD170131.u2.3.35">de</w>
        <w lemma="Empleo" msd="UPosTag=PROPN" xml:id="ParlaMint-ES_2017-01-31-CD170131.u2.3.36">Empleo</w>
    </name>
        <w lemma="y" msd="UPosTag=CCONJ" xml:id="ParlaMint-ES_2017-01-31-CD170131.u2.3.37">y</w>
        <name type="MISC">
        <w lemma="Seguridad" msd="UPosTag=PROPN" xml:id="ParlaMint-ES_2017-01-31-CD170131.u2.3.38">Seguridad</w>
        <w lemma="Social" msd="UPosTag=PROPN" xml:id="ParlaMint-ES_2017-01-31-CD170131.u2.3.39">Social</w>
    </name>
```

We solved this issue with a basic script for final cleaning, which also included conversion into camel case and lower case of annotation, when required, since the stanza-based pipeline did not do it automatically.
