# Steering 059: Design — vitest config 共通化

## 1. 構成

```
rescript-tauri/
├── tools/                                # 新規ディレクトリ (devtime のみ; publish 対象外)
│   └── vitest.shared.mjs                 # definePackageConfig helper
└── packages/
    ├── core/vitest.config.mjs            # ↓ すべて helper 呼び出しの薄い形へ
    ├── plugin-fs/vitest.config.mjs
    ├── plugin-dialog/vitest.config.mjs
    ├── plugin-shell/vitest.config.mjs
    ├── plugin-notification/vitest.config.mjs
    ├── plugin-log/vitest.config.mjs
    ├── plugin-os/vitest.config.mjs
    └── schema/vitest.config.mjs
```

## 2. helper の API

### 2.1 シグネチャ

```js
// tools/vitest.shared.mjs
import {defineConfig} from "vitest/config"

/**
 * Default config for a `@rescript-tauri/*` package's vitest setup.
 * Mirrors the settings every package has shared verbatim:
 *
 * - test environment: happy-dom
 * - test files: tests/runtime/<asterisk><asterisk>/<asterisk>.test.mjs
 * - coverage provider: v8 (text-summary / json-summary / lcov / html)
 * - coverage scope: src/<asterisk><asterisk>/<asterisk>.res.mjs
 *
 * @param {{thresholds?: {statements?: number, branches?: number, functions?: number, lines?: number}}} [opts]
 *   When `thresholds` is supplied, vitest fails the run if coverage drops below
 *   the given floors. Omit to run coverage in observe-only mode.
 */
export function definePackageConfig({thresholds} = {}) {
  return defineConfig({
    test: {
      environment: "happy-dom",
      include: ["tests/runtime/**/*.test.mjs"],
      coverage: {
        provider: "v8",
        include: ["src/**/*.res.mjs"],
        exclude: ["src/**/*.test.mjs", "tests/**", "node_modules/**", "lib/**"],
        reporter: ["text-summary", "json-summary", "lcov", "html"],
        reportsDirectory: "./coverage",
        reportOnFailure: false,
        ...(thresholds ? {thresholds} : {}),
      },
    },
  })
}
```

合計 ~35 行 (doc comment 込み)。

### 2.2 各パッケージでの使い方

```js
// packages/core/vitest.config.mjs (例)
import {definePackageConfig} from "../../tools/vitest.shared.mjs"

// Thresholds set 2-3 pt below the value measured after the C/D/E
// residual cleanup. The remaining uncovered surface is the
// defensive-fallback category that won't fire under normal
// operation. Raise this floor only after a corresponding test
// addition.
export default definePackageConfig({
  thresholds: {
    statements: 96,
    branches: 80,
    functions: 96,
    lines: 96,
  },
})
```

合計 ~14 行 (元 33 行から -19 行)。

## 3. 閾値・コメントの保持

各パッケージの現行値を以下の通り維持:

| パッケージ | statements | branches | functions | lines | コメント保持 |
|---|---|---|---|---|---|
| core | 96 | 80 | 96 | 96 | C/D/E 残存ギャップ記述 |
| plugin-fs | 100 | 45 | 100 | 100 | branch 50% 未達理由 |
| plugin-dialog | 100 | 55 | 100 | 100 | branch 60% 未達理由 |
| plugin-shell | (none) | (none) | (none) | (none) | コメントなし、threshold 未設定 |
| plugin-notification | 95 | 45 | 95 | 95 | branch 45% sendNotification overload 説明 |
| plugin-log | 95 | 50 | 95 | 95 | コメントなし |
| plugin-os | 95 | 50 | 95 | 95 | コメントなし |
| schema | 88 | 45 | 95 | 88 | helper 4 関数の説明 |

`plugin-shell` は現状 thresholds なし (観測のみ)。helper の `thresholds` を省略する形でそのまま再現する。

## 4. 行数試算

| ファイル | Before | After (試算) | 差分 |
|---|---|---|---|
| `tools/vitest.shared.mjs` (新規) | 0 | 35 | +35 |
| `packages/core/vitest.config.mjs` | 33 | 14 | -19 |
| `packages/plugin-fs/vitest.config.mjs` | 30 | 13 | -17 |
| `packages/plugin-dialog/vitest.config.mjs` | 30 | 13 | -17 |
| `packages/plugin-shell/vitest.config.mjs` | 14 | 4 | -10 |
| `packages/plugin-notification/vitest.config.mjs` | 27 | 13 | -14 |
| `packages/plugin-log/vitest.config.mjs` | 18 | 12 | -6 |
| `packages/plugin-os/vitest.config.mjs` | 18 | 12 | -6 |
| `packages/schema/vitest.config.mjs` | 23 | 13 | -10 |
| **合計** | **193** | **129** | **-64** |

純減 ~64 行。各 `vitest.config.mjs` は 4-14 行に圧縮され、変更があるとき diff のシグナル/ノイズ比が改善される。

## 5. 検証

ディスク残量確保のため `pnpm install` は走らせない。検証手段:

| 項目 | 手段 |
|---|---|
| ESM 構文 | `node --check tools/vitest.shared.mjs` および各 `vitest.config.mjs` |
| import 解決 | `node -e 'import("./packages/core/vitest.config.mjs").then(m => console.log(typeof m.default))'` (Promise) |
| 1 パッケージで実テスト | `pnpm --filter @rescript-tauri/core test` (既存 node_modules を再利用) |

実テストは core 1 件のみ実行し、他パッケージは構文チェックで担保。

## 6. 影響を受けるファイル一覧

```
新規:
  tools/vitest.shared.mjs

書き換え:
  packages/core/vitest.config.mjs
  packages/plugin-fs/vitest.config.mjs
  packages/plugin-dialog/vitest.config.mjs
  packages/plugin-shell/vitest.config.mjs
  packages/plugin-notification/vitest.config.mjs
  packages/plugin-log/vitest.config.mjs
  packages/plugin-os/vitest.config.mjs
  packages/schema/vitest.config.mjs

ドキュメント:
  docs/repository-structure.md (tools/ ディレクトリの追記)
  pnpm-workspace.yaml (tools/ を packages として登録する必要なし。ただの devtime ファイル)
```

## 7. 公開・配布上の注意

- `tools/` ディレクトリは monorepo root にあり、pnpm workspaces からは workspace パッケージとして登録されない (`pnpm-workspace.yaml` に追加しない)。
- 各パッケージの `package.json#files` (npm publish 対象) は変更しない。`vitest.config.mjs` は publish 対象外なので問題なし。
- import パスは monorepo root からの相対 (`../../tools/vitest.shared.mjs`)。これは monorepo の中で完結する。
