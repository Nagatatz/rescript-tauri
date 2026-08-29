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

- [x] T9: worktree branch を main にマージ (--no-ff)
- [x] T10: worktree / branch クリーンアップ
- [x] T11: `git push origin main` で 3 commits (steering 4 + cut commit + merge) を push (過去未 push 分はユーザーが並列で push 済み)
- [x] V1: GitHub Actions タブで全 CI workflow (`build-core`, `tests-*-types`, `tests-*-runtime`, `examples-build`, `lint-format`, `doc-link-lint`, `docs`) が green を確認

## Phase 4: User confirmation 2 (tag push 前)

- [x] M2: ユーザーに「v0.1.0 タグを push して npm publish をトリガする」可否を確認 → 承認

## Phase 5: core タグ push & 公開検証

- [x] T12: `git tag -a v0.1.0 -m "v0.1.0 — Phase 1 release (@rescript-tauri/core)"` 作成
- [x] T13: `git push origin v0.1.0`
- [x] V2: release.yml 25689466997 が `completed/success`
- [x] V3: `npm view @rescript-tauri/core version` → `0.1.0` 確認
- [x] V4: `npm view @rescript-tauri/core dist-tags.latest` → `0.1.0` 確認
- [x] V5: GitHub Releases ページに `v0.1.0` release 出現確認

## Phase 6: User confirmation 3 (plugin tags push 前)

- [x] M3: ユーザーに「9 plugin tags を一気に push する」可否を確認 → 承認

## Phase 7: 9 plugin tags push & 公開検証

- [x] T14-T22: 9 plugin tags 作成・push
  - **既知の GitHub Actions の挙動**: 9 タグを単一 `git push` で送ると release.yml が trigger されない問題に遭遇 → 各タグ delete + 個別再 push でリカバリ
  - schema-v0.1.0 ~ plugin-http-v0.1.0 すべて release.yml `completed/success`

## Phase 8: 公開後検証

- [x] V6: 全 10 パッケージの `npm view <pkg> version` が `0.1.0` を返す
- [x] V7: 全 10 パッケージの `npm view <pkg> dist-tags.latest` が `0.1.0` を返す
- [x] V8: 9 plugin の `peerDependencies` に `@rescript-tauri/core: ^0.1.0` が含まれる
- [x] V9: GitHub Releases ページに 10 件の release (v0.1.0 + 9 plugin tags) 出現
- [~] V10: スモーク試験 — **省略**: ディスク 94% / pnpm install が 1-2GB 消費するため。CI examples-build が peerDep を含む実 install を検証済み

## Phase 9: ステアリング完了

- [x] T23: 本 tasklist.md を全 `[x]` に更新する最終コミット
- [ ] T24: 最終コミットを push
- [ ] M4: 残課題（Phase 3 計画起点 / アナウンス）を別ステアリングで起票するか判断
