pwd
cd ParlaMint



for parla in $(jq -r '.[]' <<< $1 ); do
  echo "::group::Processing ParlaMint-$parla"
  DIR="SAMPLE/$parla"
  mkdir -p $DIR
  echo "::notice::Cleaning old sample files [$parla]"
  rm -f ParlaMint-$parla/ParlaMint-*.{txt,tsv,conllu,vert}

  Scripts/validate-parlamint.pl Schema ParlaMint-$parla

  echo "::notice::CONVERT to text and metadata"
  Scripts/parlamintp-tei2text.pl ParlaMint-$parla $DIR


  if [ -f "ParlaMint-$parla/ParlaMint-$parla.ana.xml" ] ; then

    echo "::notice::CONVERT to vert"
    Scripts/parlamint-tei2vert.pl ParlaMint-$parla $DIR

    echo "::notice::CONVERT and VALIDATE CoNLLu format"
    Scripts/parlamint2conllu.pl ParlaMint-$parla $DIR

  else
    echo "::warning::skipping annotated version validation - missing corpus root file"
  fi

  echo "::notice::Move new files to ParlaMint-$parla"
  mv $DIR/* ParlaMint-$parla/
  echo "::endgroup::"

done