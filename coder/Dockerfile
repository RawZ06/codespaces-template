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

# Go ecosystem
ENV ASDF_VERSION=v0.14.1
# Go version will be project-driven via .tool-versions

# Rust ecosystem
# Rust version will be project-driven via rust-toolchain.toml

# PHP ecosystem
# PHP version will be project-driven via .tool-versions

# Python (from Ubuntu 24.04 repos)
# Python3 version: 3.12.x (managed by apt)

# Container runtime
# Docker: Latest stable from get.docker.com
# ============================================================================

# ============================================================================
# BASE DEPENDENCIES
# ============================================================================

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
    pkg-config \
    \
    # PHP build deps (for asdf-php)
    autoconf \
    bison \
    re2c \
    libxml2-dev \
    libsqlite3-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    libonig-dev \
    libreadline-dev \
    libzip-dev \
    && rm -rf /var/lib/apt/lists/*

# ============================================================================
# LOCALES
# ============================================================================

RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# ============================================================================
# USER
# ============================================================================

RUN useradd -m -s /bin/bash coder && \
    echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN mkdir -p /home/coder/workspace && \
    chown -R coder:coder /home/coder

# ============================================================================
# USER CONTEXT
# ============================================================================

USER coder
WORKDIR /home/coder

# ============================================================================
# NVM (Node Version Manager)
# ============================================================================

ENV NVM_DIR=/home/coder/.nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh | bash && \
    . "$NVM_DIR/nvm.sh" && \
    nvm install ${NODE_VERSION} && \
    nvm use ${NODE_VERSION} && \
    nvm alias default ${NODE_VERSION} && \
    npm install -g pnpm@${PNPM_VERSION}

# ============================================================================
# SDKMAN (Java ecosystem)
# ============================================================================

ENV SDKMAN_DIR=/home/coder/.sdkman
RUN curl -s "https://get.sdkman.io?rcupdate=false" | bash && \
    bash -c "source $SDKMAN_DIR/bin/sdkman-init.sh && \
    sdk install java ${JAVA_VERSION} && \
    sdk install maven ${MAVEN_VERSION} && \
    sdk install gradle ${GRADLE_VERSION} && \
    sdk default java ${JAVA_VERSION} && \
    sdk default maven ${MAVEN_VERSION} && \
    sdk default gradle ${GRADLE_VERSION}"

# ============================================================================
# COMPOSER (PHP dependency manager)
# ============================================================================

RUN curl -sS https://getcomposer.org/installer | php -- \
    --install-dir=/home/coder/.local/bin \
    --filename=composer

# ============================================================================
# ASDF (Go, PHP, optional Python)
# ============================================================================

ENV ASDF_DIR=/home/coder/.asdf
RUN git clone https://github.com/asdf-vm/asdf.git $ASDF_DIR --branch ${ASDF_VERSION}

RUN bash -c "\
    source $ASDF_DIR/asdf.sh && \
    asdf plugin add golang https://github.com/asdf-community/asdf-golang.git && \
    asdf plugin add php https://github.com/asdf-community/asdf-php.git \
"

# No global install → versions selected per project via .tool-versions

# ============================================================================
# RUST (rustup)
# ============================================================================

ENV CARGO_HOME=/home/coder/.cargo
ENV RUSTUP_HOME=/home/coder/.rustup

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
# Rust version managed per project via rust-toolchain.toml

# ============================================================================
# SHELL CONFIG (bash / profile)
# ============================================================================

RUN echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc && \
    echo 'export SDKMAN_DIR="$HOME/.sdkman"' >> ~/.bashrc && \
    echo '[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"' >> ~/.bashrc && \
    echo '. "$HOME/.asdf/asdf.sh"' >> ~/.bashrc && \
    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc && \
    \
    echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.profile && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.profile && \
    echo 'export SDKMAN_DIR="$HOME/.sdkman"' >> ~/.profile && \
    echo '[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"' >> ~/.profile && \
    echo '. "$HOME/.asdf/asdf.sh"' >> ~/.profile && \
    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.profile && \
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc && \
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.profile

WORKDIR /home/coder

# Pas de ENTRYPOINT ni CMD - Coder va gérer ça via l'agent