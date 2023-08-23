# ParlaMint Samples

Here you find ParlaMint-XX directories with samples of complete corpora containing:
* `README.md`: the README files giving a short introduction to the ParlaMint-XX corpus
     the sample corpus
* `ParlaMint-XX.xml`: teiCorpus root file of the sample and XIncludes to other TEI files constituting
     the sample corpus
* `ParlaMint-XX-listOrg.xml`: the complete list of organisations used by the corpus
* `ParlaMint-XX-listPerson.xml`: the complete list of speaker used by the corpus
* `ParlaMint-taxonomy-*.xml`: common taxonomies used by the corpus
* `ParlaMint-XX_*.xml`: sample TEI components, a few speeches from the full text
  (typically 1 day of speeches)
* `ParlaMint-XX.ana.xml`: teiCorpus root file for the linguistically (UD and NER) annotated sample,
   including annotation metadata
* `ParlaMint-XX_*.ana.xml`: ParlaMint-XX_*.xml + UD and NER annotations
* `ParlaMint-XX_*.conllu`: ParlaMint-XX_*.ana in UD CoNLL-U format (also includes NER annotations)
* `ParlaMint-XX_*-meta.tsv`: Speech metadata, with type and name of speaker, 
   political party, etc.
* `ParlaMint-XX_*.txt`: plain text of each speech, with speech id
* `ParlaMint-XX_*.vert`: vertical format, as used by CQP/CWB, (no)Sketch Engine and KonText concordancers.
* `parlamint_xx.regi`: registry files for (no)Sketch Engine concordancer.

Most of the files above are also present with the `-en` suffix (e.g. `ParlaMint-XX-en_*.xml`) which are samples of the corpora
which have been machine translated to English.
