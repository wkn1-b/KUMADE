import SwiftUI

enum Workshop {
    static let paper = Color(red: 0.96, green: 0.93, blue: 0.89)
    static let ink = Color(red: 0.18, green: 0.14, blue: 0.11)
    static let vermilion = Color(red: 0.62, green: 0.19, blue: 0.14)
    static let gold = Color(red: 0.70, green: 0.55, blue: 0.29)

    static func serif(_ style: Font.TextStyle) -> Font {
        .system(style, design: .serif)
    }
}

struct Washi: View {
    var body: some View {
        Canvas { context, size in
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(Workshop.paper))
            var fibers = Path()
            for index in 0..<1300 {
                let x = CGFloat((index * 7919) % 1301) / 1301 * size.width
                let y = CGFloat((index * 4943) % 1303) / 1303 * size.height
                fibers.move(to: CGPoint(x: x, y: y))
                fibers.addLine(to: CGPoint(x: x + CGFloat(index % 4 + 1), y: y - 0.6))
            }
            context.stroke(fibers, with: .color(Workshop.ink.opacity(0.12)), lineWidth: 0.6)
        }
        .accessibilityHidden(true)
    }
}

struct WorkshopButton: ButtonStyle {
    var filled = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding(.horizontal, 22)
            .padding(.vertical, 12)
            .frame(minHeight: 44)
            .foregroundStyle(filled ? Color.white : Workshop.ink)
            .background(filled ? Workshop.vermilion : Workshop.paper, in: RoundedRectangle(cornerRadius: 7))
            .overlay {
                RoundedRectangle(cornerRadius: 7)
                    .strokeBorder(Workshop.gold.opacity(filled ? 0 : 0.45))
            }
            .opacity(configuration.isPressed ? 0.75 : 1)
    }
}
