---
description: 独立した複数の実装（plugin・template・機能パッケージ）を並列 worktree で進め、coordinator が統合する。番号予約・共通ファイルの直列編集・PR 単位のマージを扱う。「N 個を並列で実装」「複数 plugin 同時着手」で使用。
allowed-tools: Read, Write, Edit, Bash, Agent, AskUserQuestion
---

# Parallel Implementation Swarm

**使う**: N ≥ 2 の互いに依存しない実装で、それぞれ独立 PR にでき、共通ファイルの編集が少ないとき。
**使わない**: 1 つの機能を分割しただけ（相互依存）、`packages/core` の API 変更などの共通基盤変更 → 直列で実装する。

## Phase 1: 番号予約と worktree

番号は全件まとめて予約する（並列セッションとの衝突防止。採番規則は `.claude/rules/steering-workflow.md`「ステアリング番号の採番」）:

```bash
ls -1 .steering/ | grep -oE '^[0-9]{8}-[0-9]{3}' | sort -u | tail -1        # 当日の最大番号
cat > .claude/steering-lock.json <<JSON
{"reserved": ["<YYYYMMDD>-053", "<YYYYMMDD>-054"], "owner": "$(whoami)-$(date +%s)", "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"}
JSON
for n in 053 054; do git worktree add -b worktree-N-$n .claude/worktrees/N-$n HEAD; done
```

`.claude/steering-lock.json` はコミットしない。`.gitignore` に無ければ追加する。

## Phase 2: sub-agent を並列起動

worktree ごとに Agent を 1 つ起動し、ステアリング作成 → 実装 → テストまで任せる。渡すもの: worktree の絶対パス、予約番号、独立したスコープ、**共通ファイル（`CLAUDE.md`・`docs/repository-structure.md`・`pnpm-workspace.yaml`）に触れない指示**。

## Phase 3: coordinator が統合

1. 各 worktree が green か: `(cd .claude/worktrees/N-$n && pnpm test) || echo "FAIL: N-$n"`
2. 共通ファイル（`docs/repository-structure.md` への追記、`CLAUDE.md` の一覧、`pnpm-workspace.yaml`）は coordinator だけが直列に 1 コミットで編集する。
3. 1 件ずつ PR でマージする（`main` は直 push 不可）:
   ```bash
   git -C .claude/worktrees/N-$n push -u origin worktree-N-$n
   gh pr create --base main --head worktree-N-$n --title "..." --body "..."
   gh pr merge <PR番号> -R Nagatatz/rescript-tauri --merge --delete-branch
   ```
   1 件でも競合したら残りを保留し、rebase してからマージする。
4. 後片付け（`worktree-safety` skill の順序。先に単独の Bash で `cd <メインリポジトリ>`）:
   ```bash
   git pull origin main
   for n in 053 054; do git worktree remove .claude/worktrees/N-$n; git branch -d worktree-N-$n; done
   rm -f .claude/steering-lock.json
   ```

番号衝突が起きたら即座に `+1` で振り直す（`git mv` と `git branch -m`）。
