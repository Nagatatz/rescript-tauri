// rescript-tauri plugin-os example.
//
// Wires every public function of @rescript-tauri/plugin-os to a
// button so the 7 sync getters + 2 async getters can be exercised
// inside a real Tauri 2.x desktop app, with the polymorphic
// variants (`platform` / `osType` / `arch` / `family`) decoded into
// human-readable strings.

open RescriptTauriPluginOs

@val external document: 'a = "document"

let setResult = (text: string): unit => {
  let el = document["getElementById"]("result")
  el["textContent"] = text
}

let safe = (label: string, body: unit => promise<unit>): unit => {
  let _ =
    body()->Promise.catch(err => {
      Console.error2(label, err)
      let serialized =
        err->Obj.magic->JSON.stringifyAny->Option.getOr("(non-serializable)")
      setResult(label ++ " failed: " ++ serialized)
      Promise.resolve()
    })
}

// ----- Polymorphic-variant decoders -----

let platformToString = (p: PluginOs.platform): string =>
  switch p {
  | #linux => "linux"
  | #macos => "macos"
  | #ios => "ios"
  | #freebsd => "freebsd"
  | #dragonfly => "dragonfly"
  | #netbsd => "netbsd"
  | #openbsd => "openbsd"
  | #solaris => "solaris"
  | #android => "android"
  | #windows => "windows"
  }

let osTypeToString = (t: PluginOs.osType): string =>
  switch t {
  | #linux => "linux"
  | #windows => "windows"
  | #macos => "macos"
  | #ios => "ios"
  | #android => "android"
  }

let archToString = (a: PluginOs.arch): string =>
  switch a {
  | #x86 => "x86"
  | #x86_64 => "x86_64"
  | #arm => "arm"
  | #aarch64 => "aarch64"
  | #mips => "mips"
  | #mips64 => "mips64"
  | #powerpc => "powerpc"
  | #powerpc64 => "powerpc64"
  | #riscv64 => "riscv64"
  | #s390x => "s390x"
  | #sparc64 => "sparc64"
  }

let familyToString = (f: PluginOs.family): string =>
  switch f {
  | #unix => "unix"
  | #windows => "windows"
  }

// Render newline / CR as escapes so the eol value is visible.
let escapeEol = (s: string): string =>
  s->String.replaceAll("\n", "\\n")->String.replaceAll("\r", "\\r")

// ----- Sync info bundle -----

let runShowAll = async () => {
  let lines = [
    "eol         : '" ++ escapeEol(PluginOs.eol()) ++ "'",
    "platform    : " ++ platformToString(PluginOs.platform()),
    "version     : " ++ PluginOs.version(),
    "family      : " ++ familyToString(PluginOs.family()),
    "osType      : " ++ osTypeToString(PluginOs.osType_()),
    "arch        : " ++ archToString(PluginOs.arch()),
    "exeExtension: '" ++ PluginOs.exeExtension() ++ "'",
  ]
  setResult(Array.join(lines, "\n"))
}

// ----- Async getters -----

let nullableToDisplay = (v: Nullable.t<string>): string =>
  switch v->Nullable.toOption {
  | Some(s) => "'" ++ s ++ "'"
  | None => "(null)"
  }

let runGetLocale = async () => {
  let l = await PluginOs.locale()
  setResult("locale: " ++ nullableToDisplay(l))
}

let runGetHostname = async () => {
  let h = await PluginOs.hostname()
  setResult("hostname: " ++ nullableToDisplay(h))
}

// ----- Wiring -----

let bind = (id: string, run: unit => promise<unit>): unit => {
  let _ = document["getElementById"](id)["addEventListener"]("click", () => safe(id, run))
}

let main = (): unit => {
  bind("btn-show-all", runShowAll)
  bind("btn-get-locale", runGetLocale)
  bind("btn-get-hostname", runGetHostname)
}

main()
