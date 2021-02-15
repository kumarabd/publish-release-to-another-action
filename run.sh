#!/bin/bash

GITHUB_API_URL="api.github.com"

if [[ -z "$INPUT_FILE" ]]; then
  echo "Missing file input in the action"
  exit 1
fi

if [[ -z "$GITHUB_REPOSITORY" ]]; then
  echo "Missing GITHUB_REPOSITORY env variable"
  exit 1
fi

REPO=$GITHUB_REPOSITORY
if ! [[ -z ${INPUT_REPO} ]]; then
  REPO=$INPUT_REPO
fi

TARGET_REPO=$GITHUB_REPOSITORY
if ! [[ -z ${INPUT_RELEASE_REPO} ]]; then
  TARGET_REPO=$INPUT_RELEASE_REPO
fi

# Optional target file path
TARGET=$INPUT_FILE
if ! [[ -z ${INPUT_TARGET} ]]; then
  TARGET=$INPUT_TARGET
fi

# Optional personal access token for external repository
TOKEN=$GITHUB_TOKEN
if ! [[ -z ${INPUT_TOKEN} ]]; then
  TOKEN=$INPUT_TOKEN
fi

API_URL="https://$GITHUB_API_URL/repos/$REPO"
RELEASE_DATA=$(curl -H "Authorization: token $TOKEN" $API_URL/releases?tag_name=${INPUT_VERSION})
MESSAGE=$(echo $RELEASE_DATA | jq -r ".[].message")

if [[ "$MESSAGE" == "Not Found" ]]; then
  echo "[!] Release asset not found"
  echo "Release data: $RELEASE_DATA"
  echo "-----"
  echo "repo: $REPO"
  echo "asset: $INPUT_FILE"
  echo "target: $TARGET"
  echo "version: $INPUT_VERSION"
  exit 1
fi

ASSET_ID=$(echo $RELEASE_DATA | jq -r ".[].assets | map(select(.name == \"${INPUT_FILE}\"))[0].id")
ASSET_TYPE=$(echo $RELEASE_DATA | jq -r ".[].assets | map(select(.name == \"${INPUT_FILE}\"))[0].content_type")
TAG_VERSION=$(echo $RELEASE_DATA | jq -r ".[].tag_name" | sed -e "s/^v//" | sed -e "s/^v.//")

if [[ -z "$ASSET_ID" ]]; then
  echo "Could not find asset id"
  exit 1
fi

curl \
  -J \
  -L \
  -H "Authorization: token $TOKEN" \
  -H "Accept: application/octet-stream" \
  "$API_URL/releases/assets/$ASSET_ID" \
  --create-dirs \
  -o ${INPUT_RELEASE_TARGET}

echo "::set-output name=version::$TAG_VERSION"

# Release process
TARGET_API_URL="https://$GITHUB_API_URL/repos/$TARGET_REPO"
RELEASE_URL=$TARGET_API_URL/releases

curl \
  -X POST \
  -H "Authorization: token $TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "$RELEASE_URL" \
  -d '{"tag_name":"'$INPUT_RELEASE_VERSION'","body":""}'


# Upload artifact
RELEASE_UPLOAD_URL=$(curl -H "Authorization: token $TOKEN" $RELEASE_URL?tag_name=${INPUT_RELEASE_VERSION} | jq -r ".[].upload_url")
pattern="{?"
RELEASE_ASSET_URL="${RELEASE_UPLOAD_URL%$pattern*}?name=$INPUT_RELEASE_TARGET"

curl \
  -X POST \
  -H "Content-Type: $ASSET_TYPE" \
  -H "Authorization: token $TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  --data-binary @${INPUT_RELEASE_TARGET} \
  "$RELEASE_ASSET_URL"