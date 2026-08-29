# Requirements: Package READMEs (Phase 2 互換マトリクス整備)

| 項目 | 内容 |
|---|---|
| ステアリング ID | 20260509-043 |
| 親プラン | `.steering/20260509-030-phase2-planning/` §I (Phase 2 完了条件) — 各パッケージ README に互換マトリクス記載 |
| 関連パッケージ | `core`, `schema`, `plugin-fs`, `plugin-dialog` |
| 作成日 | 2026-05-09 |

---

## 1. 背景

Phase 2 完了条件 §I の「各パッケージの README に互換マトリクス記載」
を満たす。現状は:

- **core**: README が Phase 1 着手前の状態のまま (45 行)。
  「Only `Core.Raw.invoke` is implemented at this commit」など
  すべて古い記述で、互換マトリクスも無い。Phase 1 完了 (Tauri /
  Window / Webview / Menu / Tray ... 12 モジュール) を反映する必要。
- **schema / plugin-fs / plugin-dialog**: 互換マトリクスは既に
  記載済 (steering 031 / 032 / 035 で実装と同時に追加された)。
  ただし以下が欠けている:
  - `rescript` / `@rescript/core` の toolchain 行
  - sphinx-docs (`user/<name>.md`) ガイドへのリンク
  - 対応 example (`examples/<demo>/`) へのリンク
  - schema README の Status 文言が "under active development" で
    実装完了後の表現になっていない

## 2. 目的

- 4 パッケージすべての README が `npm` ページから最初に読まれる
  ドキュメントとして自己充足する状態にする。
- 互換マトリクスを toolchain 行込みで揃える。
- npm 訪問者が sphinx-docs ガイドや example へすぐ遷移できるよう
  See also 節を追加する。
- core README を Phase 1 完了状態に更新し、API 概要 + Tauri 上位
  re-export の説明を含める。

## 3. スコープ

### Must

#### `packages/core/README.md`

- Status: "Phase 1 — implementation in progress" → "Phase 1 —
  feature-complete on `main`. Awaiting first npm publish (`v0.1.0`)."
- 「Only `Core.Raw.invoke` is implemented」など古い文言を削除
- API 概要: 12 モジュール表 (sphinx-docs/user/index.md と整合)
- 互換マトリクス (toolchain 行 + Tauri / @tauri-apps/api 行)
- See also: sphinx-docs (`user/index.md`, `user/quickstart.md`),
  examples (`hello-world` / `window-management` / `ipc-typed` /
  `streaming-ipc`)

#### `packages/schema/README.md`

- 互換マトリクスに toolchain 行追加
- Status を実装完了済 + publish pending に
- See also: sphinx-docs `user/schema.md`, examples
  `ipc-typed-with-schema`

#### `packages/plugin-fs/README.md`

- 互換マトリクスに toolchain 行追加
- See also: sphinx-docs `user/plugin-fs.md`, examples
  `plugin-fs-demo`
- 落とし穴節 (`{baseDir: baseDir}` punning, `TypedArray.length`)

#### `packages/plugin-dialog/README.md`

- 互換マトリクスに toolchain 行追加
- See also: sphinx-docs `user/plugin-dialog.md`, examples
  `plugin-dialog-demo`
- "deferred to follow-up sub-steerings" 節から
  "plugin-dialog example app と専用 CI" を **完了済** に変える
  （steering 036 で plugin-dialog-demo 追加済、steering 041 で
  CI 追加済のため）

### Should（余裕があれば）

- 互換マトリクスのフォーマットを 4 README で統一 (列順 / 列名)
- 各 README の冒頭に "Status / Install / Quick example /
  Compatibility / Public API / See also" の同じ節構成
- npm 公開前を前提とした Status 文言を統一

### 非対象（Out of scope）

- 各パッケージの公開関数を増やす変更 (binding 本体の改変)
- リポジトリルートの README.md 更新（別軸）
- CHANGELOG (§I の別タスク)
- 実 npm publish (§I の別タスク)
- 日本語 README (現状英語のみ)

## 4. 受け入れ条件

1. 4 パッケージの README が以下の節を持つ:
   - Status (Phase / publish 状態)
   - Install (planned)
   - Quick example
   - Compatibility matrix (toolchain 行 + 上流 dep 行)
   - Public API (一行サマリ表)
   - See also (sphinx-docs + examples へのリンク)
2. 互換マトリクスの列構成が 4 README で統一されている
3. core README が Phase 1 完了状態を反映している
4. plugin-dialog README の "Deferred to follow-up sub-steerings"
   節が plugin-dialog-demo / CI 完了を反映している
5. `pnpm --recursive build` / `pnpm --recursive test` が引き続き
   全件パスする（README のみの変更で実コードに影響しないため）
6. `tasklist.md` の全タスクが `[x]` の状態で main マージされる

## 5. 依存・前提

- Phase 1 / Phase 2 の API 表面が main にすべて存在
  (steering 005-027, 031, 032, 035, 036, 037, 039, 041, 042 で merged)
- sphinx-docs/user/{plugin-fs,plugin-dialog,schema}.md が存在
  (steering 042 で merged)

## 6. リスク

- **互換マトリクスの細かな食い違い**: 各 README で同じ peer dep の
  バージョンレンジ表記が異なるとユーザー混乱。本 steering で 4 README
  を一度に揃える。
- **sphinx-docs と README の相対 link**: README は npm 公開時に
  npm ページで表示されるため、相対リンクは broken になる。github
  上の絶対 URL (`https://github.com/Nagatatz/rescript-tauri/blob/main/...`)
  か npm 互換の説明にする。既存 schema/plugin-* READMEs は
  `../../docs/...` の相対リンクを使っており、これは npm では切れる。
  本 steering では既存パターンを維持しつつ、新規追加リンクは
  GitHub 絶対 URL にする (sphinx-docs ガイドへの誘導は npm でも
  到達可能であるべきため)。
- **自動公開 README ベリファイ**: npm publish の README プレビュー
  検証は本 steering では行わず、Phase 2 publish steering 時に行う。

## 7. 影響範囲

- 更新: `packages/core/README.md`, `packages/schema/README.md`,
  `packages/plugin-fs/README.md`, `packages/plugin-dialog/README.md`
- 既存パッケージのコード・テスト・CI には影響なし
