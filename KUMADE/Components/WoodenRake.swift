import SwiftUI

struct WoodenRake: View {
    var body: some View {
        Canvas { context, size in
            let unit = size.width / 100
            var drawing = context
            drawing.scaleBy(x: unit, y: size.height / 100)
            let wood = Color(red: 0.78, green: 0.58, blue: 0.35)
            let edge = Color(red: 0.53, green: 0.34, blue: 0.20)
            let light = Color(red: 0.96, green: 0.79, blue: 0.51)

            func stroke(_ line: Path, _ color: Color, _ width: CGFloat) {
                drawing.stroke(line, with: .color(color), style: StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round))
            }

            let handle = Path { path in
                path.move(to: CGPoint(x: 50, y: 50))
                path.addLine(to: CGPoint(x: 50, y: 92))
            }
            stroke(handle, edge, 4.8)
            stroke(handle, wood, 3.8)
            stroke(Path { path in
                path.move(to: CGPoint(x: 49, y: 63))
                path.addLine(to: CGPoint(x: 49, y: 91))
            }, light, 0.65)

            for tooth in -8...8 {
                let spread = CGFloat(tooth) / 8
                let tip = CGPoint(x: 50 + spread * 36, y: 12 + abs(spread) * 14)
                let tine = Path { path in
                    path.move(to: CGPoint(x: 50 + spread * 2, y: 63))
                    path.addQuadCurve(to: tip, control: CGPoint(x: 50 + spread * 26, y: 29))
                    path.addQuadCurve(to: CGPoint(x: tip.x - spread * 1.3, y: tip.y - 4),
                                      control: CGPoint(x: tip.x + spread * 0.5, y: tip.y - 3))
                }
                stroke(tine, edge, 1.95)
                stroke(tine, light, 1.22)
            }

            let brace = Path { path in
                path.move(to: CGPoint(x: 25, y: 41))
                path.addQuadCurve(to: CGPoint(x: 75, y: 41), control: CGPoint(x: 50, y: 33))
            }
            stroke(brace, edge, 2.9)
            stroke(brace, wood, 1.9)

            for index in 0..<6 {
                let y = 60 + CGFloat(index) * 0.85
                stroke(Path { path in
                    path.move(to: CGPoint(x: 47.6, y: y))
                    path.addLine(to: CGPoint(x: 52.4, y: y + 0.55))
                }, index.isMultiple(of: 2) ? Workshop.ink : edge, 0.95)
            }
        }
        .accessibilityHidden(true)
    }
}
