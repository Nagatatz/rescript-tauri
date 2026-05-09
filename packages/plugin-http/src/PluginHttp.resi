/** Bindings for `@tauri-apps/plugin-http` (Tauri 2.x HTTP fetch
    plugin).

    Phase 2+ first iteration: 100% coverage of the stable public
    surface of `@tauri-apps/plugin-http` v2.5.9 — a Web-Fetch wrapper
    that routes through the Rust side to bypass webview CORS, plus
    Tauri-specific proxy / TLS configuration types.

    The DOM Fetch API surface (`Request` / `Response` / `RequestInit`)
    is intentionally not bound; use polymorphic types and annotate at
    the call site or fall back to `Obj.magic` for advanced cases.

    See: https://v2.tauri.app/plugin/http-client/
*/

/** HTTP basic auth credentials forwarded as the `Proxy-Authorization`
    header. */
type basicAuth = {
  username: string,
  password: string,
}

/** Full proxy configuration (URL plus optional auth and bypass list).

    See: https://v2.tauri.app/reference/javascript/http/#proxyconfig
*/
type proxyConfig = {
  /** URL of the proxy server. */
  url: string,
  /** Optional basic-auth credentials. */
  basicAuth?: basicAuth,
  /** Comma-separated list of host patterns to bypass the proxy. */
  noProxy?: string,
}

/** Proxy specification for one or more URL schemes. The
    `'proxyValue` type parameter accepts either a `string` URL or
    a full `proxyConfig` record (matching the upstream
    `string | ProxyConfig` union per slot).

    See: https://v2.tauri.app/reference/javascript/http/#proxy
*/
type proxy<'proxyValue> = {
  /** Proxy all traffic to the given URL / config. */
  all?: 'proxyValue,
  /** Proxy HTTP traffic only. */
  http?: 'proxyValue,
  /** Proxy HTTPS traffic only. */
  https?: 'proxyValue,
}

/** Dangerous TLS settings (disabled by default).

    See: https://v2.tauri.app/reference/javascript/http/#dangeroussettings
*/
type dangerousSettings = {
  /** Disables SSL/TLS certificate verification. */
  acceptInvalidCerts?: bool,
  /** Disables hostname verification. */
  acceptInvalidHostnames?: bool,
}

/** Tauri-specific options passed to `fetch` via the `init` argument.

    See: https://v2.tauri.app/reference/javascript/http/#clientoptions
*/
type clientOptions<'proxyValue> = {
  /** Max redirects to follow. `0` disables following redirects. */
  maxRedirections?: int,
  /** Connect timeout in milliseconds. */
  connectTimeout?: int,
  /** Proxy configuration (one URL or full `proxyConfig` per slot). */
  proxy?: proxy<'proxyValue>,
  /** Dangerous TLS settings (off by default). */
  danger?: dangerousSettings,
}

/** Fetches a resource. Polymorphic in `'input` (typically `string`,
    `URL.t`, or a `Request` instance), `'init` (typically a
    `RequestInit & ClientOptions` record), and `'response` (the DOM
    `Response`).

    See: https://v2.tauri.app/reference/javascript/http/#fetch
*/
let fetch: ('input, ~init: 'init=?) => promise<'response>
