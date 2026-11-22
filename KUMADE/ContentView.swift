import SwiftUI

struct ContentView: View {
    @StateObject private var collection = ArtworkCollection()

    var body: some View {
        NavigationStack {
            HomeView()
                .navigationDestination(for: Destination.self) { destination in
                    switch destination {
                    case .workshop:
                        EditorView()
                    case .collection:
                        CollectionView()
                    }
                }
        }
        .environmentObject(collection)
        .tint(Workshop.vermilion)
        .preferredColorScheme(.light)
    }
}

enum Destination: Hashable {
    case workshop, collection
}
