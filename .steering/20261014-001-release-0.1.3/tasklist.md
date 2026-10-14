# Tasklist: 20261014-001 release-0.1.3

## Phase 1: 計画
- [x] 採番 / worktree 作成 / steering 3 点作成（バージョン方針はユーザー決定済み）

## Phase 2: 実装
- [x] T1. `packages/*/package.json` version（notification 0.2.0 / 他 0.1.3）
- [x] T2. `packages/*/CHANGELOG.md` 確定（4 件は Unreleased 置換、6 件は maintenance entry 追加）
- [x] T3. `sphinx-docs/user/changelog.md` / `sphinx-docs/index.md` / `README.md` / `CONTRIBUTING.md` 更新 + `make update-po` + ja 翻訳
- [x] テスト: コード変更なしのため新規テストなし（既存全件 pass で確認）

## Phase 3: 検証・コミット
- [x] V1. `pnpm install --frozen-lockfile` + build + test + check
- [x] V2. sphinx html / build-ja / test
- [x] C1. コミット `🔧 Release 0.1.3 (plugin-notification 0.2.0)`

## Phase 4: PR / マージ / 公開
- [x] push → `gh pr create` → CI green → self-merge
- [x] CWD を main に戻し pull → worktree / ブランチ削除 → クリーンアップ検証
- [ ] merge commit に 10 tag を作成し 1 本ずつ push → release.yml 10 run success
- [ ] npm で plugin-notification 0.2.0 / 他 9 件 0.1.3 を確認
