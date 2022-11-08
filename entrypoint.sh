#!/bin/bash

# SPDX-FileCopyrightText: 2022 Contributors to the License scan action project <OSPO@alliander.com>
#
# SPDX-License-Identifier: Apache-2.0

# Provide convenient debug information

set -o xtrace

# Set default values for variables

RUN_DOWNLOAD="false"
RUN_EVALUATE="true"
RUN_REPORT="true"
RUN_SCAN="false"
REPORT_FORMATS="SpdxDocument,WebApp"

# Parsing commandline arguments into variables

while [[ $# -gt 0 ]]; do
    option="$1"

    case $option in
        --run-download)
            RUN_DOWNLOAD="$2"
            shift; shift
            ;;
        --run-evaluate)
            RUN_EVALUATE="$2"
            shift; shift
            ;;
        --run-report)
            RUN_REPORT="$2"
            shift; shift
            ;;
        --run-scan)
            RUN_SCAN="$2"
            shift; shift
            ;;
        --report-formats)
            REPORT_FORMATS="$2"
            shift; shift
            ;;
        *)
            echo "ERROR: Found unknown commandline argument: ${1}"
            exit 1
            ;;
    esac
done

exit_if_nonexisting () {
    if [[ ! -f ${1} ]] ; then
        exit 1
    fi
}

# Prepare directory structure

mkdir -p "ort/reports"

# TODO: remove in favor of mentioning outputs as intended by GitHub Actions
mkdir -p "ort/results"

# Analyze

/opt/ort/bin/ort \
    --info \
    analyze \
    -i "." \
    -o "ort"
LAST_OUTPUT_FILE="ort/analyzer-result.yml"
exit_if_nonexisting ${LAST_OUTPUT_FILE}

cp "ort/analyzer-result.yml" "ort/results/"

# Download

# TODO: It might be worthwhile to allow changing the output location
if "${RUN_DOWNLOAD}"; then
    /opt/ort/bin/ort \
        --info \
        download \
        -i "ort/analyzer-result.yml" \
        -o "ort/download"
fi

# Scan

if "${RUN_SCAN}"; then
    /opt/ort/bin/ort \
        --info \
        scan \
        -i "ort/analyzer-result.yml" \
        -o "ort/"
    LAST_OUTPUT_FILE="ort/scan-result.yml"
    exit_if_nonexisting ${LAST_OUTPUT_FILE}
fi

# Evaluate

if "${RUN_EVALUATE}"; then
    PKG_CURATIONS_ARG=""
    if [[ -f curations.yml ]] ; then
        PKG_CURATIONS_ARG="--package-curations-file curations.yml"
    fi
    /opt/ort/bin/ort \
        --info \
        evaluate \
        -i "${LAST_OUTPUT_FILE}" \
        -o "ort" \
        $PKG_CURATIONS_ARG
    LAST_OUTPUT_FILE="ort/evaluation-result.yml"
    exit_if_nonexisting ${LAST_OUTPUT_FILE}

    cp "ort/evaluation-result.yml" "ort/results/"
fi

# Report

if "${RUN_REPORT}"; then
    /opt/ort/bin/ort \
        --info \
        report \
        -f "${REPORT_FORMATS}" \
        -i "${LAST_OUTPUT_FILE}" \
        -o ort/reports \
        || exit 1

    cp -r "ort/reports" "ort/results/"
fi
