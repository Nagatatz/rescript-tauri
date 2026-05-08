/** A typed event delivered to a `listen` / `once` handler. */
type event<'payload> = {
  event: string,
  id: int,
  payload: 'payload,
}

/** Targets for `emitTo`. Mirrors Tauri's `EventTarget` discriminator. */
type eventTarget =
  | Any
  | AnyLabel(string)
  | App
  | Window(string)
  | Webview(string)
  | WebviewWindow(string)

/** A typed handle to one event name with its decoder. */
type t<'payload>

/** Returned by `listen` / `once` — call it to detach the handler. */
type unlisten = unit => unit

/** Declares one event with its name and JSON decoder.

    See: https://v2.tauri.app/reference/javascript/api/namespaceevent/
*/
let make: (~name: string, ~decode: Core.decoder<'payload>) => t<'payload>

/** Subscribes to every emission of the event. The returned `unlisten`
    must be called to stop receiving events. Decode failures are
    silently dropped (the user callback is not invoked).

    See: https://v2.tauri.app/reference/javascript/api/namespaceevent/#listen

    ## Example

    ```rescript
    let fileChanged = Event.make(~name="file-changed", ~decode=...)
    let unlisten = await fileChanged->Event.listen(evt => Console.log(evt.payload))
    ```
*/
let listen: (t<'payload>, event<'payload> => unit) => promise<unlisten>

/** Subscribes for exactly one emission, then auto-unsubscribes.

    See: https://v2.tauri.app/reference/javascript/api/namespaceevent/#once
*/
let once: (t<'payload>, event<'payload> => unit) => promise<unlisten>

/** Emits the event globally to every listener.

    See: https://v2.tauri.app/reference/javascript/api/namespaceevent/#emit
*/
let emit: (t<'payload>, 'payload) => promise<unit>

/** Emits the event to a specific target only.

    See: https://v2.tauri.app/reference/javascript/api/namespaceevent/#emitto
*/
let emitTo: (t<'payload>, ~target: eventTarget, 'payload) => promise<unit>
