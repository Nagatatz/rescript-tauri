type basicAuth = {
  username: string,
  password: string,
}

type proxyConfig = {
  url: string,
  basicAuth?: basicAuth,
  noProxy?: string,
}

type proxy<'proxyValue> = {
  all?: 'proxyValue,
  http?: 'proxyValue,
  https?: 'proxyValue,
}

type dangerousSettings = {
  acceptInvalidCerts?: bool,
  acceptInvalidHostnames?: bool,
}

type clientOptions<'proxyValue> = {
  maxRedirections?: int,
  connectTimeout?: int,
  proxy?: proxy<'proxyValue>,
  danger?: dangerousSettings,
}

@module("@tauri-apps/plugin-http")
external fetch: ('input, ~init: 'init=?) => promise<'response> = "fetch"
