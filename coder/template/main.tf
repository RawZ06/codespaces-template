terraform {
  required_providers {
    coder = {
      source  = "coder/coder"
      version = ">= 2.5.0"
    }
    docker = {
      source = "kreuzwerker/docker"
    }
    # Le provider HTTP est nécessaire pour lire le JSON externe
    http = {
      source = "hashicorp/http"
    }
  }
}

# 1. Récupération de la liste des templates depuis ton GitHub
data "http" "templates_source" {
  # Change cette URL par l'URL RAW de ton fichier templates.json
  url = "https://raw.githubusercontent.com/RawZ06/codespaces-template/main/templates.json"
}

locals {
  username      = data.coder_workspace_owner.me.name
  
  # 2. Parsing du JSON
  # S'il y a une erreur de décodage, retourne une liste vide []
  templates = try(jsondecode(data.http.templates_source.response_body), [])

  # CORRECTION MAJEURE: Utilisation de one() pour extraire l'objet correspondant au template sélectionné.
  # one() prend la liste résultante de la boucle for (qui devrait contenir 0 ou 1 élément) et retourne l'élément, ou null.
  selected_template = one([
    for t in local.templates : t 
    if t.value == data.coder_parameter.project_template.value
  ])

  # Les ports exposés sont automatiquement ceux du template sélectionné
  template_ports = try(local.selected_template.ports, [])

  # Ports additionnels saisis par l'utilisateur
  additional_ports = length(trimspace(data.coder_parameter.additional_ports.value)) > 0 ? split(",", replace(data.coder_parameter.additional_ports.value, " ", "")) : []

  # Combinaison des ports du template + ports additionnels
  exposed_ports = concat(
    [for port in local.template_ports : tostring(port)],
    local.additional_ports
  )
}

variable "docker_socket" {
  default     = ""
  description = "(Optional) Docker socket URI"
  type        = string
}

data "coder_parameter" "project_template" {
  name         = "project_template"
  display_name = "Project Template"
  description  = "Choose a starter template for your workspace"
  default      = "blank"
  type         = "string"
  mutable      = false
  form_type    = "dropdown"

  # Option par défaut "Blank" toujours présente
  option {
    name  = "Blank"
    icon  = "/icon/folder.svg"
    value = "blank"
  }

  # 4. Génération dynamique des options depuis le JSON
  dynamic "option" {
    for_each = local.templates
    content {
      name  = option.value.name
      # Utilisation de try() sur le champ icon pour la robustesse
      icon  = try(option.value.icon, "/icon/folder.svg")
      value = option.value.value
    }
  }
}

data "coder_parameter" "additional_ports" {
  name         = "additional_ports"
  display_name = "Additional ports (optional)"
  description  = "Comma-separated list of extra ports to expose. Template ports are already included automatically."
  type         = "string"
  default      = ""
  mutable      = true
}

provider "docker" {
  host = var.docker_socket != "" ? var.docker_socket : null
}

data "coder_provisioner" "me" {}
data "coder_workspace" "me" {}
data "coder_workspace_owner" "me" {}

resource "coder_agent" "main" {
  arch = data.coder_provisioner.me.arch
  os   = "linux"

  # On passe les infos du template sélectionné en variables d'environnement
  env = {
    GIT_AUTHOR_NAME     = coalesce(data.coder_workspace_owner.me.full_name, data.coder_workspace_owner.me.name)
    GIT_AUTHOR_EMAIL    = "${data.coder_workspace_owner.me.email}"
    GIT_COMMITTER_NAME  = coalesce(data.coder_workspace_owner.me.full_name, data.coder_workspace_owner.me.name)
    GIT_COMMITTER_EMAIL = "${data.coder_workspace_owner.me.email}"

    # On utilise try() pour accéder aux attributs même si selected_template est null
    TEMPLATE_URL        = try(local.selected_template.url, "")
    TEMPLATE_FOLDER     = try(local.selected_template.folder, "")
    TEMPLATE_NAME       = try(local.selected_template.name, "Blank")
  }

  startup_script = <<-EOT
    set -e # Arrêter le script si une commande échoue

    # Préparation du répertoire personnel (Home dir)
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
    
    # Créer et se déplacer dans le dossier de travail
    mkdir -p ~/workspace
    cd ~/workspace

    # Configurer Git
    git config --global user.name "${coalesce(data.coder_workspace_owner.me.full_name, data.coder_workspace_owner.me.name)}"
    git config --global user.email "${data.coder_workspace_owner.me.email}"

    # ---------------------------------------------------------
    # LOGIQUE D'INITIALISATION DU TEMPLATE (Nettoyée)
    # ---------------------------------------------------------
    
    # 1. Vérification si le marqueur d'installation existe dans le dossier parent ($HOME)
    if [ -f "$HOME/.template_installed" ]; then
      echo "✓ Template already installed (marker found in $HOME)."
      # Si c'est un reboot, on ne fait rien
    elif [ -z "$TEMPLATE_URL" ]; then
      # Si c'est le premier démarrage et pas de template sélectionné
      echo "✓ Blank workspace initialized (no template selected)"
      touch "$HOME/.template_installed"
    else
      # 2. Processus d'installation du template
      echo "📦 Downloading template: $TEMPLATE_NAME..."

      curl -L "$TEMPLATE_URL" -o template.zip
      unzip -q template.zip && rm template.zip

      # 3. Exécution et suppression du script de setup
      if [ -f ".coder-setup.sh" ]; then
        echo "🔧 Found .coder-setup.sh, executing and cleaning up..."
        chmod +x .coder-setup.sh
        ./.coder-setup.sh
        # Suppression du script pour garder le dossier propre
        rm -f .coder-setup.sh
        echo "✓ Setup script executed and removed."
      else
        echo "ℹ No .coder-setup.sh found. Skipping setup."
      fi

      # 4. Création du marqueur dans le dossier parent ($HOME)
      touch "$HOME/.template_installed"
    fi

    # Charger les configurations shell potentielles (pour les outils installés par setup.sh)
    [ -f "$HOME/.zshrc" ] && . "$HOME/.zshrc"
    echo "Workspace ready!"
  EOT

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
  icon = "/icon/port.svg"

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
    "workbench.preferredLightColorTheme": "Default Light Modern"
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
    "workbench.preferredLightColorTheme": "Default Light Modern"
  }

  accept_license = true

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