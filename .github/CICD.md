# CI/CD Pipeline

Ce projet utilise GitHub Actions pour garantir la qualité et la sécurité de tous les templates.

## 🔄 Workflows

### 1. Test Templates (`test-templates.yml`)

**Déclenchement :**
- Push sur `main`
- Pull Request vers `main`
- Manuellement via workflow_dispatch

**Jobs exécutés en parallèle :**

| Template | Étapes de validation |
|----------|---------------------|
| **Node.js** | Installation npm, exécution du script |
| **NestJS** | Installation pnpm, `pnpm audit`, build, tests |
| **React** | Installation pnpm, `pnpm audit`, build Vite |
| **Vue** | Installation pnpm, `pnpm audit`, build Vite |
| **Angular** | Installation pnpm, `pnpm audit`, build Angular |
| **Java Vanilla** | Setup Java 25, `mvn compile`, `mvn test`, OWASP CVE check |
| **Spring Boot** | Setup Java 25, `mvn package`, `mvn test`, OWASP CVE check, test démarrage + endpoints |
| **Python** | Setup Python 3.12, `pip-audit` CVE check, exécution script |
| **C** | Compilation GCC, `make`, exécution, test `make clean` |
| **PHP** | Setup PHP 8.3, `composer validate`, `composer audit`, exécution script |

**Vérifications de sécurité :**
- **Node.js/Frontend** : `pnpm audit --audit-level high`
- **Java** : OWASP Dependency-Check Maven Plugin (CVSS ≥ 7)
- **Python** : `pip-audit`
- **PHP** : `composer audit`

**Job final :**
- `all-tests-passed` : Échoue si au moins un template a des problèmes

### 2. Build Templates (`build-templates.yml`)

**Déclenchement :**
- Automatiquement après succès de `Test Templates`
- Manuellement via workflow_dispatch

**Condition :**
```yaml
if: ${{ github.event.workflow_run.conclusion == 'success' || github.event_name == 'workflow_dispatch' }}
```

**Actions :**
1. Création du dossier `/output`
2. Zip de chaque template avec exclusions :
   - Node.js/Frontend : `node_modules/`, `dist/`, `.angular/`
   - Java : `target/`, `.mvn/`, `mvnw`
   - Python : `__pycache__/`, `venv/`, `env/`
   - C : `obj/`, `bin/`
   - PHP : `vendor/`
3. Commit des archives avec message `🤖 Update template archives [skip ci]`
4. Push vers `main`

**Note :** Le `[skip ci]` évite une boucle infinie de workflows.

## 🛡️ Garanties de qualité

### ✅ Compilations
Tous les templates doivent compiler sans erreur :
- Java : `mvn compile` ou `mvn package`
- Node.js : `pnpm run build`
- C : `make`

### ✅ Tests unitaires
- NestJS : Jest tests
- Java : JUnit 5 tests
- Spring Boot : Tests Spring Boot

### ✅ Sécurité CVE
Détection automatique des vulnérabilités :
- Niveau critique : ≥ 7 CVSS
- Échec en mode `|| true` pour information (pas de blocage)

### ✅ Runtime
- **Spring Boot** : Test de démarrage réel + appel HTTP aux endpoints
- **Python/PHP/C** : Exécution du script/programme

## 📊 Monitoring

### Badges de statut

Ajoutez ces badges à votre README :

```markdown
[![Test Templates](https://github.com/VOTRE-USER/templates/actions/workflows/test-templates.yml/badge.svg)](https://github.com/VOTRE-USER/templates/actions/workflows/test-templates.yml)
[![Build Templates](https://github.com/VOTRE-USER/templates/actions/workflows/build-templates.yml/badge.svg)](https://github.com/VOTRE-USER/templates/actions/workflows/build-templates.yml)
```

### Logs

Consultez les logs détaillés dans :
- Actions → Test Templates → Sélectionner un run
- Chaque job affiche les résultats de build, tests et audits

## 🚨 En cas d'échec

### Test échoue
1. Consulter les logs du job qui a échoué
2. Corriger le problème localement
3. Commit et push
4. Le workflow se relance automatiquement

### Build ne se déclenche pas
Vérifier que :
- Le workflow `Test Templates` a réussi
- Pas de `[skip ci]` dans le message de commit

### CVE détectées
Les audits ne bloquent pas le build (`|| true`) mais affichent les warnings.

**Action recommandée :**
1. Consulter les CVE dans les logs
2. Mettre à jour les dépendances vulnérables
3. Re-push pour validation

## 🔧 Maintenance

### Ajouter un nouveau template

1. Créer le dossier du template
2. Ajouter un job dans `test-templates.yml` :
   ```yaml
   test-nouveau-template:
     name: Test Nouveau Template
     runs-on: ubuntu-latest
     steps:
       - uses: actions/checkout@v4
       # ... vos steps de test
   ```
3. Ajouter dans `all-tests-passed.needs` :
   ```yaml
   needs:
     - test-nouveau-template
   ```
4. Ajouter le zip dans `build-templates.yml` :
   ```yaml
   - name: Zip Nouveau template
     run: |
       zip -r output/nouveau.zip nouveau \
         -x "*/exclusions/*"
   ```

### Mise à jour des versions

**Java :**
```yaml
- name: Setup Java 25
  uses: actions/setup-java@v4
  with:
    distribution: 'oracle'
    java-version: '25'
```

**Node.js :**
```yaml
- name: Setup Node.js
  uses: actions/setup-node@v4
  with:
    node-version: '20'
```

**Python :**
```yaml
- name: Setup Python
  uses: actions/setup-python@v5
  with:
    python-version: '3.12'
```

**PHP :**
```yaml
- name: Setup PHP
  uses: shivammathur/setup-php@v2
  with:
    php-version: '8.3'
```

## 📈 Métriques

À monitorer :
- ⏱️ Durée moyenne des tests : ~5-10 min
- 📦 Taille des archives dans `/output`
- 🔒 Nombre de CVE détectées par audit
- ✅ Taux de succès des builds

## 🎯 Objectifs

- ✅ 100% des templates buildent sans erreur
- ✅ 100% des tests passent
- ✅ 0 CVE critique non traitée
- ✅ Tous les templates démarrent correctement
