# Coder Templates

[![Test Templates](https://github.com/VOTRE-USER/templates/actions/workflows/test-templates.yml/badge.svg)](https://github.com/VOTRE-USER/templates/actions/workflows/test-templates.yml)
[![Build Templates](https://github.com/VOTRE-USER/templates/actions/workflows/build-templates.yml/badge.svg)](https://github.com/VOTRE-USER/templates/actions/workflows/build-templates.yml)

Collection de templates prêts à l'emploi pour initialiser des workspaces Coder.

> ✅ Tous les templates sont testés automatiquement (build, tests, audit CVE) avant d'être packagés

## 📦 Templates disponibles

| Template | Description | Technologies |
|----------|-------------|--------------|
| **node** | Node.js minimal | Node.js, npm/pnpm |
| **nestjs** | Framework NestJS | NestJS, TypeScript, pnpm |
| **react** | Application React | React 19, Vite, TypeScript, pnpm |
| **vue** | Application Vue | Vue 3, Vite, TypeScript, pnpm |
| **angular** | Application Angular | Angular (dernière version), pnpm |
| **java-vanilla** | Java Maven minimal | Java 25, Maven, JUnit 5 |
| **java-springboot** | Spring Boot avec démo | Java 25, Spring Boot 4.0.0, H2, Lombok |
| **python** | Python minimal | Python 3 |
| **c** | Projet C avec Makefile | GCC, Make |
| **php** | PHP minimal | PHP 8+, Composer |

## 🚀 Utilisation avec Coder

### Méthode 1: URL directe (Recommandé)

Les templates sont automatiquement zippés et disponibles via GitHub:

```bash
# Dans votre template Coder
wget https://raw.githubusercontent.com/VOTRE-USER/templates/main/output/react.zip
unzip react.zip
cd react
```

### Méthode 2: Clone du repo

```bash
git clone https://github.com/VOTRE-USER/templates.git
cd templates/react
```

## 🏗️ Structure du projet

```
.
├── .github/workflows/
│   ├── test-templates.yml     # Tests & audit CVE
│   └── build-templates.yml    # Packaging des templates
├── output/                     # Archives générées automatiquement
│   ├── node.zip
│   ├── react.zip
│   └── ...
├── node/                       # Template Node.js
├── nestjs/                     # Template NestJS
├── react/                      # Template React
└── ...
```

## ⚙️ Fonctionnement (CI/CD Pipeline)

1. **Push sur main** : Quand vous modifiez un template et poussez sur main
2. **Tests automatiques** : L'action `test-templates.yml` se déclenche
   - ✅ Build de chaque template
   - ✅ Exécution des tests unitaires
   - ✅ Audit de sécurité CVE (OWASP, npm audit, pip-audit, composer audit)
   - ✅ Vérification de démarrage (Spring Boot)
3. **Build des archives** : Si tous les tests passent, `build-templates.yml` se lance
   - 📦 Chaque template est zippé (sans node_modules, target, etc.)
   - 💾 Les archives sont commitées dans `/output`
4. **URLs stables** : Les liens restent constants pour Coder

**Protection qualité** : Les archives ne sont créées que si tous les templates compilent et passent les tests !

## 🔄 Mise à jour d'un template

```bash
# Modifier le template
cd react
# ... faire vos modifications ...

# Commit et push
git add .
git commit -m "Update React template"
git push

# La GitHub Action va automatiquement:
# - Créer react.zip
# - Le commiter dans /output
# - L'URL reste la même !
```

## 🎯 Versions

### Java Templates
- **Java 25** (LTS - Septembre 2025)
  - Scoped Values (JEP 506)
  - Compact Source Files (JEP 512)
  - Flexible Constructor Bodies (JEP 513)

- **Spring Boot 4.0.0** (LTS)
  - Jakarta EE 11
  - Spring Framework 7
  - Support OpenTelemetry
  - Modularisation complète

### Frontend Templates
- React 19 avec Vite
- Vue 3 avec Vite
- Angular (dernière version)
- NestJS (dernière version)

Tous les projets Node.js/frontend utilisent **pnpm** comme package manager.

## 📝 Exemple d'intégration Coder

```hcl
# Dans votre template Coder
resource "coder_agent" "main" {
  # ...

  startup_script = <<-EOT
    #!/bin/bash

    # Télécharger et extraire le template
    wget -q https://raw.githubusercontent.com/VOTRE-USER/templates/main/output/${var.template_choice}.zip
    unzip -q ${var.template_choice}.zip
    cd ${var.template_choice}

    # Installer les dépendances selon le template
    if [ -f "package.json" ]; then
      pnpm install
    elif [ -f "pom.xml" ]; then
      mvn clean install
    fi
  EOT
}

variable "template_choice" {
  description = "Choose a template"
  default     = "react"
  validation {
    condition = contains([
      "node", "nestjs", "react", "vue", "angular",
      "java-vanilla", "java-springboot", "python", "c", "php"
    ], var.template_choice)
  }
}
```

## 🛠️ Développement local

```bash
# Cloner le repo
git clone https://github.com/VOTRE-USER/templates.git
cd templates

# Travailler sur un template
cd react
pnpm install
pnpm dev

# Tester la création d'archives localement
zip -r ../output/react.zip . -x "*/node_modules/*"
```

## 📚 Documentation

Chaque template contient son propre README avec des instructions spécifiques.

## 🤝 Contribution

1. Fork le projet
2. Créer une branche (`git checkout -b feature/nouveau-template`)
3. Commit vos changements (`git commit -m 'Add nouveau template'`)
4. Push vers la branche (`git push origin feature/nouveau-template`)
5. Ouvrir une Pull Request

## 📄 Licence

MIT
