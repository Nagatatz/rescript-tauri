# 要件定義: `@rescript-tauri/plugin-shell` 新規パッケージ

| 項目 | 内容 |
|---|---|
| 開発 ID | `20260509-051-plugin-shell` |
| 作成日 | 2026-05-09 |
| 関連 | `docs/product-requirements.md` §284（Phase 2+ Could）, `docs/repository-structure.md` §2.2 |

## 1. 背景

PRD §284 で Phase 2+ Could 優先度として位置付けられている `@tauri-apps/plugin-*` シリーズのうち、`plugin-shell` を最初に取り上げる。`plugin-shell` は Tauri アプリから外部プロセスを spawn / execute、URL や files を OS デフォルトアプリで open するための公式プラグイン (`@tauri-apps/plugin-shell` v2.3.5)。

開発ニーズの高さと API 表面の規模感（277 行 / 約 25 シンボル）が手頃であり、既存の `plugin-fs` / `plugin-dialog` パッケージとほぼ同じプロセスで仕上げられる。

## 2. ゴール

- `@tauri-apps/plugin-shell` v2.3.5 の **stable public surface 100%** をカバーする `@rescript-tauri/plugin-shell` 独立パッケージを `packages/plugin-shell/` に新設する。
- 既存の `plugin-fs` / `plugin-dialog` と同じ:
  - パッケージレイアウト (`src/PluginShell.res / .resi`, `tests/plugin_shell_signature.res`, `tests/runtime/plugin_shell.test.mjs`)
  - 命名規約・ドキュメントスタイル
  - peerDependencies 戦略
  - CI 専用ジョブ（`tests-plugin-shell-types.yml` / `tests-plugin-shell-runtime.yml`）
- Layer 1 互換: 公式 `Command` クラス・`open` 関数・`Child` クラスを忠実にバインドする。
- 型レベルテストとランタイム vitest テストを各シンボルに用意。

## 3. 非ゴール

- **本作業では追加 helper / 高位ラッパーを作らない**（PRD §284 "Could" — 直接バインドの最小実装）。
- 後続イテレーションへ分離:
  - `examples/plugin-shell-demo/` 例題（後続 sub-steering）
  - sphinx-docs `user/plugin-shell.md` ページ（リリース前にまとめて整備）
- `Command` の TypeScript 条件型 overload (`encoding: 'raw'`) は `plugin-dialog.open` と同じパターンで **関数を分割**して静的化（`Command.create` / `Command.createRaw`）。

## 4. 対象 API

### 4.1 関数

| 識別子 | TypeScript シグネチャ | ReScript シグネチャ |
|---|---|---|
| `open` | `(path: string, openWith?: string) => Promise<void>` | `open: (string, ~openWith: string=?) => promise<unit>` |

### 4.2 `Command` クラス

| 識別子 | 種別 | ReScript 表現 |
|---|---|---|
| `Command.create` (string) | static factory | `Command.create: (string, ~args: array<string>=?, ~options: spawnOptions=?) => Command.t<string>` |
| `Command.create` (raw) | static factory | `Command.createRaw: (string, ~args: array<string>=?, ~options: spawnOptions=?) => Command.t<Uint8Array.t>` |
| `Command.sidecar` (string) | static factory | `Command.sidecar: ...` |
| `Command.sidecar` (raw) | static factory | `Command.sidecarRaw: ...` |
| `command.spawn()` | instance | `Command.spawn: Command.t<'o> => promise<Child.t>` |
| `command.execute()` | instance | `Command.execute: Command.t<'o> => promise<childProcess<'o>>` |
| `command.on('close', cb)` | event | `Command.onClose: (Command.t<'o>, terminatedPayload => unit) => Command.t<'o>` |
| `command.on('error', cb)` | event | `Command.onError: (Command.t<'o>, string => unit) => Command.t<'o>` |
| `command.stdout.on('data', cb)` | event | `Command.onStdoutData: (Command.t<'o>, 'o => unit) => Command.t<'o>` |
| `command.stderr.on('data', cb)` | event | `Command.onStderrData: (Command.t<'o>, 'o => unit) => Command.t<'o>` |
| EventEmitter 全 method | event | `EventEmitter.{on, once, off, addListener, removeListener, removeAllListeners, listenerCount, prependListener, prependOnceListener}` を提供 |

### 4.3 `Child` クラス

| 識別子 | 種別 |
|---|---|
| `child.pid` | accessor |
| `child.write(data)` | instance |
| `child.kill()` | instance |

### 4.4 型

| 識別子 | 形 |
|---|---|
| `spawnOptions` | `{cwd?: string, env?: Dict.t<string>, encoding?: string}` |
| `childProcess<'o>` | `{code: Nullable.t<int>, signal: Nullable.t<int>, stdout: 'o, stderr: 'o}` |
| `terminatedPayload` | `{code: Nullable.t<int>, signal: Nullable.t<int>}` |
| `ioPayload` | TypeScript の `string \| Uint8Array` は **`Command.t` の `'o` 型変数で表現** — 別 alias を作らない |

## 5. パッケージ構成

```
packages/plugin-shell/
├── src/
│   └── PluginShell.res / .resi
├── tests/
│   ├── plugin_shell_signature.res
│   └── runtime/
│       └── plugin_shell.test.mjs
├── package.json
├── rescript.json
├── vitest.config.mjs
├── README.md
└── CHANGELOG.md
```

`peerDependencies`:
```json
{
  "@rescript-tauri/core": "^0.1.0",
  "@tauri-apps/plugin-shell": "^2.3.0",
  "rescript": ">=12.0.0",
  "@rescript/core": ">=1.6.0"
}
```

## 6. テスト要件

- **型レベル**: `plugin_shell_signature.res` に全公開シンボルへの型注釈付き呼び出しを記述。
- **ランタイム**: `Mocks.mockIPC` 経由で:
  - `Command.execute` が IPC 経由で `plugin:shell|*` 系コマンドを発行
  - `Command.spawn` が `Child.t` を返す
  - `open` が `plugin:shell|open` を呼び出す
  - `Child.write` / `Child.kill` がそれぞれ正しい IPC コマンドを発行

## 7. CI

`packages/plugin-fs` / `plugin-dialog` と同じく:
- `.github/workflows/tests-plugin-shell-types.yml`（型レベル）
- `.github/workflows/tests-plugin-shell-runtime.yml`（vitest）
- `tests-coverage.yml` の matrix に `plugin-shell` を追加

## 8. リスク

- **EventEmitter 9 method の一括バインド**: 上流 EventEmitter は名前付きイベントごとに型が違う (`close: TerminatedPayload`, `error: string`)。ReScript で型安全に表現するため、`Command.onClose` / `onError` のような専用関数 + 汎用 `EventEmitter.removeAllListeners` 等の hybrid アプローチを採る。
- **conditional return の overload**: `Command.create(_, _, {encoding: 'raw'})` だけ戻り値が `Uint8Array` になる。`plugin-dialog.openFile / openFiles` と同じパターンで関数分割。

## 9. 完了条件

- 上記 API 群すべての binding 追加（合計約 **20 関数 + 4 型**）。
- `pnpm --workspace-concurrency 1 --recursive build` 成功。
- `pnpm --workspace-concurrency 1 --recursive test` 全件 pass（既存 60 件 + plugin-shell 新規分）。
- 新パッケージの `README.md` / `CHANGELOG.md` を Phase 1 リリースに揃えた書式で配置。
- `docs/repository-structure.md` §2.2 に `plugin-shell/` セクション追記。
- 専用 CI ジョブ 2 件追加 + `tests-coverage.yml` matrix に追加。
