# Use Ubuntu as base
FROM ubuntu:22.04

# Install required packages
RUN apt-get update && apt-get install -y \
    wget \
    openjdk-11-jdk \
    python3 \
    python3-pip \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install OWASP ZAP (v2.15.0)
RUN wget -v https://github.com/zaproxy/zaproxy/releases/download/v2.15.0/ZAP_2.15.0_Linux.tar.gz -O /tmp/zap.tar.gz \
    && tar -xzf /tmp/zap.tar.gz -C /opt \
    && rm /tmp/zap.tar.gz \
    && ln -s /opt/ZAP_2.15.0 /opt/zap

# Add ZAP to PATH
ENV PATH="/opt/zap:$PATH"

# Set working directory
WORKDIR /app

# Install Python dependencies
RUN pip3 install --no-cache-dir Flask==2.3.3

# Copy app code and script
COPY . /app

# Expose the Flask port
EXPOSE 5000

# Copy and make run script executable
RUN echo '#!/bin/bash
set -e

# Check if app.py exists
if [ ! -f app.py ]; then
  echo "ERROR: app.py not found in /app"
  exit 1
fi

# Start Python app
echo "Starting Python app..."
python3 app.py &
APP_PID=$!

# Wait for app to be ready (max 15 seconds)
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
' > /app/run_and_scan.sh && chmod +x /app/run_and_scan.sh

# Default command
CMD ["/app/run_and_scan.sh"]
