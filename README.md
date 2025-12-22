# Coder Templates

[![Test Templates](https://github.com/VOTRE-USER/templates/actions/workflows/test-templates.yml/badge.svg)](https://github.com/VOTRE-USER/templates/actions/workflows/test-templates.yml)
[![Build Templates](https://github.com/VOTRE-USER/templates/actions/workflows/build-templates.yml/badge.svg)](https://github.com/VOTRE-USER/templates/actions/workflows/build-templates.yml)

Collection de templates prêts à l'emploi pour initialiser des workspaces Coder.

> ✅ Tous les templates sont testés automatiquement (build, tests, audit CVE) avant d'être packagés

## 📦 Templates disponibles

### Templates simples (Hello World)

| Template | Description | Technologies |
|----------|-------------|--------------|
| **node** | Node.js minimal | Node.js, npm |
| **node-ts** | Node.js avec TypeScript | Node.js, TypeScript, pnpm |
| **python** | Python minimal | Python 3.12+ |
| **go** | Go minimal | Go 1.23+ |
| **cpp** | C++ minimal | C++23, g++, Make |
| **rust** | Rust minimal | Rust 1.80+, Cargo |
| **c** | Projet C avec Makefile | GCC, Make |
| **php** | PHP minimal | PHP 8+, Composer |

### Templates backend (API)

| Template | Description | Technologies |
|----------|-------------|--------------|
| **node-fastify** | API Node.js avec Fastify | Fastify 5+, TypeScript, pnpm |
| **python-fastapi** | API Python avec FastAPI | FastAPI 0.115+, Python 3.12+ |
| **nestjs** | Framework NestJS | NestJS, TypeScript, pnpm |
| **java-springboot** | Spring Boot avec démo | Java 25, Spring Boot 4.0.0, H2, Lombok |

### Templates complets (Full-stack)

| Template | Description | Technologies |
|----------|-------------|--------------|
| **laravel** | Framework Laravel | Laravel 11+, PHP 8.2+ |
| **adonis** | Framework AdonisJS | AdonisJS 6+, TypeScript, Node.js |

### Templates frontend

| Template | Description | Technologies |
|----------|-------------|--------------|
| **react** | Application React | React 19, Vite, TypeScript, pnpm |
| **vue** | Application Vue | Vue 3, Vite, TypeScript, pnpm |
| **angular** | Application Angular | Angular (dernière version), pnpm |
| **nextjs** | Next.js avec App Router | Next.js 15+, React 19, TypeScript, Tailwind |
| **nuxt** | Nuxt avec TypeScript | Nuxt 4+, Vue 3, TypeScript |
| **static-server** | Site statique simple | HTML5, CSS3, JavaScript ES6+ |

### Templates avancés

| Template | Description | Technologies |
|----------|-------------|--------------|
| **java-vanilla** | Java Maven minimal | Java 25, Maven, JUnit 5 |

## 🚀 Utilisation avec Coder

### Méthode 1: URL directe (Recommandé)

Les templates sont automatiquement zippés et disponibles via GitHub:

```bash
# Dans votre template Coder
wget https://raw.githubusercontent.com/VOTRE-USER/templates/main/output/react.zip
unzip react.zip
cd templates/react
```

### Méthode 2: Clone du repo

```bash
git clone https://github.com/VOTRE-USER/templates.git
cd templates/templates/react
```

## 🏗️ Structure du projet

```
.
├── .github/workflows/
│   ├── test-templates.yml     # Tests & audit CVE
│   └── build-templates.yml    # Packaging des templates
├── templates/                  # Tous les templates
│   ├── node/                  # Template Node.js
│   ├── node-ts/               # Template Node.js TypeScript
│   ├── node-fastify/          # Template Fastify API
│   ├── python/                # Template Python
│   ├── python-fastapi/        # Template FastAPI
│   ├── go/                    # Template Go
│   ├── cpp/                   # Template C++
│   ├── rust/                  # Template Rust
│   ├── nestjs/                # Template NestJS
│   ├── react/                 # Template React
│   ├── vue/                   # Template Vue
│   ├── angular/               # Template Angular
│   ├── nextjs/                # Template Next.js
│   ├── nuxt/                  # Template Nuxt
│   ├── laravel/               # Template Laravel
│   ├── adonis/                # Template AdonisJS
│   ├── static-server/         # Template Static
│   ├── java-vanilla/          # Template Java
│   ├── java-springboot/       # Template Spring Boot
│   ├── c/                     # Template C
│   └── php/                   # Template PHP
├── output/                     # Archives générées automatiquement
│   ├── node.zip
│   ├── node-ts.zip
│   ├── node-fastify.zip
│   ├── python-fastapi.zip
│   ├── go.zip
│   ├── cpp.zip
│   ├── rust.zip
│   ├── react.zip
│   ├── nextjs.zip
│   ├── nuxt.zip
│   ├── laravel.zip
│   ├── adonis.zip
│   ├── static-server.zip
│   └── ...
└── assets/                     # Icônes des templates
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
# Modifier un template
cd templates/react
# ... faire vos modifications ...

# Commit et push
git add .
git commit -m "Update React template"
git push

# La GitHub Action va automatiquement:
# - Tester le template
# - Créer react.zip
# - Le commiter dans /output
# - L'URL reste la même !
```

## 🎯 Versions et technologies

### Langages simples
- **Go** 1.23+ (dernière version stable)
- **C++** 23 (dernier standard)
- **Rust** 1.80+ (Edition 2021)
- **Python** 3.12+
- **Node.js** 20+
- **TypeScript** 5.7+

### Frameworks Backend
- **Fastify** 5.2+ (framework web ultra-rapide)
- **FastAPI** 0.115+ (framework Python moderne)
- **NestJS** (dernière version)
- **Spring Boot** 4.0.0 (Jakarta EE 11, Spring Framework 7)
- **Laravel** 11+ (PHP 8.2+)
- **AdonisJS** 6+ (TypeScript, Lucid ORM)

### Frameworks Frontend
- **React** 19 avec Vite
- **Vue** 3 avec Vite
- **Angular** (dernière version)
- **Next.js** 15+ (App Router, React 19, Turbopack)
- **Nuxt** 4+ (Vue 3, Nitro)

### Java
- **Java** 25 (LTS - Septembre 2025)
  - Scoped Values (JEP 506)
  - Compact Source Files (JEP 512)
  - Flexible Constructor Bodies (JEP 513)

### Package Managers
- Projets Node.js/Frontend: **pnpm** (recommandé)
- Python: **pip** ou **uv**
- PHP: **Composer**
- Go: modules Go natifs
- Rust: **Cargo**
- Java: **Maven**

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
      "node", "node-ts", "node-fastify",
      "python", "python-fastapi",
      "go", "cpp", "rust", "c",
      "nestjs", "react", "vue", "angular",
      "nextjs", "nuxt", "static-server",
      "laravel", "adonis",
      "java-vanilla", "java-springboot", "php"
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
cd templates/react
pnpm install
pnpm dev

# Tester la création d'archives localement
zip -r ../../output/react.zip . -x "*/node_modules/*"
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
