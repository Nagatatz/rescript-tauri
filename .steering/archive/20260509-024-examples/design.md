# Design: 残り 3 examples の整備

## 配置

```
examples/
├── hello-world/             # 既存（steering 016）
├── window-management/       # 新規
├── ipc-typed/               # 新規
└── streaming-ipc/           # 新規
```

各 example は hello-world と同じレイアウト (package.json / rescript.json / index.html / src/App.res / src/main.mjs / src-tauri/...）。

## window-management

`Window.t` の代表的操作 (setTitle / maximize / unmaximize / minimize / center / setSize) と `WebviewWindow` の派生ウィンドウ作成・close を 1 ページで網羅。`Dpi.LogicalSize.make` を初めて example で実用使用する。Rust 側は空（コマンドなし）。

## ipc-typed

`Core.Command.make` を 2 つ宣言:
- `greet` (string -> string): 単純なケース
- `add` ({a, b} -> int): record 入力 + decoder で int を取り出す

`result<_, Core.invokeError>` の `DecodeError` / `RustError` を両方 UI 上に表示するため `JSON.stringify(payload)` で raw を見せる。

## streaming-ipc

Rust が `Channel<u32>` を取る `count_to(channel, target)` コマンドを `for n in 1..=target { channel.send(n)? }` で実装。フロントは `Core.Channel.make` でチャネル作成 → `onMessage` で受信 → `Command.invoke` でチャネルを Rust に渡す典型シーケンスを示す。

注意点: `Command.encodeArgs` はチャネルを `JSON.t` に変換する形式上は通れない (`Channel.t` は opaque)。本 example では `Obj.magic(channel)` でラップして `JSON.t` 化を回避し、ランタイム上は同一の JS Channel インスタンスを Rust に届ける。これは Channel を IPC 引数として渡す慣用句として upstream の TypeScript ドキュメントでも `invoke('cmd', {channel, ...})` と直接渡している。

## CI 統合

`.github/workflows/examples-build.yml` に各 example の frontend build + cargo check ステップを追加。3 OS マトリクスは継続。

## 警告について

ReScript の Warning 21 ("this statement never returns") が `addEventListener` 等の polymorphic external 戻り値を捨てる位置で発火するため、`let _ = el["addEventListener"](...)` の形にしてサプレスする。

## CI 影響

- `examples-build.yml` の steps が増える分、CI 時間は伸びるが、各 example は 1 〜 2 modules しかコンパイルしないので問題なし。
- 既存 hello-world のステップは変更なし。
