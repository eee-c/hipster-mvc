#!/bin/bash

set -e

#####
# Unit Tests

echo "content_shell --dump-render-tree test/index.html"
results=`DumpRenderTree test/index.html 2>&1`

echo "$results" | grep CONSOLE

echo $results | grep 'unittest-suite-success' >/dev/null

echo $results | grep -v 'Exception: Some tests failed.' >/dev/null

#####
# Type Analysis

echo
echo "dartanalyzer lib/*.dart"

dartanalyzer lib/*.dart
if [[ $? != 0 ]]; then
  echo "$results"
  exit 1
fi

echo "$results"
