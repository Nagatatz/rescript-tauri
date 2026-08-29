# Requirements: Fix Windows Cargo Lock

## Problem
CI fails on `windows-latest` because Tauri's `generate_context!` macro scans the `frontendDist` directory (set to `../`) for assets. Since `src-tauri/target` is a subdirectory, it picks up `.cargo-lock` and other artifacts currently being written by the same Cargo process, leading to "The process cannot access the file because another process has locked a portion of the file" (os error 33).

## Goal
Redirect Cargo build artifacts outside of the examples' directory structure so that they are not scanned by Tauri as frontend assets.

## Success Criteria
- [ ] No `target` directory exists inside `examples/*/src-tauri/` during build.
- [ ] Cargo artifacts are placed in a central directory at the repo root.
- [ ] `Cargo.lock` is moved to the repo root.
- [ ] `frontendDist: "../"` in `tauri.conf.json` no longer resolves to a path containing `target`.
