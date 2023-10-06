# ParlaMint directory for samples of country SI (Slovenia)

- Language sl (Slovenian)

## Documentation

### Characteristics of the national parliament

The Slovenian Parliament consists of two chambers, with the National Assembly being the highest representative and legislative body of the Republic of Slovenia. It exercises the legislative function, within the framework of which the most important legal acts are adopted. In addition, the National Assembly performs electoral and supervisory functions.

The Assembly consists of 90 deputies, two of whom represent the Italian and Hungarian ethnic groups. The Assembly operates in periods (i.e., electoral terms) that occur between one general election and the next. The National Assembly meets in regular and extraordinary sessions. Regular sessions are convened during regular session periods, while extraordinary sessions are convened by the President of the National Assembly at the request of at least one-quarter of the deputies or the President of the Republic and usually deal with time-sensitive and urgent matters. Each session has its own agenda, which contains the items to be discussed that are debated in the form of speeches. Sessions of the National Assembly are open to the public, unless material containing secret information or information protected by law is discussed (https://www.dz-rs.si/wps/portal/Home/odz/pristojnosti/organiziranost).

For each electoral period, an annual report on the work of the National Assembly is prepared, containing information on the Assembly's deputies, its structure, deputy groups, the relationship between the coalition and the opposition, sessions, bills drafted and passed, parliamentary questions and motions, impeachment, etc. In addition, all the sessions dealt with during the parliamentary term are freely accessible on the National Assembly website (https://www.dz-rs.si/).

The corpus ParlaMint-SI contains the debates of the lower house, i.e. the minutes of the National Assembly of the Republic of Slovenia. In particular, the corpus includes the minutes of the 3rd to 8th legislative sessions (2000-10-27 - 2022-05-13) and contains 1573 TEI documents, i.e. sessions on a given day with 311,376 speeches and 69,921,953 words.

### Data source and acquisition

The base data for ParlaMint-SI was taken from the evolving Slovenian parliamentary corpus (1990-2018) siParl 2.0, available through the DARIAH-SI GitHub project (https://github.com/ DARIAH-SI/siParl/) and on the CLARIN.SI repository (http://hdl.handle.net/11356/1300). The corpus includes the minutes of the National Assembly of the Republic of Slovenia from the first to the seventh legislative period (1990-2018), as well as the minutes of the working bodies of the National Assembly and the minutes of the Council of the President of the National Assembly. The corpus has already been encoded according to the Parla-CLARIN recommendations for encoding parliamentary corpora. For the ParlaMint-SI corpus, we focused exclusively on the minutes of the National Assembly of the Republic of Slovenia.

### Data encoding process

As part of the ParlaMint project, the SiParl corpus was expanded to cover the 8th legislature (2018-2022) (http://hdl.handle.net/11356/1748):

- data was manually downloaded from the Assembly website (https://www.dz-rs.si) in HTML format
- The texts were then cleaned up and properly aligned
- The speakers' metadata were already inserted into the transcripts
- Incidents and comments in the “/…/” brackets in the text were identified
- The structure of the corpus was built following the structure of the terms in the form of "SDZ#" (e.g. SDZ7), which then contains meetings from the respective term.

The corpus was then converted to ParlaMint-like encoding as part of the same project (https://github.com/DARIAH-SI/siParl/tree/master/speech), from where we then started our data encoding process into ParlaMint-compatible encoding format. Since the siParl corpus covers a very extensive period of time, we chose a period of time for the ParlaMint 3.0 corpus that is somewhat more extensive than the previous ParlaMint-SI 2.1 corpus - the corpus now covers the minutes of the 3rd to 8th legislative sessions (2000 - 2022).

There were several differences from the ParlaMint-like format used in the SiParl 3.0 corpus that we needed to consolidate during the encoding process to match the ParlaMint format:

- Most notably, the structure of the corpus had to be converted from the term-based structure to the standard ParlaMint corpus structure (from the SDZ# format to the structure based on the year of meetings).
- SiParl annotates most organizations (with exceptions such as "parliament", "government", "independent", and "ethnic_communities") as "political_party". Therefore, in order to distinguish between political parties and parliamentary groups, a manual review was required. Data was collected from the annual reports of the Assembly for each electoral period (https://www.dz-rs.si/wps/portal/Home/odz/publikacije/PorocilaDeloDZ/). In addition, the labels had to be converted to valid values as described in the ParlaMint encoding guidelines.
- SiParl does not include opposition data (only coalition), so the data on opposition had to be added manually. The data was gathered from the annual Assembly reports mentioned above.

For linguistic annotation of the Slovenian corpus we used the CLASSLA-StanfordNLP pipeline trained for Slovene (https://github.com/clarinsi/classla).

### Structure

We did not use any TEI elements or attributes outside of the ParlaMint schema.
