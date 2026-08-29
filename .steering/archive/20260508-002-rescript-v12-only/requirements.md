# 要求定義: ReScript >= 12 のみへのサポート狭小化

| 項目 | 内容 |
|---|---|
| 作業 ID | 20260508-002 |
| タイトル | rescript-v12-only |
| 起票日 | 2026-05-08 |
| 起票者 | ユーザー指示 |
| 影響範囲 | ドキュメントのみ（コード未着手の bootstrap 段階）|

## 1. 背景

bootstrap 時点 (commit `7dbf6b1` 以降) の PRD §1.3 / §6 は ReScript >= 11.0.0 をサポート範囲とし、ReScript v12 prerelease を nightly CI で並走検証する方針だった。これは ReScript v11 がデフォルト curried、v12 で uncurried-by-default に切り替わる移行期に書かれた前提に基づく。

ユーザー指示により、サポート対象を **ReScript >= 12.0.0 のみ** に狭小化する。

## 2. 動機

- **メンテナンスコスト削減**: v11 (curried 残り) と v12 (uncurried-by-default) の両対応は型・サンプル・CI 行列の複雑化を招き、1〜3 名メンテナで長期維持する PRD §1.4 のターゲットと整合しない。
- **API 表現の明快化**: v12 を前提にすれば uncurried 表記の例外説明 (`@uncurry` 等) が不要となり、`.resi` の表面が単純化する。
- **bootstrap 段階で確定する優位性**: コード未着手なので破壊的変更コストはゼロ。後で v11 を切り捨てるより、最初から v12 起点にする方が下流（examples / plugins）への影響が小さい。
- **プロジェクト方針の一貫性**: PRD §6 が既に「v12 prerelease を CI で並走確認」と記述し、v12 への確定的な追従意図はあった。今回の変更はその意図を最終化するもの。

## 3. スコープ

### 3.1 対象 (in-scope)

ReScript バージョン要件・関連表現を `>= 11.0.0` 系から `>= 12.0.0` 系に置換する全ドキュメント:

- `CLAUDE.md` — 言語要件
- `README.md` — 互換マトリクス / インストール手順 / nightly CI 注記
- `docs/product-requirements.md` — 依存方針 / 互換性 §6 / Phase 3 ロードマップ / リスク表
- `docs/functional-design.md` — peerDependencies / CI 行列 / `compat-rescript-prerelease` の意味
- `docs/architecture.md` — 互換マトリクス / リスク表 / 拡張パス
- `docs/glossary.md` — `uncurried` 用語定義
- `docs/repository-structure.md` — `.github/workflows/compat-rescript-prerelease.yml` 注釈
- `.github/workflows/README.md` — `compat-rescript-prerelease.yml` 説明

### 3.2 対象外 (out-of-scope)

- `docs/ideas/RFC-0001-core-api-design.md` — 歴史的入力。`docs/repository-structure.md` §4.1 の方針に従い改編しない。
- ソースコード (`packages/`) — 未着手のため対象なし。
- `.claude/rules/` / `.claude/skills/` — ReScript バージョン依存の記述なし（grep 結果ゼロ）。

## 4. 設計上の派生決定（要承認）

ReScript 11 を切り離すことで、以下 2 点も連動して見直しが必要:

### 4.1 nightly prerelease CI の継続可否

| 案 | 内容 | 推奨 |
|---|---|---|
| A | `compat-rescript-prerelease.yml` を継続。意味を「ReScript 12.x 次期マイナー / 次期メジャー (v13?) prerelease への先行検知」へ更新 | ✅ Recommended（API drift 早期検知の枠組みを維持）|
| B | nightly prerelease CI を削除し Phase 1 安定版運用に集中 | — |
| C | `latest stable` + `prerelease` の二段構成に拡張 | — |

### 4.2 PRD §10.4 Phase 3 ロードマップの位置づけ

元の Phase 3 は「ReScript v12 対応 / 長期運用」。v12 を Phase 1 起点で採用するため再定義が必要。

| 案 | 内容 | 推奨 |
|---|---|---|
| A | 「長期運用 + 次期 ReScript 対応 (v13 想定)」へリフレーム | ✅ Recommended |
| B | Phase 3 を「長期運用 / コントリビュータ拡充」のみに簡素化（メジャー対応は別途） | — |
| C | Phase 3 を一旦 TBD として削除 | — |

## 5. 受け入れ条件

- [ ] 上記 8 ファイルすべてで `>=11`, `v11`, `ReScript 11+` 系統の記述が `>=12` 起点の表現に置換されている
- [ ] `bs-dependencies` 言及は ReScript 11 互換のためのレガシー説明として持ち込まず、`dependencies` のみで記述
- [ ] `uncurried` の語は「v12 で default」ではなく「v12 で確定済みの default」相当の表現に整理
- [ ] §4.1 / §4.2 の派生決定が design.md に反映され、実装される
- [ ] PRD §10 の残課題に「ReScript 11 サポート除外決定」を 1 行追記し、決定経緯を後日参照可能にする
- [ ] 全ファイルのビルド系コマンドへの影響なし（ドキュメントのみ変更のため自動）

## 6. 影響を受けないこと

- アーキテクチャ 3-layer IPC 構造
- パッケージ分割方針
- 既存の examples 計画 (`hello-world` 等)
- CI ジョブ構成（`compat-rescript-prerelease.yml` の意味解釈のみ更新）

## 7. リスク

| リスク | 影響度 | 対応 |
|---|---|---|
| ReScript 12 普及率がまだ低く、ターゲット読者が触りにくい | 中 | README で v12 要件を明示。`@rescript/core` も v12 互換版を peer dep に固定 |
| 後で v11 サポート要望が来た際、再追加コストが発生 | 低 | bootstrap 段階での決定なので追加コストは小（compat 行列の再構築のみ）|
| `@rescript/core` の v12 互換最低バージョンが未確認 | 中 | design.md で `@rescript/core` の対応バージョンを再調査して確定 |
