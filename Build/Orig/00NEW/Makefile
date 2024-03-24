# Put component files in year directories
fix-DK:
	${GIT}/Scripts/dirify-parlamint.pl ParlaMint-DK.TEI

GIT  = /project/corpora/Parla/ParlaMint/ParlaMint

get-dk:
	wget https://cst.dk/costanza/ParlaMint-DK/ParlaMint-DK-w-domains.TEI.zip
	unzip ParlaMint-DK-w-domains.TEI.zip
get-cz:
	wget https://quest.ms.mff.cuni.cz/parczech/data/ParlaMint-ES.TEI.20230808.tar.gz
	wget https://quest.ms.mff.cuni.cz/parczech/data/ParlaMint-ES.TEI.ana.20230808.tar.gz
	gunzip *.gz
	tar xvf ParlaMint-ES.TEI.20230808.tar
	tar xvf ParlaMint-ES.TEI.ana.20230808.tar
get-gb:
	wget https://ucrel.lancs.ac.uk/paul/parlamint/ParlaMint-GB.tar.gz
