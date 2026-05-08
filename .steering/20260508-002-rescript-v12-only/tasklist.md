# タスクリスト: ReScript >= 12 のみへのサポート狭小化

| 項目 | 内容 |
|---|---|
| 関連 | `requirements.md` / `design.md` |
| 作成日 | 2026-05-08 |

## Phase 0: 事前承認

- [x] requirements.md レビュー・承認
- [x] design.md レビュー・承認（特に §1 の派生決定 2 つ）
- [x] tasklist.md レビュー・承認

## Phase 1: ステアリング配置 + worktree 起動

- [x] `.steering/20260508-002-rescript-v12-only/` 3 ファイルを main にコミット (`📝 Add steering for 20260508-002 (rescript-v12-only)`)
- [x] `EnterWorktree` で `rescript-v12-only` worktree を作成

## Phase 2: 実装（worktree 内）

design.md §3 に従い `@rescript/core` の v12 互換最低バージョンを確定:

- [x] `npm view @rescript/core versions` で利用可能バージョン取得（0.1.0 〜 1.6.1）
- [x] 各バージョンの `peerDependencies.rescript` を確認し v12 互換最低版を抽出: **`@rescript/core >= 1.6.0`**（1.6.0+ の peerDep は `rescript >=11.1.0` で 12.x も範囲内、1.5.x 以前は `^11.1.0-rc.7` で 12 未対応）

design.md §2 に従いファイルを更新:

- [x] **commit 1**: `docs/product-requirements.md` を v12-only に更新（§2.3 の 6 行 + §10 残課題追記）→ コミット `📝 Drop ReScript 11 from PRD: align dependency policy and roadmap to v12+`
- [x] **commit 2**: `docs/functional-design.md` + `docs/architecture.md` を v12-only に更新（§2.4 の 3 行 + §2.5 の 4 行）→ コミット `📝 Sync functional-design and architecture to ReScript v12-only`
- [x] **commit 3**: `CLAUDE.md` + `docs/glossary.md` + `docs/repository-structure.md` を v12-only に更新（§2.1 / §2.6 / §2.7）→ コミット `📝 Update CLAUDE.md, glossary, repo-structure for ReScript v12-only`
- [x] **commit 4**: `README.md` + `.github/workflows/README.md` を v12-only に更新（§2.2 / §2.8 + `@rescript/core` >= 1.6.0 同期）→ コミット `📝 Update README and CI workflow notes for ReScript v12-only`

## Phase 3: 検証（worktree 内、コミット前）

design.md §6 に従い:

- [ ] grep 残存検出: `grep -rn -E ">=11\.0|ReScript 11\+|v11(?!\.[0-9])" CLAUDE.md README.md docs/ .github/workflows/README.md | grep -v 'docs/ideas/RFC-0001'` の出力が空であること
- [ ] markdown lint 確認（IDE 診断で新規 warning なし）
- [ ] ドキュメント間リンク健全性確認（少なくとも relative path のファイル存在チェック）

## Phase 4: マージ準備

- [ ] **commit 5**: 本 tasklist.md の Phase 0〜3 の項目を `[x]` 化、および本タスク自身（Phase 4 マージタスク）を含めて全 `[x]` 化 → コミット `📝 Mark steering 20260508-002 tasks complete and queue merge`
- [ ] `AskUserQuestion` で main へのマージ可否を確認

## Phase 5: マージ・クリーンアップ

`.claude/rules/steering-workflow.md` の「worktree マージ・クリーンアップ手順」に従う:

- [ ] CWD をメインリポジトリに移動
- [ ] worktree のブランチを `--no-ff` で main にマージ
- [ ] worktree 削除 (`git worktree remove`)
- [ ] ブランチ削除 (`git branch -d`)
- [ ] クリーンアップ検証: `git worktree list` / `git branch --list 'worktree-*'` / `ls .claude/worktrees/`
- [ ] `git push origin main`
