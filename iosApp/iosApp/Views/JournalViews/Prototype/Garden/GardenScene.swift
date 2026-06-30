import SwiftUI
import Shared

typealias Color = SwiftUI.Color

// =============================================================================
// Isometric "Forest"-style garden — 1:1 translation of GardenScene.kt (331 lines).
//
// Fakes a 3-D plot with a 2.5-D isometric projection on a SwiftUI Canvas.
// Each tile is one day; days with entries grow a plant (taller/fuller with more).
// =============================================================================

// MARK: - Color Constants

// NOTE: A single uniform grass tone for every tile so the top surface reads as
// one seamless meadow instead of a two-tone checkerboard.
private let grassTop  = Color(red: 0x8F / 255.0, green: 0xCB / 255.0, blue: 0x9B / 255.0)
private let grassEdge  = Color(red: 0x5F / 255.0, green: 0xA8 / 255.0, blue: 0x77 / 255.0)
private let soilLeft   = Color(red: 0x5E / 255.0, green: 0x4A / 255.0, blue: 0x38 / 255.0)
private let soilRight  = Color(red: 0x7A / 255.0, green: 0x5C / 255.0, blue: 0x46 / 255.0)
private let flowerColors: [Color] = [
    Color(red: 0xE5 / 255.0, green: 0xA3 / 255.0, blue: 0xB8 / 255.0),
    Color(red: 0xF6 / 255.0, green: 0xC4 / 255.0, blue: 0x53 / 255.0),
    Color(red: 0xB7 / 255.0, green: 0xE4 / 255.0, blue: 0xC7 / 255.0),
    Color(red: 0xC9 / 255.0, green: 0xA7 / 255.0, blue: 0xEB / 255.0),
]

/// A foliage color set so trees are not all the same green.
private struct Foliage {
    let dark: Color
    let mid: Color
    let light: Color
    let blossom: Color?

    init(_ dark: Color, _ mid: Color, _ light: Color, blossom: Color? = nil) {
        self.dark = dark; self.mid = mid; self.light = light; self.blossom = blossom
    }
}

private let foliagePalettes: [Foliage] = [
    Foliage(Color(red: 0x0F/255, green: 0x6E/255, blue: 0x56/255), Color(red: 0x2E/255, green: 0x95/255, blue: 0x76/255), Color(red: 0x7F/255, green: 0xC0/255, blue: 0xA8/255)),
    Foliage(Color(red: 0x3E/255, green: 0x7D/255, blue: 0x3A/255), Color(red: 0x5B/255, green: 0xA1/255, blue: 0x52/255), Color(red: 0x9E/255, green: 0xD3/255, blue: 0x6B/255)),
    Foliage(Color(red: 0x2E/255, green: 0x6B/255, blue: 0x57/255), Color(red: 0x3E/255, green: 0x95/255, blue: 0x76/255), Color(red: 0x8F/255, green: 0xD0/255, blue: 0xB6/255)),
    Foliage(Color(red: 0x5C/255, green: 0x7A/255, blue: 0x1E/255), Color(red: 0x87/255, green: 0xA6/255, blue: 0x2F/255), Color(red: 0xC2/255, green: 0xD2/255, blue: 0x57/255)),
    Foliage(Color(red: 0x1F/255, green: 0x6E/255, blue: 0x4C/255), Color(red: 0x3E/255, green: 0x95/255, blue: 0x76/255), Color(red: 0xBF/255, green: 0xE3/255, blue: 0xC8/255), blossom: Color(red: 0xE5/255, green: 0xA3/255, blue: 0xB8/255)),
    Foliage(Color(red: 0x23/255, green: 0x5C/255, blue: 0x46/255), Color(red: 0x2E/255, green: 0x84/255, blue: 0x66/255), Color(red: 0x6F/255, green: 0xB8/255, blue: 0x9A/255)),
]

// MARK: - Layout

private struct GardenLayout {
    let originX: CGFloat
    let originY: CGFloat
    let tileW: CGFloat
    let tileH: CGFloat
    let depth: CGFloat
}

private func layoutFor(width: CGFloat, columns: Int, rows: Int) -> GardenLayout {
    let margin = width * 0.06
    let tileW = (width - 2 * margin) * 2 / CGFloat(columns + rows)
    let tileH = tileW / 2
    let treeHeadroom = tileW * 0.95
    return GardenLayout(
        originX: width / 2,
        originY: treeHeadroom + tileH / 2,
        tileW: tileW,
        tileH: tileH,
        depth: tileH * 0.7
    )
}

private func center(_ l: GardenLayout, col: Int, row: Int) -> CGPoint {
    CGPoint(
        x: l.originX + CGFloat(col - row) * (l.tileW / 2),
        y: l.originY + CGFloat(col + row) * (l.tileH / 2)
    )
}

/// Reverse projection: which tile index a tap landed on.
private func tileAt(_ l: GardenLayout, point: CGPoint, columns: Int, rows: Int) -> Int? {
    let a = (point.x - l.originX) / (l.tileW / 2)
    let b = (point.y - l.originY) / (l.tileH / 2)
    let col = Int(((b + a) / 2).rounded())
    let row = Int(((b - a) / 2).rounded())
    guard col >= 0, col < columns, row >= 0, row < rows else { return nil }
    return row * columns + col
}

private func scaleFor(_ count: Int) -> CGFloat {
    switch count {
    case 1: return 0.8
    case 2: return 1.0
    case 3: return 1.15
    default: return 1.3
    }
}

// MARK: - View

/// Isometric garden rendered on a SwiftUI Canvas.
struct GardenSceneView: View {
    let tiles: [GardenTile]
    var columns: Int = 5
    var rows: Int = 5
    var interactive: Bool = false
    var selectedTile: Int? = nil
    var onTileTap: ((Int) -> Void)? = nil

    var body: some View {
        Canvas { ctx, size in
            let l = layoutFor(width: size.width, columns: columns, rows: rows)

            // --- Soil walls ---
            let east = CGPoint(x: center(l, col: columns - 1, row: 0).x + l.tileW / 2, y: center(l, col: columns - 1, row: 0).y)
            let south = CGPoint(x: center(l, col: columns - 1, row: rows - 1).x, y: center(l, col: columns - 1, row: rows - 1).y + l.tileH / 2)
            let west = CGPoint(x: center(l, col: 0, row: rows - 1).x - l.tileW / 2, y: center(l, col: 0, row: rows - 1).y)
            let down = CGSize(width: 0, height: l.depth)

            ctx.fill(quadPath(west, south, south + down, west + down), with: .color(soilLeft))
            ctx.fill(quadPath(south, east, east + down, south + down), with: .color(soilRight))
            drawSoilTexture(ctx: ctx, west: west, south: south, east: east, down: down)

            // --- Grass top faces ---
            for row in 0..<rows {
                for col in 0..<columns {
                    let c = center(l, col: col, row: row)
                    drawDiamond(ctx: ctx, c: c, w: l.tileW, h: l.tileH, fill: grassTop)
                    drawGrassTufts(ctx: ctx, c: c, tileW: l.tileW, tileH: l.tileH, index: row * columns + col)
                }
            }

            // --- Selection highlight ---
            if let sel = selectedTile {
                let col = sel % columns
                let row = sel / columns
                if row < rows {
                    let c = center(l, col: col, row: row)
                    let path = diamondPath(c: c, w: l.tileW, h: l.tileH)
                    ctx.fill(path, with: .color(IremiaColors.teal100.opacity(0.55)))
                    ctx.stroke(path, with: .color(IremiaColors.teal700), lineWidth: 2.5)
                }
            }

            // --- Plants, back-to-front ---
            var gridOrder: [(Int, Int)] = []
            for row in 0..<rows { for col in 0..<columns { gridOrder.append((col, row)) } }
            gridOrder.sort { $0.0 + $0.1 < $1.0 + $1.1 }

            for (col, row) in gridOrder {
                let index = row * columns + col
                let base = center(l, col: col, row: row)
                let tile = index < tiles.count ? tiles[index] : nil
                let count = tile?.entryCount ?? 0
                if count == 0 {
                    drawDecoration(ctx: ctx, base: base, tileW: l.tileW, index: index)
                } else {
                    drawShadow(ctx: ctx, base: base, tileW: l.tileW)
                    
                    if let plantType = tile?.plantType,
                       let uiImage = plantType.image.toUIImage() {
                        let scale = scaleFor(Int(count))
                        let spriteWidth = l.tileW * scale
                        let aspect = uiImage.size.height / uiImage.size.width
                        let spriteHeight = spriteWidth * aspect
                        
                        let left = base.x - spriteWidth / 2
                        let top = (base.y + l.tileH / 2) - spriteHeight
                        
                        let rect = CGRect(x: left, y: top, width: spriteWidth, height: spriteHeight)
                        let resolvedImage = ctx.resolve(Image(uiImage: uiImage))
                        ctx.draw(resolvedImage, in: rect)
                    } else {
                        // Fallback to procedural
                        let foliage = foliagePalettes[(index * 5 + 2) % foliagePalettes.count]
                        let scale = scaleFor(Int(count))
                        if index % 2 == 0 {
                            drawPine(ctx: ctx, base: base, tileW: l.tileW, scale: scale, foliage: foliage)
                        } else {
                            drawBroadleaf(ctx: ctx, base: base, tileW: l.tileW, scale: scale, foliage: foliage, index: index)
                        }
                    }
                }
            }
        }
        .aspectRatio(1.35, contentMode: .fit)
        .contentShape(Rectangle())
        .onTapGesture { location in
            guard interactive, let tap = onTileTap else { return }
            // NOTE: We need the actual rendered size. Canvas uses the proposed size.
            // This approximation works because aspectRatio constrains the canvas.
        }
        .simultaneousGesture(
            interactive ?
            DragGesture(minimumDistance: 0)
                .onEnded { value in
                    guard let tap = onTileTap else { return }
                    // Use the tap location from the gesture
                    let point = value.location
                    // We need the size, estimate from parent
                }
            : nil
        )
        .overlay(
            interactive ?
            GeometryReader { geo in
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { location in
                        let l = layoutFor(width: geo.size.width, columns: columns, rows: rows)
                        if let idx = tileAt(l, point: location, columns: columns, rows: rows) {
                            onTileTap?(idx)
                        }
                    }
            }
            : nil
        )
    }
}

// MARK: - Drawing Helpers

private func diamondPath(c: CGPoint, w: CGFloat, h: CGFloat) -> Path {
    Path { p in
        p.move(to: CGPoint(x: c.x, y: c.y - h / 2))
        p.addLine(to: CGPoint(x: c.x + w / 2, y: c.y))
        p.addLine(to: CGPoint(x: c.x, y: c.y + h / 2))
        p.addLine(to: CGPoint(x: c.x - w / 2, y: c.y))
        p.closeSubpath()
    }
}

private func drawDiamond(ctx: GraphicsContext, c: CGPoint, w: CGFloat, h: CGFloat, fill: Color) {
    let path = diamondPath(c: c, w: w, h: h)
    ctx.fill(path, with: .color(fill))
    ctx.stroke(path, with: .color(grassEdge.opacity(0.45)), lineWidth: 1)
}

private func drawGrassTufts(ctx: GraphicsContext, c: CGPoint, tileW: CGFloat, tileH: CGFloat, index: Int) {
    let blade = tileH * 0.5
    let spots: [CGSize] = [
        CGSize(width: -tileW * 0.14, height: tileH * 0.06),
        CGSize(width: tileW * 0.12, height: -tileH * 0.05),
        CGSize(width: tileW * 0.02, height: tileH * 0.13),
    ]
    for (i, off) in spots.enumerated() {
        guard (index + i) % 3 != 0 else { continue }
        let p = CGPoint(x: c.x + off.width, y: c.y + off.height)
        let dir: CGFloat = (index + i) % 2 == 0 ? 1 : -1
        drawBlade(ctx: ctx, base: p, length: blade, bend: dir * 0.4, color: grassEdge)
        let p2 = CGPoint(x: p.x + tileW * 0.035, y: p.y)
        drawBlade(ctx: ctx, base: p2, length: blade * 0.8, bend: -dir * 0.35, color: grassEdge.opacity(0.8))
    }
}

private func drawBlade(ctx: GraphicsContext, base: CGPoint, length: CGFloat, bend: CGFloat, color: Color) {
    let tip = CGPoint(x: base.x + bend * length, y: base.y - length)
    let control = CGPoint(x: base.x + bend * length * 1.6, y: base.y - length * 0.55)
    var path = Path()
    path.move(to: base)
    path.addQuadCurve(to: tip, control: control)
    ctx.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: 2.4, lineCap: .round))
}

private func drawSoilTexture(ctx: GraphicsContext, west: CGPoint, south: CGPoint, east: CGPoint, down: CGSize) {
    for f: CGFloat in [0.42, 0.72] {
        let o = CGSize(width: 0, height: down.height * f)
        var line1 = Path(); line1.move(to: west + o); line1.addLine(to: south + o)
        ctx.stroke(line1, with: .color(.black.opacity(0.08)), lineWidth: 1)
        var line2 = Path(); line2.move(to: south + o); line2.addLine(to: east + o)
        ctx.stroke(line2, with: .color(.black.opacity(0.08)), lineWidth: 1)
    }
    let pebble = down.height * 0.12
    let positions: [(CGFloat, CGFloat)] = [(0.2, 0.35), (0.55, 0.6), (0.8, 0.3)]
    for (t, s) in positions {
        let pl = lerp(west, south, t: t) + CGSize(width: 0, height: down.height * s)
        ctx.fill(Path(ellipseIn: CGRect(x: pl.x - pebble, y: pl.y - pebble / 2, width: pebble * 2, height: pebble)), with: .color(.black.opacity(0.10)))
        let pr = lerp(south, east, t: t) + CGSize(width: 0, height: down.height * s)
        ctx.fill(Path(ellipseIn: CGRect(x: pr.x - pebble, y: pr.y - pebble / 2, width: pebble * 2, height: pebble)), with: .color(.white.opacity(0.06)))
    }
}

private func drawShadow(ctx: GraphicsContext, base: CGPoint, tileW: CGFloat) {
    ctx.fill(
        Path(ellipseIn: CGRect(x: base.x - tileW * 0.26, y: base.y - tileW * 0.05, width: tileW * 0.52, height: tileW * 0.2)),
        with: .color(.black.opacity(0.13))
    )
}

private func drawPine(ctx: GraphicsContext, base: CGPoint, tileW: CGFloat, scale: CGFloat, foliage: Foliage) {
    let trunkW = tileW * 0.06 * scale
    let trunkH = tileW * 0.12 * scale
    ctx.fill(Path(CGRect(x: base.x - trunkW / 2, y: base.y - trunkH, width: trunkW, height: trunkH)), with: .color(IremiaColors.branch))

    let tierW = tileW * 0.52 * scale
    let tierH = tileW * 0.30 * scale
    var baseY = base.y - trunkH
    for tier in 0..<3 {
        let w = tierW * (1 - CGFloat(tier) * 0.18)
        let apexY = baseY - tierH
        let apex = CGPoint(x: base.x, y: apexY)
        let bl = CGPoint(x: base.x - w / 2, y: baseY)
        let br = CGPoint(x: base.x + w / 2, y: baseY)
        ctx.fill(triPath(apex, br, bl), with: .color(foliage.dark))
        let midLeft = CGPoint(x: base.x - w / 6, y: baseY)
        ctx.fill(triPath(apex, bl, midLeft), with: .color(foliage.mid))
        baseY = apexY + tierH * 0.38
    }
}

private func drawBroadleaf(ctx: GraphicsContext, base: CGPoint, tileW: CGFloat, scale: CGFloat, foliage: Foliage, index: Int) {
    let trunkW = tileW * 0.07 * scale
    let trunkH = tileW * 0.16 * scale
    ctx.fill(Path(CGRect(x: base.x - trunkW / 2, y: base.y - trunkH, width: trunkW, height: trunkH)), with: .color(IremiaColors.branch))

    let r = tileW * 0.24 * scale
    let crown = CGPoint(x: base.x, y: base.y - trunkH - r * 0.5)
    ctx.fill(Path(ellipseIn: CGRect(x: crown.x - r, y: crown.y - r, width: r * 2, height: r * 2)), with: .color(foliage.dark))
    ctx.fill(Path(ellipseIn: CGRect(x: crown.x - r * 0.7 - r * 0.8, y: crown.y + r * 0.1 - r * 0.8, width: r * 1.6, height: r * 1.6)), with: .color(foliage.dark))
    ctx.fill(Path(ellipseIn: CGRect(x: crown.x + r * 0.7 - r * 0.8, y: crown.y + r * 0.1 - r * 0.8, width: r * 1.6, height: r * 1.6)), with: .color(foliage.dark))
    ctx.fill(Path(ellipseIn: CGRect(x: crown.x - r * 0.25 - r * 0.85, y: crown.y - r * 0.45 - r * 0.85, width: r * 1.7, height: r * 1.7)), with: .color(foliage.mid))
    ctx.fill(Path(ellipseIn: CGRect(x: crown.x - r * 0.45 - r * 0.35, y: crown.y - r * 0.55 - r * 0.35, width: r * 0.7, height: r * 0.7)), with: .color(foliage.light.opacity(0.85)))

    if let blossom = foliage.blossom {
        let spots: [CGSize] = [CGSize(width: -r * 0.4, height: -r * 0.1), CGSize(width: r * 0.45, height: -r * 0.05), CGSize(width: 0, height: -r * 0.6), CGSize(width: r * 0.1, height: r * 0.2)]
        for (i, off) in spots.enumerated() {
            if (index + i) % 2 == 0 {
                let center = CGPoint(x: crown.x + off.width, y: crown.y + off.height)
                ctx.fill(Path(ellipseIn: CGRect(x: center.x - r * 0.12, y: center.y - r * 0.12, width: r * 0.24, height: r * 0.24)), with: .color(blossom))
            }
        }
    }
}

private func drawDecoration(ctx: GraphicsContext, base: CGPoint, tileW: CGFloat, index: Int) {
    switch (index * 31 + 7) % 10 {
    case 0...2:
        let color = flowerColors[index % flowerColors.count]
        ctx.fill(Path(CGRect(x: base.x - tileW * 0.012, y: base.y - tileW * 0.14, width: tileW * 0.024, height: tileW * 0.14)), with: .color(IremiaColors.garden500))
        let center = CGPoint(x: base.x, y: base.y - tileW * 0.16)
        ctx.fill(Path(ellipseIn: CGRect(x: center.x - tileW * 0.05, y: center.y - tileW * 0.05, width: tileW * 0.1, height: tileW * 0.1)), with: .color(color))
    case 3...4:
        let c1 = CGPoint(x: base.x, y: base.y - tileW * 0.05)
        ctx.fill(Path(ellipseIn: CGRect(x: c1.x - tileW * 0.1, y: c1.y - tileW * 0.1, width: tileW * 0.2, height: tileW * 0.2)), with: .color(IremiaColors.garden500))
        let c2 = CGPoint(x: base.x - tileW * 0.1, y: base.y - tileW * 0.02)
        ctx.fill(Path(ellipseIn: CGRect(x: c2.x - tileW * 0.08, y: c2.y - tileW * 0.08, width: tileW * 0.16, height: tileW * 0.16)), with: .color(IremiaColors.garden500))
        let c3 = CGPoint(x: base.x + tileW * 0.08, y: base.y - tileW * 0.06)
        ctx.fill(Path(ellipseIn: CGRect(x: c3.x - tileW * 0.06, y: c3.y - tileW * 0.06, width: tileW * 0.12, height: tileW * 0.12)), with: .color(IremiaColors.garden300))
    default:
        break
    }
}

// MARK: - Path Helpers

private func triPath(_ a: CGPoint, _ b: CGPoint, _ c: CGPoint) -> Path {
    Path { p in p.move(to: a); p.addLine(to: b); p.addLine(to: c); p.closeSubpath() }
}

private func quadPath(_ a: CGPoint, _ b: CGPoint, _ c: CGPoint, _ d: CGPoint) -> Path {
    Path { p in p.move(to: a); p.addLine(to: b); p.addLine(to: c); p.addLine(to: d); p.closeSubpath() }
}

private func lerp(_ a: CGPoint, _ b: CGPoint, t: CGFloat) -> CGPoint {
    CGPoint(x: a.x + (b.x - a.x) * t, y: a.y + (b.y - a.y) * t)
}

// MARK: - CGPoint + CGSize arithmetic

private extension CGPoint {
    static func + (lhs: CGPoint, rhs: CGSize) -> CGPoint {
        CGPoint(x: lhs.x + rhs.width, y: lhs.y + rhs.height)
    }
}
