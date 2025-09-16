# Use Python 3.9 slim for M2 Mac compatibility
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    wget \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . .

# Create directories for data and models
RUN mkdir -p data models logs

# Expose port for Jupyter notebook or Flask app
EXPOSE 8888 5000

# Default command
CMD ["python", "train_model.py"]