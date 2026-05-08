# Requirements: examples/plugin-fs-demo

| 項目 | 内容 |
|---|---|
| ステアリング ID | 20260509-037 |
| 親プラン | `.steering/20260509-030-phase2-planning/` §I (Phase 2 完了条件) — examples 追加 |
| 関連パッケージ | `@rescript-tauri/plugin-fs` (steering 032 で実装済み) |
| 作成日 | 2026-05-09 |

---

## 1. 背景

Phase 2 で `@rescript-tauri/plugin-fs` の実装が完了した
(steering 032)。前 steering 036 で plugin-dialog 用の例題を追加した
ため、本 steering では plugin-fs 用の対となる例題を追加する。

両 demo が揃うことで examples/ 配下が「core API + plugin パッケージ
2 種」をすべて使い分けられる状態になる。

## 2. 目的

- `@rescript-tauri/plugin-fs` の **公開 14 関数すべて** を 1 つの
  Tauri アプリ内から呼び出すデモを示す。
- `BaseDirectory.appLocalData` 配下のサンドボックス領域でファイル
  操作を完結させる（追加 OS パーミッションを必要としない）。
- `pnpm --filter plugin-fs-demo build` がローカルで成功する。

## 3. スコープ

### Must（本 steering で対応）

- `examples/plugin-fs-demo/` ディレクトリの新規作成
- ReScript フロント (`src/App.res`)
  - 14 関数すべて (`readTextFile` / `writeTextFile` / `readFile` /
    `writeFile` / `exists` / `remove` / `rename` / `mkdir` /
    `readDir` / `stat` / `lstat` / `truncate` / `copyFile` /
    `size`) をボタン経由で呼び出す
  - すべての書き込みは `BaseDirectory.appLocalData` 直下の
    `plugin-fs-demo/` フォルダに対して行う
  - 各操作の結果は `<pre id="result">` に追記表示
- Rust 側 (`src-tauri/`)
  - `tauri-plugin-fs` v2.x を `Cargo.toml` に追加し
    `tauri::Builder` に `.plugin(tauri_plugin_fs::init())` で登録
  - `capabilities/default.json` を新規作成し
    `core:default` + `fs:default` + `fs:allow-app-local-data-recursive`
    を許可（appLocalData 配下のサブツリーを許可）
- `index.html`（カテゴリ別ボタン群と結果表示要素）
- `package.json` / `rescript.json`
- `README.md`（実行方法・ファイル構成・各ボタンの挙動・互換マトリクス）

### Should（余裕があれば）

- `docs/repository-structure.md` §3 の `examples/` リストに
  `plugin-fs-demo/` を追記
- README に "上流 plugin-fs v2.5 系を `peerDependencies` 経由で
  取り込んでいる" 旨の互換マトリクス節

### 非対象（Out of scope）

- `pnpm tauri dev` の実機実行確認（OS とアイコン素材揃えが
  別 steering の責務）
- CI ワークフロー (`examples-build.yml` 等) の実際のジョブ追加
  – steering 037 後段の B 軸 (CI 拡張) で対応
- `FileHandle` / `watch` / `readTextFileLines` など plugin-fs
  本体の Phase 2 後続スコープ API（packages/plugin-fs 自体に未実装）
- アイコン素材の独自生成（`hello-world/icons/` を流用）

## 4. 受け入れ条件

1. `examples/plugin-fs-demo/` が新規ディレクトリとして作成され、
   `package.json` に `name: "plugin-fs-demo"` が含まれる。
2. ローカルで `pnpm install && pnpm --filter plugin-fs-demo build`
   が **エラーなく完了** する（ReScript ビルドのみで OK）。
3. `src/App.res` から plugin-fs の **公開 14 関数すべて** を実際に
   使用する（型レベル参照のみは不可）。
4. `tauri-plugin-fs` バージョンが `@tauri-apps/plugin-fs` peerDep の
   2.5.x 系と整合している。
5. `pnpm --recursive build` が他パッケージに regression を起こさず
   全件成功し、`pnpm --recursive test` も全件パスする。
6. `tasklist.md` の全タスク（マージタスクを含む）が `[x]` の状態で
   main マージされる。

## 5. 依存・前提

- steering 032 で `@rescript-tauri/plugin-fs` が実装済み。
- steering 036 で plugin-dialog-demo が main にマージ済み（直近の
  examples 構成基準として参照）。

## 6. リスク

- **Rust 側 capability の漏れ**: `fs:default` だけでは appLocalData
  配下への書き込みが拒否される可能性がある。`fs:allow-app-local-data-recursive`
  を併記して appLocalData サブツリーを明示許可する。
- **Tauri toolchain なし環境での Rust ビルド**: ReScript 側ビルドの
  みで完了とし、Rust 側は CI に委譲する（受け入れ条件 §2 と整合）。
- **`Uint8Array` の生成方法**: ReScript の `Uint8Array` バインディング
  でバイト配列を作る簡潔な手順を示す必要がある。`Uint8Array.fromArray`
  で 0..255 の整数配列を渡す形を採る。

## 7. 影響範囲

- 追加: `examples/plugin-fs-demo/**`、ステアリング一式
- 更新（任意）: `docs/repository-structure.md`
- 既存パッケージへの破壊的変更なし
