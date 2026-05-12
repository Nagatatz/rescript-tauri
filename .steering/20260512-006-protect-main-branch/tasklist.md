# Tasklist: main ブランチ直 push 禁止

## Phase 0: Steering 準備（main へ直接コミット）

- [x] T0-1: 本 steering ディレクトリと requirements.md / design.md / tasklist.md を作成
- [x] T0-2: ユーザーから requirements / design / tasklist の承認を得る
- [x] T0-3: Phase 0 のドキュメントを main に直接コミット（コミットメッセージ: `📝 Add steering 20260512-006 (protect main branch)`）

## Phase 1: Branch protection 適用

- [x] T1-1: `gh api -X PUT /repos/Nagatatz/rescript-tauri/branches/main/protection` を design.md §2 のペイロードで実行
- [x] T1-2: `gh api /repos/Nagatatz/rescript-tauri/branches/main/protection` で受け入れ条件（enforce_admins, allow_force_pushes 等）を検証

## Phase 2: ワークフロー doc 更新（worktree + PR）

- [x] T2-1: worktree `worktree-protect-main-branch` を作成（EnterWorktree）
- [x] T2-2: `.claude/rules/steering-workflow.md` の「worktree マージ・クリーンアップ手順」を PR ベースに書き換え
- [x] T2-3: `.claude/rules/git-conventions.md` の「ブランチ運用ルール」を PR フローに更新し、直接コミット例外条項（.steering/ / docs/）を削除
- [x] T2-4: `.claude/rules/definition-of-done.md` の Phase 4 / 5 を PR フローに合わせて更新
- [x] T2-5: tasklist.md の T2-1〜T2-4 を `[x]` に更新（worktree 内で）
- [x] T2-6: コミット作成（コミットメッセージ: `📝 Update rules to PR-based main workflow (steering 20260512-006)`）
- [x] T2-7: `git push origin worktree-protect-main-branch`
- [x] T2-8: `gh pr create` で PR 作成（title / body は steering 20260512-006 を参照）
- [x] T2-9: `gh pr merge <pr-number> --merge --delete-branch` で self-merge（PR #2）

## Phase 3: マージ後検証とクリーンアップ

- [x] T3-1: メインリポジトリで `git pull origin main` を実行し、ローカル main を最新化
- [x] T3-2: `git worktree remove .claude/worktrees/protect-main-branch` でローカル worktree を削除（ExitWorktree action=remove）
- [x] T3-3: `git worktree prune` と `git branch --list 'worktree-*'` で残骸が無いことを確認
- [x] T3-4: 動作確認: ローカル main で空 commit を作って `git push origin main` し、拒否されることを目視確認後、commit を `git reset --hard origin/main` で破棄（`GH006: Protected branch update failed` で拒否されることを確認）
- [x] T3-5: tasklist.md の Phase 3 全項目を `[x]` に更新し、main に PR 経由でコミット（コミットメッセージ: `📝 Mark steering 20260512-006 tasklist complete`）

## マージ前最終確認

- [x] T-FIN: tasklist.md の全タスク（T-FIN 自体を含む）が `[x]` になっていることを確認

## メモ

- T3-4 の動作確認は **拒否されることを期待した試験** なので、`git push` が失敗するのが正常。失敗後は `git reset --hard origin/main` でローカルを戻す
- protection 解除が必要になった場合は design.md §6 のロールバック手順を参照
