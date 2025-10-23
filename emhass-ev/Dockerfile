# EMHASS EV Extension Add-on Dockerfile
# Builds from tomvanacker85/emhass fork with EV charging extension

ARG BUILD_FROM
FROM ${BUILD_FROM}

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    python3 \
    python3-pip \
    python3-dev \
    coinor-cbc \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV PYTHONPATH="/app/src"
ENV EMHASS_PORT="5003"

# Create app directory
WORKDIR /app

# Clone your EV-enhanced EMHASS fork
RUN git clone --branch feature/ev-charging-extension \
    https://github.com/tomvanacker85/emhass.git /app/emhass-source

# Install Python dependencies
COPY requirements.txt /tmp/requirements.txt
RUN pip3 install --no-cache-dir -r /tmp/requirements.txt

# Install EMHASS with EV extension
RUN cd /app/emhass-source && \
    pip3 install --no-cache-dir -e .

# Copy run script
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

# Create data directories
RUN mkdir -p /share/emhass-ev /config /data

# Expose port
EXPOSE 5001

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:5001/ || exit 1

# Run EMHASS
CMD ["/app/run.sh"]