# -------------------------------
# Builder Stage
# -------------------------------
FROM python:3.12-slim AS builder

WORKDIR /app

# Install build dependencies
RUN apt-get update -y && apt-get install -y \
    gcc \
    pkg-config \
    libmariadb-dev \
    libmariadb-dev-compat \
 && rm -rf /var/lib/apt/lists/*

# Copy only requirements first (to leverage caching)
COPY requirements.txt .

# Install dependencies in a virtual environment
RUN python -m venv /opt/venv \
    && . /opt/venv/bin/activate \
    && pip install --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# -------------------------------
# Final Minimal Stage
# -------------------------------
FROM python:3.12-slim

WORKDIR /app

# Install runtime library (needed for libmariadb.so.3)
RUN apt-get update -y && apt-get install -y \
    libmariadb3 \
 && rm -rf /var/lib/apt/lists/*

# Copy virtual environment from builder
COPY --from=builder /opt/venv /opt/venv

# Use the venv as the default Python
ENV PATH="/opt/venv/bin:$PATH"

# Copy application code
COPY . .

# Run the app
CMD ["python", "app.py"]
