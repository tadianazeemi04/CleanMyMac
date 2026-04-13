import SwiftUI

/// DashboardView: The primary command center of ZenClean.
/// Offers a visually stunning "Liquid Glass" interface for scanning and system health overview.
struct DashboardView: View {
    @ObservedObject var engine: CleaningEngine
    
    /// UI state tracking for the permission guidance overlay.
    @State private var showPermissionGuide = false
    
    /// Animation state for the pulse effect on the scan orb.
    @State private var orbPulse: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Dynamic Background
            MeshBackground()
            
            VStack(spacing: 40) {
                // MARK: - Header Section
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ZenClean Pro")
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [BrandColors.gradientStart, BrandColors.gradientEnd],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        Text("Ready to polish your Mac")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    
                    // Small info button
                    Button(action: { showPermissionGuide = true }) {
                        Image(systemName: "shield.checkered")
                            .font(.title2)
                            .foregroundStyle(engine.hasFullDiskAccess ? .green : .orange)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 40)
                
                Spacer()
                
                // MARK: - Interaction Section
                ZStack {
                    // Outer Glow Rings (Concentric Geometry)
                    Circle()
                        .stroke(BrandColors.gradientStart.opacity(0.1), lineWidth: 40)
                        .frame(width: 320, height: 320)
                    
                    Circle()
                        .stroke(BrandColors.gradientEnd.opacity(0.05), lineWidth: 20)
                        .frame(width: 380, height: 380)
                    
                    if engine.isScanning {
                        ScanningCircle(progress: engine.scanProgress)
                    } else {
                        // The Liquid Scan Orb
                        Button(action: {
                            triggerScan()
                        }) {
                            VStack(spacing: 12) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 50))
                                    .symbolRenderingMode(.hierarchical)
                                Text("CLEAN")
                                    .font(.system(size: 22, weight: .heavy))
                                    .tracking(2)
                            }
                            .frame(width: 220, height: 220)
                            .background(
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [BrandColors.gradientStart, BrandColors.gradientEnd],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                    
                                    Circle()
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                        .padding(2)
                                    
                                    // Inner soft glow
                                    Circle()
                                        .fill(RadialGradient(colors: [.white.opacity(0.2), .clear], center: .center, startRadius: 0, endRadius: 100))
                                }
                            )
                            .shadow(color: BrandColors.gradientStart.opacity(0.5), radius: 30, x: 0, y: 15)
                            .scaleEffect(orbPulse)
                        }
                        .buttonStyle(.plain)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                                orbPulse = 1.05
                            }
                        }
                    }
                }
                
                // MARK: - Stats Section
                if engine.totalFoundSize > 0 && !engine.isScanning {
                    VStack(spacing: 8) {
                        Text(ByteCountFormatter.string(fromByteCount: engine.totalFoundSize, countStyle: .file))
                            .font(.system(size: 48, weight: .black, design: .rounded))
                            .foregroundStyle(.primary)
                        
                        Text("TOTAL JUNK DETECTED")
                            .font(.caption.bold())
                            .tracking(2)
                            .foregroundStyle(.secondary)
                    }
                    .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity), removal: .opacity))
                }
                
                Spacer()
            }
            .padding(40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $showPermissionGuide) {
            PermissionView(engine: engine)
        }
        .sheet(isPresented: $engine.showSuccess) {
            SuccessView(cleanedSize: engine.lastCleanedSize) {
                engine.showSuccess = false
            }
        }
    }
    
    /// Triggers the scan sequence with a small haptic-like UI animation.
    private func triggerScan() {
        withAnimation(.spring()) {
            orbPulse = 0.9
        }
        Task {
            try? await Task.sleep(nanoseconds: 100_000_000)
            await engine.startScan()
        }
    }
}

/// ScanningCircle: An animated progress ring representing the active scan.
struct ScanningCircle: View {
    var progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.05), lineWidth: 24)
                .frame(width: 240, height: 240)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: [BrandColors.liquidStart, BrandColors.liquidEnd],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 24, lineCap: .round)
                )
                .frame(width: 240, height: 240)
                .rotationEffect(.degrees(-90))
                .shadow(color: BrandColors.liquidStart.opacity(0.3), radius: 10)
            
            VStack(spacing: 8) {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 44, weight: .black, design: .rounded))
                Text("ANALYZING...")
                    .font(.caption.bold())
                    .tracking(2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
