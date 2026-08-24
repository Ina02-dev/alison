import SwiftUI

@main
struct AlisonApp: App {
    var body: some Scene {
        WindowGroup {
            CatalogView()
                .preferredColorScheme(.dark)
        }
    }
}
