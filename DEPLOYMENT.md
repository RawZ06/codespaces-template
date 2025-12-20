# Guide de déploiement

Instructions pour déployer ce repository de templates Coder.

## 📋 Prérequis

- Un compte GitHub
- Git installé localement
- (Optionnel) Java 25, Node.js 20, Python 3.12, GCC, PHP 8.3 pour tester localement

## 🚀 Déploiement initial

### 1. Créer le repository GitHub

```bash
# Dans le dossier templates
git init
git add .
git commit -m "Initial commit: Coder templates with CI/CD"
```

Créer un repository sur GitHub (ex: `votre-user/templates`), puis :

```bash
git remote add origin git@github.com:VOTRE-USER/templates.git
git branch -M main
git push -u origin main
```

### 2. Mettre à jour les URLs dans README.md

Remplacer `VOTRE-USER` par votre username GitHub dans :
- `README.md`
- Tous les exemples de code

```bash
# Rechercher et remplacer
find . -name "*.md" -type f -exec sed -i '' 's/VOTRE-USER/votre-username/g' {} \;
```

### 3. Activer GitHub Actions

Les workflows sont dans `.github/workflows/` et s'activeront automatiquement au premier push.

**Vérification :**
1. Aller sur `https://github.com/VOTRE-USER/templates/actions`
2. Vérifier que "Test Templates" se lance
3. Attendre la fin des tests
4. Vérifier que "Build Templates" se lance après succès

### 4. Vérifier le dossier /output

Après le premier run réussi :
1. Les archives `.zip` seront dans `/output`
2. Un nouveau commit sera créé automatiquement
3. Les URLs seront disponibles :
   ```
   https://raw.githubusercontent.com/VOTRE-USER/templates/main/output/react.zip
   ```

## 🔧 Configuration avancée

### Permissions GitHub Actions

Si le push automatique échoue, vérifier les permissions :

1. Aller dans `Settings → Actions → General`
2. Sous "Workflow permissions", sélectionner :
   - ✅ **Read and write permissions**
3. Sauvegarder

### Branch Protection

Pour protéger `main` :

1. `Settings → Branches → Add rule`
2. Branch name pattern : `main`
3. Activer :
   - ✅ Require status checks to pass
   - ✅ Require branches to be up to date
   - Sélectionner : `all-tests-passed`
4. Sauvegarder

Ainsi, impossible de merger si les tests échouent !

### Secrets (si nécessaire)

Pour des templates nécessitant des secrets :

1. `Settings → Secrets and variables → Actions`
2. New repository secret
3. Ajouter dans les workflows :
   ```yaml
   env:
     API_KEY: ${{ secrets.API_KEY }}
   ```

## 📦 Intégration avec Coder

### Template Terraform de base

Créer un fichier `main.tf` dans votre projet Coder :

```hcl
terraform {
  required_providers {
    coder = {
      source = "coder/coder"
    }
  }
}

data "coder_parameter" "template_choice" {
  name         = "template_choice"
  display_name = "Template"
  description  = "Choose a starter template"
  default      = "react"
  mutable      = false
  option {
    name  = "Node.js"
    value = "node"
  }
  option {
    name  = "NestJS"
    value = "nestjs"
  }
  option {
    name  = "React + Vite"
    value = "react"
  }
  option {
    name  = "Vue + Vite"
    value = "vue"
  }
  option {
    name  = "Angular"
    value = "angular"
  }
  option {
    name  = "Java Vanilla"
    value = "java-vanilla"
  }
  option {
    name  = "Spring Boot 4"
    value = "java-springboot"
  }
  option {
    name  = "Python"
    value = "python"
  }
  option {
    name  = "C"
    value = "c"
  }
  option {
    name  = "PHP"
    value = "php"
  }
}

resource "coder_agent" "main" {
  arch = "amd64"
  os   = "linux"

  startup_script = <<-EOT
    #!/bin/bash
    set -e

    # Télécharger le template
    wget -q https://raw.githubusercontent.com/VOTRE-USER/templates/main/output/${data.coder_parameter.template_choice.value}.zip

    # Extraire
    unzip -q ${data.coder_parameter.template_choice.value}.zip
    cd ${data.coder_parameter.template_choice.value}

    # Installer les dépendances selon le type
    case "${data.coder_parameter.template_choice.value}" in
      node|nestjs|react|vue|angular)
        echo "📦 Installing pnpm dependencies..."
        pnpm install
        ;;
      java-vanilla|java-springboot)
        echo "📦 Building with Maven..."
        mvn clean install -DskipTests
        ;;
      python)
        echo "📦 Installing Python dependencies..."
        [ -f requirements.txt ] && pip install -r requirements.txt
        ;;
      php)
        echo "📦 Installing Composer dependencies..."
        composer install
        ;;
    esac

    echo "✅ Template ready!"
  EOT
}

resource "coder_app" "code-server" {
  agent_id     = coder_agent.main.id
  slug         = "code-server"
  display_name = "VS Code"
  url          = "http://localhost:8080"
  icon         = "/icon/code.svg"
  subdomain    = true
  share        = "owner"
}

# ... reste de votre configuration Docker/Kubernetes
```

### Tester l'intégration

```bash
# Dans votre workspace Coder
cd /workspace
wget https://raw.githubusercontent.com/VOTRE-USER/templates/main/output/react.zip
unzip react.zip
cd react
pnpm install
pnpm dev
```

## 🔄 Workflow de mise à jour

### Modifier un template

```bash
# 1. Créer une branche
git checkout -b update/react-template

# 2. Modifier le template
cd react
# ... modifications ...

# 3. Tester localement
pnpm install
pnpm run build

# 4. Commit et push
git add .
git commit -m "Update React template: add new component"
git push origin update/react-template

# 5. Créer une Pull Request
# Les tests GitHub Actions se lancent automatiquement

# 6. Si tests OK, merger dans main
# Les archives seront automatiquement mises à jour
```

### Ajouter un nouveau template

```bash
# 1. Créer le dossier
mkdir nouveau-template
cd nouveau-template

# 2. Initialiser le template
# ... créer les fichiers ...

# 3. Ajouter les tests dans .github/workflows/test-templates.yml
# 4. Ajouter le zip dans .github/workflows/build-templates.yml
# 5. Mettre à jour README.md

# 6. Commit et push
git add .
git commit -m "Add nouveau-template"
git push
```

## 📊 Monitoring

### Vérifier les builds

1. GitHub Actions : `https://github.com/VOTRE-USER/templates/actions`
2. Consulter les logs en cas d'échec
3. Les badges dans README.md montrent le statut

### Vérifier les archives

```bash
# Lister toutes les archives
ls -lh output/

# Tester le téléchargement
wget https://raw.githubusercontent.com/VOTRE-USER/templates/main/output/react.zip
unzip -l react.zip
```

### Statistiques utiles

```bash
# Taille totale des archives
du -sh output/

# Nombre de fichiers par template
for dir in */; do echo "$dir: $(find "$dir" -type f | wc -l) files"; done

# Dernières modifications
git log --oneline -10
```

## 🐛 Dépannage

### Les tests échouent

**Problème : Build Java échoue**
```
Solution: Vérifier que Java 25 est disponible dans GitHub Actions
```

**Problème : pnpm audit trouve des CVEs**
```
Solution: Mettre à jour les dépendances
cd template-concerné
pnpm update
pnpm audit fix
```

### Le build ne se déclenche pas

**Vérifier :**
1. Les tests ont réussi
2. Les permissions GitHub Actions (Settings → Actions → General)
3. Pas de message `[skip ci]` dans le commit manuel

### Les archives ne sont pas créées

**Vérifier :**
1. Le workflow "Build Templates" dans Actions
2. Les logs du job
3. Les permissions d'écriture du bot GitHub Actions

## 📚 Ressources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Coder Documentation](https://coder.com/docs)
- [OWASP Dependency Check](https://owasp.org/www-project-dependency-check/)

## ✅ Checklist de déploiement

- [ ] Repository GitHub créé
- [ ] Code pushé sur `main`
- [ ] URLs mises à jour (remplacer `VOTRE-USER`)
- [ ] Permissions GitHub Actions activées
- [ ] Premier workflow "Test Templates" réussi
- [ ] Premier workflow "Build Templates" réussi
- [ ] Dossier `/output` créé avec les archives
- [ ] Templates testés avec `wget` + `unzip`
- [ ] Template Coder configuré
- [ ] Documentation à jour
- [ ] Branch protection configurée (optionnel)
- [ ] Badges de statut affichés dans README

## 🎉 Félicitations !

Votre système de templates Coder est maintenant déployé avec CI/CD complète !

Tous les templates sont :
- ✅ Testés automatiquement
- ✅ Buildés sans erreur
- ✅ Audités pour les CVE
- ✅ Packagés et disponibles via URL stable
