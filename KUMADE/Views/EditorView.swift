import SwiftUI

struct EditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var ornaments: [PlacedOrnament] = []
    @State private var selection: UUID?
    @State private var information: Ornament?
    @State private var completion: Artwork?

    var body: some View {
        GeometryReader { geometry in
            let wide = geometry.size.width >= 660
            let layout = wide ? AnyLayout(HStackLayout(spacing: 0)) : AnyLayout(VStackLayout(spacing: 0))
            layout {
                palette
                    .frame(width: wide ? geometry.size.width / 3 : nil,
                           height: wide ? nil : min(225, geometry.size.height * 0.36))
                Rectangle()
                    .fill(Workshop.gold.opacity(0.4))
                    .frame(width: wide ? 1 : nil, height: wide ? nil : 1)
                    .accessibilityHidden(true)
                VStack(spacing: 0) {
                    KumadeCanvas(ornaments: ornaments, selection: selection,
                                 select: select, move: move, drop: add, transform: transform)
                    if let selection, let item = ornaments.first(where: { $0.id == selection }) {
                        controls(for: item)
                    } else {
                        Text("飾りをドラッグして配置")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .background(Workshop.paper)
                    }
                    if let information {
                        infoPanel(information)
                    }
                }
                .background(Washi())
            }
        }
        .foregroundStyle(Workshop.ink)
        .background(Workshop.paper)
        .navigationTitle("熊手をつくる")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: { Label("戻る", systemImage: "chevron.left") }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("完成") { completion = Artwork(title: "", ornaments: ornaments) }
                    .buttonStyle(WorkshopButton())
            }
        }
        .sheet(item: $completion) { work in
            NavigationStack { ArtworkView(work: work, isNew: true) }
        }
    }

    private var palette: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible())], spacing: 10) {
                ForEach(Ornament.allCases) { kind in
                    Button {
                        information = kind
                    } label: {
                        VStack(spacing: 4) {
                            OrnamentArt(kind: kind)
                                .frame(height: 69)
                            Text(kind.name)
                                .font(.subheadline.weight(.medium))
                                .multilineTextAlignment(.center)
                        }
                        .padding(8)
                        .frame(maxWidth: .infinity, minHeight: 104)
                        .background(Workshop.paper.opacity(0.8), in: RoundedRectangle(cornerRadius: 8))
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(information == kind ? Workshop.vermilion : Workshop.gold.opacity(0.35))
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .draggable(kind.rawValue)
                    .accessibilityAddTraits(information == kind ? .isSelected : [])
                    .accessibilityHint("意味と由来、追加ボタンを表示します")
                }
            }
            .padding(14)
        }
        .background(Workshop.gold.opacity(0.10))
    }

    private func infoPanel(_ kind: Ornament) -> some View {
        ViewThatFits(in: .vertical) {
            infoContent(kind)
            ScrollView { infoContent(kind) }
        }
        .frame(maxHeight: 164)
        .background(Workshop.paper)
        .overlay(alignment: .top) { Divider().accessibilityHidden(true) }
    }

    private func infoContent(_ kind: Ornament) -> some View {
        HStack(alignment: .top, spacing: 12) {
            OrnamentArt(kind: kind).frame(width: 48, height: 48)
            VStack(alignment: .leading, spacing: 5) {
                Text(kind.name).font(Workshop.serif(.headline)).accessibilityAddTraits(.isHeader)
                Text("意味　").fontWeight(.semibold) + Text(kind.meaning)
                Text("由来　").fontWeight(.semibold) + Text(kind.origin)
                Button {
                    let offset = CGFloat(ornaments.count % 5 - 2) * 0.038
                    add(kind, CGPoint(x: 0.5 + offset, y: 0.39 + abs(offset) * 0.45))
                } label: {
                    Label("追加", systemImage: "plus")
                }
                .buttonStyle(WorkshopButton())
            }
            .font(.subheadline)
            .frame(maxWidth: .infinity, alignment: .leading)
            Button { information = nil } label: {
                Image(systemName: "xmark").frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("説明を閉じる")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private func controls(for item: PlacedOrnament) -> some View {
        ScrollView(.horizontal) {
            HStack(spacing: 4) {
                action("左へ移動", "arrow.left") { nudge(item, x: -0.025, y: 0) }
                action("右へ移動", "arrow.right") { nudge(item, x: 0.025, y: 0) }
                action("上へ移動", "arrow.up") { nudge(item, x: 0, y: -0.025) }
                action("下へ移動", "arrow.down") { nudge(item, x: 0, y: 0.025) }
                Divider().frame(height: 24)
                action("縮小", "minus.magnifyingglass") { resize(item.id, by: -0.15) }
                action("拡大", "plus.magnifyingglass") { resize(item.id, by: 0.15) }
                action("回転", "rotate.right") { change(item.id) { $0.rotation = ($0.rotation + 15).truncatingRemainder(dividingBy: 360) } }
                action("最前面へ", "square.on.square") {
                    ornaments.removeAll { $0.id == item.id }
                    ornaments.append(item)
                }
                action("削除", "trash") {
                    ornaments.removeAll { $0.id == item.id }
                    selection = nil
                }
            }
            .padding(.horizontal, 8)
        }
        .background(Workshop.paper)
        .overlay(alignment: .top) { Divider().accessibilityHidden(true) }
    }

    private func action(_ title: LocalizedStringKey, _ symbol: String, perform: @escaping () -> Void) -> some View {
        Button(action: perform) {
            Image(systemName: symbol)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(title))
    }

    private func select(_ id: UUID) { selection = id }

    private func add(_ kind: Ornament, _ point: CGPoint) {
        let item = PlacedOrnament(kind: kind, position: PlacedOrnament.bounded(point))
        ornaments.append(item)
        selection = item.id
    }

    private func move(_ id: UUID, _ point: CGPoint) {
        change(id) { $0.position = PlacedOrnament.bounded(point, scale: $0.scale) }
    }

    private func nudge(_ item: PlacedOrnament, x: CGFloat, y: CGFloat) {
        move(item.id, CGPoint(x: item.position.x + x, y: item.position.y + y))
    }

    private func resize(_ id: UUID, by amount: CGFloat) {
        guard let item = ornaments.first(where: { $0.id == id }) else { return }
        transform(id, item.scale + amount, item.rotation)
    }

    private func transform(_ id: UUID, _ scale: CGFloat, _ rotation: Double) {
        change(id) {
            $0.scale = PlacedOrnament.boundedScale(scale)
            $0.rotation = rotation.truncatingRemainder(dividingBy: 360)
            $0.position = PlacedOrnament.bounded($0.position, scale: $0.scale)
        }
    }

    private func change(_ id: UUID, _ update: (inout PlacedOrnament) -> Void) {
        guard let index = ornaments.firstIndex(where: { $0.id == id }) else { return }
        update(&ornaments[index])
    }
}
