# Design: Dpi / Path / App / Image モジュール

## モジュール配置

```
packages/core/src/
├── Dpi.res / Dpi.resi
├── Path.res / Path.resi
├── App.res / App.resi          # Image.t を参照（ファイル順序は ReScript が依存解決）
└── Image.res / Image.resi
```

## Dpi

各 4 つのサイズ/位置クラスは `opaque type t` + `@new` コンストラクタ + `@get` getter + `@send` 変換ヘルパで表現する。Tauri JS API は `instanceof LogicalSize` 等で判定するので、record 型での再現は IPC でずれる。実装上は本物のクラスインスタンスを取得する必要がある。

`Size` / `Position` は internal `_make: 'inner => t` を経由して `fromLogical` / `fromPhysical` を提供する（コンストラクタが `LogicalSize | PhysicalSize` のいずれかを受ける upstream の overload を 2 つの ReScript ヘルパに分解）。

## Path

ほぼ全関数を `@module` で薄くバインド。`join` / `resolve` は upstream で variadic なので `@variadic external join: array<string> => promise<string>` で配列を可変長引数として渡す。

`BaseDirectory` は upstream で数値 enum (1〜23)。`type t = private int` を `.resi` で公開し、`.res` 側で `let audio: t = 1` 等と定数化することで「ユーザーは値を生成できないが、`@rescript-tauri/core` が用意した定数のみ渡せる」型安全を実現する。整数演算を直接受けつけない。

## App

stable な 9 関数 + `theme` ポリ variant のみ提供。`defaultWindowIcon` の戻り値は `Image.t`（`Nullable.t` 包み）。

`fetchDataStoreIdentifiers` / `removeDataStore` / `getBundleType` / `onBackButtonPress` / `supportsMultipleWindows` は本 steering ではバインドせず、Phase 2 で再評価。

## Image

opaque + `@scope("Image")` のスタティックメソッド。upstream の `Image.new` は ReScript 予約語と衝突するため、外部名 `new` を `new_` に再公開（カリー化バインド + ラッパ関数で labeled-arg を提供）。

## テスト

各モジュールに対して型レベルテスト (`<module>_signature.res`) を追加。runtime テストは `Mocks.mockIPC` を経由する形で書けるが、本 steering では型レベルのみで十分（PRD §5.2 testing budget 準拠）。

## CI 影響

- `tests-core-types.yml` の公開シンボルカバレッジゲートは `_check_*` の数が `let *` の数 ≦ で OK。新規 4 モジュールで public lets 39 件追加 (Dpi: 24, Path: 47, App: 9, Image: 5 = 85 actually)、対応する `_check_` を 35 件以上追加する必要がある（追加した）。
- `doc-link-lint.yml` は各 `.resi` に少なくとも 1 つの `v2.tauri.app/` URL があれば OK（追加した）。
