# Requirements: sphinx-docs Phase 2 sync

| 項目 | 内容 |
|---|---|
| ステアリング ID | 20260509-042 |
| 親プラン | `.steering/20260509-030-phase2-planning/` §I (Phase 2 完了条件) — `sphinx-docs/` を Phase 2 全パッケージに対応 |
| 関連パッケージ | `@rescript-tauri/schema`, `@rescript-tauri/plugin-fs`, `@rescript-tauri/plugin-dialog` |
| 作成日 | 2026-05-09 |

---

## 1. 背景

Phase 2 で 3 パッケージ (`@rescript-tauri/schema` / `plugin-fs` /
`plugin-dialog`) が main にマージされ、対応する examples / CI も
整った (steering 031/032/035/036/037/039/041)。しかし
`sphinx-docs/user/` はまだ Phase 1 (`@rescript-tauri/core` 単独)
向けの記述しかなく、外部公開ドキュメントが Phase 2 に追従していない。

Phase 2 完了条件 §I の `sphinx-docs/ を Phase 2 全パッケージに対応`
を満たすため、ユーザー向けドキュメントを 3 パッケージに合わせて
拡張する。

## 2. 目的

- `sphinx-docs/user/` に Phase 2 各パッケージの導入ガイドを 1 件
  ずつ追加する (3 件)。
- 既存ページ (`index.md` / `installation.md` / `configuration.md`)
  を Phase 2 パッケージへの導線・互換マトリクスを含む形に更新する。
- 各ガイドページから対応する `examples/<demo>` への参照を貼り、
  README で対比できるようにする。

## 3. スコープ

### Must

#### 新規ページ (3 件)

- `sphinx-docs/user/plugin-fs.md`
  - 概要・インストール・最小ファイル IO 例・互換性
  - `examples/plugin-fs-demo/` への参照
  - `BaseDirectory.appLocalData` を使う最小サンプル
  - `fs:default` + `fs:allow-app-local-data-recursive` capability の
    必要性を明記
- `sphinx-docs/user/plugin-dialog.md`
  - 概要・インストール・最小 open/save/message 例・互換性
  - `examples/plugin-dialog-demo/` への参照
  - `dialog:default` capability の必要性
  - `openFile` / `openFiles` / `openDirectory` / `openDirectories`
    の 4 関数分割（条件型を ReScript で静的化した経緯）を簡潔に
    紹介
- `sphinx-docs/user/schema.md`
  - 概要 (Layer 3 IPC)・インストール
  - `Schema.fromSchemas` の最小例（`greet` を `Core.Command.make`
    版と並べて行数比較）
  - `Schema.channelFromSchema` / `Schema.eventFromSchema` /
    `Schema.toDecoder` の用途
  - `examples/ipc-typed-with-schema/` への参照
  - `rescript-schema 9.x` peerDep + DSL 注意点
    (`s.field("name", S.string)` メソッド呼び出し)

#### 既存ページの更新

- `sphinx-docs/user/index.md`
  - 「Phase 2 packages」セクションを追加し、新規 3 ページへリンク
  - "Modules at a glance" の表は core のままで残す（plugin / schema
    は別ページに切り出す）
- `sphinx-docs/user/installation.md`
  - "Install (planned)" セクションに Phase 2 パッケージのインストール
    例 (`pnpm add @rescript-tauri/plugin-fs @tauri-apps/plugin-fs`
    などの 3 セット) を追加
  - 互換マトリクスはページ別に書くため `installation.md` 側は
    リンクで誘導
- `sphinx-docs/user/configuration.md`
  - 末尾の "Plugin packages (Phase 2+)" 表を「Phase 2 で実装済」
    の状態に更新（"Phase 2+" → "Phase 2 (実装済 / npm publish 待ち)"
    と注記、各行から該当ガイドページへリンク）

### Should（余裕があれば）

- `sphinx-docs/index.md` の "Quick Links" に Phase 2 ページを追加
- 各新規ページの先頭に "Status" コールアウト
  （npm publish 前なので workspace 経由で使う旨）

### 非対象（Out of scope）

- 日本語翻訳 (`.po` ファイル) の更新 — `make gettext` /
  `make update-po` で再生成する必要があり、本セッション環境では
  uv toolchain がないため後続 steering または翻訳担当者に委ねる。
  本 steering ではタスクリストに「`.po` 再生成は未実施」と明記
  し、英語ソースの追加までで完了とする。
- ドキュメント全体のレイアウト変更 / 新セクション (例: Tutorial /
  Cookbook 等) の導入
- `sphinx-docs/dev/` (コントリビュータ向け) の Phase 2 対応 — 別軸
- 各パッケージの個別 README + 互換マトリクス追加 — 親 §D / §E / §F
  の別タスクとして残す

## 4. 受け入れ条件

1. `sphinx-docs/user/` に新規 3 ページが追加される。
2. `sphinx-docs/user/index.md` の `toctree` に新規 3 ページが含まれ、
   サイドバーから到達できる。
3. `sphinx-docs/user/installation.md` で Phase 2 パッケージの
   インストール例が記述されている。
4. `sphinx-docs/user/configuration.md` の "Plugin packages" 表が
   Phase 2 実装済を反映し、各行からガイドページへリンクしている。
5. `sphinx-docs/locale/ja/LC_MESSAGES/user/` の更新は本 steering
   では実施しない (上記 Out of scope) — tasklist に明記。
6. すべての markdown が MyST 構文として有効 (heading / list /
   `{toctree}` directive 等)。本 steering では Sphinx ビルド検証は
   uv toolchain なしのため text-only validation で代替。
7. `tasklist.md` の全タスク（マージタスクを含む）が `[x]` の状態で
   main マージされる。

## 5. 依存・前提

- Phase 2 パッケージの `.resi` および README / examples が main に
  存在 (steering 031/032/035/036/037/039 でマージ済)。
- B 軸 CI (steering 041) は本 steering の作業範囲外だが、新規 .md
  への path filter は不要 (sphinx-docs 用 CI は別運用 = `docs.yml`)。

## 6. リスク

- **Sphinx ビルド未検証**: 環境に uv / sphinx がないため
  `make html` でのビルド成功を直接確認できない。
  `myst-parser` の標準 directive (`{toctree}` / `{note}` /
  fenced code) のみ使用し、未確認の拡張は避ける。
- **日本語翻訳の遅延**: 本 steering で英語ソースのみ追加するため、
  日本語サイトでは新規ページが英文表示のままになる。次回
  `make gettext` / `make update-po` 実行時に .po stub が
  生成され、翻訳作業は別途進める。
- **クロスリンクの整合**: `sphinx-docs/user/index.md` の `toctree`
  追加・既存ページからの参照リンクで誤りがあると linkcheck で
  fail する。手動でリンク先パスを確認する。

## 7. 影響範囲

- 追加: `sphinx-docs/user/plugin-fs.md`, `plugin-dialog.md`,
  `schema.md`
- 更新: `sphinx-docs/user/index.md`, `installation.md`,
  `configuration.md`
- (任意) 更新: `sphinx-docs/index.md`
- 既存パッケージ・examples・テスト・CI には影響なし
