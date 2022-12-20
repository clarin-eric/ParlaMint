# ParlaMint: Comparable Parliamentary Corpora

The [CLARIN ParlaMint
project](https://www.clarin.eu/content/parlamint-towards-comparable-parliamentary-corpora)
is compiling comparable parliamentary corpora for a number of countries and languages. 

ParlaMint corpora are interoperable, i.e. encoded to a very constrained common ParlaMint schema, a
specialisation of the [Parla-CLARIN recommendations](https://clarin-eric.github.io/parla-clarin/),
which are a customisation of the [TEI Guidelines](https://tei-c.org/guidelines/p5/).  Common scripts
should process the common data in any ParlaMint corpus, despite the differing parliamentary
systems of the countries, the kind of information included in the corpora, and, of course, language.

The latest version of ParlaMint is [2.1](https://github.com/clarin-eric/ParlaMint/releases/tag/v2.1)
which contains corpora for 17 countries (and 16 languages) and is available from the CLARIN.SI
repository ([http://hdl.handle.net/11356/1432](http://hdl.handle.net/11356/1432)), also with SoA
linguistic annotations ([http://hdl.handle.net/11356/1431](http://hdl.handle.net/11356/1431)).
The background and 2.1 corpus is further described in:

Tomaž Erjavec, Maciej Ogrodniczuk, Petya Osenova, Nikola Ljubešić, Kiril Simov, Andrej Pančur,
Michał Rudolf, Matyáš Kopp, Starkaður Barkarson, Steinþór Steingrímsson, Çağrı Çöltekin, Jesse
de Does, Katrien Depuydt, Tommaso Agnoloni, Giulia Venturi, María Calzada Pérez, Luciana D. de
Macedo, Costanza Navarretta, Giancarlo Luxardo, Matthew Coole, Paul Rayson, Vaidas Morkevičius,
Tomas Krilavičius, Roberts Darǵis, Orsolya Ring, Ruben van Heusden, Maarten Marx & Darja Fišer.
The ParlaMint corpora of parliamentary proceedings.
*Language Resources & Evaluation* (2022).
[10.1007/s10579-021-09574-0](https://doi.org/10.1007/s10579-021-09574-0).
   
We are now working on extending the ParlaMint corpora with newer proceedings and with new
countries, languages, and modalities, cf. the CLARIN ERIC
[ParlaMint project description](https://www.clarin.eu/content/parlamint-towards-comparable-parliamentary-corpora).
   
****

This Git repository contains the ParlaMint XML schemas, the scripts used to validate and convert the
ParlaMint TEI XML corpora to some useful derived formats, and samples of the ParlaMint corpora.
Note that there are several branches for different parts of the development.

* Contributing to ParlaMint repository is described in *[CONTRIBUTING.md](CONTRIBUTING.md) file*
  * git and GitHub setup
  * installing prerequisites
* Running *`make help`* in repository root folder provides make targets list with description.
* The *[TEI](TEI/) folder* contains the TEI ODD, i.e. the Guidelines for encoding ParlaMint corpora,
with their HTML available on [ParlaMint project pages] and the formal TEI schema specification.
[TEI README](TEI/README.md) provides more information.
* The *[Schema](Schema/) folder* contains the RelaxNG schemas for separately validating the
four types of files present in the corpora.
[Schema README](Schema/README.md) provides more information.
* The *[Scripts](Scripts/) folder* contains the XSLT scripts and Perl wrappers used to:
  * validate the corpora (RNG + XSLT validation for consistency);
  * convert the TEI encoded corpora to derived formats;
  * add/change common information, currently for V3.0
  * compute some statistics

* The *[Data](Data/) folder* contains *sample country directories* that should include:
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
