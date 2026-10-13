# 設計: Tauri 2.12 系への追従

## 1. 差分の洗い出し方法
bump 前後の `node_modules/@tauri-apps/*` から `.d.ts` を退避して `diff -ruN` を取り、コメント行を除いた
コード差分（86 行）を全件確認した。doc comment のみの変更（権限の remarks 追記等）は対象外。

## 2. バインディング変更

| パッケージ | upstream の変更 | 対応 |
|---|---|---|
| core / `App` | `exit(code?: number)` 追加 (2.12.0) | `App.exit: (~code: int=?) => promise<unit>` |
| core / `Window` | `setFullscreenOnMonitor(position: PhysicalPosition)` 追加 (2.12.0) | `Window.setFullscreenOnMonitor: (t, Dpi.PhysicalPosition.t) => promise<unit>` |
| core / `Window` | `Effect.LiquidGlassRegular` / `LiquidGlassClear` 追加 | `effectStyle` に `#liquidGlassRegular` / `#liquidGlassClear` |
| core / `Window` | `Effects.interactive?: boolean` 追加 | `effects.interactive?: bool` |
| core / `Window` `WebviewWindow` | `WindowOptions.noRedirectionBitmap?: boolean` 追加 | 両 `options` に `noRedirectionBitmap?: bool` |
| plugin-fs | `size(path, options?: SizeOptions)` (2.6.0) | `sizeOptions` 型追加、`size: (string, ~options: sizeOptions=?) => promise<float>` |
| plugin-shell | `SpawnOptions.processGroup?: boolean` (2.5.0) | `spawnOptions.processGroup?: bool` |
| plugin-notification | `onAction` の payload が `Options` → `ActionPerformed` (2.6.0) | `actionPerformed` 型追加、`onAction: (actionPerformed => unit) => ...`（破壊的変更） |
| plugin-notification | IPC `listChannels` → `list_channels` (2.5.0) | バインディング変更なし。テスト期待値のみ修正 |

対応しないもの（requirements の Non-goals 参照）: `Resource[Symbol.asyncDispose]`、`JsImage` alias、
`menu/base.d.ts` の内部 helper `prepareItem`、`Image.rgba` の戻り値型 `Uint8Array<ArrayBuffer>`（TS の型引数のみの変更）。

## 3. peerDependencies
dev 依存と lockfile は全パッケージ最新へ。peer 範囲は「古い upstream だと型は通るのに黙って誤動作する」ものだけ引き上げる。

| パッケージ | 旧 | 新 | 理由 |
|---|---|---|---|
| plugin-fs | `^2.5.0` | `^2.6.0` | 2.5.x は `size` の `baseDir` を無視し、別パスのサイズを返す |
| plugin-shell | `^2.3.0` | `^2.5.0` | 2.4.x 以前は `processGroup` を無視し、`kill` がツリーを止めない |
| plugin-notification | `^2.3.0` | `^2.6.0` | 2.5.x 以前は `onAction` に `Options` が渡り、`actionPerformed` 型と食い違う |

core の `@tauri-apps/api ^2.0.0` は据え置く。`App.exit` / `Window.setFullscreenOnMonitor` は古い upstream では
関数が存在せず即座に例外になる（黙って誤動作しない）ため、doc comment に必要バージョンを明記するに留める。
pre-1.0 のため互換 shim は付けない。

## 4. Rust 側 (Cargo.lock)
#93 の `Cargo.lock`（3 OS の CI で検証済み）を取り込み、その上で #93 作成後に出た plugin crate を
`cargo update -p` で最新化する（notification 2.6.0 / shell 2.5.0 / dialog 2.8.2 / http 2.8.2 / log 2.10.1 /
clipboard-manager 2.4.2）。JS 2.6.0 の `onAction` payload と shell の `processGroup` は Rust 側の同 minor が必要。
`cargo metadata --locked` で lock の整合のみローカル確認し、コンパイルは CI の `examples-build` に任せる。

## 5. compat-tauri-latest の拡張
`pnpm add @tauri-apps/api@latest` を 5 workspace に個別実行する方式をやめ、
`pnpm update --recursive --latest "@tauri-apps/*"` で全 workspace を一括更新し、
`pnpm --recursive build` / `pnpm --recursive test` を回す。これで plugin の IPC 改名のような破壊を nightly で検知できる。
新 API の「未バインド」検知は対象外（build / test では検知できないため、追従時に `.d.ts` 差分を取る運用とする）。

## 6. 本 PR と Dependabot PR の関係
本 PR は #85 / #93 の内容を包含する。マージ後、両 PR は Dependabot が自動 close する見込み。
