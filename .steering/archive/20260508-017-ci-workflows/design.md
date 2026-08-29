# 設計: CI workflow 実体化

## ファイル構成

```
.github/workflows/
├── build-core.yml             # 新規
├── tests-core-types.yml       # 新規
├── tests-core-runtime.yml     # 新規
├── doc-link-lint.yml          # 新規
├── examples-build.yml         # 新規 (3 OS マトリクス)
├── docs.yml                   # 既存 (sphinx-docs)
├── auto-pr-description.yml.template
├── claude-code-review.yml.template
└── README.md                  # 更新（active 表に 5 個追加）
```

## 各 workflow の中身

### `.github/workflows/build-core.yml`

```yaml
name: build-core

on:
  push:
    branches: [main]
    paths:
      - "packages/core/**"
      - "pnpm-lock.yaml"
      - "package.json"
      - ".github/workflows/build-core.yml"
  pull_request:
    branches: [main]
    paths:
      - "packages/core/**"
      - "pnpm-lock.yaml"
      - "package.json"

permissions:
  contents: read

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v4
        with:
          version: 10
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: pnpm
      - run: pnpm install --frozen-lockfile
      - name: Clean build
        run: pnpm --filter @rescript-tauri/core run clean
      - name: Build with timing
        run: |
          start=$(date +%s)
          pnpm --filter @rescript-tauri/core build
          end=$(date +%s)
          echo "build_seconds=$((end - start))" >> "$GITHUB_OUTPUT"
          echo "::notice::Clean build completed in $((end - start))s (PRD §5.2 budget: 30s)"
```

### `.github/workflows/tests-core-types.yml`

```yaml
name: tests-core-types

on:
  push:
    branches: [main]
    paths:
      - "packages/core/**"
      - "pnpm-lock.yaml"
      - ".github/workflows/tests-core-types.yml"
  pull_request:
    branches: [main]
    paths:
      - "packages/core/**"
      - "pnpm-lock.yaml"

permissions:
  contents: read

jobs:
  type-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v4
        with:
          version: 10
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: pnpm
      - run: pnpm install --frozen-lockfile
      - name: Build (compiles tests/*_signature.res = type-level test)
        run: pnpm --filter @rescript-tauri/core build
      - name: Public-symbol coverage check
        shell: bash
        run: |
          set -euo pipefail
          # Count public lets across all .resi files
          PUBLIC_COUNT=$(grep -rE '^[[:space:]]*let [A-Za-z_]' packages/core/src --include='*.resi' | wc -l | tr -d ' ')
          # Count _check_* references in tests/*_signature.res
          CHECK_COUNT=$(grep -rE '^let _check_' packages/core/tests --include='*_signature.res' | wc -l | tr -d ' ')
          echo "Public lets in .resi : $PUBLIC_COUNT"
          echo "_check_ refs in tests: $CHECK_COUNT"
          if [ "$CHECK_COUNT" -lt "$PUBLIC_COUNT" ]; then
            echo "::error::Type-level coverage incomplete: $CHECK_COUNT/$PUBLIC_COUNT"
            exit 1
          fi
          echo "::notice::Type-level coverage OK ($CHECK_COUNT/$PUBLIC_COUNT)"
```

### `.github/workflows/tests-core-runtime.yml`

```yaml
name: tests-core-runtime

on:
  push:
    branches: [main]
    paths:
      - "packages/core/**"
      - "pnpm-lock.yaml"
      - ".github/workflows/tests-core-runtime.yml"
  pull_request:
    branches: [main]
    paths:
      - "packages/core/**"
      - "pnpm-lock.yaml"

permissions:
  contents: read

jobs:
  vitest:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v4
        with:
          version: 10
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: pnpm
      - run: pnpm install --frozen-lockfile
      - run: pnpm --filter @rescript-tauri/core test
```

### `.github/workflows/doc-link-lint.yml`

```yaml
name: doc-link-lint

on:
  push:
    branches: [main]
    paths:
      - "packages/core/**/*.resi"
      - ".github/workflows/doc-link-lint.yml"
  pull_request:
    branches: [main]
    paths:
      - "packages/core/**/*.resi"

permissions:
  contents: read

jobs:
  doc-links:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Verify each .resi mentions a Tauri docs URL
        shell: bash
        run: |
          set -euo pipefail
          missing=0
          for f in $(find packages/core/src -name '*.resi'); do
            if ! grep -qE 'v2\.tauri\.app/' "$f"; then
              echo "::error file=$f::no v2.tauri.app/ URL found in this .resi"
              missing=$((missing + 1))
            fi
          done
          if [ "$missing" -gt 0 ]; then
            exit 1
          fi
          echo "::notice::All public .resi files include a Tauri docs URL"
```

### `.github/workflows/examples-build.yml`

```yaml
name: examples-build

on:
  push:
    branches: [main]
    paths:
      - "examples/**"
      - "packages/core/**"
      - "pnpm-lock.yaml"
      - ".github/workflows/examples-build.yml"
  pull_request:
    branches: [main]
    paths:
      - "examples/**"
      - "packages/core/**"
      - "pnpm-lock.yaml"

permissions:
  contents: read

jobs:
  build:
    strategy:
      fail-fast: false
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v4
        with:
          version: 10
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: pnpm
      - uses: dtolnay/rust-toolchain@stable
      - name: Linux Tauri prerequisites
        if: matrix.os == 'ubuntu-latest'
        run: |
          sudo apt-get update
          sudo apt-get install -y libwebkit2gtk-4.1-dev libgtk-3-dev libayatana-appindicator3-dev librsvg2-dev libssl-dev
      - run: pnpm install --frozen-lockfile
      - name: Build hello-world frontend
        run: pnpm --filter hello-world build
      - name: Cargo check on hello-world Rust side
        working-directory: examples/hello-world/src-tauri
        run: cargo check --release
```

> **Note**: 完全な `pnpm tauri build` 相当の bundle 作成は GUI 関係の dependencies が重く、本 CI ではフロント `pnpm build` + Rust `cargo check` で十分とする (functional-design §6 examples-build の妥当性を確認済み)。

### `.github/workflows/README.md` 更新

`Active workflows` 表に 5 個追加し、`Planned for Phase 1` 表から 5 個を削除。残 3 個（`compat-*` × 2, `release`）は Planned のまま。

## コミット粒度

| # | コミット |
|---|---|
| 1 | 📝 Add steering for 20260508-017 (ci-workflows) |
| 2 | 🔧 Add 5 active CI workflows (build-core / tests-core-types / tests-core-runtime / doc-link-lint / examples-build) |
| 3 | 📝 Update .github/workflows/README.md to reflect newly active workflows |
| 4 | 📝 Mark steering 20260508-017 complete |

## worktree

`EnterWorktree(name="ci-workflows")`。

## テスト

ローカルでは workflow の `paths` フィルタや YAML 構文の確認のみ。実際の実行は GitHub Actions 上で push 後に発生する（visibility が private のためコスト発生に留意。Free Plan の private repo は月 2000 分まで無料）。

`actionlint` ツール (`brew install actionlint`) があれば事前 lint 可能だが、本ステアリングでは Python の yaml parser で構文チェックに留める。
