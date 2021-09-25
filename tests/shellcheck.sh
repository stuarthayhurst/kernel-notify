#!/bin/bash
shellcheckVer="$(shellcheck -V |grep version |grep -v license)"
shellcheckVer="${shellcheckVer/version: }"
shellcheckArgs=()
if [[ "$shellcheckVer" > "0.7.0" ]]; then
  shellcheckArgs+=("-W" "0")
fi

for file in $(echo */*); do
  if [[ -f "$file" ]] && grep -q "#!/bin/bash" "$file"; then
    if ! shellcheck "${shellcheckArgs[@]}" "$file"; then
      exit 1
    fi
  fi
done
