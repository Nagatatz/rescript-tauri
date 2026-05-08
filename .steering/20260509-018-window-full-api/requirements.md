# Steering 018: Window 全 API 展開 (Phase 1 完了に向けて)

| 項目 | 内容 |
|---|---|
| 作成日 | 2026-05-09 |
| 関連 | PRD §3 Story 3-1, functional-design §2.3, .steering/20260508-014-window-module |
| ブランチ | `worktree-phase1-window-expansion` |

## 背景

Steering 014 で `Window` モジュールの最小バインディング (24 メソッド) を実装し、PRD Story 3-1 と 4-1 の最低限を満たした。一方 Phase 1 リリース要件 (PRD §8) は **Tauri 2.x の Window クラス公開分すべて** を求めている (functional-design §2.3.3)。upstream `@tauri-apps/api ^2.0.0` (v2.11.0 ロック) の `window.d.ts` を確認したところ、未バインドのインスタンス・スタティックメソッドおよび関連型 (Theme, CursorIcon, UserAttentionType, ResizeDirection, TitleBarStyle, ProgressBarState, Effects, Color, WindowSizeConstraints) が 30+ 残存している。

## 要求

1. **インスタンスメソッド網羅:** upstream `Window` クラスの公開インスタンスメソッドをすべて `@send` バインディングで提供する。
2. **`on*` ハンドラ:** `onResized`, `onMoved`, `onCloseRequested`, `onFocusChanged`, `onScaleChanged`, `onThemeChanged`, `onMenuClicked` を提供。
3. **静的メソッド/プロパティ:** `getCurrent`, `getAll`, `getByLabel`, `getFocusedWindow` 等 + `currentMonitor` / `primaryMonitor` / `monitorFromPoint` / `availableMonitors` / `cursorPosition` などの module-level 関数。
4. **型定義:**
   - `theme: [#light | #dark]`
   - `cursorIcon: [...]`（全カーソル値）
   - `userAttentionType: [#critical | #informational]`
   - `resizeDirection: [...]`（8 方向 + 角）
   - `titleBarStyle: [#visible | #transparent | #overlay]`
   - `progressBarStatus: [#none | #normal | #indeterminate | #paused | #error]`
   - `progressBarState: {status?: progressBarStatus, progress?: int}`
   - `monitor`, `effects`, `color`, `windowSizeConstraints` レコード型
5. **opaque を維持:** `Window.t` は opaque のまま (`.resi` で隠蔽)。
6. **doc コメント:** 各公開シンボルに Tauri 公式 URL を含める (`code-comments.md`)。
7. **テスト:** `tests/window_signature.res` を全公開シンボル網羅に拡張、`tests/runtime/window.test.mjs` で代表的呼び出しパスを検証。
8. **互換性:** 既存の Phase 1 バインディング (`make`, `setTitle` 等) のシグネチャは破壊しない。

## Non-goals

- WebviewWindow / Webview の実装（steering 023 で別途実装）。
- Dpi モジュールの正式実装（steering 019 で別途、本 steering では `setSize` などの引数は引き続き polymorphic にする / Dpi 実装後に差し替え）。
- Image モジュール統合（`setIcon` の Image 型受け取りは steering 022 完了後に対応、本 steering では `string` のみ受ける薄いオーバーロードか polymorphic で先行公開）。

## 受け入れ条件

- [x] `pnpm --filter @rescript-tauri/core build` が成功する
- [x] `pnpm --filter @rescript-tauri/core test` が全件パスする
- [x] `tests/window_signature.res` で全公開シンボルがカバーされる
- [x] `.resi` の各シンボルに Tauri 公式 URL が含まれる (doc-link-lint CI 緑)
- [x] 既存テスト (`window.test.mjs`) が引き続きパスする
