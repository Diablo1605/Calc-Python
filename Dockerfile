# Use Ubuntu as base (stable and widely available)
FROM ubuntu:22.04

# Install required packages
RUN apt-get update && apt-get install -y \
    wget \
    openjdk-11-jdk \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install OWASP ZAP using the official download (latest stable: v2.15.0)
RUN wget -v https://github.com/zaproxy/zaproxy/releases/download/v2.15.0/ZAP_2.15.0_Linux.tar.gz -O /tmp/zap.tar.gz \
    && tar -xzf /tmp/zap.tar.gz -C /opt \
    && rm /tmp/zap.tar.gz \
    && ln -s /opt/ZAP_2.15.0 /opt/zap

# Add ZAP to PATH
ENV PATH="/opt/zap:$PATH"

# Set working directory
WORKDIR /app

# Install Python dependencies directly (assuming Flask for the calc app; adjust if needed)
RUN pip3 install --no-cache-dir Flask==2.3.3

# Copy the app code
COPY . .

# Expose the port (assuming default Flask port; adjust if different)
EXPOSE 5000

# Script to run the app and scan (with logging and error handling)
RUN echo '#!/bin/bash\n\
set -e  # Exit on any error\n\
echo "Starting Python app..."\n\
python3 app.py &\n\
APP_PID=$!\n\
sleep 5  # Wait for app to start\n\
echo "Checking if app is running on port 5000..."\n\
if ! curl -f http://localhost:5000 > /dev/null 2>&1; then\n\
    echo "ERROR: App not responding on http://localhost:5000. Check app.py and dependencies."\n\
    kill $APP_PID\n\
    exit 1\n\
fi\n\
echo "App is running. Starting ZAP baseline scan..."\n\
zap.sh -cmd -autorun /opt/zap/zap-baseline.py -t http://localhost:5000 -r /output/zap_report.html\n\
SCAN_EXIT=$?\n\
echo "ZAP scan completed with exit code: $SCAN_EXIT"\n\
if [ $SCAN_EXIT -ne 0 ]; then\n\
    echo "WARNING: ZAP scan failed, but creating empty report for artifact."\n\
    echo "<html><body><h1>ZAP Scan Failed</h1><p>Check logs for details.</p></body></html>" > /output/zap_report.html\n\
fi\n\
echo "Killing app..."\n\
kill $APP_PID\n\
echo "Process complete. Report saved to /output/zap_report.html"\n\
' > /app/run_and_scan.sh && chmod +x /app/run_and_scan.sh

# Default command: Run the app and scan
CMD ["/app/run_and_scan.sh"]
