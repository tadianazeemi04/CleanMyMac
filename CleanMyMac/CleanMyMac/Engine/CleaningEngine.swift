import Foundation
import SwiftUI
import Combine

/// CleaningEngine: The central processing unit of ZenClean.
/// Responsible for scanning the filesystem, calculating junk sizes, and performing safe deletions.
/// This class is marked with `@MainActor` to ensure all `@Published` properties are updated on the main thread.
@MainActor
class CleaningEngine: ObservableObject {
    /// The collection of junk found during the last scan, grouped by category.
    @Published var foundJunk: [JunkCategory] = []
    
    /// Indicates whether a scanning operation is currently in progress.
    /// The collection of large files (>200MB) found in the user's home directory.
    @Published var largeFiles: [JunkItem] = []
    
    @Published var isScanning = false
    
    /// A value between 0.0 and 1.0 representing the progress of the current scan.
    @Published var scanProgress: Double = 0
    
    /// The total cumulative size of all junk found in the current session.
    @Published var totalFoundSize: Int64 = 0
    
    /// Indicates whether a cleaning operation is currently in progress.
    @Published var isCleaning = false
    
    /// Heuristic state representing whether the app has the necessary Full Disk Access.
    @Published var hasFullDiskAccess = true
    
    /// Controlled state to trigger the 'Success' celebration UI.
    @Published var showSuccess = false
    
    /// The amount of space cleared in the most recent cleaning operation.
    @Published var lastCleanedSize: Int64 = 0
    
    private let fileManager = FileManager.default
    
    init() {
        checkPermissions()
    }
    
    /// Performs a heuristic check to determine if the app has Full Disk Access.
    /// It attempts to read a protected directory (`~/Library/Safari`) to verify access.
    func checkPermissions() {
        let safariPath = fileManager.homeDirectoryForCurrentUser.appendingPathComponent("Library/Safari")
        do {
            // If this succeeds, we likely have Full Disk Access.
            _ = try fileManager.contentsOfDirectory(at: safariPath, includingPropertiesForKeys: nil)
            hasFullDiskAccess = true
        } catch {
            // Access denied usually means FDA is not granted.
            hasFullDiskAccess = false
        }
    }
    
    /// Performs a comprehensive scan for files larger than 200MB in common user directories.
    /// Excludes system Library folders to ensure privacy and safety.
    func startLargeFilesScan() async {
        self.isScanning = true
        self.largeFiles = []
        self.scanProgress = 0
        
        let targetFolders = [
            fileManager.homeDirectoryForCurrentUser.appendingPathComponent("Downloads"),
            fileManager.homeDirectoryForCurrentUser.appendingPathComponent("Documents"),
            fileManager.homeDirectoryForCurrentUser.appendingPathComponent("Desktop"),
            fileManager.homeDirectoryForCurrentUser.appendingPathComponent("Movies"),
            fileManager.homeDirectoryForCurrentUser.appendingPathComponent("Music")
        ]
        
        var discoveredFiles: [JunkItem] = []
        let minSize: Int64 = 200 * 1024 * 1024 // 200 MB
        
        for (index, folder) in targetFolders.enumerated() {
            // High-performance recursive enumeration
            let keys: [URLResourceKey] = [.fileSizeKey, .isDirectoryKey]
            let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles, .skipsPackageDescendants]
            
            if let enumerator = fileManager.enumerator(at: folder, includingPropertiesForKeys: keys, options: options) {
                for case let fileURL as URL in enumerator {
                    guard let resourceValues = try? fileURL.resourceValues(forKeys: Set(keys)),
                          resourceValues.isDirectory == false,
                          let size = resourceValues.fileSize,
                          size >= minSize else { continue }
                    
                    let item = JunkItem(name: fileURL.lastPathComponent, path: fileURL, size: Int64(size))
                    discoveredFiles.append(item)
                    
                    // Frequent UI updates for the "Large Files" list
                    self.largeFiles = discoveredFiles.sorted(by: { $0.size > $1.size })
                }
            }
            
            self.scanProgress = Double(index + 1) / Double(targetFolders.count)
        }
        
        self.isScanning = false
    }
    
    /// Initiates a comprehensive scan of all predefined junk locations.
    /// Updates the `foundJunk` and `totalFoundSize` properties as it progresses.
    func startScan() async {
        checkPermissions()
        
        // Reset state for new scan
        self.isScanning = true
        self.foundJunk = []
        self.totalFoundSize = 0
        self.scanProgress = 0
        
        var categories: [JunkCategory] = []
        let junkTypes = JunkType.allCases
        
        for (index, type) in junkTypes.enumerated() {
            let category = await scanCategory(type)
            categories.append(category)
            
            // Incremental UI updates for a "live" feel
            let progress = Double(index + 1) / Double(junkTypes.count)
            self.foundJunk = categories
            self.totalFoundSize = categories.reduce(0) { $0 + $1.totalSize }
            self.scanProgress = progress
        }
        
        self.isScanning = false
    }
    
    /// Scans a specific category of junk by traversing its associated system paths.
    /// - Parameter type: The `JunkType` to target.
    /// - Returns: A `JunkCategory` containing all discovered items.
    private func scanCategory(_ type: JunkType) async -> JunkCategory {
        let paths = getPaths(for: type)
        var items: [JunkItem] = []
        
        for path in paths {
            if let folderItems = scanDirectory(at: path) {
                items.append(contentsOf: folderItems)
            }
        }
        
        return JunkCategory(type: type, items: items)
    }
    
    /// Defines the filesystem paths associated with each junk category.
    /// - Parameter type: The category type.
    /// - Returns: An array of URLs to scan.
    private func getPaths(for type: JunkType) -> [URL] {
        let home = fileManager.homeDirectoryForCurrentUser
        
        switch type {
        case .systemCaches:
            return [URL(fileURLWithPath: "/Library/Caches")]
        case .userCaches:
            return [home.appendingPathComponent("Library/Caches")]
        case .systemLogs:
            return [URL(fileURLWithPath: "/Library/Logs")]
        case .userLogs:
            return [home.appendingPathComponent("Library/Logs")]
        case .xcodeJunk:
            return [home.appendingPathComponent("Library/Developer/Xcode/DerivedData")]
        case .trash:
            return [home.appendingPathComponent(".Trash")]
        case .mailDownloads:
            return [home.appendingPathComponent("Library/Containers/com.apple.mail/Data/Library/Mail Downloads")]
        }
    }
    
    /// Shallow scans a directory to find potential junk items.
    /// - Parameter url: The directory to scan.
    /// - Returns: An optional array of `JunkItem`s.
    private func scanDirectory(at url: URL) -> [JunkItem]? {
        guard let contents = try? fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: [URLResourceKey.fileSizeKey, URLResourceKey.isDirectoryKey], options: .skipsHiddenFiles) else {
            return nil
        }
        
        return contents.compactMap { itemUrl -> JunkItem? in
            let resourceValues = try? itemUrl.resourceValues(forKeys: [URLResourceKey.fileSizeKey, URLResourceKey.isDirectoryKey])
            let size = Int64(resourceValues?.fileSize ?? 0)
            
            // If it's a directory, calculate the recursive size of its contents.
            var totalSize = size
            if resourceValues?.isDirectory == true {
                totalSize = calculateFolderSize(at: itemUrl)
            }
            
            if totalSize > 64 * 1024 { // Filter for items > 64KB to ignore noise
                return JunkItem(name: itemUrl.lastPathComponent, path: itemUrl, size: totalSize)
            }
            return nil
        }
    }
    
    /// Recursively calculates the size of a folder and its children.
    /// - Parameter url: The target directory.
    /// - Returns: Total size in bytes.
    private func calculateFolderSize(at url: URL) -> Int64 {
        var total: Int64 = 0
        if let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: [URLResourceKey.fileSizeKey], options: .skipsHiddenFiles) {
            for case let fileURL as URL in enumerator {
                if let resourceValues = try? fileURL.resourceValues(forKeys: [URLResourceKey.fileSizeKey]) {
                    total += Int64(resourceValues.fileSize ?? 0)
                }
            }
        }
        return total
    }
    
    /// Toggles the selection status of all items within a specific category.
    /// - Parameter category: The category to toggle.
    func toggleCategory(_ category: JunkCategory) {
        if let index = foundJunk.firstIndex(where: { $0.id == category.id }) {
            let allSelected = foundJunk[index].items.allSatisfy { $0.isSelected }
            for i in foundJunk[index].items.indices {
                foundJunk[index].items[i].isSelected = !allSelected
            }
        }
    }
    
    /// Toggles the selection status of a single junk item.
    /// - Parameters:
    ///   - item: The item to toggle.
    ///   - category: The parent category of the item.
    func toggleItem(_ item: JunkItem, in category: JunkCategory) {
        if let catIndex = foundJunk.firstIndex(where: { $0.id == category.id }),
           let itemIndex = foundJunk[catIndex].items.firstIndex(where: { $0.id == item.id }) {
            foundJunk[catIndex].items[itemIndex].isSelected.toggle()
        }
    }
    
    /// Toggles the selection status of a single large file.
    func toggleLargeFile(_ file: JunkItem) {
        if let index = largeFiles.firstIndex(where: { $0.id == file.id }) {
            largeFiles[index].isSelected.toggle()
        }
    }
    
    /// Trashes the selected large files.
    func cleanSelectedLargeFiles() async {
        let selectedSize = largeFiles.filter { $0.isSelected }.reduce(0) { $0 + $1.size }
        self.isCleaning = true
        
        for file in largeFiles where file.isSelected {
            do {
                try fileManager.trashItem(at: file.path, resultingItemURL: nil)
            } catch {
                print("Failed to trash large file: \(error)")
            }
        }
        
        self.lastCleanedSize = selectedSize
        await startLargeFilesScan() // Refresh
        
        self.isCleaning = false
        self.showSuccess = true
    }
    
    /// Trashes the selected items across all categories.
    /// Does not permanently delete; items are moved to the system Trash for safety.
    func cleanSelected() async {
        let selectedSize = foundJunk.reduce(0) { $0 + $1.selectedSize }
        self.isCleaning = true
        
        for category in foundJunk {
            for item in category.items where item.isSelected {
                do {
                    // Safe move to trash instead of permanent removal.
                    try fileManager.trashItem(at: item.path, resultingItemURL: nil)
                } catch {
                    print("Failed to trash item: \(error)")
                }
            }
        }
        
        self.lastCleanedSize = selectedSize
        await startScan() // Refresh found junk after cleaning
        
        self.isCleaning = false
        self.showSuccess = true
    }
}
