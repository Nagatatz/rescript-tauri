# Tasklist: 20260830-002 release-0.1.2

## Phase 1: 計画
- [x] 採番 / worktree 作成 / steering 3 点作成

## Phase 2: 実装
- [x] T1. `packages/*/package.json` version 0.1.2
- [x] T2. `packages/*/CHANGELOG.md` Unreleased → 0.1.2 (2026-08-30)
- [x] T3. `sphinx-docs/user/changelog.md` 更新 + `make update-po` + ja 翻訳（changelog.po 7 entry / index.po 1 entry）。あわせて README.md / CONTRIBUTING.md / sphinx-docs/index.md の「初回 npm publish 待ち」表記を公開済みに更新
- [x] テスト: コード変更なしのため新規テストなし（既存全件 pass で確認）

## Phase 3: 検証・コミット
- [x] V1. `pnpm install --frozen-lockfile` + build + test + check
- [x] V2. sphinx html / build-ja / test
- [x] C1. コミット `🔧 Bump all packages to 0.1.2`

## Phase 4: PR / マージ / 公開
- [x] push → `gh pr create` (PR #57) → CI green (41 pass / 2 skip) → self-merge (`c8e9ee9`)
- [x] CWD を main に戻し pull → worktree / ブランチ削除 → クリーンアップ検証
- [x] merge commit に 10 tag を作成・push → release.yml 10 run success（run 33266385043〜33266445645）。**注意**: 10 tag を 1 回の `git push` でまとめて push したところ push イベントが生成されず release.yml が起動しなかった（GitHub 仕様: 4 個以上の tag を同時 push するとイベントが作られない）。remote tag を削除し 8 秒間隔で 1 本ずつ push し直して解決
- [x] `npm view` で 10 パッケージ 0.1.2 確認（plugin-notification のみ数分の伝播遅延あり、registry API で `latest: 0.1.2` を確認）

## Phase 5: 完了記録
- [x] 本 tasklist の Phase 4 完了記録 + `docs/development-guidelines.md` §9 にタグ push の注意を追記（PR 経由）
