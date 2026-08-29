# Design: Biome による format / lint 導入

| 項目 | 内容 |
|---|---|
| 関連 requirements | `requirements.md` |
| 設計日 | 2026-05-09 |

---

## 1. 全体方針

Biome をルートに 1 つだけ導入する **single root config** 方式を採用する。各パッケージごとに `biome.json` を持たせる方式は採らない。

理由:

- 対象ファイルが約 18 個と少なく、パッケージ別に設定を分ける動機がない
- `*.res.mjs` の除外ルールはモノレポ全体で共通であり、重複定義を避けたい
- 実行コマンドはルートの `pnpm run check` 1 本に集約する方がシンプル

## 2. 採用バージョン

Biome **2.x 系** の最新安定版を採用する（執筆時点で 2.x がメジャー安定）。

`devDependencies` でルート `package.json` にのみ追加する:

```json
"devDependencies": {
  "@biomejs/biome": "^2.0.0"
}
```

> `^` で minor 追従。production-ready バインディングという PRD 要件上、stable 版に追従する。

## 3. ディレクトリ・ファイル変更計画

```
rescript-tauri/
├── biome.json                            # 新規 ★
├── package.json                          # devDependencies + scripts 追加
├── .github/workflows/
│   └── lint-format.yml                   # 新規 ★ または build-core.yml に step 追加
├── docs/
│   └── development-guidelines.md         # format/lint 節を追記
└── README.md                             # Development セクションに追記
```

`.steering/20260509-038-add-biome-format-lint/` は本ステアリングディレクトリ。

## 4. `biome.json` の設計

### 4.1 全体構造

```json
{
  "$schema": "https://biomejs.dev/schemas/2.0.0/schema.json",
  "vcs": {
    "enabled": true,
    "clientKind": "git",
    "useIgnoreFile": true
  },
  "files": {
    "includes": [
      "**",
      "!**/node_modules",
      "!**/lib",
      "!**/*.res.mjs",
      "!**/target",
      "!**/.claude/worktrees",
      "!sphinx-docs",
      "!examples/*/src-tauri",
      "!**/Cargo.lock"
    ]
  },
  "formatter": {
    "enabled": true,
    "indentStyle": "space",
    "indentWidth": 2,
    "lineWidth": 100,
    "lineEnding": "lf"
  },
  "javascript": {
    "formatter": {
      "quoteStyle": "double",
      "semicolons": "asNeeded",
      "trailingCommas": "all",
      "arrowParentheses": "always"
    }
  },
  "json": {
    "formatter": {
      "indentWidth": 2,
      "trailingCommas": "none"
    }
  },
  "linter": {
    "enabled": true,
    "rules": {
      "recommended": true
    }
  }
}
```

### 4.2 includes パターンの設計判断

- `"**"` で全ファイルを起点に取り、`!` プレフィックスで段階的に除外する（Biome 2.x の `includes` 仕様）
- `useIgnoreFile: true` により `.gitignore` も自動尊重される（`*.res.mjs` は既に gitignore 済みだが、二重に明示することで CI での誤検知を防止）
- `examples/*/src-tauri` を除外して Rust コード・`Cargo.lock` を対象外にする
- `sphinx-docs` 全体を除外（Markdown は本 steering の対象外）

### 4.3 JS フォーマット規則の決定理由

| 設定項目 | 値 | 既存コードとの整合 |
|---|---|---|
| `quoteStyle` | `double` | 既存 `.mjs` がダブルクォート優勢 |
| `semicolons` | `asNeeded` | 既存 `.mjs` が ASI スタイル（`core_command.test.mjs` 確認済み） |
| `trailingCommas` | `all` | 既存コードに準拠 |
| `arrowParentheses` | `always` | Biome デフォルト |
| `lineWidth` | `100` | 既存テストで長めの行が出る |

**実際の既存コード適用結果は実装時に検証する**。差分が大きすぎる場合は設定を実情に合わせて調整する（ただし基本姿勢は「Biome 推奨に寄せる」）。

### 4.4 lint ルールの決定

- **`recommended: true`** のみ有効化
- 個別ルール調整は **違反が出た場合のみ事後追加** する（YAGNI）
- ReScript 出力 JS との互換性のため、`noExplicitAny` 等の TypeScript 専用ルールは対象外（`.mjs` のみのため自動的に無効）

### 4.5 違反予測

| ルール | 予測される違反 | 対処方針 |
|---|---|---|
| `noUnusedVariables` | テストで宣言だけして未使用、の可能性 | 変数を実際に使う or `_` プレフィックス |
| `useTemplate` | 文字列連結を template literal に | 修正で対応 |
| `noConsole` | テスト内 `console.log` | `recommended` に含まれない想定。違反時のみ対処 |
| `useConst` | `let` で再代入なし | 修正で対応 |

## 5. `package.json` の設計

ルート `package.json` に scripts を追加する:

```json
{
  "scripts": {
    "build": "pnpm --recursive --if-present build",
    "clean": "pnpm --recursive --if-present run clean",
    "test": "pnpm --recursive --if-present test",
    "format": "biome format --write .",
    "format:check": "biome format .",
    "lint": "biome lint .",
    "lint:fix": "biome lint --write .",
    "check": "biome check .",
    "check:fix": "biome check --write ."
  }
}
```

| script | 用途 |
|---|---|
| `format` | ローカルで一括フォーマット（書き換える） |
| `format:check` | フォーマット差分検証のみ（CI 用） |
| `lint` | lint 実行（書き換えなし、CI 用） |
| `lint:fix` | lint 自動修正 |
| `check` | format + lint 統合検証（CI 用、書き換えなし） |
| `check:fix` | format + lint 統合修正（ローカル用） |

## 6. CI 統合の設計

### 6.1 方針

新規ワークフロー **`.github/workflows/lint-format.yml`** を追加する。既存の `build-core.yml` 等に step を足すと再利用しにくいため独立ジョブとする。

### 6.2 ワークフロー定義（案）

```yaml
name: Lint & Format
on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  biome:
    name: Biome check
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@<pinned SHA>
      - uses: pnpm/action-setup@<pinned SHA>
        with:
          version: 10
      - uses: actions/setup-node@<pinned SHA>
        with:
          node-version: 22
          cache: pnpm
      - run: pnpm install --frozen-lockfile
      - run: pnpm run check
      - name: Verify no source mutation
        run: git diff --exit-code
```

- アクション SHA は `.github/workflows/build-core.yml` で使用済みのものに合わせる（`28-pin-action-shas` ステアリングの方針に準拠）
- 最終 step `git diff --exit-code` で「Biome が誤って `*.res.mjs` を書き換えていないこと」を検証する（FR-4 の保険）

### 6.3 既存ワークフローとの関係

- `build-core.yml` / `tests-core-runtime.yml` 等は変更しない
- 並列実行されることでフィードバック時間を短縮する

## 7. 開発者ワークフロー

### 7.1 通常開発

```bash
# 編集後
pnpm run check:fix   # ローカルで format + lint 自動修正

# コミット前確認
pnpm run check       # 違反がないか最終確認
```

### 7.2 VS Code 統合

`biome.json` がプロジェクトルートにあれば、Biome VS Code 拡張がそれを自動認識する。

**本ステアリングで `.vscode/settings.json` を追加するかは検討する**:

- 追加するメリット: 開発者がプロジェクトを開いた瞬間から正しい挙動になる
- 追加しないメリット: `.gitignore` で `.vscode/` を除外している既存方針と整合
- **判断: 追加しない**。`.gitignore` で `.vscode/` が除外されている既存方針を尊重し、`README.md` の手順案内のみで対応する

## 8. ドキュメント更新計画

### 8.1 `README.md`

`Development` セクション（または同等の節）に以下を追記:

```markdown
## Code Quality

JavaScript / JSON files are linted and formatted by [Biome](https://biomejs.dev/).
ReScript files (`.res` / `.resi`) are formatted by `rescript format` instead.

\`\`\`bash
pnpm run check       # verify
pnpm run check:fix   # auto-fix
\`\`\`
```

### 8.2 `docs/development-guidelines.md`

format/lint 節を追加（または既存節に追記）。実装時に既存の構成を確認して挿入箇所を決定する。

### 8.3 `CLAUDE.md`

「ビルド・実行コマンド」節に `pnpm run check` を追記する:

```markdown
# 品質チェック（format + lint）
pnpm run check
```

### 8.4 `.steering/[作業ディレクトリ]/`

本ステアリングのファイルは実装コミットに同梱する。

## 9. 実装順序（要約）

1. worktree 作成（`worktree-add-biome-format-lint`）
2. `biome.json` 作成
3. `package.json` 更新（devDependencies + scripts）
4. `pnpm install` で Biome をインストール
5. `pnpm run check:fix` を一度実行し、既存ファイルをフォーマット
6. lint 違反があれば修正（または `biome.json` で限定的に無効化）
7. ReScript ビルド実行 → `*.res.mjs` が変更されていないことを `git diff` で確認
8. CI ワークフロー追加
9. ドキュメント更新（README / development-guidelines / CLAUDE.md）
10. tasklist 全項目を `[x]` に更新してマージ準備コミット
11. ユーザー承認 → main マージ → クリーンアップ

詳細は `tasklist.md` 参照。

## 10. ロールバック計画

もし本ステアリング導入後に問題が発生した場合:

- `biome.json` 削除 + `package.json` の scripts/devDependencies から Biome 関連エントリ削除 + CI ワークフロー削除 で完全にロールバック可能
- ReScript ビルドや既存テストには影響を与えない設計（FR-3 / NFR-3 で保証）
