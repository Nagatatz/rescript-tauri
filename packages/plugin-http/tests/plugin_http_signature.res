// Type-level signature test for PluginHttp.

let _check_basic_auth: PluginHttp.basicAuth = {username: "u", password: "p"}

let _check_proxy_config: PluginHttp.proxyConfig = {url: "http://proxy:8080"}

// proxy<'proxyValue> with string URLs
let _check_proxy_string: PluginHttp.proxy<string> = {all: ?Some("http://proxy:8080")}

// proxy<'proxyValue> with full proxyConfig
let _check_proxy_full: PluginHttp.proxy<PluginHttp.proxyConfig> = {
  https: ?Some({url: "http://proxy:8080"}),
}

let _check_dangerous: PluginHttp.dangerousSettings = {acceptInvalidCerts: ?Some(false)}

let _check_client_options: PluginHttp.clientOptions<string> = {
  maxRedirections: ?Some(5),
  connectTimeout: ?Some(30000),
}

let _check_fetch: ('input, ~init: 'init=?) => promise<'response> = PluginHttp.fetch
