# design — examples ビルドの `cookie` / `time` 破壊対処

| 項目 | 内容 |
|---|---|
| ステアリング番号 | 20260710-001 |
| 関連 | requirements.md |

## 1. 方針（改訂）

root Cargo workspace の `Cargo.lock` を追跡対象にし、現時点で解決可能かつ cookie が通る `time 0.3.53` を lock で固定する。CI は `--locked` で committed lock を強制するため、float 破壊が再発しない。

> **当初案からの変更**: `time` を `0.3.41` に precise pin する予定だったが、`plist 1.10.0`（tauri 2.11.5 経由）が `time ^0.3.47` を要求するため 0.3.41 は選択不可。かつ `time 0.3.53` で cookie 0.18.1 が正常コンパイルすることを確認したため、明示 pin は不要。lock で 0.3.53 を固定するだけで足りる（requirements.md「実装中の追加調査」参照）。

## 2. 変更対象（改訂）

| ファイル | 変更 |
|---|---|
| `.gitignore` | `Cargo.lock` 行を削除（ルート workspace lock を追跡対象化）+ 理由コメント追記 |
| `Cargo.lock`（新規 commit） | `cargo generate-lockfile` で生成（time 0.3.53 / cookie 0.18.1 に解決）。明示的な `cargo update --precise` は行わない |
| `.github/workflows/examples-build.yml` | 各 `cargo check --release` を `cargo check --release --locked` に変更（lock 逸脱を CI で検知。float 防止の実効化）。加えて push/pull_request の `paths` に `Cargo.lock` を追加（lock が依存を決める以上、lock 変更で examples-build を回すべき）。pull_request 側には欠けていた `.github/workflows/examples-build.yml` も追加し、workflow 編集を PR で検証可能にする |
| `docs/repository-structure.md` | §9 の `.gitignore` 行と §1 のルート `Cargo.lock` 記述を「commit 対象」に更新 |

## 3. float 破壊の背景（記録）

`Cargo.lock` はコメントを保持しないため、経緯は本 steering と `docs/repository-structure.md` の注記で残す:
- `cookie 0.18.1`（crates.io 最新）は `time 0.3.42`〜`0.3.52` の `Parsable::parse` シグネチャ変更で E0061 コンパイルエラー。
- `time 0.3.53`（2026-07-01）で upstream 修正され、cookie 0.18.1 が再びコンパイル可能。
- committed lock + `--locked` により、将来 `time` が再び壊れる版を出しても CI は lock 済みの動作版を使い続ける。解除・更新は明示的な `cargo update` 時のみ。

## 4. lockfile の位置

root `Cargo.toml` が `[workspace]` を宣言しており、13 example メンバー全体で `Cargo.lock` は **ルート 1 個**。各 example の `src-tauri` から `cargo check` してもルート lock を参照する。従って追跡対象はルート `Cargo.lock` のみ。

## 5. `--locked` 採用理由

committed lock があっても `--locked` 無しでは cargo が暗黙に lock を更新し得る。build ゲートでは lock 逸脱を **fail で顕在化** させるのが正道であり、`--locked` を付けることで pin が実効化する。examples-build.yml の各 `cargo check --release` ステップ（13 example 分）に一律付与する。

## 6. 検証（実施結果）

1. ✅ worktree で `cargo generate-lockfile` 成功（593 packages、time 0.3.53 / cookie 0.18.1 に解決）。
2. ✅ `cargo check --locked -p cookie` で cookie 0.18.1 が E0061 無しでコンパイル通過（time 0.3.53）。ディスク 92% のため full build は避け、失敗していた cookie の通過を確認。full な 3-OS 検証は PR CI に委ねる。
3. ✅ `Cargo.lock` の `time = 0.3.53` / `cookie = 0.18.1` を grep 確認。

## 7. リスクと対処

| リスク | 対処 |
|---|---|
| ~~resolver が time 0.3.41 を許さない~~（実際に発生: plist 1.10.0 が time ^0.3.47 要求） | 対処済み: time 0.3.53 で cookie が通るため pin 自体が不要になった |
| ディスク 92% で cargo build が失敗 | full build せず `cargo check` の cookie 通過まで。必要なら `cargo clean` で target を都度削減。最終検証は PR CI |
| committed lock が巨大 | 13-member Tauri workspace の lock は数千行だが正常。バイナリ crate では commit が定石で問題なし |
| 別セッションが同時に main を更新 | マージ直前に origin/main を rebase 確認（memory: 並列セッション高頻度更新） |
