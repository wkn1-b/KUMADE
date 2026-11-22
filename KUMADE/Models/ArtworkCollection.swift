import Combine
import Foundation

struct Artwork: Codable, Identifiable {
    var id = UUID()
    var title: String
    var createdAt = Date()
    var ornaments: [PlacedOrnament]
}

@MainActor
final class ArtworkCollection: ObservableObject {
    @Published private(set) var works: [Artwork] = []
    @Published var error: String?
    private let url: URL

    init() {
        url = URL.applicationSupportDirectory.appending(path: "KUMADE", directoryHint: .isDirectory).appending(path: "artworks.json")
        do {
            works = try JSONDecoder().decode([Artwork].self, from: Data(contentsOf: url))
        } catch let failure as CocoaError where failure.code == .fileReadNoSuchFile {
            works = []
        } catch {
            self.error = String(localized: "コレクションを読み込めませんでした。")
        }
    }

    func save(_ work: Artwork) -> Bool {
        guard error == nil else { return false }
        var updated = works
        if let index = updated.firstIndex(where: { $0.id == work.id }) {
            updated[index] = work
        } else {
            updated.insert(work, at: 0)
        }
        do {
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try JSONEncoder().encode(updated).write(to: url, options: .atomic)
            works = updated
            return true
        } catch {
            return false
        }
    }
}
