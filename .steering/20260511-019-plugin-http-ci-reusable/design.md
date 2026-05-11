# Design: plugin-http CI を reusable workflow に揃える

## 現状

### tests-plugin-http-types.yml (53 行)

```yaml
jobs:
  type-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@...
      - uses: pnpm/action-setup@...
      - uses: actions/setup-node@...
      - run: pnpm install --frozen-lockfile
      - name: Build (...)
        run: pnpm --filter @rescript-tauri/plugin-http build
      - name: Public-symbol coverage check
        run: |
          ... 17 行のスクリプト ...
```

### tests-plugin-http-runtime.yml (33 行)

```yaml
jobs:
  vitest:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@...
      - uses: pnpm/action-setup@...
      - uses: actions/setup-node@...
      - run: pnpm install --frozen-lockfile
      - run: pnpm --filter @rescript-tauri/plugin-http test
```

## 変更後

### tests-plugin-http-types.yml (~25 行)

```yaml
name: tests-plugin-http-types

on:
  push:
    branches: [main]
    paths:
      - "packages/plugin-http/**"
      - "packages/core/**"
      - "pnpm-lock.yaml"
      - ".github/workflows/tests-plugin-http-types.yml"
      - ".github/workflows/_test-package-types.yml"
  pull_request:
    branches: [main]
    paths:
      - "packages/plugin-http/**"
      - "packages/core/**"
      - "pnpm-lock.yaml"
      - ".github/workflows/_test-package-types.yml"

permissions:
  contents: read

jobs:
  call:
    uses: ./.github/workflows/_test-package-types.yml
    with:
      package-name: "@rescript-tauri/plugin-http"
      package-path: "packages/plugin-http"
```

### tests-plugin-http-runtime.yml (~22 行)

```yaml
name: tests-plugin-http-runtime

on:
  push:
    branches: [main]
    paths:
      - "packages/plugin-http/**"
      - "packages/core/**"
      - "pnpm-lock.yaml"
      - ".github/workflows/tests-plugin-http-runtime.yml"
      - ".github/workflows/_test-package-runtime.yml"
  pull_request:
    branches: [main]
    paths:
      - "packages/plugin-http/**"
      - "packages/core/**"
      - "pnpm-lock.yaml"
      - ".github/workflows/_test-package-runtime.yml"

permissions:
  contents: read

jobs:
  call:
    uses: ./.github/workflows/_test-package-runtime.yml
    with:
      package-name: "@rescript-tauri/plugin-http"
```

## 整合性確認

`tests-plugin-log-runtime.yml`, `tests-plugin-log-types.yml` 等の既存 REUSABLE ファイルと並べて diff し、構造が一致することを確認する。差分は `package-name` / `package-path` の値のみ。

## 検証手段

```bash
# YAML syntax check
yq eval . .github/workflows/tests-plugin-http-types.yml
yq eval . .github/workflows/tests-plugin-http-runtime.yml

# 他 plugin との構造一致確認 (diff against plugin-log)
diff <(grep -v 'http' .github/workflows/tests-plugin-http-types.yml) \
     <(grep -v 'log' .github/workflows/tests-plugin-log-types.yml)
```

CI 上での動作検証はマージ後に PR をいくつか走らせて確認（plugin-http のテストが正しく起動するか）。

## リスク

- `permissions: contents: read` の有無 — runtime 版は元々無いが、reusable 版に揃える際に追加 or 省略を統一する必要がある
  - **確認**: 他 plugin の runtime workflow には `permissions: contents: read` が **無い**（reusable 側で持つ）。types 版にはあるが、reusable 側にも同等の宣言がある。設定は reusable 側に集約する方針で問題なし
- ジョブ名が `type-tests` / `vitest` から `call` に変わる — GitHub branch protection rules で `tests-plugin-http-types / type-tests` 等を required にしている場合、`tests-plugin-http-types / call / type-tests` に変わる可能性あり
  - **確認**: 他 plugin は既に `call` を使用しているため、branch protection の整合性は既に取れているはず（http だけが outlier）
