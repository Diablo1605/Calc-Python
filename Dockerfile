# Use OWASP ZAP stable as the base image (Ubuntu-based)
FROM owasp/zap2docker-stable

# Switch to root to install Python
USER root

# Install Python and pip
RUN apt-get update && apt-get install -y python3 python3-pip && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy and install Python dependencies
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

# Copy the app code
COPY . .

# Switch back to zap user for security
USER zap

# Expose the port (assuming default Flask port; adjust if different)
EXPOSE 5000

# Script to run the app and scan
RUN echo '#!/bin/bash\n\
# Start the app in the background\n\
python3 app.py &\n\
APP_PID=$!\n\
sleep 5  # Wait for app to start\n\
# Run ZAP baseline scan\n\
zap-baseline.py -t http://localhost:5000 -r zap_report.html\n\
# Kill the app\n\
kill $APP_PID\n\
' > /app/run_and_scan.sh && chmod +x /app/run_and_scan.sh

# Default command: Run the app and scan
CMD ["/app/run_and_scan.sh"]
