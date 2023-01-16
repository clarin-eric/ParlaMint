# ParlaMint Data samples

This directory contains:
* ParlaMint-XX: directories with samples of complete corpora containing:
  * `ParlaMint-XX.xml`: teiCorpus root file of the sample and XIncludes to other TEI files constituting
     the sample corpus;
  * `ParlaMint-XX-listOrg.xml`: the complete list of organisations used by the corpus;
  * `ParlaMint-XX-listPerson.xml`: the complete list of speaker used by the corpus;
  * `ParlaMint-taxonomy-*.xml`: common taxonomies used by the corpus;
  * `ParlaMint-XX_*.xml`: sample TEI components, a few speeches from the full text
    (typically 1 day of speeches);
  * `ParlaMint-XX.ana.xml`: teiCorpus root file for the linguistically (UD and NER) annotated sample,
    including annotation metadata;
  * `ParlaMint-XX_*.ana.xml`: ParlaMint-XX_*.xml + UD and NER annotations;
  * `ParlaMint-XX_*.conllu`: ParlaMint-XX_*.ana in UD CoNLL-U format (also includes NER annotations)
  * `ParlaMint-XX_*-meta.tsv`: Speech metadata, with type and name of speaker, 
    political party, etc.;
  * `ParlaMint-XX_*.txt`: plain text of each speech, with speech id;
  * `ParlaMint-XX_*.vert`: vertical format, as used by CQP/CWB, (no)Sketch Engine and KonText concordancers.
* [ParlaMint.xml](ParlaMint.xml): automatically generated root file for all the ParlaMint "plain text"
   corpora
* [ParlaMint.ana.xml](ParlaMint.ana.xml): automatically generated root file for all the ParlaMint
   linguistically analysed (.ana) corpora
* [Metadata/](Metadata/): automatically generated *metadata* of the corpus 
* [Ministers/](Ministers/): TSV files and build invironment for inserting minister affiliations into
  the ParlaMint corpora
* [Orientations/](Orientations/): TSV files for inserting political orientation of parliamentary groups
  and political parties minister affiliations into the ParlaMint corpora
  the ParlaMint corpora
* [Taxonomies/](Taxonomies/): directory for development of common taxonomies
