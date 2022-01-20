cd ParlaMint

echo "test if fetch >= 2"
num=$(git rev-list --count --first-parent HEAD)

if [ "$num" -lt "2" ] ; then
  echo "ERROR - atleast 2 comits should be in repository"
  exit 1
fi