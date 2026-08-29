# Requirements — funding フィールドを全パッケージに追加

| 項目 | 内容 |
|---|---|
| ステアリング番号 | 20260512-005 |
| 作成日 | 2026-05-12 |
| 種別 | 設定変更（全 10 パッケージの `package.json` に `funding` フィールド追加） |
| 関連 | 20260512-004 (v0.1.0 リリース), 20260512-003 (package reservation tooling) |

## 1. 背景

v0.1.0 リリース時点で、`packages/*/package.json` のいずれにも `funding` フィールドが存在しない。npm では `funding` を宣言すると、利用者が `npm install` した後に「N packages are looking for funding, run `npm fund` for details」と表示され、`npm fund` でツリー表示・URL 確認・ブラウザ起動が可能になる。

OSS のサステナビリティ観点からも、リポジトリ owner への支援動線を npm エコシステム標準の形で提供しておく価値がある。

## 2. ゴール

全 10 パッケージ (`core`, `plugin-fs`, `plugin-dialog`, `plugin-shell`, `plugin-notification`, `plugin-log`, `plugin-os`, `plugin-clipboard-manager`, `plugin-http`, `schema`) の `package.json` に `funding` フィールドを統一フォーマットで追加する。

## 3. 受入条件

- [ ] 10 パッケージすべての `package.json` に `funding` フィールドが追加されている
- [ ] フォーマットは全パッケージで統一されている（type + url の object 形式）
- [ ] `pnpm --recursive build` が成功する（package.json の構文破壊が無いことの確認）
- [ ] `pnpm run check` が green（Biome の JSON format に違反しない）
- [ ] CHANGELOG への追記は不要（公開 API 変更ではなく metadata 追加のため）

## 4. funding URL の選択

候補:

| 案 | URL | 備考 |
|---|---|---|
| A | `https://github.com/sponsors/Nagatatz` | GitHub Sponsors。最も一般的・`npm fund` で `type: "github"` として認識される |
| B | `https://github.com/Nagatatz/rescript-tauri` | repo URL フォールバック。Sponsors 未設定でも 404 にならない |
| C | A + B の複数（配列） | 一次は Sponsors、二次は repo |

**確定: A (`https://github.com/sponsors/Nagatatz`)** — ユーザー承認 (2026-05-12)

理由: npm の慣例上最も標準的。GitHub Sponsors が未設定の場合は GitHub 側でデフォルトの導線（リポジトリページへの誘導等）が表示されるため、404 にはならない。

## 5. Non-goals

- 個別パッケージごとに異なる funding URL を設定すること（統一フォーマット原則を優先）
- `package.json` のその他フィールド整理（別ステアリングで扱う）
- GitHub Sponsors の有効化作業（リポジトリ側の設定で別途実施）
- ルート `package.json` への追加（公開対象ではないため対象外）

## 6. 影響範囲

- 公開済み v0.1.0 には影響しない（既存バージョンの metadata は不変）
- 次回 publish される v0.1.1 以降から `funding` が npm registry に反映される
- 既存利用者には `npm install` 時の出力に「looking for funding」行が増えるのみで、機能的影響なし
