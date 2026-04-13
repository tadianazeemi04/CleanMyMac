import SwiftUI

/// SuccessView: A complimentary screen that celebrates the completion of a cleaning task.
/// Displays the amount of space saved and provides a positive closure to the user journey.
struct SuccessView: View {
    /// The total byte count of the items that were successfully moved to the Trash.
    let cleanedSize: Int64
    
    /// Closure to be executed when the user dismisses the success screen.
    var onDone: () -> Void
    
    /// State to trigger a subtle entrance animation for the seal icon.
    @State private var showSeal = false
    
    var body: some View {
        ZStack {
            // Elegant Background
            MeshBackground()
            
            VStack(spacing: 45) {
                // MARK: - Animated Icon
                ZStack {
                    // Soft background glow
                    Circle()
                        .fill(BrandColors.liquidStart.opacity(0.15))
                        .frame(width: 240, height: 240)
                        .blur(radius: 20)
                    
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 100))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [BrandColors.liquidStart, BrandColors.liquidEnd],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .scaleEffect(showSeal ? 1.0 : 0.5)
                        .opacity(showSeal ? 1.0 : 0)
                        .rotationEffect(.degrees(showSeal ? 0 : -45))
                }
                
                // MARK: - Achievement Text
                VStack(spacing: 15) {
                    Text("Clean & Pristine")
                        .font(.system(size: 38, weight: .black, design: .rounded))
                    
                    VStack(spacing: 4) {
                        Text("Successfully moved")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        Text(ByteCountFormatter.string(fromByteCount: cleanedSize, countStyle: .file))
                            .font(.system(size: 52, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [BrandColors.gradientStart, BrandColors.gradientEnd],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("to the system Trash.")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // MARK: - Dismissal
                Button(action: onDone) {
                    Text("Return to Dashboard")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 240)
                        .padding(.vertical, 18)
                        .background(
                            Capsule()
                                .fill(BrandColors.gradientStart)
                                .shadow(color: BrandColors.gradientStart.opacity(0.4), radius: 15, y: 8)
                        )
                }
                .buttonStyle(.plain)
                .padding(.top, 20)
            }
            .padding(40)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0)) {
                showSeal = true
            }
        }
    }
}
