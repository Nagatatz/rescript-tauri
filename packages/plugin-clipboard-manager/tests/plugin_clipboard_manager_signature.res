// Type-level signature test for PluginClipboardManager.

let _check_write_text_options: PluginClipboardManager.writeTextOptions = {
  label: ?Some("history-label"),
}

let _check_write_text: (
  string,
  ~opts: PluginClipboardManager.writeTextOptions=?,
) => promise<unit> = PluginClipboardManager.writeText

let _check_read_text: unit => promise<string> = PluginClipboardManager.readText

let _check_write_image: 'image => promise<unit> = PluginClipboardManager.writeImage

let _check_read_image: unit => promise<RescriptTauriCore.Image.t> =
  PluginClipboardManager.readImage

let _check_write_html: (string, ~altText: string=?) => promise<unit> =
  PluginClipboardManager.writeHtml

let _check_clear: unit => promise<unit> = PluginClipboardManager.clear
