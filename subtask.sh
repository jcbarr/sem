#!/bin/sh

echo "=== All ENV vars ==="
env | sort
echo "=== End ENV ==="

TASK_NUM="${TASK_NUM:-1}"
INPUT_PAYLOAD="${INPUT_PAYLOAD:-none}"
ARG1="${1:-}"
ARG2="${2:-}"

echo "TASK_NUM env var: ${TASK_NUM}"
echo "INPUT_PAYLOAD env var: ${INPUT_PAYLOAD}"
echo "ARG1 positional: ${ARG1}"
echo "ARG2 positional: ${ARG2}"