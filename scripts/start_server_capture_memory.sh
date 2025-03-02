#!/bin/bash

# Paths to the scripts
SCRIPT1="./start_server.sh"
SCRIPT2="./memory_usage_mysql.sh"
SCRIPT3="./memory_usage_activemq.sh"

# Enable job control
set -m

# Temporary file to capture the output of script1
TEMP_FILE=$(mktemp)

# Start script1 in the background and redirect its output to the temporary file
$SCRIPT1 > "$TEMP_FILE" 2>&1 &
PID1=$!

# Start a background task to monitor the log for the trigger message
tail -f "$TEMP_FILE" | while read -r line; do
    echo "$line"
    if [[ "$line" == *"Iniciando la aplicación Java..."* ]]; then
        echo "Comenzando a capturar memoria de activemq y mysql"
        # Start script2 and script3 in the background
        $SCRIPT2 &
        PID2=$!
        $SCRIPT3 &
        PID3=$!
        break
    fi
done &  # Run the log monitoring in the background

TAIL_PID=$!

# Function to clean up all running processes on exit
cleanup() {
    echo "Stopping all scripts..."
    kill $PID1 $PID2 $PID3 $TAIL_PID 2>/dev/null
    wait $PID1 $PID2 $PID3 $TAIL_PID 2>/dev/null
    echo "All scripts stopped."
    exit 0
}

# Trap signals to clean up processes
trap cleanup SIGINT SIGTERM

# Wait for all background processes
wait
