# リポジトリ構造定義書 (Repository Structure)

| 項目 | 内容 |
|---|---|
| プロダクト | `@rescript-tauri/core` および周辺パッケージ群 |
| 構造形式 | pnpm workspaces によるモノレポ |
| 作成日 | 2026-05-08 |
| 関連 | [docs/functional-design.md](./functional-design.md) §1.1, [docs/product-requirements.md](./product-requirements.md) §1.4 |

> 本書は CLAUDE.md から `@import` され、Claude Code が常に参照する。リポジトリ内のディレクトリ・ファイルの位置と責務の **正本**。新規ディレクトリ追加時は本書を必ず更新する。

---

## 1. ルートレイアウト

```
rescript-tauri/                          # monorepo root
├── packages/                            # 公開パッケージ群
│   ├── core/                            # @rescript-tauri/core
│   ├── plugin-fs/                       # @rescript-tauri/plugin-fs
│   ├── plugin-dialog/                   # @rescript-tauri/plugin-dialog
│   ├── plugin-shell/                    # @rescript-tauri/plugin-shell
│   ├── plugin-notification/             # @rescript-tauri/plugin-notification
│   ├── plugin-log/                      # @rescript-tauri/plugin-log
│   ├── plugin-os/                       # @rescript-tauri/plugin-os
│   ├── plugin-clipboard-manager/        # @rescript-tauri/plugin-clipboard-manager
│   ├── plugin-http/                     # @rescript-tauri/plugin-http
│   └── schema/                          # @rescript-tauri/schema
├── examples/                            # ビルド可能な使用例（CI ゲート対象）
│   ├── hello-world/                     # 最小構成
│   ├── window-management/
│   ├── ipc-typed/
│   ├── streaming-ipc/
│   ├── plugin-fs-demo/
│   ├── plugin-dialog-demo/
│   ├── plugin-shell-demo/
│   ├── plugin-http-demo/
│   ├── plugin-clipboard-manager-demo/
│   ├── plugin-log-demo/
│   ├── plugin-notification-demo/
│   ├── plugin-os-demo/
│   └── ipc-typed-with-schema/           # Layer 3 demo
├── docs/                                # 開発チーム向け内部ドキュメント
│   ├── ideas/                           # ドラフト・RFC 集約
│   ├── product-requirements.md
│   ├── functional-design.md
│   ├── architecture.md
│   ├── repository-structure.md          # 本書
│   ├── glossary.md
│   ├── development-guidelines.md
│   └── mcp-servers.md
├── sphinx-docs/                         # 外部公開ドキュメント (GitHub Pages)
│   ├── user/                            # ユーザーガイド
│   ├── dev/                             # 開発者ガイド
│   └── locale/ja/                       # 日本語翻訳
├── .steering/                           # ステアリングドキュメント (作業ごと)
│   ├── archive/                         # 30 日以上経過した完了作業
│   └── [YYYYMMDD]-[NNN]-[title]/
├── .claude/                             # Claude Code 設定
│   ├── commands/                        # スラッシュコマンド
│   ├── skills/                          # 状況発火型スキル
│   ├── agents/                          # サブエージェント定義
│   ├── rules/                           # 常時適用ルール
│   ├── hooks/                           # 自動実行 hook (check-secrets / check-disk-space / biome-format)
│   ├── settings.json                    # PreToolUse / PostToolUse hook 登録
│   ├── output-styles/
│   ├── statusline.sh
│   └── worktrees/                       # ビルトイン worktree 作成先
├── .github/                             # GitHub Actions / Templates
│   └── workflows/
├── tools/                               # リポジトリ共通の Node ツール
│   └── vitest.shared.mjs                # 全 package 共有の vitest config helper (steering 059)
├── CLAUDE.md                            # プロジェクト指示書（本構造を @import）
├── AGENTS.md                            # Claude Code 以外のエージェント参照集約
├── CONTRIBUTING.md                      # コントリビュータ向けガイド
├── CODE_OF_CONDUCT.md                   # 行動規範
├── SECURITY.md                          # セキュリティポリシー / 脆弱性報告先
├── LICENSE                              # MIT
├── README.md
├── pnpm-workspace.yaml
├── package.json
├── pnpm-lock.yaml                       # pnpm lockfile（commit 対象）
├── Cargo.toml                           # ルート Cargo workspace（examples の Rust 側を束ねる）
├── biome.json                           # Biome (手書き JS / JSON の format + lint)
└── .gitignore
```

---

## 2. `packages/` — 公開パッケージ

### 2.1 `packages/core/`

`@rescript-tauri/core`。中心パッケージ。`@tauri-apps/api` v2.11.0 の **stable public 表面の 100%** をカバー（`Image.transformImage` のみ upstream の "API not stable" 明記により意図的に除外。steering 049, 2026-05-09）。

```
packages/core/
├── src/
│   ├── Common.res / .resi               # 横断型 (unlisten / color / dragDropEvent) と共有 decoder。Window / Webview / WebviewWindow / Event から参照
│   ├── Core.res / .resi                 # invoke / convertFileSrc / Channel / Command / Resource / PluginListener / addPluginListener / permissions / isTauri / LowLevel
│   ├── Event.res / .resi                # listen / once / emit / emitTo / TauriEvent enum / ~target option
│   ├── Window.res / .resi               # Window クラスバインディング (~90 メソッド)
│   ├── Webview.res / .resi              # Webview クラスバインディング (getByLabel / clearAllBrowsingData 含む)
│   ├── WebviewWindow.res / .resi
│   ├── Path.res / .resi
│   ├── App.res / .resi                  # BundleType / DataStore / onBackButtonPress / supportsMultipleWindows 含む完全カバー
│   ├── Dpi.res / .resi
│   ├── Menu.res / .resi                 # NativeIcon polymorphic variant 含む
│   ├── Tray.res / .resi
│   ├── Image.res / .resi
│   ├── Mocks.res / .resi                # mockConvertFileSrc / mockIPCOptions 含む
│   └── Tauri.res / .resi                # 上位 re-export
├── tests/
│   ├── (型レベルテスト, *.res)         # コンパイル成功 = pass
│   └── runtime/                         # vitest テスト
├── rescript.json
├── package.json
└── README.md
```

**ファイル命名規約:**
- 1 モジュール 1 ファイル（PascalCase）。
- すべての `.res` に対応する `.resi` を必須化（`.resi` が API 表面の正本）。
- テストファイルは対象モジュール名 + `_*.res`（例: `core_command.res`）。

### 2.2 `packages/plugin-*/`

各プラグインは独立 publish。

```
packages/plugin-fs/                      # 着手済み (steering 032, 2026-05-09)
├── src/
│   └── PluginFs.res / .resi             # 14 single-shot IO 関数 + 関連型
├── tests/
│   ├── plugin_fs_signature.res          # 型レベル網羅
│   └── runtime/plugin_fs.test.mjs       # vitest + Mocks 経由
├── rescript.json
├── package.json                         # @rescript-tauri/plugin-fs
├── vitest.config.mjs
└── README.md
```

各プラグインは対応する上流 `@tauri-apps/plugin-*` を `peerDependencies` に宣言する:

```json
"peerDependencies": {
  "@rescript-tauri/core": "^0.1.0",
  "@tauri-apps/plugin-fs": "^2.5.0",
  "rescript": ">=12.0.0",
  "@rescript/core": ">=1.6.0"
}
```

`plugin-fs` の `BaseDirectory` は `@rescript-tauri/core` の `Path.BaseDirectory.t` を peerDep 経由で再利用する（独自 enum を持たない）。

`FileHandle` クラス・`watch` 系・`readTextFileLines` 等の複雑 API は plugin-fs 後続 sub-steering に分離（steering 032 §Non-goals）。

```
packages/plugin-dialog/                  # 着手済み (steering 035, 2026-05-09)
├── src/
│   └── PluginDialog.res / .resi         # open / save / message / ask / confirm + 関連型
├── tests/
│   ├── plugin_dialog_signature.res      # 型レベル網羅
│   └── runtime/plugin_dialog.test.mjs   # vitest + Mocks 経由
├── rescript.json
├── package.json                         # @rescript-tauri/plugin-dialog
├── vitest.config.mjs
└── README.md
```

`peerDependencies`: `@rescript-tauri/core ^0.1.0`, `@tauri-apps/plugin-dialog ^2.7.0`, `rescript >=12.0.0`, `@rescript/core >=1.6.0`.

upstream `open(options)` の TypeScript 条件型戻り値を 4 関数（`openFile` / `openFiles` / `openDirectory` / `openDirectories`）に分割して静的化（steering 035 §3.1）。`MessageDialogButtonsYesNoCustom` 等のカスタム文言・examples・専用 CI は plugin-dialog 後続 sub-steering に分離。

```
packages/plugin-shell/                   # 着手済み (steering 051, 2026-05-09)
├── src/
│   └── PluginShell.res / .resi          # openPath / Command / Child / EventEmitter
├── tests/
│   ├── plugin_shell_signature.res       # 型レベル網羅 (21 _check_)
│   └── runtime/plugin_shell.test.mjs    # vitest + Mocks 経由 (8 cases)
├── rescript.json
├── package.json                         # @rescript-tauri/plugin-shell
├── vitest.config.mjs
├── CHANGELOG.md
└── README.md
```

`peerDependencies`: `@rescript-tauri/core ^0.1.0`, `@tauri-apps/plugin-shell ^2.3.0`, `rescript >=12.0.0`, `@rescript/core >=1.6.0`.

upstream `Command.create({encoding: 'raw'})` の TypeScript 条件型戻り値を `Command.create` / `Command.createRaw` / `Command.sidecar` / `Command.sidecarRaw` に分割して静的化（steering 051 §3.1）。トップレベル `open` は ReScript 予約語との衝突回避のため `openPath` にリネーム。`examples/plugin-shell-demo/` と sphinx-docs `user/plugin-shell.md` は後続 sub-steering に分離。

```
packages/plugin-notification/            # 着手済み (steering 054, 2026-05-09)
├── src/
│   └── PluginNotification.res / .resi   # 15 関数 + Schedule / Importance / Visibility モジュール + 8 records + notificationPermission
├── tests/
│   ├── plugin_notification_signature.res # 型レベル網羅 (38 _check_)
│   └── runtime/plugin_notification.test.mjs # vitest + Mocks + window.Notification stub (19 cases)
├── rescript.json
├── package.json                         # @rescript-tauri/plugin-notification
├── vitest.config.mjs
├── CHANGELOG.md
└── README.md
```

`peerDependencies`: `@rescript-tauri/core ^0.1.0`, `@tauri-apps/plugin-notification ^2.3.0`, `rescript >=12.0.0`, `@rescript/core >=1.6.0`.

upstream の `sendNotification(options: Options | string)` overload を `sendNotification` / `sendNotificationText` の 2 関数に分割して静的化（steering 054 §3.1）。`Importance` / `Visibility` は `@unboxed` variant (`@as(N)`) として公開し、runtime 表現は bare integer で upstream 数値 enum と wire-compatible (steering 20260511-020)。`requestPermission` / `sendNotification` / `sendNotificationText` は upstream で IPC ではなく `window.Notification` Web API 経由で動作するため、テストでは `globalThis.window.Notification` を stub する。sphinx-docs `user/plugin-notification.md` は steering 20260511-002 で、`examples/plugin-notification-demo/` は steering 20260511-016 で追加済み。

```
packages/plugin-log/                     # 着手済み (steering 055, 2026-05-09)
├── src/
│   └── PluginLog.res / .resi            # 5 log fn + attachLogger + attachConsole + LogLevel + types
├── tests/
│   ├── plugin_log_signature.res         # 型レベル網羅 (16 _check_)
│   └── runtime/plugin_log.test.mjs      # vitest + Mocks 経由 (9 cases)
├── rescript.json
├── package.json                         # @rescript-tauri/plugin-log
├── vitest.config.mjs
├── CHANGELOG.md
└── README.md
```

`peerDependencies`: `@rescript-tauri/core ^0.1.0`, `@tauri-apps/plugin-log ^2.0.0`, `rescript >=12.0.0`, `@rescript/core >=1.6.0`.

`LogLevel.t` は `@unboxed` variant (`Trace=@as(1)` / `Debug=@as(2)` / `Info=@as(3)` / `Warn=@as(4)` / `Error=@as(5)`) として公開し、runtime 表現は bare integer で upstream 数値 enum と wire-compatible (steering 20260511-020)。トップレベル log 関数 (`error` / `warn` / `info` / `debug` / `trace`) は名前衝突なし。`attachLogger` / `attachConsole` は Tauri Event (`log://log`) 経由で動作するため、テストでは `__TAURI_INTERNALS__` の `transformCallback` / `invoke` を stub する。`examples/plugin-log-demo/` と sphinx-docs `user/plugin-log.md` は後続 sub-steering に分離。

```
packages/plugin-os/                      # 着手済み (steering 056, 2026-05-09)
├── src/
│   └── PluginOs.res / .resi             # 8 関数 + OsType submodule (eol/platform/version/family/OsType.get/arch/exeExtension/locale/hostname) + 4 polymorphic variants
├── tests/
│   ├── plugin_os_signature.res          # 型レベル網羅 (19 _check_)
│   └── runtime/plugin_os.test.mjs       # vitest + globals stub + Mocks (10 cases)
├── rescript.json
├── package.json                         # @rescript-tauri/plugin-os
├── vitest.config.mjs
├── CHANGELOG.md
└── README.md
```

`peerDependencies`: `@rescript-tauri/core ^0.1.0`, `@tauri-apps/plugin-os ^2.0.0`, `rescript >=12.0.0`, `@rescript/core >=1.6.0`.

upstream の `type()` は ReScript の予約語 `type` と衝突するため `OsType.get()` サブモジュールで公開 (steering 20260511-020)。7 つの sync getter (`eol` / `platform` / `version` / `family` / `OsType.get` / `arch` / `exeExtension`) は upstream で `window.__TAURI_OS_PLUGIN_INTERNALS__` を直接読み取るため、テストではこの globals を stub する。残り 2 つ (`locale` / `hostname`) は IPC (`plugin:os|locale` / `plugin:os|hostname`) 経由で `Mocks.mockIPC` で検証可能。sphinx-docs `user/plugin-os.md` は steering 20260511-004 で、`examples/plugin-os-demo/` は steering 20260511-017 で追加済み。

```
packages/plugin-clipboard-manager/       # 着手済み (steering 057, 2026-05-09)
├── src/
│   └── PluginClipboardManager.res / .resi # 6 関数 (writeText/readText/writeImage/readImage/writeHtml/clear) + writeTextOptions
├── tests/
│   ├── plugin_clipboard_manager_signature.res # 型レベル網羅 (8 _check_)
│   └── runtime/plugin_clipboard_manager.test.mjs # vitest + Mocks (7 cases)
├── rescript.json
├── package.json                         # @rescript-tauri/plugin-clipboard-manager
├── vitest.config.mjs
├── CHANGELOG.md
└── README.md
```

`peerDependencies`: `@rescript-tauri/core ^0.1.0`, `@tauri-apps/plugin-clipboard-manager ^2.0.0`, `rescript >=12.0.0`, `@rescript/core >=1.6.0`.

`readImage` は `RescriptTauriCore.Image.t` を返す（peerDep 経由で core モジュールを再利用、独自 type を持たない）。`writeImage` は upstream union (`string | Image | Uint8Array | ArrayBuffer | number[]`) を polymorphic `'image` で受ける。`examples/plugin-clipboard-manager-demo/` と sphinx-docs `user/plugin-clipboard-manager.md` は後続 sub-steering に分離。

```
packages/plugin-http/                    # 着手済み (steering 058, 2026-05-09)
├── src/
│   └── PluginHttp.res / .resi           # fetch + 5 records (basicAuth/proxyConfig/proxy/dangerousSettings/clientOptions)
├── tests/
│   ├── plugin_http_signature.res        # 型レベル網羅 (8 _check_)
│   └── runtime/plugin_http.test.mjs     # vitest + __TAURI_INTERNALS__ stub (3 cases)
├── rescript.json
├── package.json                         # @rescript-tauri/plugin-http
├── vitest.config.mjs
├── CHANGELOG.md
└── README.md
```

`peerDependencies`: `@rescript-tauri/core ^0.1.0`, `@tauri-apps/plugin-http ^2.0.0`, `rescript >=12.0.0`, `@rescript/core >=1.6.0`.

upstream `fetch(input, init)` は Web Fetch API のラッパー。`input` (`string | URL | Request`) / `init` (`RequestInit & ClientOptions`) / 戻り値 `Response` は DOM 型のため、ReScript 側では polymorphic `'input` / `'init` / `'response` で受け流し、呼び出し側で型注釈を付ける運用とする。Tauri 固有の設定 (`proxy` / `clientOptions` / `proxyConfig` / `dangerousSettings` / `basicAuth`) は明示的な record 型として公開。`proxy<'proxyValue>` と `clientOptions<'proxyValue>` は upstream の `string | ProxyConfig` union を polymorphic `'proxyValue` で表現。sphinx-docs `user/plugin-http.md` は steering 20260511-007 で、`examples/plugin-http-demo/` は steering 20260511-009 で追加済み。完全な Web Fetch API 型バインディングは後続 sub-steering に分離。

### 2.3 `packages/schema/`

着手済み (steering 031, 2026-05-09)。`rescript-schema` 向けの Layer 3 IPC ヘルパを提供する独立パッケージ:

```
packages/schema/
├── src/
│   └── Schema.res / .resi              # toDecoder / fromSchemas / channelFromSchema / eventFromSchema
├── tests/
│   ├── schema_signature.res            # 型レベル網羅
│   └── runtime/schema.test.mjs         # vitest + Mocks 経由
├── rescript.json
├── package.json                        # @rescript-tauri/schema
├── vitest.config.mjs
└── README.md
```

`peerDependencies`: `@rescript-tauri/core ^0.1.0`, `rescript-schema ^9.0.0`, `rescript >=12.0.0`, `@rescript/core >=1.6.0`.

`rescript-struct` は upstream で deprecated 済み (2026-05-09 確認) のため対象外（RFC-0002 §2.1）。

---

## 3. `examples/` — 使用例（CI ゲート対象）

各例題は **Linux / macOS / Windows** で CI ビルドされ、1 つでも失敗するとリリース不可（PRD §5.4）。

```
examples/hello-world/                     # 最小構成。invoke + Window
examples/window-management/               # Window / WebviewWindow 操作
examples/ipc-typed/                       # Command.make の典型例
examples/streaming-ipc/                   # Channel デモ
examples/plugin-dialog-demo/              # @rescript-tauri/plugin-dialog 全関数デモ (steering 036)
examples/plugin-fs-demo/                  # @rescript-tauri/plugin-fs 全関数デモ (steering 037)
examples/plugin-shell-demo/               # @rescript-tauri/plugin-shell 全関数デモ (steering 20260511-008)
examples/plugin-http-demo/                # @rescript-tauri/plugin-http 4 step デモ (steering 20260511-009)
examples/plugin-clipboard-manager-demo/   # @rescript-tauri/plugin-clipboard-manager 全関数デモ (steering 20260511-014)
examples/plugin-log-demo/                 # @rescript-tauri/plugin-log 全関数デモ (steering 20260511-015)
examples/plugin-notification-demo/        # @rescript-tauri/plugin-notification 全関数デモ (steering 20260511-016)
examples/plugin-os-demo/                  # @rescript-tauri/plugin-os 全関数デモ (steering 20260511-017)
examples/ipc-typed-with-schema/           # @rescript-tauri/schema (Layer 3) デモ — ipc-typed の対比版 (steering 039)
```

各 `examples/*/` には:
- `src-tauri/`（Rust 側 Tauri バックエンド）
- `src/`（ReScript フロント）
- `package.json` / `rescript.json` / `README.md`

`README.md` は「何を示す例か」「どう動かすか」を記載する。

---

## 4. `docs/` — 内部ドキュメント

開発チーム・コントリビュータ向けの設計・要件ドキュメント。エンドユーザー向けは `sphinx-docs/`（後述）。

| ファイル | 役割 | 更新頻度 |
|---|---|---|
| `product-requirements.md` | プロダクト要求定義書 (PRD) | 大型機能追加時 |
| `functional-design.md` | 機能設計書（モジュール別） | PRD 変更時に同期 |
| `architecture.md` | アーキテクチャ・技術仕様書 | 大型構造変更時 |
| `repository-structure.md` | 本書。CLAUDE.md から @import される | 構造変更ごと |
| `glossary.md` | ユビキタス言語定義 | 新概念導入時 |
| `development-guidelines.md` | 開発ガイドライン | プロセス変更時 |
| `mcp-servers.md` | MCP サーバー設定ガイド | MCP 導入時 |

### 4.1 `docs/ideas/`

ドラフト・RFC を集約するサブディレクトリ。**入力として扱い、確定後は PRD / functional-design / architecture に反映**して以後改編しない。

| ファイル | 役割 |
|---|---|
| `RFC-0001-core-api-design.md` | コア API 設計提案（PRD の一次入力） |

新規 RFC は `RFC-NNNN-<title>.md` 形式。

---

## 5. `sphinx-docs/` — 外部公開ドキュメント

Sphinx + Furo テーマで構築し GitHub Pages にホスティング。

```
sphinx-docs/
├── index.md                             # トップページ
├── user/                                # エンドユーザー向け
│   ├── index.md
│   ├── installation.md
│   ├── quickstart.md
│   ├── configuration.md
│   ├── plugin-fs.md                     # @rescript-tauri/plugin-fs ガイド
│   ├── plugin-dialog.md                 # @rescript-tauri/plugin-dialog ガイド
│   ├── schema.md                        # @rescript-tauri/schema (Layer 3) ガイド
│   └── changelog.md
├── dev/                                 # コントリビュータ向け
│   ├── index.md
│   ├── setup.md
│   ├── building.md
│   ├── architecture.md                  # 簡易版（docs/architecture.md の抜粋）
│   ├── project-structure.md             # 簡易版（本書の抜粋）
│   └── contributing.md
├── locale/ja/                           # 日本語翻訳 (.po)
├── tests/                               # ドキュメントの自動テスト（OGP / ReScript Pygments lexer 等）
├── _ext/                                # プロジェクト内 Sphinx 拡張 (rescript_lexer 等, steering 20260511-021)
├── _static/
├── _templates/
├── conf.py
├── pyproject.toml                       # Sphinx ビルド用 Python 依存（uv 管理）
└── Makefile
```

**`docs/` との役割分担:**
- `docs/` は開発チーム向け（PRD・設計）
- `sphinx-docs/` はエンドユーザー・コントリビュータ向け（使い方・チュートリアル）

詳細は `.claude/rules/documentation.md` を参照。

---

## 6. `.steering/` — ステアリングドキュメント

中規模以上のコード変更時に `[YYYYMMDD]-[NNN]-[開発タイトル]/` ディレクトリを作成し、`requirements.md` / `design.md` / `tasklist.md` を配置する。実装は **必ず Claude Code のビルトイン worktree 機能** で隔離して行う（`.claude/rules/steering-workflow.md`）。

```
.steering/
├── 20260508-001-core-command-impl/
│   ├── requirements.md
│   ├── design.md
│   └── tasklist.md
├── 20260601-002-event-listen-impl/
└── archive/                             # 最終コミット日 30 日以上経過したもの
```

`docs/ideas/` とは別物（`ideas/` は将来構想、`.steering/` は確定作業）。

---

## 7. `.claude/` — Claude Code 設定

| ディレクトリ | 役割 |
|---|---|
| `commands/` | `/setup-project` 等のスラッシュコマンド定義 |
| `skills/` | 状況発火型スキル本体（`SKILL.md` + 補助ファイル） |
| `agents/` | code-reviewer / debugger 等のサブエージェント定義 |
| `rules/` | CLAUDE.md から @import される常時適用ルール |
| `hooks/` | 自動実行される shell hook（`check-secrets.sh` / `check-disk-space.sh` / `biome-format.sh`） |
| `settings.json` | Claude Code lifecycle hook 登録（PreToolUse / PostToolUse） |
| `output-styles/` | 出力スタイル設定 |
| `statusline.sh` | ステータスライン表示スクリプト |
| `worktrees/` | ビルトイン worktree 作成先（一時的） |

各 rule / skill / agent / command の追加判断基準は `README.md` 「規約とスキルの住み分け」セクション参照。

---

## 8. `.github/` — CI / Templates

```
.github/
├── workflows/                                    # GitHub Actions ジョブ
│   ├── _test-package-runtime.yml                 # 再利用 workflow (workflow_call) — vitest 実行
│   ├── _test-package-types.yml                   # 再利用 workflow (workflow_call) — rescript build + public-symbol 網羅検証
│   ├── build-core.yml                            # PR / push トリガ — core ビルド検証
│   ├── tests-core-types.yml
│   ├── tests-core-runtime.yml
│   ├── tests-plugin-fs-types.yml
│   ├── tests-plugin-fs-runtime.yml
│   ├── tests-plugin-dialog-types.yml
│   ├── tests-plugin-dialog-runtime.yml
│   ├── tests-plugin-shell-types.yml
│   ├── tests-plugin-shell-runtime.yml
│   ├── tests-plugin-notification-types.yml
│   ├── tests-plugin-notification-runtime.yml
│   ├── tests-plugin-log-types.yml
│   ├── tests-plugin-log-runtime.yml
│   ├── tests-plugin-os-types.yml
│   ├── tests-plugin-os-runtime.yml
│   ├── tests-plugin-clipboard-manager-types.yml
│   ├── tests-plugin-clipboard-manager-runtime.yml
│   ├── tests-plugin-http-types.yml
│   ├── tests-plugin-http-runtime.yml
│   ├── tests-schema-types.yml
│   ├── tests-schema-runtime.yml
│   ├── tests-coverage.yml                        # 10 パッケージ matrix で vitest v8 カバレッジ計測（観測フェーズ）
│   ├── examples-build.yml                        # 3 OS マトリクス
│   ├── lint-format.yml                           # Biome (手書き JS / JSON の format + lint)
│   ├── doc-link-lint.yml                         # docs / README 内リンク検証
│   ├── docs.yml                                  # sphinx-docs ビルド + GitHub Pages デプロイ
│   ├── compat-tauri-latest.yml                   # nightly — 上流 Tauri 最新リリース追従
│   ├── compat-rescript-prerelease.yml            # nightly — ReScript 12.x 次期マイナー / 次期メジャー prerelease 検証
│   └── release.yml                               # tag push — npm publish + changelog
├── ISSUE_TEMPLATE/
├── PULL_REQUEST_TEMPLATE.md
├── auto-pr-description.yml.template              # オプトイン: PR description 自動生成（未有効化）
└── claude-code-review.yml.template               # オプトイン: Claude Code レビュー自動投稿（未有効化）
```

`_` プレフィックスのファイルは `workflow_call` 経由で他 workflow から呼ばれる再利用 workflow。新 plugin 追加時は `tests-<name>-runtime.yml` / `tests-<name>-types.yml` の 2 つを `tests-plugin-fs-*` 等を雛形にして `package-name` / `package-path` / `paths` を書き換えるだけで済む。`.template` 拡張子のファイルは opt-in 用テンプレートで、本リポジトリでは現状未有効化。

CI ジョブ定義の詳細は `docs/functional-design.md` §6 を参照。

---

## 9. ルート設定ファイル

| ファイル | 役割 |
|---|---|
| `CLAUDE.md` | Claude Code への強制指示。`@docs/repository-structure.md` を含む @import チェーンの起点 |
| `AGENTS.md` | Claude Code 以外のエージェント（Cursor / Copilot 等）が参照する集約ファイル |
| `CONTRIBUTING.md` | コントリビュータ向けガイド（PR 出し方 / テスト / レビュー観点） |
| `CODE_OF_CONDUCT.md` | 行動規範（Contributor Covenant ベース） |
| `SECURITY.md` | セキュリティポリシー / 脆弱性報告先 |
| `LICENSE` | MIT ライセンス全文 |
| `README.md` | プロジェクト全体の overview / インストール / 互換マトリクス |
| `pnpm-workspace.yaml` | `packages/*`, `examples/*` を workspace として宣言 |
| `package.json` | ルート package（`devDependencies`、共通スクリプト） |
| `pnpm-lock.yaml` | pnpm lockfile（commit 対象） |
| `Cargo.toml` | ルート Cargo workspace（examples の `src-tauri/` 群を束ねる） |
| `biome.json` | 手書き JS / JSON の format + lint 設定（ReScript 生成物 `*.res.mjs` / `lib/` は除外） |
| `.gitignore` | `node_modules/`, `.mcp.json`, `CLAUDE.local.md`, `.steering/archive/.*` 等 |

---

## 10. `tools/` — リポジトリ共通の Node ツール

`packages/*` から共有して読み込む素の Node スクリプト置き場。パッケージ化はせず、各 package の設定ファイル (`../../tools/...`) または `tests/runtime/*.test.mjs` (`../../../../tools/...`) から相対 import で利用する。

| ファイル | 役割 |
|---|---|
| `vitest.shared.mjs` | 全 package の `vitest.config.mjs` から呼び出す `definePackageConfig({thresholds?})` helper。`happy-dom` / `tests/runtime/**` / v8 coverage 等のボイラープレートを一元化する (steering 059, 2026-05-09) |
| `tauri-mocks.mjs` | `tests/runtime/*.test.mjs` 用の Tauri グローバル stub helper (`installTauriInternals` / `installEventPluginInternals` / `installOsPluginInternals` / `installNotificationStub`)。各 helper は cleanup 関数を返す。`__TAURI_INTERNALS__` / `__TAURI_OS_PLUGIN_INTERNALS__` / `window.Notification` の inline 重複を一元化する (steering 20260511-018, 2026-05-11) |

新ヘルパ追加時は: (1) 純粋な default export または factory 関数を提供し、副作用を持たないこと; (2) `node --check` で構文確認できること; (3) 本書のテーブルに 1 行追記すること。

---

## 11. 構造変更時のルール

新規ディレクトリ・パッケージ・モジュールを追加する際は:

1. 本書（`docs/repository-structure.md`）を更新する。
2. CLAUDE.md からの @import チェーンが壊れていないことを確認する。
3. `docs/functional-design.md` §1.1 と整合させる。
4. CI ジョブ（`.github/workflows/`）の対象パスに新規 directory を含めるか判断する。
5. 影響範囲が大きい場合（パッケージ新設等）は `.steering/` で正式に提案する。
