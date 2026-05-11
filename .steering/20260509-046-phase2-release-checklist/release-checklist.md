# Phase 2 リリース当日チェックリスト

> 作業日: TBD（Phase 2 リリース確定時に追記）
> 担当: メンテナ（@Nagatatz）
> 対象パッケージ: `@rescript-tauri/schema`,
> `@rescript-tauri/plugin-fs`, `@rescript-tauri/plugin-dialog`

実装はすべて main にマージ済み (steering 031 / 032 / 035 で binding,
036 / 037 / 039 で examples, 041 で CI / release.yml 拡張, 042 で
sphinx-docs, 043 で README, 044 で CHANGELOG, 045 で PRD §10 #5
確定)。本ドキュメントはリリース当日に **GitHub と npm 上で実施
する手動操作** を 1 ページにまとめる。

Phase 1 (`v0.1.0`) 用は
[`.steering/20260509-029-phase1-release-followups/release-checklist.md`](../20260509-029-phase1-release-followups/release-checklist.md)
を参照。

## 0. 前提条件

- [ ] **Phase 1 (`v0.1.0`) が npm 上に公開済**
  ```bash
  npm view @rescript-tauri/core version
  # 期待: 0.1.0 (またはそれ以上)
  ```
  Phase 2 各パッケージは `peerDependencies: @rescript-tauri/core ^0.1.0`
  を要求するため、Phase 1 が npm に存在しないと利用者の install が
  失敗する。
- [ ] npm 側で各 Phase 2 パッケージの Trusted Publisher が設定済み
  - 対象: `@rescript-tauri/schema`, `@rescript-tauri/plugin-fs`, `@rescript-tauri/plugin-dialog`
  - 各パッケージごとに npm UI で登録（入力値は Phase 1 と同じ:
    provider=GitHub Actions, repo=Nagatatz/rescript-tauri, workflow=release.yml, environment 空欄）
  - 公式手順: [Trusted Publishers (npm Docs)](https://docs.npmjs.com/trusted-publishers)
  - 未公開パッケージの場合は npm UI の "Add new trusted publisher for a new package" を使用
  - `NPM_TOKEN` は不要（OIDC で短命トークンを自動発行、steering 20260512-002）
- [ ] リポジトリが public (Phase 1 release で対応済)
- [ ] Branch protection が `main` に有効 (Phase 1 release で対応済)

## 1. リリース前確認 (前日まで)

### `@rescript-tauri/schema`

- [x] 公開 API が `.resi` で確定
  (`Schema.fromSchemas` / `channelFromSchema` / `eventFromSchema` /
  `toDecoder`、steering 031)
- [x] `packages/schema/README.md` 互換マトリクス記載 (steering 043)
- [x] `packages/schema/CHANGELOG.md` Unreleased エントリ
  (steering 044)
- [x] 専用 CI 緑: `tests-schema-types.yml` /
  `tests-schema-runtime.yml` (steering 041)
- [x] examples 緑: `examples/ipc-typed-with-schema/` を含む
  3-OS matrix (steering 039 + 041)

### `@rescript-tauri/plugin-fs`

- [x] 公開 API が `.resi` で確定 (14 single-shot IO 関数、
  steering 032)
- [x] `packages/plugin-fs/README.md` 互換マトリクス記載
  (steering 043)
- [x] `packages/plugin-fs/CHANGELOG.md` Unreleased エントリ
  (steering 044)
- [x] 専用 CI 緑: `tests-plugin-fs-types.yml` /
  `tests-plugin-fs-runtime.yml` (steering 041)
- [x] examples 緑: `examples/plugin-fs-demo/` を含む 3-OS matrix
  (steering 037 + 041)

### `@rescript-tauri/plugin-dialog`

- [x] 公開 API が `.resi` で確定 (8 関数、steering 035)
- [x] `packages/plugin-dialog/README.md` 互換マトリクス記載
  (steering 043)
- [x] `packages/plugin-dialog/CHANGELOG.md` Unreleased エントリ
  (steering 044)
- [x] 専用 CI 緑: `tests-plugin-dialog-types.yml` /
  `tests-plugin-dialog-runtime.yml` (steering 041)
- [x] examples 緑: `examples/plugin-dialog-demo/` を含む 3-OS
  matrix (steering 036 + 041)

### PRD §10 残課題

- [x] #5 `Mocks` の独立パッケージ化 → core 同梱継続で確定
  (steering 045)

## 2. Cut コミット (バージョン bump + CHANGELOG 日付確定)

リリース日を `YYYY-MM-DD` 形式で確定し、各パッケージの
`package.json` と `CHANGELOG.md` を更新する。

### macOS (BSD sed)

```bash
# 0. main を最新に同期
git checkout main && git pull --ff-only

# 1. リリース日を環境変数に
RELEASE_DATE="2026-MM-DD"   # ← 編集

# 2. schema
sed -i '' 's/"version": "0.0.0"/"version": "0.1.0"/' packages/schema/package.json
sed -i '' "s/^## Unreleased$/## 0.1.0 ($RELEASE_DATE)/" packages/schema/CHANGELOG.md
git add packages/schema/{package.json,CHANGELOG.md}
git commit -m "📝 Cut @rescript-tauri/schema v0.1.0"

# 3. plugin-fs
sed -i '' 's/"version": "0.0.0"/"version": "0.1.0"/' packages/plugin-fs/package.json
sed -i '' "s/^## Unreleased$/## 0.1.0 ($RELEASE_DATE)/" packages/plugin-fs/CHANGELOG.md
git add packages/plugin-fs/{package.json,CHANGELOG.md}
git commit -m "📝 Cut @rescript-tauri/plugin-fs v0.1.0"

# 4. plugin-dialog
sed -i '' 's/"version": "0.0.0"/"version": "0.1.0"/' packages/plugin-dialog/package.json
sed -i '' "s/^## Unreleased$/## 0.1.0 ($RELEASE_DATE)/" packages/plugin-dialog/CHANGELOG.md
git add packages/plugin-dialog/{package.json,CHANGELOG.md}
git commit -m "📝 Cut @rescript-tauri/plugin-dialog v0.1.0"

# 5. sphinx-docs/user/changelog.md の各 Phase 2 セクションを更新
sed -i '' "s/^## \`@rescript-tauri\/schema\` (Unreleased)$/## \`@rescript-tauri\/schema\` 0.1.0 ($RELEASE_DATE)/" sphinx-docs/user/changelog.md
sed -i '' "s/^## \`@rescript-tauri\/plugin-fs\` (Unreleased)$/## \`@rescript-tauri\/plugin-fs\` 0.1.0 ($RELEASE_DATE)/" sphinx-docs/user/changelog.md
sed -i '' "s/^## \`@rescript-tauri\/plugin-dialog\` (Unreleased)$/## \`@rescript-tauri\/plugin-dialog\` 0.1.0 ($RELEASE_DATE)/" sphinx-docs/user/changelog.md
git add sphinx-docs/user/changelog.md
git commit -m "📝 Cut sphinx user changelog for Phase 2 0.1.0 releases"

# 6. push
git push
```

### Linux (GNU sed)

`sed -i ''` を `sed -i` に置き換える以外は同じ。

### 確認

- [ ] `git log --oneline -5` で 4 つの "Cut" コミットが並んでいる
- [ ] `cat packages/{schema,plugin-fs,plugin-dialog}/package.json | grep version`
      がすべて `"version": "0.1.0"` になっている
- [ ] `cat packages/{schema,plugin-fs,plugin-dialog}/CHANGELOG.md | grep '^## '`
      の 1 行目が `## 0.1.0 (YYYY-MM-DD)` になっている
- [ ] `pnpm --recursive build` / `pnpm --recursive test` がすべて
      green

## 3. タグ作成と push

3 タグは独立に切れる。release.yml が tag prefix を解釈して
適切なパッケージを publish する (steering 041 で実装済)。

```bash
# 1 タグずつ push して GitHub Actions の進行を確認するのを推奨
git tag -a schema-v0.1.0 -m "schema-v0.1.0 — Phase 2 schema package"
git push origin schema-v0.1.0
# → GitHub Actions タブで release.yml の進行を確認
# → 完了したら次へ

git tag -a plugin-fs-v0.1.0 -m "plugin-fs-v0.1.0 — Phase 2 plugin-fs package"
git push origin plugin-fs-v0.1.0
# → 完了確認

git tag -a plugin-dialog-v0.1.0 -m "plugin-dialog-v0.1.0 — Phase 2 plugin-dialog package"
git push origin plugin-dialog-v0.1.0
# → 完了確認
```

> 連続 push しても並列実行されるが、GitHub Actions の concurrency
> 制限や npm の publish スロットルを避けるため、1 タグずつ完了を
> 待ってから次を push するのを推奨。

### release.yml の自動処理

タグ push 後、`release.yml` が以下を実行する (steering 041 §3):

1. `Determine target package` ステップで tag prefix を解釈
   (`schema-v*` → `@rescript-tauri/schema`,
   `packages/schema` ディレクトリ)
2. `pnpm --filter <package> build`
3. `pnpm --filter <package> test`
4. `pnpm publish --provenance --access public`
   (NPM_TOKEN が設定されている場合)
5. `gh release create <tag> --generate-notes`

進捗は GitHub Actions タブで確認。

## 4. Dry-run (希望者向け)

GitHub UI または CLI で `release.yml` を `workflow_dispatch` +
`dry_run=true` で起動するとリハーサルできる。ただし
`workflow_dispatch` 時は `release.yml` のロジックが core に
フォールバックするため (steering 041 §3.2)、Phase 2 パッケージの
リハーサル目的では一度タグを切って削除する方法も選択肢:

```bash
# テスト用に schema-v0.1.0-rc1 を切って動作確認
git tag -a schema-v0.1.0-rc1 -m "schema-v0.1.0 dry-run"
git push origin schema-v0.1.0-rc1
# → release.yml が走り、`schema-v*` パターンに合致して
#   schema パッケージを publish しようとする
# → Trusted Publisher が未設定なら publish ステップで失敗、
#   設定済みなら publish される (タグを実際に切るとリアル
#   リリースになるため、rc1 タグでも npm 公開を望まない場合は
#   workflow_dispatch + dry_run=true でリハーサル推奨)
# → 確認後に削除
git tag -d schema-v0.1.0-rc1
git push --delete origin schema-v0.1.0-rc1
```

## 5. リリース後検証

### npm

```bash
npm view @rescript-tauri/schema version          # → 0.1.0
npm view @rescript-tauri/plugin-fs version       # → 0.1.0
npm view @rescript-tauri/plugin-dialog version   # → 0.1.0

npm view @rescript-tauri/schema dist-tags        # → latest: 0.1.0
npm view @rescript-tauri/plugin-fs dist-tags     # → latest: 0.1.0
npm view @rescript-tauri/plugin-dialog dist-tags # → latest: 0.1.0

# peerDependencies が package.json と一致しているか確認
npm view @rescript-tauri/schema peerDependencies
npm view @rescript-tauri/plugin-fs peerDependencies
npm view @rescript-tauri/plugin-dialog peerDependencies
```

### GitHub Releases

- [ ] `https://github.com/Nagatatz/rescript-tauri/releases` に 3 つの
  release ページが存在
  - `schema-v0.1.0`
  - `plugin-fs-v0.1.0`
  - `plugin-dialog-v0.1.0`
- [ ] 各 release に `--generate-notes` で生成された変更ログ要約が
  入っている

### sphinx-docs

- [ ] GitHub Pages が更新済の `sphinx-docs/user/changelog.md` を
  表示している (各 Phase 2 セクションが `0.1.0 (YYYY-MM-DD)`
  ヘッダになっている)
- [ ] User guide の `plugin-fs` / `plugin-dialog` / `schema` ページ
  が引き続き表示できている

### 互換マトリクス整合

各 README の互換マトリクスと `npm view <pkg> peerDependencies`
が一致していることを確認。steering 043 で揃えたバージョン値が
publish 時にも保たれている。

## 6. スモーク試験

```bash
# schema
mkdir /tmp/rt-smoke-schema && cd /tmp/rt-smoke-schema
pnpm init -y
pnpm add @rescript-tauri/core @rescript-tauri/schema rescript-schema \
         @tauri-apps/api rescript @rescript/core
pnpm exec rescript -version  # >= 12.0.0

# plugin-fs
mkdir /tmp/rt-smoke-plugin-fs && cd /tmp/rt-smoke-plugin-fs
pnpm init -y
pnpm add @rescript-tauri/core @rescript-tauri/plugin-fs \
         @tauri-apps/api @tauri-apps/plugin-fs rescript @rescript/core
pnpm exec rescript -version

# plugin-dialog
mkdir /tmp/rt-smoke-plugin-dialog && cd /tmp/rt-smoke-plugin-dialog
pnpm init -y
pnpm add @rescript-tauri/core @rescript-tauri/plugin-dialog \
         @tauri-apps/api @tauri-apps/plugin-dialog rescript @rescript/core
pnpm exec rescript -version
```

各ディレクトリで `pnpm install` が peer dep の resolution エラー
なしに完了することを確認。

## 7. 告知 (オプション)

Phase 1 と同じ媒体:

- [ ] [ReScript Forum](https://forum.rescript-lang.org/) に Phase 2
  リリースアナウンス (Layer 3 schema 統合 + plugin-fs / plugin-dialog
  の追加が主軸)
- [ ] [Tauri Discord](https://discord.com/invite/tauri) #showcase
- [ ] X/Twitter / Bluesky 等

## 8. Phase 3 起点準備

- [ ] `.steering/` 直下のうち最終コミット日が 30 日以上前のものを
  `.steering/archive/` へ移動 (steering 030〜046 のうち該当分)
- [ ] Phase 3 planning steering を 1 件作成
  - Should スコープ: `@rescript-tauri/plugin-opener`,
    `@rescript-tauri/plugin-process`, Mocks 拡張
  - Could スコープ: `@rescript-tauri/plugin-updater`,
    `@rescript-tauri/plugin-shell` (セキュリティ評価必須),
    `@rescript-tauri/plugin-store`
  - core API: Phase 1 見送り API の再評価 (PRD §10 残 #2 / #3 /
    #4 / #6 など)

## 9. ロールバック (publish 失敗時)

各パッケージに対し:

```bash
# npm 側のロールバックは「unpublish」でなく「deprecate」を推奨
npm deprecate @rescript-tauri/<pkg>@0.1.0 \
  "0.1.0 has a critical issue, please wait for 0.1.1"

# tag は移動できないため、修正後は 0.1.1 として再リリースする
git tag -a <pkg>-v0.1.1 -m "..."
git push origin <pkg>-v0.1.1
```

`npm unpublish` は 72 時間以内のみ可能で、そのパッケージ名
+バージョン組合わせの再 publish が 24 時間ロックされるため
実運用では `deprecate + 0.1.1` を推奨。

---

## 連絡先

- メンテナ: @Nagatatz
- リポジトリ: https://github.com/Nagatatz/rescript-tauri
- 関連 PRD: `docs/product-requirements.md` §8, §10
- Phase 1 release checklist:
  [`.steering/20260509-029-phase1-release-followups/release-checklist.md`](../20260509-029-phase1-release-followups/release-checklist.md)
- Phase 2 planning:
  [`.steering/20260509-030-phase2-planning/`](../20260509-030-phase2-planning/)
