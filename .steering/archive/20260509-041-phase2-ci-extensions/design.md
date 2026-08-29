# Design: Phase 2 CI extensions

## 1. テスト CI ワークフロー（6 ファイル）

### 1.1 共通テンプレート（runtime 系）

`tests-core-runtime.yml` をベースに、`packages/core` を対象パッケージ
に置換し、`pnpm --filter @rescript-tauri/<name> test` に差し替える。

`paths:` フィルタも対象パッケージへのパスに変更:

```yaml
paths:
  - "packages/<name>/**"
  - "packages/core/**"      # core 依存のため
  - "pnpm-lock.yaml"
  - ".github/workflows/tests-<name>-runtime.yml"
```

`packages/core/**` は plugin-fs / plugin-dialog / schema 全部が core を
peer として使うため依存トリガとして含める。

### 1.2 共通テンプレート（types 系）

`tests-core-types.yml` ベース。public-symbol coverage チェックの
`PUBLIC_COUNT` 算出を doc-comment 除外版にする (schema 対策)。

```bash
PUBLIC_COUNT=$(awk '
  BEGIN { in_doc = 0 }
  /^[[:space:]]*\/\*\*/ { in_doc = 1 }
  in_doc && /\*\// { in_doc = 0; next }
  !in_doc && /^[[:space:]]*let [A-Za-z_]/ { count++ }
  END { print count + 0 }
' packages/<name>/src/*.resi)
```

`/** ... */` ブロック中の `let` 例を除外。同じ awk を 4 つの
types ワークフローすべてに使うことで挙動を一貫させる。

### 1.3 ファイルごとの差分

| ファイル | filter / package |
|---|---|
| `tests-schema-types.yml` | `@rescript-tauri/schema`, `packages/schema` |
| `tests-schema-runtime.yml` | 同上 |
| `tests-plugin-fs-types.yml` | `@rescript-tauri/plugin-fs`, `packages/plugin-fs` |
| `tests-plugin-fs-runtime.yml` | 同上 |
| `tests-plugin-dialog-types.yml` | `@rescript-tauri/plugin-dialog`, `packages/plugin-dialog` |
| `tests-plugin-dialog-runtime.yml` | 同上 |

### 1.4 type-level test ビルドステップ

各 plugin / schema パッケージの test スクリプトは `rescript build` で
signature ファイル `*_signature.res` も同時にコンパイルされる
（dev-source として `rescript.json` の `tests` ディレクトリが含まれる
ため）。types ジョブは `pnpm --filter <pkg> build` ではなく、core と
同じく `pnpm --filter <pkg> test` のうち `rescript build` 部分まで
実行できれば良いが、テスト用の `tests/runtime/*` も同時に走らせない
ためには別途調整が必要。

シンプルに「`pnpm --filter <pkg> test` を runtime ジョブで動かす」
+ 「types ジョブは `rescript build` を呼んで signature コンパイルを
含む 1 ビルド + coverage 数チェック」の二段構成とする:

- types ジョブ: `pnpm --filter <pkg> build` →
  signature.res は dev source なので `rescript build` 単体では
  コンパイルされない。`rescript build` の代わりに `npx -w packages/<pkg> rescript build`
  + `--with-deps` フラグで dev source を含める…が、core の
  `tests-core-types.yml` は `pnpm --filter @rescript-tauri/core build`
  だけで signature を `Compiled` できている。

確認するため core の rescript.json を見てから判断する。

> 実装時に確認: core の rescript.json は `tests` を `type: "dev"` 付きで
> `sources` に含む。`rescript build` は dev source も既定でコンパイル
> する。よって types ジョブは `pnpm --filter <pkg> build` だけで
> signature コンパイルが走る (= 型レベルテスト)。

### 1.5 型コミットメント

types ジョブの構造:

```yaml
jobs:
  type-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
      - uses: pnpm/action-setup@a15d269cd4658e1107c09f1fabf4cbd7bd1f308a # v4.4.0
      - uses: actions/setup-node@48b55a011bda9f5d6aeb4c2d9c7362e8dae4041e # v6.4.0
        with:
          node-version: 24
          cache: pnpm
      - run: pnpm install --frozen-lockfile
      - name: Build (compiles tests/*_signature.res = type-level test)
        run: pnpm --filter @rescript-tauri/<name> build
      - name: Public-symbol coverage check
        shell: bash
        run: |
          set -euo pipefail
          PUBLIC_COUNT=$(awk '
            BEGIN { in_doc = 0 }
            /^[[:space:]]*\/\*\*/ { in_doc = 1 }
            in_doc && /\*\// { in_doc = 0; next }
            !in_doc && /^[[:space:]]*let [A-Za-z_]/ { count++ }
            END { print count + 0 }
          ' packages/<name>/src/*.resi)
          CHECK_COUNT=$(grep -rE '^let _check_' packages/<name>/tests --include='*_signature.res' | wc -l | tr -d ' ')
          echo "Public lets in .resi : $PUBLIC_COUNT"
          echo "_check_ refs in tests: $CHECK_COUNT"
          if [ "$CHECK_COUNT" -lt "$PUBLIC_COUNT" ]; then
            echo "::error::Type-level coverage incomplete: $CHECK_COUNT/$PUBLIC_COUNT"
            exit 1
          fi
          echo "::notice::Type-level coverage OK ($CHECK_COUNT/$PUBLIC_COUNT)"
```

## 2. `examples-build.yml` 拡張

既存マトリクス末尾に 3 例題分のステップを追加:

```yaml
      - name: Build plugin-dialog-demo frontend
        run: pnpm --filter plugin-dialog-demo build
      - name: Cargo check on plugin-dialog-demo Rust side
        working-directory: examples/plugin-dialog-demo/src-tauri
        run: cargo check --release

      - name: Build plugin-fs-demo frontend
        run: pnpm --filter plugin-fs-demo build
      - name: Cargo check on plugin-fs-demo Rust side
        working-directory: examples/plugin-fs-demo/src-tauri
        run: cargo check --release

      - name: Build ipc-typed-with-schema frontend
        run: pnpm --filter ipc-typed-with-schema build
      - name: Cargo check on ipc-typed-with-schema Rust side
        working-directory: examples/ipc-typed-with-schema/src-tauri
        run: cargo check --release
```

`paths` フィルタは `examples/**` がワイルドカード化されているため
追加変更不要。

## 3. `release.yml` 拡張

### 3.1 タグ→パッケージのマッピング

`on.push.tags` で `v*` 単独だと plugin / schema タグも `v*` に
マッチしてしまう (`schema-v0.1.0` は `v` を含むが頭ではないので
マッチしない)。改めて整理:

- `v*` → core
- `schema-v*` → schema
- `plugin-fs-v*` → plugin-fs
- `plugin-dialog-v*` → plugin-dialog

`v*` パターンは `*` 部分が任意なので `schema-v0.1.0` などを除外する
ためには明示的にすべての prefix を `tags:` 配列に追加する。
GitHub の glob に negative pattern (`!schema-v*`) を加える方法も
あるが、可読性のため明示列挙する。

```yaml
on:
  push:
    tags:
      - "v*"
      - "schema-v*"
      - "plugin-fs-v*"
      - "plugin-dialog-v*"
```

問題点: `v*` は `schema-v*` などにマッチしないか? GitHub Actions の
ref glob は ref 全体に対する pattern マッチなので、`refs/tags/v*` は
頭が `refs/tags/v` で始まるタグにのみマッチ。`refs/tags/schema-v0.1.0`
は `s` で始まるため `v*` にマッチしない。OK。

### 3.2 タグ→パッケージ判定ステップ

```yaml
      - name: Determine target package
        id: target
        shell: bash
        env:
          GITHUB_REF: ${{ github.ref }}
        run: |
          set -euo pipefail
          tag="${GITHUB_REF#refs/tags/}"
          case "$tag" in
            schema-v*)
              echo "package=@rescript-tauri/schema" >> "$GITHUB_OUTPUT"
              echo "directory=packages/schema"     >> "$GITHUB_OUTPUT"
              ;;
            plugin-fs-v*)
              echo "package=@rescript-tauri/plugin-fs" >> "$GITHUB_OUTPUT"
              echo "directory=packages/plugin-fs"     >> "$GITHUB_OUTPUT"
              ;;
            plugin-dialog-v*)
              echo "package=@rescript-tauri/plugin-dialog" >> "$GITHUB_OUTPUT"
              echo "directory=packages/plugin-dialog"     >> "$GITHUB_OUTPUT"
              ;;
            v*)
              echo "package=@rescript-tauri/core" >> "$GITHUB_OUTPUT"
              echo "directory=packages/core"      >> "$GITHUB_OUTPUT"
              ;;
            *)
              echo "::error::Unrecognized tag pattern: $tag"
              exit 1
              ;;
          esac
```

`workflow_dispatch` でタグ無しに走るケースは core にフォールバック
（既存挙動維持）:

```yaml
            "")
              # workflow_dispatch (no tag context) — default to core
              echo "package=@rescript-tauri/core" >> "$GITHUB_OUTPUT"
              echo "directory=packages/core"      >> "$GITHUB_OUTPUT"
              ;;
```

ただし `workflow_dispatch` 時 `GITHUB_REF` は `refs/heads/<branch>` に
なるため、`tag=` が頭からその値になる。判定では `case` の `*)` に
落ちてしまうので、先に `[ "${GITHUB_EVENT_NAME}" = "workflow_dispatch" ]`
の場合は core 固定にする。

```bash
if [ "${GITHUB_EVENT_NAME}" = "workflow_dispatch" ]; then
  echo "package=@rescript-tauri/core" >> "$GITHUB_OUTPUT"
  echo "directory=packages/core" >> "$GITHUB_OUTPUT"
  exit 0
fi
tag="${GITHUB_REF#refs/tags/}"
case "$tag" in
  ...
esac
```

### 3.3 build / test ステップの汎用化

既存:

```yaml
      - name: Build @rescript-tauri/core
        run: pnpm --filter @rescript-tauri/core build
      - name: Test @rescript-tauri/core
        run: pnpm --filter @rescript-tauri/core test
```

を `${{ steps.target.outputs.package }}` 参照に変える:

```yaml
      - name: Build target package
        run: pnpm --filter ${{ steps.target.outputs.package }} build
      - name: Test target package
        run: pnpm --filter ${{ steps.target.outputs.package }} test
```

publish ステップも `working-directory: ${{ steps.target.outputs.directory }}`
に変える。

### 3.4 GitHub Release 作成

既存:

```yaml
      - name: Create GitHub Release
        if: startsWith(github.ref, 'refs/tags/v')
        ...
```

`startsWith(github.ref, 'refs/tags/v')` は `schema-v*` 等にマッチ
しないが、これらでも release は作りたい。条件を `startsWith(github.ref, 'refs/tags/')`
に緩める。

## 4. ステップ詳細表

| 編集対象 | 変更内容 |
|---|---|
| `.github/workflows/tests-schema-types.yml` | 新規作成 |
| `.github/workflows/tests-schema-runtime.yml` | 新規作成 |
| `.github/workflows/tests-plugin-fs-types.yml` | 新規作成 |
| `.github/workflows/tests-plugin-fs-runtime.yml` | 新規作成 |
| `.github/workflows/tests-plugin-dialog-types.yml` | 新規作成 |
| `.github/workflows/tests-plugin-dialog-runtime.yml` | 新規作成 |
| `.github/workflows/examples-build.yml` | 3 example の build/check ステップ追加 |
| `.github/workflows/release.yml` | タグ → パッケージマッピング、build/test/publish/release を steps.target ベースに汎用化 |

## 5. ローカル検証手順

1. すべての YAML を python の `yaml.safe_load` でパースし、構文
   エラーがないことを確認。
2. `pnpm --recursive build` / `pnpm --recursive test` で実行コードに
   影響がないことを確認（CI 設定のみの変更）。
3. release.yml のタグ→ディレクトリ判定 bash を手動実行で
   コーナーケース確認 (`v0.1.0`, `schema-v0.1.0`, `plugin-fs-v1.2.3`,
   workflow_dispatch 模擬)。

## 6. リスクと対応

| リスク | 対応 |
|---|---|
| schema の type-coverage が doc-comment example で false fail | awk で `/** ... */` ブロックを除外 |
| 既存 `v*` タグが新パターンと衝突 | GitHub の ref glob は ref 全体マッチ。`v0.1.0` と `schema-v0.1.0` は別物として扱われる |
| publish 対象が誤判定 | bash `case` で厳密 prefix マッチ。デフォルト分岐 (`*)`) で `exit 1` |
| GitHub Release 作成漏れ | 条件を `refs/tags/` 全体に緩める |
| 並行セッションが workflows を編集中 | merge 時に conflict が出たら手動解消 |
