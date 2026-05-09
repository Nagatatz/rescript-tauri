# 用語集 (Glossary)

| 項目 | 内容 |
|---|---|
| 役割 | 本プロジェクトのユビキタス言語の正本 |
| 作成日 | 2026-05-08 |
| 更新ポリシー | 新概念導入時に追記。命名・定義に揺れがあれば本書を優先する |

> 本書はプロジェクト固有用語・Tauri 用語・ReScript 用語・パッケージング用語を一元管理する。PRD / 機能設計書 / アーキテクチャ書に出てくる専門語の定義はすべて本書を参照する。

---

## 1. 本プロダクト固有用語

| 用語 | 定義 |
|---|---|
| **rescript-tauri** | 本プロジェクト全体を指す名称。`@rescript-tauri` npm scope のパッケージ群（`core`, `schema`, `plugin-*`）を含む。 |
| **`@rescript-tauri/core`** | Phase 1 の中心パッケージ。Tauri 2.x の `@tauri-apps/api` に対する ReScript バインディングを提供する。 |
| **`@rescript-tauri/schema`** | Phase 2 で merged されたスキーマ統合パッケージ（初版 publish 待ち）。`rescript-schema` から `Command.t` / `Channel.t` / `Event.t` を派生させる。 |
| **`@rescript-tauri/plugin-*`** | 上流 `@tauri-apps/plugin-*` に対応する ReScript バインディングパッケージ群。Phase 2 で `plugin-fs` / `plugin-dialog` が merged（初版 publish 待ち）。各々独立 publish。 |
| **Layer 1 / Layer 2 / Layer 3** | IPC API の抽象化階層。Layer 1 = Raw（薄い） / Layer 2 = Typed Command / Layer 3 = Schema 統合（外部パッケージ）。詳細は `architecture.md` §3。 |
| **互換マトリクス** | `@rescript-tauri/core` の各バージョンが対応する `@tauri-apps/api` / ReScript / `@rescript/core` のバージョン対応表。README に必須掲載（PRD Story 7-1）。 |

---

## 2. Tauri 用語

| 用語 | 定義 | 参照 |
|---|---|---|
| **Tauri** | Rust 製のクロスプラットフォーム desktop アプリフレームワーク。本プロダクトの対象は Tauri 2.x。 | <https://v2.tauri.app/> |
| **`@tauri-apps/api`** | Tauri 公式 JS/TS SDK。本プロダクトはこれを ReScript からアクセス可能にする。 | npm: `@tauri-apps/api` |
| **IPC (Inter-Process Communication)** | Tauri における WebView (JS) と Rust ランタイム間のメッセージング基盤。 | — |
| **invoke** | フロントエンドから Rust 側コマンド（`#[tauri::command]`）を呼び出す Tauri の標準 API。 | <https://v2.tauri.app/develop/calling-rust/> |
| **convertFileSrc** | ローカルファイルパスを WebView から読める URL 形式に変換するユーティリティ。 | <https://v2.tauri.app/reference/javascript/api/namespacecore/#convertfilesrc> |
| **Channel** | Tauri 2.0+ の一方向ストリーミング機構。Rust → フロントへ任意タイミングで複数メッセージを送る。`invoke` の引数として渡す。 | <https://v2.tauri.app/concept/inter-process-communication/#channel> |
| **Event** | Tauri の pub/sub。`Window` / `App` スコープでブロードキャスト可能。`listen` / `emit` / `once` で操作。 | <https://v2.tauri.app/develop/calling-rust/#event-system> |
| **Predefined Event** | Tauri が提供するビルトインイベント群（`tauri://close-requested`, `tauri://focus`, `tauri://blur` ほか）。 | — |
| **Window** | Tauri のウィンドウ抽象。`@tauri-apps/api/window` の `Window` クラスに対応。 | <https://v2.tauri.app/reference/javascript/api/namespacewindow/> |
| **Webview** | Tauri の WebView 抽象。`Window` とは独立して操作可能。 | <https://v2.tauri.app/reference/javascript/api/namespacewebview/> |
| **WebviewWindow** | `Window` + `Webview` を合成した便利クラス。JS 上では prototype chain で両クラスのメソッドを継承。 | <https://v2.tauri.app/reference/javascript/api/namespacewebviewwindow/> |
| **Menu / Submenu / MenuItem** | アプリメニュー構成要素。デスクトップアプリ特有のメニューバーやコンテキストメニューを構築する。 | <https://v2.tauri.app/reference/javascript/api/namespacemenu/> |
| **TrayIcon** | システムトレイ常駐アイコン。 | <https://v2.tauri.app/reference/javascript/api/namespacetray/> |
| **`__TAURI_INTERNALS__`** | WebView に注入される Tauri ランタイムのグローバルオブジェクト。テスト時にモックする対象。 | — |
| **`@tauri-apps/api/mocks`** | テスト用 IPC モック API。`mockIPC` / `mockWindows` / `clearMocks` を提供する。 | <https://v2.tauri.app/reference/javascript/api/namespacemocks/> |

---

## 3. ReScript 用語

| 用語 | 定義 |
|---|---|
| **ReScript** | OCaml 由来の関数型言語で JS にコンパイルされる。本プロダクトの一次対象言語。 |
| **`@rescript/core`** | ReScript 公式の標準ライブラリ後継。`JSON.t`, `Dict.t`, `Nullable.t` 等を提供。本プロダクトの peerDep。 |
| **`.res` / `.resi`** | `.res` = 実装ファイル、`.resi` = インターフェイス（公開 API シグネチャ）ファイル。本プロダクトでは `.resi` を必須化する。 |
| **opaque type** | `.resi` で定義のみ公開し中身を隠蔽した型。本プロダクトでは JS クラス値（`Window.t` 等）の表現に使用。 |
| **polymorphic variant** | `[#name]` 構文で表される open variant。文字列にコンパイルされる（ランタイムコスト 0）。string-literal union の表現に使う。 |
| **closed bound / open bound** | polymorphic variant の境界指定。`.resi` 公開 API では closed bound（`[#light \| #dark]`）で型を確定する。 |
| **`@as("...")`** | polymorphic variant の ReScript spelling と JS spelling が異なる場合に補正する decorator。例: `#notAllowed @as("notAllowed")`。 |
| **`@send`** | ReScript の decorator。JS の instance method 呼び出しを外部関数としてバインドする。第 1 引数がレシーバになる。 |
| **`@module`** | npm モジュールから関数や値を import する decorator。 |
| **`@scope`** | `@module` と組み合わせて静的メソッド呼び出しをバインドする decorator。例: `@scope("Window")`。 |
| **`@new`** | JS クラスのコンストラクタ呼び出しをバインドする decorator。 |
| **`%identity`** | ReScript の組み込みキャスト。実行時に no-op で型だけを変換する。`WebviewWindow.t` を `Window.t` として扱うのに使用。 |
| **pipe-first (`->`)** | ReScript の関数呼び出し演算子。`x->f(y)` は `f(x, y)` と等価。本プロダクトのインスタンスメソッド API はすべて pipe-first 前提。 |
| **`promise<'a>`** | ReScript の標準 Promise 型。`async/await` で扱う。 |
| **`result<'a, 'e>`** | ReScript の Result 型（`Ok('a) \| Error('e)`）。本プロダクトの Layer 2 IPC で失敗を表現する。 |
| **`*Exn` 命名規約** | `result` を unwrap し失敗時に raise する関数の suffix。`@rescript/core` 慣習に準拠（`Belt.Array.getExn` など）。 |
| **uncurried** | ReScript v12 以降で default となる関数呼び出し慣習。本プロダクトは v12+ をターゲットとし uncurried-by-default を前提とする。 |
| **namespace (`namespace: true`)** | `rescript.json` のオプション。有効化するとパッケージ名がモジュール接頭辞になる（例: `RescriptTauriCore.Core`）。 |

---

## 4. パッケージング・配布用語

| 用語 | 定義 |
|---|---|
| **`peerDependencies`** | npm の依存形態。利用者側で版を解決する依存（自動 install されない）。本プロダクトは `@tauri-apps/api` / `rescript` / `@rescript/core` を peerDep として宣言する。 |
| **`dependencies`** | パッケージインストール時に自動 install される依存。本プロダクトの core パッケージは **0 件**（`peerDependencies` のみ）。 |
| **`devDependencies`** | 開発時のみ必要な依存（テスト・ビルドツール等）。 |
| **semver** | Semantic Versioning。`MAJOR.MINOR.PATCH`。本プロダクトの各パッケージは独立 semver で運用する。 |
| **monorepo / pnpm workspaces** | 複数パッケージを 1 リポジトリで管理する構成。本プロダクトは `pnpm-workspace.yaml` で `packages/*` と `examples/*` を workspace 化する。 |
| **互換マトリクス** | パッケージバージョンと依存先バージョンの対応表。README に必須掲載。 |

---

## 5. プロセス・ドキュメント用語

| 用語 | 定義 |
|---|---|
| **PRD (Product Requirements Document)** | プロダクト要求定義書。`docs/product-requirements.md`。 |
| **RFC (Request For Comments)** | 大型設計提案ドキュメント。`docs/ideas/RFC-NNNN-*.md` に置く。確定後は PRD / functional-design / architecture に反映され、RFC 自体は historical input として保存される。 |
| **steering ワークフロー** | 中規模以上のコード変更時に `.steering/[YYYYMMDD]-[NNN]-[title]/` で `requirements.md` / `design.md` / `tasklist.md` を作成する本プロジェクトの規約。詳細は `.claude/rules/steering-workflow.md`。 |
| **Definition of Done (DoD)** | 作業の完了条件を一元管理する正本。詳細は `.claude/rules/definition-of-done.md`。 |
| **worktree** | git worktree。本プロジェクトでは Claude Code のビルトイン worktree 機能で隔離された実装環境を作る。 |
| **Phase 1 / Phase 2 / Phase 3** | リリース計画上のマイルストーン区分。詳細は PRD §8。 |

---

## 6. 略号

| 略号 | フル | 文脈 |
|---|---|---|
| **API** | Application Programming Interface | 本プロジェクトでは `@tauri-apps/api` を「上流 API」と呼ぶ |
| **IPC** | Inter-Process Communication | Tauri の WebView ↔ Rust 間メッセージング |
| **CI** | Continuous Integration | GitHub Actions ジョブ群 |
| **CWD** | Current Working Directory | worktree 操作時の安全規約で頻出 |
| **DoD** | Definition of Done | Phase 完了条件 |
| **KPI / KGI** | Key Performance Indicator / Key Goal Indicator | PRD §7 成功指標 |
| **OSS** | Open Source Software | — |
| **MCP** | Model Context Protocol | Claude Code の外部ツール接続規格。`docs/mcp-servers.md` 参照 |
| **PR** | Pull Request | GitHub の変更提案 |
| **WIP** | Work In Progress | 中断時の WIP コミット等 |
