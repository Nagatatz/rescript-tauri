# Steering 023: Tauri.res 上位 re-export

| 項目 | 内容 |
|---|---|
| 作成日 | 2026-05-09 |
| 関連 | PRD §10 #1, functional-design §2.8 |
| ブランチ | `worktree-phase1-tauri-reexport` |

## 背景

PRD §10 残課題 #1 「`Tauri.res` の re-export 範囲」。暫定方針は「コア・Event・Window のみ」、確定タイミングは「Phase 1 リリース直前」。Steering 018〜022 で Phase 1 全モジュールが揃ったため、Phase 1 リリース直前確定として本 steering で対応する。

## 決定

functional-design §2.8 に沿い、以下を `Tauri` の re-export 範囲とする：

```rescript
// Tauri.resi
module Core = Core
module Event = Event
module Window = Window
module Webview = Webview
module WebviewWindow = WebviewWindow
```

含めない（heavy なので明示的に `import` させる）：
- `Path` — ユーティリティ関数 31 個。`open Tauri` で名前空間を汚染しない
- `App` — `getName / getVersion` などプロセスメタデータ
- `Dpi` — サイズ・座標型は明示的に使うべき
- `Menu` / `Tray` — heavy + サブモジュール多数
- `Image` — opaque リソース、明示インポート推奨
- `Mocks` — テスト専用

## 要求

- `Tauri.res` / `Tauri.resi` に上記 5 モジュールの re-export を実装
- 各 re-export に何故 Tauri に含まれるかの doc コメント
- `tests/tauri_signature.res` を作成し、`open Tauri` 後に各サブモジュールが使えることを型レベルで確認
- ビルド & テスト緑

## Non-goals

- 全モジュール re-export（決定済みで採用しない）
- `Tauri.X.Y` の長いパスを単純化するヘルパ（不要）

## 受け入れ条件

- [x] `Tauri.res` / `Tauri.resi` 実装
- [x] `tests/tauri_signature.res` 作成
- [x] `pnpm --filter @rescript-tauri/core build` 緑
- [x] `pnpm --filter @rescript-tauri/core test` 緑
- [x] PRD §10 #1 を「決定済み」状態に更新

## PRD 更新

PRD §10 の表の 1 行目を以下のように書き換える：

| # | 論点 | 暫定方針 | 確定タイミング |
|---|---|---|---|
| 1 | `Tauri.res` の re-export 範囲 | **Core / Event / Window / Webview / WebviewWindow（確定）**（経緯: `.steering/20260509-023-tauri-reexport/`） | **確定済み（2026-05-09）** |
