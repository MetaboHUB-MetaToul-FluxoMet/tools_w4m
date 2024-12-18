#!/bin/bash

# Create the tests_output directory if it doesn't exist
mkdir -p tests_output

# Initialize counters for summary
total_tests=0
passed_tests=0
failed_tests=0

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
      
      # Run planemo test on the XML file and redirect output to a log file and standard output
      planemo test "../../$xml_file" 2>&1 | tee "$(basename "$xml_file" .xml)_$$.log"
      
      # Check the test output JSON file for test status
      output_json="tool_test_output.json"
      if [ -f "$output_json" ]; then
        test_status=$(jq -r '.tests[].data.status' "$output_json")
        total_tests=$((total_tests + 1))
        if [ "$test_status" == "passed" ]; then
          echo "Test for $xml_file passed."
          passed_tests=$((passed_tests + 1))
        else
          echo "Test for $xml_file did not pass. Status: $test_status"
          failed_tests=$((failed_tests + 1))
        fi
      else
        echo "Test output JSON file not found for $xml_file."
      fi
      
      # Change back to the original directory
      cd - > /dev/null
    done
  fi
done

# Print summary of all tests
echo "Summary of all tests:"
echo "Total tests: $total_tests"
echo "Passed tests: $passed_tests"
echo "Failed tests: $failed_tests"