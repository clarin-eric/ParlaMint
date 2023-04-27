# ParlaMint directory for samples of country AT (Austria)

- Languages: de (German)

## Documentation

### Characteristics of the national parliament

The Austrian Parliament is bicameral and consists of the following two campers: the National Council (“Nationalrat”)  and the Federal Council (“Bundesrat”). The political system is a multi-party system. The ParlaMint-AT corpus contains the shorthand records of the plenary sittings of the National Council from term 20 to term 27 (1996 - 2022).

### Data source and acquisition

The shorthand records are freely available on the website of the Austrian Parliament (https://www.parlament.gv.at/PAKT/STPROT/) as HTML or pdf documents since the 20th legislative period. For the earlier legislative periods only scanned originals in pdf are available. As data source for the ParlaMint-AT corpus  the HTML version of the shorthand records were scraped from the Austrian parliamentary website. It has to be noted that the original HTML documents are encoded in Windows-1252 and not in UTF8.
Metadata about legislative periods, governments and persons was also retrieved in HTML format from  https://www.parlament.gv.at/PAKT/STPROT/ and subsequently transformed into XML-TEI using dedicated perl scripts.

### Data encoding process

The original HTML data was first cleaned of obvious formatting errors by applying string substitutions in perl and then transformed to XHTML using tidy html 5. This data then is further transformed into TEI-XML using a series of scripts in perl and xslt which were created previously for the ParlAT corpus.

### Corpus-specific metadata

There is no metadata available going beyond what’s common for all corpora.

### Structure

There are no additional TEI elements beyond what’s described in the ParlaMint schema.

### Linguistic annotation

There is no specific linguistic annotation going beyond what’s common for all corpora.
