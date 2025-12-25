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
ENV GO_VERSION=1.22.4

# Rust ecosystem
ENV RUST_VERSION=1.77.2

# PHP ecosystem
ENV PHP_VERSION=8.5

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
    pkg-config

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
# PHP – installation manuelle (version figée)
# ============================================================================
RUN sudo apt-get update && sudo apt-get install -y software-properties-common && \
    sudo add-apt-repository -y ppa:ondrej/php && \
    sudo apt-get update

RUN sudo apt-get install -y \
    php${PHP_VERSION} \
    php${PHP_VERSION}-cli \
    php${PHP_VERSION}-common \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-soap \
    php${PHP_VERSION}-intl \
    php${PHP_VERSION}-sqlite3 \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-zip

# ============================================================================
# COMPOSER (PHP dependency manager)
# ============================================================================
# Assure-toi que le dossier existe
RUN mkdir -p /home/coder/.local/bin

# Installer Composer
RUN curl -sS https://getcomposer.org/installer | php -- \
    --install-dir=/home/coder/.local/bin \
    --filename=composer

# ============================================================================
# RUST (rustup)
# ============================================================================

ENV CARGO_HOME=/home/coder/.cargo
ENV RUSTUP_HOME=/home/coder/.rustup
ENV PATH="$CARGO_HOME/bin:$PATH"

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain ${RUST_VERSION}

# ============================================================================
# GO (version figée)
# ============================================================================
ENV GOROOT=/home/coder/.local/go
ENV GOPATH=/home/coder/go
ENV PATH="$GOROOT/bin:$GOPATH/bin:$PATH"

RUN curl -fsSL https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz -o go.tar.gz && \
    mkdir -p "$GOROOT" && \
    tar -C "$GOROOT" --strip-components=1 -xzf go.tar.gz && \
    rm go.tar.gz

RUN go version

# ============================================================================
# SHELL CONFIG (bash / profile)
# ============================================================================

RUN echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc && \
    echo 'export SDKMAN_DIR="$HOME/.sdkman"' >> ~/.bashrc && \
    echo '[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"' >> ~/.bashrc && \
    echo 'export CARGO_HOME="$HOME/.cargo"' >> ~/.bashrc && \
    echo 'export RUSTUP_HOME="$HOME/.rustup"' >> ~/.bashrc && \
    echo 'export GOROOT="$HOME/.local/go"' >> ~/.bashrc && \
    echo 'export GOPATH="$HOME/go"' >> ~/.bashrc && \
    echo 'export PATH="/usr/local/bin:/usr/bin:$GOROOT/bin:$GOPATH/bin:$CARGO_HOME/bin:$HOME/.local/bin:$PATH"' >> ~/.bashrc && \
    \
    echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.profile && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.profile && \
    echo 'export SDKMAN_DIR="$HOME/.sdkman"' >> ~/.profile && \
    echo '[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"' >> ~/.profile && \
    echo 'export CARGO_HOME="$HOME/.cargo"' >> ~/.profile && \
    echo 'export RUSTUP_HOME="$HOME/.rustup"' >> ~/.profile && \
    echo 'export GOROOT="$HOME/.local/go"' >> ~/.profile && \
    echo 'export GOPATH="$HOME/go"' >> ~/.profile && \
    echo 'export PATH="/usr/local/bin:/usr/bin:$GOROOT/bin:$GOPATH/bin:$CARGO_HOME/bin:$HOME/.local/bin:$PATH"' >> ~/.profile
    
WORKDIR /home/coder

# Pas de ENTRYPOINT ni CMD - Coder va gérer ça via l'agent