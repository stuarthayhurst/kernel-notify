#!/bin/bash
while IFS='' read -r line || [ -n "$line" ]; do
  if [[ "$line" = *"+x"* ]]; then
    line="${line// +x}"
  fi
  if [[ ! -f "${line% *}" ]]; then
    echo "${line% *} is missing. Have you run 'make build'?"
    failed="true"
  fi
done < src/lists/install.list
if [[ "$failed" == "true" ]]; then
  exit 1
fi
