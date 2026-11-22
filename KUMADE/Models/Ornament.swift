import SwiftUI

enum Ornament: String, CaseIterable, Identifiable, Codable {
    case cat, coin, okame, daruma, bream, crane, turtle, boat

    case plum, bamboo, pine, fan, mallet, gourd

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
        case .plum: "梅の花"
        case .bamboo: "竹"
        case .pine: "松"
        case .fan: "扇"
        case .mallet: "打ち出の小槌"
        case .gourd: "ひょうたん"
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
        case .plum: "春の訪れ"
        case .bamboo: "健やかな成長"
        case .pine: "長寿"
        case .fan: "末広がりの繁栄"
        case .mallet: "福や豊かさ"
        case .gourd: "無病息災"
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
        case .plum: "早春に咲く花。松・竹とともに「松竹梅」の祝いの意匠に用いられます。"
        case .bamboo: "節を持ち、まっすぐ伸びる植物です。松竹梅や門松にも使われます。"
        case .pine: "冬も緑を保つ常緑樹です。正月の門松にも使われます。"
        case .fan: "開くと先が広がる形から、「末広」とも呼ばれます。"
        case .mallet: "大黒天が持つ小槌として知られ、昔話『一寸法師』にも登場します。"
        case .gourd: "六つのひょうたんを「六瓢（むびょう）」と読み、「無病」に掛ける意匠があります。"
        }
    }
}

struct PlacedOrnament: Identifiable, Codable {
    var id = UUID()
    let kind: Ornament
    var position: CGPoint
    var scale: CGFloat = 1
    var rotation: Double = 0

    static func boundedScale(_ value: CGFloat) -> CGFloat {
        min(1.8, max(0.55, value))
    }

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
