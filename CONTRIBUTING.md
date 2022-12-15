# CONTRIBUTING in ParlaMint

## Git and GitHub

Sample data should be pushed to the Data branch of the ParlaMint repository directly into the parliament folder (*`Data/ParlaMint-XX`*) in a flat structure of files.

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
git add Data/ParlaMint-XX/*.xml
git commit -m 'XX' Data/ParlaMint-XX/ParlaMint-XX*.xml
```

- Add common content (tagUsages, word extents, version):

  - edit files and save in `Data/ParlaMint-XX/add-common-content/ParlaMint-XX/` folder: `make add-common-content-XX`
  - check if modified files are ok
  - replace `Data/ParlaMint-XX/*.xml` files with `Data/ParlaMint-XX/add-common-content/ParlaMint-XX/` content
  - commit changes `git commit -m 'XX add common content' Data/ParlaMint-XX/ParlaMint-XX*.xml`

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

You can check if all prerequisites are installed with the command `make check-prereq` if all success the output is:

```
Saxon: OK
Jing: OK
UD tools: OK
INFO: Maximum java heap size (saxon needs 5-times more than the size of processed xml file)
  1.80469 GB
```

### Saxon

Saxon is expected to be at this location in your system: `/usr/share/java/saxon.jar`
You need superuser privileges to do this.

```bash
# download saxon file into /opt folder
sudo wget https://search.maven.org/remotecontent?filepath=net/sf/saxon/Saxon-HE/10.6/Saxon-HE-10.6.jar -O /opt/saxon.jar
# create a symbolic link to the correct location
sudo ln -s /opt/saxon.jar /usr/share/java/saxon.jar
```

**Important note: jing archive below also contains Saxon. But that version of Saxon does not support all features that are needed.**

### Jing

Jing is expected to be at this location in your system: `/usr/share/java/jing.jar`
You need superuser privileges to do this.

```bash
# download jing into tmp folder
wget https://github.com/relaxng/jing-trang/releases/download/V20181222/jing-20181222.zip -O /tmp/jing-20181222.zip
# extract jinfg into /opt
sudo unzip /tmp/jing-20181222.zip jing-20181222/bin/* -d /opt
# create a symbolic link to the correct location
sudo ln -s /opt/jing-20181222/bin/jing.jar /usr/share/java/jing.jar
rm /tmp/jing-20181222.zip
```

### UD tools

- Change directory to `Scripts` folder: `cd Scripts`
- Clone UD tools repository: `git clone https://github.com/UniversalDependencies/tools.git`
- Install Python regex library: `pip3 install --user regex`

## Local validation

Running *`make help`* in the repository root folder provides a make targets list with a description.
Once the set-up has been done, the corpus for country XX can be validated with the
`validate-parlamint-XX` command. For the linguistically annotated version, `make conllu-XX` should
also be run.

## Submitting the completed corpora

Once samples have been validated and incorporated into the ParlaMint GitHub repository, and the
complete corpus validates locally, the directory with the complete corpus (e.g. `ParlaMint-XX.TEI`)
should be compressed (either .zip or .tgz) into one file and put somewhere where the editors of the
corpus can access it, e.g. on a local web server, WeTransfer or similar. Then the editors
(@TomazErjavec and @matyaskopp) should be sent an email with instructions on how to download the
corpus.

The corpus should be structured according to the rules of ParlaMint, as explained in the [Section on
Filenames and directory structure](https://clarin-eric.github.io/ParlaMint/#sec-files) of the
Guidelines.

Note that ParlaMint distinguishes two version of the corpus, the "plain text" one (stored in the
`ParlaMint-XX.TEI` directory), and the linguistically annotated one (stored in the
`ParlaMint-XX.TEI.ana` directory), where the root and component files and are marked with the `.ana`
suffix. The two versions should be submitted separately, i.e. each in it own compressed file.


