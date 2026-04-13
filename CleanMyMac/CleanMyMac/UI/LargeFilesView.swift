import SwiftUI

/// LargeFilesView: A dedicated surface for discovering and managing space-hogging files.
/// Identifies data larger than 200MB and allows for selective trashing.
struct LargeFilesView: View {
    /// The shared engine responsible for scanning and cleaning logic.
    @ObservedObject var engine: CleaningEngine
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Large Files Finder")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                    Text("Identify files larger than 200MB across your home directory.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                
                // Scan Trigger
                Button(action: {
                    Task { await engine.startLargeFilesScan() }
                }) {
                    HStack {
                        if engine.isScanning {
                            ProgressView().controlSize(.small).brightness(2)
                        } else {
                            Image(systemName: "magnifyingglass")
                        }
                        Text(engine.isScanning ? "Scanning..." : "Search Home")
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(BrandColors.gradientStart)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)
                .disabled(engine.isScanning)
            }
            .padding(30)
            .background(MeshBackground().opacity(0.3))
            
            // MARK: - List Content
            if engine.largeFiles.isEmpty && !engine.isScanning {
                EmptyLargeFilesView()
            } else {
                List {
                    ForEach(engine.largeFiles) { file in
                        LargeFileRow(engine: engine, file: file)
                            .listRowInsets(EdgeInsets(top: 8, leading: 24, bottom: 8, trailing: 24))
                            .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            
            // MARK: - Footer (Selective Cleaning)
            if !engine.largeFiles.isEmpty {
                VStack {
                    Divider()
                    HStack(spacing: 24) {
                        // Total Selection Count & Size
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Total Selection:")
                                .font(.caption.bold())
                                .foregroundStyle(.secondary)
                            Text(ByteCountFormatter.string(fromByteCount: totalSelectedSize, countStyle: .file))
                                .font(.title3.bold())
                                .foregroundStyle(BrandColors.gradientStart)
                        }
                        
                        Spacer()
                        
                        // Action Button
                        Button(action: {
                            Task { await engine.cleanSelectedLargeFiles() }
                        }) {
                            HStack(spacing: 12) {
                                if engine.isCleaning {
                                    ProgressView().controlSize(.small)
                                } else {
                                    Image(systemName: "trash.fill")
                                }
                                Text(engine.isCleaning ? "Trashing..." : "Move to Trash")
                                    .font(.headline)
                            }
                            .frame(width: 180)
                            .padding(.vertical, 14)
                            .background(
                                ZStack {
                                    if totalSelectedSize > 0 {
                                        Color.red
                                    } else {
                                        Color.gray.opacity(0.3)
                                    }
                                }
                            )
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: .red.opacity(totalSelectedSize > 0 ? 0.3 : 0), radius: 10, y: 5)
                        }
                        .buttonStyle(.plain)
                        .disabled(engine.isCleaning || totalSelectedSize == 0)
                    }
                    .padding(24)
                }
                .background(VisualEffectView(material: .headerView, blendingMode: .withinWindow))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BrandColors.primaryBackground)
    }
    
    /// Sum of all large files marked for removal.
    private var totalSelectedSize: Int64 {
        engine.largeFiles.filter { $0.isSelected }.reduce(0) { $0 + $1.size }
    }
}

/// LargeFileRow: A visually dense row representing a space-hogging file.
struct LargeFileRow: View {
    @ObservedObject var engine: CleaningEngine
    let file: JunkItem
    
    var body: some View {
        HStack(spacing: 16) {
            // Selection Checkbox
            Toggle("", isOn: Binding(
                get: { file.isSelected },
                set: { _ in engine.toggleLargeFile(file) }
            ))
            .toggleStyle(.checkbox)
            .labelsHidden()
            
            // File Type Icon
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(BrandColors.gradientStart.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: fileIcon(for: file.name))
                    .font(.title2)
                    .foregroundStyle(BrandColors.gradientStart)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(file.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(file.path.path)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            
            Spacer()
            
            // File Size
            Text(ByteCountFormatter.string(fromByteCount: file.size, countStyle: .file))
                .font(.system(.body, design: .monospaced).bold())
        }
        .padding(12)
        .glassCard(radius: 12)
    }
    
    private func fileIcon(for name: String) -> String {
        let ext = name.lowercased()
        if ext.hasSuffix(".mp4") || ext.hasSuffix(".mov") || ext.hasSuffix(".mkv") { return "film" }
        if ext.hasSuffix(".zip") || ext.hasSuffix(".dmg") || ext.hasSuffix(".iso") { return "archivebox" }
        if ext.hasSuffix(".mp3") || ext.hasSuffix(".wav") { return "music.note" }
        if ext.hasSuffix(".pdf") { return "doc.richtext" }
        return "doc.fill"
    }
}

/// EmptyLargeFilesView: Displayed when no massive files are found or before a scan.
struct EmptyLargeFilesView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles.rectangle.stack")
                .font(.system(size: 60))
                .foregroundStyle(.tertiary)
            
            Text("No massive files detected yet")
                .font(.title3.bold())
            
            Text("Click 'Search Home' to scan your Downloads, Documents, and Movies for files larger than 200MB.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 50)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
