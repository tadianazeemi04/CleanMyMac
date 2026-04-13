import SwiftUI

/// CleanMyMacApp: The main entry point for the ZenClean application.
/// Configures the primary window scene and initializes the root `ContentView`.
@main
struct CleanMyMacApp: App {
    var body: some Scene {
        WindowGroup {
            // Initiate the application with the root navigational view.
            ContentView()
        }
        // Applying a standard window title and minimum size.
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}
