import { spawnSync } from "node:child_process"
import { test } from "node:test"
import assert from "node:assert/strict"
import { fileURLToPath } from "node:url"

const script = fileURLToPath(new URL("./resolve-rescript-tag.mjs", import.meta.url))
const resolve = (tag, input) =>
  spawnSync(process.execPath, [script, tag], { input, encoding: "utf8" })

test("checks latest and published prereleases", () => {
  const tags = JSON.stringify({ latest: "12.3.1", "next-13": "13.0.0-alpha.1" })
  for (const [tag, version] of [
    ["latest", "12.3.1"],
    ["next-13", "13.0.0-alpha.1"],
  ]) {
    const result = resolve(tag, tags)
    assert.equal(result.status, 0, result.stderr)
    assert.equal(result.stdout, `skip=false\nversion=${version}\n`)
  }
})

test("only a genuinely unpublished optional tag is skipped", () => {
  const result = resolve("beta", '{"latest":"12.3.1"}')
  assert.equal(result.status, 0, result.stderr)
  assert.equal(result.stdout, "skip=true\n")
  for (const [tag, input] of [
    ["latest", "{}"],
    ["next", ""],
    ["next", "null"],
    ["next", "[]"],
    ["next", '{"next":42}'],
    ["next", JSON.stringify({ next: "13.0.0\nskip=true" })],
  ]) {
    const failed = resolve(tag, input)
    assert.notEqual(failed.status, 0, `${tag}: ${input}`)
    assert.equal(failed.stdout, "")
  }
})
