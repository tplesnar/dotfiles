#!/bin/bash
# <xbar.title>Backrest Backup Monitor</xbar.title>
# <xbar.version>v1.0</xbar.version>
# <xbar.author>thierry</xbar.author>
# <xbar.desc>Shows last backup status and time from Backrest</xbar.desc>
# <swiftbar.hideAbout>true</swiftbar.hideAbout>
# <swiftbar.hideRunInTerminal>false</swiftbar.hideRunInTerminal>
# <swiftbar.hideLastUpdated>true</swiftbar.hideLastUpdated>
# <swiftbar.hideDisablePlugin>true</swiftbar.hideDisablePlugin>

OPLOG="$HOME/.local/share/backrest/oplog.sqlite"

# --- Status codes ---
# 1 = running, 2 = success, 3 = warning, 4 = error

# --- Check if a backup is currently running ---
if pgrep -x restic > /dev/null; then
    echo "☁️ ⟳ backing up..."
    echo "---"
    echo "Backup in progress | color=blue"
    echo "Open Backrest | href=http://localhost:9898"
    exit 0
fi

# --- Read last operation from sqlite ---
LAST_ROW=$(sqlite3 "$OPLOG" \
    "SELECT start_time_ms, status FROM operations ORDER BY id DESC LIMIT 1;" 2>/dev/null)

if [ -z "$LAST_ROW" ]; then
    echo "☁️ ?"
    echo "---"
    echo "No backup data found"
    echo "Open Backrest | href=http://localhost:9898"
    exit 0
fi

LAST_TIME_MS=$(echo "$LAST_ROW" | cut -d'|' -f1)
LAST_STATUS=$(echo "$LAST_ROW" | cut -d'|' -f2)

# Convert ms to seconds
LAST_TIME_S=$((LAST_TIME_MS / 1000))
NOW_S=$(date +%s)
DIFF_S=$((NOW_S - LAST_TIME_S))

# --- Format elapsed time ---
if [ $DIFF_S -lt 60 ]; then
    AGO="just now"
elif [ $DIFF_S -lt 3600 ]; then
    AGO="$((DIFF_S / 60))m ago"
elif [ $DIFF_S -lt 86400 ]; then
    AGO="$((DIFF_S / 3600))h ago"
else
    AGO="$((DIFF_S / 86400))d ago"
fi

# --- Format last backup date ---
LAST_DATE=$(date -r "$LAST_TIME_S" "+%Y-%m-%d %H:%M")

# --- Menu bar title ---
case "$LAST_STATUS" in
    2) echo "☁️ ✅ $AGO" ;;
    3) echo "☁️ ⚠️ $AGO" ;;
    4) echo "☁️ ❌ $AGO" ;;
    *) echo "☁️ ? $AGO" ;;
esac

echo "---"

# --- Dropdown ---
case "$LAST_STATUS" in
    2) echo "Last backup: $LAST_DATE ✅ | color=green" ;;
    3) echo "Last backup: $LAST_DATE ⚠️ warning | color=orange" ;;
    4) echo "Last backup: $LAST_DATE ❌ failed | color=red" ;;
    *) echo "Last backup: $LAST_DATE (unknown status)" ;;
esac

# --- Last 5 operations ---
echo "---"
echo "Recent operations:"
sqlite3 "$OPLOG" \
    "SELECT start_time_ms, status FROM operations ORDER BY id DESC LIMIT 5;" 2>/dev/null \
| while IFS='|' read -r ts status; do
    dt=$(date -r "$((ts / 1000))" "+%Y-%m-%d %H:%M")
    case "$status" in
        2) icon="✅" ;;
        3) icon="⚠️" ;;
        4) icon="❌" ;;
        1) icon="⟳" ;;
        *) icon="?" ;;
    esac
    echo "  $icon $dt"
done

echo "---"
echo "Open Backrest | href=http://localhost:9898"
