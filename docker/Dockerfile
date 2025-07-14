FROM python:3.12-slim as builder

# Improve Python behavior in containers:
# - Disable stdout/stderr buffering
# - Prevent .pyc files generation
# - Avoid pip cache to reduce image size
# - Disable pip version check to silence warnings
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

RUN apt-get update && apt-get install -y \
    build-essential \
    libffi-dev \
    libssl-dev \
    python3-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

RUN uv venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy Python dependency definitions for layer caching and faster install
COPY docker/pyproject.toml /tmp/pyproject.toml
COPY docker/uv.lock /tmp/uv.lock

WORKDIR /tmp
RUN uv sync --frozen --no-dev

FROM python:3.12-slim

# 設定標籤
LABEL maintainer="ouroborosng"
LABEL description="Docker image for Ansible Molecule testing with tox"
LABEL version="1.0.0"

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PATH="/opt/venv/bin:$PATH"

RUN apt-get update && apt-get install -y \
    curl \
    git \
    docker.io \
    openssh-client \
    rsync \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Copy the prebuilt virtual environment with installed dependencies
COPY --from=builder /opt/venv /opt/venv

# Create runner user
RUN groupadd -g 1001 runner && \
    useradd -r -u 1001 -g runner -d /home/runner runner && \
    usermod -aG docker runner && \
    mkdir -p /home/runner && \
    chown -R runner:runner /home/runner

# Copy entrypoint script
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# 設定工作目錄
WORKDIR /workspace

# 切換到非 root 使用者
USER runner

# 設定入口點
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# 預設指令
CMD ["tox", "--help"]
