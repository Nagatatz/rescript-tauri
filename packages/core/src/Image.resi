/** Image bindings from `@tauri-apps/api/image`.

    `Image.t` is an opaque RGBA-image resource handle. Constructors
    are async because the underlying Rust side allocates a resource
    id; callers must keep the handle alive for the duration of any
    use (the resource is reference-counted on the Rust side and
    released when the JS object is collected).

    See: https://v2.tauri.app/reference/javascript/api/namespaceimage/
*/

/** Opaque image handle. Pass to `Window.setIcon`, `TrayIcon.setIcon`,
    etc.

    See: https://v2.tauri.app/reference/javascript/api/namespaceimage/#image
*/
type t

/** Pixel size returned by `size`.

    See: https://v2.tauri.app/reference/javascript/api/namespaceimage/#imagesize
*/
type imageSize = {
  width: float,
  height: float,
}

/** Constructs an `Image` from raw RGBA bytes (row-major, top to bottom).

    See: https://v2.tauri.app/reference/javascript/api/namespaceimage/#new
*/
let new_: (~rgba: Uint8Array.t, ~width: float, ~height: float) => promise<t>

/** Loads an `Image` from raw bytes, inferring the format (`png` or
    `ico` depending on Cargo features enabled on the Rust side).

    See: https://v2.tauri.app/reference/javascript/api/namespaceimage/#frombytes
*/
let fromBytes: Uint8Array.t => promise<t>

/** Loads an `Image` from a file path.

    See: https://v2.tauri.app/reference/javascript/api/namespaceimage/#frompath
*/
let fromPath: string => promise<t>

/** Returns the RGBA byte buffer for this image (row-major, top to
    bottom).

    See: https://v2.tauri.app/reference/javascript/api/namespaceimage/#rgba
*/
let rgba: t => promise<Uint8Array.t>

/** Returns the size of this image in pixels.

    See: https://v2.tauri.app/reference/javascript/api/namespaceimage/#size
*/
let size: t => promise<imageSize>
