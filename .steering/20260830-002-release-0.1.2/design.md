# Design: 全パッケージ 0.1.2 メンテナンスリリース

## D1. バージョン bump

`sed -i 's/"version": "0.1.1"/"version": "0.1.2"/' packages/*/package.json`。`pnpm-lock.yaml` は workspace パッケージの version を保持しないため変更不要（`pnpm install --frozen-lockfile` で確認）。

## D2. CHANGELOG

各 `## Unreleased` ブロック（見出し〜次の `## ` まで）を Python で置換。本文テンプレート:

```
## 0.1.2 (2026-08-30)

Maintenance release — no runtime or API changes.

### Changed

- Bumped development dependencies to their latest patch / minor
  releases (<package 固有リスト>). The published artifacts are unaffected.
```

## D3. sphinx changelog

`sphinx-docs/user/changelog.md` の note を「全 10 パッケージは npm 公開済み（最新 0.1.2）。各パッケージの正本は `packages/<name>/CHANGELOG.md`」に改め、`## Maintenance releases` セクションに 0.1.1 / 0.1.2 の 2 entry を追加。`make update-po` → `locale/ja/LC_MESSAGES/user/changelog.po` の新規 msgid を翻訳、fuzzy 解消。

## D4. タグ push（0.1.1 と同一手順、PR #14 参照）

```
for t in v schema-v plugin-fs-v plugin-dialog-v plugin-shell-v plugin-notification-v plugin-log-v plugin-os-v plugin-clipboard-manager-v plugin-http-v; do
  git tag -a "${t}0.1.2" <merge-commit> -m "${t}0.1.2 — Maintenance release"
done
git push origin --tags   # または個別 push
```

`release.yml` は tag ごとに 1 run（build → test → `npm publish --provenance` → `gh release create`）。

### D4.1 実装時に判明した事項

- `git push origin --tags` / 複数 tag の一括 push では **push イベントが生成されず release.yml が起動しない**（GitHub Actions の仕様: 1 回の push で 4 個以上の tag を含むとイベントを作らない）。0.1.1 のときは 8 秒間隔で 1 本ずつ push していた。
- 対処: `git push origin :refs/tags/<tag>` で remote tag を削除 → `git push origin refs/tags/<tag>` を 1 本ずつ（`sleep 8` 挟み）実行。ローカル tag はそのまま流用可。
- `npm view <pkg> version` は publish 直後数分は旧版を返すことがある。`https://registry.npmjs.org/<pkg>` の `dist-tags` で確認する。

## テスト方針

コード変更なし。既存テスト全件 pass + release.yml の build/test ステップで回帰確認。
