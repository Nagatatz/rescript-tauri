# Requirements: examples/plugin-http-demo

| 項目 | 内容 |
|---|---|
| ステアリング番号 | 20260511-009 |
| パッケージ | `@rescript-tauri/plugin-http` の使用例 |
| 目的 | `examples/plugin-http-demo/` を新設し、`PluginHttp.fetch` の典型用法（GET / POST / clientOptions / headers & status）を動く形で示す。CI ゲート（examples-build.yml）にも組み込み、Linux / macOS / Windows で frontend build + `cargo check` をパスさせる |

## 背景

- `@rescript-tauri/plugin-http` は steering 058 で実装済み。ユーザーガイドは steering 20260511-007 で sphinx-docs に追加済み。
- Phase 2 add-on パッケージのうち、`plugin-fs` / `plugin-dialog` には `examples/` 配下に動作可能なデモが既にある（`examples/plugin-fs-demo/`, `examples/plugin-dialog-demo/`）。
- `examples/plugin-shell-demo/` も既に存在するが、`examples-build.yml` への組み込みは未完了（並列セッションで進行中）。本作業では plugin-http-demo のみを対象とする。
- `packages/plugin-http/CHANGELOG.md` で「Live demo は後続 sub-steering で追加」と明示されている。本 steering でその約束を回収する。

## スコープ

### In-scope

- 新規ディレクトリ: `examples/plugin-http-demo/`
- 4 ステップのデモ機能（GET / POST / clientOptions / headers&status）
- `package.json` / `rescript.json` / `tsconfig` / `tauri.conf.json` / `capabilities/default.json` / `Cargo.toml` / `src-tauri/src/main.rs` / `src-tauri/build.rs` / `index.html` / `src/App.res` / `src/main.mjs` / `README.md` / `icons/`（FS demo から流用可）
- ルート `Cargo.toml` の `workspace.members` に `examples/plugin-http-demo/src-tauri` を追加
- `.github/workflows/examples-build.yml` に `plugin-http-demo` の build + `cargo check` ステップを追加
- `docs/repository-structure.md` の `examples/` 一覧に `plugin-http-demo/` を追記
- `sphinx-docs/user/plugin-http.md` の See also 節に live demo へのリンクを追加
- `packages/plugin-http/CHANGELOG.md` の Unreleased セクションに「examples/plugin-http-demo added (steering 009)」を追記

### Out-of-scope

- 完全な Web Fetch API バインディング（`Request` / `Response` 型化）— `packages/plugin-http/CHANGELOG.md` の deferred 通り別 steering
- proxy / dangerousSettings の実 proxy / 自己署名証明書を用いた動作確認（ローカルで proxy を立てる必要があるため、デモは options 渡しの構文表示のみ）
- ja 翻訳 .po は触らない（別 sub-steering）

## デモ要件

### Step 1 — Simple GET

- `PluginHttp.fetch("https://jsonplaceholder.typicode.com/users/1")` で固定の public API から JSON 取得
- polymorphic `'response` を `Obj.magic` + inline structural type で `{json: unit => promise<'a>, status: int}` として扱う
- `status` と取得した `name` フィールドを画面に表示

### Step 2 — POST with JSON body

- `PluginHttp.fetch("https://jsonplaceholder.typicode.com/posts", ~init={...})` で `method: "POST"` + JSON ボディ
- `body: JSON.stringify(...)` + `headers: {"content-type": "application/json"}`
- レスポンスの `id` フィールド（jsonplaceholder が自動採番）を画面に表示

### Step 3 — clientOptions demo

- `connectTimeout: 5000` + `maxRedirections: 0` を `~init` に含めて GET
- 設定値が `~init` に展開されることを画面で示す（実際の timeout 挙動は環境依存なので、コード上で値が渡せていることを README で説明）

### Step 4 — Headers & status inspection

- レスポンスの `status` / `headers` / `text()` を順に取得
- inline structural type を使った wrap pattern を実演

## 非機能要件

- `pnpm --filter plugin-http-demo build` がローカルで成功
- `cargo check --release` が `examples/plugin-http-demo/src-tauri` 配下で成功
- ローカルで `pnpm tauri dev` を実行すると 4 つのボタンがすべて動作（jsonplaceholder への通信が前提）
- CI (`examples-build.yml`) の 3 OS（Linux / macOS / Windows）で build + cargo check がパス

## capability 設定

`examples/plugin-http-demo/src-tauri/capabilities/default.json`:

```json
{
  "permissions": [
    "core:default",
    {
      "identifier": "http:default",
      "allow": [
        {"url": "https://jsonplaceholder.typicode.com/*"}
      ]
    }
  ]
}
```

開発時のみ `**` 利用可能だが、本デモは固定 URL を使うため scoped に絞る。

## 受け入れ条件

- [ ] `examples/plugin-http-demo/` 一式が新規作成される
- [ ] 4 ステップが `src/App.res` で実装され、対応する button / 結果表示エリアが `index.html` に存在する
- [ ] ルート `Cargo.toml` の `workspace.members` に `examples/plugin-http-demo/src-tauri` が追加される
- [ ] `.github/workflows/examples-build.yml` に `plugin-http-demo` の build + cargo check ステップが追加される
- [ ] `docs/repository-structure.md` の `examples/` ツリー記載と表に `plugin-http-demo/` が反映される
- [ ] `sphinx-docs/user/plugin-http.md` の See also に live demo リンクが追加される
- [ ] `packages/plugin-http/CHANGELOG.md` の Unreleased に追記される
- [ ] ローカル `pnpm --filter plugin-http-demo build` が成功する
- [ ] ローカル `cargo check --release` が `examples/plugin-http-demo/src-tauri` で成功する
