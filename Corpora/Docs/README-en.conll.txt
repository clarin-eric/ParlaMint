                        Comparable parliamentary corpus
                              ParlaMint-XX.ana ZZ
                Derived CoNLL-U encoded corpus with TSV metadata
                         
         Citation, documentation, download, and licence available from
                        YY

This directory contains the CoNLL-U encoded machine translated ParlaMint-XX.ana corpus.
The annotations include tokenisation, lemmatisation and UD PoS and morphological features
but no syntactic annotation. The MISC column encodes NER annotation in IOB format; word
alignment information as output by the MT system (ForwardAlignment, BackwardAlignment);
and the USAS semantic annotation (SEM). When these tags refer to a multi-word unit, this
is encoded as IOB on the SEMMWE attribute.

Additionally, each CoNLL-U file has an associated TSV file giving the metadata of its speeches.

Note that the CoNLL-U files do not contain all the information from the source
corpus, in particular, the transcriber comments are not included.
