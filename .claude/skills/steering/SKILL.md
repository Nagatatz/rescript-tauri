---
description: ステアリングワークフロー（requirements / design / tasklist の作成、worktree 隔離実装、振り返り）。コード変更を伴う指示を受けたとき、または `.steering/` を参照する作業で必ず使用。`/steering plan|implement|review` で明示起動も可。
allowed-tools: Read, Write, Edit, Glob, Bash
---

# Steering

いつ使うか・承認の取り方は `.claude/rules/steering-workflow.md`、完了条件は `.claude/rules/definition-of-done.md`。本 skill は手順を持つ。

## 動的コンテキスト

- ブランチ: !`git branch --show-current 2>/dev/null`
- 最新ステアリング: !`ls -d .steering/2*/ 2>/dev/null | sort | tail -1`
- 変更ファイル: !`git status --short 2>/dev/null | head -10`
- 直近コミット: !`git log --oneline -3 2>/dev/null`

## 使い方

```text
/steering [plan] [<機能名>]          # モード1（引数なしもこれ）
/steering implement [<ディレクトリ>]  # モード2。省略時は最新の .steering/*/
/steering review [<ディレクトリ>]     # モード3
```

## モード1: 計画

1. `.steering/<YYYYMMDD>-<NNN>-<機能名>/` を作る。NNN は当日内の連番。採番と衝突時の振り直しは `.claude/rules/steering-workflow.md`「ステアリング番号の採番」に従う（`git branch --list 'worktree-*'` で並列セッションの予約も確認）。機能名が無ければユーザーに聞く。
2. 方針を読む（存在するものだけ）: `CLAUDE.md`、`docs/product-requirements.md`・`functional-design.md`・`architecture.md`・`repository-structure.md`・`development-guidelines.md`・`glossary.md`。
3. `templates/requirements.md`・`design.md`・`tasklist.md` を読み、`{{機能名}}`・`{{日付}}`（YYYY-MM-DD）と各節を具体的に埋めて同名で保存する。
4. tasklist.md をフェーズごとの具体タスク・サブタスク・実装順・依存注記まで詳細化する。

## モード2: 実装

開始時に tasklist.md・requirements.md・design.md を読む。全タスクが `[x]` になるまで繰り返す:

1. tasklist.md を読み、次の `[ ]` を選ぶ
2. 着手時にそのタスクだけ Edit で `[x]` にする（まとめて更新しない）
3. 実装する。必要ならメモを追記
4. 追加タスクが判明したら、該当フェーズに理由付きで追記

**完遂**: 「時間の都合」「別タスクで実施」などでスキップしない。`[ ]` を残して終えない。

全タスク完了後のコミット:

```bash
pnpm build && pnpm test     # 通ることを確認してから
git add <ファイル>...         # 個別指定。`git add .` / `git add -A` は使わない
```

粒度と絵文字は `.claude/rules/git-conventions.md`。**push はユーザーの明示指示があるまでしない。**

## モード3: 振り返り

1. tasklist.md に `[ ]` が残っていれば報告し、モード2に戻るかユーザーに確認する。
2. 末尾の「振り返り」節に記録: 工夫した点 / 発生した問題と解決策 / 設計変更の理由 / 次回への改善点。
3. 設計が変わったら、永続ドキュメント（`docs/architecture.md`・`functional-design.md`・`repository-structure.md`・`development-guidelines.md`・`glossary.md`、`CLAUDE.md` など）の更新をユーザーに提案する。

## worktree（単一機能）

`main` は branch protection で直 push できない。main への反映は必ず PR 経由（`.claude/rules/steering-workflow.md`「worktree から main への反映手順」が SSOT）。

1. ステアリング番号を採番する。
2. `EnterWorktree`（または `claude --worktree <機能名>`）で `.claude/worktrees/<機能名>/`・ブランチ `worktree-<機能名>`（HEAD から）を作る。
3. worktree 内でステアリング 3 ファイルを作成・承認し、実装・ビルド確認・コミットする。
4. マージ承認後に push → PR → self-merge:
   ```bash
   git push -u origin worktree-<機能名>
   gh pr create --base main --head worktree-<機能名> --title "..." --body "..."
   gh pr merge <PR番号> -R Nagatatz/rescript-tauri --merge --delete-branch   # worktree 内ではローカル main の checkout 競合を避けるため -R 必須
   ```
5. 単独の Bash で `cd <メインリポジトリ>` → `git pull origin main` → worktree とローカルブランチの削除（`worktree-safety` skill の順序）。

## 参照

- 複数機能を並列実装する → [references/parallel.md](references/parallel.md)
