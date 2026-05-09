# Design: sphinx-docs Phase 2 sync

## 1. ディレクトリ・ファイル一覧

新規追加 (3 件) + 更新 (3 件):

```
sphinx-docs/user/
├── index.md                  # 更新: toctree + Phase 2 packages section
├── installation.md           # 更新: 3 パッケージのインストール例
├── configuration.md          # 更新: Plugin packages 表を実装済に
├── quickstart.md             # 変更なし (core API 中心)
├── changelog.md              # 変更なし
├── plugin-fs.md              # 新規
├── plugin-dialog.md          # 新規
└── schema.md                 # 新規
```

## 2. ページ別設計

### 2.1 `sphinx-docs/user/plugin-fs.md`

#### 構成

- 1 行サマリ (Tauri 2.x filesystem plugin の ReScript バインディング)
- Status (Phase 2 完了 / npm publish 待ち)
- Install
  - `pnpm add @rescript-tauri/plugin-fs @tauri-apps/plugin-fs`
  - Rust 側 `tauri-plugin-fs = "2"` + `tauri::Builder::plugin(tauri_plugin_fs::init())`
- Capabilities
  - `core:default` + `fs:default` + `fs:allow-app-local-data-recursive`
    (デモ準拠)
  - 他のサブツリーを使う場合のヒント
- Minimal example (3 行レベル)
  ```rescript
  open RescriptTauriPluginFs

  let baseDir = PluginFs.BaseDirectory.appLocalData
  await PluginFs.writeTextFile("notes.txt", "hi", ~options={baseDir: baseDir, create: true})
  let body = await PluginFs.readTextFile("notes.txt", ~options={baseDir: baseDir})
  ```
- API 表（公開 14 関数の 1 行ずつ）
- 落とし穴
  - 単一フィールド record の punning が block と解釈される
    （`{baseDir}` ではなく `{baseDir: baseDir}`）
  - `Uint8Array.length` は `TypedArray.length` 経由
- Compatibility table (peer deps + supported OS)
- See also: `examples/plugin-fs-demo/`

#### 入出力 1 行サンプル

`writeTextFile` / `readTextFile` を最小に。`Uint8Array.fromArray` の
バイナリパスは "binary" 節で別途。

### 2.2 `sphinx-docs/user/plugin-dialog.md`

#### 構成

- 1 行サマリ (native dialog plugin の ReScript バインディング)
- Status
- Install
  - `pnpm add @rescript-tauri/plugin-dialog @tauri-apps/plugin-dialog`
  - Rust 側 `tauri-plugin-dialog = "2"` + plugin init
- Capabilities (`dialog:default`)
- Minimal example
  ```rescript
  open RescriptTauriPluginDialog

  let path = await PluginDialog.openFile(~options={
    title: "Pick a file",
    filters: [{name: "Text", extensions: ["txt", "md"]}],
  })
  switch path->Nullable.toOption {
  | Some(p) => Console.log("picked: " ++ p)
  | None => Console.log("cancelled")
  }
  ```
- 4-way `open` 分割の経緯 (条件型 → 静的化)
- 公開 8 関数表
- Compatibility table
- See also: `examples/plugin-dialog-demo/`

### 2.3 `sphinx-docs/user/schema.md`

#### 構成

- 1 行サマリ (Layer 3 typed IPC via rescript-schema)
- Status
- Install
  - `pnpm add @rescript-tauri/schema rescript-schema`
- Why Layer 3? (Layer 2 との対比 — `Core.Command.make` の手書き
  encoder/decoder vs `Schema.fromSchemas` の宣言的記述)
- Minimal example
  ```rescript
  open RescriptTauriSchema

  let greet = Schema.fromSchemas(
    ~name="greet",
    ~args=Schema.S.object(s => {name: s.field("name", Schema.S.string)}),
    ~result=Schema.S.string,
  )

  switch await greet->Core.Command.invoke({name: "ReScript"}) {
  | Ok(message) => Console.log(message)
  | Error(DecodeError(msg)) => Console.error("decode failed: " ++ msg)
  | Error(RustError(json)) => Console.error2("rust error:", json)
  }
  ```
- 行数比較表（同等の `Core.Command.make` 版と並列）
- `channelFromSchema` / `eventFromSchema` / `toDecoder` の用途
- rescript-schema の DSL 注意点
  - `s.field("name", S.string)` がメソッド呼び出し記法
- Compatibility table (rescript-schema 9.x peer)
- See also: `examples/ipc-typed-with-schema/`

### 2.4 `sphinx-docs/user/index.md`

既存 "Modules at a glance" 直後に新セクションを挿入:

```markdown
## Phase 2 packages

Phase 2 introduces three add-on packages that build on the Phase 1
core. Each one ships independently and pulls the matching upstream
plugin / schema library through `peerDependencies`.

| Package | Purpose | Guide |
|---|---|---|
| `@rescript-tauri/plugin-fs` | Filesystem operations (read/write/dir/stat) | [plugin-fs](plugin-fs.md) |
| `@rescript-tauri/plugin-dialog` | Native dialogs (open / save / message / ask / confirm) | [plugin-dialog](plugin-dialog.md) |
| `@rescript-tauri/schema` | Layer 3 typed IPC via rescript-schema | [schema](schema.md) |
```

`{toctree}` に 3 ページを追加:

```markdown
```{toctree}
:hidden:
:maxdepth: 2

installation
quickstart
configuration
plugin-fs
plugin-dialog
schema
changelog
```
```

### 2.5 `sphinx-docs/user/installation.md`

"Install (planned, post Phase 1 release)" セクションに Phase 2
パッケージのスニペットを追加:

```markdown
### Phase 2 add-on packages

Each Phase 2 package is published independently. Install them as
needed alongside the matching upstream plugin / schema library:

```bash
# Filesystem
pnpm add @rescript-tauri/plugin-fs @tauri-apps/plugin-fs

# Native dialogs
pnpm add @rescript-tauri/plugin-dialog @tauri-apps/plugin-dialog

# Layer 3 typed IPC (rescript-schema)
pnpm add @rescript-tauri/schema rescript-schema
```

See the [plugin-fs](plugin-fs.md), [plugin-dialog](plugin-dialog.md),
and [schema](schema.md) guides for the matching ReScript / Rust /
capability setup.
```

### 2.6 `sphinx-docs/user/configuration.md`

末尾の "Plugin packages (Phase 2+)" 表を更新:

```markdown
## Phase 2 add-on packages

Phase 2 ships three add-on packages, each independently versioned
and published. They declare both `@rescript-tauri/core` and the
matching upstream library as `peerDependencies`.

| Package | Upstream peer | Status | Guide |
|---|---|---|---|
| `@rescript-tauri/plugin-fs` | `@tauri-apps/plugin-fs ^2.5.0` | Phase 2 implementation merged; `plugin-fs-v0.1.0` npm publish pending | [plugin-fs](plugin-fs.md) |
| `@rescript-tauri/plugin-dialog` | `@tauri-apps/plugin-dialog ^2.7.0` | Phase 2 implementation merged; `plugin-dialog-v0.1.0` npm publish pending | [plugin-dialog](plugin-dialog.md) |
| `@rescript-tauri/schema` | `rescript-schema ^9.0.0` | Phase 2 implementation merged; `schema-v0.1.0` npm publish pending | [schema](schema.md) |
```

## 3. クロスリンクと toctree

新規 3 ページは `sphinx-docs/user/` 直下に置き、`user/index.md` の
`toctree` から到達できるようにする。

`sphinx-docs/index.md` の Quick Links は Phase 1 リンクのみで
維持しても差し支えない（最上段の grid card で User Guide ↔ Dev
Guide に分岐させているため）。Should スコープとして必要なら
Phase 2 ページもショートカットに追加。

## 4. MyST 構文の使用

各ページで使う directive を最小に絞る:

- `{note}` (callout) — Status コールアウト
- `{toctree}` — index.md のみ
- fenced code blocks (` ```rescript `, ` ```bash `, ` ```json `, ` ```rust `)
- 標準 markdown table

未使用にする directive: `{tab-set}`, `{grid}` 等の高度なもの
(theme 依存のため安全側で見送る)。

## 5. 検証手順

uv / sphinx-build が無いため build 検証は省略。代替検証:

1. すべての markdown を text-check (タブ無し / 必要な heading 階層)。
2. 内部リンクが既存ファイル / 新規 3 ファイルに解決すること
   (grep で確認)。
3. `examples/<demo>` への外部リンクが正しい GitHub URL であること
   (既存ページのフォーマットに合わせる)。
4. `pnpm --recursive build` / `pnpm --recursive test` で
   regression が無いこと（実コード未変更のため自動的に通る）。

## 6. 翻訳 (`.po`) の扱い

本 steering では英語ソースのみ追加。`.po` 再生成は次のとおり別途
実施を想定:

```bash
cd sphinx-docs
make install         # uv sync
make gettext         # .pot 生成
make update-po       # locale/ja/LC_MESSAGES/user/<new>.po を生成
```

tasklist にこの未実施項目を「Should スコープ for follow-up
steering」として明記する。日本語サイトのビルドはこの間も既存ページ
のみで成立する。

## 7. リスクと対応

| リスク | 対応 |
|---|---|
| Sphinx ビルド未検証 | 標準 MyST directive のみ使用 + 既存ページの構造を踏襲 |
| 日本語翻訳の遅延 | tasklist に follow-up steering を明記 |
| linkcheck の失敗（GitHub URL が private repo の場合 404） | 既存 conf.py の `linkcheck_ignore` で対応済 |
| examples/<demo> パス変更による参照崩れ | 既存 examples README の URL に合わせる |
