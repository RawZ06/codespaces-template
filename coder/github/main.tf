terraform {
  required_providers {
    coder = {
      source  = "coder/coder"
      version = ">= 2.5.0"
    }
    docker = {
      source = "kreuzwerker/docker"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }

  }
}

locals {
  username        = data.coder_workspace_owner.me.name
  github_repo_url = data.coder_parameter.github_repo.value
  exposed_ports   = length(trimspace(data.coder_parameter.ports.value)) > 0 ? split(",", replace(data.coder_parameter.ports.value, " ", "")) : []
  
  # Construction directe des URLs de clone depuis les full_names (un seul appel GitHub)
  repo_options = {
    for full_name in data.github_repositories.mine.full_names :
    full_name => "https://github.com/${full_name}.git"
  }
}

variable "docker_socket" {
  default     = ""
  description = "(Optional) Docker socket URI"
  type        = string
}

# --- Paramètre Coder : liste déroulante ---
data "coder_parameter" "github_repo" {
  name         = "github_repo"
  display_name = "GitHub Repository"
  description  = "Choisis un dépôt à cloner dans la workspace"
  type         = "string"
  form_type    = "dropdown"

  # Défaut : le premier repo de la liste
  default = try(local.repo_options[element(data.github_repositories.mine.full_names, 0)], "")

  # Génère automatiquement les options depuis GitHub
  dynamic "option" {
    for_each = local.repo_options
    content {
      name  = option.key   # ex: "RawZ06/mon-repo"
      value = option.value # ex: "https://github.com/RawZ06/mon-repo.git"
      icon  = "/icon/github.svg"
    }
  }
}


data "coder_parameter" "ports" {
  name         = "ports"
  display_name = "Exposed ports"
  description  = "Comma-separated list of ports to expose (e.g. 3000,8080)"
  type         = "string"
  default      = ""
  mutable      = false
}

provider "docker" {
  host = var.docker_socket != "" ? var.docker_socket : null
}

provider "github" {}

data "coder_provisioner" "me" {}
data "coder_workspace" "me" {}
data "coder_workspace_owner" "me" {}

# Un seul appel GitHub pour récupérer tous les repos
data "github_repositories" "mine" {
  query = "user:RawZ06"
  sort  = "updated"
}


resource "coder_agent" "main" {
  arch = data.coder_provisioner.me.arch
  os   = "linux"

  startup_script = <<-EOT

    # Create workspace directory
    mkdir -p ~/workspace

    # Configure Git with Coder user info (GitHub will be linked via Coder)
    git config --global user.name "${coalesce(data.coder_workspace_owner.me.full_name, data.coder_workspace_owner.me.name)}"
    git config --global user.email "${data.coder_workspace_owner.me.email}"

    # Prepare user home with default files on first start
    if [ ! -f ~/.init_done ]; then
      cp -rn /etc/skel ~ 2>/dev/null || true
      touch ~/.init_done
    fi
    
    # Ensure all environment variables are in bashrc (in case volume overwrote it)
    if ! grep -q "NVM_DIR" ~/.bashrc; then
      echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc
      echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc
    fi
    if ! grep -q "SDKMAN_DIR" ~/.bashrc; then
      echo 'export SDKMAN_DIR="$HOME/.sdkman"' >> ~/.bashrc
      echo '[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"' >> ~/.bashrc
    fi
    if ! grep -q "CARGO_HOME" ~/.bashrc; then
      echo 'export CARGO_HOME="$HOME/.cargo"' >> ~/.bashrc
      echo 'export RUSTUP_HOME="$HOME/.rustup"' >> ~/.bashrc
    fi
    if ! grep -q "GOROOT" ~/.bashrc; then
      echo 'export GOROOT="$HOME/.local/go"' >> ~/.bashrc
      echo 'export GOPATH="$HOME/go"' >> ~/.bashrc
    fi
    if ! grep -q "\.local/bin" ~/.bashrc; then
      echo 'export PATH="/usr/local/bin:/usr/bin:$GOROOT/bin:$GOPATH/bin:$CARGO_HOME/bin:$HOME/.local/bin:$PATH"' >> ~/.bashrc
    fi

    # Load all environment variables for this session
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    export SDKMAN_DIR="$HOME/.sdkman"
    [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
    export CARGO_HOME="$HOME/.cargo"
    export RUSTUP_HOME="$HOME/.rustup"
    export GOROOT="$HOME/.local/go"
    export GOPATH="$HOME/go"
    export PATH="/usr/local/bin:/usr/bin:$GOROOT/bin:$GOPATH/bin:$CARGO_HOME/bin:$HOME/.local/bin:$PATH"

    
    # Initialize workspace based on mode
    cd ~/workspace
    # Clone from GitHub repository
    REPO_URL="${local.github_repo_url}"

    if [ -n "$REPO_URL" ]; then
      echo "🔗 Cloning repository from GitHub..."
      echo "Repository: $REPO_URL"

      # Clone the repository into current directory
      git clone "$REPO_URL" .

      echo "✓ Repository cloned successfully!"

      # Auto-detect and install dependencies if needed
      if [ -f "package.json" ]; then
        echo "📦 Detected package.json, installing Node.js dependencies..."
        pnpm install
      elif [ -f "pom.xml" ]; then
        echo "📦 Detected pom.xml, installing Maven dependencies..."
        mvn install
      elif [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
        echo "📦 Detected Gradle project, installing dependencies..."
        gradle build
      elif [ -f "requirements.txt" ]; then
        echo "📦 Detected requirements.txt, installing Python dependencies..."
        pip install -r requirements.txt
      elif [ -f "composer.json" ]; then
        echo "📦 Detected composer.json, installing PHP dependencies..."
        composer install
      fi
    else
      echo "⚠ No repository URL provided, starting with empty workspace"
    fi
    [ -f "$HOME/.zshrc" ] && . "$HOME/.zshrc"
    echo "Workspace ready!"
  EOT

  env = {
    GIT_AUTHOR_NAME     = coalesce(data.coder_workspace_owner.me.full_name, data.coder_workspace_owner.me.name)
    GIT_AUTHOR_EMAIL    = "${data.coder_workspace_owner.me.email}"
    GIT_COMMITTER_NAME  = coalesce(data.coder_workspace_owner.me.full_name, data.coder_workspace_owner.me.name)
    GIT_COMMITTER_EMAIL = "${data.coder_workspace_owner.me.email}"
  }

  # Metadata pour afficher les stats dans le dashboard
  metadata {
    display_name = "CPU Usage"
    key          = "0_cpu_usage"
    script       = "coder stat cpu"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "RAM Usage"
    key          = "1_ram_usage"
    script       = "coder stat mem"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "Home Disk"
    key          = "3_home_disk"
    script       = "coder stat disk --path $${HOME}"
    interval     = 60
    timeout      = 1
  }

  metadata {
    display_name = "CPU Usage (Host)"
    key          = "4_cpu_usage_host"
    script       = "coder stat cpu --host"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "Memory Usage (Host)"
    key          = "5_mem_usage_host"
    script       = "coder stat mem --host"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "Load Average (Host)"
    key          = "6_load_host"
    script       = <<EOT
      echo "`cat /proc/loadavg | awk '{ print $1 }'` `nproc`" | awk '{ printf "%0.2f", $1/$2 }'
    EOT
    interval     = 60
    timeout      = 1
  }

  metadata {
    display_name = "Swap Usage (Host)"
    key          = "7_swap_host"
    script       = <<EOT
      free -b | awk '/^Swap/ { printf("%.1f/%.1f", $3/1024.0/1024.0/1024.0, $2/1024.0/1024.0/1024.0) }'
    EOT
    interval     = 10
    timeout      = 1
  }
}

resource "coder_app" "apps" {
  for_each = toset(local.exposed_ports)

  agent_id = coder_agent.main.id
  slug     = "port-${each.value}"
  display_name = "Port ${each.value}"

  url = "http://localhost:${each.value}"
  icon = "/icons/port.svg"

  subdomain = true
}

# VS Code Browser (code-server)
module "code-server" {
  count   = data.coder_workspace.me.start_count
  source  = "registry.coder.com/coder/code-server/coder"
  version = "~> 1.0"

  agent_id = coder_agent.main.id
  order    = 1
  folder   = "/home/coder/workspace"

  settings = {
    "workbench.iconTheme": "material-icon-theme",
    "workbench.colorTheme": "Default Dark Modern",
    "window.autoDetectColorScheme": true,
    "workbench.preferredDarkColorTheme": "Default Dark Modern",
    "workbench.preferredLightColorTheme": "Default Light Modern",
  }

  extensions = [
    "pkief.material-icon-theme",
    "mhutchie.git-graph",
  ]
}

#VS Code Web (Official)
module "vscode-web" {
  count   = data.coder_workspace.me.start_count
  source  = "registry.coder.com/coder/vscode-web/coder"
  version = "~> 1.0"

  agent_id = coder_agent.main.id
  folder   = "/home/coder/workspace"
  order    = 1

  settings = {
    "workbench.iconTheme": "material-icon-theme",
    "workbench.colorTheme": "Default Dark Modern",
    "window.autoDetectColorScheme": true,
    "workbench.preferredDarkColorTheme": "Default Dark Modern",
    "workbench.preferredLightColorTheme": "Default Light Modern",
  }

  accept_license=true

  extensions = [
    # UI
    "pkief.material-icon-theme",
    "mhutchie.git-graph",
  ]
}

# JetBrains IDEs
module "jetbrains" {
  count      = data.coder_workspace.me.start_count
  source     = "registry.coder.com/coder/jetbrains/coder"
  version    = "~> 1.1"
  agent_id   = coder_agent.main.id
  agent_name = "main"
  folder     = "/home/coder/workspace"
  tooltip    = "You need to install JetBrains Toolbox to use this app."
}

module "filebrowser" {
  count    = data.coder_workspace.me.start_count
  source   = "registry.coder.com/coder/filebrowser/coder"
  version  = "1.1.3"
  agent_id = coder_agent.main.id
}

# Build l'image depuis /root/images/base sur le VPS
resource "docker_image" "coder_image" {
  name = "codespace-custom:latest"
  build {
    context    = "/root/images/base"
    dockerfile = "Dockerfile"
#    no_cache   = true
  }
  keep_locally = true

  # Force rebuild à chaque fois
#  triggers = {
#    always_rebuild = timestamp()
#  }
}

# Volume persistant pour /home/coder
resource "docker_volume" "home_volume" {
  name = "coder-${data.coder_workspace.me.id}-home"

  lifecycle {
    ignore_changes = all
  }

  labels {
    label = "coder.owner"
    value = data.coder_workspace_owner.me.name
  }
  labels {
    label = "coder.owner_id"
    value = data.coder_workspace_owner.me.id
  }
  labels {
    label = "coder.workspace_id"
    value = data.coder_workspace.me.id
  }
  labels {
    label = "coder.workspace_name_at_creation"
    value = data.coder_workspace.me.name
  }
}

# Container Docker pour le workspace
resource "docker_container" "workspace" {
  count = data.coder_workspace.me.start_count
  image = docker_image.coder_image.name
  name  = "coder-${data.coder_workspace_owner.me.name}-${lower(data.coder_workspace.me.name)}"

  hostname = data.coder_workspace.me.name

  # Entrypoint pour lancer l'agent Coder
  entrypoint = ["sh", "-c", replace(coder_agent.main.init_script, "/localhost|127\\.0\\.0\\.1/", "host.docker.internal")]

  env = ["CODER_AGENT_TOKEN=${coder_agent.main.token}"]

  host {
    host = "host.docker.internal"
    ip   = "host-gateway"
  }

  volumes {
    container_path = "/home/coder"
    volume_name    = docker_volume.home_volume.name
    read_only      = false
  }

  # Labels pour tracking
  labels {
    label = "coder.owner"
    value = data.coder_workspace_owner.me.name
  }
  labels {
    label = "coder.owner_id"
    value = data.coder_workspace_owner.me.id
  }
  labels {
    label = "coder.workspace_id"
    value = data.coder_workspace.me.id
  }
  labels {
    label = "coder.workspace_name"
    value = data.coder_workspace.me.name
  }
}
