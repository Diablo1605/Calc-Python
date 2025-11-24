# Base image
FROM ubuntu:22.04

# Install required packages
RUN apt-get update && apt-get install -y \
    wget \
    openjdk-11-jdk \
    python3 \
    python3-pip \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install OWASP ZAP
RUN wget -v https://github.com/zaproxy/zaproxy/releases/download/v2.15.0/ZAP_2.15.0_Linux.tar.gz -O /tmp/zap.tar.gz \
    && tar -xzf /tmp/zap.tar.gz -C /opt \
    && rm /tmp/zap.tar.gz \
    && ln -s /opt/ZAP_2.15.0 /opt/zap

# Download compatible zap-baseline.py for 2.15.0
RUN wget https://github.com/zaproxy/zaproxy/releases/download/v2.15.0/zap-baseline.py -O /opt/zap/zap-baseline.py \
    && chmod +x /opt/zap/zap-baseline.py


# Add ZAP to PATH
ENV PATH="/opt/zap:$PATH"

# Set working directory
WORKDIR /app

# Install Python dependencies
RUN pip3 install --no-cache-dir Flask==2.3.3 fastapi

# Copy project files (including src/)
COPY . /app

# Make script executable
RUN chmod +x /app/run_and_scan.sh

# Expose Flask port
EXPOSE 5000

# Default command
CMD ["/app/run_and_scan.sh"]
