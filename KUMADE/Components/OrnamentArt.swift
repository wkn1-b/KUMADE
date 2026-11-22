import SwiftUI

struct OrnamentArt: View {
    let kind: Ornament

    var body: some View {
        Canvas { context, size in
            let side = min(size.width, size.height)
            var art = context
            art.translateBy(x: (size.width - side) / 2, y: (size.height - side) / 2)
            art.scaleBy(x: side / 100, y: side / 100)
            let ink = Workshop.ink
            let red = Workshop.vermilion
            let gold = Color(red: 0.87, green: 0.69, blue: 0.33)
            let ivory = Color(red: 1, green: 0.96, blue: 0.86)
            let jade = Color(red: 0.26, green: 0.42, blue: 0.33)
            let rose = Color(red: 0.86, green: 0.47, blue: 0.39)

            func shape(_ path: Path, _ color: Color?) {
                if let color { art.fill(path, with: .color(color)) }
                art.stroke(path, with: .color(ink), style: StrokeStyle(lineWidth: 1.8, lineCap: .round, lineJoin: .round))
            }

            func oval(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat, _ color: Color) {
                shape(Path(ellipseIn: CGRect(x: x, y: y, width: w, height: h)), color)
            }

            func line(_ points: [CGPoint], fill: Color? = nil) {
                guard let start = points.first else { return }
                shape(Path { path in
                    path.move(to: start)
                    for point in points.dropFirst() { path.addLine(to: point) }
                    if fill != nil { path.closeSubpath() }
                }, fill)
            }

            func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x, y: y) }

            func eyes(_ left: CGFloat, _ right: CGFloat, _ y: CGFloat) {
                oval(left, y, 4, 5, ink)
                oval(right, y, 4, 5, ink)
            }

            switch kind {
            case .cat:
                oval(24, 45, 56, 45, ivory)
                oval(15, 31, 17, 38, ivory)
                line([p(24, 45), p(29, 18), p(45, 31), p(61, 31), p(72, 18), p(80, 47)], fill: ivory)
                oval(24, 31, 56, 38, ivory)
                eyes(39, 61, 46)
                line([p(47, 54), p(52, 57), p(57, 54)])
                line([p(33, 64), p(52, 69), p(71, 64), p(68, 72), p(52, 76), p(36, 71)], fill: red)
                oval(46, 70, 13, 13, gold)
            case .coin:
                oval(25, 9, 50, 82, gold)
                oval(30, 14, 40, 72, ivory)
                line([p(41, 29), p(59, 29)])
                line([p(50, 24), p(50, 56)])
                line([p(40, 42), p(60, 42), p(56, 54), p(44, 54), p(40, 42)])
                line([p(42, 68), p(58, 68)])
                line([p(45, 74), p(55, 74)])
            case .okame:
                oval(23, 13, 54, 73, ink)
                oval(28, 28, 44, 59, ivory)
                oval(26, 55, 16, 14, rose)
                oval(58, 55, 16, 14, rose)
                line([p(35, 48), p(39, 45), p(43, 48)])
                line([p(57, 48), p(61, 45), p(65, 48)])
                line([p(49, 50), p(46, 60), p(51, 60)])
                line([p(44, 71), p(50, 75), p(56, 71)])
            case .daruma:
                oval(17, 15, 66, 73, red)
                oval(26, 29, 48, 35, ivory)
                oval(31, 38, 14, 13, .white)
                oval(55, 38, 14, 13, .white)
                oval(36, 42, 5, 5, ink)
                oval(60, 42, 5, 5, ink)
                line([p(33, 35), p(40, 32), p(47, 35)])
                line([p(53, 35), p(60, 32), p(67, 35)])
                line([p(37, 56), p(49, 59), p(63, 56)])
                oval(45, 69, 10, 12, gold)
            case .bream:
                line([p(71, 45), p(93, 34), p(88, 51), p(94, 68), p(70, 59)], fill: rose)
                line([p(31, 36), p(46, 22), p(62, 36)], fill: rose)
                oval(8, 33, 69, 35, red)
                oval(18, 43, 10, 10, ivory)
                oval(20, 46, 4, 4, ink)
                line([p(35, 38), p(41, 51), p(35, 64)])
                line([p(47, 42), p(53, 49), p(47, 56)])
                line([p(58, 42), p(64, 49), p(58, 56)])
            case .crane:
                line([p(29, 62), p(36, 73), p(18, 88), p(13, 86)])
                line([p(25, 60), p(27, 72), p(10, 80)])
                line([p(11, 55), p(32, 51), p(53, 56), p(67, 47), p(72, 29), p(80, 21), p(88, 25), p(91, 30), p(82, 32), p(76, 52), p(66, 64), p(45, 69), p(27, 65)], fill: ivory)
                line([p(36, 56), p(16, 21), p(52, 37), p(61, 51), p(51, 62)], fill: ivory)
                line([p(20, 27), p(31, 34), p(37, 47), p(28, 42)], fill: ink)
                oval(77, 22, 8, 5, red)
                oval(83, 28, 2, 2, ink)
            case .turtle:
                oval(71, 40, 19, 16, jade)
                oval(16, 35, 17, 11, jade)
                oval(15, 58, 17, 11, jade)
                oval(61, 34, 14, 11, jade)
                oval(61, 59, 14, 11, jade)
                line([p(22, 49), p(9, 56), p(23, 56)], fill: jade)
                oval(21, 29, 55, 44, jade)
                line([p(38, 42), p(50, 35), p(63, 41), p(64, 57), p(52, 64), p(39, 58), p(38, 42)])
                oval(83, 44, 3, 3, ink)
            case .boat:
                line([p(48, 15), p(48, 67)])
                line([p(48, 17), p(77, 60), p(33, 60)], fill: ivory)
                oval(46, 41, 13, 13, gold)
                line([p(9, 58), p(28, 70), p(76, 70), p(92, 58), p(82, 82), p(26, 82)], fill: red)
                line([p(34, 76), p(72, 76)])
                line([p(15, 88), p(26, 85), p(38, 88), p(51, 85), p(63, 88), p(76, 85), p(88, 88)])
            }
        }
        .accessibilityHidden(true)
    }
}
