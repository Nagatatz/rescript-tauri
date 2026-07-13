# 要求定義: Biome から oxlint / oxfmt への移行

| 項目 | 内容 |
|---|---|
| 機能名 | Biome から oxlint / oxfmt への移行 |
| 採番 | 20260713-001 |
| 作成日 | 2026-07-13 |
| ステータス | 計画中 |

## 1. 背景と目的

### 背景

手書き JavaScript (`.mjs`) と JSON の lint + format は現在 **Biome** (`@biomejs/biome ^2.5.3`) が一手に担っている。実体は以下の 5 箇所:

- `biome.json` — formatter / linter 設定（手書き `.mjs` / JSON 対象、`*.res.mjs` と `lib/` は除外）
- ルート `package.json` の 6 scripts（`format` / `format:check` / `lint` / `lint:fix` / `check` / `check:fix`）
- CI `.github/workflows/lint-format.yml`（`pnpm run check` + `git diff --exit-code`）
- PostToolUse hook `.claude/hooks/biome-format.sh`（Edit/Write 後に `.mjs` / `.json` / `.jsonc` を best-effort 自動整形）
- `.claude/settings.json` の PostToolUse hook 登録

oxc プロジェクトの **oxlint**（Rust 製 linter、npm 最新 **1.73.0** stable）と **oxfmt**（Rust 製 Prettier 互換 formatter、npm 最新 **0.58.0**）は Biome より高速で、oxfmt は Prettier の JS/TS conformance test を 100% pass する production-ready なフォーマッタ。これらへ移行する。

### 目的

Biome が担っている lint + format の責務を oxlint（lint）/ oxfmt（format）に置き換える。**対象ファイル種別・整形スタイル・CI ゲート・PostToolUse 自動整形といった現行の振る舞いは維持**し、ツールチェーンのみ差し替える。

## 2. 変更・追加する機能

| 観点 | 現行 (Biome) | 移行後 (oxc) |
|---|---|---|
| Lint | `biome lint`（recommended） | `oxlint`（`categories` で lint gate を構成） |
| Format | `biome format` | `oxfmt` |
| 設定ファイル | `biome.json` | `.oxlintrc.json`（lint）/ `.oxfmtrc.json`（format） |
| 対象 | 手書き `.mjs` / JSON | 同一（手書き `.mjs` / JSON のみ。oxfmt がデフォルトで対象にする md/yml/toml/css 等は **除外**） |
| 除外 | `*.res.mjs`, `lib/`, `node_modules`, `target`, `sphinx-docs`, `examples/*/src-tauri`, lockfile 等 | 同一の除外を再現 |
| 整形スタイル | semi なし / 100 幅 / ダブルクオート / trailingComma all / arrowParens always / 2-space / LF | **同一**（oxfmt の設定で再現） |
| npm scripts | 6 個 | 同名・同責務で oxlint/oxfmt 呼び出しに置換 |
| CI | `lint-format.yml`（job: biome） | 同 workflow を oxlint + oxfmt --check に置換 |
| PostToolUse hook | `biome-format.sh` | `oxfmt-format.sh`（oxfmt で `.mjs` / `.json` を自動整形） |
| devDependency | `@biomejs/biome` | `oxlint` + `oxfmt`（`@biomejs/biome` は削除） |

## 3. ユーザーストーリー

| # | ユーザー | 操作 | 期待する結果 |
|---|---|---|---|
| 1 | 開発者 | `pnpm run check` を実行 | oxlint + oxfmt --check が走り、lint / format 違反が報告される |
| 2 | 開発者 | `pnpm run check:fix` を実行 | oxlint --fix + oxfmt --write が走り、自動修正される |
| 3 | 開発者 | `.mjs` / `.json` を Edit/Write で編集 | PostToolUse hook が oxfmt で自動整形する |
| 4 | コントリビュータ | PR を出す | CI `lint-format` ジョブが oxlint/oxfmt で検証し、ゲートとして機能する |
| 5 | 開発者 | `.res` / `.resi` を編集 | 従来どおり ReScript コンパイラのフォーマッタが管理し、oxc は介入しない |

## 4. 受け入れ条件

- [ ] `biome.json` を削除し、`.oxlintrc.json` / `.oxfmtrc.json` を追加した
- [ ] `@biomejs/biome` を devDependencies から削除し、`oxlint` / `oxfmt` を追加した
- [ ] ルート `package.json` の 6 scripts が oxlint/oxfmt 呼び出しに置換され、同名・同責務を維持している
- [ ] oxfmt の整形スタイルが現行 Biome と一致している（semi なし / 100 幅 / ダブルクオート / trailingComma all / arrowParens always / 2-space / LF）
- [ ] oxfmt の整形対象が手書き `.mjs` / JSON のみに限定され、md / yml / toml / css 等を再整形しない（`oxfmt --list-different` の出力で検証）
- [ ] `*.res.mjs` / `lib/` / `sphinx-docs` / `examples/*/src-tauri` 等、Biome の除外が oxc 側でも再現されている
- [ ] `oxlint` のルールが安定した lint gate を構成し、既存の `.mjs` に対して green である
- [ ] `.github/workflows/lint-format.yml` が oxlint + oxfmt --check に置換され、CI が green になる
- [ ] `biome-format.sh` → `oxfmt-format.sh` にリネーム・書き換えし、`settings.json` の登録を更新した
- [ ] Biome を言及する全ドキュメント（CLAUDE.md / README.md / CONTRIBUTING.md / docs/repository-structure.md / docs/development-guidelines.md / docs/functional-design.md）を oxlint/oxfmt に更新した
- [ ] `pnpm run check` がローカルで pass し、`git diff --exit-code` が clean である

## 5. Non-goals

- ReScript (`.res` / `.resi`) の整形は対象外（ReScript コンパイラが管理）。
- Rust (`src-tauri`) の整形・lint は対象外（従来どおり除外）。
- lint ルールの Biome ↔ oxlint 完全 1:1 再現は目標としない。安定した gate を優先し、既存コードが green になる範囲で `categories` を構成する。
- sphinx-docs / examples の Rust・Python は対象外。
