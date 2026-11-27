import { readFileSync } from "node:fs"

const tag = process.argv[2]
if (!["latest", "next", "beta", "next-12", "next-13"].includes(tag))
  throw new Error("Unsupported ReScript dist-tag")
const tags = JSON.parse(readFileSync(0, "utf8"))
if (!tags || typeof tags !== "object" || Array.isArray(tags)) {
  throw new Error("Expected a registry dist-tags object")
}
if (!Object.hasOwn(tags, tag)) {
  if (tag === "latest") throw new Error("Registry response is missing the latest tag")
  console.log("skip=true")
} else {
  const version = tags[tag]
  if (
    typeof version !== "string" ||
    !/^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?(?:\+[0-9A-Za-z.-]+)?$/.test(version)
  ) {
    throw new Error("Invalid registry version")
  }
  console.log("skip=false")
  console.log(`version=${version}`)
}
