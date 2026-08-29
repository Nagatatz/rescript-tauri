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
- [ ] push → `gh pr create` → CI green → self-merge
- [ ] CWD を main に戻し pull → worktree / ブランチ削除 → クリーンアップ検証
- [ ] merge commit に 10 tag を作成・push → release.yml 10 run success
- [ ] `npm view` で 10 パッケージ 0.1.2 確認
