# ParlaMint scripts

This directory contains the scripts that are used to validate or
convert ParlaMint XML corpora to other formats. Most scripts have an
explanation of how to run them in comments and the start of the
script. Note that these scripts should be typically run via the repository
[Makefile](../Makefile); for instructions how to use it, pls. see the
repository [CONTRIBUTING](../CONTRIBUTING.md) file.

## Validation

* [validate-parlamint.pl](validate-parlamint.pl): Perl script that
  runs all the validation scripts below
* [validate-parlamint.xsl](validate-parlamint.xsl): checks for common
  encoding or metadata mistakes
* [check-links.xsl](check-links.xsl):checks that all IDs that are referred to actually exist
* [parlamint2root.xsl](parlamint2root.xsl): not strictly validation (altough the result can be used for such), makes the ParlaMint corpus root files [ParlaMint.xml](../ParlaMint.xml) and [ParlaMint.ana.xml](../ParlaMint.ana.xml) on the basis of the individual corpora roots.

## Conversion

* [parlamint-tei2text.xsl](parlamint-tei2text.xsl): transforms a ParlaMint corpus component file to plain text
* [parlamint2conllu.pl](parlamint2conllu.pl): runs the parlamint2conllu XSLT script as well as running the
  UD validator on the resulting files. Not that it is assumed that this directory contains (gitignored) the UD  validator, which is installed with `git clone git@github.com:UniversalDependencies/tools.git`
* [parlamint2conllu.xsl](parlamint2conllu.xsl): convert the linguistically annotated TEI corpus
  component to CoNLL-U format. It expects the TEI root corpus file as the value of the `$meta` parameter.
* [parlamint2xmlvert.xsl](parlamint2xmlvert.xsl): convert the linguistically annotated TEI corpus compoment to
  vertical format for the CQP line of concordancers.
  It expects the TEI root corpus file as the value of the `hdr`
  parameter. Note that the produced files is still in XML - to convert it to "proper"
  vertical format, use `parlamint-xml2vert.pl`.
* [corpus2sample.xsl](corpus2sample.xsl): takes a root corpus file as input and outputs a sample in output 
  directory, which is specified via the `$outDir` parameter. The script retains the
  first and last component file from the corpus, and first and last $Range utterances in them.
* [classlisize.py](classlisize.py): takes a 'plain text' ParlaMint TEI component file as input then uses
  the [classla-stanfordnlp](https://github.com/clarinsi/classla-stanfordnlp) pipeline for
  linguistic processing, and outputs the linguistically annotated TEI file.
