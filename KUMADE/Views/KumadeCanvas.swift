import SwiftUI

struct KumadeCanvas: View {
    let ornaments: [PlacedOrnament]
    var selection: UUID?
    var select: ((UUID) -> Void)?
    var move: ((UUID, CGPoint) -> Void)?
    var drop: ((Ornament, CGPoint) -> Void)?

    @GestureState private var drag: DragPreview? = nil

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
        return CGPoint(x: point.x * side, y: point.y * side)
    }

    private func decoration(_ item: PlacedOrnament, side: CGFloat) -> some View {
        let size = side * 0.185 * item.scale
        return OrnamentArt(kind: item.kind)
            .frame(width: size, height: size)
            .rotationEffect(.degrees(item.rotation))
            .frame(minWidth: select == nil ? 0 : 44, minHeight: select == nil ? 0 : 44)
            .contentShape(Rectangle())
            .background {
                if selection == item.id {
                    RoundedRectangle(cornerRadius: 9)
                        .strokeBorder(Workshop.vermilion, style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
                }
            }
    }
}
