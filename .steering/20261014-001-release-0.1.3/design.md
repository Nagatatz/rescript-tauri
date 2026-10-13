# Design: 0.1.3 リリース（plugin-notification は 0.2.0）

## D1. バージョン bump

`packages/plugin-notification/package.json` を `0.2.0`、他 9 件を `0.1.3` に書き換える。`pnpm-lock.yaml` は workspace パッケージの version を保持しないため変更不要（`pnpm install --frozen-lockfile` で確認）。examples は `workspace:*` 参照のため影響なし。

## D2. CHANGELOG

- core / plugin-fs / plugin-shell: `## Unreleased` → `## 0.1.3 (2026-10-14)`
- plugin-notification: `## Unreleased` → `## 0.2.0 (2026-10-14)`
- 残り 6 件: `## 0.1.2 (2026-08-30)` の直前に以下を挿入（上流 plugin を持たない schema は該当項目を省く）

```
## 0.1.3 (2026-10-14)

Maintenance release — no runtime or API changes.

### Changed

- Bumped development dependencies to their latest releases (<固有リスト>).
  The published artifacts are unaffected.
```

## D3. タグ

| パッケージ | tag |
|---|---|
| core | `v0.1.3` |
| schema | `schema-v0.1.3` |
| plugin-notification | `plugin-notification-v0.2.0` |
| 他 plugin 7 件 | `plugin-<name>-v0.1.3` |

`release.yml` の tag パターンは `plugin-notification-v*` なので 0.2.0 でもそのまま起動する。merge commit に annotated tag を作成し、`git push origin refs/tags/<tag>` を 1 本ずつ（間隔を空けて）実行する（steering 20260830-002 D4.1 の教訓）。push のたびに `gh run list --workflow=release.yml` で起動を確認する。

core を最初に公開する。plugin の peer は `^0.1.0` で 0.1.2 でも満たされるため順序依存は無いが、利用者が plugin だけ先に更新しても新しい core を取得できる状態にしておく。

## D4. ドキュメント

バージョンが揃わなくなるため「current release `0.1.2`」は「`0.1.3`（`plugin-notification` は `0.2.0`）」と書く。

## テスト方針

コード変更なし。既存テスト全件 pass + release.yml の build / test ステップで回帰確認。
