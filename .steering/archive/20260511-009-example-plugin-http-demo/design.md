# Design: examples/plugin-http-demo

| 項目 | 内容 |
|---|---|
| ステアリング番号 | 20260511-009 |
| 関連 | requirements.md / tasklist.md |
| 参考スタイル | `examples/plugin-fs-demo/`, `examples/plugin-dialog-demo/` |

## 1. ファイル一覧

```
examples/plugin-http-demo/
├── README.md                          # 使い方 + What it does
├── index.html                         # ボタン × 4 + result <pre>
├── package.json                       # workspace ":*" deps
├── rescript.json                      # rescript build 設定
├── src/
│   ├── App.res                        # demo 本体
│   └── main.mjs                       # entry (App.res.mjs を import)
└── src-tauri/
    ├── Cargo.toml                     # tauri-plugin-http = "2"
    ├── build.rs                       # tauri_build::build()
    ├── tauri.conf.json                # window 設定
    ├── capabilities/default.json      # http:default + scoped allow
    ├── icons/                         # plugin-fs-demo から流用
    └── src/main.rs                    # plugin(tauri_plugin_http::init())
```

## 2. デモ App.res 設計

`plugin-fs-demo` と同じ命名スタイル: `runStep1` / `runStep2` / `runStep3` / `runStep4` + `setResult` ヘルパ + `safe` ラッパで promise エラーを画面表示。

### Step 1 — Simple GET

```rescript
let runGet = async () => {
  let response: 'response =
    await PluginHttp.fetch("https://jsonplaceholder.typicode.com/users/1")
  let wrapped =
    (Obj.magic(response): {"json": unit => promise<'a>, "status": int})
  let status = wrapped["status"]
  let user = await wrapped["json"]()
  let name =
    (Obj.magic(user): {"name": string, "email": string})["name"]
  setResult(
    "GET ok\n  status = " ++ Int.toString(status) ++
    "\n  user.name = " ++ name,
  )
}
```

### Step 2 — POST with JSON body

```rescript
let runPost = async () => {
  let body = JSON.stringify(
    Dict.fromArray([
      ("title", JSON.string("rescript-tauri demo")),
      ("body", JSON.string("Hello from plugin-http-demo")),
      ("userId", JSON.number(1.0)),
    ])->JSON.object,
  )
  let response: 'response = await PluginHttp.fetch(
    "https://jsonplaceholder.typicode.com/posts",
    ~init={
      "method": "POST",
      "headers": {"content-type": "application/json"},
      "body": body,
    },
  )
  let wrapped = (Obj.magic(response): {"json": unit => promise<'a>, "status": int})
  let created = await wrapped["json"]()
  let id = (Obj.magic(created): {"id": float})["id"]
  setResult(
    "POST ok\n  status = " ++ Int.toString(wrapped["status"]) ++
    "\n  created.id = " ++ Float.toString(id),
  )
}
```

### Step 3 — clientOptions demo

```rescript
let runClientOptions = async () => {
  let response: 'response = await PluginHttp.fetch(
    "https://jsonplaceholder.typicode.com/posts/1",
    ~init={
      "connectTimeout": 5000,
      "maxRedirections": 0,
    },
  )
  let wrapped = (Obj.magic(response): {"status": int})
  setResult(
    "clientOptions ok\n  connectTimeout=5000 maxRedirections=0\n  status = " ++
    Int.toString(wrapped["status"]),
  )
}
```

### Step 4 — Headers & status

```rescript
let runHeaders = async () => {
  let response: 'response =
    await PluginHttp.fetch("https://jsonplaceholder.typicode.com/posts/1")
  let wrapped = (Obj.magic(response): {
    "status": int,
    "headers": {"get": string => Nullable.t<string>},
    "text": unit => promise<string>,
  })
  let contentType =
    wrapped["headers"]["get"]("content-type")->Nullable.toOption->Option.getOr("(missing)")
  let body = await wrapped["text"]()
  let preview = String.slice(body, ~start=0, ~end=60)
  setResult(
    "headers ok" ++
    "\n  status = " ++ Int.toString(wrapped["status"]) ++
    "\n  content-type = " ++ contentType ++
    "\n  body preview = " ++ preview ++ "...",
  )
}
```

## 3. index.html

```html
<h1>@rescript-tauri/plugin-http demo</h1>
<p>All operations target <code>jsonplaceholder.typicode.com</code> over HTTPS.</p>

<h2>Step 1 — Simple GET</h2>
<button id="btn-get">GET users/1</button>

<h2>Step 2 — POST</h2>
<button id="btn-post">POST posts</button>

<h2>Step 3 — clientOptions</h2>
<button id="btn-client-options">connectTimeout + maxRedirections</button>

<h2>Step 4 — Headers & status</h2>
<button id="btn-headers">read status + headers + text()</button>

<h2>Result</h2>
<pre id="result">(no action yet)</pre>
```

スタイルは `plugin-fs-demo/index.html` と統一。

## 4. capability 設定

```json
{
  "$schema": "../gen/schemas/desktop-schema.json",
  "identifier": "default",
  "description": "Default capability for the plugin-http demo",
  "windows": ["main"],
  "permissions": [
    "core:default",
    {
      "identifier": "http:default",
      "allow": [{"url": "https://jsonplaceholder.typicode.com/*"}]
    }
  ]
}
```

## 5. README.md 構成

`plugin-fs-demo/README.md` のスタイルを踏襲:

1. Title + Phase 2 status
2. Run locally (`pnpm install` + `pnpm tauri dev`)
3. What it does（4 step 表）
4. Why JSONPlaceholder（公開 mock REST API、無料、レート制限軽い、HTTPS 必須でない URL は使わない旨）
5. Capability tightening（dev 中の `**` から prod の scoped allow 移行ガイド）
6. See also（package README / sphinx user guide / upstream Tauri http plugin docs）

## 6. CI integration

`.github/workflows/examples-build.yml` に既存 `plugin-fs-demo` ブロック後に挿入:

```yaml
      - name: Build plugin-http-demo frontend
        run: pnpm --filter plugin-http-demo build
      - name: Cargo check on plugin-http-demo Rust side
        working-directory: examples/plugin-http-demo/src-tauri
        run: cargo check --release
```

## 7. ルート Cargo.toml 更新

```toml
[workspace]
members = [
  "examples/hello-world/src-tauri",
  "examples/ipc-typed/src-tauri",
  "examples/ipc-typed-with-schema/src-tauri",
  "examples/plugin-dialog-demo/src-tauri",
  "examples/plugin-fs-demo/src-tauri",
  "examples/plugin-http-demo/src-tauri",  # ← 追加
  "examples/plugin-shell-demo/src-tauri",
  "examples/streaming-ipc/src-tauri",
  "examples/window-management/src-tauri",
]
```

## 8. docs/repository-structure.md 更新

`examples/` ツリー部分に `plugin-http-demo/` を 1 行追記。Phase 2 群と並べる:

```
├── plugin-fs-demo/                  # Phase 2
├── plugin-dialog-demo/              # Phase 2
├── plugin-http-demo/                # Phase 2 (steering 009)
├── ipc-typed-with-schema/           # Phase 2 (Layer 3 demo)
```

## 9. sphinx-docs/user/plugin-http.md 更新

`## See also` 節の冒頭に live demo リンクを追加（plugin-fs.md と同じ位置）:

```
- Live demo:
  [`examples/plugin-http-demo`](https://github.com/Nagatatz/rescript-tauri/tree/main/examples/plugin-http-demo)
```

## 10. 検証戦略

- `node --check examples/plugin-http-demo/src/main.mjs` で entry の構文確認
- `pnpm --filter plugin-http-demo build` で rescript build 成功確認
- `cargo check --release` で Rust 側コンパイル成功確認（ローカル）
- workflow yaml の構文を `actionlint` or `yamllint`（任意）で確認

## 11. ロールバック条件

- jsonplaceholder URL の到達性が CI 環境（特に Windows runner）から異なれば、URL を README で動的に切り替えられる旨を案内
- cargo check が失敗 → tauri-plugin-http バージョン (`= "2"`) の固定で再確認
