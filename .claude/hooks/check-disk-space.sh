#!/usr/bin/env bash
# PreToolUse Bash hook — ディスク使用率が高い場合に警告
# 用途: pnpm install / rescript build / cargo build 等で disk space crisis に
#       陥る前に検知し、ユーザーに介入を促す。
# 動作: 90% 超で警告、95% 超でユーザー介入要求。deny はしない（情報提供のみ）。

set -euo pipefail

# 入力（hook 規約に従い stdin を消費するが、本 hook は内容を見ない）
cat > /dev/null

# CWD のディスク使用率を取得
# df -P でポータブル形式、awk で Use% カラムから数字を抽出
use_pct=$(df -P . 2>/dev/null | awk 'NR==2 {gsub(/%/,"",$5); print $5}')

if [ -z "$use_pct" ]; then
  exit 0
fi

if [ "$use_pct" -ge 95 ]; then
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":"⚠️  ディスク使用率 %s%% — クリティカル。ビルド / install を実行する前に空き容量を確保することを強く推奨します（CC Insights レポートで 119MB まで圧迫した事例あり）。"}}\n' "$use_pct"
elif [ "$use_pct" -ge 90 ]; then
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":"ℹ️  ディスク使用率 %s%% — 高め。大規模 install / build を行う前に空き容量を確認することを推奨します。"}}\n' "$use_pct"
fi

# 必ず正常終了（hook の失敗で build を止めない）
exit 0
