import SwiftUI

struct HomeView: View {
    @Environment(\.dynamicTypeSize) private var textSize

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                let sideBySide = geometry.size.width >= 680 && !textSize.isAccessibilitySize
                let layout = sideBySide ? AnyLayout(HStackLayout(spacing: 36)) : AnyLayout(VStackLayout(spacing: 30))
                layout {
                    VStack(alignment: .leading, spacing: 19) {
                        Text("KUMADE")
                            .font(.system(.largeTitle, design: .serif, weight: .semibold))
                            .tracking(4)
                            .accessibilityAddTraits(.isHeader)
                        Text("伝統に、わたしらしさを。")
                            .font(Workshop.serif(.title2))
                        Text("福をかき集めるといわれる熊手。あなたの大切なものを飾って、自分だけの一作を。")
                            .font(.body)
                            .lineSpacing(5)
                            .foregroundStyle(Workshop.ink.opacity(0.8))
                            .frame(maxWidth: 320, alignment: .leading)
                        VStack(alignment: .leading, spacing: 12) {
                            NavigationLink(value: Destination.workshop) {
                                Label("つくる", systemImage: "plus")
                            }
                            .buttonStyle(WorkshopButton())
                            NavigationLink(value: Destination.collection) {
                                Label("コレクション", systemImage: "square.grid.2x2")
                            }
                            .buttonStyle(WorkshopButton(filled: false))
                        }
                        .padding(.top, 8)
                    }
                    .frame(maxWidth: sideBySide ? 360 : .infinity, alignment: .leading)

                    KumadeCanvas(ornaments: PlacedOrnament.sample)
                        .frame(height: sideBySide ? min(540, max(350, geometry.size.height - 96)) : 320)
                        .background {
                            ZStack {
                                Rectangle().fill(Workshop.ink)
                                Washi().padding(10)
                                Rectangle()
                                    .strokeBorder(Workshop.gold.opacity(0.55), lineWidth: 1)
                                    .padding(21)
                                Rectangle()
                                    .strokeBorder(Workshop.gold.opacity(0.3), lineWidth: 1)
                                    .padding(27)
                            }
                        }
                        .accessibilityLabel("完成した熊手の見本")
                        .accessibilityElement(children: .ignore)
                }
                .padding(sideBySide ? 48 : 24)
                .frame(maxWidth: 1220, minHeight: geometry.size.height)
                .frame(maxWidth: .infinity)
            }
        }
        .foregroundStyle(Workshop.ink)
        .background {
            ZStack {
                Washi()
                VStack {
                    Rectangle().fill(Workshop.ink).frame(height: 9)
                    Spacer()
                    Rectangle().fill(Workshop.ink).frame(height: 16)
                }
            }
            .ignoresSafeArea()
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
