# Design: sphinx-docs Phase 1 同期

## 編集対象ファイル

```
sphinx-docs/
├── user/
│   ├── index.md          # 「Modules at a glance」テーブル新規追加
│   ├── installation.md   # 警告文を「Phase 1 完成、npm 公開待ち」に更新
│   ├── quickstart.md     # 警告刷新 + Window / WebviewWindow / Channel / Path / App セクション追加 + Event/Channel コールバックを result-typed に同期
│   ├── configuration.md  # Tauri re-export の表を 5 モジュール明示に
│   └── changelog.md      # Unreleased セクションに Phase 1 12 モジュール一覧
└── (dev/ は変更なし — 既存内容は依然有効)
```

## 主要更新

### user/quickstart.md

新規セクション 4 つを末尾近くに追加し、`hello-world` 以外の 3 example へのリンクを掲載:

- **Window operations** — `Window.getCurrent` / `setTitle` / `maximize` / `setSize` の最小例 + `Dpi.LogicalSize.make` 使用例
- **Spawning a `WebviewWindow`** — `WebviewWindow.make` + `asWindow` キャスト
- **Streaming with `Channel`** — `Core.Channel.make` + `onMessage` (新シグネチャの `result<'message, string> => unit`)
- **Path / App utilities** — `open Tauri` 後でも `Path` / `App` は明示パス必須であることを示す

既存の Event subscription サンプルも `result<event<'payload>, string> => unit` シグネチャに更新（並行 steering で Event API が変更されたため）。

### user/configuration.md

`Top-level Tauri re-export` セクションの内容を、確定した 5 モジュール (Core / Event / Window / Webview / WebviewWindow) と、含まれない 6 モジュール (Path / App / Dpi / Image / Menu+Tray / Mocks) を 2 つの表に分割して掲載。Phase 1 リリース直前確定 (PRD §10 #1 = 2026-05-09) を明記。

### user/changelog.md

`Unreleased` の `### Added` を 12 モジュールの一覧、`Tauri.res`、4 examples、9 CI workflows と項目立てて記述。

### user/index.md

「Modules at a glance」テーブルを追加し、12 モジュール + Tauri を 1 行ずつ概略する。

### docs/repository-structure.md

並行 steering のリベース時点で既に `examples/window-management` 等の「未作成」ステータスは消えており、本 steering では追加変更不要（既に実装済表記）。

## ローカルビルド

`uv run sphinx-build -b html . _build/html` で warnings なくビルド成功（CI は同等設定）。`-W` (warnings as errors) では既存の Pygments lexer (`rescript` がリストにない) 関連で 9 件 warning だが、これは並行作業で `make build-all` (CI) は -W を付けない設定なので CI 緑のまま。

## CI 影響

- docs.yml workflow は `make build-all` を実行し warnings を error 扱いしない設定なので、本 steering のドキュメント変更は CI 緑を維持。
- リンク先 (`docs/functional-design.md` など) は変更なしで参照可能。
