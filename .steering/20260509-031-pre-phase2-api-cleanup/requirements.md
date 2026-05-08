# Pre-Phase 2 API 表面クリーンアップ — 要件

| 項目 | 内容 |
|---|---|
| 作業 ID | 20260509-031-pre-phase2-api-cleanup |
| 開始日 | 2026-05-09 |
| 状態 | 進行中 |
| 関連 | `.steering/20260509-027-core-refactoring/`、`.steering/20260509-030-phase2-planning/` |

## 背景

Phase 1 完了直後・Phase 2 着手前のタイミングで、`packages/core/` の API 表面に積み残された tech debt を解消する。Pre-1.0 のため後方互換性は不要（`MEMORY.md` 参照）。本作業はトリアージ調査（2026-05-09 実施）で抽出された高レバレッジ候補のうち、API 表面に直結する 3 件をまとめて処理する。

## 対象範囲

### 含む

1. **Dpi 型のポリモーフィック解消**: Phase 1 で `'size` / `'position` の placeholder として残されていた箇所を、現在実装されている `Dpi.Size.t` / `Dpi.Position.t` で置換する。対象: `Window`, `Webview`, `WebviewWindow`, `Tray`。
2. **`App.theme` と `Window.theme` の統合**: 同一定義 `[#light | #dark]` の二重宣言を `Window.theme` に集約。`App` は再エクスポート。
3. **`Core._applyDecoder` / `_exnToJson` の隠蔽**: `.resi` から外し、`Core.Internal` サブモジュールへ移動するか `.res` 内のローカル `let` のみで共有。

### 含まない

- Menu / Event の codec 共通化（→ 別ステアリング 032 へ）
- 軽微な命名修正（Image.new_、Path.BaseDirectory、App.setTheme 引数名等）
- Phase 2 本体（plugin-fs 等）の実装

## 受け入れ基準

- [ ] `pnpm --recursive build` が成功する
- [ ] `pnpm --recursive test` が成功する（既存テストは破壊変更に追従して更新可）
- [ ] `Window.resi` / `Webview.resi` / `Tray.resi` から `'size` / `'position` の generic placeholder が消滅し、`Dpi.Size.t` / `Dpi.Position.t` 等の具体型に置き換わっている
- [ ] `Window.resi` / `Webview.resi` 等で「Polymorphic until the `Dpi` module..." のコメントが解消されている
- [ ] `App.res` / `App.resi` から重複する `theme` 定義が消え、`Window.theme` を経由している
- [ ] `Core.resi` から `_applyDecoder` / `_exnToJson` が消えている。Event / Channel が依存している場合は `Core.Internal` 等の経路に移行している
- [ ] 既存テスト（`tests/*_signature.res`, `tests/runtime/`）が新シグネチャに追従して通る
- [ ] examples（hello-world, ipc-typed, streaming-ipc, window-management）がビルドできる

## 制約

- **後方互換性無視**: 破壊変更を許容（`MEMORY.md` の pre-release ポリシー参照）
- **API 設計**: Tauri 公式 SDK のシグネチャに整合させる（`https://v2.tauri.app/reference/javascript/api/...`）
- **doc コメント**: 必須コメント（`code-comments.md`）と Tauri 公式 URL リンクを保持
