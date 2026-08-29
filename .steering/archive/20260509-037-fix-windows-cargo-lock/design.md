# Design: Cargo Workspace for Example Isolation

## Approach
Create a root `Cargo.toml` to define a Cargo workspace containing all examples.

### Why Workspace?
- **Centralized `target`**: By default, a workspace uses a single `target` directory at the workspace root.
- **Centralized `Cargo.lock`**: A workspace uses a single `Cargo.lock` at the root.
- **Isolation from Assets**: For an example located at `examples/hello-world/src-tauri`, the `frontendDist` is `../` (`examples/hello-world/`). The root `target` is at `../../../target`, which is NOT inside `examples/hello-world/`.

## Implementation
1. Root `Cargo.toml`:
   ```toml
   [workspace]
   members = ["examples/*/src-tauri"]
   resolver = "2"
   ```
2. `.gitignore`:
   Ensure `target/` and `Cargo.lock` are ignored at the root.

## Alternatives Considered
1. **Moving `index.html` to `src/`**: Would require updating all examples and potentially breaks access to `node_modules` for raw ES module loading.
2. **`.cargo/config.toml` with `target-dir`**: Relative paths are resolved relative to CWD, which varies depending on where `cargo` is called, making it brittle.
