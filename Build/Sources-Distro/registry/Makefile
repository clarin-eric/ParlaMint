## Copy over registry files so they can be included in a distribution
all:	cp_regis

SRC=/project/clarinsi-cqp/registry/
REGIST_VERSION=50
REGIST_CORPORA=at ba be bg cz dk ee es es_ct es_ga es_pv fi fr gb gr hr hu is it lv nl no pl pt rs se si tr ua xx xx_en

# Registry files 
cp_regis:
	rm -f registry/*
	for CORPUS in ${REGIST_CORPORA}; do \
	cp -f ${SRC}/parlamint${REGIST_VERSION}_$${CORPUS} parlamint${REGIST_VERSION}_$${CORPUS}; \
	done;
