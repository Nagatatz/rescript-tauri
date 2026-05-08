type t

type imageSize = {
  width: float,
  height: float,
}

@module("@tauri-apps/api/image") @scope("Image")
external new_: (Uint8Array.t, float, float) => promise<t> = "new"

let new_ = (~rgba, ~width, ~height) => new_(rgba, width, height)

@module("@tauri-apps/api/image") @scope("Image")
external fromBytes: Uint8Array.t => promise<t> = "fromBytes"

@module("@tauri-apps/api/image") @scope("Image")
external fromPath: string => promise<t> = "fromPath"

@send external rgba: t => promise<Uint8Array.t> = "rgba"
@send external size: t => promise<imageSize> = "size"
