#!/bin/bash
set -e

# Detect Python app automatically
APP_FILE=$(ls *.py | head -n 1)

if [ -z "$APP_FILE" ]; then
  echo "ERROR: No Python file found in /app"
  exit 1
fi

echo "Starting Python app: $APP_FILE..."
python3 "$APP_FILE" &
APP_PID=$!

# Wait for the app to start (max 15 seconds)
echo "Waiting for app to start on port 5000..."
for i in {1..15}; do
  if curl -f http://localhost:5000 > /dev/null 2>&1; then
    echo "App is running!"
    break
  fi
  sleep 1
done

# Final check
if ! curl -f http://localhost:5000 > /dev/null 2>&1; then
  echo "ERROR: App not responding on http://localhost:5000"
  kill $APP_PID || true
  exit 1
fi

# Run ZAP baseline scan
echo "Starting ZAP baseline scan..."
zap.sh -cmd -autorun /opt/zap/zap-baseline.py -t http://localhost:5000 -r /output/zap_report.html
SCAN_EXIT=$?

echo "ZAP scan completed with exit code: $SCAN_EXIT"

if [ $SCAN_EXIT -ne 0 ]; then
  echo "WARNING: ZAP scan failed, creating empty report."
  echo "<html><body><h1>ZAP Scan Failed</h1><p>Check logs for details.</p></body></html>" > /output/zap_report.html
fi

# Kill Python app
echo "Stopping Python app..."
kill $APP_PID || true

echo "Process complete. Report saved to /output/zap_report.html"
