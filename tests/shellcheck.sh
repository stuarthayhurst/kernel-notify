#!/bin/bash
while IFS= read -r -d '' i; do
  dirList+=("$i/*")
done <   <(find ./src -type d -print0)

shellcheckVer="$(shellcheck -V |grep version |grep -v license)"
shellcheckVer="${shellcheckVer/version: }"
shellcheckArgs=()
if [[ "$shellcheckVer" > "0.7.0" ]]; then
  shellcheckArgs+=("-W" "0")
fi
for files in "${dirList[@]}"; do
  if [[ -f "$files" ]] && [[ "$(head -n 1 "$files")" == "#!/bin/bash" ]]; then
    if ! shellcheck "${shellcheckArgs[@]}" "$files"; then
      exit 1
    fi
  fi
done
