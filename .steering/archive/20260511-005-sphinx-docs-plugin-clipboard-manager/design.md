# Steering 20260511-005 — Design

## 文書スタイル

`sphinx-docs/user/plugin-fs.md` を準拠スタイルとする:

- H1 = ``# `@rescript-tauri/plugin-clipboard-manager` ``
- 冒頭で upstream（[Tauri 2.x clipboard plugin](https://v2.tauri.app/plugin/clipboard/)）リンク + 1 行サマリ
- `{note}` admonition で「Phase 2、初版公開待ち」フラグ
- Section 順: Install → Capabilities → Minimal example → Public API → Pitfalls (任意) → Compatibility → See also
- ReScript code block は ``` ```rescript ``` ```` フェンス
- パスは GitHub blob リンクで `https://github.com/Nagatatz/rescript-tauri/tree/main/...`

## ファイル構成案

```
sphinx-docs/user/plugin-clipboard-manager.md
sphinx-docs/user/index.md            # Phase 2 表 + toctree に 1 行追記
sphinx-docs/user/installation.md     # note 句から clipboard-manager を除外
```

## ガイド本文構成

### 1. 冒頭 + Image.t 連携注意書き

```markdown
# `@rescript-tauri/plugin-clipboard-manager`

ReScript bindings for the [Tauri 2.x clipboard plugin](https://v2.tauri.app/plugin/clipboard/)
— read and write text, HTML, and images.

```{note}
The Phase 2 implementation is feature-complete in `main`. The
first npm publish (`plugin-clipboard-manager-v0.1.0`) is scheduled
alongside the other Phase 2 packages.
```

```{tip}
Image APIs (`writeImage` / `readImage`) reuse
`@rescript-tauri/core`'s
[`Image`](https://github.com/Nagatatz/rescript-tauri/blob/main/packages/core/src/Image.resi)
module directly — no separate image type ships with this package.
Construct an `Image.t` with `Core.Image.fromPath` or
`Core.Image.fromBytes`, write it via `writeImage`, and inspect
clipboard image bytes with `Core.Image.rgba`.
```
```

### 2. Install 節

`pnpm add @rescript-tauri/plugin-clipboard-manager @tauri-apps/plugin-clipboard-manager` + `rescript.json` 設定。core も peerDep のため `dependencies` に必要。

### 3. Capabilities 節

```json
{
  "permissions": [
    "core:default",
    "clipboard-manager:default"
  ]
}
```

`clipboard-manager:default` で全 read/write API を許可。より細かく絞りたい場合は upstream の `clipboard-manager:allow-write-text` 等を案内（リンクのみ、詳細はガイド外）。

### 4. Minimal example 節

テキスト round-trip（README の Quick example を流用）。

### 5. Public API 節

API 一覧テーブル（README の表を流用）に加え、3 つのサブ節:

#### 5.1 Text APIs — `writeText` / `readText` / `writeTextOptions`

- `writeText("Hello")` の最小例
- `writeTextOptions.label` の Android 用途を明示
- `readText()` の戻り値型 `string`

#### 5.2 Image APIs — `writeImage` / `readImage`

冒頭で再度「Image 型は core を再利用」を明示。2 つのコード例:

```rescript
// (a) `Image.t` を介する
let img = await RescriptTauriCore.Image.fromPath("/path/to/icon.png")
await Cb.writeImage(img)

// (b) RGBA バイト列を直接渡す
let bytes = Uint8Array.fromArray([255, 0, 0, 255, /* ... */])
await Cb.writeImage(bytes)
```

`readImage` 後の `Image.rgba` 例:

```rescript
let img = await Cb.readImage()
let bytes = await RescriptTauriCore.Image.rgba(img)
Console.log(TypedArray.length(bytes))
```

#### 5.3 HTML APIs — `writeHtml`

`writeHtml(html, ~altText?, ())` のシグネチャ説明: HTML clipboard 形式の typical use case はリッチテキスト（太字・色付き文字）を別アプリへ pasteable にすることで、`~altText` は HTML を解釈できない受信側へのプレーンテキスト fallback。

```rescript
await Cb.writeHtml(
  "<b>Hello</b>",
  ~altText="Hello",
)
```

### 6. Clear 節 (Public API の延長として）

`clear()` の説明 + Android < SDK 28 fallback の注意。

### 7. Pitfalls 節 (任意 — Image RGBA layout)

Image RGBA は row-major top-to-bottom であり、画像ライブラリの順序（BGRA、bottom-to-top 等）を変換せずに渡すと色化けする旨を 1 段落で。

### 8. Compatibility + See also

plugin-fs.md と同形。`See also` は:

- README へのリンク (packages/plugin-clipboard-manager/README.md)
- 上流 Tauri docs
- `@rescript-tauri/core` の Image.resi (peerDep 経由の依存型)

## Cross-ref 検証

- `installation.md` に `plugin-clipboard-manager.md` への toctree 経由のリンクが存在することを確認 (`index.md` の toctree で十分)
- `Core.Image` への参照: sphinx 内に internal cross-ref がないため、external link `https://github.com/Nagatatz/rescript-tauri/blob/main/packages/core/src/Image.resi` を使用
- `installation.md` の note 句から「plugin-clipboard-manager」を除外して整合させる

## `installation.md` 変更計画

現状 (74-83 行):

```
Dedicated user guides for `@rescript-tauri/plugin-shell`,
`@rescript-tauri/plugin-notification`, `@rescript-tauri/plugin-log`,
`@rescript-tauri/plugin-os`, and
`@rescript-tauri/plugin-clipboard-manager` are scheduled for follow-up
sub-steerings.
```

→ `plugin-clipboard-manager` を除外し、72 行付近の `See the [...] guides for the matching ReScript / Rust / capability setup.` リンク列に `[plugin-clipboard-manager](plugin-clipboard-manager.md)` を追加。

## `index.md` 変更計画

現状 (43-50 行) の Phase 2 テーブル + toctree:

```
| `@rescript-tauri/plugin-notification` | Native notifications ... | [plugin-notification](plugin-notification.md) |
```

の直後に:

```
| `@rescript-tauri/plugin-clipboard-manager` | Clipboard (text / image / HTML) | [plugin-clipboard-manager](plugin-clipboard-manager.md) |
```

を追加し、toctree に `plugin-clipboard-manager` を `plugin-notification` の次に挿入。
