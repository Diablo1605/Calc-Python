# Use Ubuntu as base (stable and widely available)
FROM ubuntu:22.04

# Install required packages
RUN apt-get update && apt-get install -y \
    wget \
    openjdk-11-jdk \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install OWASP ZAP using the official script
RUN wget -q https://github.com/zaproxy/zaproxy/releases/download/v2.14.0/ZAP_2.14.0_Linux.tar.gz -O /tmp/zap.tar.gz \
    && tar -xzf /tmp/zap.tar.gz -C /opt \
    && rm /tmp/zap.tar.gz \
    && ln -s /opt/ZAP_2.14.0 /opt/zap

# Add ZAP to PATH
ENV PATH="/opt/zap:$PATH"

# Set working directory
WORKDIR /app

# Copy and install Python dependencies
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

# Copy the app code
COPY . .

# Expose the port (assuming default Flask port; adjust if different)
EXPOSE 5000

# Script to run the app and scan
RUN echo '#!/bin/bash\n\
# Start the app in the background\n\
python3 app.py &\n\
APP_PID=$!\n\
sleep 5  # Wait for app to start\n\
# Run ZAP baseline scan\n\
zap.sh -cmd -autorun /opt/zap/zap-baseline.py -t http://localhost:5000 -r zap_report.html\n\
# Kill the app\n\
kill $APP_PID\n\
' > /app/run_and_scan.sh && chmod +x /app/run_and_scan.sh

# Default command: Run the app and scan
CMD ["/app/run_and_scan.sh"]
