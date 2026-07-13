#!/usr/bin/env bash
# PostToolUse Edit/Write hook — 編集ファイルを oxfmt で auto-format
# 対象: 手書き .mjs / .json / .jsonc のみ
# 除外: ReScript 生成物 *.res.mjs は明示的にスキップ（oxfmt は明示パス指定時
#       ignorePatterns を適用しないため、hook 側でガードする）
# 動作: 失敗しても build を止めない（best-effort）

set -euo pipefail

input=$(cat)

# 編集対象ファイルパスを抽出（Edit / Write 両対応）
file_path=$(printf "%s" "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null || true)

if [ -z "$file_path" ]; then
  exit 0
fi

# ReScript 生成物は整形対象外（*.mjs に先立って除外）
case "$file_path" in
  *.res.mjs) exit 0 ;;
esac

# 対象拡張子のみ処理
case "$file_path" in
  *.mjs|*.json|*.jsonc) ;;
  *) exit 0 ;;
esac

# pnpm が存在しない環境では何もしない
if ! command -v pnpm >/dev/null 2>&1; then
  exit 0
fi

# プロジェクトルートでのみ動作（.oxfmtrc.json が無い環境でスキップ）
repo_root=$(git rev-parse --show-toplevel 2>/dev/null || true)
if [ -z "$repo_root" ] || [ ! -f "$repo_root/.oxfmtrc.json" ]; then
  exit 0
fi

# node_modules/.bin/oxfmt が無い環境ではスキップ（pnpm install を auto-trigger しない）
if [ ! -x "$repo_root/node_modules/.bin/oxfmt" ]; then
  exit 0
fi

# oxfmt auto-format を best-effort で実行（失敗しても hook を成功扱い）
(cd "$repo_root" && ./node_modules/.bin/oxfmt "$file_path" 2>/dev/null) || true

exit 0
