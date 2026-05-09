---
description: 複数の独立した実装作業（plugin / template / 機能パッケージ）を並列に worktree で進める際のオーケストレーション手順。番号予約 / coordinator / batch merge を扱う。「N 個を並列で実装」「複数 plugin 同時着手」「並列で N 個の template 追加」のリクエストに proactively 使用。
allowed-tools: Read, Write, Edit, Bash, Agent, AskUserQuestion
---

# Parallel Implementation Swarm

複数の独立した実装作業を並列 worktree で実行し、coordinator パターンで安全に統合するスキル。

## 発火条件

以下のいずれかに該当する場合に proactively 使用:

- **N >= 2** の独立した類似実装（例: 「plugin-shell, plugin-http, plugin-store を並列実装」）
- 各実装が **独立 PR 化可能** で、互いに依存関係が無い
- 主要な共通ファイル（`docs/repository-structure.md`、`CLAUDE.md` 等）への編集が **限定的**

該当しない例（直列で実装すべきケース）:
- 1 つの大きな機能を分割しているだけ（互いに依存）
- 共通基盤の変更（`packages/core` の API 変更）

## ワークフロー

### Phase 1: 番号予約と Worktree 準備

各実装に対し当日の連番ステアリング番号を予約する。並列セッションでの衝突を防ぐため、**番号は事前に全件アトミックに予約**する。

```bash
# 1. 当日の最大番号を取得
base=$(ls -1 .steering/ 2>/dev/null | grep -oE '^[0-9]{8}-[0-9]{3}' | sort -u | tail -1)
# 例: 20260509-052

# 2. N 個分の番号を予約（例: N=3 → 053, 054, 055）
# .claude/steering-lock.json に記録（ファイル mtime ベースの簡易ロック）
cat > .claude/steering-lock.json <<EOF
{
  "reserved": ["20260509-053", "20260509-054", "20260509-055"],
  "owner": "$(whoami)-$(date +%s)",
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

# 3. 各 worktree 用ブランチを HEAD から事前に作成
for n in 053 054 055; do
  git worktree add -b worktree-N-$n .claude/worktrees/N-$n HEAD
done
```

`.claude/steering-lock.json` は **commit しない**（gitignore に追加）。

### Phase 2: 並列 Sub-agent 起動

各 worktree で 1 つの Sub-agent (Task tool) を起動し、ステアリングドキュメント作成 + 実装 + テストまでを担当させる。

```
Agent[1] (worktree-N-053) → plugin-shell 実装
Agent[2] (worktree-N-054) → plugin-http 実装
Agent[3] (worktree-N-055) → plugin-store 実装
```

各 agent には以下を渡す:
- 担当する worktree の絶対パス
- 予約済みステアリング番号
- 実装スコープ（独立して完結すること）
- **共通ファイル（CLAUDE.md / docs/repository-structure.md）には触れない**指示

### Phase 3: Coordinator による Reconcile

全 agent が完了したら、coordinator（親セッション）が以下を実施:

1. **各 worktree の green 確認**
   ```bash
   for n in 053 054 055; do
     (cd .claude/worktrees/N-$n && pnpm --recursive test) || echo "FAIL: N-$n"
   done
   ```

2. **共通ファイルの統合編集**
   - `docs/repository-structure.md` への新パッケージ追記
   - `CLAUDE.md` の skill 表 / package 一覧の更新
   - `pnpm-workspace.yaml` への追加（必要なら）
   - これらを **coordinator が直列で 1 commit にまとめて実施**（衝突を避ける）

3. **Batch merge 順序の決定**
   ```bash
   # 番号順（依存関係に従う）か、テスト pass 順（早く完了した順）
   # 1 件ずつ main に merge
   for n in 053 054 055; do
     git merge worktree-N-$n --no-ff -m "Merge branch 'worktree-N-$n'"
   done
   ```

4. **クリーンアップ** (`.claude/rules/steering-workflow.md` の「worktree マージ・クリーンアップ手順」に従う)
   ```bash
   for n in 053 054 055; do
     git worktree remove .claude/worktrees/N-$n
     git branch -d worktree-N-$n
   done
   rm -f .claude/steering-lock.json
   ```

## ガードレール

- **共通ファイル編集を sub-agent に許可しない**: `CLAUDE.md` / `docs/repository-structure.md` / `pnpm-workspace.yaml` 等は coordinator のみが編集
- **番号衝突発生時は即座に rename**（→ `steering-workflow.md` の「ステアリング番号の採番」§衝突発生時の対処）
- **マージ失敗時は他の worktree を保留**: 1 件でもマージで競合が起きたら、残りの worktree は手動 rebase してから merge
- **steering-lock.json は commit しない**: `.gitignore` への追加を skill 起動時にチェック

## .gitignore への追加

skill 起動時に `.gitignore` に以下を追加（既存なら何もしない）:

```
# Parallel implementation swarm lock file
.claude/steering-lock.json
```

## なぜ並列化するか

CC Insights レポート（2026-04 〜 2026-05、82 sessions）で「N 個の plugin / template を sequential に実装」が複数回観測された:

- 4 React framework templates (TanStack Start, Remix v7, Astro, Waku)
- 5 server template Postgres/MySQL バリアント
- plugin-fs / plugin-dialog / schema 系列の継続作業

これらを並列化することで、複数日の sequential 作業 → 1 セッションでの parallel run に短縮できる。

## 関連

- `.claude/rules/steering-workflow.md` — ステアリング番号採番手順 / worktree 鮮度確認
- `.claude/skills/worktree-safety/` — worktree 削除順序の必須規約
- `.claude/skills/steering/` — 単一機能の steering ワークフロー
