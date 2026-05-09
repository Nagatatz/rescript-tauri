# CLAUDE.md

## 強制的な行動指示

本ファイルおよび `@import` で読み込まれるルール、`.claude/skills/` 配下のスキル本文に書かれている規約は **すべて強制** であり、ユーザーから明示的に解除されない限り例外なく従うこと。違反した場合は即座に修正する。

## プロジェクト概要

Tauri 2.x 公式 JS SDK (`@tauri-apps/api`) に対する production-ready な ReScript バインディング群。`@rescript-tauri/core` を中心とするモノレポで、IPC・Event・Window・Webview・Menu・Tray など Tauri 公開 API すべてを ReScript からアクセス可能にする。詳細は `docs/product-requirements.md`。

- 言語: ReScript (>=12.0.0, uncurried-by-default) / JavaScript (生成物・テストツール)
- ビルドシステム: pnpm workspaces + ReScript compiler (`rescript build`)
- 対象プラットフォーム: Linux / macOS / Windows（Tauri 2.x desktop アプリのフロント側ライブラリ）

## ビルド・実行コマンド

```bash
# ビルド（全 workspace）
pnpm install && pnpm --recursive build

# クリーンビルド
pnpm --recursive run clean && pnpm --recursive build

# テスト（型レベル + vitest）
pnpm --recursive test

# core パッケージのみのインクリメンタルビルド
pnpm --filter @rescript-tauri/core build

# 品質チェック（Biome: 手書き .mjs / JSON の format + lint）
pnpm run check          # 検証のみ
pnpm run check:fix      # 自動修正
```

<!-- Sphinx ドキュメントを使う場合は以下を有効化:
## Sphinx ドキュメント

```bash
cd sphinx-docs && make install  # 依存関係インストール
make html                       # 英語 HTML ビルド
make build-all                  # 全言語ビルド + Pagefind
make serve                      # ローカルサーバーで確認
make check                      # 品質チェック (lint + test)
```
-->

## プロジェクト構成

@docs/repository-structure.md

## 開発規約

- パッケージ: `@rescript-tauri/` スコープ（`core`, `plugin-fs`, `plugin-dialog`, `schema`, ...）。各パッケージは独立 semver。
- バインディング規約: 公開 API は必ず `.resi` でシグネチャを正本化し、Tauri 公式 URL リンク付き doc comment を必須とする（→ `code-comments.md`）。
- IPC 階層: Layer 1 (Raw) / Layer 2 (Command) / Layer 3 (Schema) の住み分けは `docs/functional-design.md` §1.2 を参照。

> `.claude/` 配下の rule / skill / agent / command の役割分担と新規追加判断基準は README.md「規約とスキルの住み分け」セクション参照。

### 常時適用される規約 (rules)

以下のルールはすべてのセッションで `@import` され、常に適用される。

@.claude/rules/testing.md
@.claude/rules/code-comments.md
@.claude/rules/git-conventions.md
@.claude/rules/steering-workflow.md
@.claude/rules/documentation.md
@.claude/rules/definition-of-done.md
@.claude/rules/permission-modes.md
@.claude/rules/pre-flight-verification.md

<!--
  /learn skill が `.claude/rules/learnings.md` を生成したら、以下のコメントを外して有効化する。
  存在しないファイルを @import すると Claude Code が警告する可能性があるため、生成前は無効化しておく。

  @.claude/rules/learnings.md
-->


### 状況発火型の知識 (skills)

以下は `.claude/skills/` に配置されており、該当状況になると Claude が自動でロードする。手動呼び出しは不要。

| スキル | 発火タイミング |
|------|--------------|
| **bash-safety** | 破壊的な Bash 操作（rm, rm -r, ディレクトリ削除等）を実行する直前 |
| **worktree-safety** | git worktree の作成・削除・整理時 / CWD 壊れの復旧時 |
| **context-management** | コンテキスト圧迫時 / 探索→実装の切替時 |
| **token-optimization** | サブエージェント / モデル選択時 |
| **parallel-implementation-swarm** | N >= 2 の独立実装（plugin / template 並列追加）/ 番号予約 + coordinator + batch merge |
| **coverage-climber** | 「カバレッジを上げて」「coverage を N% まで」/ state file ベースの再開可能ループ |

## 個人ノート

`CLAUDE.local.md` を作成すると、git 追跡対象外の個人メモとして扱われる（`.gitignore` 済み）。チームに共有しない作業手順、個人 API キー操作メモ、デバッグ用一時情報などを記述してよい。`@CLAUDE.local.md` で CLAUDE.md から取り込むこともできる。
