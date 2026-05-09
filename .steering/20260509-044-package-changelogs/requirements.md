# Requirements: Per-package CHANGELOGs

| 項目 | 内容 |
|---|---|
| ステアリング ID | 20260509-044 |
| 親プラン | `.steering/20260509-030-phase2-planning/` §I (Phase 2 完了条件) — `CHANGELOG が各パッケージで 0.1.0 以降の履歴を持つ` |
| 関連パッケージ | `core`, `schema`, `plugin-fs`, `plugin-dialog` |
| 作成日 | 2026-05-09 |

---

## 1. 背景

Phase 2 完了条件 §I の「CHANGELOG が各パッケージで `0.1.0` 以降の
履歴を持つ」を満たす。現状は:

- `packages/<pkg>/` 配下に `CHANGELOG.md` は **存在しない**
  (4 パッケージすべて未作成)
- `sphinx-docs/user/changelog.md` は core 単独の Phase 1
  Unreleased 履歴のみ記載
- `release.yml` は GitHub Release 作成時に `--generate-notes` で
  自動 release notes を生成しているが、これは npm 上の package
  ページや repo 内の CHANGELOG にはならない

各パッケージの最初の publish (`v0.1.0` / `schema-v0.1.0` /
`plugin-fs-v0.1.0` / `plugin-dialog-v0.1.0`) に向けて CHANGELOG
ファイルを各パッケージに追加し、リリース運用の起点を整える。

## 2. 目的

- 4 パッケージそれぞれに `CHANGELOG.md` を新設し、初回リリース
  (`0.1.0`) 向けの Unreleased エントリを書き起こす。
- 4 ファイルすべて
  [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/)
  形式で統一する。
- 各 README から `CHANGELOG.md` への参照を加え、npm ページ訪問者が
  履歴を辿れるようにする。
- `sphinx-docs/user/changelog.md` を Phase 2 を含む全 4 パッケージ
  をカバーするよう更新する。

## 3. スコープ

### Must

#### 新規ファイル (4 件)

- `packages/core/CHANGELOG.md`
  - Unreleased セクション (Phase 1 内容)
  - 既存 sphinx changelog の Added エントリを移植・要約
- `packages/schema/CHANGELOG.md`
  - Unreleased: `Schema.fromSchemas` / `channelFromSchema` /
    `eventFromSchema` / `toDecoder` の初版実装
- `packages/plugin-fs/CHANGELOG.md`
  - Unreleased: 14 single-shot IO 関数の初版実装
- `packages/plugin-dialog/CHANGELOG.md`
  - Unreleased: 8 関数 (open*4 + save + message + ask + confirm)
    の初版実装

#### 既存ファイル更新

- `sphinx-docs/user/changelog.md`
  - Phase 2 パッケージ (schema / plugin-fs / plugin-dialog) の
    Unreleased セクションを追加
  - 既存 core セクションは維持
  - 各セクションの先頭で対応する `packages/<pkg>/CHANGELOG.md` への
    参照を貼る (絶対 GitHub URL)
- 4 パッケージの `README.md` に「Changelog: see
  [`CHANGELOG.md`](./CHANGELOG.md)」相当の See also エントリを追加
  - 既存の See also 節がある場合 (steering 043 で追加した) は
    そこに 1 行追加

### Should（余裕があれば）

- `release.yml` に `--notes-from-tag` または明示的な `--notes-file`
  を渡し、CHANGELOG.md の該当バージョン節をリリース本文に流用する
  仕組み — Phase 2 完了条件外なので任意

### 非対象（Out of scope）

- 実 npm publish (タグ push 後のジョブで実行される予定)
- 古いコミットの細粒度履歴の再構成 (Unreleased 一括で十分)
- リポジトリルートの CHANGELOG (モノレポでは各パッケージ単位の
  CHANGELOG が source of truth)
- 日本語 CHANGELOG (英語のみ)

## 4. 受け入れ条件

1. 4 パッケージそれぞれに `CHANGELOG.md` が新規追加される。
2. すべて Keep a Changelog 1.1.0 形式 (`## Unreleased` →
   `### Added` / `Changed` / `Fixed` / `Removed` セクション、
   semver タグ付きヘッダ、リリース日 ISO 形式) に従う。
3. 各 `CHANGELOG.md` の先頭に
   ["Keep a Changelog](https://keepachangelog.com/en/1.1.0/) +
   [Semantic Versioning](https://semver.org/spec/v2.0.0.html)
   準拠" の宣言コメントが含まれる。
4. 各 README に CHANGELOG への参照リンクが追加される。
5. `sphinx-docs/user/changelog.md` が 4 パッケージすべての
   Unreleased を反映する。
6. `pnpm --recursive build` / `pnpm --recursive test` が引き続き
   全件パスする (ドキュメントのみの変更)。
7. `tasklist.md` の全タスク (マージタスクを含む) が `[x]` の状態で
   main マージされる。

## 5. 依存・前提

- `packages/<pkg>/package.json` に `0.0.0` の version が入っている
  (publish 時点で `0.1.0` に bump されるが、CHANGELOG では Unreleased
  扱い)。
- 既存 `sphinx-docs/user/changelog.md` の文章を流用できる。

## 6. リスク

- **ヘッダリンクの衝突**: 4 CHANGELOG で `## Unreleased` が
  繰り返されるが、各ファイル内では一意。
- **リリースタグ ↔ CHANGELOG バージョンの一貫性**: タグは
  `schema-v0.1.0` 形式、CHANGELOG ヘッダは `## 0.1.0 (YYYY-MM-DD)`
  形式 (タグ prefix を含めない、conventional な keepachangelog 形式)。
- **既存 sphinx changelog の表記揺れ**: Unreleased の内容詳細度を
  4 パッケージで揃えるか、簡潔版にするか。要件としては実装ハイ
  ライト + テスト + examples の存在まで言及できれば十分。

## 7. 影響範囲

- 追加: `packages/{core,schema,plugin-fs,plugin-dialog}/CHANGELOG.md`
- 更新: `packages/{core,schema,plugin-fs,plugin-dialog}/README.md`
  (See also に CHANGELOG リンク追加)
- 更新: `sphinx-docs/user/changelog.md`
- 既存パッケージのコード・テスト・CI には影響なし
