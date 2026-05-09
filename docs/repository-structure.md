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
│   ├── plugin-fs/                       # @rescript-tauri/plugin-fs (Phase 2+)
│   ├── plugin-dialog/                   # @rescript-tauri/plugin-dialog (Phase 2+)
│   ├── plugin-shell/                    # @rescript-tauri/plugin-shell (Phase 2+)
│   ├── plugin-notification/             # @rescript-tauri/plugin-notification (Phase 2+)
│   └── schema/                          # @rescript-tauri/schema (Phase 2)
├── examples/                            # ビルド可能な使用例（CI ゲート対象）
│   ├── hello-world/                     # Phase 1 必須
│   ├── window-management/
│   ├── ipc-typed/
│   ├── streaming-ipc/
│   ├── plugin-fs-demo/                  # Phase 2
│   ├── plugin-dialog-demo/              # Phase 2
│   └── ipc-typed-with-schema/           # Phase 2 (Layer 3 demo)
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
├── CLAUDE.md                            # プロジェクト指示書（本構造を @import）
├── README.md
├── pnpm-workspace.yaml
├── package.json
├── biome.json                          # Biome (手書き JS / JSON の format + lint)
└── .gitignore
```

---

## 2. `packages/` — 公開パッケージ

### 2.1 `packages/core/`

`@rescript-tauri/core`。Phase 1 の中心パッケージ。`@tauri-apps/api` v2.11.0 の **stable public 表面の 100%** をカバー（`Image.transformImage` のみ upstream の "API not stable" 明記により意図的に除外。steering 049, 2026-05-09）。

```
packages/core/
├── src/
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

Phase 2 着手済み。各プラグインは独立 publish。

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

upstream の `sendNotification(options: Options | string)` overload を `sendNotification` / `sendNotificationText` の 2 関数に分割して静的化（steering 054 §3.1）。`Importance` / `Visibility` の数値 enum は ReScript 側で `int` の named constants として公開し、`default_` / `private_` / `public_` は JS 出力の `$$default` / `$$private` / `$$public` エスケープを避けるため suffix 付き。`requestPermission` / `sendNotification` / `sendNotificationText` は upstream で IPC ではなく `window.Notification` Web API 経由で動作するため、テストでは `globalThis.window.Notification` を stub する。`examples/plugin-notification-demo/` と sphinx-docs `user/plugin-notification.md` は後続 sub-steering に分離。

### 2.3 `packages/schema/`

Phase 2 着手済み (steering 031, 2026-05-09)。`rescript-schema` 向けの Layer 3 IPC ヘルパを提供する独立パッケージ:

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
├── user/                                # エンドユーザー向け
│   ├── installation.md
│   ├── quickstart.md
│   ├── configuration.md
│   └── changelog.md
├── dev/                                 # コントリビュータ向け
│   ├── setup.md
│   ├── building.md
│   ├── architecture.md                  # 簡易版（docs/architecture.md の抜粋）
│   └── contributing.md
├── locale/ja/                           # 日本語翻訳 (.po)
├── conf.py
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
├── workflows/                           # GitHub Actions ジョブ
│   ├── build-core.yml                   # PR / push トリガ
│   ├── tests-core-types.yml
│   ├── tests-core-runtime.yml
│   ├── tests-coverage.yml               # 4 パッケージ matrix で vitest v8 カバレッジ計測（観測フェーズ）
│   ├── examples-build.yml               # 3 OS マトリクス
│   ├── doc-link-lint.yml
│   ├── compat-tauri-latest.yml          # nightly
│   ├── compat-rescript-prerelease.yml   # nightly (12.x 次期マイナー / 次期メジャー prerelease 検証)
│   └── release.yml                      # tag push
├── ISSUE_TEMPLATE/
└── PULL_REQUEST_TEMPLATE.md
```

CI ジョブ定義の詳細は `docs/functional-design.md` §6 を参照。

---

## 9. ルート設定ファイル

| ファイル | 役割 |
|---|---|
| `CLAUDE.md` | Claude Code への強制指示。`@docs/repository-structure.md` を含む @import チェーンの起点 |
| `README.md` | プロジェクト全体の overview / インストール / 互換マトリクス |
| `pnpm-workspace.yaml` | `packages/*`, `examples/*` を workspace として宣言 |
| `package.json` | ルート package（`devDependencies`、共通スクリプト） |
| `biome.json` | 手書き JS / JSON の format + lint 設定（ReScript 生成物 `*.res.mjs` / `lib/` は除外） |
| `.gitignore` | `node_modules/`, `.mcp.json`, `CLAUDE.local.md`, `.steering/archive/.*` 等 |

---

## 10. 構造変更時のルール

新規ディレクトリ・パッケージ・モジュールを追加する際は:

1. 本書（`docs/repository-structure.md`）を更新する。
2. CLAUDE.md からの @import チェーンが壊れていないことを確認する。
3. `docs/functional-design.md` §1.1 と整合させる。
4. CI ジョブ（`.github/workflows/`）の対象パスに新規 directory を含めるか判断する。
5. 影響範囲が大きい場合（パッケージ新設等）は `.steering/` で正式に提案する。
