import SwiftUI
import AppKit

/// PermissionView: A user-centric guide for enabling macOS 'Full Disk Access'.
/// Provides a step-by-step walkthrough to help users navigate system settings.
struct PermissionView: View {
    @ObservedObject var engine: CleaningEngine
    
    /// Provides access to environment-based dismissal (e.g., when the user clicks 'I've granted access').
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 35) {
            // MARK: - Iconic Header
            ZStack {
                Circle()
                    .fill(BrandColors.gradientStart.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [BrandColors.gradientStart, BrandColors.gradientEnd],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            
            // MARK: - Description Section
            VStack(spacing: 12) {
                Text("Privacy & Safety")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                
                Text("To find and clean system junk, ZenClean requires 'Full Disk Access'. This ensures we can safely analyze your cache and log folders.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 20)
            }
            
            // MARK: - Instruction list
            VStack(alignment: .leading, spacing: 18) {
                PermissionStep(number: 1, text: "Click the 'Open Settings' button below.")
                PermissionStep(number: 2, text: "Unlock the pane and find 'ZenClean' in the list.")
                PermissionStep(number: 3, text: "Toggle the switch to ON and return here.")
            }
            .padding(24)
            .background(Color.black.opacity(0.2))
            .cornerRadius(16)
            
            // MARK: - Primary Action
            VStack(spacing: 16) {
                Button(action: {
                    openFullDiskAccessSettings()
                }) {
                    HStack {
                        Image(systemName: "arrow.up.right.square.fill")
                        Text("Open System Settings")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(BrandColors.gradientStart)
                    .cornerRadius(12)
                    .shadow(color: BrandColors.gradientStart.opacity(0.3), radius: 10, y: 5)
                }
                .buttonStyle(.plain)
                
                Button("I've already enabled this") {
                    engine.checkPermissions()
                    if engine.hasFullDiskAccess {
                        dismiss()
                    }
                }
                .font(.subheadline.bold())
                .foregroundColor(BrandColors.gradientEnd)
                .buttonStyle(.plain)
            }
        }
        .padding(40)
        .frame(width: 480)
        .glassCard(radius: 24)
    }
    
    /// Programmatically opens the macOS System Settings directly to the Full Disk Access pane.
    private func openFullDiskAccessSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles") {
            NSWorkspace.shared.open(url)
        }
    }
}

/// PermissionStep: A reusable row for the permission instruction list.
struct PermissionStep: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(spacing: 16) {
            Text("\(number)")
                .font(.system(.caption, design: .monospaced).bold())
                .foregroundColor(.white)
                .frame(width: 26, height: 26)
                .background(
                    Circle()
                        .fill(BrandColors.gradientStart)
                        .shadow(color: BrandColors.gradientStart.opacity(0.4), radius: 4)
                )
            
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary.opacity(0.9))
            
            Spacer()
        }
    }
}
