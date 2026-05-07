# RFC-0001: rescript-tauri Core API Design

- **Status:** Draft
- **Author:** TBD
- **Created:** 2026-05-08
- **Target package:** `@rescript-tauri/core`
- **Discussion:** _link to GitHub Discussion_

## Summary

This RFC proposes the foundational API design for `@rescript-tauri/core`, a ReScript binding library for `@tauri-apps/api`. It covers module naming conventions, the design of `invoke` (the IPC bridge), the event system, the representation of class-based JS APIs, the handling of string-literal unions, and error handling strategy.

The goal is to provide a binding that is **idiomatic ReScript**, **faithful to Tauri's underlying behavior**, and **maintainable as Tauri evolves**.

## Motivation

`@tauri-apps/api` is the official JavaScript/TypeScript SDK for Tauri. ReScript users currently have no production-ready bindings to it. Past attempts (`tauri-bindgen`'s ReScript generator, `tauri-rescript-template`, `rescript-tauri-bolierplate`) are either unmaintained, narrowly scoped, or built against obsolete versions of ReScript and Tauri.

A well-designed `rescript-tauri` enables ReScript developers to build Tauri desktop applications with full type safety, leveraging ReScript's variants, options, and result types where TypeScript falls back to `unknown`, `any`, or string-literal unions.

## Goals

- Provide complete bindings to `@tauri-apps/api` (Tauri 2.x).
- Feel idiomatic to ReScript developers familiar with `rescript-react`, `@rescript/core`, etc.
- Stay close enough to the JS API that Tauri's official documentation remains usable.
- Allow incremental adoption: users can mix raw bindings with high-level abstractions.
- Be maintainable by a small team (1–3 contributors) over a multi-year horizon.

## Non-goals

- Generating Rust-side code (out of scope; covered by `tauri-bindgen`, `specta`, etc.).
- Providing a project scaffolding tool (separate package, e.g., `create-rescript-tauri`).
- Bundling UI components.
- Innovating on Tauri's IPC protocol.

---

## 1. Package layout and naming

### 1.1 Monorepo structure

```
rescript-tauri/
├── packages/
│   ├── core/                  # @rescript-tauri/core
│   ├── plugin-fs/             # @rescript-tauri/plugin-fs
│   ├── plugin-dialog/         # @rescript-tauri/plugin-dialog
│   └── ...
├── examples/
│   ├── hello-world/
│   ├── window-management/
│   └── ipc-typed/
└── docs/
```

The npm scope `@rescript-tauri` is used. Each plugin is published as a separate package, mirroring the upstream `@tauri-apps/plugin-*` structure.

### 1.2 Module naming inside `@rescript-tauri/core`

ReScript namespacing is enabled via `rescript.json`:

```json
{
  "name": "@rescript-tauri/core",
  "namespace": true,
  "package-specs": [{ "module": "esmodule", "in-source": true }],
  "suffix": ".res.mjs"
}
```

With `namespace: true`, source files use plain names (`Core.res`, `Event.res`, `Window.res`) and consumers access them as `RescriptTauriCore.Core`, `RescriptTauriCore.Event`, etc.

A top-level `Tauri.res` re-exports the most commonly used modules to allow:

```rescript
open Tauri
let result = await Core.invoke("greet", {"name": "World"})
```

### 1.3 Module list (initial scope)

Mirroring `@tauri-apps/api`:

| Module | Source file | Notes |
|---|---|---|
| `core` | `Core.res` | `invoke`, `convertFileSrc`, `Channel` |
| `event` | `Event.res` | `listen`, `emit`, `once`, predefined events |
| `window` | `Window.res` | `Window` class, current/all/byLabel |
| `webview` | `Webview.res` | `Webview` class |
| `webviewWindow` | `WebviewWindow.res` | Combined `Window` + `Webview` |
| `path` | `Path.res` | Path utility functions |
| `app` | `App.res` | App metadata |
| `dpi` | `Dpi.res` | `LogicalSize`, `PhysicalSize`, etc. |
| `menu` | `Menu.res` | Menu, MenuItem, Submenu |
| `tray` | `Tray.res` | TrayIcon |
| `image` | `Image.res` | Image resource |
| `mocks` | `Mocks.res` | Test utilities |

---

## 2. `invoke` and the IPC bridge

This is the most important design decision in the RFC.

### 2.1 Three-layer design

The `invoke` API is exposed at three layers, allowing users to opt into more or less type safety.

```
┌──────────────────────────────────────────────┐
│  Layer 3: Schema-integrated (separate pkg)   │  @rescript-tauri/schema
├──────────────────────────────────────────────┤
│  Layer 2: Typed Command abstraction          │  Core.Command
├──────────────────────────────────────────────┤
│  Layer 1: Raw bindings                       │  Core.Raw
└──────────────────────────────────────────────┘
```

### 2.2 Layer 1: Raw bindings

Direct bindings to `@tauri-apps/api/core`. Faithful to the JS API. Always available as an escape hatch.

```rescript
// Core.res
module Raw = {
  type invokeOptions = {headers?: Dict.t<string>}

  @module("@tauri-apps/api/core")
  external invoke: (string, ~args: 'args=?, ~options: invokeOptions=?) => promise<'result>
    = "invoke"

  @module("@tauri-apps/api/core")
  external convertFileSrc: (string, ~protocol: string=?) => string = "convertFileSrc"
}
```

**Rationale:**
- Lets users adopt the library without buying into higher-level abstractions.
- Provides a fallback when Tauri ships new APIs that the high-level layer doesn't yet cover.
- Keeps `.resi` interfaces small and reviewable.

**Trade-off:** Layer 1 is not type-safe across the IPC boundary. The user is responsible for the types of `'args` and `'result`.

### 2.3 Layer 2: `Command<'args, 'result>` abstraction

A typed handle to a Rust-side command, with explicit encoders and decoders.

```rescript
// Core.res
module Command: {
  type t<'args, 'result>

  let make: (
    ~name: string,
    ~encodeArgs: 'args => JSON.t,
    ~decodeResult: JSON.t => result<'result, string>,
  ) => t<'args, 'result>

  let invoke: (
    t<'args, 'result>,
    'args,
    ~options: Raw.invokeOptions=?,
  ) => promise<result<'result, invokeError>>

  let invokeExn: (
    t<'args, 'result>,
    'args,
    ~options: Raw.invokeOptions=?,
  ) => promise<'result>
}

type invokeError =
  | DecodeError(string)
  | RustError(JSON.t)
```

**Usage:**

```rescript
module Commands = {
  let greet = Core.Command.make(
    ~name="greet",
    ~encodeArgs=({name}) => JSON.Encode.object([("name", JSON.Encode.string(name))]),
    ~decodeResult=json =>
      switch json->JSON.Decode.string {
      | Some(s) => Ok(s)
      | None => Error("expected string")
      },
  )
}

// At the call site:
switch await Commands.greet->Core.Command.invoke({name: "Tsubasa"}) {
| Ok(message) => Console.log(message)
| Error(DecodeError(msg)) => Console.error("decode failed: " ++ msg)
| Error(RustError(json)) => Console.error2("rust error:", json)
}
```

**Rationale:**
- Centralizes the contract with the Rust backend in one declaration per command.
- Decouples the encoder/decoder from any specific schema library, keeping the core dependency-free.
- The `result` type forces the user to acknowledge IPC failure.
- `invokeExn` is provided for users who prefer exception-based control flow.

**Trade-off:** Hand-written encoders/decoders are verbose. Layer 3 addresses this.

### 2.4 Layer 3: Schema-integrated (separate package)

Out of scope for this RFC, but the design must accommodate it. A separate package (`@rescript-tauri/schema`) integrates with `rescript-schema` or `rescript-struct` to derive encoders/decoders:

```rescript
// In a hypothetical @rescript-tauri/schema integration
let greet = Command.fromSchemas(
  ~name="greet",
  ~args=S.object(o => {name: o->S.field("name", S.string)}),
  ~result=S.string,
)
```

This is deferred to RFC-0002 or later. The `Command.make` signature must remain stable enough that this layer can be built on top.

### 2.5 Why expose all three layers?

The trade-off space for IPC bindings has no single right answer. Different users will want different points on the safety/ergonomics curve. A layered design lets the library serve all of them without forcing a choice.

### 2.6 Alternatives considered

**Alternative A: Single typed `invoke` with type parameters.**

```rescript
let invoke: (string, 'args) => promise<'result>
```

Rejected because: provides no genuine type safety (the type variables are unconstrained), and offers no place to attach decoders or error handling.

**Alternative B: Code generation from Rust source.**

Out of scope for this package, but compatible with our design. Tools like `tauri-bindgen` or `specta` can generate `Command.t` declarations as their output target. This RFC does not preclude such tooling.

**Alternative C: Effect-based API.**

Defer until ReScript's effect story stabilizes.

---

## 3. Event system

### 3.1 Design

Events are represented as typed handles, parallel to `Command`.

```rescript
// Event.res
module Event: {
  type event<'payload> = {
    event: string,
    id: int,
    payload: 'payload,
    windowLabel?: string,
  }

  type t<'payload>
  type unlisten = unit => unit

  let make: (
    ~name: string,
    ~decode: JSON.t => result<'payload, string>,
  ) => t<'payload>

  let listen: (t<'payload>, event<'payload> => unit) => promise<unlisten>
  let once: (t<'payload>, event<'payload> => unit) => promise<unlisten>
  let emit: (t<'payload>, 'payload) => promise<unit>
  let emitTo: (t<'payload>, ~target: eventTarget, 'payload) => promise<unit>
}

and eventTarget =
  | Any
  | AnyLabel(string)
  | App
  | Window(string)
  | Webview(string)
  | WebviewWindow(string)
```

### 3.2 Predefined Tauri events

Tauri ships a set of built-in events (`tauri://close-requested`, `tauri://focus`, etc.). These are exposed as pre-constructed `Event.t<...>` values:

```rescript
module Event = {
  // ...
  module Predefined = {
    let closeRequested: t<unit>
    let focus: t<unit>
    let blur: t<unit>
    let scaleFactorChanged: t<{scaleFactor: float, size: PhysicalSize.t}>
    let resized: t<PhysicalSize.t>
    let moved: t<PhysicalPosition.t>
    let fileDrop: t<fileDropEvent>
    // ...
  }
}
```

### 3.3 `unlisten` as `unit => unit`

The JS API returns `Promise<UnlistenFn>` where `UnlistenFn = () => void`. We preserve this exactly. Users can call `unlisten()` synchronously to detach.

**Alternatives considered:**

- Returning a `Subscription` object with explicit `dispose` method. Rejected: deviates from the JS API without clear benefit.
- Auto-cleanup via finalizers. Rejected: unreliable across runtimes; surprising semantics.

### 3.4 `Channel` (Tauri 2.0+)

`Channel` is Tauri's mechanism for one-way streaming from Rust to the frontend. It is conceptually distinct from events (which use a pub/sub model).

```rescript
// Core.res
module Channel: {
  type t<'message>

  let make: (~decode: JSON.t => result<'message, string>) => t<'message>
  let onMessage: (t<'message>, 'message => unit) => unit
  let id: t<'message> => int
}
```

The `Channel.t` is passed as an argument to `Command.invoke`, and the Rust side writes to it. A worked example will be in `examples/streaming-ipc/`.

---

## 4. Class-based APIs

### 4.1 Pattern: opaque type + `@send` methods

ReScript has no classes. JS classes are encoded as opaque types with associated functions, using `@send` for instance methods and `@scope`/`@new` for constructors and statics.

```rescript
// Window.res
module Window = {
  type t

  type options = {
    url?: string,
    title?: string,
    width?: float,
    height?: float,
    resizable?: bool,
    fullscreen?: bool,
    // ...
  }

  // Constructors
  @module("@tauri-apps/api/window") @new
  external make: (string, ~options: options=?) => t = "Window"

  // Static methods
  @module("@tauri-apps/api/window") @scope("Window")
  external getCurrent: unit => t = "getCurrent"

  @module("@tauri-apps/api/window") @scope("Window")
  external getAll: unit => array<t> = "getAll"

  @module("@tauri-apps/api/window") @scope("Window")
  external getByLabel: string => promise<Nullable.t<t>> = "getByLabel"

  // Instance methods
  @send external label: t => string = "label"
  @send external setTitle: (t, string) => promise<unit> = "setTitle"
  @send external title: t => promise<string> = "title"
  @send external close: t => promise<unit> = "close"
  @send external destroy: t => promise<unit> = "destroy"
  @send external show: t => promise<unit> = "show"
  @send external hide: t => promise<unit> = "hide"
  @send external minimize: t => promise<unit> = "minimize"
  @send external maximize: t => promise<unit> = "maximize"
  @send external unmaximize: t => promise<unit> = "unmaximize"
  @send external isMaximized: t => promise<bool> = "isMaximized"
  // ... and so on
}
```

**Usage:**

```rescript
let win = Window.getCurrent()
await win->Window.setTitle("Hello")
await win->Window.minimize
```

### 4.2 Inheritance: `WebviewWindow` extends `Window`

`WebviewWindow` in the JS API combines `Window` and `Webview`. ReScript represents this with a separate type `WebviewWindow.t` and explicit conversion functions:

```rescript
module WebviewWindow = {
  type t

  // Treat WebviewWindow as a Window
  external asWindow: t => Window.t = "%identity"
  external asWebview: t => Webview.t = "%identity"

  // Methods specific to WebviewWindow (or shared)
  @send external setTitle: (t, string) => promise<unit> = "setTitle"
  // ...
}
```

The `%identity` cast is safe because the JS-level object is the same; only our type-level view differs. This avoids duplicating every `Window` method on `WebviewWindow`.

**Alternatives considered:**

- Module functors / first-class modules to share the method set. Rejected: too heavyweight for a binding library, harms IDE discoverability.
- Re-exporting `Window` methods on `WebviewWindow`. Considered as a complement, not a replacement. May be added in a future RFC if usability requires it.

### 4.3 Object lifetime

JS handles to native resources (windows, menus, trays) are not garbage-collected on the Rust side automatically. Users must call `close`/`destroy` explicitly. The `.resi` documentation must make this clear; the binding does not attempt to add automatic cleanup.

---

## 5. String-literal unions

### 5.1 Use polymorphic variants

JS APIs frequently use string-literal unions (`'light' | 'dark'`, theme/cursor/event names). We represent these as polymorphic variants with `@as` for the JS-level string when the desired ReScript spelling differs:

```rescript
type theme = [#light | #dark]

type cursorIcon = [
  | #default
  | #crosshair
  | #pointer
  | #move
  | #text
  | #wait
  | #help
  | #progress
  | #notAllowed @as("notAllowed")
  | #contextMenu @as("contextMenu")
  // ...
]

@send external setTheme: (Window.t, theme) => promise<unit> = "setTheme"
```

### 5.2 Why polymorphic variants

- Compile to plain strings in the emitted JS (zero runtime cost).
- Compose well across modules without forcing a single sum type.
- Enable open variants when Tauri adds new values, by allowing the user to extend with their own bindings.

**Alternatives considered:**

- Regular variants with conversion functions. Rejected: more boilerplate, allocates objects at runtime.
- Module-level string constants. Rejected: weakest type safety, no exhaustiveness checking.

### 5.3 Open vs closed unions

Tauri may add new theme or cursor values in future versions. Polymorphic variants are open by default, which means a user-supplied `[#light | #dark | #sepia]` can flow into a function expecting `[> #light | #dark]`. This is a feature, not a bug.

For functions that accept Tauri-defined unions, we use closed bounds in the published interface (`.resi`):

```rescript
let setTheme: (Window.t, [#light | #dark]) => promise<unit>
```

If Tauri adds `'sepia'`, we add it in a minor version bump.

---

## 6. Promises, results, and exceptions

### 6.1 Layer 1 returns raw `promise<'a>`

Faithful to JS. Errors come through promise rejection, which translates to a thrown `exn` when awaited.

### 6.2 Layer 2 returns `promise<result<'a, _>>`

Higher-level abstractions (`Command.invoke`, `Event.listen` decoder failure) wrap errors in `result`:

```rescript
let invoke: (
  Command.t<'args, 'result>,
  'args,
) => promise<result<'result, invokeError>>
```

### 6.3 Both `Safe` and `Exn` variants where useful

Where it makes ergonomic sense, both variants are provided:

```rescript
let invoke: (...) => promise<result<'a, invokeError>>
let invokeExn: (...) => promise<'a>  // rejects on error
```

The naming convention is borrowed from `@rescript/core` (`Belt.Array.getExn`, etc.).

### 6.4 Error type hierarchy

```rescript
type invokeError =
  | DecodeError(string)
  | RustError(JSON.t)

type eventError =
  | DecodeError(string)
```

These are intentionally separate types per module rather than a single global `tauriError` union, to keep the failure surface narrow at each call site.

---

## 7. JSON handling

### 7.1 Stick with `JSON.t` from `@rescript/core`

Decoders take `JSON.t` (the standard ReScript JSON type) and return `result<'a, string>`. We do not introduce a new JSON abstraction.

### 7.2 No bundled decoder combinators

The core package provides no JSON decoder library. Users either:

- Write decoders by hand using `JSON.Decode.*`.
- Use `rescript-schema`, `rescript-struct`, or another decoder library of their choice via the `@rescript-tauri/schema` companion package (RFC-TBD).

**Rationale:** keeps the core package's dependency footprint minimal and avoids endorsing a single decoder library.

---

## 8. `peerDependencies` and version policy

### 8.1 Peer dependencies

```json
{
  "peerDependencies": {
    "@tauri-apps/api": "^2.0.0",
    "rescript": ">=11.0.0",
    "@rescript/core": ">=1.0.0"
  }
}
```

### 8.2 Versioning

`@rescript-tauri/core` follows semantic versioning **independently** of Tauri's version. Major bumps in `@tauri-apps/api` may or may not require a major bump here, depending on whether the changes are visible at the binding surface.

A version compatibility table is maintained in the README:

| `@rescript-tauri/core` | `@tauri-apps/api` | ReScript |
|---|---|---|
| `1.x` | `2.x` | `>=11.0` |

### 8.3 Plugin packages version independently

Each plugin package (`@rescript-tauri/plugin-fs`, etc.) versions independently and declares its own peer dep on the corresponding `@tauri-apps/plugin-*` package.

---

## 9. Documentation conventions

### 9.1 `.resi` files are mandatory

Every `.res` file has a corresponding `.resi`. The `.resi` is the source of truth for the public API and contains the documentation comments.

### 9.2 Doc comment format

```rescript
/** Invokes a Tauri command on the Rust backend.

    See: https://v2.tauri.app/develop/calling-rust/

    ## Example

    ```rescript
    let result: string = await Tauri.Core.Raw.invoke("greet", ~args={"name": "World"})
    ```
*/
let invoke: (string, ~args: 'args=?, ~options: invokeOptions=?) => promise<'result>
```

Every public binding includes:
- A one-line summary.
- A link to the corresponding upstream Tauri documentation.
- A minimal example.
- Notes on platform-specific behavior, if any.

### 9.3 README hierarchy

- Root `README.md`: project overview, installation, quick start, link to docs site.
- `packages/core/README.md`: package-specific overview.
- `examples/*/README.md`: scenario explanation.

---

## 10. Testing

### 10.1 Compile-time tests

`packages/core/tests/` contains `.res` files that exercise every public binding. CI requires these to compile successfully. This catches type-level regressions.

### 10.2 Runtime tests

`vitest` + `happy-dom`, with `window.__TAURI_INTERNALS__` mocked. Tests verify that:

- `invoke` produces the expected JS-level call.
- `Event.listen` registers and detaches handlers correctly.
- Encoders and decoders round-trip correctly.

### 10.3 Examples as integration tests

`examples/hello-world` and other examples are built in CI on Linux/macOS/Windows runners. A failed example build blocks release.

---

## 11. Open questions

1. **`Tauri.res` re-export shape.** Should the top-level `Tauri.res` re-export every module, or only a curated subset? Re-exporting everything makes `open Tauri` very heavy. Curating it requires judgment calls.

2. **Whether to bundle `Channel` in `Core.res` or split to `Channel.res`.** It is small, but conceptually distinct from `invoke`.

3. **Naming of `invokeExn` variants.** Alternatives: `invokeOrThrow`, `invokeUnsafe`. ReScript convention favors `Exn` suffix (`@rescript/core`).

4. **How aggressively to pre-define typed events in `Event.Predefined`.** Tauri has many built-in events. Covering them all is verbose; covering only a few risks inconsistency.

5. **Plugin package boundaries.** Should `Channel` live in `core` (it's part of the IPC primitive) or in its own module? Should `Mocks` be a separate package?

6. **`@rescript/core` vs Belt.** We assume `@rescript/core` (`JSON.t`, `Dict.t`, `Nullable.t`). Belt-only users would need a compatibility shim. Should we provide one?

---

## 12. Migration / adoption path

A user starting from `@tauri-apps/api`:

1. **Direct port.** Replace `import { invoke } from '@tauri-apps/api/core'` with `open RescriptTauriCore`. Use `Core.Raw.invoke` and existing call sites work with minimal changes.

2. **Incremental hardening.** Convert hot-path commands to `Core.Command.make` declarations. Errors become explicit.

3. **Full type safety.** Adopt `@rescript-tauri/schema` to derive encoders/decoders from schemas. Match this with `specta` or `tauri-bindgen` on the Rust side for end-to-end type generation.

Each step is independent and reversible.

---

## 13. Risks and mitigations

| Risk | Mitigation |
|---|---|
| Tauri 2.x API surface drifts | Track upstream changelogs; pin peer dep range; automated tests against latest. |
| Maintainer burnout (1-person bus factor) | Recruit co-maintainer early; document everything in CONTRIBUTING.md. |
| ReScript 12 breaking changes (uncurried by default, etc.) | Test on ReScript master in CI; publish prereleases targeting v12 alongside v11. |
| Competing binding effort emerges | Coordinate via ReScript Forum and Tauri Discord; merge if possible. |
| `tauri-bindgen` revives and overlaps | Position `rescript-tauri` as the *runtime* layer; `tauri-bindgen` can target it as a *generator*. Complementary, not competing. |

---

## 14. Reference: comparison with existing approaches

| Project | Status | Scope | Notes |
|---|---|---|---|
| `tauri-apps/tauri-bindgen` | Unmaintained since 2024 | Code gen for IPC only | ReScript output via WIT |
| `JonasKruckenberg/tauri-rescript-template` | Template only | Project scaffolding | No binding library |
| `riemannulus/rescript-tauri-bolierplate` | Obsolete (bs-platform era) | Project scaffolding | Pre-Tauri 1.0 |
| `JonasKruckenberg/tauri-sys` | Active (Rust + wasm-bindgen) | `@tauri-apps/api` for Rust frontends | Useful design reference |
| _this RFC_ | Draft | Full `@tauri-apps/api` for ReScript | New |

---

## 15. Decision checklist

Before merging this RFC, the following must be settled:

- [ ] npm scope `@rescript-tauri` is reserved.
- [ ] Repository created at a stable URL (org or personal).
- [ ] License chosen (MIT recommended).
- [ ] Module naming convention finalized (Section 1.2).
- [ ] `Command` API signature finalized (Section 2.3).
- [ ] `Event.t` shape finalized (Section 3.1).
- [ ] Polymorphic variants vs regular variants for unions (Section 5.1).
- [ ] Error type granularity (Section 6.4).
- [ ] CONTRIBUTING.md drafted.

Once these are settled, the RFC moves from Draft to Accepted, and Phase 1 implementation begins.

---

## Appendix A: First call-site example

A complete, end-to-end example of how the library will be used after Phase 1 ships. This serves as a sanity check on the design.

```rescript
// commands.res
open RescriptTauriCore

module User = {
  type t = {id: int, name: string, email: string}

  let decode = json => {
    open JSON.Decode
    switch json->object {
    | None => Error("expected object")
    | Some(d) =>
      switch (d->Dict.get("id"), d->Dict.get("name"), d->Dict.get("email")) {
      | (Some(id), Some(name), Some(email)) =>
        switch (id->int, name->string, email->string) {
        | (Some(id), Some(name), Some(email)) =>
          Ok({id: Float.toInt(id), name, email})
        | _ => Error("invalid field type")
        }
      | _ => Error("missing field")
      }
    }
  }
}

let getUser = Core.Command.make(
  ~name="get_user",
  ~encodeArgs=({id}) => JSON.Encode.object([("id", JSON.Encode.int(id))]),
  ~decodeResult=User.decode,
)
```

```rescript
// app.res
open RescriptTauriCore

let main = async () => {
  let win = Window.getCurrent()
  await win->Window.setTitle("My App")

  let unlisten = await Event.Predefined.closeRequested->Event.listen(_ => {
    Console.log("user requested close")
  })

  switch await Commands.getUser->Core.Command.invoke({id: 1}) {
  | Ok(user) => Console.log2("got user:", user.name)
  | Error(DecodeError(msg)) => Console.error("decode failed: " ++ msg)
  | Error(RustError(json)) => Console.error2("rust error:", json)
  }

  unlisten()
}
```

If this code reads naturally and the types tell the right story, the RFC is doing its job.
