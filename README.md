# ParlaMint: Comparable Parliamentary Corpora

The [CLARIN ParlaMint
project](https://www.clarin.eu/content/parlamint-towards-comparable-parliamentary-corpora)
compiled comparable parliamentary corpora for a number of countries and languages. 

ParlaMint corpora are interoperable, i.e. encoded to a very constrained common ParlaMint schema, a
specialisation of the [Parla-CLARIN recommendations](https://clarin-eric.github.io/parla-clarin/),
which are a customisation of the [TEI Guidelines](https://tei-c.org/guidelines/p5/).  Common scripts
can process any of the ParlaMint corpora, despite the differing parliamentary systems of the
countries, the kind of information included in the corpora, and, of course, language.

The latest version of ParlaMint is 2.1 which contains corpora for 17 countries (and 16 languages)
and is available from the CLARIN.SI repository, both in the linguistically
unannotated ([http://hdl.handle.net/11356/1432](http://hdl.handle.net/11356/1432)) and
annotated ([http://hdl.handle.net/11356/1431](http://hdl.handle.net/11356/1431)) variants.

This Git contains the ParlaMint XML schemas, the scripts used to validate,
and convert the XML corpora to some useful derived formats, and samples of the
ParlaMint corpora:

* The *[Schema](Schema/) folder* contains the schemas for validating the
four types of files present in the corpora. The README in this
directory provides more information.
* The *[Scripts](Scripts/) folder* contains the XSLT scripts (and their Perl wrappers) used to:
  * finalize the corpora submitted by the project partners to V2.1;
  * validate the corpora (in addition to schema validation also for links and metadata consistency);
  * convert the TEI encoded corpora to derived formats.
* The *sample country directories* should include:
  * `ParlaMint-XX.xml`: teiCorpus root file of the sample with (e.g. speaker and party) metadata and
     XIncludes to its component TEI files;
  * `ParlaMint-XX_*.xml`: sample TEI component, a few speeches from the full text
    (typically 1 day of speeches);
  * `ParlaMint-XX.ana.xml`: teiCorpus root file for the linguistically (UD and NER) annotated sample,
    including annotation metadata;
  * `ParlaMint-XX_*.ana.xml`: ParlaMint-XX_*.xml + UD and NER annotations;
  * `ParlaMint-XX_*.conllu`: ParlaMint-XX_*.ana in UD CoNLL-U format (also includes NER annotations)
  * `ParlaMint-XX_*-meta.tsv`: Speech metadata, with type and name of speaker, 
    political party, etc.;
  * `ParlaMint-XX_*.txt`: plain text of each speech, with speech id;
  * `ParlaMint-XX_*.vert`: vertical format, as used by CQP/CWB, (no)Sketch Engine and KonText concordancers.
