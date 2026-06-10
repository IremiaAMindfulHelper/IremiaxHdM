#!/bin/bash
# Reads ANTHROPIC_API_KEY from .env at the repo root and writes it into
# Secrets.plist directly inside the built app bundle. Never commits the key.
set -e

ENV_FILE="${SRCROOT}/../.env"
OUTPUT_DIR="${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
OUTPUT_FILE="${OUTPUT_DIR}/Secrets.plist"

mkdir -p "${OUTPUT_DIR}"

API_KEY=""
if [ -f "${ENV_FILE}" ]; then
    API_KEY=$(grep -E "^ANTHROPIC_API_KEY=" "${ENV_FILE}" | head -n 1 | cut -d '=' -f 2- | tr -d '"' | tr -d "'" | xargs || true)
fi

cat > "${OUTPUT_FILE}" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>ANTHROPIC_API_KEY</key>
    <string>${API_KEY}</string>
</dict>
</plist>
EOF

if [ -z "${API_KEY}" ]; then
    echo "warning: ANTHROPIC_API_KEY missing — voice feature will use fallback strings only. Add it to ${ENV_FILE}"
fi
