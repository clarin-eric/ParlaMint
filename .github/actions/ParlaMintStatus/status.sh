pwd
cd ParlaMint

changed_files=$(git diff --name-only HEAD HEAD~1)
parla_changed=$(echo "$changed_files"|grep 'Sample/ParlaMint-.*/'|sed -n 's/^Sample\/ParlaMint-\([-A-Z]*\).*.xml$/\1/p'|sort|uniq|tr '\n' ' '|sed 's/ *$//')
scripts_changed=$(echo "$changed_files"|egrep  "^(Schema|Scripts)")
parla_all=$(echo Sample/ParlaMint-*|sed 's/Sample\/ParlaMint-\([-A-Z]*\)/\1/g'|sort)


parla_process=$(test -z "${parla_changed}" && echo "${parla_all}" || echo "${parla_changed}")
parla_process=$(echo "[\"$parla_process\"]"|sed 's/  */","/g'| sed 's/^\[""\]$/[]/;s/,""//')

parla_changed_size=0
for parla in $parla_changed;
do
  size=$(find Sample/ParlaMint-$parla -type f -name "ParlaMint-$parla*.xml"  -print0 | du -c --block-size=1000000 --files0-from=-|tail -1|cut -f 1)
  echo "::notice:: Sample/ParlaMint-$parla size =${size} MB"
  parla_changed_size=$(echo "$parla_changed_size+$size"|bc)
done

echo "::notice:: total changed parla tei files size=${parla_changed_size} MB"


parla_changed=$(echo "[\"$parla_changed\"]"|sed 's/  */","/g'| sed 's/^\[""\]$/[]/;s/,""//')

echo "DEBUG: changed_files=${changed_files}"

echo "DEBUG: parla_changed=${parla_changed}"

echo "DEBUG: scripts_changed=${scripts_changed}"

echo "DEBUG: parla_all=${parla_all}"

echo "DEBUG: parla_process=${parla_process}"


echo "parla_process=${parla_process}" >> $GITHUB_OUTPUT
echo "parla_all=${parla_all}" >> $GITHUB_OUTPUT
echo "parla_changed=${parla_changed}" >> $GITHUB_OUTPUT
echo "scripts_changed=${scripts_changed}" | tr "\n" " " | sed "s/$/\n/" >> $GITHUB_OUTPUT
echo "parla_changed_size=${parla_changed_size}" >> $GITHUB_OUTPUT