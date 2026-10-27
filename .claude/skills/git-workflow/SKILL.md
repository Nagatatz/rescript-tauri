---
description: ブランチ作成・絵文字付きコミット・PR 作成・状態確認を行う。「コミットして」「ブランチ切って」「PR 作って」で使用。
allowed-tools: Bash, Read, Glob, Grep
---

# Git ワークフロー

絵文字・コミット粒度・ブランチ命名は `.claude/rules/git-conventions.md`（常時読み込み）に従う。

## 現在の状態

- ブランチ: !`git branch --show-current 2>/dev/null`
- 状態: !`git status --short 2>/dev/null | head -10`
- 直近 3 コミット: !`git log --oneline -3 2>/dev/null`
- リモート差分: !`git status -sb 2>/dev/null | head -1`

## 使い方

```text
/git-workflow [status]               # 引数なし = status
/git-workflow branch <名前>
/git-workflow commit [-m "<メッセージ>"]
/git-workflow pr
```

## branch

名前に規約のプレフィックス（`feature/` `fix/` `refactor/` `docs/` `test/` `chore/`）が無ければユーザーに確認する。未コミット変更があれば警告してから `git checkout -b <名前>`。

## commit

1. `git status` / `git diff` / `git diff --cached` で変更を確認する。
2. **ファイルを個別に `git add`** する（`git add .` / `git add -A` は使わない）。`.env`・`credentials.json` などの秘密情報と、生成物（`lib/`・`*.res.mjs`・`coverage/`・`node_modules/`）は入れない。
3. メッセージは `<絵文字> <動詞で始まる英語の要約>`。`-m` 指定時は絵文字が無ければ付ける。
4. HEREDOC でコミットする:
   ```bash
   git commit -m "$(cat <<'MSG'
   ✨ Add user authentication

   Co-Authored-By: <実行中の Claude モデル名> <noreply@anthropic.com>
   MSG
   )"
   ```
5. **push しない。** ユーザーの明示指示があるまで待ち、push するか確認する。

## pr

1. 差分を確認: `git log --oneline main..HEAD` / `git diff main...HEAD --stat`
2. タイトルは 70 文字以内で主目的を表す。絵文字は付けない。
3. push はユーザー確認後: `git push -u origin <ブランチ名>`。`main` は branch protection で直 push できないので、必ず PR 経由にする。
4. PR を作成し、URL を表示する。マージ（`gh pr merge --merge --delete-branch`）と後片付けは `.claude/rules/steering-workflow.md`「worktree から main への反映手順」に従う:
   ```bash
   gh pr create --title "<タイトル>" --body "$(cat <<'MSG'
   ## Summary
   - 変更の概要（1〜3 行）

   ## Changes
   - 変更ファイルと内容

   ## Test plan
   - [ ] `pnpm build` が成功する
   - [ ] `pnpm test` が全件パスする
   - [ ] `pnpm check` が通る
   - [ ] 手動確認: …

   🤖 Generated with [Claude Code](https://claude.com/claude-code)
   MSG
   )"
   ```

## status

```bash
git branch --show-current; git status --short; git log --oneline -5; git stash list
```

ブランチ・未コミット件数・最近のコミット・未コミットファイルをまとめ、最後に git-conventions.md の絵文字一覧を添える。
