#!/bin/bash

# Install jq if it is not already installed
if ! command -v jq &> /dev/null; then
  echo "jq could not be found, installing..."
  sudo apt-get update
  sudo apt-get install -y jq
fi

conda activate planemo

# Create the tests_output directory if it doesn't exist
mkdir -p tests_output

# Initialize counters and lists for summary
total_tests=0
passed_tests=0
failed_tests=0
errored_tests=0
passed_tools=()
failed_tools=()
errored_tools=()

# Loop over each directory in the current directory
for dir in */; do
  # Check if the directory contains any XML files
  if ls "$dir"/*.xml 1> /dev/null 2>&1; then
    # Create a subdirectory in tests_output for the current tool
    tool_name=$(basename "$dir")
    mkdir -p "tests_output/$tool_name"
    
    # Loop over each XML file in the directory
    for xml_file in "$dir"/*.xml; do
      # Change to the associated output directory
      cd "tests_output/$tool_name"
      
      # Run planemo test on the XML file with galaxy_root set to "galaxy" and redirect output to a log file and standard output
      planemo test --galaxy_root "../../../galaxy" "../../$xml_file" 2>&1 | tee "$(basename "$xml_file" .xml).log"
      
      # Check the test output JSON file for test status
      output_json="tool_test_output.json"
      if [ -f "$output_json" ]; then
        num_errors=$(jq -r '.summary.num_errors' "$output_json")
        num_failures=$(jq -r '.summary.num_failures' "$output_json")
        num_skips=$(jq -r '.summary.num_skips' "$output_json")
        total_tests=$((total_tests + 1))
        if [ "$num_errors" -eq 0 ] && [ "$num_failures" -eq 0 ] && [ "$num_skips" -eq 0 ]; then
          echo "Test for $xml_file passed."
          passed_tests=$((passed_tests + 1))
          passed_tools+=("$tool_name")
        elif [ "$num_errors" -gt 0 ]; then
          echo "Test for $xml_file errored. Errors: $num_errors"
          errored_tests=$((errored_tests + 1))
          errored_tools+=("$tool_name")
        else
          echo "Test for $xml_file failed. Failures: $num_failures, Skips: $num_skips"
          failed_tests=$((failed_tests + 1))
          failed_tools+=("$tool_name")
        fi
      else
        echo "Test output JSON file not found for $xml_file."
        errored_tests=$((errored_tests + 1))
        errored_tools+=("$tool_name")
      fi
      
      # Change back to the original directory
      cd - > /dev/null
    done
  fi
done

# Print detailed summary of all tests
echo -e "\n=== Test Summary ==="
echo "Total tests: $total_tests"
echo "Passed tests: $passed_tests"
echo "Failed tests: $failed_tests"
echo "Errored tests: $errored_tests"

echo -e "\n=== Passed Tools ==="
if [ ${#passed_tools[@]} -eq 0 ]; then
    echo "None"
else
    printf '\033[0;32m%s\033[0m\n' "${passed_tools[@]}"
fi

echo -e "\n=== Failed Tools ==="
if [ ${#failed_tools[@]} -eq 0 ]; then
    echo "None"
else
    printf '\033[0;31m%s\033[0m\n' "${failed_tools[@]}"
fi

echo -e "\n=== Errored Tools ==="
if [ ${#errored_tools[@]} -eq 0 ]; then
    echo "None"
else
    printf '\033[0;33m%s\033[0m\n' "${errored_tools[@]}"
fi

# Copy passed tools to ../galaxy/tools/my_tools and overwrite existing tools
for tool in "${passed_tools[@]}"; do
  echo "Copying $tool to ../galaxy/tools/my_tools"
  cp -r "$tool" "../galaxy/tools/my_tools/"
done

echo "All operations completed."