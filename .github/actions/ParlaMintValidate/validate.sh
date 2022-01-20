pwd
cd ParlaMint

FAIL=0


for parla in $(jq -r '.[]' <<< $1 ); do
  echo "::group::Processing ParlaMint-$parla"
  DIR="SAMPLE/$parla"
  mkdir -p $DIR
  echo "::notice::Cleaning old sample files [$parla]"
  rm -f ParlaMint-$parla/ParlaMint-*.{txt,tsv,conllu,vert}

  Scripts/validate-parlamint.pl Schema ParlaMint-$parla 2>&1 | tee $DIR/validate.log | sed "s/^\(.*\)\(error\)/::error::\1\2/i"

  echo "::notice::CONVERT to text and metadata"
  Scripts/parlamintp-tei2text.pl ParlaMint-$parla $DIR 2>&1 | tee $DIR/text.log | sed "s/^\(.*\)\(error\)/::error::\1\2/i"


  if [ -f "ParlaMint-$parla/ParlaMint-$parla.ana.xml" ] ; then

    echo "::notice::CONVERT to vert"
    Scripts/parlamint-tei2vert.pl ParlaMint-$parla/ParlaMint-$parla.ana.xml $DIR 2>&1 | tee $DIR/vert.log | sed "s/^\(.*\)\(error\)/::error::\1\2/i"

    echo "::notice::CONVERT and VALIDATE CoNLLu format"
    Scripts/parlamint2conllu.pl ParlaMint-$parla $DIR 2>&1 | tee $DIR/conllu.log | sed "s/^\(.*\)\(error\)/::error::\1\2/i"

  else
    echo "::warning::skipping annotated version validation - missing corpus root file"
  fi

  echo "::notice::Move new files to ParlaMint-$parla"
  mv $DIR/ParlaMint-*.{txt,tsv,conllu,vert} ParlaMint-$parla/
  echo "::endgroup::"
  if cat $DIR/*.log | grep -iq 'error' ; then
    FAIL=1
    echo "::error:: ParlaMint-$parla validation failed"
  fi
done

if [ $FAIL -eq 1 ] ; then
  exit 1
fi