FROM ubuntu:24.04

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# ============================================================================
# VERSION CONTROL - Update these to upgrade tools (all versions are pinned)
# ============================================================================
# Node.js ecosystem
ENV NVM_VERSION=v0.40.3
ENV NODE_VERSION=24.12.0
ENV PNPM_VERSION=10.26.1

# Java ecosystem
ENV JAVA_VERSION=25.0.1-tem
ENV MAVEN_VERSION=3.9.12
ENV GRADLE_VERSION=9.2.1

# Python (from Ubuntu 24.04 repos)
# Python3 version: 3.12.x (managed by apt)

# Container runtime
# Docker: Latest stable from get.docker.com
# ============================================================================

# Install base dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    sudo \
    locales \
    ca-certificates \
    gnupg \
    lsb-release \
    openssh-client \
    build-essential \
    python3 \
    python3-pip \
    python3-venv \
    zip \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Docker (Docker-in-Docker)
#RUN curl -fsSL https://get.docker.com -o get-docker.sh && \
#    sh get-docker.sh && \
#    rm get-docker.sh

# Configure locales
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Create non-root user with zsh as default shell
RUN useradd -m -s /bin/bash coder && \
    echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Create working directories
RUN mkdir -p /home/coder/workspace && \
    chown -R coder:coder /home/coder

# Switch to coder user for installing nvm and sdkman
USER coder
WORKDIR /home/coder

# Install NVM (Node Version Manager) with fixed version
ENV NVM_DIR=/home/coder/.nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh | bash && \
    . "$NVM_DIR/nvm.sh" && \
    nvm install ${NODE_VERSION} && \
    nvm use ${NODE_VERSION} && \
    nvm alias default ${NODE_VERSION} && \
    npm install -g pnpm@${PNPM_VERSION}

# Install SDKMAN (for Java and other JVM languages) with fixed versions
ENV SDKMAN_DIR=/home/coder/.sdkman
RUN curl -s "https://get.sdkman.io?rcupdate=false" | bash && \
    bash -c "source $SDKMAN_DIR/bin/sdkman-init.sh && \
    sdk install java ${JAVA_VERSION} && \
    sdk install maven ${MAVEN_VERSION} && \
    sdk install gradle ${GRADLE_VERSION} && \
    sdk default java ${JAVA_VERSION} && \
    sdk default maven ${MAVEN_VERSION} && \
    sdk default gradle ${GRADLE_VERSION}"

# Add nvm and sdkman to PATH for ALL shells (zshrc, bashrc, profile)
RUN echo 'export NVM_DIR="$HOME/.nvm"' >> /home/coder/.zshrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> /home/coder/.zshrc && \
    echo 'export SDKMAN_DIR="$HOME/.sdkman"' >> /home/coder/.zshrc && \
    echo '[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"' >> /home/coder/.zshrc && \
    echo 'export NVM_DIR="$HOME/.nvm"' >> /home/coder/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> /home/coder/.bashrc && \
    echo 'export SDKMAN_DIR="$HOME/.sdkman"' >> /home/coder/.bashrc && \
    echo '[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"' >> /home/coder/.bashrc && \
    echo 'export NVM_DIR="$HOME/.nvm"' >> /home/coder/.profile && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> /home/coder/.profile && \
    echo 'export SDKMAN_DIR="$HOME/.sdkman"' >> /home/coder/.profile && \
    echo '[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"' >> /home/coder/.profile

WORKDIR /home/coder

# Pas de ENTRYPOINT ni CMD - Coder va gérer ça via l'agent