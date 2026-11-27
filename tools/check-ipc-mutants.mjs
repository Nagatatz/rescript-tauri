import { spawnSync } from "node:child_process"
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs"
import { tmpdir } from "node:os"
import { basename, join } from "node:path"
import { fileURLToPath, pathToFileURL } from "node:url"

const root = fileURLToPath(new URL("../", import.meta.url))
const emitted = join(root, "packages/core/src/Core.res.mjs")
const tmp = mkdtempSync(join(tmpdir(), "rescript-tauri-ipc-"))
const mutant = join(root, "packages/core/src", `.${basename(tmp)}.mjs`)
const report = join(tmp, "report.json")
const property = "routes generated IPC outcomes without confusing decode and backend failures"
const env = { ...process.env }
delete env.RESCRIPT_TAURI_IPC_TEST_MODULE

function run(args, extraEnv = {}) {
  const result = spawnSync("pnpm", ["--filter", "@rescript-tauri/core", ...args], {
    cwd: root,
    env: { ...env, ...extraEnv },
    encoding: "utf8",
    timeout: 120000,
  })
  if (result.error || result.signal) throw result.error ?? new Error(`Signal: ${result.signal}`)
  return result
}

const args = [
  "exec",
  "vitest",
  "run",
  "tests/runtime/core_command_properties.test.mjs",
  "--reporter=json",
  `--outputFile=${report}`,
]

function editOne(source, before, after) {
  if (source.split(before).length !== 2) {
    throw new Error(`Expected a single emitted mutation site: ${before}`)
  }
  return source.replace(before, after)
}

try {
  const build = run(["build"])
  if (build.status !== 0) throw new Error(`Build failed: ${build.stdout}\n${build.stderr}`)
  const baseline = run(args)
  if (baseline.status !== 0)
    throw new Error(`Baseline failed: ${baseline.stdout}\n${baseline.stderr}`)
  const source = readFileSync(emitted, "utf8")
  const cases = [
    ["decode error relabeled as backend", 'TAG: "DecodeError"', 'TAG: "RustError"'],
    ["backend rejection relabeled as decode", 'TAG: "RustError"', 'TAG: "DecodeError"'],
    [
      "wrong IPC command forwarded",
      "Core.invoke(cmd.name, encoded,",
      "Core.invoke(cmd.name + '-wrong', encoded,",
    ],
  ]
  for (const [label, before, after] of cases) {
    // Only mutate the non-throwing invoke, not invokeExn.
    const index = source.indexOf("async function invokeExn(")
    if (index < 0) throw new Error("Could not locate invokeExn boundary")
    writeFileSync(mutant, editOne(source.slice(0, index), before, after) + source.slice(index))
    rmSync(report, { force: true })
    const outcome = run(args, { RESCRIPT_TAURI_IPC_TEST_MODULE: pathToFileURL(mutant).href })
    const data = JSON.parse(readFileSync(report, "utf8"))
    const failures = data.testResults
      .flatMap((file) => file.assertionResults)
      .filter(
        (result) =>
          result.title === property &&
          result.status === "failed" &&
          result.failureMessages.some((message) => message.includes("Property failed")),
      )
    if (outcome.status !== 1 || failures.length !== 1) {
      throw new Error(
        `No verified property failure for: ${label}\n${outcome.stdout}\n${outcome.stderr}`,
      )
    }
    console.log(`Killed: ${label}`)
  }
} finally {
  rmSync(mutant, { force: true })
  rmSync(tmp, { recursive: true, force: true })
}
