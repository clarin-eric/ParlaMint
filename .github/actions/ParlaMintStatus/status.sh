pwd
cd ParlaMint
pwd
changed_files=$(git diff --name-only HEAD HEAD~1)
echo A "$changed_files"
echo "$changed_files"
echo "-"
echo "$changed_files"|grep 'ParlaMint-.*/'
echo "-"
echo "$changed_files"|grep 'ParlaMint-.*/'|sed 's/^ParlaMint-\([-A-Z]*\).*$/\1/'
echo "-"
echo "$changed_files"|grep 'ParlaMint-.*/'|sed 's/^ParlaMint-\([-A-Z]*\).*$/\1/'|sort
echo "-"
echo "$changed_files"|grep 'ParlaMint-.*/'|sed 's/^ParlaMint-\([-A-Z]*\).*$/\1/'|sort|uniq
echo "-"
echo "$changed_files"|grep 'ParlaMint-.*/'|sed 's/^ParlaMint-\([-A-Z]*\).*$/\1/'|sort|uniq|tr '\n' ' '
echo "-"
parla_changed=$(echo "$changed_files"|grep 'ParlaMint-.*/'|sed 's/^ParlaMint-\([-A-Z]*\).*$/\1/'|sort|uniq|tr '\n' ' ')
echo B "$parla_changed"
scripts_changed=$(echo "$changed_files"|grep -vc 'ParlaMint-.*')
echo C
parla_all=$(echo ParlaMint-*|sed 's/ParlaMint-\([-A-Z]*\)/\1/g'|sort)
echo D
parla_process=$(test -z "${parla_changed}" && echo "${parla_all}" || echo "${parla_changed}")
echo E
parla_process=$(echo "[\"$parla_process\"]"|sed 's/  */","/g')
echo F
parla_changed=$(echo "[\"$parla_changed\"]"|sed 's/  */","/g')
echo G
echo "DEBUG: changed_files=${changed_files}"
echo A
echo "DEBUG: parla_changed=${parla_changed}"
echo A
echo "DEBUG: scripts_changed=${scripts_changed}"
echo A
echo "DEBUG: parla_all=${parla_all}"
echo A
echo ::set-output name=parla_process::${parla_process}
echo A
echo ::set-output name=parla_all::${parla_all}
echo A
echo ::set-output name=parla_changed::${parla_changed}