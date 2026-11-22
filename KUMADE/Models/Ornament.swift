import SwiftUI

enum Ornament: String, CaseIterable, Identifiable, Codable {
    case cat, coin, okame, daruma, bream, crane, turtle, boat

    var id: String { rawValue }

    var name: LocalizedStringKey {
        switch self {
        case .cat: "招き猫"
        case .coin: "小判"
        case .okame: "おかめ"
        case .daruma: "だるま"
        case .bream: "鯛"
        case .crane: "鶴"
        case .turtle: "亀"
        case .boat: "宝船"
        }
    }

    var meaning: LocalizedStringKey {
        switch self {
        case .cat: "福や人を招く"
        case .coin: "財や商いの繁栄"
        case .okame: "福や家庭の円満"
        case .daruma: "願いの成就"
        case .bream: "祝いごと"
        case .crane, .turtle: "長寿"
        case .boat: "福や豊かさ"
        }
    }

    var origin: LocalizedStringKey {
        switch self {
        case .cat: "前足を上げ、招く姿の置物です。発祥には諸説あります。"
        case .coin: "江戸時代に流通した金貨をかたどっています。"
        case .okame: "ふっくらした頬と穏やかな表情で親しまれている面です。"
        case .daruma: "禅宗の達磨をかたどり、願いを託す縁起物として親しまれています。"
        case .bream: "「めでたい」に通じる語呂合わせでも、祝いの席に親しまれています。"
        case .crane: "「鶴は千年、亀は万年」ということわざにも登場します。"
        case .turtle: "鶴とともに、長寿を願う意匠に用いられます。"
        case .boat: "七福神や宝を載せた船の絵は、正月の縁起物として親しまれています。"
        }
    }
}

struct PlacedOrnament: Identifiable, Codable {
    var id = UUID()
    let kind: Ornament
    var position: CGPoint
    var scale: CGFloat = 1
    var rotation: Double = 0

    static func bounded(_ point: CGPoint, scale: CGFloat = 1) -> CGPoint {
        // Keep larger pieces clear of the board edge while allowing overlap over the rake.
        let margin = max(0.10, scale * 0.12)
        return CGPoint(x: min(max(point.x, margin), 1 - margin),
                       y: min(max(point.y, margin), 0.81))
    }

    static let sample: [Self] = [
        .init(kind: .crane, position: CGPoint(x: 0.36, y: 0.27), rotation: -15),
        .init(kind: .coin, position: CGPoint(x: 0.66, y: 0.28), rotation: 15),
        .init(kind: .bream, position: CGPoint(x: 0.32, y: 0.44), rotation: -12),
        .init(kind: .daruma, position: CGPoint(x: 0.68, y: 0.43), rotation: 10),
        .init(kind: .cat, position: CGPoint(x: 0.5, y: 0.36), scale: 1.5),
        .init(kind: .boat, position: CGPoint(x: 0.5, y: 0.54), scale: 1.2)
    ]
}
