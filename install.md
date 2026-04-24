# Installation de Coder 🚀

Ce guide vous explique comment installer et configurer votre propre environnement de développement cloud utilisant [Coder](https://coder.com).

## 📋 Prérequis

*   **Serveur :** Ubuntu ou Debian (recommandé : 8 Go RAM, 2 CPU, 100 Go SSD).
*   **Domaine :** Un nom de domaine (appelé `domain.dev` dans ce guide).
*   **Cloudflare :** Un compte Cloudflare pour la gestion DNS et le support de VS Code Web (Microsoft Marketplace).
*   **Docker :** Installé sur votre serveur.

---

## 🛠️ Étape 1 : Installation automatisée

Nous fournissons un script qui installe et configure automatiquement **Coder**, **Traefik** (proxy inverse) et **PostgreSQL**.

1. Connectez-vous à votre serveur en SSH.
2. Clonez ce dépôt ou téléchargez le script d'installation.
3. Exécutez le script en tant que root :

```bash
sudo bash coder/install.sh
```

Le script vous demandera votre **email** (pour SSL Let's Encrypt) et votre **nom de domaine**.

---

## 🌐 Étape 2 : Configuration DNS (Cloudflare)

Pour que Coder fonctionne avec des sous-domaines dynamiques (indispensable pour VS Code Web et les previews), vous devez configurer vos DNS :

1. Allez sur [Cloudflare Dash](https://dash.cloudflare.com/).
2. Ajoutez votre domaine si ce n'est pas déjà fait.
3. Créez deux enregistrements **A** pointant vers l'IP de votre serveur :
    *   `domain.dev` (proxied ✅)
    *   `*.domain.dev` (proxied ✅)

> [!IMPORTANT]
> Le mode "Proxy" de Cloudflare est recommandé pour bénéficier de la protection et des fonctionnalités avancées, mais assurez-vous que le mode SSL/TLS est réglé sur "Full" ou "Full (strict)".

---

## 🔧 Étape 3 : Ajustements Traefik

Si vous utilisez un wildcard différent ou si vous avez des besoins spécifiques, éditez la configuration dynamique de Traefik :

```bash
nano /etc/traefik/dynamic.yml
```

Vérifiez que la règle Host correspond bien à votre domaine :
```yaml
rule: "Host(`domain.dev`) || HostRegexp(`^.+\\.domain\\.dev$`)"
```

Redémarrez les services pour appliquer les changements :

```bash
systemctl daemon-reload
systemctl restart coder
systemctl restart traefik
```

---

## 🏗️ Étape 4 : Configuration du Template Docker

Une fois connecté à votre interface Coder (https://domain.dev) :

1. **Dockerfile :** Placez le `Dockerfile` fourni dans ce repo sur votre serveur hôte (par exemple dans `/root/images/base/Dockerfile`).
2. **Créer un Template :** Dans Coder, créez un nouveau template de type "Docker Containers".
3. **Terraform :** Utilisez le fichier `coder/template/main.tf` fourni dans ce dépôt.
4. **Chemin du Dockerfile :** À la ligne 355 du `main.tf`, vérifiez que le chemin correspond à l'endroit où vous avez mis votre Dockerfile :
    ```hcl
    context = "/root/images/base"
    ```

---

## 🚀 Étape 5 : Créez votre Workspace

1. Allez dans l'onglet **Workspaces**.
2. Cliquez sur **Create Workspace**.
3. Choisissez votre template Docker.
4. Sélectionnez le template de projet souhaité (React, Python, Go, etc.) via les paramètres.
5. Lancez et commencez à coder ! 💻

---

## 💡 Astuces & Dépannage

*   **Logs :** `journalctl -u coder -f` ou `journalctl -u traefik -f`.
*   **JetBrains :** Pour utiliser IntelliJ ou PyCharm à distance, assurez-vous d'avoir installé [JetBrains Gateway](https://www.jetbrains.com/remote-development/gateway/) sur votre machine locale.
*   **VS Code Web :** En utilisant le template fourni, vous avez accès à `code-server` ET à l'interface officielle VS Code Web.
