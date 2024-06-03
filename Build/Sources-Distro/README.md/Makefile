## Link README.md files from the Samples directory to here, so they can be used in a distribution

all:	ln_readmes

SAMPLES=../../../Samples
README_CORPORA=AT BA BE BG CZ DK EE ES ES-CT ES-GA ES-PV FI FR GB GR HR HU IS IT LV NL NO PL PT RS SE SI TR UA

# Main readmes from Samples/, link to them in README.md
ln_readmes:
	#rm -f *.md
	for CORPUS in ${README_CORPORA}; do \
	ln -s ${SAMPLES}/ParlaMint-$${CORPUS}/README.md README-$${CORPUS}.md; \
	done;
