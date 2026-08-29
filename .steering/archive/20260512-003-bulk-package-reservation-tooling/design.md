# Design: Bulk Package Reservation & Trusted Publisher Setup Tooling

| 項目 | 内容 |
|---|---|
| 作成日 | 2026-05-12 |
| 関連 | requirements.md |

## 1. ファイル配置

```
tools/
├── reserve-npm-packages.sh        # 新規 (9 packages reservation)
├── setup-trusted-publishers.sh    # 新規 (10 packages trust setup)
├── vitest.shared.mjs              # 既存
└── tauri-mocks.mjs                # 既存
```

`tools/` は CLAUDE.md ＆ `docs/repository-structure.md` で「リポジトリ共通の Node ツール」と定義されているが、bash スクリプトも同居させる。役割は同じ「リポジトリ運用補助」。

## 2. `tools/reserve-npm-packages.sh`

### 2.1 動作

1. 一時ディレクトリ `/tmp/rt-reserve` を作成
2. 9 パッケージごとに以下を実行:
   a. サブディレクトリ作成
   b. `package.json` を生成（name / version=`0.0.0-reserved` / description / license / repository / publishConfig）
   c. `README.md` を生成（reservation 説明）
   d. `npm publish --tag reserved` を実行
3. 完了後 `/tmp/rt-reserve` を削除
4. 各パッケージの登録状況を `npm view <pkg> version` で検証

### 2.2 冪等性

各 publish 前に `npm view "@rescript-tauri/$pkg" version 2>/dev/null` で存在チェック。既に登録済みなら **skip して進む** (エラーで止めない)。これにより一部失敗時の再実行が安全。

### 2.3 シェル設計

- shebang `#!/usr/bin/env bash`
- `set -euo pipefail`
- 配列で 9 パッケージリストを保持
- 各 publish の前後にエコー（進捗が見える）

### 2.4 出力例

```
=== Reserving @rescript-tauri/schema@0.0.0-reserved ===
  + @rescript-tauri/schema@0.0.0-reserved
=== Reserving @rescript-tauri/plugin-fs@0.0.0-reserved ===
  ⚠ already exists, skipping
=== ...
✓ All packages reserved
```

## 3. `tools/setup-trusted-publishers.sh`

### 3.1 動作

1. `npm` バージョンチェック (11.10.0 以上が必要)
2. 10 パッケージリストをループ
3. 各パッケージで `npm trust github "@rescript-tauri/$pkg" --file release.yml --repo Nagatatz/rescript-tauri --yes` を実行
4. `npm trust list` で確認

### 3.2 core の扱い

core は Web UI で既に設定済み。`npm trust github` を再実行すると以下のいずれかが発生:

- (a) 上書き成功 → 同じ設定なので問題なし
- (b) 既存があるためエラー → スクリプトを `|| true` でラップして無視

(a) を期待しつつ、念のため (b) でも止まらないように `|| echo "  (already configured)"` で fallback する。

スクリプト先頭に `SKIP_CORE=false` の環境変数を用意し、`SKIP_CORE=true bash tools/setup-trusted-publishers.sh` で core を除外できるオプションも提供。

### 3.3 シェル設計

- shebang `#!/usr/bin/env bash`
- `set -euo pipefail`
- npm CLI バージョン検査（11.10.0 未満ならエラーで終了）
- 各 trust 設定の前後にエコー

## 4. ドキュメント更新

### 4.1 `docs/repository-structure.md`

§10「`tools/` — リポジトリ共通の Node ツール」の table に 2 行追加:

| ファイル | 役割 |
|---|---|
| `reserve-npm-packages.sh` | npm scope `@rescript-tauri/*` 配下の未公開パッケージを `0.0.0-reserved` で一括予約する bash スクリプト (steering 003) |
| `setup-trusted-publishers.sh` | `npm trust github` CLI で 10 パッケージの Trusted Publisher を一括設定する bash スクリプト (steering 003) |

### 4.2 `.steering/20260508-007-npm-scope-reservation/report.md`

§6 Step 6 を以下に置換:

> ### Step 6: 残りパッケージの予約
>
> 残り 9 パッケージ（schema, plugin-fs, plugin-dialog, plugin-shell, plugin-notification, plugin-log, plugin-os, plugin-clipboard-manager, plugin-http）は `tools/reserve-npm-packages.sh` で一括予約できる:
>
> ```bash
> bash tools/reserve-npm-packages.sh
> ```
>
> 詳細は `.steering/20260512-003-bulk-package-reservation-tooling/` 参照。

## 5. 検証

### 5.1 構文検証

```bash
bash -n tools/reserve-npm-packages.sh
bash -n tools/setup-trusted-publishers.sh
```

### 5.2 dry-run 的な検証

`shellcheck` がインストール済みなら:

```bash
shellcheck tools/reserve-npm-packages.sh
shellcheck tools/setup-trusted-publishers.sh
```

### 5.3 実行検証

スクリプトの実行はユーザー側で 2FA OTP を伴うため、本ステアリングでは行わない。実行後の検証はユーザーが `npm view` / `npm trust list` で確認する。

## 6. リスク

| リスク | 対策 |
|---|---|
| スクリプトが誤って既存パッケージを上書き | 冪等性チェック (`npm view ... version`) で skip |
| 2FA OTP 入力タイムアウトで途中失敗 | 失敗箇所から再実行可能（冪等性で重複 skip） |
| `npm trust github` で既存設定の上書きエラー | `|| echo "(already configured)"` で fallback |
| npm CLI が古くて `npm trust` が無い | スクリプト先頭でバージョン検査して即終了 |
| `tools/` に bash と JS が混在して責務不明瞭 | `docs/repository-structure.md` で「Node ツール + bash 運用スクリプト」と説明 |
