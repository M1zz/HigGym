import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

let S: CGFloat = 1024
let space = CGColorSpace(name: CGColorSpace.sRGB)!
let ctx = CGContext(data: nil, width: Int(S), height: Int(S), bitsPerComponent: 8,
                    bytesPerRow: 0, space: space,
                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!

func rgb(_ hex: UInt32, _ a: CGFloat = 1) -> CGColor {
    CGColor(srgbRed: CGFloat((hex >> 16) & 0xFF)/255,
            green: CGFloat((hex >> 8) & 0xFF)/255,
            blue: CGFloat(hex & 0xFF)/255, alpha: a)
}

// 배경: 팔레트의 accent → accent2 로 흐르는 대각 그라디언트.
let grad = CGGradient(colorsSpace: space,
                      colors: [rgb(0x2E7BF6), rgb(0x6B5CF0), rgb(0x8A5CE8)] as CFArray,
                      locations: [0, 0.55, 1])!
ctx.drawLinearGradient(grad, start: CGPoint(x: 0, y: S), end: CGPoint(x: S, y: 0), options: [])

// 화면(캔버스) — 흰 라운드 사각형.
let w: CGFloat = 528, h: CGFloat = 672
let frame = CGRect(x: (S - w)/2, y: (S - h)/2 - 8, width: w, height: h)
ctx.setFillColor(rgb(0x000000, 0.16))
ctx.addPath(CGPath(roundedRect: frame.offsetBy(dx: 0, dy: -18), cornerWidth: 84, cornerHeight: 84, transform: nil))
ctx.fillPath()
ctx.setFillColor(rgb(0xFFFFFF))
ctx.addPath(CGPath(roundedRect: frame, cornerWidth: 84, cornerHeight: 84, transform: nil))
ctx.fillPath()

// 상단 툴바 — 이 앱의 주제. 강조색으로 채워 한눈에 읽히게.
let pad: CGFloat = 56
let bar = CGRect(x: frame.minX + pad, y: frame.maxY - pad - 96, width: w - pad*2, height: 96)
ctx.setFillColor(rgb(0x2E7BF6))
ctx.addPath(CGPath(roundedRect: bar, cornerWidth: 48, cornerHeight: 48, transform: nil))
ctx.fillPath()

// 본문 — 큰 카드 하나와 짧은 줄 하나. 실제 화면의 리듬을 그대로.
let card = CGRect(x: frame.minX + pad, y: bar.minY - 44 - 232, width: w - pad*2, height: 232)
ctx.setFillColor(rgb(0x2E7BF6, 0.20))
ctx.addPath(CGPath(roundedRect: card, cornerWidth: 44, cornerHeight: 44, transform: nil))
ctx.fillPath()

ctx.setFillColor(rgb(0x2E7BF6, 0.20))
let line = CGRect(x: frame.minX + pad, y: card.minY - 60 - 52, width: (w - pad*2) * 0.58, height: 52)
ctx.addPath(CGPath(roundedRect: line, cornerWidth: 26, cornerHeight: 26, transform: nil))
ctx.fillPath()

// 하단 탭바 — 점 세 개, 가운데만 선택된 상태.
let dotY = frame.minY + pad + 30
for i in 0..<3 {
    let cx = frame.midX + CGFloat(i - 1) * 118
    ctx.setFillColor(i == 1 ? rgb(0x2E7BF6) : rgb(0x2E7BF6, 0.22))
    ctx.fillEllipse(in: CGRect(x: cx - 32, y: dotY - 32, width: 64, height: 64))
}

let img = ctx.makeImage()!
let url = URL(fileURLWithPath: CommandLine.arguments[1]) as CFURL
let dest = CGImageDestinationCreateWithURL(url, UTType.png.identifier as CFString, 1, nil)!
CGImageDestinationAddImage(dest, img, nil)
CGImageDestinationFinalize(dest)
