# Steering 058: Design — CI ワークフロー集約

## 1. アーキテクチャ

```
.github/workflows/
├── _test-package-runtime.yml         # 新規 (workflow_call で呼び出される)
├── _test-package-types.yml           # 新規 (同上)
├── tests-core-runtime.yml            # → 薄い wrapper
├── tests-core-types.yml              # → 薄い wrapper
├── tests-plugin-fs-runtime.yml       # → 薄い wrapper
├── tests-plugin-fs-types.yml         # → 薄い wrapper
├── ... (他 14 ファイル, 同様)
└── (build-core / examples-build / 他は対象外)
```

`_` プレフィックスは「他 workflow から `workflow_call` 経由でしか呼ばれない内部 workflow」であることを示す慣習。GitHub Actions の挙動上 `_` プレフィックスに特別な意味はないが、`actionlint` や手動レビュー時に意図が伝わりやすい。

## 2. 再利用 workflow の構造

### 2.1 `_test-package-runtime.yml`

```yaml
name: _test-package-runtime

on:
  workflow_call:
    inputs:
      package-name:
        description: "pnpm filter target, e.g. @rescript-tauri/plugin-fs"
        required: true
        type: string

permissions:
  contents: read

jobs:
  vitest:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
      - uses: pnpm/action-setup@91ab88e2619ed1f46221f0ba42d1492c02baf788 # v6.0.6
      - uses: actions/setup-node@48b55a011bda9f5d6aeb4c2d9c7362e8dae4041e # v6.4.0
        with:
          node-version: 24
          cache: pnpm
      - run: pnpm install --frozen-lockfile
      - run: pnpm --filter ${{ inputs.package-name }} test
```

合計 25 行。

### 2.2 `_test-package-types.yml`

```yaml
name: _test-package-types

on:
  workflow_call:
    inputs:
      package-name:
        description: "pnpm filter target, e.g. @rescript-tauri/plugin-fs"
        required: true
        type: string
      package-path:
        description: "Repo-relative path, e.g. packages/plugin-fs"
        required: true
        type: string

permissions:
  contents: read

jobs:
  type-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
      - uses: pnpm/action-setup@91ab88e2619ed1f46221f0ba42d1492c02baf788 # v6.0.6
      - uses: actions/setup-node@48b55a011bda9f5d6aeb4c2d9c7362e8dae4041e # v6.4.0
        with:
          node-version: 24
          cache: pnpm
      - run: pnpm install --frozen-lockfile
      - name: Build (compiles tests/*_signature.res = type-level test)
        run: pnpm --filter ${{ inputs.package-name }} build
      - name: Public-symbol coverage check
        shell: bash
        env:
          PKG_PATH: ${{ inputs.package-path }}
        run: |
          set -euo pipefail
          PUBLIC_COUNT=$(awk '
            BEGIN { in_doc = 0 }
            /^[[:space:]]*\/\*\*/ { in_doc = 1 }
            in_doc && /\*\// { in_doc = 0; next }
            !in_doc && /^[[:space:]]*let [A-Za-z_]/ { count++ }
            END { print count + 0 }
          ' "$PKG_PATH"/src/*.resi)
          CHECK_COUNT=$(grep -rE '^let _check_' "$PKG_PATH"/tests --include='*_signature.res' | wc -l | tr -d ' ')
          echo "Public lets in .resi : $PUBLIC_COUNT"
          echo "_check_ refs in tests: $CHECK_COUNT"
          if [ "$CHECK_COUNT" -lt "$PUBLIC_COUNT" ]; then
            echo "::error::Type-level coverage incomplete: $CHECK_COUNT/$PUBLIC_COUNT"
            exit 1
          fi
          echo "::notice::Type-level coverage OK ($CHECK_COUNT/$PUBLIC_COUNT)"
```

合計 ~50 行。

## 3. wrapper の構造

### 3.1 runtime wrapper (例: `tests-plugin-fs-runtime.yml`)

```yaml
name: tests-plugin-fs-runtime

on:
  push:
    branches: [main]
    paths:
      - "packages/plugin-fs/**"
      - "packages/core/**"
      - "pnpm-lock.yaml"
      - ".github/workflows/tests-plugin-fs-runtime.yml"
      - ".github/workflows/_test-package-runtime.yml"
  pull_request:
    branches: [main]
    paths:
      - "packages/plugin-fs/**"
      - "packages/core/**"
      - "pnpm-lock.yaml"
      - ".github/workflows/_test-package-runtime.yml"

jobs:
  call:
    uses: ./.github/workflows/_test-package-runtime.yml
    with:
      package-name: "@rescript-tauri/plugin-fs"
```

合計 21 行。`paths` に reusable workflow ファイル (`_test-package-runtime.yml`) を含めることで、reusable 側が変更されたときに wrapper も走るようにする。

### 3.2 types wrapper (例: `tests-plugin-fs-types.yml`)

```yaml
name: tests-plugin-fs-types

on:
  push:
    branches: [main]
    paths:
      - "packages/plugin-fs/**"
      - "packages/core/**"
      - "pnpm-lock.yaml"
      - ".github/workflows/tests-plugin-fs-types.yml"
      - ".github/workflows/_test-package-types.yml"
  pull_request:
    branches: [main]
    paths:
      - "packages/plugin-fs/**"
      - "packages/core/**"
      - "pnpm-lock.yaml"
      - ".github/workflows/_test-package-types.yml"

jobs:
  call:
    uses: ./.github/workflows/_test-package-types.yml
    with:
      package-name: "@rescript-tauri/plugin-fs"
      package-path: "packages/plugin-fs"
```

合計 23 行。

## 4. core 用の特殊化

`tests-core-runtime.yml` / `tests-core-types.yml` は他と異なる以下の特性がある:
- `paths:` に `packages/core/**` のみ (他 plugin は `core` も依存として含む)
- types 側の public-symbol coverage 検証は同等構造

→ そのまま reusable workflow を使えるが、wrapper の `paths:` は core only に簡略化する。

## 5. 行数試算

| 項目 | Before | After |
|---|---|---|
| reusable workflow (新規) | 0 | ~75 行 (25 + 50) |
| 16 wrapper (runtime × 8 + types × 8) | 32×8 + 52×8 = 672 行 | (21+23)×8 = 352 行 |
| **合計** | **672 行** | **427 行** |
| 純減 | — | **245 行** |

純減 245 行は当初見積もりの 420 行より少ないが、これは wrapper を完全空にできず `paths` filter は残す必要があるため。それでも 36% 削減 + 新 plugin 追加コストが 84 行 → 44 行 (-48%) になる。

## 6. ローカル検証

ディスク残量が 25 GB と限られているため `pnpm install` は実行しない。検証は以下に絞る:

| 項目 | 手段 |
|---|---|
| YAML 構文 | `python3 -c 'import yaml; yaml.safe_load(open(f))'` または `yq eval . <file>` |
| `uses:` の相対パス解決 | ファイル存在確認 (`ls .github/workflows/_test-package-*.yml`) |
| reusable workflow input 不整合 | wrapper の `with:` キーが reusable の `inputs:` と一致するか目視レビュー |

実 CI 上の動作確認は PR 上 (push 後の status check) で行う。本ステアリング内では行わない (push は別途指示があれば対応)。

## 7. 影響を受けるファイル一覧

```
新規:
  .github/workflows/_test-package-runtime.yml
  .github/workflows/_test-package-types.yml

書き換え:
  .github/workflows/tests-core-runtime.yml
  .github/workflows/tests-core-types.yml
  .github/workflows/tests-plugin-fs-runtime.yml
  .github/workflows/tests-plugin-fs-types.yml
  .github/workflows/tests-plugin-dialog-runtime.yml
  .github/workflows/tests-plugin-dialog-types.yml
  .github/workflows/tests-plugin-shell-runtime.yml
  .github/workflows/tests-plugin-shell-types.yml
  .github/workflows/tests-plugin-notification-runtime.yml
  .github/workflows/tests-plugin-notification-types.yml
  .github/workflows/tests-plugin-log-runtime.yml
  .github/workflows/tests-plugin-log-types.yml
  .github/workflows/tests-plugin-os-runtime.yml
  .github/workflows/tests-plugin-os-types.yml
  .github/workflows/tests-plugin-clipboard-manager-runtime.yml
  .github/workflows/tests-plugin-clipboard-manager-types.yml
  .github/workflows/tests-schema-runtime.yml
  .github/workflows/tests-schema-types.yml

ドキュメント:
  docs/repository-structure.md (CI ジョブ説明への補足追加)
```

## 8. リスクと緩和策

| リスク | 緩和策 |
|---|---|
| Branch Protection が status check 名で gating している場合、`<wrapper> / call / <reusable> / vitest` 形式に変わって gate 失敗 | 現リポジトリは Branch Protection 未設定 (PR チェックは informational)。変更後 PR で動作確認 |
| reusable workflow の input 名 typo で実行失敗 | 16 wrapper 全件を機械的に書き換えた後 grep で `with:` キーを統一性チェック |
| `paths` フィルタリングの抜け | core 依存が必要な plugin wrapper には全件 `packages/core/**` を含める |
