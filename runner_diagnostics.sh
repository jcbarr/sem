#!/bin/bash

echo "============================================"
echo "  Runner Diagnostics - $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
echo "============================================"

echo ""
echo ">> Hostname:     $(hostname)"
echo ">> Kernel:       $(uname -r)"
echo ">> OS:           $(cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2 | tr -d '\"')"
echo ">> Uptime:       $(uptime -p)"
echo ""

echo ">> CPU"
echo "   Cores:        $(nproc)"
echo "   Model:        $(grep 'model name' /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)"
echo "   Load avg:     $(cat /proc/loadavg | awk '{print $1, $2, $3}')"
echo ""

echo ">> Memory"
free -h | awk 'NR==1{printf "   %-12s %10s %10s %10s\n",$1,$2,$3,$4} NR==2{printf "   %-12s %10s %10s %10s\n",$1,$2,$3,$4}'
echo ""

echo ">> Disk"
df -h / | awk 'NR==1{printf "   %-20s %6s %6s %6s %5s\n",$1,$2,$3,$4,$5} NR==2{printf "   %-20s %6s %6s %6s %5s\n",$1,$2,$3,$4,$5}'
echo ""

echo ">> Network Interfaces"
ip -o -4 addr show | awk '{printf "   %-12s %s\n", $2, $4}'
echo ""

echo ">> Top 5 Processes by Memory"
ps aux --sort=-%mem | awk 'NR<=6{printf "   %-25s %5s%% %5s%%\n", $11, $3, $4}'
echo ""

echo ">> Environment"
echo "   USER:         $USER"
echo "   HOME:         $HOME"
echo "   SHELL:        $SHELL"
echo "   PWD:          $PWD"
echo ""
echo "============================================"
echo "  Done"
echo "============================================"