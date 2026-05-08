# 要求定義: CODE_OF_CONDUCT.md と SECURITY.md の整備

| 項目 | 内容 |
|---|---|
| 作業 ID | 20260508-005 |
| タイトル | coc-and-security |
| 起票日 | 2026-05-08 |
| 起票者 | ユーザー指示 |
| 影響範囲 | ドキュメントのみ（コード未着手の bootstrap 段階）|

## 1. 背景

steering 003 で `CONTRIBUTING.md` を整備した際、2 箇所で TBD を残した:

| 場所 | 現状の文言 | 問題 |
|---|---|---|
| `CONTRIBUTING.md` §5（line 116） | "A `SECURITY.md` with a private disclosure channel will be added at the Phase 1 release. Until then, please contact the maintainer through the email listed in the GitHub profile." | private disclosure channel が未整備、ユーザーは GitHub profile の email を辿る必要 |
| `CONTRIBUTING.md` §6（line 122） | "A `CODE_OF_CONDUCT.md` will be added at the Phase 1 release. Until then, contributors and reviewers are expected to act with respect, assume good faith..." | enforcement contact / 違反時の手順が未定義 |

GitHub の Community Standards チェック（リポジトリ Insights → Community Profile）でも、`CODE_OF_CONDUCT.md` と `SECURITY.md` は標準項目として評価される。bootstrap 段階で整えておけば、Phase 1 リリース時に追加対応不要。

## 2. 動機

- **TBD の解消**: `CONTRIBUTING.md` の TBD 言及を実体ファイルへの参照に置き換え、ドキュメント網を完成に近づける。
- **GitHub Community Standards 充足**: `LICENSE`（既達）/ `CONTRIBUTING.md`（既達）/ `README.md`（既達）に加えて `CODE_OF_CONDUCT.md` / `SECURITY.md` を揃え、Community Profile スコアを満たす。
- **Phase 1 リリース前の準備**: visibility 切替（private → public）時に「外部から触れる文書」が一通り整っている状態を作る。
- **私的 email 露出の最小化**: 現在 `CONTRIBUTING.md` で「GitHub profile の email を見て」と案内しているが、GitHub の標準 channel（Security Advisories）に誘導する方が安全かつ tracking も楽。

## 3. スコープ

### 3.1 対象 (in-scope)

| ファイル | 種別 | 配置 | 言語 |
|---|---|---|---|
| `CODE_OF_CONDUCT.md` | 新規 | リポジトリルート | 英語 |
| `SECURITY.md` | 新規 | リポジトリルート | 英語 |
| `CONTRIBUTING.md` 軽微修正 | 既存 | リポジトリルート | 英語 |

### 3.2 対象外 (out-of-scope)

- Sphinx-docs への CoC / Security ページ追加（必要なら steering 004 後続作業として別途）。
- GitHub Security Advisories の有効化操作（リポジトリ設定で UI から行う必要、ユーザー手動）。
- CoC 翻訳（日本語版）。
- `GOVERNANCE.md`（Phase 3 で検討予定）。
- README.md sphinx-docs publication TBD（別件）。
- `.steering/` の他作業ディレクトリへの言及。

## 4. 設計上の派生決定（要承認）

### 4.1 Code of Conduct のソース

| 案 | 内容 | 推奨 |
|---|---|---|
| A | [Contributor Covenant 2.1](https://www.contributor-covenant.org/version/2/1/code_of_conduct/) を全文採用（OSS デファクト標準、外部認知度高、enforcement guidelines 4 段階ペナルティを含む） | ✅ Recommended |
| B | 独自の簡略版（5–10 項目） | — (再発明、外部信頼度低)|
| C | Mozilla Community Participation Guidelines | — (重い、本プロジェクトには過剰) |

### 4.2 CoC enforcement contact

CoC 違反報告先。GitHub Security Advisories は本来セキュリティ専用なので、CoC 違反報告には別経路が必要。

| 案 | 内容 | 推奨 |
|---|---|---|
| A | 個人 email（`nagata.hbdc@gmail.com`）を直接記載 | ✅ Recommended（git commit 履歴に既出、追加露出リスクは小、実効性高）|
| B | GitHub Profile (`@Nagatatz`) 経由で contact を促す | — (ワンステップ多く、実効性低)|
| C | 専用 email（`coc@rescript-tauri.example`）を取得 | — (ドメイン未取得、Phase 1 リリース後に検討可能)|
| D | 当面記載なしで「メンテナまで GitHub Issue で連絡」 | — (公開 Issue は CoC 違反報告に不向き)|

### 4.3 Security disclosure channel

脆弱性報告先。

| 案 | 内容 | 推奨 |
|---|---|---|
| A | GitHub Security Advisories（GHSA）のみ | ✅ Recommended（private、tracking、CVE 連携、OSS 標準）|
| B | GHSA + email（`nagata.hbdc@gmail.com`）の二系統 | — (email 露出を増やすが、GHSA 利用に不慣れな報告者向けの fallback として有効、判断分かれる)|
| C | email のみ | — (tracking なし、再発明)|

派生検討: case A を採るなら、SECURITY.md 内で「リポジトリの Security タブ → Report a vulnerability から GHSA を起票」の手順を案内する。

### 4.4 Supported versions セクション

`SECURITY.md` の慣習として「Supported versions」表を含める。Phase 1 前なので「未公開」と明示する。

| 案 | 内容 | 推奨 |
|---|---|---|
| A | "No supported versions yet. The first published release will be marked supported. Pre-release reports are welcome through the GHSA channel above." を 1 段落で記載 | ✅ Recommended |
| B | 表形式の placeholder（"Phase 1 — Pending"）| — (空表は誤解を招く)|

## 5. 受け入れ条件

- [ ] `CODE_OF_CONDUCT.md` がリポジトリルートに存在し、Contributor Covenant 2.1 の全文（attribution 含む）+ enforcement contact が記載されている
- [ ] `SECURITY.md` がリポジトリルートに存在し、Supported versions / Reporting a vulnerability / Response timeline / Disclosure policy のセクションを持つ
- [ ] `CONTRIBUTING.md` §5（line 116）の TBD 記述が `SECURITY.md` への参照に置き換わる
- [ ] `CONTRIBUTING.md` §6（line 122）の TBD 記述が `CODE_OF_CONDUCT.md` への参照に置き換わる
- [ ] 派生決定 4.1 / 4.2 / 4.3 / 4.4 がすべて反映されている
- [ ] GitHub Community Standards で `CODE_OF_CONDUCT.md` / `SECURITY.md` が認識される位置（リポジトリルート）に配置されている

## 6. 影響を受けないこと

- 既存 `docs/*` の内容
- `LICENSE`、`README.md`（README §Visibility のチェックリスト 5 条件には CoC/SECURITY は含まれていないため更新不要）
- `packages/`, `examples/`, `sphinx-docs/`
- `.github/workflows/`, `.claude/rules/`

## 7. リスク

| リスク | 影響度 | 対応 |
|---|---|---|
| 個人 email の更なる露出 | 中 | 派生決定 4.2 / 4.3 で確認、git 履歴に既出のため追加リスクは限定的 |
| GHSA を有効化していないと「Report a vulnerability」リンクが Security タブに表示されない | 中 | SECURITY.md に「リポジトリ管理者がまだ GHSA を有効化していない場合は email でも受け付ける（fallback）」と一文追加するか、後続作業として GHSA 有効化を tasklist に残す |
| Contributor Covenant の attribution / license 表示漏れで CC ライセンス違反 | 低 | デフォルトのテンプレ通り attribution + CC BY 4.0 表示を必ず含める |

## 8. 後続タスクへの引き継ぎ

本ステアリング完了後の TODO（別ステアリングまたは設定操作）:

- GitHub リポジトリ設定で **Security Advisories を有効化**（Settings → Security → Privately reporting）
- visibility 切替時（private → public）に GHSA の動作確認
- 必要なら CoC の日本語訳を `sphinx-docs/locale/ja/` に追加（Phase 1 後）
