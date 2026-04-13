import Foundation
import SwiftUI

/// JunkType: Categorizes different types of ignorable or removable system data.
/// Each type has a descriptive name, a system icon, and a thematic color.
enum JunkType: String, Identifiable, CaseIterable {
    case systemCaches = "System Caches"
    case userCaches = "User Caches"
    case systemLogs = "System Logs"
    case userLogs = "User Logs"
    case xcodeJunk = "Xcode Junk"
    case trash = "Trash"
    case mailDownloads = "Mail Downloads"
    
    var id: String { self.rawValue }
    
    /// Returns the SFSymbol name associated with the junk category.
    var iconName: String {
        switch self {
        case .systemCaches: return "cpu"
        case .userCaches: return "person.circle"
        case .systemLogs: return "doc.text"
        case .userLogs: return "doc.append"
        case .xcodeJunk: return "hammer"
        case .trash: return "trash"
        case .mailDownloads: return "envelope.open"
        }
    }
    
    /// Returns a thematic color for the progress and categorization UI.
    var themeColor: Color {
        switch self {
        case .systemCaches, .userCaches: return .blue
        case .systemLogs, .userLogs: return .orange
        case .xcodeJunk: return .purple
        case .trash: return .red
        case .mailDownloads: return .green
        }
    }
}

/// JunkItem: Represents a single file or directory identified as junk.
struct JunkItem: Identifiable {
    let id = UUID()
    
    /// The display name of the item (usually the filename).
    let name: String
    
    /// The absolute path to the item on disk.
    let path: URL
    
    /// The size of the item in bytes.
    let size: Int64
    
    /// Whether the user has selected this item for cleaning.
    var isSelected: Bool = true
}

/// JunkCategory: A group of `JunkItem`s belonging to the same `JunkType`.
struct JunkCategory: Identifiable {
    let type: JunkType
    
    /// The detailed list of items found in this category.
    var items: [JunkItem]
    
    /// UI state tracking whether the category is expanded in the results list.
    var isExpanded: Bool = false
    
    var id: String { type.id }
    
    /// Calculated total size of all items in this category.
    var totalSize: Int64 {
        items.reduce(0) { $0 + $1.size }
    }
    
    /// Calculated size of only the items currently selected by the user.
    var selectedSize: Int64 {
        items.filter { $0.isSelected }.reduce(0) { $0 + $1.size }
    }
    
    /// A user-friendly string representation of the total size (e.g., "1.2 GB").
    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file)
    }
}

/// ScanStats: Holds historical data and summaries of scanning operations.
struct ScanStats {
    var totalFound: Int64 = 0
    var totalCleaned: Int64 = 0
    var lastScanDate: Date?
}
