# ParlaMint third-party software

This directory contains the third party software needed to run ParlaMint scripts:

## Saxon

Saxon is the XSLT processor, which we use to run all .xslt scripts.
Saxon is a Java script, so you need Java installed on your machine.

The download instructions are in [Saxon/README.md](Saxon/README.md).

Note that the ParlaMint programs (Perl and Makefiles) use "Scripts/bin/saxon.jar",
which is symlinked to the actual version of Saxon used, itself in the Saxon/ directory.

## Jing

Jing is used to validate XML files with RelaxNG RNG schemas.
The ParlaMint RNG schemas are found in the [ParlaMint/Schema/](../../Schema/) directory.

Jing can be installed as follows:
```bash
# download and unzp jing
wget https://github.com/relaxng/jing-trang/releases/download/V20220510/jing-20220510.zip
unzip jing-20220510.zip
# copy just the jing jar file
cp jing-20220510/bin/jing.jar .
```

## Universal Dependencies tools

Only one tool is used from the [Universal Dependencies tools](https://github.com/UniversalDependencies/tools/),
namely `validate.py`, needed to validate the CoNLL-U files derived from the source ParlaMint-encoded XML corpora.

The files should be found in the `tools/` directory.

The UD tools are installed by cloning them from GitHub.
Do the following in this directory:
```bash
git clone https://github.com/UniversalDependencies/tools.git
```

If you do not have it installed yet, install the Python regex library:
```
pip3 install --user regex
```

## Installation test

To check if all the main prerequisites are installed, use the command `make check-prereq` in the
top ParlaMint directory.

If everything is ok, the output is:

```
Saxon: OK
Jing: OK
UD tools: OK
INFO: Maximum java heap size (saxon needs 5-times more than the size of processed XML file)
  1.80469 GB
```

## Tools for maintenance of the ParlaMint guidelines and schemas

In case you change the [ParlaMint TEI guidelines and schema](../../TEI), you will need
the [TEI XSLT Stylesheets](https://github.com/TEIC/Stylesheets) in order to convert the ODD
specifications into HTML and RelaxNG schemas (cf. the [Makefile](../../TEI/Makefile) in the
[TEI/](../../TEI) directory).

To install simply clone them to the current directory:
```bash
git clone git@github.com:TEIC/Stylesheets.git
```

To convert the ParlaMint source RelaxNG RNG (i.e. XML syntax) schemas to RNC (compact syntax) you will need
Trang.

Trang can be installed as follows:
```bash
# download and unzp trang
wget https://github.com/relaxng/jing-trang/releases/download/V20220510/trang-20220510.zip
unzip trang-20220510.zip
# copy just the trang jar file
cp trang-20220510/trang.jar .
```
