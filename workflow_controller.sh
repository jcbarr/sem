#!/bin/sh

API="https://portal.semaphoreui.com/api"
TOKEN="uciqfq_mlgd4bktg2lqacea4khfee5ix3ewip9ojxmw="
PROJECT="14855"
SUBTASK_TEMPLATE_ID="41602"

SUMMARY_FILE="/tmp/wf_summary.txt"
rm -f "${SUMMARY_FILE}"

api_get() {
    wget -qO- --header="Authorization: Bearer ${TOKEN}" "$1"
}

api_post_json() {
    wget -qO- \
        --header="Authorization: Bearer ${TOKEN}" \
        --header="Content-Type: application/json" \
        --post-data="$1" "$2"
}

run_subtask() {
    NUM=$1
    INPUT=$2

    ST_START=$(date -u '+%Y-%m-%d %H:%M:%S UTC')
    ST_EPOCH_START=$(date +%s)

    echo ""
    echo "+----- Sub-task ${NUM} ----------------------------------"
    echo "|  Start:  ${ST_START}"
    echo "|  Input:  ${INPUT}"

    # Build environment JSON - Semaphore passes these as KEY=VALUE positional args to bash
    ENV_JSON=$(printf '{"TASK_NUM":"%s","INPUT_PAYLOAD":"%s"}' "${NUM}" "${INPUT}")
    ENV_ESC=$(printf '%s' "${ENV_JSON}" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g')
    BODY=$(printf '{"template_id":%s,"message":"workflow-sub-%s","environment":"%s"}' \
        "${SUBTASK_TEMPLATE_ID}" "${NUM}" "${ENV_ESC}")

    RESP=$(api_post_json "${BODY}" "${API}/project/${PROJECT}/tasks")
    TASK_ID=$(echo "${RESP}" | grep -o '"id":[0-9]*' | head -1 | sed 's/"id"://')
    echo "|  Task ID: ${TASK_ID}"

    STATUS=""
    while true; do
        sleep 1
        TJ=$(api_get "${API}/project/${PROJECT}/tasks/${TASK_ID}")
        STATUS=$(echo "${TJ}" | grep -o '"status":"[^"]*"' | head -1 | sed 's/"status":"//;s/"//')
        printf "|  [%s] %s\n" "$(date -u '+%H:%M:%S')" "${STATUS}"
        case "${STATUS}" in success|error|stopped) break ;; esac
    done

    ST_END=$(date -u '+%Y-%m-%d %H:%M:%S UTC')
    ST_EPOCH_END=$(date +%s)
    ST_DURATION=$(( ST_EPOCH_END - ST_EPOCH_START ))

    OUT=$(api_get "${API}/project/${PROJECT}/tasks/${TASK_ID}/output")
    ST_PAYLOAD=$(echo "${OUT}" | grep -o '"output":"PAYLOAD_OUTPUT:[^"]*"' | head -1 \
        | sed 's/"output":"PAYLOAD_OUTPUT://;s/"$//')

    echo "|  End:      ${ST_END}"
    echo "|  Duration: ${ST_DURATION}s  Status: ${STATUS}"
    echo "|  Payload:  ${ST_PAYLOAD}"
    echo "+---------------------------------------------------"

    printf "  #%s | %s -> %s | %ss | %s\n      payload: %s\n" \
        "${NUM}" "${ST_START}" "${ST_END}" "${ST_DURATION}" "${STATUS}" "${ST_PAYLOAD}" \
        >> "${SUMMARY_FILE}"

    LAST_PAYLOAD="${ST_PAYLOAD}"
}

# ── Main ─────────────────────────────────────────────────────────────────────

WF_START=$(date -u '+%Y-%m-%d %H:%M:%S UTC')
WF_EPOCH_START=$(date +%s)

echo "==================================================="
echo "  WORKFLOW CONTROLLER STARTED"
echo "  ${WF_START}"
echo "==================================================="

run_subtask 1 "init"
PAYLOAD_1="${LAST_PAYLOAD}"

run_subtask 2 "${PAYLOAD_1}"
PAYLOAD_2="${LAST_PAYLOAD}"

run_subtask 3 "${PAYLOAD_2}"
PAYLOAD_3="${LAST_PAYLOAD}"

WF_END=$(date -u '+%Y-%m-%d %H:%M:%S UTC')
WF_EPOCH_END=$(date +%s)
WF_DURATION=$(( WF_EPOCH_END - WF_EPOCH_START ))

echo ""
echo "==================================================="
echo "  WORKFLOW COMPLETE"
echo "==================================================="
echo "  Started:   ${WF_START}"
echo "  Ended:     ${WF_END}"
echo "  Total:     ${WF_DURATION}s"
echo "---------------------------------------------------"
echo "  Sub-task results:"
cat "${SUMMARY_FILE}"
echo "---------------------------------------------------"
echo "  Payload chain:"
echo "    init"
echo "    -> ${PAYLOAD_1}"
echo "    -> ${PAYLOAD_2}"
echo "    -> ${PAYLOAD_3}"
echo "==================================================="