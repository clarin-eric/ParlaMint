# CONTRIBUTING in ParlaMint

## Git and GitHub

Sample data should be pushed to the Data branch of the ParlaMint repository directly into the samples folder
(*`Samples/ParlaMint-XX`*) in a flat structure of files.

### Setup

- [Create a GitHub account](https://github.com/signup) if you don't have one.
- [Fork ParlaMint repository](https://github.com/clarin-eric/ParlaMint/fork) into your organization or private account.
- Start the terminal on your computer and navigate to the folder where you want the ParlaMint local clone of the repository to be placed:

```bash
# replace <USER-ORG> with your GitHub user or organization name
 git clone git@github.com:<USER-ORG>/ParlaMint.git
```

- Set the data branch in your repository to be synchronized with the data branch in the ParlaMint repository:

```bash
cd ParlaMint
git remote add upstream https://github.com/clarin-eric/ParlaMint.git
git fetch upstream
git checkout -b data upstream/data
git push -u origin data
```

### Adding new data into your remote repository (Fork)
- check you are in the data branch

```bash
git status
# switch do data branch:
git checkout data
```
- Update your local git repository with your remote repository

```bash
git pull
```

- Add new data to your local git repository:

```bash
# replace XX with your country code
git add Samples/ParlaMint-XX/*.xml
git commit -m 'XX' Samples/ParlaMint-XX/ParlaMint-XX*.xml
```

- Add common content (tagUsages, word extents, version):

  - edit files and save in `Samples/ParlaMint-XX/add-common-content/ParlaMint-XX/` folder: `make add-common-content-XX`
  - check if modified files are ok
  - replace `Samples/ParlaMint-XX/*.xml` files with `Samples/ParlaMint-XX/add-common-content/ParlaMint-XX/` content
  - commit changes `git commit -m 'XX add common content' Samples/ParlaMint-XX/ParlaMint-XX*.xml`

- Push data to your Fork:

```bash
git push
```

### Synchronize your remote repository with the ParlaMint repository

- update your repository with new content in ParlaMint repository:
  - create a pull request: https://github.com/USER-ORG/ParlaMint/compare/data...clarin-eric:data
  - check changes
  - merge pull request
- update ParlaMint repository with data in your repository:
  - create a pull request: https://github.com/clarin-eric/ParlaMint/compare/data...USER-ORG:data


## Install prerequisites

All prerequisite programs (which are not part of a Unix system) should be installed in [Scripts/bin/](Scripts/bin/).
See [Scripts/bin/README.md](Scripts/bin/README.md) for installation instructions.

You can check if all prerequisites are installed with the command `make check-prereq`.
If everything is ok, the output is:

```
Saxon: OK
Jing: OK
UD tools: OK
INFO: Maximum java heap size (saxon needs 5-times more than the size of processed XML file)
  1.80469 GB
```

## Local validation

Running *`make help`* in the repository root folder provides a make targets list with a description.
Once the set-up has been done, the corpus for country XX can be validated with the
`validate-parlamint-XX` command. For the linguistically annotated version, `make conllu-XX` should
also be run.

## Submitting the completed corpora

Once samples have been validated and incorporated into the ParlaMint GitHub repository the
complete corpus can be processed and submitted.

First, pls. note that the samples in GitHub use a flat directory structure, while the complete
corpus is structure differently. First, the linguistically non-annotated corpus should be stored
in the directory named ParlaMint-XX.TEI/, while the linguistically annotated corpus should be
stored separately, in the directory named ParlaMint-XX.TEI.ana/. Second, the component files
should be stored in subdirectories, one for each year. Note that this is explained in the [Section
on Filenames and directory structure](https://clarin-eric.github.io/ParlaMint/#sec-files) of the
Guidelines.

Once the corpus is stored in the recommended way, it can be validated localy, and then the
complete TEI and TEI.ana versions of the corpus should be compressed (either .zip or .tgz) into
two files and put somewhere where the ParlaMint editors can access it. Preferably this is a web
(http) server or any other location, where the files can be dowloaded via the command line. If
this is not possible then the corpus can also be made available on the cloud, WeTransfer or
similar. Then the editors (@TomazErjavec and @matyaskopp) should be sent an email with
instructions on how to download the corpus, and they will send feedback on whether the corpus
passed validation and let you have the validation and conversion log file.


