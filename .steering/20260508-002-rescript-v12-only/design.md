# 設計: ReScript >= 12 のみへのサポート狭小化

| 項目 | 内容 |
|---|---|
| 関連 | `requirements.md` |
| 作成日 | 2026-05-08 |

## 1. 派生決定の確定（要承認）

requirements.md §4 で挙げた選択肢に対し、本設計で以下を採用する:

### 1.1 nightly prerelease CI

**採用: 案 A** — `compat-rescript-prerelease.yml` を継続し、意味を更新する。

- 既存ジョブ名は変更しない（リネームによる CI 履歴断絶を避ける）。
- ジョブの趣旨を「ReScript 12.x 系の次期マイナー / 次期メジャー (v13 想定) prerelease に対する先行検知」と再定義する。
- `docs/functional-design.md` §6 の説明文と `.github/workflows/README.md` で意味を明記する。

### 1.2 Phase 3 ロードマップ

**採用: 案 A** — 「長期運用 + 次期 ReScript メジャー (v13 想定) prerelease 対応」へリフレーム。

- Phase 3 の達成条件を「v13 prerelease で CI 緑」「CONTRIBUTING.md / governance 整備」に更新。
- v12 採用は Phase 1 完了条件に含める（インストール要件として README/PRD 互換マトリクスに反映）。

## 2. ファイル別変更方針

各ファイルの修正を before/after で示す。**実際の表現は実装時に文脈に合わせて微調整するが、意味的に等価であること**を本設計で保証する。

### 2.1 `CLAUDE.md`

| 行 | before | after |
|---|---|---|
| 11 | `言語: ReScript (>=11.0.0) / JavaScript (生成物・テストツール)` | `言語: ReScript (>=12.0.0, uncurried-by-default) / JavaScript (生成物・テストツール)` |

### 2.2 `README.md`

| 行 | before | after |
|---|---|---|
| 40 | `\| ReScript \| >= 11.0.0 (uncurried mode) \|` | `\| ReScript \| >= 12.0.0 (uncurried-by-default) \|` |
| 45 | `... ReScript prerelease line is planned to detect API drift early.` | `... next ReScript 12.x minor / next-major prerelease line is planned to detect API drift early.` |
| 57 | `Then add @rescript-tauri/core to your rescript.json (dependencies on ReScript 12; bs-dependencies on ReScript 11 — the legacy key is still accepted in 12 but deprecated).` | `Then add @rescript-tauri/core to dependencies in your rescript.json.` |

### 2.3 `docs/product-requirements.md`

| 行 | before の要旨 | after の要旨 |
|---|---|---|
| 83 | ナガタさん課題: `ReScript v11/v12 の uncurried 化` | `ReScript v12 への uncurried-by-default 移行`（歴史的事実として残しつつ表現単純化）|
| 89 | ナガタさんワークフロー: `ReScript v12 prerelease で CI を走らせ、互換性ブレを早期検知` | `ReScript 12.x 次期マイナー / 次期メジャー prerelease で CI を走らせ、互換性ブレを早期検知` |
| 243 | `peerDependencies: ... rescript >=11.0.0, @rescript/core >=1.0.0` | `peerDependencies: ... rescript >=12.0.0, @rescript/core >= <v12 互換最低版>`（実装時に確定）|
| 292 | `ReScript: >=11.0.0（namespace, JSX v4 想定）。v12 prerelease を CI で並走確認。` | `ReScript: >=12.0.0（uncurried-by-default, namespace, JSX v4 想定）。次期マイナー / メジャー prerelease を CI で並走確認。` |
| 389 | Phase 3: `ReScript v12 対応 / 長期運用` … 達成: `v12 安定版で CI 緑` | Phase 3: `長期運用 / 次期 ReScript メジャー対応（v13 想定）` … 達成: `v13 prerelease で CI 緑、CONTRIBUTING.md / governance 整備` |
| 399 | リスク: `ReScript v12 破壊的変更 / uncurried 変換失敗 / v11 v12 並走 CI` | リスク: `ReScript 12.x 後続マイナーの破壊的変更 / nightly prerelease 検証で先行検知` |
| §10 残課題 | （該当なし） | 1 行追加: `ReScript 11 サポート除外決定 (2026-05-08, .steering/20260508-002 参照)` |

### 2.4 `docs/functional-design.md`

| 行 | before | after |
|---|---|---|
| 76 | `peerDependencies: ... rescript >=11.0.0, @rescript/core >=1.0.0` | `peerDependencies: ... rescript >=12.0.0, @rescript/core >= <v12 互換最低版>` |
| 623 | `ReScript v11 / v12 prerelease の matrix CI` | `ReScript 12.x 安定版 + 次期マイナー / メジャー prerelease の matrix CI` |
| 639 | `compat-rescript-prerelease \| nightly \| ReScript v12 prerelease で build` | `compat-rescript-prerelease \| nightly \| ReScript 次期マイナー / メジャー prerelease で build。v12 系 API drift を先行検知` |

### 2.5 `docs/architecture.md`

| 行 | before の要旨 | after の要旨 |
|---|---|---|
| 143 | 互換マトリクス: `Tauri 2.x ↔ ReScript 11+ で 1.x` | `Tauri 2.x ↔ ReScript 12+ で 1.x` |
| 248 | アスキーアート内 `compat-rescript-prerelease (v12 先行検知)` | `compat-rescript-prerelease (次期マイナー/メジャー先行検知)` |
| 292 | リスク: `ReScript v12 破壊的変更 / uncurried-by-default 化 / nightly v12 prerelease 検証 / Phase 3 で正式対応` | リスク: `ReScript 12.x 後続マイナーの破壊的変更 / nightly prerelease 検証で先行検知` |
| 304 | 拡張パス: `ReScript v12 uncurried 完全対応 / core を minor or major bump` | 拡張パス: `次期 ReScript メジャー (v13 想定) 対応 / core を major bump` |

### 2.6 `docs/glossary.md`

| 行 | before | after |
|---|---|---|
| 68 | `uncurried: ReScript v12 で default となる関数呼び出し慣習。本プロダクトは v11 をターゲットとしつつ v12 prerelease を nightly で検証。` | `uncurried: ReScript v12 以降で default となる関数呼び出し慣習。本プロダクトは v12+ をターゲットとし uncurried-by-default を前提とする。` |

### 2.7 `docs/repository-structure.md`

| 行 | before | after |
|---|---|---|
| 248 | `compat-rescript-prerelease.yml   # nightly` | `compat-rescript-prerelease.yml   # nightly (次期 12.x マイナー / 次期メジャー prerelease 検証)` |

### 2.8 `.github/workflows/README.md`

| 該当行 | before | after |
|---|---|---|
| `compat-rescript-prerelease.yml` 行 | `Nightly compatibility run against the ReScript prerelease line.` | `Nightly compatibility run against the next ReScript 12.x minor / next-major prerelease line.` |

## 3. `@rescript/core` 互換最低バージョンの確定

ReScript 12 互換の `@rescript/core` 最低バージョンは実装時に以下の手順で確定する:

1. `npm view @rescript/core versions` で全バージョン取得
2. 各バージョンの `peerDependencies.rescript` を確認し、`>=12` を満たす最低バージョンを抽出
3. 確定値を PRD §6 / functional-design §1.3 に反映

実装時にこの調査が失敗した場合（npm レジストリへのアクセス不可など）、暫定値として `@rescript/core >= 1.6.0` を仮置きし、tasklist に「実装後 npm 確認」のフォローアップを残す。

## 4. コミット粒度

`git-conventions.md` の「1 コミット = 1 論理的変更」に従い、以下に分割する:

| # | コミット | 内容 |
|---|---|---|
| 1 | 📝 Drop ReScript 11 from PRD: align dependency policy and roadmap to v12+ | `docs/product-requirements.md` のみ |
| 2 | 📝 Sync functional-design and architecture to ReScript v12-only | `docs/functional-design.md` + `docs/architecture.md` |
| 3 | 📝 Update CLAUDE.md, glossary, repo-structure for ReScript v12-only | `CLAUDE.md` + `docs/glossary.md` + `docs/repository-structure.md` |
| 4 | 📝 Update README and CI workflow notes for ReScript v12-only | `README.md` + `.github/workflows/README.md` |
| 5 | 📝 Mark steering 20260508-002 tasks complete and queue merge | `.steering/20260508-002-rescript-v12-only/tasklist.md` |

各コミットの最初には対応する `tasklist.md` のタスクを `[x]` に更新する。

## 5. worktree 運用

`.claude/rules/steering-workflow.md` に従い、`EnterWorktree` で `rescript-v12-only` という名前の worktree を作成し、隔離環境で実装する。worktree 内ではメインリポジトリの未追跡ステアリングファイルが参照できない問題を避けるため、ステアリング 3 ファイルは **worktree 作成前にメインリポジトリへ git add → コミットしない** で配置し、worktree 作成と同時に worktree 側へコピーされる構成とする。

ただし `EnterWorktree` は HEAD ベースで worktree を作るため、未追跡ファイルは引き継がれない。実務上は以下のいずれかで対応:

- **採用**: ステアリング 3 ファイルは main 側で先に承認 → コミット (`📝 Add steering for 20260508-002`) → worktree 作成 → 実装、の順とする。これにより worktree からもステアリングが見える。

## 6. テスト戦略

ドキュメントのみの変更のためユニットテストは不要。検証は以下で行う:

1. **grep 残存検出**: `grep -rn -E ">=11\.0|ReScript 11\+|v11" CLAUDE.md README.md docs/ .github/workflows/README.md | grep -v RFC-0001` の出力が空になること（RFC は対象外）。
2. **markdown lint**: 既存の lint が通ること（IDE 診断 warning が増えていないこと）。
3. **リンク健全性**: 既存ドキュメント間リンクが切れていないこと。
