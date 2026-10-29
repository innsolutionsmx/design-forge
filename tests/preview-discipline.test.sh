#!/usr/bin/env bash
# Tests for hooks/preview-discipline.sh: which prompts inject the preview reminder.
# Run: bash tests/preview-discipline.test.sh   (exit 0 = all pass)
set -uo pipefail

hook="$(cd "$(dirname "$0")/.." && pwd)/hooks/preview-discipline.sh"
fail=0

payload() { # prompt -> JSON hook payload (python3, so the test needs no jq)
  python3 -c 'import json,sys; print(json.dumps({"prompt": sys.argv[1], "cwd": "/tmp/design-forge"}))' "$1"
}

fires() { # prompt -> "yes" if the hook injected context, "no" otherwise
  local out
  out="$(payload "$1" | bash "$hook")"
  if [ -n "$out" ]; then echo yes; else echo no; fi
}

expect() { # expected prompt
  local got
  got="$(fires "$2")"
  if [ "$got" = "$1" ]; then
    echo "ok    [$1] $2"
  else
    echo "FAIL  [expected $1, got $got] $2"
    fail=1
  fi
}

# Visual work: must fire.
expect yes "Haz este hero uno a uno con los assets del proyecto"
expect yes "rediseñá el navbar"
expect yes "mirá esta captura, quiero algo así"
expect yes "crea una sección de testimonios"
expect yes "Make this landing look like the screenshot"
expect yes "replicate this pricing section 1:1"
expect yes "agrega un carrusel al hero"

# Not design work: must stay silent.
expect no "build the project and run the tests"
expect no "fix the redirect on the login page"
expect no "commit the changes"
expect no "update the image upload validation in the API"
expect no "corre el doctor"
expect no "revisemos las mejoras pendientes del menu de comandos"

# Defensive: empty or malformed payload never injects and always exits 0.
out="$(printf 'not json' | bash "$hook")"; code=$?
if [ "$code" -eq 0 ] && [ -z "$out" ]; then echo "ok    malformed payload is silent"; else echo "FAIL  malformed payload"; fail=1; fi

# The reminder names the main command and the reference-asset rule.
msg="$(payload "rediseñá el navbar" | bash "$hook")"
for needle in "/design-forge:replicate" "assets"; do
  if [[ "$msg" == *"$needle"* ]]; then echo "ok    message mentions $needle"; else echo "FAIL  message lacks $needle"; fail=1; fi
done

exit "$fail"
