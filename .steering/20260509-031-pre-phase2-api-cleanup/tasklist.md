# Pre-Phase 2 API 表面クリーンアップ — タスクリスト

## Phase 1: ステアリング作成

- [x] 要件定義 (`requirements.md`)
- [x] 設計 (`design.md`)
- [x] タスクリスト (`tasklist.md`)
- [x] worktree 作成 (`pre-phase2-api-cleanup`)

## Phase 2: 実装

### Step 1 — Dpi 型のポリモーフィック解消（Window）

- [ ] `packages/core/src/Window.res` の `'size` / `'position` を具体型に置換
- [ ] `packages/core/src/Window.resi` の対応シグネチャ更新（doc コメントから "Polymorphic until..." を削除）
- [ ] `packages/core/tests/window_signature.res` の型注釈を更新

### Step 2 — Dpi 型のポリモーフィック解消（Webview）

- [ ] `packages/core/src/Webview.res` の `'size` / `'position` / `'pos` を具体型に置換
- [ ] `packages/core/src/Webview.resi` のシグネチャ更新（doc コメント整備）
- [ ] `packages/core/tests/webview_signature.res` の型注釈を更新

### Step 3 — Dpi 型のポリモーフィック解消（Tray）

- [ ] `packages/core/src/Tray.res` の `'pos` / `'size` を具体型に置換
- [ ] `packages/core/src/Tray.resi` のシグネチャ更新
- [ ] `packages/core/tests/tray_signature.res` の型注釈を更新

### Step 4 — App.theme の Window.theme 化

- [ ] `packages/core/src/App.res` の `type theme = [#light | #dark]` を `type theme = Window.theme` に変更
- [ ] `packages/core/src/App.resi` の対応更新

### Step 5 — Core 内部 API の Internal モジュール化

- [ ] `packages/core/src/Core.res` で `_applyDecoder` / `_exnToJson` を `Core.Internal.applyDecoder` / `Core.Internal.exnToJson` に再配置
- [ ] `packages/core/src/Core.resi` で `_applyDecoder` を削除し、`module Internal: { ... }` を追加
- [ ] `packages/core/src/Event.res` の `Core._applyDecoder` 呼び出しを `Core.Internal.applyDecoder` に更新
- [ ] `Core.Command.invoke` 内部の `_exnToJson` 参照を更新

### Step 6 — examples / docs の追従

- [ ] `examples/window-management/` のサイズ/位置を扱うコードが新シグネチャでビルドできること
- [ ] `examples/streaming-ipc/` 等の影響箇所を確認・修正
- [ ] `docs/functional-design.md` の記述が古くなっていないか確認、必要なら更新

## Phase 3: 検証

- [ ] `pnpm --recursive build` が成功する
- [ ] `pnpm --recursive test` が成功する

## Phase 4: コミット

- [ ] Step 1 (Window) を 1 コミット: `♻️ Concretize Dpi types in Window bindings`
- [ ] Step 2 (Webview) を 1 コミット: `♻️ Concretize Dpi types in Webview bindings`
- [ ] Step 3 (Tray) を 1 コミット: `♻️ Concretize Dpi types in Tray bindings`
- [ ] Step 4 (App.theme) を 1 コミット: `♻️ Re-export Window.theme from App`
- [ ] Step 5 (Core.Internal) を 1 コミット: `♻️ Move Core internal helpers into Core.Internal submodule`
- [ ] Step 6 (examples/docs) があれば 1 コミット: `🔧 Update examples and docs for Dpi type concretization`
- [ ] tasklist.md を `[x]` 化してマージ前最終コミット

## Phase 5: マージ

- [ ] AskUserQuestion で main マージ可否確認
- [ ] 承認後、worktree マージ・クリーンアップ手順に従い実行
- [ ] クリーンアップ完了の検証
