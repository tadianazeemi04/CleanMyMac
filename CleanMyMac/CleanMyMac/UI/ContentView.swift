import SwiftUI

/// ContentView: The root navigational component of ZenClean Pro.
/// Implements a `NavigationSplitView` with a premium sidebar and fluid transitions between features.
struct ContentView: View {
    /// The shared `CleaningEngine` instance used throughout the app life cycle.
    @StateObject private var engine = CleaningEngine()
    
    /// The currently selected feature tab in the sidebar.
    @State private var selectedTab: Tab? = .dashboard
    
    /// Tab: Defines the primary navigation sections of the application.
    enum Tab: String, CaseIterable {
        case dashboard = "Dashboard"
        case systemJunk = "System Junk"
        case largeFiles = "Large Files"
        case extensions = "Extensions"
        
        /// SFSymbol icon name for each tab.
        var icon: String {
            switch self {
            case .dashboard: return "house.fill"
            case .systemJunk: return "cpu.fill"
            case .largeFiles: return "doc.arrow.up.fill"
            case .extensions: return "puzzlepiece.fill"
            }
        }
    }
    
    var body: some View {
        NavigationSplitView {
            // MARK: - Sidebar
            List(Tab.allCases, id: \.self, selection: $selectedTab) { tab in
                NavigationLink(value: tab) {
                    HStack {
                        Image(systemName: tab.icon)
                            .foregroundStyle(selectedTab == tab ? BrandColors.gradientStart : .secondary)
                            .frame(width: 24)
                        
                        Text(tab.rawValue)
                            .font(.headline)
                    }
                    .padding(.vertical, 4)
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("ZenClean Pro")
            .background(VisualEffectView(material: .sidebar, blendingMode: .withinWindow))
        } detail: {
            // MARK: - Detail Content
            Group {
                switch selectedTab {
                case .dashboard:
                    DashboardView(engine: engine)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                case .systemJunk:
                    ResultsView(engine: engine)
                        .transition(.move(edge: .trailing))
                case .largeFiles:
                    LargeFilesView(engine: engine)
                        .transition(.move(edge: .bottom))
                default:
                    ComingSoonView()
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedTab)
        }
        .frame(minWidth: 1000, minHeight: 650)
    }
}

/// ComingSoonView: A placeholder for features under development.
struct ComingSoonView: View {
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "timer")
                    .font(.system(size: 60))
                    .foregroundStyle(.tertiary)
            }
            
            VStack(spacing: 8) {
                Text("Feature Coming Soon")
                    .font(.title2.bold())
                
                Text("We are working hard to bring you more pro-cleaning features.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BrandColors.primaryBackground)
    }
}

#Preview {
    ContentView()
}
