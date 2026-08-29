# 設計: `@rescript-tauri/plugin-shell` 新規パッケージ

| 項目 | 内容 |
|---|---|
| 開発 ID | `20260509-051-plugin-shell` |
| 作成日 | 2026-05-09 |
| 関連 | `requirements.md` |

## 1. 全体構造

`packages/plugin-shell/src/PluginShell.res` の中で 3 つの sub-module を切る:

- **`Command`** モジュール: `Command<O>` クラス相当 + 4 種の static factory 関数。
- **`Child`** モジュール: `Child` クラス相当（pid / write / kill）。
- **`EventEmitter`** モジュール: stdout / stderr の `EventEmitter` 用ジェネリック helper。

トップレベルに型エイリアス (`spawnOptions` / `childProcess<'o>` / `terminatedPayload`) と `open` 関数を配置する。

## 2. 型定義

```rescript
type spawnOptions = {
  cwd?: string,
  env?: Dict.t<string>,
  encoding?: string,
}

type childProcess<'o> = {
  code: Nullable.t<int>,
  signal: Nullable.t<int>,
  stdout: 'o,
  stderr: 'o,
}

type terminatedPayload = {
  code: Nullable.t<int>,
  signal: Nullable.t<int>,
}
```

`IOPayload` (`string | Uint8Array`) はバインドしない — 各 `Command.t<'o>` の型変数 `'o` で表現する。

## 3. `Command` モジュール

```rescript
module Command: {
  /** Opaque command handle. `'o` is `string` for default encoding,
      `Uint8Array.t` for `encoding: "raw"`. */
  type t<'o>

  /** Creates a string-encoded command. The default upstream behavior. */
  let create: (string, ~args: array<string>=?, ~options: spawnOptions=?) => t<string>

  /** Creates a raw-bytes command (`encoding: "raw"`). The TypeScript
      conditional overload is split into a separate function so the
      `Uint8Array.t` return type stays static. */
  let createRaw: (
    string,
    ~args: array<string>=?,
    ~options: spawnOptions=?,
  ) => t<Uint8Array.t>

  /** Sidecar variant — looks up the program in the bundle's
      `tauri.conf.json > bundle > externalBin` list rather than PATH. */
  let sidecar: (string, ~args: array<string>=?, ~options: spawnOptions=?) => t<string>

  let sidecarRaw: (
    string,
    ~args: array<string>=?,
    ~options: spawnOptions=?,
  ) => t<Uint8Array.t>

  /** Spawns the command, returning a `Child.t` handle. */
  let spawn: t<'o> => promise<Child.t>

  /** Executes the command and waits for completion, returning the
      collected output. */
  let execute: t<'o> => promise<childProcess<'o>>

  /** Subscribes to the `close` event. The handler receives the
      `terminatedPayload` (exit code / signal). Returns `t` for
      chaining. */
  let onClose: (t<'o>, terminatedPayload => unit) => t<'o>

  /** Subscribes to the `error` event. The handler receives the error
      message string. Returns `t` for chaining. */
  let onError: (t<'o>, string => unit) => t<'o>

  /** Subscribes to the `stdout` event-emitter's `data` event. */
  let onStdoutData: (t<'o>, 'o => unit) => t<'o>

  /** Subscribes to the `stderr` event-emitter's `data` event. */
  let onStderrData: (t<'o>, 'o => unit) => t<'o>

  /** Removes all close / error listeners on the Command. */
  let removeAllListeners: t<'o> => t<'o>
}
```

`@module @scope @new` パターンで実装する:

```rescript
// Command.res 実装側
module Command = {
  type t<'o>

  @module("@tauri-apps/plugin-shell") @scope("Command")
  external create: (string, ~args: array<string>=?, ~options: spawnOptions=?) => t<string> =
    "create"

  @module("@tauri-apps/plugin-shell") @scope("Command")
  external _createRaw: (string, array<string>, spawnOptions) => t<Uint8Array.t> = "create"

  let createRaw = (program, ~args=[], ~options: spawnOptions={}) => {
    let withRaw: spawnOptions = {...options, encoding: "raw"}
    _createRaw(program, args, withRaw)
  }

  // 以下同様 ...
}
```

`createRaw` / `sidecarRaw` は `encoding: "raw"` を強制するため `_createRaw` 経由で実装。`{...options, encoding: "raw"}` で element override。

## 4. `Child` モジュール

```rescript
module Child: {
  type t

  /** Process id. */
  let pid: t => int

  /** Writes data to the child's stdin. Accepts `string`, `Uint8Array.t`,
      or `array<int>` (matching upstream `IOPayload | number[]`). */
  let write: (t, 'data) => promise<unit>

  /** Kills the child process. */
  let kill: t => promise<unit>
}
```

`write` の引数は polymorphic `'data` — TypeScript 上では `IOPayload | number[]` で 3 通り受け付けるが ReScript で union を表現する必要はない（呼び出し側がそれぞれ正しい型の値を渡せば良い）。

## 5. `EventEmitter` モジュール

EventEmitter の 9 method は generic helper として提供する:

```rescript
module EventEmitter: {
  /** EventEmitter from `@tauri-apps/plugin-shell`. `'event` is the
      named event key (typically a polymorphic-variant constant
      string). `'payload` is the payload type for that event. */
  type t<'events>

  /** Returns `t` for chaining. */
  let addListener: (t<'events>, string, 'payload => unit) => t<'events>
  let removeListener: (t<'events>, string, 'payload => unit) => t<'events>
  let on: (t<'events>, string, 'payload => unit) => t<'events>
  let once: (t<'events>, string, 'payload => unit) => t<'events>
  let off: (t<'events>, string, 'payload => unit) => t<'events>
  let removeAllListeners: (t<'events>, ~event: string=?) => t<'events>
  let listenerCount: (t<'events>, string) => int
  let prependListener: (t<'events>, string, 'payload => unit) => t<'events>
  let prependOnceListener: (t<'events>, string, 'payload => unit) => t<'events>
}
```

`Command.t<'o>` と stdout/stderr の `EventEmitter<{data: 'o}>` の関係を ReScript で扱うために、`Command.t<'o>` から内部の stdout/stderr accessor を提供する低位 API も用意する:

```rescript
@get external stdout: t<'o> => EventEmitter.t<{"data": 'o}> = "stdout"
@get external stderr: t<'o> => EventEmitter.t<{"data": 'o}> = "stderr"
```

これで上級ユーザーは `command->Command.stdout->EventEmitter.on("data", handler)` のように構成できる。

## 6. `open` 関数

```rescript
@module("@tauri-apps/plugin-shell")
external open: (string, ~openWith: string=?) => promise<unit> = "open"
```

ReScript の予約語ではないが、`open` は `pervasives` の `open` 構文と紛らわしい。`Open` モジュール経由か、シンボル名を変えて回避する。

```rescript
@module("@tauri-apps/plugin-shell")
external openPath: (string, ~openWith: string=?) => promise<unit> = "open"
```

→ **採用**: `openPath` という名前で公開（upstream `open` を ReScript 側で `openPath` にリネーム）。

## 7. パッケージ設定

### 7.1 `package.json`

`plugin-dialog` を雛形にして `name` / `description` / `peerDependencies` / `devDependencies` を `plugin-shell` 用に置換。`@tauri-apps/plugin-shell ^2.3.0` を peer に設定。

### 7.2 `rescript.json`

`name: "@rescript-tauri/plugin-shell"` 以外は `plugin-dialog` と同一。

### 7.3 `vitest.config.mjs`

`plugin-dialog` のものと同一（環境を `happy-dom` に固定）。

### 7.4 README / CHANGELOG

`plugin-dialog` 雛形を流用。Features 表で `Command` / `Child` / `open` を列挙。

## 8. テスト

### 8.1 型レベル (`plugin_shell_signature.res`)

各 export を型注釈付きで参照:
```rescript
let _check_open: (string, ~openWith: string=?) => promise<unit> = PluginShell.openPath
let _check_create: (string, ~args: array<string>=?, ~options: PluginShell.spawnOptions=?) => PluginShell.Command.t<string> = PluginShell.Command.create
let _check_create_raw: (string, ~args: array<string>=?, ~options: PluginShell.spawnOptions=?) => PluginShell.Command.t<Uint8Array.t> = PluginShell.Command.createRaw
// ... 全シンボル
```

### 8.2 ランタイム (`plugin_shell.test.mjs`)

`Mocks.mockIPC` で IPC コマンド名を検証:
- `openPath("https://example.com")` → `plugin:shell|open`
- `Command.create("echo", ~args=["hi"]).execute()` → `plugin:shell|execute`
- `Command.spawn` → `plugin:shell|spawn`
- `Child.write` → `plugin:shell|stdin_write`
- `Child.kill` → `plugin:shell|kill`

## 9. CI

### 9.1 専用 workflow

`.github/workflows/tests-plugin-shell-types.yml` と `tests-plugin-shell-runtime.yml` を `plugin-fs` 同等のテンプレートで新設。トリガー条件を `packages/plugin-shell/**` に絞る。

### 9.2 `tests-coverage.yml` matrix

```yaml
matrix:
  package: [core, schema, plugin-fs, plugin-dialog, plugin-shell]
```

## 10. 影響範囲

- 新設: `packages/plugin-shell/`
- 編集: `pnpm-workspace.yaml`（自動的に `packages/*` を吸収するので変更不要）
- 編集: `docs/repository-structure.md` §2.2
- 編集: `README.md` (root) — Packages 表に追加
- 編集: `tests-coverage.yml` matrix
- 新設: 2 ファイル `.github/workflows/tests-plugin-shell-{types,runtime}.yml`

他パッケージの API には変更を加えない。
