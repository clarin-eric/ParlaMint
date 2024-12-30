# ParlaMint: Comparable Parliamentary Corpora

The [CLARIN ParlaMint project](https://www.clarin.eu/parlamint)
compiled comparable parliamentary corpora for a number of countries and languages. 

ParlaMint corpora are interoperable, i.e. encoded to a very constrained common ParlaMint schema, a
specialisation of the [Parla-CLARIN recommendations](https://clarin-eric.github.io/parla-clarin/),
which are a customisation of the [TEI Guidelines](https://tei-c.org/guidelines/p5/).  Common scripts
should process the common data in any ParlaMint corpus, despite the differing parliamentary
systems of the countries, the kind of information included in the corpora, and, of course, language.

The latest version of ParlaMint is [4.1](https://github.com/clarin-eric/ParlaMint/releases/tag/v4.1)
which contains corpora for 29 countries and autonomous regions in original languages as well as machine
translated to English, and is available from the CLARIN.SI repository:

- [ParlaMint v4.1](http://hdl.handle.net/11356/1912): "plain text", i.e. linguistically unannotated variant of the ParlaMint corpora
- [ParlaMint.ana v4.1](http://hdl.handle.net/11356/1911): linguistically annotated variant of the ParlaMint corpora
- [ParlaMint-en.ana v4.1](http://hdl.handle.net/11356/1910): machine translated and linguistically annotated ParlaMint corpora

Publications connected to ParlaMint are available at the
[ParlaMint project page](https://www.clarin.eu/parlamint#publications-and%C2%A0presentations).

The two most comprehensive publication on ParlaMint corpora are the two open access LREV papers describing
versions 4.1 and 2.1:

- Tomaž Erjavec, Matyáš Kopp, Nikola Ljubešić, Taja Kuzman, Paul Rayson, Petya Osenova, Maciej
  Ogrodniczuk, Çağrı Çöltekin, Danijel Koržinek, Katja Meden, Jure Skubic, Peter Rupnik, Tommaso
  Agnoloni, José Aires, Starkaður Barkarson, Roberto Bartolini, Núria Bel, Calzada María Pérez,
  Roberts Darģis, Sascha Diwersy, Maria Gavriilidou, van Ruben Heusden, Mikel Iruskieta, Neeme
  Kahusk, Anna Kryvenko, Noémi Ligeti-Nagy, Carmen Magariños, Martin Mölder, Costanza
  Navarretta, Kiril Simov, Lars Magne Tungland, Jouni Tuominen, John Vidler, Adina Ioana Vladu,
  Tanja Wissik, Väinö Yrjänäinen & Darja Fišer.
  **ParlaMint II: Advancing Comparable Parliamentary Corpora Across Europe**.
  *Language Resources & Evaluation* (2024).
  DOI: [10.1007/s10579-024-09798-w](https://doi.org/10.1007/s10579-024-09798-w).
  
- Tomaž Erjavec, Maciej Ogrodniczuk, Petya Osenova, Nikola Ljubešić, Kiril Simov, Andrej Pančur,
  Michał Rudolf, Matyáš Kopp, Starkaður Barkarson, Steinþór Steingrímsson, Çağrı Çöltekin, Jesse
  de Does, Katrien Depuydt, Tommaso Agnoloni, Giulia Venturi, María Calzada Pérez, Luciana D. de
  Macedo, Costanza Navarretta, Giancarlo Luxardo, Matthew Coole, Paul Rayson, Vaidas Morkevičius,
  Tomas Krilavičius, Roberts Darǵis, Orsolya Ring, Ruben van Heusden, Maarten Marx & Darja Fišer.
  **The ParlaMint corpora of parliamentary proceedings**.
  *Language Resources & Evaluation* 57:415–448 (2023).
  DOI: [10.1007/s10579-021-09574-0](https://doi.org/10.1007/s10579-021-09574-0).
   
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
* The *[Build](Build/) folder* contains the build environemt for a release, and all associated data.
  This consists of the input (source) data, scripts, and Makefile with targets to make a relese.
  Note the the complete corpora are too large to store on GitHub, so most data files are gitignored.
  However, the directory or its subdirectories contain
  various associated resources, e.g. the automatically produced ParlaMint root files, common taxonomies,
  various metadata on the corpora etc.
