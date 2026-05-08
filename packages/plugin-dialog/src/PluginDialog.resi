/** Bindings for `@tauri-apps/plugin-dialog` (Tauri 2.x native dialog
    plugin).

    Phase 2 first iteration scope: open / save / message / ask /
    confirm with their record-style options. The TypeScript-level
    conditional return type of upstream's `open` is unrolled into
    four ReScript functions (`openFile` / `openFiles` /
    `openDirectory` / `openDirectories`) so the result types stay
    static.

    See: https://v2.tauri.app/plugin/dialog/
*/

/** A file extension filter. `extensions` is the list of allowed
    extensions without the leading `.`.

    See: https://v2.tauri.app/reference/javascript/dialog/#dialogfilter
*/
type dialogFilter = {
  name: string,
  extensions: array<string>,
}

/** Mobile-only picker mode hint. */
type pickerMode = [
  | #document
  | #media
  | #image
  | #video
]

/** iOS-only file access mode. */
type fileAccessMode = [#copy | #scoped]

/** Severity hint for `message` / `ask` / `confirm`. */
type dialogKind = [#info | #warning | #error]

/** Default button layout for `message`.

    See: https://v2.tauri.app/reference/javascript/dialog/#messagedialogdefaultbuttons
*/
type messageButtons = [#Ok | #OkCancel | #YesNo | #YesNoCancel]

/** Result returned by `message`. The upstream union of named
    constants (`'Yes' | 'No' | 'Ok' | 'Cancel'`) plus arbitrary
    custom-button strings is exposed as a plain `string`; pattern
    match on it directly.

    See: https://v2.tauri.app/reference/javascript/dialog/#messagedialogresult
*/
type messageResult = string

/** Options for the open dialog. The `multiple` / `directory` keys
    that exist upstream are intentionally **not** exposed here —
    callers pick a function (`openFile` / `openFiles` /
    `openDirectory` / `openDirectories`) which encodes those values
    statically.

    See: https://v2.tauri.app/reference/javascript/dialog/#opendialogoptions
*/
type openOptions = {
  title?: string,
  filters?: array<dialogFilter>,
  defaultPath?: string,
  recursive?: bool,
  canCreateDirectories?: bool,
  pickerMode?: pickerMode,
  fileAccessMode?: fileAccessMode,
}

/** Options for the save dialog.

    See: https://v2.tauri.app/reference/javascript/dialog/#savedialogoptions
*/
type saveOptions = {
  title?: string,
  filters?: array<dialogFilter>,
  defaultPath?: string,
  canCreateDirectories?: bool,
}

/** Options for `message`.

    See: https://v2.tauri.app/reference/javascript/dialog/#messagedialogoptions
*/
type messageOptions = {
  title?: string,
  kind?: dialogKind,
  okLabel?: string,
  buttons?: messageButtons,
}

/** Options for `ask` / `confirm`.

    See: https://v2.tauri.app/reference/javascript/dialog/#confirmdialogoptions
*/
type confirmOptions = {
  title?: string,
  kind?: dialogKind,
  okLabel?: string,
  cancelLabel?: string,
}

/** Single-file selection. Returns the picked path or `Nullable.null`
    when the user cancels.

    See: https://v2.tauri.app/reference/javascript/dialog/#open
*/
let openFile: (~options: openOptions=?) => promise<Nullable.t<string>>

/** Multi-file selection. Returns `Nullable.null` when the user
    cancels.

    See: https://v2.tauri.app/reference/javascript/dialog/#open
*/
let openFiles: (~options: openOptions=?) => promise<Nullable.t<array<string>>>

/** Single-directory selection.

    See: https://v2.tauri.app/reference/javascript/dialog/#open
*/
let openDirectory: (~options: openOptions=?) => promise<Nullable.t<string>>

/** Multi-directory selection.

    See: https://v2.tauri.app/reference/javascript/dialog/#open
*/
let openDirectories: (~options: openOptions=?) => promise<Nullable.t<array<string>>>

/** Save-as dialog. Returns the chosen save path or `Nullable.null`.

    See: https://v2.tauri.app/reference/javascript/dialog/#save
*/
let save: (~options: saveOptions=?) => promise<Nullable.t<string>>

/** Shows a message dialog. Returns the label of the clicked button.

    See: https://v2.tauri.app/reference/javascript/dialog/#message
*/
let message: (string, ~options: messageOptions=?) => promise<messageResult>

/** Ask the user a yes/no question. Returns `true` for Yes / Ok.

    See: https://v2.tauri.app/reference/javascript/dialog/#ask
*/
let ask: (string, ~options: confirmOptions=?) => promise<bool>

/** Confirm dialog (OK / Cancel).

    See: https://v2.tauri.app/reference/javascript/dialog/#confirm
*/
let confirm: (string, ~options: confirmOptions=?) => promise<bool>
