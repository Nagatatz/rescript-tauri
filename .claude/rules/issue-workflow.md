# GitHub Issue による作業管理

1. 着手前に同じ目的の Issue/PR がないか検索し、既存の記録を優先する。作業を引き取る前に担当者・作業中のラベル・既存 PR を確認する。
2. Issue 本文に背景、対象と対象外、制約、検証可能な `## DoD` を記載する。長期保守が必要な設計は `docs/` に置き Issue から参照する。必要な決定は Issue で「要判断」とし、承認が必要な部分だけ保留する。
3. `origin/main` の鮮度を確認し、既存のローカル作業を上書きせず、変更は専用のブランチ / worktree で作る。worktree の安全な扱いは `../skills/worktree-safety/SKILL.md` を参照。
4. 実装・テスト・関連文書を一つの論理的変更にまとめる。長い作業は独立した Issue または検証が通る小さなコミットに分け、残件・最後のコミット・確認結果を Issue に残す。
5. チェック項目は検証できたときだけ完了にする。Issue 本文を書き換える前に取り直し、他者の変更を維持する。PR は Issue とリンクし、完了させる PR だけに `Closes #N` を使う。
6. main への直接 push は行わない。マージは CI と必要な承認を確認してから `gh pr merge <番号> --merge --delete-branch` を使う。マージ後、worktree を削除する前に CWD を既存のメイン checkout 等に移す。使用中・変更のある worktree や他者のブランチは削除しない。
7. `.steering/` は過去資料として読み取り専用で残す。新規作業では steering 番号、並行番号予約、`requirements.md` / `design.md` / `tasklist.md` の三点セットを使わない。

既定の確認項目と検証コマンドは `definition-of-done.md` とルートの `AGENTS.md` を参照。
