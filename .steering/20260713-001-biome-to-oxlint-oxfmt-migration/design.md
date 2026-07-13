# 設計: Biome から oxlint / oxfmt への移行

| 項目 | 内容 |
|---|---|
| 機能名 | Biome から oxlint / oxfmt への移行 |
| 採番 | 20260713-001 |
| 作成日 | 2026-07-13 |
| 関連 | requirements.md |

## 1. 実装アプローチ

Biome の 5 実体（設定 / npm scripts / CI / PostToolUse hook / settings 登録）を、責務・対象範囲・整形スタイルを保ったまま oxlint + oxfmt に置換する。順序:

1. **依存差し替え**: `@biomejs/biome` を削除し `oxlint` / `oxfmt` を devDependency に追加。
2. **設定追加**: `.oxlintrc.json`（lint）/ `.oxfmtrc.json`（format、現行スタイル再現 + 対象を `.mjs`/JSON に限定）を作成し、`biome.json` を削除。
3. **scripts 置換**: ルート `package.json` の 6 scripts を oxlint/oxfmt 呼び出しに置換。
4. **整形・lint の適用と検証**: `pnpm run check:fix` を一度実行し、一度きりの再整形差分・新規 lint 指摘を解消して green にする。`oxfmt --list-different` で対象が `.mjs`/JSON のみであることを確認する。
5. **CI 置換**: `lint-format.yml` を oxlint + oxfmt --check に置換。
6. **hook 置換**: `biome-format.sh` → `oxfmt-format.sh` にリネーム・書き換え、`settings.json` の登録を更新。
7. **ドキュメント更新**: Biome 言及を oxlint/oxfmt に更新。
8. **検証**: ローカル `pnpm run check` pass + `git diff --exit-code` clean → PR → CI green。

### oxfmt の対象範囲限定（最重要リスク）

oxfmt はデフォルトで JS/JSX/TS/TSX/JSON/JSONC/JSON5/YAML/TOML/HTML/CSS/SCSS/Less/Markdown/MDX/GraphQL/Vue/Svelte 等を整形対象にする。Biome は **JS + JSON しか整形していなかった**ため、対象を手書き `.mjs` / JSON に限定する必要がある。方針:

- npm scripts では **明示 glob** `"**/*.mjs"` `"**/*.json"` を positional 引数で渡し、拡張子を JS/JSON に限定する。
- `.oxfmtrc.json` の `ignorePatterns` で Biome の除外を再現する（`**/*.res.mjs` / `**/lib/**` / `sphinx-docs/**` / `examples/*/src-tauri/**` / `**/target/**` / `**/pnpm-lock.yaml` / `**/Cargo.lock` / `**/.claude/worktrees/**`）。oxfmt は `.gitignore` をデフォルト参照するため `node_modules` 等は自動除外されるが、gitignore されない `*.res.mjs` / `sphinx-docs` の JSON 等は明示除外する。
- 実装時に `oxfmt --list-different "**/*.mjs" "**/*.json"` の出力を確認し、`.mjs` / `.json` 以外や除外対象が含まれていれば `ignorePatterns` を追加して限定が完全であることを検証する。

## 2. 変更するコンポーネント

| ファイル | 変更内容 | 変更種別 |
|---|---|---|
| `biome.json` | 削除 | 削除 |
| `.oxlintrc.json` | lint 設定（`categories` で gate、`ignorePatterns` で除外再現） | 新規 |
| `.oxfmtrc.json` | format 設定（現行スタイル再現、`ignorePatterns` で対象限定） | 新規 |
| `package.json` (root) | `@biomejs/biome` 削除 → `oxlint`/`oxfmt` 追加、6 scripts 置換 | 修正 |
| `pnpm-lock.yaml` | 依存差し替えを反映 | 修正 |
| 既存 `.mjs` / `.json` | oxfmt による一度きりの再整形 + oxlint 指摘修正（発生時） | 修正 |
| `.github/workflows/lint-format.yml` | job/step を oxlint + oxfmt --check に置換 | 修正 |
| `.claude/hooks/biome-format.sh` → `.claude/hooks/oxfmt-format.sh` | リネーム + oxfmt ベースに書き換え | 修正(リネーム) |
| `.claude/settings.json` | PostToolUse hook の command パスを更新 | 修正 |
| `CLAUDE.md` | 「品質チェック（Biome…）」記述を oxlint/oxfmt に更新 | 修正 |
| `README.md` | Biome 言及を更新 | 修正 |
| `CONTRIBUTING.md` | `lint-format (Biome…)` を更新 | 修正 |
| `docs/repository-structure.md` | hooks 一覧 / `biome.json` / `lint-format.yml` の記述を更新 | 修正 |
| `docs/development-guidelines.md` | 「手書き JS / JSON の format + lint（Biome）」セクション更新 | 修正 |
| `docs/functional-design.md` | §6 CI テーブルの `lint-format` 記述更新 | 修正 |

## 3. 設定ファイルの詳細

### 3.1 `.oxfmtrc.json`（整形スタイル対応表）

oxfmt のデフォルトは現行 Biome スタイルとほぼ一致し、**明示指定が必要なのは `semi: false` のみ**（他はデフォルトで一致）。可読性・意図明示のため主要キーは明示する。

| Biome (`biome.json`) | oxfmt (`.oxfmtrc.json`) | oxfmt default |
|---|---|---|
| `formatter.indentStyle: space` | `useTabs: false` | false ✓ |
| `formatter.indentWidth: 2` | `tabWidth: 2` | 2 ✓ |
| `formatter.lineWidth: 100` | `printWidth: 100` | 100 ✓ |
| `formatter.lineEnding: lf` | `endOfLine: "lf"` | "lf" ✓ |
| `javascript.formatter.quoteStyle: double` | `singleQuote: false` | false ✓ |
| `javascript.formatter.semicolons: asNeeded` | `semi: false` | **true ✗（要指定）** |
| `javascript.formatter.trailingCommas: all` | `trailingComma: "all"` | "all" ✓ |
| `javascript.formatter.arrowParentheses: always` | `arrowParens: "always"` | "always" ✓ |

JSON の `trailingCommas: none`（Biome）は oxfmt でも JSON に trailing comma を付けないため追加設定不要。

```json
{
  "printWidth": 100,
  "tabWidth": 2,
  "useTabs": false,
  "semi": false,
  "singleQuote": false,
  "trailingComma": "all",
  "arrowParens": "always",
  "endOfLine": "lf",
  "ignorePatterns": [
    "**/*.res.mjs",
    "**/lib/**",
    "**/target/**",
    "sphinx-docs/**",
    "examples/*/src-tauri/**",
    "**/pnpm-lock.yaml",
    "**/Cargo.lock",
    "**/.claude/worktrees/**"
  ]
}
```

> `ignorePatterns` の最終形は実装時に `oxfmt --list-different` の出力で検証・調整する。

### 3.2 `.oxlintrc.json`（lint 設定）

Biome の `linter.recommended: true` に対応する lint gate を oxlint の `categories` で構成する。oxlint は JS/TS のみ lint し JSON は対象外（Biome も JSON は lint していない）。安定運用のため既定の `correctness` を error とし、既存 `.mjs` が green になる範囲で `suspicious` を追加する。実装時に既存コードでの pass 状況を見て最終決定する。

```json
{
  "$schema": "./node_modules/oxlint/configuration_schema.json",
  "categories": {
    "correctness": "error",
    "suspicious": "warn"
  },
  "ignorePatterns": [
    "**/*.res.mjs",
    "**/lib/**",
    "**/target/**",
    "sphinx-docs/**",
    "examples/*/src-tauri/**"
  ]
}
```

### 3.3 `package.json` scripts 置換

| script | 現行 | 移行後 |
|---|---|---|
| `format` | `biome format --write .` | `oxfmt "**/*.mjs" "**/*.json"` |
| `format:check` | `biome format .` | `oxfmt --check "**/*.mjs" "**/*.json"` |
| `lint` | `biome lint .` | `oxlint` |
| `lint:fix` | `biome lint --write .` | `oxlint --fix` |
| `check` | `biome check .` | `oxlint && oxfmt --check "**/*.mjs" "**/*.json"` |
| `check:fix` | `biome check --write .` | `oxlint --fix && oxfmt "**/*.mjs" "**/*.json"` |

> `oxfmt` の `--write` はデフォルト動作のためフラグ省略可。glob は shell 展開を防ぐためクォートする。

### 3.4 `oxfmt-format.sh`（PostToolUse hook）

`biome-format.sh` の構造を踏襲し、以下を変更:
- 対象拡張子: `*.mjs|*.json|*.jsonc`（据え置き）
- ガード: `biome.json` 存在チェック → `.oxfmtrc.json` 存在チェック、`node_modules/.bin/biome` → `node_modules/.bin/oxfmt`
- 実行: `./node_modules/.bin/oxfmt "$file_path"` を best-effort（失敗しても hook 成功扱い）

### 3.5 CI `lint-format.yml`

job 名は `biome` → `oxc`（もしくは汎用の `lint-format`）に変更。step は `pnpm run check`（= oxlint + oxfmt --check）+ `git diff --exit-code` を維持。required status check 名の変更に注意（branch protection 設定と整合。job 名変更が required check に影響する場合はユーザーに確認）。

## 4. データ構造の変更

設定ファイルのスキーマ置換のみ。アプリケーションのデータモデル・型定義の変更なし。ReScript / Rust の生成物・ソースには一切触れない。

## 5. テスト方針

lint/format ツールの移行のため専用ユニットテストは追加しない（`testing.md` の「外部ツール結合」に該当）。代わりに以下で振る舞いを検証する:

- `pnpm run check` がローカルで pass する
- `pnpm run check:fix` 実行後 `git diff --exit-code` が clean（冪等性）
- `oxfmt --list-different "**/*.mjs" "**/*.json"` の出力に `.mjs`/`.json` 以外・除外対象が含まれない
- 意図的にスタイル違反を入れた一時ファイルで `oxfmt --check` / `oxlint` が非 0 exit することを確認（実装時のスモーク）
- PR 後 CI `lint-format` ジョブが green

tasklist.md にテスト省略理由として本方針を明記する。

## 6. リスクと対応

| リスク | 対応 |
|---|---|
| oxfmt が Biome と微妙に異なる整形をし大量 diff が出る | 一度きりの再整形として 1 コミットに分離し、diff を目視レビュー。スタイル設定で吸収できない差は許容（ツール移行に伴う正常な差分） |
| oxfmt が md/yml 等まで整形してしまう | 明示 glob + `ignorePatterns` + `--list-different` 検証で限定 |
| oxlint が既存 `.mjs` に新規 lint エラーを出す | 該当を修正、または `categories` の severity を調整して安定 gate を構成 |
| CI required status check 名の変更で PR がマージ不能になる | job 名変更前に branch protection の required check 設定を確認。必要なら check 名を維持 or ユーザーに設定変更を依頼 |
| oxfmt が 0.x（beta）で将来非互換変更の可能性 | production-ready と公表済み・Prettier conformance 100%。バージョンを `^0.58.0` で固定し nightly 互換 workflow で追従 |
