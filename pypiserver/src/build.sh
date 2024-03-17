if [[ $# -eq 1 ]]; then
  printf "Specify path to the package"
  exit 1
fi
if [[ $# -gt 2 ]]; then
  printf "To many arguments"
  exit 1
fi
cmd="setup.py sdist --dist-dir=${1}"
if [[ $# -eq 2 ]]; then
  sleep 0.5
  cmd="${cmd} upload -r ${2}"
fi

python3 ${cmd}
