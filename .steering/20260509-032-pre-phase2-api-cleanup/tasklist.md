# Pre-Phase 2 API 表面クリーンアップ — タスクリスト

## Phase 1: ステアリング作成

- [x] 要件定義 (`requirements.md`)
- [x] 設計 (`design.md`)
- [x] タスクリスト (`tasklist.md`)
- [x] worktree 作成 (`pre-phase2-api-cleanup`)

## Phase 2: 実装

### Step 1 — Dpi 型のポリモーフィック解消（Window）

- [x] `packages/core/src/Window.res` の `'size` / `'position` を具体型に置換
- [x] `packages/core/src/Window.resi` の対応シグネチャ更新（doc コメントから "Polymorphic until..." を削除）
- [x] `packages/core/tests/window_signature.res` の型注釈を更新

### Step 2 — Dpi 型のポリモーフィック解消（Webview）

- [x] `packages/core/src/Webview.res` の `'size` / `'position` / `'pos` を具体型に置換
- [x] `packages/core/src/Webview.resi` のシグネチャ更新（doc コメント整備）
- [x] `packages/core/tests/webview_signature.res` の型注釈を更新

### Step 3 — Dpi 型のポリモーフィック解消（Tray）

- [x] `packages/core/src/Tray.res` の `'pos` / `'size` を具体型に置換
- [x] `packages/core/src/Tray.resi` のシグネチャ更新
- [x] `packages/core/tests/tray_signature.res` の型注釈を更新

### Step 4 — App.theme の Window.theme 化

- [x] `packages/core/src/App.res` の `type theme = [#light | #dark]` を `type theme = Window.theme` に変更
- [x] `packages/core/src/App.resi` の対応更新

### Step 5 — Core 内部 API の Internal モジュール化

- [x] `packages/core/src/Core.res` で `_applyDecoder` / `_exnToJson` を `Core.Internal.applyDecoder` / `Core.Internal.exnToJson` に再配置
- [x] `packages/core/src/Core.resi` で `_applyDecoder` を削除し、`module Internal: { ... }` を追加
- [x] `packages/core/src/Event.res` の `Core._applyDecoder` 呼び出しを `Core.Internal.applyDecoder` に更新
- [x] `Core.Command.invoke` 内部の `_exnToJson` 参照を更新

### Step 6 — examples / docs の追従

- [x] `examples/window-management/` のサイズ/位置を扱うコードが新シグネチャでビルドできること（`Dpi.Size.fromLogical` でラップ）
- [x] `examples/streaming-ipc/` 等の影響箇所を確認・修正（既存バグ：result-based callback への追従を別コミットで修正済み）
- [x] `docs/functional-design.md` / `sphinx-docs/` に古い記述がないか確認（grep で参照なしと確認）

## Phase 3: 検証

- [x] `pnpm --recursive build` が成功する
- [x] `pnpm --recursive test` が成功する

## Phase 4: コミット

- [x] streaming-ipc 既存バグ修正 + steering 同梱: `🐛 Fix streaming-ipc example for result-based Channel.onMessage callback`
- [x] Step 1 (Window) を 1 コミット: `♻️ Concretize Dpi types in Window bindings`
- [x] Step 2 (Webview) を 1 コミット: `♻️ Concretize Dpi types in Webview bindings`
- [x] Step 3 (Tray) を 1 コミット: `♻️ Concretize Dpi types in Tray bindings`
- [x] Step 4 (App.theme) を 1 コミット: `♻️ Re-export Window.theme from App`
- [x] Step 5 (Core.Internal) を 1 コミット: `♻️ Move Core internal helpers into Core.Internal submodule`
- [x] Step 6 (examples) を 1 コミット: `🔧 Update window-management example for Dpi.Size.t setSize signature`
- [x] tasklist.md を `[x]` 化してマージ前最終コミット

## Phase 5: マージ

- [x] AskUserQuestion で main マージ可否確認
- [x] 承認後、worktree マージ・クリーンアップ手順に従い実行
- [x] クリーンアップ完了の検証
