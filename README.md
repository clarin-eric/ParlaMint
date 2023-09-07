# ParlaMint: Comparable Parliamentary Corpora

The [CLARIN ParlaMint
project](https://www.clarin.eu/content/parlamint-towards-comparable-parliamentary-corpora)
is compiling comparable parliamentary corpora for a number of countries and languages. 

ParlaMint corpora are interoperable, i.e. encoded to a very constrained common ParlaMint schema, a
specialisation of the [Parla-CLARIN recommendations](https://clarin-eric.github.io/parla-clarin/),
which are a customisation of the [TEI Guidelines](https://tei-c.org/guidelines/p5/).  Common scripts
should process the common data in any ParlaMint corpus, despite the differing parliamentary
systems of the countries, the kind of information included in the corpora, and, of course, language.

The latest version of ParlaMint is [3.0](https://github.com/clarin-eric/ParlaMint/releases/tag/v3.0)
which contains corpora for 26 countries and autonomous regions and is available from the CLARIN.SI
repository ([http://hdl.handle.net/11356/1486](http://hdl.handle.net/11356/1486)), also with SoA
linguistic annotations ([http://hdl.handle.net/11356/1488](http://hdl.handle.net/11356/1488)).

The most comprehensive publications on ParlaMint corpora describes version 2.1:

Tomaž Erjavec, Maciej Ogrodniczuk, Petya Osenova, Nikola Ljubešić, Kiril Simov, Andrej Pančur,
Michał Rudolf, Matyáš Kopp, Starkaður Barkarson, Steinþór Steingrímsson, Çağrı Çöltekin, Jesse
de Does, Katrien Depuydt, Tommaso Agnoloni, Giulia Venturi, María Calzada Pérez, Luciana D. de
Macedo, Costanza Navarretta, Giancarlo Luxardo, Matthew Coole, Paul Rayson, Vaidas Morkevičius,
Tomas Krilavičius, Roberts Darǵis, Orsolya Ring, Ruben van Heusden, Maarten Marx & Darja Fišer.
The ParlaMint corpora of parliamentary proceedings.
*Language Resources & Evaluation* 57:415–448 (2023).
[10.1007/s10579-021-09574-0](https://doi.org/10.1007/s10579-021-09574-0).
   
We are now working on the ParlaMint II project, cf. the CLARIN ERIC
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
* The *[Samples](Samples/) folder* contains directories for a particular country or autonomous region
  that should include samples for all variants and formats of the ParlaMint corpora
* The *[Corpora](Corpora/) folder* contains directories for a particular country or autonomous region
  that should include complete corpora for all variants and formats of the ParlaMint corpora, along with
  the build environemt for a release, and associated data. Note the the complete corpora are too large to
  store on GitHub, so most data files are gitignored.
