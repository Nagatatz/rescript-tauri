# タスクリスト: Tauri 2.12 系への追従

## 依存更新
- [x] `pnpm update --recursive --latest "@tauri-apps/*"` で全 workspace の dev 依存と `pnpm-lock.yaml` を更新
- [x] #93 の `Cargo.lock` を取り込み、`cargo update -p` で plugin crate を最新化
- [x] `cargo metadata --locked` で lock 整合を確認
- [x] peerDependencies を引き上げ（plugin-fs `^2.6.0` / plugin-shell `^2.5.0` / plugin-notification `^2.6.0`）

## バインディング + テスト
- [x] 新旧 `.d.ts` の差分を取り、対応要否を全件判定（design.md §2）
- [x] core: `App.exit` + 型レベルテスト + runtime テスト
- [x] core: `Window.setFullscreenOnMonitor` + 型レベルテスト + runtime テスト
- [x] core: `effectStyle` の Liquid Glass 2 種 / `effects.interactive` + 型レベルテスト + runtime テスト
- [x] core: `Window.options` / `WebviewWindow.options` の `noRedirectionBitmap` + 型レベルテスト
- [x] plugin-fs: `sizeOptions` / `size ~options` + 型レベルテスト + runtime テスト
- [x] plugin-shell: `spawnOptions.processGroup` + 型レベルテスト + runtime テスト
- [x] plugin-notification: `actionPerformed` / `onAction` + 型レベルテスト
- [x] plugin-notification: `channels` の runtime テスト期待値を `list_channels` に修正
- [x] examples/plugin-notification-demo の `onAction` ハンドラを新 payload に追従

## CI
- [x] `compat-tauri-latest` を `@tauri-apps/*` 全体・全 workspace の build + test に拡張
  - テスト省略: workflow YAML は単体テスト不可。同じコマンド列（update → build → test）をローカルで実行して確認

## ドキュメント
- [x] README / `packages/core/README.md` / 各 plugin README
- [x] `docs/repository-structure.md` / `docs/functional-design.md` / `docs/architecture.md`
- [x] sphinx-docs（`user/changelog.md` / `index.md` / `configuration.md` / `plugin-fs.md` / `plugin-shell.md` / `plugin-notification.md`）
- [x] `make update-po` + ja 翻訳（fuzzy 0 件）、`make build-ja` 成功
- [x] 各パッケージ `CHANGELOG.md` に `Unreleased` 追記（core / plugin-fs / plugin-shell / plugin-notification）

## 検証
- [x] `pnpm --recursive build`
- [x] `pnpm --recursive test`
- [x] `pnpm run check`

## 反映
- [x] コミット・push
- [x] PR 作成 (#94)・CI 確認（`examples-build` 3 OS を含む全チェック pass）
- [x] マージ（ユーザー承認済み）・worktree クリーンアップ
