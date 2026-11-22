import SwiftUI

struct ArtworkView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var collection: ArtworkCollection
    @State private var title: String
    @State private var saved = false
    @State private var saveFailed = false
    let work: Artwork
    let isNew: Bool

    init(work: Artwork, isNew: Bool = false) {
        self.work = work
        self.isNew = isNew
        _title = State(initialValue: work.title)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                KumadeCanvas(ornaments: work.ornaments)
                    .frame(height: 360)
                    .background(Washi())
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("完成した熊手")

                if isNew {
                    TextField("作品タイトル（任意）", text: $title)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: title) { _, value in
                            if value.count > 40 { title = String(value.prefix(40)) }
                        }
                    Button(saved ? "保存済み" : "コレクションに保存") {
                        var entry = work
                        entry.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
                        saved = collection.save(entry)
                        saveFailed = !saved
                    }
                    .buttonStyle(WorkshopButton())
                    .disabled(saved)
                    .onChange(of: title) { _, _ in saved = false }
                } else {
                    if work.title.isEmpty {
                        Text("無題の熊手").font(Workshop.serif(.title2))
                    } else {
                        Text(work.title).font(Workshop.serif(.title2))
                    }
                    Text(work.createdAt, format: .dateTime.year().month().day())
                        .font(.subheadline)
                }
            }
            .padding(24)
            .frame(maxWidth: 540)
            .frame(maxWidth: .infinity)
        }
        .background(Washi().ignoresSafeArea())
        .foregroundStyle(Workshop.ink)
        .navigationTitle(isNew ? "完成した熊手" : "作品")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isNew {
                ToolbarItem(placement: .topBarLeading) {
                    Button("編集に戻る") { dismiss() }
                }
            }
        }
        .alert("作品を保存できませんでした", isPresented: $saveFailed) {
            Button("閉じる", role: .cancel) {}
        }
    }
}

struct CollectionView: View {
    @EnvironmentObject private var collection: ArtworkCollection

    var body: some View {
        Group {
            if let error = collection.error {
                ContentUnavailableView {
                    Label("コレクション", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(error)
                }
            } else if collection.works.isEmpty {
                ContentUnavailableView("作品がありません", systemImage: "square.grid.2x2",
                                       description: Text("完成した熊手を保存すると、ここに並びます。"))
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 200), spacing: 16)], spacing: 16) {
                        ForEach(collection.works) { work in
                            NavigationLink {
                                ArtworkView(work: work)
                            } label: {
                                VStack(alignment: .leading, spacing: 8) {
                                    KumadeCanvas(ornaments: work.ornaments)
                                        .frame(height: 175)
                                        .accessibilityHidden(true)
                                    if work.title.isEmpty {
                                        Text("無題の熊手").font(.headline)
                                    } else {
                                        Text(work.title).font(.headline)
                                    }
                                    Text(work.createdAt, format: .dateTime.year().month().day())
                                        .font(.subheadline)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(14)
                                .background(Workshop.paper, in: RoundedRectangle(cornerRadius: 8))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 8)
                                        .strokeBorder(Workshop.gold.opacity(0.4))
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(20)
                }
            }
        }
        .foregroundStyle(Workshop.ink)
        .background(Washi().ignoresSafeArea())
        .navigationTitle("コレクション")
        .navigationBarTitleDisplayMode(.inline)
    }
}
