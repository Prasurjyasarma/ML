# ----------------------------------------------------------------------
# STAGE 1: Builder Stage (for compiling and installing dependencies)
# ----------------------------------------------------------------------
# Use a full-featured image for building/compiling
FROM python:3.9 as builder

# Set working directory
WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install -y \
    gcc g++ \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# ----------------------------------------------------------------------
# STAGE 2: Production Stage (minimal runtime image)
# ----------------------------------------------------------------------
# Use the minimal 'slim' image for the final, smaller container
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Install runtime dependencies AND tools needed for remote development
# procps: provides 'ps' command (process status)
# openssh-server: if you need SSH access
# Other common utilities for development/debugging
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    git \
    procps \
    psmisc \
    lsof \
    net-tools \
    && rm -rf /var/lib/apt/lists/*

# Copy installed Python packages from the builder stage
COPY --from=builder /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Copy project files
COPY . .

# Create directories and expose ports (as before)
RUN mkdir -p data models logs
EXPOSE 8888 5000

# Default command
CMD ["python", "train_model.py"]