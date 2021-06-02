# ParlaMint: Comparable Parliamentary Corpora

The [CLARIN ParlaMint
project](https://www.clarin.eu/content/parlamint-towards-comparable-parliamentary-corpora) is
compiling comparable parliamentary corpora for a number of countries/languages. 

ParlaMint corpora are interoperable, i.e. encoded to a very constrained common schema,
a specialisation of the [Parla-CLARIN recommendations](https://clarin-eric.github.io/parla-clarin/).
Common scripts can process any of the ParlaMint corpora, despite the
differing parliamentary systems of the countries, the kind of
information included in the corpora, and, of course, languages.

The [first version](http://hdl.handle.net/11356/1345) of the corpora included BG/bg, HR/hr, PL/pl
and SI/sl, while the second version (split into the [unannotated](http://hdl.handle.net/11356/1388)
and [linguistically annotated](http://hdl.handle.net/11356/1405) versions) contains many more
languages as well as fixing some errors from the first one. Version 2.1 is currenlty being
finalised, and its state is documented here. The complete corpora should become available in the
June 2021.

This Git contains the ParlaMint RelaxNG schema, samples of the ParlaMint corpora, and the XSLT (and
Perl) scripts used to validate, curate, and convert the ParlaMint/TEI/XML corpora to some useful
derived formats, also included.

The *[Schema](Schema/) folder* contains the schemas for validating the
four types of files present in the corpora. The README in this
directory provides more information.

The *[Scripts](Scripts/) folder* contains the XSLT scripts (and their Perl wrappers) used to:

* convert the first generation ParlaMint corpora to the present one;

* validate the corpora, in addition to schema validation also for links and metadata consistency;

* prepare the full corpora for distribution;

* convert the TEI encoded corpora to derived formats.

The *sample country directories* should include:

* `ParlaMint-XX.xml`: teiCorpus root file of the sample with (e.g. speaker and party) metadata and
  XIncludes to its component TEI files;

* `ParlaMint-XX_*.xml`: sample TEI component, a few speeches from the full text (typicall 1 day of speeches);

* `ParlaMint-XX.ana.xml`: teiCorpus root file for the linguistically (UD and NER) annotated sample,
  including annotation metadata;

* `ParlaMint-XX_*.ana.xml`: ParlaMint-XX_*.xml + UD and NER annotations;

* `ParlaMint-XX_*.conllu`: ParlaMint-XX_*.ana in UD CoNLL-U format (also includes NER annotations)

* `ParlaMint-XX_*-meta.tsv`: Speech metadata, with type and name of speaker, 
  political party, etc.;

* `ParlaMint-XX_*.txt`: plain text of each speech, with speech id;

* `ParlaMint-XX_*.vert`: vertical format, as used by CQP/CWB, (no)Sketch Engine and KonText concordancers.
