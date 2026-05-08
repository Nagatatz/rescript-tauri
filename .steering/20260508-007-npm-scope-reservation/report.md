# 手順書: npm scope `@rescript-tauri` の予約

| 項目 | 内容 |
|---|---|
| 作業 ID | 20260508-007 |
| タイトル | npm-scope-reservation |
| 種別 | 調査 + ユーザー手動操作の手順書（`steering-workflow.md` の「調査・リサーチタスク」枠 + ユーザー手動作業の補助）|
| 起票日 | 2026-05-08 |
| 起票者 | ユーザー指示（drift analysis 006 の唯一の未対応項目 No.6 を解消） |

## 1. 背景と動機

`docs/ideas/RFC-0001-core-api-design.md` §15 Decision checklist の行 1:

> [ ] npm scope `@rescript-tauri` is reserved.

これは **Phase 0 完了の必須条件** として明示されているが、bootstrap 完了時点でも未対応。drift analysis (steering 006 / report.md No.6) でも唯一の未対応項目として記録されている。

**リスク**: scope `@rescript-tauri` を他者に取得されると、Phase 1 リリース時にパッケージ命名を変更する破壊的影響が発生する。早期予約が望ましい。

## 2. 現状調査（2026-05-08 時点）

### 2.1 npm registry での確認結果

すべて Claude が read-only で確認:

| 確認対象 | コマンド | 結果 |
|---|---|---|
| `@rescript-tauri/core` | `npm view @rescript-tauri/core` | E404 (未取得) |
| `@rescript-tauri/cli` | `npm view @rescript-tauri/cli` | E404 |
| `@rescript-tauri/schema` | `npm view @rescript-tauri/schema` | E404 |
| `@rescript-tauri/plugin-fs` | `npm view @rescript-tauri/plugin-fs` | E404 |
| `@rescript-tauri/plugin-dialog` | `npm view @rescript-tauri/plugin-dialog` | E404 |
| `@rescript-tauri/mocks` | `npm view @rescript-tauri/mocks` | E404 |
| Org `rescript-tauri` | `curl https://registry.npmjs.org/-/org/rescript-tauri` | HTTP 404 (未登録) |
| Search `scope:rescript-tauri` | `curl https://registry.npmjs.org/-/v1/search?text=scope:rescript-tauri` | hits = 0 |

**結論**: scope `@rescript-tauri` は **完全に空き**。新規取得可能。

### 2.2 npm の scope 取得ルール

npm では `@xxx/...` への publish は `xxx` が以下のいずれかでなければならない:

1. **npm user 名** に紐づく user scope (例: 個人アカウントが `Nagatatz` なら `@nagatatz/...` のみ publish 可)
2. **npm Organization (Org) 名** に紐づく org scope

`@rescript-tauri` は user 名ではなく **Org として作成する必要** がある。npm Org の Free Plan は無料 (public packages のみ)、Pro Plan は $7/user/月。本プロダクトは OSS で public のみのため Free Plan で十分。

## 3. Claude が実行できない理由

| 操作 | 不可能な理由 |
|---|---|
| `npm login` / `npm adduser` | 対話的認証 + ユーザー個人アカウント |
| `npm org create rescript-tauri` (Web UI) | npm Org 作成は Web ブラウザの操作が必要 (CLI 単独では完結しない) |
| `npm publish` | 認証情報が必要 + 公開操作で blast radius 大 |

→ 以降の手順は **ユーザー手動で実行**。Claude は予約完了後の文書反映で支援する。

## 4. ユーザー手順（推奨ルート: Web UI）

### Step 1: npm アカウント確認

既に npm アカウントを持っている場合: skip して Step 2 へ。

未取得の場合:

- <https://www.npmjs.com/signup> でアカウント作成
- 2FA を有効化（推奨。npm publish 時に OTP を要求される）
  - <https://docs.npmjs.com/configuring-two-factor-authentication>

### Step 2: npm Organization `rescript-tauri` を作成

- <https://www.npmjs.com/org/create> にアクセス
- Organization name: **`rescript-tauri`** （ハイフン区切り、小文字）
- Plan: **Free** （`Unlimited public packages`）を選択
- 作成完了後、自分が **Owner** ロールであることを確認

GitHub Org / Personal account 連携は任意。本プロジェクトの GitHub repo (`Nagatatz/rescript-tauri`) と npm Org (`rescript-tauri`) を将来 npm の "Trusted Publisher" (OIDC) で結びつける場合に有用。

### Step 3: ローカルマシンで npm にログイン

```bash
npm login
# username: <your npm username>
# password: <your password>
# email: <your email>
# OTP: <2FA code if enabled>

npm whoami
# → 自分の npm username が表示されれば OK
```

### Step 4: dummy package を publish して scope を確実に占有

`@rescript-tauri/core` の最初のバージョンとして `0.0.0-reserved` を publish する。これにより npm registry 上で scope + パッケージ名の両方が予約される。

#### (a) ローカル一時ディレクトリで dummy package を準備

```bash
cd /tmp
mkdir rescript-tauri-reserve && cd rescript-tauri-reserve

cat > package.json <<'EOF'
{
  "name": "@rescript-tauri/core",
  "version": "0.0.0-reserved",
  "description": "Reserved name. The actual package will be published at the Phase 1 release. See https://github.com/Nagatatz/rescript-tauri",
  "license": "MIT",
  "homepage": "https://github.com/Nagatatz/rescript-tauri",
  "repository": {
    "type": "git",
    "url": "git+https://github.com/Nagatatz/rescript-tauri.git"
  },
  "publishConfig": {
    "access": "public"
  }
}
EOF

cat > README.md <<'EOF'
# @rescript-tauri/core (reserved)

This is a name reservation. The actual package will be published at the Phase 1 release of [rescript-tauri](https://github.com/Nagatatz/rescript-tauri).

ReScript bindings for Tauri 2.x's official JS SDK (`@tauri-apps/api`).
EOF
```

#### (b) Publish

```bash
npm publish --tag reserved
# → 2FA を有効化していれば OTP を要求される
# → 成功すると "+ @rescript-tauri/core@0.0.0-reserved" が表示される
```

**`--tag reserved` は必須**。`0.0.0-reserved` は SemVer 上の **prerelease バージョン**（hyphen 以降が pre-release identifier として解釈される）で、npm は明示 dist-tag なしの prerelease publish を以下のエラーで拒否する:

```
npm error You must specify a tag using --tag when publishing a prerelease version.
```

`--tag reserved` を指定すると dist-tag `reserved` に割り当てられ、デフォルトの `latest` タグには何も入らない。これにより後で Phase 1 の正式リリース時に `npm publish`（タグなし、デフォルト `latest`）を実行したとき、`npm install @rescript-tauri/core` が **正式版** を取得する正しい挙動になる（`reserved` タグの dummy ではなく）。

`access: "public"` は scoped package を公開で publish するために必須（デフォルトは private で、Free Plan では publish できない）— `package.json` の `publishConfig.access` で設定済み。

##### Phase 1 リリース時の挙動

正式版 `0.1.0` を publish するときは `--tag` 不要:

```bash
# Phase 1 リリース時
npm publish        # → @rescript-tauri/core@0.1.0 が dist-tag latest に
```

dummy `0.0.0-reserved` は `reserved` タグに残り続けるが、`npm install` のデフォルト挙動には影響しない。気になる場合は `npm dist-tag rm @rescript-tauri/core reserved` で reserved タグを除去できる（dummy version 自体は npm の unpublish 制約上残る）。

#### (c) 後始末

```bash
cd /tmp && rm -rf rescript-tauri-reserve
```

### Step 5: 予約完了の検証

```bash
npm view @rescript-tauri/core
# → name: @rescript-tauri/core
#   version: 0.0.0-reserved
#   ... 正常に取得できれば予約完了
```

ブラウザでも確認可能:

- <https://www.npmjs.com/package/@rescript-tauri/core>
- <https://www.npmjs.com/org/rescript-tauri>

### Step 6 (任意): 他のパッケージ名も予約

Phase 2+ で計画されている `@rescript-tauri/plugin-fs` / `plugin-dialog` / `schema` も同じ手順で予約しておくと、命名衝突リスクをさらに排除できる。dummy 内容は同じパターンで `name` だけ変える。

ただし scope `@rescript-tauri` 自体が予約されている限り、scope 配下の他のパッケージ名はその scope の Org 所有者しか publish できないため、**最初の 1 個 `@rescript-tauri/core` だけ publish すれば実用上は十分**。残りはオプション。

## 5. 後続フォローアップ（Claude が実行可能、予約完了後に実施）

ユーザーが Step 5 まで完了したら、Claude に「scope 予約完了」と伝えてください。以下を main に反映します:

| 反映先 | 変更内容 |
|---|---|
| `docs/product-requirements.md` §10 残課題 | 行 8 として「npm scope `@rescript-tauri` 予約: 完了 (YYYY-MM-DD, `0.0.0-reserved`)、Phase 1 リリース時に正式 0.1.0 publish 予定」を追記 |
| `docs/product-requirements.md` §5.6 | 「npm scope `@rescript-tauri` を予約済みにする (リリース前提条件)」を「予約完了」に更新 |
| `README.md` §Visibility ブロック | 切替条件 #3 (npm publish) の状態を「scope 予約済み、初版 publish は Phase 1」と注記 |
| `README.md` §Compatibility / §Installation | 必要なら状態説明を微調整 |
| `.steering/20260508-007-npm-scope-reservation/report.md` (本書) | 末尾に「予約完了 (YYYY-MM-DD)」セクションを追記 |

これらの反映は軽微な変更のため、`git-conventions.md` 例外規定でステアリング省略 + main 直接コミット可。

## 6. リスク・注意事項

| リスク | 影響 | 対策 |
|---|---|---|
| `0.0.0-reserved` を publish した後、後で削除したくなる | npm の `unpublish` は 72 時間以内のみ可。それ以降は npm support に依頼が必要 | 予約バージョンは未来の正式リリースで上書き (`0.1.0` 以降) されるので unpublish 不要。`0.0.0-reserved` はそのまま残る |
| 2FA を有効化していないと publish に失敗 | publish 不可 | Step 1 で 2FA 設定を確認 |
| `0.0.0-reserved` を `--tag` なしで `npm publish` すると `prerelease version requires --tag` エラー | publish 失敗 | Step 4 (b) で **必ず `npm publish --tag reserved`** を使用。詳細は Step 4 (b) を参照 |
| Org 名のタイポ (`rescript_tauri` など) | scope が変わってしまう | Step 2 で正確に `rescript-tauri` (ハイフン) を入力 |
| 既に他者が `@rescript-tauri` Org を取得していた | scope 予約不可 | §2 で 2026-05-08 時点の空きを確認済み。実行は早めに |
| 個人アカウントで Org を作成 → 後で組織アカウントに移したい | 移管は可能だが手続き必要 | Phase 1 リリース後の運用安定後に検討 |

## 7. 参照

- npm Organizations: <https://docs.npmjs.com/organizations>
- Creating an organization: <https://docs.npmjs.com/creating-an-organization>
- Publishing scoped public packages: <https://docs.npmjs.com/creating-and-publishing-scoped-public-packages>
- Trusted Publishers (GitHub Actions OIDC): <https://docs.npmjs.com/trusted-publishers>
- RFC-0001 §15 Decision checklist 行 1
- drift analysis: `.steering/20260508-006-rfc-0001-drift-analysis/report.md` §3.5 No.6

---

## 8. 完了記録

予約が完了した日付・バージョン・publish した npm ユーザー名を以下に記録してください（Claude 経由で更新可）:

```
予約完了日: ____________________
予約バージョン: 0.0.0-reserved
Publish したユーザー: ____________________
Org owner: ____________________
追加で予約したパッケージ (任意): ____________________
```
