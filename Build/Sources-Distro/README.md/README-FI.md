# ParlaMint directory for samples of country FI (Finland)

- Languages: fi (Finnish)

## Documentation

### Characteristics of the national parliament

The Parliament of Finland is the unicameral and supreme legislature of Finland. The Parliament consists of 200 members, 199 of whom are elected every four years from 13 multi-member districts electing 7 to 36 members using the proportional D'Hondt method. In addition, there is one member from Åland. Most MPs work in parliamentary groups which correspond with the political parties.

The ParlaMint-FI corpus contains the minutes of the Finnish Parliament's plenary sessions from parliamentary session 2015 to parliamentary session 2021 (28.4.2015-28.1.2022).

### Data source and acquisition

The minutes of the Finnish Parliament's plenary sessions from parliamentary session 2015 onwards are freely available on the Open Data service of the Parliament of Finland (https://avoindata.eduskunta.fi) via an API in XML format (wrapped in JSON). The minutes were fetched from the API using a Python script.

Biographical information (birth and death dates, sex) of speakers who are not MPs have been fetched from other sources, namely regarding the chancellors of justice and parliamentary ombudsmen are fetched from Wikidata via a SPARQL query.

### Data encoding process

The original XML data was transformed into TEI-XML using a series of Python and shell scripts (https://github.com/SemanticComputing/semparl-data-transformation).

### Corpus-specific metadata

There is no metadata available going beyond what’s common for all corpora.

### Structure

There are no additional TEI elements beyond what’s described in the ParlaMint schema.

### Linguistic annotation

The linguistic annotation was generated using a Python script utilizing a previously generated linguistically annotated version of the minutes of the Finnish Parliament's plenary sessions in RDF format (which was produced in the Finnish Semantic Parliament project (https://seco.cs.aalto.fi/projects/semparl/en/)).

There is an issue in the linguistically annotated data regarding speeches that contain transcriber comments and/or interruptions. Transcriber comments and interruptions, and also the parts of the speeches that are after a transcriber comment or interruption aren't included in the linguistically annotated version.

There is no specific linguistic annotation going beyond what’s common for all corpora.