# Menu/App 仕上げポリッシュ — タスクリスト

## Phase 1: ステアリング作成

- [x] 要件定義 (`requirements.md`)
- [x] 設計 (`design.md`)
- [x] タスクリスト (`tasklist.md`)
- [x] worktree 作成 (`menu-app-polish`)

## Phase 2: 実装

### Step A — Menu.popup / Submenu.popup の Dpi 化

- [x] `packages/core/src/Menu.res` の `Submenu` 内 `popup` の `~at: 'pos` を `~at: Dpi.Position.t` に置換
- [x] `packages/core/src/Menu.res` の `Menu` 内 `popup` の `~at: 'pos` を `~at: Dpi.Position.t` に置換
- [x] `packages/core/src/Menu.resi` の対応シグネチャ更新（"polymorphic until full Dpi integration" 削除）
- [x] `packages/core/tests/menu_signature.res` の該当箇所追従

### Step B — App.setTheme パラメータ名改善

- [x] `packages/core/src/App.res` で `~theme` → `~preferred` に rename
- [x] `packages/core/src/App.resi` で対応シグネチャ更新
- [x] `packages/core/tests/app_signature.res` でテスト追従

## Phase 3: 検証

- [x] `pnpm --recursive build` が成功する
- [x] `pnpm --recursive test` が成功する
- [x] `examples/` で `App.setTheme` を使う箇所がないか確認（あれば修正）

## Phase 4: コミット

- [x] Step A を 1 コミット: `♻️ Concretize Dpi.Position.t in Menu/Submenu popup`
- [x] Step B を 1 コミット: `♻️ Rename App.setTheme parameter to ~preferred`
- [ ] tasklist.md 更新を最終コミット

## Phase 5: マージ

- [ ] AskUserQuestion で main マージ可否確認
- [ ] 承認後、worktree マージ・クリーンアップ手順に従い実行
- [ ] クリーンアップ完了の検証
