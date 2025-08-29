#!/bin/bash

# Usage: ./memtrack_cont.sh <PID> <OUTPUT_FILE>
PID=$1
OUTFILE=$2

INTERVAL=1     # Sample every 1 second
WINDOW=60      # Aggregate peak over this many seconds (1 minute)

echo "minute,peak_mem_MB" > "$OUTFILE"

minute=0

while kill -0 "$PID" 2>/dev/null; do
    MAX_MEM_MB=0

    for ((i=0; i<$WINDOW; i+=$INTERVAL)); do
        # Get all child PIDs
        PIDS=$(pstree -p "$PID" | grep -oP '\(\d+\)' | grep -oP '\d+')
        PIDS="$PID $PIDS"

        # Sum RSS memory usage (in KB), convert to MB
        MEM_KB=$(ps -o rss= -p $PIDS 2>/dev/null | awk '{sum+=$1} END{print sum}')
        MEM_KB=${MEM_KB:-0}
        MEM_MB=$(echo "scale=2; $MEM_KB / 1024" | bc)
        MEM_MB=${MEM_MB:-0}

        # Update peak for this minute
        cmp=$(echo "$MEM_MB > $MAX_MEM_MB" | bc)
        if [ "$cmp" -eq 1 ]; then
            MAX_MEM_MB=$MEM_MB
        fi

        sleep $INTERVAL
    done

    echo "$minute,$MAX_MEM_MB" >> "$OUTFILE"
    minute=$((minute + 1))
done

