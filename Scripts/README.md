# ParlaMint scripts

This directory contains various scripts that help in manipulating ParlaMint corpora:

* check-links.xsl: checks that all IDs that are referred to actually exist. How to use
  it is explained at the start of the script.
* classlisize.py: takes a 'plain text' ParlaMint TEI component file as input then uses
  the (classla-stanfordnlp)[https://github.com/clarinsi/classla-stanfordnlp] pipeline for
  linguistic processing, and outputs the linguistically annotated TEI file.
* parlamint-tei2text.xsl: transforms a ParlaMint corpus component file to plain text
* parlamint2conllu.xsl: convert the linguistically annotated TEI corpus component to CoNLL-U
  format. It expects the TEI root corpus file as the value of the `$meta` parameter.
* parlamint2xmlvert.xsl: convert the linguistically annotated TEI corpus compoment to
  vertical format. It expects the TEI root corpus file as the value of the `$hdr`
  parameter. Note that the produced files is still in XML - to convert it to proper
  vertical format, use `parlamint-xml2vert.pl`.
* corpus2sample.xsl: takes a root corpus file as input and outputs a sample in output 
  directory, which is specified via the `$outDir` parameter. The script retains the
  first and last component file from the corpus, and first and last $Range utterances in them.
