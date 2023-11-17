# ParlaMint directory for samples of country LV (Latvia)

- Language lv (Latvian)

## Documentation

### Characteristics of the national parliament

The Saeima (Latvian pronunciation: `[ˈsai.ma]`) is the parliament of the Republic of Latvia. It is a unicameral parliament consisting of 100 members who are elected by proportional representation, with seats allocated to political parties which gain at least 5% of the popular vote. Elections are scheduled to be held once every four years.

The current corpus consists of transcripts of the plenary session from the 12th term (2014-11-04) to the end of 13th term (2022-10-27).

### Data source and acquisition

The source data for this corpus was crawled from the Saeima’s website (https://www.saeima.lv/) where verbatim reports of all the sessions of the Saeima are published in HTML format. The texts are processed using a semi-automatic pipeline to identify the boundaries of speeches and the speakers. The text is split into utterances, where each utterance contains a speech from only one speaker.

### Data encoding process

The affiliations are only meant to to be used for #member roles. If speaker was representing some other organization, the role was set to #guest. If the member does not have affiliation to any organization, that means that the deputy has left the fraction. The affiliation period is extrapolated from speeches and meant to be used  only for figuring out the affiliation of a member during a speech. The period does not represent the actual period when a person was a member of an organization.

### Linguistic annotation

All annotation layers are generated using Latvian NLP Tool Pipeline (http://nlp.ailab.lv/)

A. Znotins and E. Cirule, NLP-PIPE: Latvian NLP Tool Pipeline, Human Language Technologies - The Baltic Perspective, IOS Press, 2018,
