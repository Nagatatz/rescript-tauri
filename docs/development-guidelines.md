# 開発ガイドライン (Development Guidelines)

| 項目 | 内容 |
|---|---|
| プロダクト | `@rescript-tauri/core` および周辺パッケージ群 |
| 対象 | Phase 1 以降の全実装作業 |
| 作成日 | 2026-05-08 |
| 関連 | [docs/architecture.md](./architecture.md), [docs/functional-design.md](./functional-design.md), [docs/repository-structure.md](./repository-structure.md), [.claude/rules/](../.claude/rules/) |
| ステータス | Draft |

> 本書は「**どう開発するか**」の実務指針。コーディング規約や Git 規約自体は `.claude/rules/*` を SSoT とし、本書はそれらを開発者の動線に沿って組み立て直す。各規約の本文は対応する rule ファイルへのリンクで委譲し、本書では「いつ・どの順序で適用するか」を示す。

---

## 1. 開発の全体フロー

### 1.1 標準フロー

```
ステアリング起動 → worktree 隔離 → 実装 → 自己検証 → コミット → マージ確認 → クリーンアップ
```

各ステップの定義は `.claude/rules/steering-workflow.md` を参照。

| ステップ | 主な成果物 | 失敗時の挙動 |
|---|---|---|
| ステアリング起動 | `.steering/[YYYYMMDD]-[NNN]-[title]/{requirements,design,tasklist}.md` | ユーザー承認なしに次工程へ進めない |
| worktree 隔離 | `.claude/worktrees/<name>/` + `worktree-<name>` ブランチ | コード実装は隔離環境で行う |
| 実装 | コード + テスト + ドキュメント更新 | tasklist を `[x]` リアルタイム更新 |
| 自己検証 | ビルド成功、テスト pass、型チェック OK | コミット禁止 |
| コミット | 1 コミット = 1 論理的変更 | 規約違反は再分割 |
| マージ確認 | `AskUserQuestion` でユーザー承認 | 承認なしのマージ禁止 |
| クリーンアップ | worktree 削除 + ブランチ削除 + push | クリーンアップ未完了でセッション終了不可 |

### 1.2 軽微な変更 vs 中規模以上の判断

| 作業区分 | 推奨フロー | 根拠 |
|---|---|---|
| タイポ修正、1 行の設定変更 | 通常モード（直接実行）| `permission-modes.md` |
| 軽微な変更（差分を 1 文で説明できる）| Plan Mode | `permission-modes.md` |
| 中規模以上（複数ファイル、不慣れなコード）| ステアリングワークフロー | `steering-workflow.md` |

判断に迷う場合は **steering 寄りに倒す**。requirements.md だけでも作成しておけば、後の参照になる。

### 1.3 Definition of Done の各フェーズ

実装完了の判定は `.claude/rules/definition-of-done.md` の Phase 1〜5 を順守する。各フェーズのチェック項目は本書では再掲せず、定義そのものに当たること。

---

## 2. ローカル開発環境

### 2.1 必要ツール

| ツール | バージョン | 用途 |
|---|---|---|
| pnpm | >= 9 | パッケージマネージャ（workspace 必須） |
| ReScript | >= 12.0.0 | 本プロダクトの言語要件（uncurried-by-default）|
| `@rescript/core` | >= 1.6.0 | 標準ライブラリ（peerDep）|
| Node.js | Active LTS | ReScript ランタイム / vitest 実行 |
| Rust + Cargo | stable | `examples/` の Tauri バックエンドのみ必要 |

### 2.2 推奨 IDE

- **VS Code + rescript-vscode 拡張**（公式）— LSP / フォーマッタ / inlay hints
- 補助: GitLens、Markdown All in One

`.vscode/` はリポジトリに含めない（`.gitignore` 対象）。個人設定は手元で管理する。

### 2.3 リポジトリ初期化

```bash
git clone git@github.com:Nagatatz/rescript-tauri.git
cd rescript-tauri
cp .env.example .env           # 必要に応じて編集
cp .mcp.json.template .mcp.json  # MCP を使う場合のみ。.gitignore 対象
pnpm install
```

`.env` および `.mcp.json` は `.gitignore` 対象。秘密情報を含めて git に上げないこと。

---

## 3. ビルド・テスト・lint コマンド

`CLAUDE.md` 「ビルド・実行コマンド」と同期している。差分が出た場合は CLAUDE.md を SSoT とする。

```bash
# 全 workspace ビルド
pnpm install && pnpm --recursive build

# クリーンビルド
pnpm --recursive run clean && pnpm --recursive build

# テスト（型レベル + vitest）
pnpm --recursive test

# core パッケージのみのインクリメンタルビルド
pnpm --filter @rescript-tauri/core build
```

`examples/` の個別ビルドは各 `examples/<name>/README.md` を参照（Phase 1 で整備）。

---

## 4. テスト方針（3 段構え）

詳細は `docs/functional-design.md` §5 / §7 と `.claude/rules/testing.md` を参照。本書では概観のみ示す。

| 段 | 配置 | 検証対象 | 失敗時の意味 |
|---|---|---|---|
| 型レベル | `packages/core/tests/*.res` | `.resi` 公開シンボル 100% 参照 | 後方互換性ブレ |
| ランタイム | `packages/core/tests/runtime/*.mjs` (vitest) | encode/decode round-trip、`Mocks.mockIPC` 経由の listen/emit | 振る舞いの回帰 |
| 統合 | `examples/*/` を 3 OS でビルド | フルビルド成功 | ユーザー体験回帰、リリース不可 |

`testing.md` の「自己検証」フローに従い、コミット前にテスト実行 + 型チェック + ビルドを必ず行う。3 回修正しても解決しない場合はユーザーに報告する。

---

## 5. 新モジュール追加時の手順

`packages/core/` に新しいモジュールを追加する場合の標準手順。

### 5.1 ファイル配置

```
packages/core/src/<Name>.res
packages/core/src/<Name>.resi   ← .res と 1:1 で必ず作成
packages/core/tests/<name>_*.res                ← 型レベルテスト
packages/core/tests/runtime/<name>_test.mjs     ← 必要時のみ vitest
```

命名は PascalCase で 1 モジュール 1 ファイル（`docs/repository-structure.md` §2.1）。

### 5.2 `.resi` doc comment の必須要素

`.claude/rules/code-comments.md` を SSoT とする。本書ではテンプレートを示す:

```rescript
/** モジュールの責務を 1〜3 文で記述する。
    関連モジュールへの参照は `→` で示す。
    See: https://v2.tauri.app/reference/javascript/api/<page>/ */
module Foo: {
  /** Public シンボルの動作を 1〜2 文。
      パラメータが 2 つ以上ある場合はパラメータ・戻り値を記述。
      See: https://v2.tauri.app/reference/javascript/api/<page>/#<anchor> */
  let bar: (~name: string, ~options: options=?) => promise<result<t, error>>
}
```

`See:` 行の Tauri 公式 URL は `.github/workflows/doc-link-lint.yml`（Phase 1 で実装）が grep 検証する。各 public シンボルに必ず付与すること。

### 5.3 型レベルテスト追加

```rescript
// packages/core/tests/<name>_signature.res
// コンパイル成功 = pass。.resi 公開シンボルすべてを 1 回以上参照する。
let _ = Foo.bar
let _ = Foo.someType: Foo.t => unit
// ...
```

`tests-core-types.yml`（Phase 1 で実装）が grep ベースで「.resi 公開シンボル 100% 参照カバレッジ」を強制する。

### 5.4 `Tauri.res` re-export の更新

トップレベル re-export ポリシーは `docs/functional-design.md` §2.13 を参照（PRD §10 残課題 #1 で curated subset 方針確定済み）。新モジュールが re-export 対象なら `Tauri.res` を更新する。

### 5.5 examples の追加（必要時）

新モジュールに典型ユースケースがある場合、`examples/` に追加する（PRD §5.4「100% symbol coverage」と整合）。

---

## 6. コーディング規約（実装パターン）

詳細規約は `.claude/rules/code-comments.md` および `docs/architecture.md` §3, §5 を参照。本書では本プロダクト特有のパターンを列挙する。

| パターン | 用途 | 参照 |
|---|---|---|
| `.resi` を必ず併設 | 公開 API 表面の正本化 | `repository-structure.md` §2.1 |
| polymorphic variant `[#light \| #dark]` | string-literal union の型安全表現（コンパイル後 string、cost 0）| `architecture.md` §3, §5 |
| opaque type + `@send` | JS クラスのインスタンスメソッドを pipe-first で表現 | `architecture.md` §3 |
| `%identity` キャスト | クラス継承（`WebviewWindow.t` → `Window.t`）| `architecture.md` §5 |
| `result<'a, e>` で失敗表現 | Layer 2 IPC、デコーダ失敗 | `functional-design.md` §2.1 |
| `*Exn` 派生命名 | `result` を unwrap し失敗時に raise（`@rescript/core` 慣習）| `glossary.md` |
| Layer 1/2/3 の使い分け | IPC 設計の階層選択 | `functional-design.md` §1.2 |

### 6.1 禁止事項

- `Belt` の API を本パッケージから直接利用しない（peerDep は `@rescript/core` のみ。PRD §10 残課題 #6）。
- ランタイムオーバーヘッドを発生させる中間コレクション（PRD §5.2）。
- decoder ライブラリ（`rescript-schema` 等）への依存（PRD Story 1-3 / `architecture.md` §3）。

---

## 7. コミット粒度・メッセージ

`.claude/rules/git-conventions.md` を SSoT とする。要点のみ再掲:

- **粒度**: 1 コミット = 1 論理的変更。実装コード + 対応テスト + 設定ファイル登録は同一コミット可。`tasklist.md` の更新は各コミットに含める。
- **メッセージ**: 絵文字プレフィックス + 動詞で始まる英語。判定優先順位: ✨ > 🐛 > ♻️ > 📝 > 🎨 > ⚡ > 🔧 > ✅ > 🗑️
- **ブランチ**: `feature/`, `fix/`, `refactor/`, `docs/`, `test/`, `chore/` のいずれかをプレフィックスとし、`main` から派生

例外（`main` 直接コミット可）:
- タイポ修正、1 行の設定変更
- ステアリング (`.steering/`) のみの変更
- `CLAUDE.md` や `docs/` のみのドキュメント更新

---

## 8. PR レビュー観点

### 8.1 自動化されたレビュー

| エージェント | 起動タイミング | 観点 |
|---|---|---|
| `code-reviewer` | コミット前、PR 作成前 | ドキュメントコメント / テスト存在 / コードスタイル / デッドコード / エッジケースカバレッジ |
| `build-resolver` | ビルドエラー / 型エラー / テスト失敗時 | 根本原因分析と修正案 |
| `debugger` | バグ・予期しない挙動・エラー時 | 根本原因 vs 症状の切り分け、再発防止 |
| `security-reviewer` | セキュリティ関連変更時 | 認証 / 認可 / インジェクション / シークレット漏洩 |

### 8.2 リリースゲート（Phase 1）

`docs/functional-design.md` §7 のリリース判定基準を全件満たすこと:

1. PRD §4 Must スコープが全実装済み
2. 全モジュールに `.resi` + doc comment + Tauri 公式 URL リンクが付与
3. 型レベル + vitest + examples ビルド (3 OS) 全緑
4. `.github/workflows/release.yml` の tag push トリガで npm publish 可能

加えて `definition-of-done.md` Phase 4 の全項目を順守する。

### 8.3 セキュリティ関連変更

`.claude/rules/definition-of-done.md` Phase 4 にて、セキュリティ関連モジュールの変更がある場合は `security-reviewer` agent によるレビューを必須とする。

---

## 9. リリース手順（概要）

詳細は Phase 1 リリース直前に `release-manager` agent と連携して詳細化する。現時点では概要のみ:

1. `release-manager` agent でリリース PR 作成・changelog 生成
2. 各パッケージ独立 semver
3. `.github/workflows/release.yml` の tag push トリガで npm publish + GitHub Release
4. `README.md` 互換マトリクスを更新（必要時）
5. visibility 切替条件を満たしているか確認し、満たしていれば `gh repo edit Nagatatz/rescript-tauri --visibility public`

---

## 10. 参照

- `.claude/rules/`
  - [`testing.md`](../.claude/rules/testing.md) — テスト規約 + 自己検証フロー
  - [`code-comments.md`](../.claude/rules/code-comments.md) — doc / インラインコメント規約
  - [`git-conventions.md`](../.claude/rules/git-conventions.md) — コミット / ブランチ規約
  - [`steering-workflow.md`](../.claude/rules/steering-workflow.md) — ステアリング + worktree 運用
  - [`documentation.md`](../.claude/rules/documentation.md) — `docs/` / `sphinx-docs/` 役割分担
  - [`definition-of-done.md`](../.claude/rules/definition-of-done.md) — 完了定義 SSoT
  - [`permission-modes.md`](../.claude/rules/permission-modes.md) — Plan Mode / steering / auto / sandbox 住み分け
- `docs/`
  - [`product-requirements.md`](./product-requirements.md) — PRD（ペルソナ / ユーザーストーリー / KPI）
  - [`functional-design.md`](./functional-design.md) — モジュール別 API 仕様
  - [`architecture.md`](./architecture.md) — 設計原則 / 横断ポリシー
  - [`repository-structure.md`](./repository-structure.md) — リポジトリ構造正本
  - [`glossary.md`](./glossary.md) — ユビキタス言語定義
- [`.github/workflows/README.md`](../.github/workflows/README.md) — CI ワークフロー一覧（active / opt-in / planned）
- [`CONTRIBUTING.md`](../CONTRIBUTING.md) — 外部コントリビュータ向け（英語）
