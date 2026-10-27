---
description: git worktree を作成・削除・整理するとき、または "ENOENT: no such file or directory" / posix_spawn エラーで CWD が壊れたときの復旧に使用。削除順序の必須規約と Agent ツールでの復旧。
allowed-tools: Read, Bash, Agent
---

# Git Worktree 安全ルール

worktree から main への反映（push → PR → self-merge → 後片付け）は `.claude/rules/steering-workflow.md`「worktree から main への反映手順」に従う。本 skill は破壊的操作の禁止事項を持つ。

worktree 内を CWD にしたまま `git worktree remove` や `git branch -d|-D` を実行すると、シェルの CWD が消えて全 Bash が `ENOENT ... posix_spawn '/bin/sh'` で失敗し、続行できなくなる。

## 削除の順序（必須）

1. メインリポジトリのルートへ `cd` する（単独の Bash 呼び出しで。`git -C` は CWD を動かさないので代用不可）。
2. `git worktree remove <worktree-path>`（または `git worktree prune`）。
3. `git branch -d <ブランチ名>` で不要なブランチを削除する。

Agent tool の `isolation: "worktree"` で作った worktree の後片付けにも同じ順序を適用する。

## 禁止

- worktree ディレクトリ内での `git worktree remove`
- worktree ディレクトリ内での `git branch -d` / `git branch -D`
- メインリポジトリへ `cd` せずに worktree を削除すること

## CWD が既に壊れている場合

通常の Bash は何も実行できない。**Agent tool（`subagent_type=general-purpose`）** で別プロセスからクリーンアップする。
