# Typed IPC verification pilot

- Runtime/property: `pnpm --filter @rescript-tauri/core test` runs the compiled ReScript bindings against Tauri's JavaScript mock boundary. The generated property fixes seed 1127, and tests dispatch, decoding and error origin across generated JSON and text.
- Focused mutation: `node tools/check-ipc-mutants.mjs` builds first, runs the baseline and mutates three behaviors in a disposable copy of emitted JavaScript. A compile error, timeout or missing Vitest assertion is not a kill. This is a focused pilot, not a package-wide score.
- Formal proof: with Lean 4.23.0, run `lean tools/formal/IpcRouting.lean`. The theorems quantify over opaque payloads and a total decoder for the three reply categories. The runtime property checks analogous behavior of the real binding. It does not prove native Tauri transport, exceptions from the encoder/decoder, or machine code.
- Compatibility: `compat-rescript-prerelease.yml` reports upstream stable and the published major-specific prerelease tags independently. A missing optional tag is untested; registry errors are failures. The existing latest-Tauri workflow remains separate.
