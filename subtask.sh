#!/bin/sh

TASK_NUM="${TASK_NUM:-1}"
INPUT_PAYLOAD="${INPUT_PAYLOAD:-none}"
SLEEP_TIME=$(( (RANDOM % 6) + 2 ))

pick_word() {
    words="$1"
    count=$(echo "$words" | wc -w)
    idx=$(( (RANDOM % count) + 1 ))
    echo "$words" | tr ' ' '\n' | sed -n "${idx}p"
}

A=$(pick_word "swift lazy bright dark fuzzy bold calm sharp stormy silent")
B=$(pick_word "falcon river pixel circuit signal comet vortex matrix anchor beacon")
N=$(( RANDOM % 9000 + 1000 ))
PAYLOAD="T${TASK_NUM}-${A}-${B}-${N}"
CHAIN="${INPUT_PAYLOAD};${PAYLOAD}"

echo "========================================"
echo "  Sub-task #${TASK_NUM}"
echo "  Received:  ${INPUT_PAYLOAD}"
echo "  Sleeping:  ${SLEEP_TIME}s"
echo "========================================"

sleep "${SLEEP_TIME}"

echo ""
echo "  Generated: ${PAYLOAD}"
echo "  Chain:     ${CHAIN}"
echo ""
echo "PAYLOAD_OUTPUT:${CHAIN}"