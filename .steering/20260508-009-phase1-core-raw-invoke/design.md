# 設計: Phase 1 着手 — pnpm workspace + packages/core スケルトン + Core.Raw.invoke

| 項目 | 内容 |
|---|---|
| 関連 | `requirements.md` |
| 作成日 | 2026-05-08 |

## 1. 派生決定の確定（要承認）

requirements.md §4 に対し、本設計で以下を採用する:

| § | 採用 | 内容 |
|---|---|---|
| 4.1 バージョン pin | requirements.md 表どおり | rescript `^12.2.0`、@rescript/core `^1.6.0`、@tauri-apps/api `^2.11.0`（dev）、peerDeps は PRD §5.1 範囲 |
| 4.2 出力フォーマット | namespace + esmodule + `.res.mjs` + in-source | RFC §1.2 |
| 4.3 package.json | `type: module`, `main: ./src/Core.res.mjs` (暫定), `publishConfig.access: public` | RFC §1.2 / §8 |
| 4.4 テスト | 型レベル + vitest per-package | RFC §10 / functional-design §5 / §7 |
| 4.5 worktree | 必須、`phase1-core-raw-invoke` 名で作成 | steering-workflow.md |

## 2. ファイル構成（新規）

### 2.1 リポジトリルート

#### `package.json`

```json
{
  "name": "rescript-tauri-monorepo",
  "version": "0.0.0",
  "private": true,
  "type": "module",
  "description": "Monorepo root for rescript-tauri (private; not published)",
  "license": "MIT",
  "engines": {
    "node": ">=18",
    "pnpm": ">=9"
  },
  "scripts": {
    "build": "pnpm --recursive --if-present build",
    "clean": "pnpm --recursive --if-present run clean",
    "test": "pnpm --recursive --if-present test"
  },
  "devDependencies": {
    "@types/node": "^22.0.0"
  },
  "packageManager": "pnpm@10.28.1"
}
```

ルートは `private: true` で publish 対象外。共通 scripts は `pnpm --recursive` でワークスペース横断実行。`packageManager` フィールドで pnpm バージョンを固定（Corepack で自動取得）。

#### `pnpm-workspace.yaml`

```yaml
packages:
  - "packages/*"
  - "examples/*"
```

`examples/` は今回まだ存在しないが宣言だけ済ませる（`packages/*` のみでも OK だが、後で `examples/` を追加した時に変更不要）。

#### `.gitignore` 追記

既存 `.gitignore` に以下を追加（`pnpm` 関連の追加のみ、`node_modules/` `lib/` は既設）:

```gitignore
# pnpm lock cache (lockfile はコミット対象なので除外しない)
.pnpm-store/

# pnpm によるシムログ
.pnpm-debug.log*
```

`pnpm-lock.yaml` は **コミット対象**（再現可能ビルドのため）。

### 2.2 `packages/core/package.json`

```json
{
  "name": "@rescript-tauri/core",
  "version": "0.0.0",
  "description": "Production-ready ReScript bindings for @tauri-apps/api (Tauri 2.x)",
  "license": "MIT",
  "homepage": "https://github.com/Nagatatz/rescript-tauri",
  "repository": {
    "type": "git",
    "url": "git+https://github.com/Nagatatz/rescript-tauri.git",
    "directory": "packages/core"
  },
  "type": "module",
  "main": "./src/Core.res.mjs",
  "files": [
    "src/**/*.res",
    "src/**/*.resi",
    "src/**/*.res.mjs",
    "rescript.json",
    "README.md"
  ],
  "scripts": {
    "build": "rescript build",
    "clean": "rescript clean",
    "test": "rescript build && vitest run"
  },
  "peerDependencies": {
    "@rescript/core": ">=1.6.0",
    "@tauri-apps/api": "^2.0.0",
    "rescript": ">=12.0.0"
  },
  "devDependencies": {
    "@rescript/core": "^1.6.0",
    "@tauri-apps/api": "^2.11.0",
    "@types/node": "^22.0.0",
    "happy-dom": "^15.0.0",
    "rescript": "^12.2.0",
    "vitest": "^3.0.0"
  },
  "publishConfig": {
    "access": "public"
  },
  "engines": {
    "node": ">=18"
  }
}
```

`main` は **暫定的に `./src/Core.res.mjs`** を指す。`Tauri.res` を後続で導入する際に `./src/Tauri.res.mjs` に変更。

`files` は npm publish 時に同梱される対象。`.res` / `.resi` ソースも含めることで、利用側 ReScript ビルドが解釈できる（ReScript ライブラリの慣習）。

### 2.3 `packages/core/rescript.json`

```json
{
  "name": "@rescript-tauri/core",
  "version": "0.0.0",
  "namespace": true,
  "package-specs": [
    {
      "module": "esmodule",
      "in-source": true
    }
  ],
  "suffix": ".res.mjs",
  "sources": [
    {
      "dir": "src",
      "subdirs": true
    },
    {
      "dir": "tests",
      "type": "dev",
      "subdirs": true
    }
  ],
  "bs-dev-dependencies": [
    "@rescript/core"
  ],
  "dependencies": [
    "@rescript/core"
  ],
  "jsx": {
    "version": 4
  }
}
```

- `namespace: true` で `RescriptTauriCore.Core` の名前空間に置かれる
- `sources`: src は production、tests は dev
- ReScript 12 のキー: `dependencies` / `bs-dev-dependencies`（`bs-dev-dependencies` は legacy だが ReScript 12 でもまだ動作。`dev-dependencies` への切替は ReScript 公式 schema 確認後）
- `jsx.version: 4`（PRD §5.1）

> **Note**: `bs-dependencies` / `bs-dev-dependencies` の deprecation 状況は steering 002 で確認済み。ReScript 12 では `dependencies` を採用。`dev-dependencies` キーが正式かを実装時に再確認し、必要なら `bs-dev-dependencies` にフォールバック。

### 2.4 `packages/core/README.md`

短い「これは何？」+ 親 README / docs/ へのリンク（30〜50 行）:

```markdown
# @rescript-tauri/core

Production-ready ReScript bindings for Tauri 2.x's official JS SDK
(`@tauri-apps/api`). This is the **core** package of the rescript-tauri
monorepo.

> Status: Phase 1 — implementation in progress. Only `Core.Raw.invoke`
> is implemented at this commit; the rest of the API surface follows
> in subsequent steerings.

For project-wide context, see the [repository root README](../../README.md).
For the design rationale, see [docs/product-requirements.md](../../docs/product-requirements.md)
and [docs/functional-design.md](../../docs/functional-design.md) §2.

## Install (after Phase 1 release)

\`\`\`bash
pnpm add @rescript-tauri/core @tauri-apps/api
\`\`\`

Add `@rescript-tauri/core` to `dependencies` in your `rescript.json`.

## Usage

See the [Quick Start](../../sphinx-docs/user/quickstart.md) page for the
target API.
```

### 2.5 `packages/core/src/Core.res`

```rescript
module Raw = {
  type invokeOptions = {headers?: Dict.t<string>}

  @module("@tauri-apps/api/core")
  external invoke: (string, ~args: 'args=?, ~options: invokeOptions=?) => promise<'result> =
    "invoke"
}
```

実装は最小限。`@module` で `@tauri-apps/api/core` の `invoke` 関数を直接バインド。

### 2.6 `packages/core/src/Core.resi`

```rescript
module Raw: {
  /** Optional headers passed alongside the IPC call. */
  type invokeOptions = {headers?: Dict.t<string>}

  /** Calls a Tauri command on the Rust backend.

      This is the **Layer 1 (Raw)** binding — a near-1:1 mirror of
      `@tauri-apps/api/core`'s `invoke`. Use it when you want the
      lightest possible binding or as an escape hatch from the typed
      `Core.Command` layer.

      The return type is fully polymorphic; the caller is responsible
      for narrowing it via a type annotation. Promise rejection from
      the Rust side surfaces as a thrown `exn` when awaited, matching
      the JS API behavior exactly.

      See: https://v2.tauri.app/develop/calling-rust/

      ## Example

      ```rescript
      let greeting: string =
        await Tauri.Core.Raw.invoke("greet", ~args={"name": "World"})
      ```
  */
  let invoke: (string, ~args: 'args=?, ~options: invokeOptions=?) => promise<'result>
}
```

doc comment は `.claude/rules/code-comments.md` 準拠 (1〜2 文サマリ + Tauri 公式 URL + 例)。

### 2.7 `packages/core/tests/core_raw_signature.res`

```rescript
// 公開シンボル `Raw.invoke` を型注釈付きで参照することで、
// API 後方互換性のコンパイルチェックを実現する。
let _check_invoke_signature: (
  string,
  ~args: 'args=?,
  ~options: Core.Raw.invokeOptions=?,
) => promise<'result> = Core.Raw.invoke

// invokeOptions の型構造も参照しておく
let _check_invoke_options_type: Core.Raw.invokeOptions = {
  headers: ?None,
}
```

`packages/core/tests/runtime/` を別ディレクトリにすることで、ReScript 型レベルテストとは無関係にする (vitest はランタイム JS でのみ動く)。

### 2.8 `packages/core/tests/runtime/core_raw.test.mjs`

```javascript
import { describe, it, expect, beforeEach, afterEach, vi } from "vitest"

// In-test mocking helper. The full `Mocks` module follows in a later
// steering; for now we directly install a stub on
// globalThis.window.__TAURI_INTERNALS__.invoke.
const installMock = (handler) => {
  globalThis.window = globalThis.window ?? {}
  globalThis.window.__TAURI_INTERNALS__ = {
    invoke: handler,
  }
}

const clearMock = () => {
  if (globalThis.window) {
    delete globalThis.window.__TAURI_INTERNALS__
  }
}

describe("Core.Raw.invoke", () => {
  beforeEach(clearMock)
  afterEach(clearMock)

  it("calls window.__TAURI_INTERNALS__.invoke with the command name and args", async () => {
    const handler = vi.fn(async (cmd, args) => {
      expect(cmd).toBe("greet")
      expect(args).toEqual({ name: "ReScript" })
      return "hello, ReScript!"
    })
    installMock(handler)

    const { Raw } = await import("../../src/Core.res.mjs")
    const result = await Raw.invoke("greet", { name: "ReScript" })

    expect(handler).toHaveBeenCalledTimes(1)
    expect(result).toBe("hello, ReScript!")
  })

  it("propagates rejection as a thrown error when awaited", async () => {
    installMock(async () => {
      throw new Error("rust-side failure")
    })

    const { Raw } = await import("../../src/Core.res.mjs")
    await expect(Raw.invoke("any", {})).rejects.toThrow("rust-side failure")
  })
})
```

> **Note**: `@tauri-apps/api/core` の `invoke` の実装が `globalThis.window.__TAURI_INTERNALS__.invoke` を内部で呼び出す前提。これは Tauri 2.x の仕様であり、PRD Story 6-1 / RFC §10.2 と整合。実装上のディテール（呼び出し path）が異なる場合、test を最小限に修正する。

### 2.9 `packages/core/vitest.config.mjs`

```javascript
import { defineConfig } from "vitest/config"

export default defineConfig({
  test: {
    environment: "happy-dom",
    include: ["tests/runtime/**/*.test.mjs"],
  },
})
```

### 2.10 `.gitignore`（ルート、追記のみ）

既存 `.gitignore` に以下を追加（`node_modules/` / `lib/` は既設のため不要）:

```
.pnpm-store/
.pnpm-debug.log*
```

`pnpm-lock.yaml` は明示的にコミット対象（除外しない）。

## 3. コミット粒度

| # | コミット | 内容 |
|---|---|---|
| 1 | 📝 Add steering for 20260508-009 (phase1-core-raw-invoke) | ステアリング 3 ファイル配置 (main で実行) |
| 2 | ✨ Add pnpm workspace root for monorepo | ルート package.json + pnpm-workspace.yaml + .gitignore 追記 + pnpm-lock.yaml |
| 3 | ✨ Add packages/core scaffolding | packages/core/{package.json, rescript.json, README.md, src/(空), tests/(空), vitest.config.mjs} |
| 4 | ✨ Implement Core.Raw.invoke binding | packages/core/src/Core.res + Core.resi |
| 5 | ✅ Add type-level signature test for Core.Raw | packages/core/tests/core_raw_signature.res |
| 6 | ✅ Add vitest runtime test for Core.Raw.invoke | packages/core/tests/runtime/core_raw.test.mjs |
| 7 | 📝 Mark steering 20260508-009 complete (verify build/test) | tasklist 全 [x] 化 + 適用結果記録 |

`pnpm install` の lockfile 更新は commit 2 と commit 3 で発生する可能性。各コミットで `pnpm-lock.yaml` を含める。

## 4. worktree 運用

`steering-workflow.md` に従い `EnterWorktree(name="phase1-core-raw-invoke")` で隔離。

worktree 内のファイル絶対パス例:
```
/Users/ngtz/Documents/repos/rescript-tauri/.claude/worktrees/phase1-core-raw-invoke/packages/core/src/Core.res
```

steering 002 で経験した「Edit のパス指定ミス（main 側に書いてしまう）」を防ぐため、worktree 入った直後に `pwd` で確認、Edit/Write は必ず worktree 配下絶対パス。

## 5. テスト・検証戦略

### 5.1 各コミットでの最小検証

| コミット | 検証 |
|---|---|
| 2 (root) | `pnpm install` 成功 |
| 3 (scaffolding) | `pnpm --filter @rescript-tauri/core install` 成功、`rescript --version` で 12.2.0 確認 |
| 4 (Core.Raw 実装) | `pnpm --filter @rescript-tauri/core build` 成功、`src/Core.res.mjs` 生成確認 |
| 5 (型テスト) | 同上の build に tests も含まれ、型レベルテスト pass |
| 6 (vitest) | `pnpm --filter @rescript-tauri/core test` で型レベル + vitest 全 pass |
| 7 (完了) | 全 6 commits 後にまとめて `pnpm --recursive build && pnpm --recursive test` |

### 5.2 失敗時のリカバリ

3 回修正しても解決しない場合は `.claude/rules/testing.md` の自己検証フローに従いユーザーに報告。

## 6. リリース判定への影響

本ステアリング完了で `README.md` Visibility ブロックの 5 条件のうち #3（`@rescript-tauri/core` の最初の npm publish）に向けた **第一歩**。実 publish はまだ。

| visibility 切替条件 | 状態 |
|---|---|
| LICENSE | ✅ 既達 |
| CONTRIBUTING.md | ✅ 既達 |
| `@rescript-tauri/core` npm publish | ⏳ 進行中（本 steering で初コード） |
| `examples/*` 3 OS ビルド | ⏳ Phase 1 後半 |
| CI ワークフロー実体化 | ⏳ Phase 1 後半 |
