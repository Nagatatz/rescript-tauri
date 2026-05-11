# `@rescript-tauri/plugin-http`

ReScript bindings for the [Tauri 2.x HTTP fetch
plugin](https://v2.tauri.app/plugin/http-client/) — a Web Fetch
API wrapper that routes through the Rust side to bypass webview
CORS, plus typed proxy / TLS configuration. The 100% stable
public surface of `@tauri-apps/plugin-http` v2.5.9 is covered.

```{note}
The Phase 2 implementation is feature-complete in `main`. The
first npm publish (`plugin-http-v0.1.0`) is scheduled alongside
the other Phase 2 packages. Until then, consume
`@rescript-tauri/plugin-http` via the source repository or a
workspace link.
```

## Install

```bash
pnpm add @rescript-tauri/plugin-http @tauri-apps/plugin-http
```

`@rescript-tauri/plugin-http` declares both
`@rescript-tauri/core` and `@tauri-apps/plugin-http` as
`peerDependencies`, so you control each upstream version.

Add the package to `dependencies` in your `rescript.json`:

```json
{
  "dependencies": [
    "@rescript-tauri/core",
    "@rescript-tauri/plugin-http"
  ]
}
```

On the Rust side, add the plugin crate and register it on the
builder:

```toml
# src-tauri/Cargo.toml
[dependencies]
tauri-plugin-http = "2"
```

```rust
// src-tauri/src/main.rs
fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_http::init())
        .run(tauri::generate_context!())
        .expect("error while running app");
}
```

Allowed origins are not configured in `tauri.conf.json` —
Tauri 2.x routes them through the capability layer covered in
the next section.

## Capabilities

Tauri 2.x requires every plugin permission to be granted
explicitly. Combine `http:default` (allows the `fetch` API) with
a scoped `allow` list that pins the URLs your app may reach:

```json
{
  "$schema": "../gen/schemas/desktop-schema.json",
  "identifier": "default",
  "windows": ["main"],
  "permissions": [
    "core:default",
    {
      "identifier": "http:default",
      "allow": [{ "url": "https://api.example.com/*" }]
    }
  ]
}
```

The scoped `allow` array is a positive list — any URL not
matched is rejected at the Rust boundary, independent of CORS.
Use `**` only in development; production capabilities should
enumerate every host the app talks to.

## Minimal example

```rescript
open RescriptTauriPluginHttp

let getUsers = async () => {
  let response: 'response =
    await PluginHttp.fetch("https://api.example.com/users")
  // The return value is the DOM Response. Use Obj.magic (or an
  // inline object type) to access .json() / .status / etc.
  let r = (Obj.magic(response): {"json": unit => promise<'json>, "status": int})
  if r["status"] === 200 {
    let body = await r["json"]()
    Console.log(body)
  }
}
```

A POST with Tauri-specific options (proxy, custom timeout) looks
much the same — pass `~init` as a JS object literal:

```rescript
let postWithProxy = async () => {
  let _: 'response = await PluginHttp.fetch(
    "https://api.example.com/events",
    ~init={
      "method": "POST",
      "headers": {"content-type": "application/json"},
      "body": Js.Json.stringify(Js.Json.object_(Js.Dict.empty())),
      "proxy": {"all": "http://corp-proxy:8080"},
      "connectTimeout": 5000,
    },
  )
}
```

## Public API

`PluginHttp` exposes a single `fetch` function plus five record
types covering the Tauri-specific options:

| Symbol | Purpose |
|---|---|
| `fetch(input, ~init=?)` | Polymorphic Web-Fetch wrapper backed by Rust (bypasses webview CORS). `input` accepts `string` / `URL.t` / `Request`; `init` accepts `RequestInit & ClientOptions` |
| `proxy<'proxyValue>` | `{all?, http?, https?}` — `'proxyValue` is `string` (URL) or `proxyConfig` per slot |
| `proxyConfig` | `{url, basicAuth?, noProxy?}` |
| `basicAuth` | `{username, password}` — forwarded as `Proxy-Authorization` |
| `clientOptions<'proxyValue>` | `{maxRedirections?, connectTimeout?, proxy?, danger?}` |
| `dangerousSettings` | `{acceptInvalidCerts?, acceptInvalidHostnames?}` (off by default) |

### `fetch` signature

```rescript
let fetch: ('input, ~init: 'init=?) => promise<'response>
```

All three of `'input`, `'init`, and `'response` are polymorphic
on purpose:

- **`'input`** — typically `string`, `URL.t`, or a `Request`
  instance. ReScript infers the type from the call site, so
  passing a `string` literal works without an explicit
  annotation.
- **`'init`** — a `RequestInit & ClientOptions` shape. In
  practice you pass a JS object literal (`{"method": "POST",
  ...}`) that includes both standard `RequestInit` fields
  (`method`, `headers`, `body`, `signal`, …) and the
  Tauri-specific `clientOptions` fields documented below.
- **`'response`** — the DOM `Response`. The DOM type isn't
  bound here; see the *Pitfalls* section for the three idioms
  that work.

### `clientOptions` fields

| Field | Type | Purpose |
|---|---|---|
| `maxRedirections` | `int` (optional) | Maximum redirects to follow. `0` disables following entirely. |
| `connectTimeout` | `int` (optional) | Connect timeout in milliseconds. |
| `proxy` | `proxy<'proxyValue>` (optional) | Proxy specification per URL scheme. |
| `danger` | `dangerousSettings` (optional) | Dangerous TLS settings (off by default). |

### `proxy` / `proxyConfig` / `basicAuth`

`proxy<'proxyValue>` selects which traffic each slot covers,
parametric on a single `'proxyValue` type that is either a plain
URL `string` or a full `proxyConfig` record:

```rescript
// URL-only form: pass strings for every slot
let init = {"proxy": {"all": "http://corp-proxy:8080"}}

// Full ProxyConfig with auth and bypass list
let init = {
  "proxy": {
    "https": {
      "url": "http://corp-proxy:8443",
      "basicAuth": {"username": "alice", "password": "s3cret"},
      "noProxy": "localhost,*.internal",
    },
  },
}
```

`proxyConfig.noProxy` accepts the upstream comma-separated host
pattern syntax (`localhost`, `*.internal`, `192.168.0.0/16`,
etc.).

### `dangerousSettings`

```rescript
let init = {
  "danger": {
    "acceptInvalidCerts": true,
    "acceptInvalidHostnames": true,
  },
}
```

`acceptInvalidCerts` skips SSL/TLS certificate verification;
`acceptInvalidHostnames` skips the cert's hostname check. Both
default to `false` — opt in only for self-signed certs in a
development build, internal staging, or mTLS experiments. **Do
not enable either in shipped production code.**

## Pitfalls

### DOM Web Fetch types are intentionally unbound

The DOM `Request` / `Response` / `RequestInit` types live in
`@rescript/core`'s sparse Web Fetch surface, which doesn't cover
the streaming / progress / clone APIs the plugin exposes. Rather
than ship a partially-typed binding, `fetch` is left polymorphic
and the call site picks a strategy:

1. **Type annotation** — when you already have a concrete
   record-or-object type that captures the fields you touch:

   ```rescript
   type apiResponse = {"ok": bool, "status": int}
   let r: apiResponse =
     Obj.magic(await PluginHttp.fetch("https://api.example.com"))
   ```

2. **`Obj.magic` + inline structural type** — the minimum-cost
   path, useful when you only need a couple of fields:

   ```rescript
   let r =
     (Obj.magic(
       await PluginHttp.fetch("https://api.example.com"),
     ): {"json": unit => promise<'a>})
   ```

3. **External binding** — for repeated access, wrap the surface
   you actually use behind a `@send` / `@get` external block in
   your own module.

A typed Web Fetch surface is deferred to a follow-up
sub-steering (see the package CHANGELOG).

### `proxy<'proxyValue>` takes a single type parameter

Because `proxy<'proxyValue>` has one type variable shared across
the `all` / `http` / `https` slots, mixing a `string` URL in one
slot with a full `proxyConfig` record in another is a type error
when you build the record with the `~init` ReScript record
syntax. Two workarounds:

- **Unify the type**: wrap every slot in `proxyConfig`, even when
  you only need a URL.
- **Use a JS object literal**: object literals don't enforce the
  type parameter, so a mixed `{"http": "http://...", "https":
  {"url": "https://...", "basicAuth": …}}` shape is accepted as
  `'init`.

### `dangerousSettings` ships disabled

If you omit `danger` from `init`, both checks stay on by
default. The plugin's Tauri-level capability layer cannot
re-enable them — only an explicit `init.danger` record can. This
keeps secure-by-default behaviour visible at the call site.

## Compatibility

| Component | Supported range |
|---|---|
| Upstream `@tauri-apps/plugin-http` | `^2.0.0` (peer) |
| Rust `tauri-plugin-http` | `2.x` |
| `@rescript-tauri/core` | `^0.1.0` (peer) |
| ReScript | `>=12.0.0` |
| `@rescript/core` | `>=1.6.0` |
| OS | Linux / macOS / Windows |

## See also

- Source:
  [`packages/plugin-http`](https://github.com/Nagatatz/rescript-tauri/tree/main/packages/plugin-http)
- Package README:
  [`packages/plugin-http/README.md`](https://github.com/Nagatatz/rescript-tauri/blob/main/packages/plugin-http/README.md)
- Upstream docs:
  [Tauri 2.x http plugin](https://v2.tauri.app/plugin/http-client/)
- Upstream JS reference:
  [http module](https://v2.tauri.app/reference/javascript/http/)
