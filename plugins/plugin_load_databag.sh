local src_file="${DATABAG}/$1"

if [[ ! -s "${src_file}" ]]; then
  echo "FAILED: Please check..."
  echo "        1. Databag file \"${src_file}\" does not exist !"
  echo "        2. Databag file \"${src_file}\" is empty !"
  exit
fi
. ${src_file}
echo ""
