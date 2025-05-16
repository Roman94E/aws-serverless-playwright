# Base image for build
FROM mcr.microsoft.com/playwright/python:v1.52.0-jammy as build-image

# Define function directory
ARG FUNCTION_DIR="/function"

# Install only essential build dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    g++ make cmake unzip libcurl4-openssl-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create function directory and install dependencies
WORKDIR ${FUNCTION_DIR}
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir --target ${FUNCTION_DIR} -r requirements.txt

# Copy function code
COPY . .

# Final stage with only necessary runtime components
FROM mcr.microsoft.com/playwright/python:v1.52.0-jammy

ARG FUNCTION_DIR="/function"
WORKDIR ${FUNCTION_DIR}

# Install only runtime dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    fonts-liberation libappindicator3-1 libasound2 \
    libatk-bridge2.0-0 libatk1.0-0 libcups2 \
    libdbus-1-3 libgdk-pixbuf2.0-0 libnspr4 libnss3 \
    pciutils xdg-utils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy only needed files from build stage
COPY --from=build-image ${FUNCTION_DIR} ${FUNCTION_DIR}

# Set runtime interface client as default command
ENTRYPOINT ["python", "-m", "awslambdaric"]
CMD ["lambda_loader.handler"]