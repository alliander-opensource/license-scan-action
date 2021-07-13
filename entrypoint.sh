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

mkdir -p "${GITHUB_WORKSPACE}/ort/reports"

# Analyze

/opt/ort/bin/ort \
    --info \
    analyze \
    -i "${GITHUB_WORKSPACE}" \
    -o "${GITHUB_WORKSPACE}/ort" \
    --package-curations-file "${GITHUB_WORKSPACE}/curations.yml"

cp "${GITHUB_WORKSPACE}/ort/analyzer-result.yml" "${GITHUB_WORKSPACE}/ort/results/"

# Evaluate

if "${ RUN_EVALUATE }"; then
    /opt/ort/bin/ort \
        --info \
        evaluate \
        -i "${GITHUB_WORKSPACE}/ort/analyzer-result.yml" \
        -o "${GITHUB_WORKSPACE}/ort" \
        --package-curations-file "${GITHUB_WORKSPACE}/curations.yml"

    cp "${GITHUB_WORKSPACE}/ort/evaluation-result.yml" "${GITHUB_WORKSPACE}/ort/results/"
fi

# Report

/opt/ort/bin/ort \
    --info \
    report \
    $(if [[ -e "${GITHUB_WORKSPACE}/ort/evaluation-result.yml"]] ; then echo "-i ${GITHUB_WORKSPACE}/ort/evaluation-result.yml"; else echo "-i ${GITHUB_WORKSPACE}/ort/analyzer-result.yml") \
    -o "${GITHUB_WORKSPACE}/ort/reports" \

cp -r "${GITHUB_WORKSPACE}/ort/reports" "${GITHUB_WORKSPACE}/ort/results/"
