pwd
cd ParlaMint

FAIL=0

DATADIR=Data

TESTDIR="SAMPLE/Parla-CLARIN"
mkdir -p $TESTDIR

for parla in $(jq -r '.[]' <<< $1 ); do
  echo "::group::Processing ParlaMint-$parla"
  DIR="SAMPLE/$parla"
  mkdir -p $DIR
  echo "Cleaning old sample files [$parla]"
  rm -f ${DATADIR}/ParlaMint-$parla/ParlaMint-*.{txt,tsv,conllu,vert}

  Scripts/validate-parlamint.pl Schema ${DATADIR}/ParlaMint-$parla 2>&1 | sed "s/^\(.*\)\(\berror\b\)/::error::\1\2/i" | tee $DIR/validate.log

  echo "Validating parla-CLARIN (TEI)"
  java -jar /usr/share/java/saxon.jar -xi -xsl:Scripts/copy.xsl ${DATADIR}/ParlaMint-$parla/ParlaMint-$parla.xml > $TESTDIR/ParlaMint-$parla.xml
  java -jar /usr/share/java/jing.jar Schema/parla-clarin.rng $TESTDIR/ParlaMint-$parla.xml| sed "s/^\(.*\)\(\berror\b\)/::error::\1\2/i" | tee $DIR/parla-clarin-validate-tei.log

  echo "CONVERT to text and metadata"
  Scripts/parlamintp-tei2text.pl ${DATADIR}/ParlaMint-$parla $DIR 2>&1 | sed "s/^\(.*\)\(\berror\b\)/::error::\1\2/i" | tee $DIR/text.log


  if [ -f "${DATADIR}/ParlaMint-$parla/ParlaMint-$parla.ana.xml" ] ; then
    echo "Validating parla-CLARIN (TEI.ana)"
    java -jar /usr/share/java/saxon.jar -xi -xsl:Scripts/copy.xsl ${DATADIR}/ParlaMint-$parla/ParlaMint-$parla.ana.xml > $TESTDIR/ParlaMint-$parla.ana.xml
    java -jar /usr/share/java/jing.jar Schema/parla-clarin.rng $TESTDIR/ParlaMint-$parla.ana.xml | sed "s/^\(.*\)\(\berror\b\)/::error::\1\2/i" | tee $DIR/parla-clarin-validate-tei.log

    echo "CONVERT to vert"
    Scripts/parlamint-tei2vert.pl ${DATADIR}/ParlaMint-$parla/ParlaMint-$parla.ana.xml $DIR 2>&1 | tee $DIR/vert.log | sed "s/^\(.*\)\(\berror\b\)/::error::\1\2/i"

    echo "CONVERT and VALIDATE CoNLLu format"
    Scripts/parlamint2conllu.pl ${DATADIR}/ParlaMint-$parla $DIR 2>&1 \
      | perl -pe '$s //= {}; if(/^INFO/){($L) = $_ =~ m/Validating level (\d):/;} $ERROR= ($L>1 && !/morpho/i) ? "warning" : "error"; s/^(.*)(\berrors?\b)/\:\:$ERROR\:\:$1$2/i; if($seen{m/\[L2[^\]*\]/}){s/^/\:\:$ERROR\:\:/}; m/\[(L2[^\]]*)\]/; unless( $s->{$1}){$s->{$1}=1;s/^/\:\:$ERROR\:\:(1st of this type)/;}' \
      | tee $DIR/conllu.log

  else
    echo "::warning::skipping annotated version validation - missing corpus root file"
  fi

  echo "Move new files to ParlaMint-$parla"
  mv $DIR/ParlaMint-*.{txt,tsv,conllu,vert} ${DATADIR}/ParlaMint-$parla/
  echo "::endgroup::"
  if cat $DIR/*.log | grep -iq '::error::' ; then
    FAIL=1
    echo "::error:: ParlaMint-$parla validation failed"
  fi
done

if [ $FAIL -eq 1 ] ; then
  exit 1
fi