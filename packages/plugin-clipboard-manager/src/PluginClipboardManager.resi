/** Bindings for `@tauri-apps/plugin-clipboard-manager` (Tauri 2.x
    clipboard plugin).

    Phase 2+ first iteration: 100% coverage of the stable public
    surface of `@tauri-apps/plugin-clipboard-manager` v2.3.2 — 6
    functions covering text / image / HTML read & write plus a
    clipboard `clear` operation.

    See: https://v2.tauri.app/plugin/clipboard/
*/

/** Options for `writeText`. `label` is an Android-only entity name
    surfaced in clipboard history UIs. */
type writeTextOptions = {label?: string}

/** Writes plain text to the clipboard.

    See: https://v2.tauri.app/reference/javascript/clipboard-manager/#writetext
*/
let writeText: (string, ~opts: writeTextOptions=?) => promise<unit>

/** Reads plain text from the clipboard.

    See: https://v2.tauri.app/reference/javascript/clipboard-manager/#readtext
*/
let readText: unit => promise<string>

/** Writes an image to the clipboard. The polymorphic `'image`
    argument matches the upstream union: pass any of
    `string` (path), `RescriptTauriCore.Image.t`, `Uint8Array.t`,
    `ArrayBuffer.t`, or `array<int>` (RGBA bytes).

    Unsupported on Android / iOS upstream.

    See: https://v2.tauri.app/reference/javascript/clipboard-manager/#writeimage
*/
let writeImage: 'image => promise<unit>

/** Reads the clipboard contents as an `Image.t` resource handle.
    Use `RescriptTauriCore.Image.rgba` to inspect the bytes.

    Unsupported on Android / iOS upstream.

    See: https://v2.tauri.app/reference/javascript/clipboard-manager/#readimage
*/
let readImage: unit => promise<RescriptTauriCore.Image.t>

/** Writes HTML to the clipboard. `~altText` is an optional plain-text
    fallback for clients that don't accept HTML.

    Unsupported on Android / iOS upstream.

    See: https://v2.tauri.app/reference/javascript/clipboard-manager/#writehtml
*/
let writeHtml: (string, ~altText: string=?) => promise<unit>

/** Clears the clipboard. On Android < SDK 28, falls back to writing
    an empty string.

    See: https://v2.tauri.app/reference/javascript/clipboard-manager/#clear
*/
let clear: unit => promise<unit>
