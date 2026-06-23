#!/usr/bin/env bash
set -euo pipefail

flutter/bin/flutter build web --release \
  --dart-define=AUTH0_DOMAIN="${DEV_AUTH0_DOMAIN}" \
  --dart-define=AUTH0_CLIENTID="${DEV_AUTH0_CLIENTID}" \
  --dart-define=AUTH0_REDIRECT_URL="${DEV_AUTH0_REDIRECT_URL}" \
  --dart-define=AUTH0_AUDIENCE="${DEV_AUTH0_AUDIENCE}" \
  --dart-define=BLOG_API_BASE_URL="${DEV_BLOG_API_BASE_URL}"