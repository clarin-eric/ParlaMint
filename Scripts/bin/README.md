# ParlaMint third-party software

This directory contains the third party software needed to run the various ParlaMint scripts:

* Saxon/: XSLT processor, used to run all .xslt scripts,
  available from https://github.com/Saxonica/Saxon-HE/. Note the programs use the name "saxon.jar", which is
  symlinked to the actual version of saxon used, itself in the Saxon/ directory
* jing.jar: XML RelaxNG validator, available from https://relaxng.org/jclark/jing.html or https://github.com/relaxng/jing-trang
* trang.jar: Conversion for RelaxNG XML syntaxt (.rng) to compact syntax (.rnc), available from https://github.com/relaxng/jing-trang
* Stylesheets/: The TEI Stylesheets for converting the ParlaMint TEI ODD,
  available from https://github.com/TEIC/Stylesheets
* tools/: Universal Dependencies tools, used for checking CoNLL-U files,
  available from https://github.com/UniversalDependencies/tools/
