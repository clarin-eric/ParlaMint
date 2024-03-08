## Copy and rename README and registry files so they can be included in a distribution

cp_all:	cp_readmes cp_regis

README_CORPORA = AT BA BE BG CZ DK EE ES ES-CT ES-GA ES-PV FI FR GB GR HR HU IS IT LV NL NO PL PT RS SE SI TR UA
REGIST_VERSION = 41
REGIST_CORPORA = at ba be bg cz dk ee es es_ct es_ga es_pv fi fr gb gr hr hu is it lv nl no pl pt rs se si tr ua

# Main readmes from Samples/, store here and rename
cp_readmes:
	# rm -f README.md/*.md
	for CORPUS in ${README_CORPORA}; do \
	cp ../../Samples/ParlaMint-$${CORPUS}/README.md \
	README.md/README-$${CORPUS}.md; \
	done;

# Registry files 
cp_regis:
	#rm -f registry/*
	for CORPUS in ${REGIST_CORPORA}; do \
	cp /project/clarinsi-cqp/registry/parlamint${REGIST_VERSION}_$${CORPUS} \
	registry/parlamint${REGIST_VERSION}_$${CORPUS}; \
	done;
