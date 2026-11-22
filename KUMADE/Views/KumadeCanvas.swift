import SwiftUI

struct KumadeCanvas: View {
    let ornaments: [PlacedOrnament]
    var selection: UUID?
    var select: ((UUID) -> Void)?
    var move: ((UUID, CGPoint) -> Void)?
    var drop: ((Ornament, CGPoint) -> Void)?
    var transform: ((UUID, CGFloat, Double) -> Void)?

    @GestureState private var drag: DragPreview? = nil

    @GestureState private var adjustment: Adjustment? = nil

    private enum Handle {
        case scale, rotation

        var symbol: String {
            switch self {
            case .scale: "arrow.up.left.and.arrow.down.right"
            case .rotation: "arrow.clockwise"
            }
        }
    }

    private struct Adjustment {
        let id: UUID
        let scale: CGFloat
        let rotation: Double
    }

    private struct DragPreview {
        let id: UUID
        let offset: CGSize
    }

    var body: some View {
        GeometryReader { geometry in
            let side = min(geometry.size.width, geometry.size.height)
            ZStack {
                WoodenRake()
                ForEach(ornaments) { item in
                    if let select, let move {
                        Button { select(item.id) } label: {
                            decoration(item, side: side)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(Text(item.kind.name))
                        .accessibilityAddTraits(selection == item.id ? .isSelected : [])
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 6, coordinateSpace: .named("rake"))
                                .updating($drag) { value, state, _ in
                                    state = DragPreview(id: item.id, offset: value.translation)
                                }
                                .onChanged { _ in select(item.id) }
                                .onEnded { value in
                                    guard side > 0 else { return }
                                    move(item.id, CGPoint(x: item.position.x + value.translation.width / side,
                                                          y: item.position.y + value.translation.height / side))
                                }
                        )
                        .position(location(item, side: side))
                    } else {
                        decoration(item, side: side)
                            .position(location(item, side: side))
                    }
                }
                if let selection, let item = ornaments.first(where: { $0.id == selection }),
                   let transform, side > 0 {
                    handle(.scale, item: item, side: side, transform: transform)
                    handle(.rotation, item: item, side: side, transform: transform)
                }
            }
            .frame(width: side, height: side)
            .coordinateSpace(name: "rake")
            .contentShape(Rectangle())
            .dropDestination(for: String.self) { values, point in
                guard let drop, side > 0, let raw = values.first, let kind = Ornament(rawValue: raw) else {
                    return false
                }
                drop(kind, CGPoint(x: point.x / side, y: point.y / side))
                return true
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func location(_ item: PlacedOrnament, side: CGFloat) -> CGPoint {
        guard side > 0 else { return .zero }
        var point = item.position
        if let drag, drag.id == item.id {
            point = PlacedOrnament.bounded(
                CGPoint(x: point.x + drag.offset.width / side, y: point.y + drag.offset.height / side),
                scale: item.scale
            )
        }
        if let adjustment, adjustment.id == item.id {
            point = PlacedOrnament.bounded(point, scale: adjustment.scale)
        }
        return CGPoint(x: point.x * side, y: point.y * side)
    }

    private func decoration(_ item: PlacedOrnament, side: CGFloat) -> some View {
        let preview = adjustment.flatMap { $0.id == item.id ? $0 : nil }
        let size = side * 0.185 * (preview?.scale ?? item.scale)
        return OrnamentArt(kind: item.kind)
            .frame(width: size, height: size)
            .rotationEffect(.degrees(preview?.rotation ?? item.rotation))
            .frame(minWidth: select == nil ? 0 : 44, minHeight: select == nil ? 0 : 44)
            .contentShape(Rectangle())
            .background {
                if selection == item.id {
                    RoundedRectangle(cornerRadius: 9)
                        .strokeBorder(Workshop.vermilion, style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
                }
            }
    }

    private func handle(_ kind: Handle, item: PlacedOrnament, side: CGFloat,
                        transform: @escaping (UUID, CGFloat, Double) -> Void) -> some View {
        let anchor = location(item, side: side)
        let scale = adjustment?.id == item.id ? (adjustment?.scale ?? item.scale) : item.scale
        let extent = max(22, side * 0.185 * scale / 2)
        let position: CGPoint
        switch kind {
        case .scale:
            position = CGPoint(x: anchor.x + extent, y: anchor.y + extent)
        case .rotation:
            position = CGPoint(x: anchor.x, y: anchor.y - extent - 12)
        }

        // Keep the 44-point drag target available near the edges of the board.
        let inset = min(22, side / 2)
        let target = CGPoint(x: min(max(position.x, inset), side - inset),
                             y: min(max(position.y, inset), side - inset))
        return Image(systemName: kind.symbol)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 26, height: 26)
            .background(Workshop.vermilion, in: Circle())
            .frame(width: 44, height: 44)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 3, coordinateSpace: .named("rake"))
                    .updating($adjustment) { value, state, _ in
                        state = transformPreview(kind, item: item, side: side, value: value)
                    }
                    .onEnded { value in
                        let result = transformPreview(kind, item: item, side: side, value: value)
                        transform(item.id, result.scale, result.rotation)
                    }
            )
            .position(target)
            .accessibilityHidden(true)
    }

    private func transformPreview(_ kind: Handle, item: PlacedOrnament, side: CGFloat,
                                  value: DragGesture.Value) -> Adjustment {
        let center = CGPoint(x: item.position.x * side, y: item.position.y * side)
        let start = CGPoint(x: value.startLocation.x - center.x, y: value.startLocation.y - center.y)
        let end = CGPoint(x: value.location.x - center.x, y: value.location.y - center.y)
        switch kind {
        case .scale:
            let startDistance = hypot(Double(start.x), Double(start.y))
            let endDistance = hypot(Double(end.x), Double(end.y))
            let ratio = CGFloat(endDistance / max(1, startDistance))
            return Adjustment(id: item.id, scale: PlacedOrnament.boundedScale(item.scale * ratio),
                              rotation: item.rotation)
        case .rotation:
            let angle = atan2(Double(end.y), Double(end.x)) - atan2(Double(start.y), Double(start.x))
            return Adjustment(id: item.id, scale: item.scale, rotation: item.rotation + angle * 180 / .pi)
        }
    }
}
