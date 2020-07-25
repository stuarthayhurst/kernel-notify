#!/bin/bash
while IFS= read -r -d '' i; do
  dirList+="$i/* "
done <   <(find ./src -type d -print0)

for i in $dirList; do
  if [[ -f "$i" ]]; then
    if [[ "$(head -n 1 "$i")" == "#!/bin/bash" ]]; then
      if ! shellcheck -W 0 "$i"; then
        exit 1
      fi
    fi
  fi
done
