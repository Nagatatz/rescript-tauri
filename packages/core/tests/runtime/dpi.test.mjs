// Dpi exposes plain JS class wrappers (LogicalSize / PhysicalSize /
// LogicalPosition / PhysicalPosition / Size / Position) — no IPC is
// involved. Tests just instantiate and read back the data.
import { describe, expect, it } from "vitest"
import * as Dpi from "../../src/Dpi.res.mjs"

describe("Dpi.LogicalSize", () => {
  it("make stores width / height and getters return them", () => {
    const s = Dpi.LogicalSize.make(800, 600)
    expect(Dpi.LogicalSize.width(s)).toBe(800)
    expect(Dpi.LogicalSize.height(s)).toBe(600)
  })
})

describe("Dpi.PhysicalSize", () => {
  it("make + width/height/toLogical round-trip", () => {
    const p = Dpi.PhysicalSize.make(1600, 1200)
    expect(Dpi.PhysicalSize.width(p)).toBe(1600)
    expect(Dpi.PhysicalSize.height(p)).toBe(1200)

    // toLogical(scaleFactor) divides by scale factor.
    const l = Dpi.PhysicalSize.toLogical(p, 2.0)
    expect(Dpi.LogicalSize.width(l)).toBe(800)
    expect(Dpi.LogicalSize.height(l)).toBe(600)
  })
})

describe("Dpi.LogicalPosition", () => {
  it("make + x/y", () => {
    const p = Dpi.LogicalPosition.make(10, 20)
    expect(Dpi.LogicalPosition.x(p)).toBe(10)
    expect(Dpi.LogicalPosition.y(p)).toBe(20)
  })
})

describe("Dpi.PhysicalPosition", () => {
  it("make + x/y/toLogical round-trip", () => {
    const p = Dpi.PhysicalPosition.make(40, 80)
    expect(Dpi.PhysicalPosition.x(p)).toBe(40)
    expect(Dpi.PhysicalPosition.y(p)).toBe(80)

    const l = Dpi.PhysicalPosition.toLogical(p, 2.0)
    expect(Dpi.LogicalPosition.x(l)).toBe(20)
    expect(Dpi.LogicalPosition.y(l)).toBe(40)
  })
})

describe("Dpi.Size", () => {
  it("fromLogical wraps a LogicalSize and toPhysical converts back", () => {
    const logical = Dpi.LogicalSize.make(100, 200)
    const sz = Dpi.Size.fromLogical(logical)
    const phys = Dpi.Size.toPhysical(sz, 2.0)
    expect(Dpi.PhysicalSize.width(phys)).toBe(200)
    expect(Dpi.PhysicalSize.height(phys)).toBe(400)
  })

  it("fromPhysical wraps a PhysicalSize and toLogical converts back", () => {
    const physical = Dpi.PhysicalSize.make(800, 600)
    const sz = Dpi.Size.fromPhysical(physical)
    const logical = Dpi.Size.toLogical(sz, 2.0)
    expect(Dpi.LogicalSize.width(logical)).toBe(400)
    expect(Dpi.LogicalSize.height(logical)).toBe(300)
  })
})

describe("Dpi.Position", () => {
  it("fromLogical wraps a LogicalPosition and toPhysical converts back", () => {
    const logical = Dpi.LogicalPosition.make(50, 100)
    const pos = Dpi.Position.fromLogical(logical)
    const phys = Dpi.Position.toPhysical(pos, 2.0)
    expect(Dpi.PhysicalPosition.x(phys)).toBe(100)
    expect(Dpi.PhysicalPosition.y(phys)).toBe(200)
  })

  it("fromPhysical wraps a PhysicalPosition and toLogical converts back", () => {
    const physical = Dpi.PhysicalPosition.make(400, 800)
    const pos = Dpi.Position.fromPhysical(physical)
    const logical = Dpi.Position.toLogical(pos, 2.0)
    expect(Dpi.LogicalPosition.x(logical)).toBe(200)
    expect(Dpi.LogicalPosition.y(logical)).toBe(400)
  })
})
