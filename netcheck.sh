#!/bin/bash
        
---------
# Network & Service Health Checker
        
# Description: CLI tool to check ping response times and HTTP status
 
# Usage: ./netcheck.sh [OPTION] <host1> <host2>
_________
        
# Colors for terminal output
GREEN='\033[0;32m'
RED='\033[0;31m' 
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
          
# Default settings
LOG_FILE="" 
SILENT_MODE=false
        
show_help() {
        echo -e "${BLUE}Usage:${NC} $0 [option] <target1> <target2> ..."
        echo ""  
        echo "Options:"
        echo " -l, --log <file> Save check results to specified log file"
        echo " -h, --help       Show this help message"
        echo ""
        echo "Example:"
        echo " $0 google.com github.com 8.8.8.8"
        echo " $0 -l network.log google.com tu.ie"
        exit 0
}
        
# Parse options (исправлена кавычка перед =~графі)
while [[ "$1" =~ ^- ]]; do
        case "$1" in
        -h|--help)
                show_help
                ;;
        -l|--log)
                shift
                LOG_FILE="$1"
                shift
                ;;
        *)
                ;;
        esac
done
        
# Check if arguments exist
if [ $# -eq 0 ]; then
        echo -e "${RED}Error: No target hosts specified.${NC}"
        show_help
fi

echo -e "${BLUE}==========================================================={NC}"
echo -e "${BLUE}        Network & Service Availability check               ${NC}"
echo -e "${BLUE}==========================================================={NC}"
printf "%-25s %-12s %-15s\n" "TARGET" "STATUS" "RESPONSE / CODE"
echo "----------------------------------------------------"
        
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

for TARGET in "$@"; do
        # Check if target responds to ping (добавлен пробел перед $TARGET)
        PING_OUT=$(ping -c 1 -W 2 "$TARGET" 2>&1)
        if [ $? -eq 0 ]; then
                # Extract response time using sed/cut pipeline (исправлен sed и закрыта скобка)
                RTT=$(echo "$PING_OUT" | grep "time=" | sed -E 's/.*time=([^ ]+).*/\1/')
                if [ -z "$RTT" ]; then RTT="<1ms"; fi
                
                STATUS_STR="${GREEN}[ ONLINE ]${NC}"
                RESULT_TEXT="ONLINE ($RTT)"
                printf "%-25s %-22s %-15s\n" "$TARGET" "$STATUS_STR" "$RTT"
        else
                STATUS_STR="${RED}[ OFFLINE ]${NC}"
                RESULT_TEXT="OFFLINE (Unreachable)"
                printf "%-25s %-22s %-15s\n" "$TARGET" "$STATUS_STR" "N/A"
        fi

        # Write to log file if this enabled (убрана лишняя кавычка в конце)
        if [ -n "$LOG_FILE" ]; then
                echo "[$TIMESTAMP] Host: $TARGET - $RESULT_TEXT" >> "$LOG_FILE"
        fi  
done

echo -e "${BLUE}==========================================================={NC}"
if [ -n "$LOG_FILE" ]; then
        echo -e "${GREEN}Results logged to:${NC} $LOG_FILE"
fi

