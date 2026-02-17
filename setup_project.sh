#!/bin/bash

# 1. Validate Input
if [ -z "$1" ]; then
    echo "Usage: $0 <project_name>"
    exit 1
fi

BASE_DIR="attendance_tracker_$1"
BACKUP_ARCHIVE="${BASE_DIR}_archive.tar.gz"

# 2. Trap for Ctrl+C
cleanup() {
    echo ""
    echo "Script interrupted! Creating archive..."

    if [ -d "$BASE_DIR" ]; then
        tar -czf "$BACKUP_ARCHIVE" "$BASE_DIR"
        rm -rf "$BASE_DIR"
        echo "Archive created: $BACKUP_ARCHIVE"
        echo "Incomplete project directory removed."
    fi

    exit 1
}

trap cleanup SIGINT

# 3. Create Directory Structure
echo "Creating project structure..."

mkdir -p "$BASE_DIR/Helpers"
mkdir -p "$BASE_DIR/reports"

# 4. Create Required Files

# attendance_checker.py
cat > "$BASE_DIR/attendance_checker.py" << 'EOF'
import csv
import json
import os
from datetime import datetime

def run_attendance_check():
    with open('Helpers/config.json', 'r') as f:
        config = json.load(f)

    if os.path.exists('reports/reports.log'):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        os.rename('reports/reports.log',
                  f'reports/reports_{timestamp}.log.archive')

    with open('Helpers/assets.csv', mode='r') as f, open('reports/reports.log','w') as log:
        reader = csv.DictReader(f)
        total_sessions = config['total_sessions']

        log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")

        for row in reader:
            name = row['Names']
            email = row['Email']
            attended = int(row['Attendance Count'])

            attendance_pct = (attended / total_sessions) * 100
            message = ""

            if attendance_pct < config['thresholds']['failure']:
                message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}%. You will fail this class."
            elif attendance_pct < config['thresholds']['warning']:
                message = f"WARNING: {name}, your attendance is {attendance_pct:.1f}%. Please be careful."

            if message:
                if config['run_mode'] == "live":
                    log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n")
                    print(f"Logged alert for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":
    run_attendance_check()
EOF


# assets.csv
cat > "$BASE_DIR/Helpers/assets.csv" << EOF
Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0
EOF

# config.json
cat > "$BASE_DIR/Helpers/config.json" << EOF
{
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live",
    "total_sessions": 15
}
EOF

# reports.log
touch "$BASE_DIR/reports/reports.log"

# 5. Dynamic Configuration
echo ""
read -p "Do you want to update attendance thresholds? (y/n): " user_choice

if [ "$user_choice" = "y" ]; then
    read -p "Enter Warning threshold (default 75): " warn_threshold
    read -p "Enter Failure threshold (default 50): " fail_threshold

    warn_threshold=${warn_threshold:-75}
    fail_threshold=${fail_threshold:-50}

    sed -i "s/\"warning\": [0-9]*/\"warning\": $warn_threshold/" "$BASE_DIR/Helpers/config.json"
    sed -i "s/\"failure\": [0-9]*/\"failure\": $fail_threshold/" "$BASE_DIR/Helpers/config.json"

    echo "Thresholds updated."
else
    echo "Using default thresholds."
fi

# 6. Environment Validation
echo ""
echo "Running Health Check..."

if python3 --version &> /dev/null; then
    echo "Python3 is installed."
else
    echo "Warning: Python3 is NOT installed."
fi

# Verify directory structure
if [ -f "$BASE_DIR/attendance_checker.py" ] &&
   [ -f "$BASE_DIR/Helpers/assets.csv" ] &&
   [ -f "$BASE_DIR/Helpers/config.json" ] &&
   [ -f "$BASE_DIR/reports/reports.log" ]; then
    echo "Directory structure verified."
else
    echo "Directory structure is incorrect."
fi

echo ""
echo "Project setup complete!"
echo "project created at: $BASE_DIR"
echo "to run: cd $PROJECT_DIR && python3 attandance_checker.py"
