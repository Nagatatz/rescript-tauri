# rescript-tauri

Production-ready ReScript bindings for Tauri 2.x's official JS SDK (`@tauri-apps/api`). `@rescript-tauri/core` を中心に、IPC・Event・Window・Webview・Menu・Tray など Tauri 公開 API すべてを ReScript からアクセス可能にするモノレポです。

> **Status:** Phase 1 — 設計完了 / 実装未着手。本リポジトリは PRD・機能設計・アーキテクチャ・リポジトリ構造・用語集を整備した bootstrap 状態です。コードは未だ含まれていません。`docs/product-requirements.md` と `docs/functional-design.md` を参照してください。

---

## ✨ ハイライト

- **Idiomatic ReScript** — `variant` / `option` / `result` / polymorphic variant を活用し、TypeScript で `unknown` や string-literal union に頼っていた箇所を型安全に翻訳する。
- **Faithful to Tauri** — JS API 表面と 1:1 に近い構造を保ち、Tauri 公式ドキュメントがそのまま読み替え可能。`.resi` の doc comment に Tauri 公式 URL を必ず併記する。
- **3-layer IPC** — Layer 1 (Raw `invoke`) / Layer 2 (typed `Command`) / Layer 3 (Schema 統合) を提供し、ユーザーが安全性とエルゴノミクスのトレードオフを選べる。
- **Maintainable monorepo** — `@tauri-apps/plugin-*` の構造をミラーし、コア・プラグイン・例題を独立 semver で進化させる。1〜3 名のメンテナで長期維持できる構造を目指す。

詳細は [`docs/product-requirements.md`](./docs/product-requirements.md) を参照。

---

## 📦 パッケージ構成

| パッケージ | 役割 | フェーズ |
|---|---|---|
| `@rescript-tauri/core` | `@tauri-apps/api` 全公開 API のコアバインディング | Phase 1 |
| `@rescript-tauri/plugin-fs` | `@tauri-apps/plugin-fs` バインディング | Phase 2+ |
| `@rescript-tauri/plugin-dialog` | `@tauri-apps/plugin-dialog` バインディング | Phase 2+ |
| `@rescript-tauri/schema` | `rescript-schema` / `rescript-struct` 連携の `Command.fromSchemas` ヘルパ | Phase 2 |

各パッケージは独立 semver で publish され、対応する上流 `@tauri-apps/*` を `peerDependencies` に宣言します。

---

## 🧩 互換マトリクス

| 要素 | サポート範囲 |
|---|---|
| Tauri | 2.x（`@tauri-apps/api` の peerDep 範囲）|
| ReScript | >= 11.0.0（uncurried 化済み）|
| Node.js | >= 18 (LTS) |
| OS | Linux / macOS / Windows（Tauri 2.x desktop 対象）|

CI では nightly で「Tauri 最新」「ReScript prerelease」に対する互換性チェックを実施し、API drift を早期検知する方針です（→ [`docs/functional-design.md`](./docs/functional-design.md) §6）。

---

## 🚀 インストール (Phase 1 リリース後の予定)

```bash
# Phase 1 リリース後に有効
pnpm add @rescript-tauri/core
# peerDependencies として @tauri-apps/api を別途インストール
pnpm add @tauri-apps/api
```

`rescript.json` の `bs-dependencies` に `@rescript-tauri/core` を追加してください。

---

## ⚡ クイックスタート (設計上の最終形)

```rescript
// Layer 1: Raw invoke
let greeting = await Core.Raw.invoke("greet", ~args={"name": "ReScript"})

// Layer 2: typed Command
let greet = Core.Command.make1(~name="greet", ~argName="name", ~argType=String, ~returnType=String)
let greeting = await greet("ReScript")

// Window 操作
let win = Window.getCurrent()
await win->Window.setTitle("Hello from ReScript")

// Event 購読
let unlisten = await Event.listen("file-changed", payload => {
  Console.log(payload.payload)
})
```

実行可能な使用例は `examples/` 配下に Phase 1 で整備されます（`hello-world` / `window-management` / `ipc-typed` / `streaming-ipc`）。

---

## 🛠️ 開発セットアップ

```bash
# 依存関係インストール（pnpm 必須）
pnpm install

# 全 workspace ビルド
pnpm --recursive build

# クリーンビルド
pnpm --recursive run clean && pnpm --recursive build

# テスト（型レベル + vitest）
pnpm --recursive test

# core パッケージのみインクリメンタルビルド
pnpm --filter @rescript-tauri/core build
```

詳細な開発手順は [`docs/development-guidelines.md`](./docs/development-guidelines.md)（Phase 1 で整備予定）を参照。

---

## 📁 リポジトリ構造

トップレベル構成の概要のみ示します。**正本は [`docs/repository-structure.md`](./docs/repository-structure.md)** で、新規ディレクトリ追加時は必ず同書を更新してください。

```
rescript-tauri/
├── packages/         # @rescript-tauri/core, plugin-*, schema
├── examples/         # hello-world / window-management / ipc-typed / streaming-ipc
├── docs/             # 内部ドキュメント (PRD, 機能設計, アーキテクチャ, etc.)
│   └── ideas/        # ドラフト・RFC 集約
├── sphinx-docs/      # 外部公開ドキュメント (GitHub Pages)
├── .steering/        # ステアリングドキュメント (作業ごと)
├── .claude/          # Claude Code 設定 (rules / skills / agents / commands)
├── .github/          # GitHub Actions / Templates
├── CLAUDE.md         # Claude Code への強制指示
└── README.md         # 本ファイル
```

---

## 📚 ドキュメント一覧

| ドキュメント | 内容 |
|---|---|
| [`docs/product-requirements.md`](./docs/product-requirements.md) | プロダクト要求定義書 (PRD) — ペルソナ・ユーザーストーリー・KPI |
| [`docs/functional-design.md`](./docs/functional-design.md) | 機能設計書 — モジュール別 API・型の詳細 |
| [`docs/architecture.md`](./docs/architecture.md) | アーキテクチャ・技術仕様書 — 設計原則・3 層 IPC・横断ポリシー |
| [`docs/repository-structure.md`](./docs/repository-structure.md) | リポジトリ構造定義書 — ディレクトリ・ファイルの正本 |
| [`docs/glossary.md`](./docs/glossary.md) | ユビキタス言語定義 |
| [`docs/ideas/RFC-0001-core-api-design.md`](./docs/ideas/RFC-0001-core-api-design.md) | コア API 設計 RFC（PRD の一次入力、改編しない歴史的入力） |
| [`CLAUDE.md`](./CLAUDE.md) | Claude Code への強制指示（プロジェクト全体の規約集約点）|

外部公開ドキュメント（ユーザーガイド・開発者ガイド）は `sphinx-docs/` に整備されます（Phase 1 リリース時に GitHub Pages で公開予定）。

---

## 🤖 規約とスキルの住み分け

本リポジトリは Claude Code を活用した開発を前提に、`.claude/` 配下に 4 種類の設定を配置しています。それぞれの役割は次の通りです。

| 種別 | 配置 | 役割 | 起動方法 |
|---|---|---|---|
| **rules** | `.claude/rules/` | 常時適用される規約。`CLAUDE.md` から `@import` され、すべてのセッションで強制される。 | 常時適用（手動起動不要）|
| **skills** | `.claude/skills/` | 状況発火型の知識・手順。該当状況になると Claude が自動でロードする。`/skill-name` で明示起動も可。 | 状況自動 / `/<name>` 明示 |
| **agents** | `.claude/agents/` | 専門サブエージェント定義（code-reviewer / debugger / build-resolver / security-reviewer 等）。Agent ツールで起動。 | Agent ツール |
| **commands** | `.claude/commands/` | スラッシュコマンド定義（`/setup-project` / `/add-feature` 等）。 | `/<command>` |

### 追加判断基準

新しい知識やワークフローを追加するときは、次の優先順位で配置先を決定してください:

1. **すべてのセッションで例外なく強制したい規約** → `rules/`（`CLAUDE.md` に `@import` を追加）
2. **特定の状況・キーワードで自動発火させたい手順** → `skills/`
3. **独立した役割を持つ専門サブエージェントとして切り出したい** → `agents/`
4. **明示的なエントリーポイント（`/xxx`）として呼び出したい** → `commands/`

`rules` と `skills` は混同しやすいですが、「常に適用」が `rules`、「状況になったら適用」が `skills` です。どちらにすべきか判断に迷う場合は `skills/` から始め、適用範囲が広がれば `rules/` に昇格させてください。

### 主要な常時適用ルール

| ルール | 内容 |
|---|---|
| [`rules/testing.md`](./.claude/rules/testing.md) | テスト作成必須、自己検証フロー |
| [`rules/code-comments.md`](./.claude/rules/code-comments.md) | doc comment / インラインコメント規約 |
| [`rules/git-conventions.md`](./.claude/rules/git-conventions.md) | 絵文字プレフィックス・コミット粒度・ブランチ命名 |
| [`rules/steering-workflow.md`](./.claude/rules/steering-workflow.md) | ステアリングドキュメント・worktree 運用 |
| [`rules/documentation.md`](./.claude/rules/documentation.md) | `docs/` / `sphinx-docs/` の役割分担 |
| [`rules/definition-of-done.md`](./.claude/rules/definition-of-done.md) | 完了定義（Phase 1〜5）の SSoT |
| [`rules/permission-modes.md`](./.claude/rules/permission-modes.md) | Plan Mode / steering / auto / sandbox の住み分け |

---

## 🤝 コントリビュート

Phase 1 リリースまでは設計フェーズのため、外部からの PR は受け付けていません。設計や RFC へのフィードバックは GitHub Issues にお寄せください。Phase 1 リリース後に `CONTRIBUTING.md` を整備します。

---

## 📜 ライセンス

TBD — Phase 1 リリース時に確定（MIT を想定）。
