pwd
cd ParlaMint

changed_files=$(git diff --name-only HEAD HEAD~1)
parla_changed=$(echo "$changed_files"|grep 'ParlaMint-.*/'|sed 's/^ParlaMint-\([-A-Z]*\).*$/\1/'|sort|uniq|tr '\n' ' ')
scripts_changed=$(echo "$changed_files"|grep -vc 'ParlaMint-.*')
parla_all=$(echo ParlaMint-*|sed 's/ParlaMint-\([-A-Z]*\)/\1/g'|sort)


parla_process=$(test -z "${parla_changed}" && echo "${parla_all}" || echo "${parla_changed}")
parla_process=$(echo "[\"$parla_process\"]"|sed 's/  */","/g'| sed 's/^\[""\]$/[]/;s/,""//')

parla_changed=$(echo "[\"$parla_changed\"]"|sed 's/  */","/g'| sed 's/^\[""\]$/[]/;s/,""//')

echo "DEBUG: changed_files=${changed_files}"

echo "DEBUG: parla_changed=${parla_changed}"

echo "DEBUG: scripts_changed=${scripts_changed}"

echo "DEBUG: parla_all=${parla_all}"

echo "DEBUG: parla_process=${parla_process}"


echo ::set-output name=parla_process::${parla_process}
echo ::set-output name=parla_all::${parla_all}
echo ::set-output name=parla_changed::${parla_changed}