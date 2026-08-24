#!/usr/bin/env bash
#
# Aplica la configuracion de repositorio que una plantilla de GitHub NO puede
# llevarse: el ruleset de la rama principal, la politica de merge y el escaneo de
# secretos. Una plantilla copia ficheros, no ajustes, asi que sin esto cada
# proyecto nuevo arranca con `main` desprotegida.
#
# Idempotente: al reejecutarlo avisa de que el ruleset ya existe y no toca nada.
#
# Uso:  scripts/setup-github.sh [owner/repo]
#       Por defecto, el repositorio al que apunta el directorio actual.

set -euo pipefail

REPO="${1:-$(gh repo view --json nameWithOwner --jq .nameWithOwner)}"
RULESET_FILE="$(dirname "$0")/ruleset-main.json"
RULESET_NAME="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["name"])' "$RULESET_FILE")"

echo "==> Configurando $REPO"

# --- Politica de merge ----------------------------------------------------------------
# Solo squash, y borrar la rama al terminar. Es lo que corresponde al flujo de
# CLAUDE.md: historia lineal, un commit por pull request.
echo "--> Politica de merge: solo squash, borrar rama al fusionar"
gh repo edit "$REPO" \
  --enable-squash-merge \
  --enable-merge-commit=false \
  --enable-rebase-merge=false \
  --delete-branch-on-merge >/dev/null

# --- Ruleset de rama ------------------------------------------------------------------
# Apunta a ~DEFAULT_BRANCH y no al nombre literal, para que renombrar la rama por
# defecto no deje el repositorio sin proteccion en silencio.
if gh api "repos/$REPO/rulesets" --jq '.[].name' 2>/dev/null | grep -qx "$RULESET_NAME"; then
  echo "--> El ruleset '$RULESET_NAME' ya existe, no se toca"
else
  echo "--> Creando ruleset '$RULESET_NAME' (checks obligatorios, PR obligatorio, sin force push)"
  gh api "repos/$REPO/rulesets" --method POST --input "$RULESET_FILE" >/dev/null
fi

# --- Escaneo de secretos --------------------------------------------------------------
# Gratis en repositorios publicos. gitleaks en CI revisa el historial completo; la
# proteccion de push corta el secreto antes de que llegue a subirse. Son
# complementarios, se activan los dos.
echo "--> Escaneo de secretos y proteccion de push"
if gh api "repos/$REPO" --method PATCH \
  --raw-field 'security_and_analysis[secret_scanning][status]=enabled' \
  --raw-field 'security_and_analysis[secret_scanning_push_protection][status]=enabled' \
  >/dev/null 2>&1; then
  echo "    activados"
else
  echo "    no se han podido activar desde la API: hazlo en"
  echo "    Settings > Advanced Security. En un repositorio privado requieren plan de pago."
fi

# --- Lo que queda a mano --------------------------------------------------------------
cat <<'EOF'

==> Listo. Sigue siendo manual:

  * Marcar el repositorio como plantilla, si esto es la plantilla:
      gh repo edit --template

  * Conectar el repositorio a Vercel. El proyecto se configura solo:
    framework Astro, build `npm run build`, output `dist`. Lo unico que hay
    que anadir a mano son las variables de entorno (ver .env.example).

  * No hay secretos de repositorio que crear: este proyecto no despliega desde
    Actions, lo hace Vercel al recibir el push.

Comprobar con:
  gh api repos/OWNER/REPO/rulesets --jq '.[].name'
  gh repo view OWNER/REPO --json isTemplate,deleteBranchOnMerge,squashMergeAllowed
EOF
