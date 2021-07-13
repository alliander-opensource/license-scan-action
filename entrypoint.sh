#!/bin/bash

set -o xtrace

while [[ $# -gt 0 ]]; do
    option="$1"

    case $option in
        --run-evaluate)
            RUN_EVALUATE="$2"
            shift; shift;;
        --report-formats)
            REPORT_FORMATS="$2"
            shift; shift;;
    esac
done

mkdir -p "ort/reports"

# Analyze

/opt/ort/bin/ort \
    --info \
    analyze \
    -i "." \
    -o "ort" \
    --package-curations-file "curations.yml"

# temporary debugging
ls -la "ort/"
ls -la "ort/results"

cp "ort/analyzer-result.yml" "ort/results/"

# Evaluate

if "${RUN_EVALUATE}"; then
    /opt/ort/bin/ort \
        --info \
        evaluate \
        -i "ort/analyzer-result.yml" \
        -o "ort" \
        --package-curations-file "curations.yml"

    cp "ort/evaluation-result.yml" "ort/results/"
fi

# Report

/opt/ort/bin/ort \
    --info \
    report \
    $(if [[ -e "ort/evaluation-result.yml"]] ; then echo "-i ort/evaluation-result.yml"; else echo "-i ort/analyzer-result.yml") \
    -o "ort/reports" \

cp -r "ort/reports" "ort/results/"
