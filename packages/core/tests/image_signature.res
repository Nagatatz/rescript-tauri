// Type-level signature test for Image.

let _check_new: (~rgba: Uint8Array.t, ~width: float, ~height: float) => promise<Image.t> = Image.new_
let _check_from_bytes: Uint8Array.t => promise<Image.t> = Image.fromBytes
let _check_from_path: string => promise<Image.t> = Image.fromPath
let _check_rgba: Image.t => promise<Uint8Array.t> = Image.rgba
let _check_size: Image.t => promise<Image.imageSize> = Image.size

let _check_image_size: Image.imageSize = {width: 0.0, height: 0.0}
