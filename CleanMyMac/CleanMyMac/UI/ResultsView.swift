import SwiftUI

/// ResultsView: A detailed breakdown of all discoverable junk items.
/// Allows users to review individual files and selectively clean categories.
struct ResultsView: View {
    @ObservedObject var engine: CleaningEngine
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header Section
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Scan Analysis")
                        .font(.title2.bold())
                    Text("Review and select items for removal.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                
                // Total Size Badge
                HStack(spacing: 8) {
                    Image(systemName: "externaldrive.fill")
                    Text(ByteCountFormatter.string(fromByteCount: engine.totalFoundSize, countStyle: .file))
                }
                .font(.headline)
                .foregroundStyle(BrandColors.gradientStart)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .glassCard(radius: 10)
            }
            .padding(24)
            .background(VisualEffectView(material: .headerView, blendingMode: .withinWindow))
            
            // MARK: - List Section
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(engine.foundJunk) { category in
                        CategoryRow(engine: engine, category: category)
                    }
                }
                .padding(24)
            }
            .background(BrandColors.primaryBackground.opacity(0.3))
            
            // MARK: - Footer Section
            VStack {
                Divider()
                HStack(spacing: 20) {
                    // Selection Summary
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Selected to Trash:")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                        Text(ByteCountFormatter.string(fromByteCount: totalSelectedSize, countStyle: .file))
                            .font(.title3.bold())
                            .foregroundStyle(.primary)
                    }
                    
                    Spacer()
                    
                    // Clean Action Button
                    Button(action: {
                        Task { await engine.cleanSelected() }
                    }) {
                        HStack(spacing: 12) {
                            if engine.isCleaning {
                                ProgressView()
                                    .controlSize(.small)
                            } else {
                                Image(systemName: "sparkles")
                            }
                            Text(engine.isCleaning ? "Cleaning..." : "Clean Now")
                                .font(.headline)
                        }
                        .frame(width: 160)
                        .padding(.vertical, 14)
                        .background(
                            ZStack {
                                if totalSelectedSize > 0 {
                                    LinearGradient(colors: [BrandColors.gradientStart, BrandColors.gradientEnd], startPoint: .leading, endPoint: .trailing)
                                } else {
                                    Color.gray.opacity(0.3)
                                }
                            }
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: BrandColors.gradientStart.opacity(totalSelectedSize > 0 ? 0.3 : 0), radius: 10, y: 5)
                    }
                    .buttonStyle(.plain)
                    .disabled(engine.isCleaning || totalSelectedSize == 0)
                }
                .padding(24)
            }
            .background(VisualEffectView(material: .headerView, blendingMode: .withinWindow))
        }
    }
    
    /// Calculates the sum of all items the user has currently marked for deletion.
    var totalSelectedSize: Int64 {
        engine.foundJunk.reduce(0) { $0 + $1.selectedSize }
    }
}

/// CategoryRow: A collapsible card representing a group of junk files.
struct CategoryRow: View {
    @ObservedObject var engine: CleaningEngine
    let category: JunkCategory
    
    /// Controls the expansion state of the item list.
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Card Header
            HStack(spacing: 15) {
                // Selection Checkbox
                Toggle("", isOn: Binding(
                    get: { category.items.allSatisfy { $0.isSelected } },
                    set: { _ in engine.toggleCategory(category) }
                ))
                .toggleStyle(.checkbox)
                .labelsHidden()
                
                // Category Icon with thematic glow
                ZStack {
                    Circle()
                        .fill(category.type.themeColor.opacity(0.1))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: category.type.iconName)
                        .font(.title3)
                        .foregroundStyle(category.type.themeColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(category.type.rawValue)
                        .font(.headline)
                    Text(category.formattedSize)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.body.bold())
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    .foregroundStyle(.tertiary)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            isExpanded.toggle()
                        }
                    }
            }
            .padding(16)
            .contentShape(Rectangle())
            
            // Expanded Content (Items List)
            if isExpanded {
                VStack(spacing: 1) {
                    Divider().padding(.horizontal)
                    
                    ForEach(category.items) { item in
                        HStack(spacing: 12) {
                            // Individual Checkbox
                            Toggle("", isOn: Binding(
                                get: { item.isSelected },
                                set: { _ in engine.toggleItem(item, in: category) }
                            ))
                            .toggleStyle(.checkbox)
                            .labelsHidden()
                            
                            Text(item.name)
                                .font(.subheadline)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Text(ByteCountFormatter.string(fromByteCount: item.size, countStyle: .file))
                                .font(.caption.monospaced())
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                    }
                }
                .background(Color.black.opacity(0.05))
            }
        }
        .glassCard(radius: 12)
    }
}
