# Tasklist: Release v0.1.0 — All 10 Packages

## Phase 0: 計画とセットアップ

- [ ] requirements.md / design.md / tasklist.md を作成
- [ ] `EnterWorktree` で worktree-release-v0.1.0-all-packages を作成
- [ ] ステアリングファイル 3 点を初回コミット

## Phase 1: Cut commit 作成

- [x] T1: 10 個の `packages/*/package.json` の `version` を `0.1.0` に bump (sed)
- [x] T2: 10 個の `packages/*/CHANGELOG.md` の `## Unreleased` を `## 0.1.0 (2026-05-12)` に置換 (sed)
- [x] T3: `sphinx-docs/user/changelog.md` の既存 4 セクションヘッダを `(Unreleased)` から `0.1.0 (2026-05-12)` に置換 (sed)
- [x] T4: `sphinx-docs/user/changelog.md` に 6 プラグイン分の新セクション (`plugin-shell` / `plugin-notification` / `plugin-log` / `plugin-os` / `plugin-clipboard-manager` / `plugin-http`) を挿入
- [x] T5: `git diff --stat` で 21 ファイル変更を確認 (10 package.json + 10 CHANGELOG + 1 sphinx-docs)
- [~] T6: ローカル `pnpm --recursive build` — **省略**: ディスク 93%、worktree に node_modules 不在で pnpm install のリスクあり。変更はメタデータのみで code 変更なし。CI に委ねる
- [~] T7: ローカル `pnpm --recursive test` — **省略**: 同上
- [x] T8: 単一 commit `📝 Cut all packages v0.1.0 (2026-05-12)` を作成

## Phase 2: User confirmation 1 (push commit 前)

- [ ] M1: ユーザーに「cut commit を main に push して release.yml CI を回す」可否を確認

## Phase 3: Push commit & CI 確認

- [ ] T9: worktree branch を main にマージ (--no-ff)
- [ ] T10: worktree / branch クリーンアップ
- [ ] T11: `git push origin main` で 12 commits (steering 4 + cut commit + merge + 過去未 push) を push
- [ ] V1: GitHub Actions タブで全 CI workflow (`build-core`, `tests-*-types`, `tests-*-runtime`, `examples-build`, `lint-format`, `doc-link-lint`, `docs`) が green を確認

## Phase 4: User confirmation 2 (tag push 前)

- [ ] M2: ユーザーに「v0.1.0 タグを push して npm publish をトリガする」可否を確認

## Phase 5: core タグ push & 公開検証

- [ ] T12: `git tag -a v0.1.0 -m "v0.1.0 — Phase 1 release (core)"` 作成
- [ ] T13: `git push origin v0.1.0`
- [ ] V2: GitHub Actions の `release.yml` 実行を `gh run watch` で確認
- [ ] V3: `npm view @rescript-tauri/core version` が `0.1.0` を返すこと
- [ ] V4: `npm view @rescript-tauri/core dist-tags.latest` が `0.1.0` を返すこと
- [ ] V5: GitHub Releases ページに `v0.1.0` release が出現

## Phase 6: User confirmation 3 (plugin tags push 前)

- [ ] M3: ユーザーに「9 plugin tags を順次 push する」可否を確認

## Phase 7: 9 plugin tags push & 公開検証

- [ ] T14: `schema-v0.1.0` push & 完了確認
- [ ] T15: `plugin-fs-v0.1.0` push & 完了確認
- [ ] T16: `plugin-dialog-v0.1.0` push & 完了確認
- [ ] T17: `plugin-shell-v0.1.0` push & 完了確認
- [ ] T18: `plugin-notification-v0.1.0` push & 完了確認
- [ ] T19: `plugin-log-v0.1.0` push & 完了確認
- [ ] T20: `plugin-os-v0.1.0` push & 完了確認
- [ ] T21: `plugin-clipboard-manager-v0.1.0` push & 完了確認
- [ ] T22: `plugin-http-v0.1.0` push & 完了確認

## Phase 8: 公開後検証

- [ ] V6: 全 10 パッケージの `npm view <pkg> version` が `0.1.0` を返す
- [ ] V7: 全 10 パッケージの `npm view <pkg> dist-tags.latest` が `0.1.0` を返す
- [ ] V8: 9 plugin の `peerDependencies` に `@rescript-tauri/core: ^0.1.0` が含まれる
- [ ] V9: GitHub Releases ページに 10 件の release (v0.1.0 + 9 plugin tags) が出現
- [ ] V10: スモーク試験 (`/tmp/rt-smoke` で pnpm add) が peer dep error なく完了

## Phase 9: ステアリング完了

- [ ] T23: 本 tasklist.md を全 `[x]` に更新する最終コミット
- [ ] T24: 最終コミットを push
- [ ] M4: 残課題（Phase 3 計画起点 / アナウンス）を別ステアリングで起票するか判断
