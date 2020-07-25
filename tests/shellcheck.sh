#!/bin/bash
while IFS= read -r -d '' i; do
  dirList+="$i/* "
done <   <(find ./src -type d -print0)

shellcheckVer="$(shellcheck -V |grep version |grep -v license)"
shellcheckVer="${shellcheckVer/version: }"
if [[ "$shellcheckVer" > "0.7.0" ]]; then
  shellcheckArgs=("-W" "0")
else
  shellcheckArgs=()
fi
for i in $dirList; do
  if [[ -f "$i" ]]; then
    if [[ "$(head -n 1 "$i")" == "#!/bin/bash" ]]; then
      if ! shellcheck "${shellcheckArgs[@]}" "$i"; then
        exit 1
      fi
    fi
  fi
done
