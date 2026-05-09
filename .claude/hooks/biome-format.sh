#!/usr/bin/env bash
# PostToolUse Edit/Write hook — 編集ファイルを Biome で auto-format
# 対象: 手書き .mjs / .json / .jsonc のみ
# 除外: ReScript 生成物 *.res.mjs と lib/ は biome.json 側で除外済み
# 動作: 失敗しても build を止めない（best-effort）

set -euo pipefail

input=$(cat)

# 編集対象ファイルパスを抽出（Edit / Write 両対応）
file_path=$(printf "%s" "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null || true)

if [ -z "$file_path" ]; then
  exit 0
fi

# 対象拡張子のみ処理
case "$file_path" in
  *.mjs|*.json|*.jsonc) ;;
  *) exit 0 ;;
esac

# pnpm が存在しない環境では何もしない
if ! command -v pnpm >/dev/null 2>&1; then
  exit 0
fi

# プロジェクトルートでのみ動作（biome.json が無い環境でスキップ）
repo_root=$(git rev-parse --show-toplevel 2>/dev/null || true)
if [ -z "$repo_root" ] || [ ! -f "$repo_root/biome.json" ]; then
  exit 0
fi

# node_modules/.bin/biome が無い環境ではスキップ（pnpm install を auto-trigger しない）
if [ ! -x "$repo_root/node_modules/.bin/biome" ]; then
  exit 0
fi

# Biome auto-fix を best-effort で実行（失敗しても hook を成功扱い）
(cd "$repo_root" && ./node_modules/.bin/biome check --write "$file_path" 2>/dev/null) || true

exit 0
