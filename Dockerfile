# Use Python base image for the app
FROM python:3.9-slim AS app-stage

# Set working directory
WORKDIR /app

# Copy and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the app code
COPY . .

# Expose the port (assuming default Flask port; adjust if different)
EXPOSE 5000

# Stage 2: Add OWASP ZAP for scanning
FROM owasp/zap2docker-stable AS zap-stage

# Copy the app from the first stage
COPY --from=app-stage /app /app

# Set working directory
WORKDIR /app

# Install Python in ZAP stage (for running the app)
USER root
RUN apt-get update && apt-get install -y python3 python3-pip && rm -rf /var/lib/apt/lists/*
RUN pip3 install --no-cache-dir -r requirements.txt
USER zap

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
