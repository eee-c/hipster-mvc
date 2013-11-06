#!/bin/bash

#####
# Unit Tests

# Start the test server
echo "starting test server"
packages/plummbur_kruk/start.sh

echo "content_shell --dump-render-tree test/index.html"
results=`content_shell --dump-render-tree test/index.html 2>&1`

echo "$results"

# Stop the server
packages/plummbur_kruk/stop.sh

# check to see if DumpRenderTree tests
# fails, since it always returns 0
if [[ "$results" == *"Some tests failed"* ]]; then
    exit 1
fi

if [[ "$results" == *"Exception: "* ]]; then
    exit 1
fi


#####
# Type Analysis

echo
echo "dartanalyzer lib/*.dart"

dartanalyzer lib/hipster_collection.dart
if [[ $? != 0 ]]; then
  exit 1
fi

dartanalyzer lib/hipster_history.dart
if [[ $? != 0 ]]; then
  exit 1
fi

dartanalyzer lib/hipster_model.dart
if [[ $? != 0 ]]; then
  exit 1
fi

dartanalyzer lib/hipster_router.dart
if [[ $? != 0 ]]; then
  exit 1
fi

dartanalyzer lib/hipster_view.dart
if [[ $? != 0 ]]; then
  exit 1
fi
