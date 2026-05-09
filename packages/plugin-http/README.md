# @rescript-tauri/plugin-http

ReScript bindings for [`@tauri-apps/plugin-http`](https://www.npmjs.com/package/@tauri-apps/plugin-http)
— Tauri 2.x's HTTP fetch plugin (a `fetch` that bypasses webview
CORS via the Rust side, with proxy / TLS configuration).

## Status

Phase 2+, first iteration. Awaiting first npm publish (`plugin-http-v0.1.0`).

100% coverage of the stable public surface of `@tauri-apps/plugin-http` v2.5.9.

## Install (planned)

```bash
pnpm add @rescript-tauri/plugin-http @rescript-tauri/core @tauri-apps/plugin-http @tauri-apps/api
```

## Quick example

```rescript
module Http = RescriptTauriPluginHttp.PluginHttp

let getJson = async () => {
  let response: 'response = await Http.fetch("https://api.example.com/data")
  // The `fetch` return type is polymorphic — annotate to fit your
  // call site or use Obj.magic to access Web Response methods.
  Console.log(response)
}

let postWithProxy = async () => {
  let init = {
    "method": "POST",
    "body": "payload",
    "proxy": {"all": "http://corp-proxy:8080"},
  }
  let _: 'response = await Http.fetch("https://api.example.com/data", ~init)
}
```

## Public API

| Symbol | Purpose |
|---|---|
| `fetch(input, ~init=?)` | Polymorphic Web-Fetch wrapper backed by Rust (bypasses webview CORS). `input` accepts `string` / `URL.t` / `Request`; `init` accepts `RequestInit & ClientOptions` |
| `proxy<'proxyValue>` | `{all?, http?, https?}` — `'proxyValue` is `string` (URL) or `proxyConfig` |
| `proxyConfig` | `{url, basicAuth?, noProxy?}` |
| `basicAuth` | `{username, password}` |
| `clientOptions<'proxyValue>` | `{maxRedirections?, connectTimeout?, proxy?, danger?}` |
| `dangerousSettings` | `{acceptInvalidCerts?, acceptInvalidHostnames?}` |

The Web Fetch API surface (`Request` / `Response` / `RequestInit`)
is intentionally not bound here — annotate at the call site or use
`Obj.magic` for advanced usage. The Tauri-specific options
(`proxy` / `clientOptions` / `dangerousSettings`) are typed
explicitly.

## Compatibility

| Component | Supported range |
|---|---|
| `@rescript-tauri/plugin-http` | this package |
| `@rescript-tauri/core` | `^0.1.0` (peer) |
| `@tauri-apps/plugin-http` | `^2.0.0` (peer) |
| `rescript` | `>=12.0.0` |
| `@rescript/core` | `>=1.6.0` |
| OS | Linux / macOS / Windows |

## See also

- [Changelog](./CHANGELOG.md)
- Upstream docs:
  [Tauri 2.x http plugin](https://v2.tauri.app/plugin/http-client/)
- [`@rescript-tauri/core` README](../core/README.md)
