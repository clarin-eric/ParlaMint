#CORPORA = AT BA BE BG CZ DK EE ES ES-CT ES-GA FI FR GB GR HR HU IS IT LV NL NO PL PT RS SE SI TR UA
CORPORA = ES-CT

unpack:
	for CORPUS in ${CORPORA}; do \
	tar xvzf ParlaMint-$${CORPUS}.tgz; \
	tar xvzf ParlaMint-$${CORPUS}.ana.tgz; \
	done;
