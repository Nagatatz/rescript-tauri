# AGENTS.md

このファイルがプロジェクトで共有する指示の正本。詳しい手順や設計は作業に必要なものだけ読む。

## モデルと検証

- Claude Code は [v2.1.277 以降の直接読み込み](https://code.claude.com/docs/en/memory#use-agents-md) を使う。新規セッションの `/context all` でこのファイルを確認する。ローカルの `CLAUDE.local.md` や親ディレクトリの設定が優先される場合は、個別に Project instructions を確認する。Codex 等では下記の参照先を必要時に明示的に読む。
- 通常の実装・レビューは Opus 5.5 を第一候補とし、難しい設計判断・長期調査・Opus で解決できないデバッグのみ、利用可能なら Fable 5.2 を検討する。局所修正・機械的調査は安価なモデルまたはコマンドを使う。共有設定でモデル・権限を固定しない。
- モデルや自己レビューの結果を合格の根拠にしない。Issue の DoD と実行結果を照合し、失敗・未実行・実機の未確認を分けて記録する。

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

# 品質チェック（oxlint + oxfmt: 手書き .mjs / JSON の lint + format）
pnpm run check          # 検証のみ
pnpm run check:fix      # 自動修正
```

## プロジェクト構成

詳細は `docs/repository-structure.md`（必要時に参照）。

## 開発規約

- パッケージ: `@rescript-tauri/` スコープ（`core`, `plugin-fs`, `plugin-dialog`, `schema`, ...）。各パッケージは独立 semver。
- バインディング規約: 公開 API は必ず `.resi` でシグネチャを正本化し、Tauri 公式 URL リンク付き doc comment を必須とする（→ `code-comments.md`）。
- IPC 階層: Layer 1 (Raw) / Layer 2 (Command) / Layer 3 (Schema) の住み分けは `docs/functional-design.md` §1.2 を参照。

> `.claude/` 配下の rule / skill / agent / command の役割分担と新規追加判断基準は README.md「規約とスキルの住み分け」セクション参照。

### 常時適用される規約 (rules)

次の規約は該当作業に適用する。作業を始める前に関連する本文を確認する。

- `.claude/rules/testing.md`
- `.claude/rules/code-comments.md`
- `.claude/rules/git-conventions.md`
- `.claude/rules/issue-workflow.md`
- `.claude/rules/documentation.md`
- `.claude/rules/definition-of-done.md`
- `.claude/rules/permission-modes.md`
- `.claude/rules/pre-flight-verification.md`

### 状況発火型の知識 (skills)

以下は `.claude/skills/` に配置されており、該当状況になると Claude が自動でロードする。手動呼び出しは不要。

| スキル | 発火タイミング |
|------|--------------|
| **bash-safety** | 破壊的な Bash 操作（rm, rm -r, ディレクトリ削除等）を実行する直前 |
| **worktree-safety** | git worktree の作成・削除・整理時 / CWD 壊れの復旧時 |
| **context-management** | コンテキスト圧迫時 / 探索→実装の切替時 |
| **token-optimization** | サブエージェント / モデル選択時 |
| **parallel-implementation-swarm** | N >= 2 の独立実装（plugin / template 並列追加）/ Issue 単位の割り当て + coordinator + PR |
| **coverage-climber** | 「カバレッジを上げて」「coverage を N% まで」/ state file ベースの再開可能ループ |

## 作業の正本

計画・進捗は GitHub Issue の `## DoD` に記録し、PR とリンクする。新規の `.steering/` や `tasklist.md` は作成しない。過去資料は既存の参照のために保持する。

## プロジェクトの検証基準

- プロパティベースドテスト、ミューテーションテスト、形式仕様の機械検証を、いずれもプロジェクトの検証として持つ。既存コード全体への適用ではなく、影響の大きい境界・状態遷移を優先し、対象・コマンド・成果物・未対応範囲を Issue / PR に明記する。
- プロパティ試験は乱数 seed と反例を再現できる形で記録する。ミューテーションは対象を絞り、生存変異を確認する。形式手法は不変条件とモデルの仮定を明記し、実装との対応を回帰テストで別に確かめる。有限モデル検査を実装全体の証明と呼ばない。
- この方針があるだけでは導入済みとしない。未導入や実行できない場合はブロッカーと次の作業を Issue に残す。
