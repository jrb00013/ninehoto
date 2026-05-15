import SwiftUI

struct LoadingOverlayView: View {
    let message: String
    let progress: Double?
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                if let progress = progress {
                    ProgressView(value: progress)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                }
                
                Text(message)
                    .font(.headline)
                    .foregroundColor(.white)
                
                if let progress = progress {
                    Text("\(Int(progress * 100))%")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(40)
            .background(Color.secondaryBackground)
            .cornerRadius(20)
        }
        .accessibilityElement(children: .combine)
    }
}

struct ShimmerLoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ForEach(0..<5, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 200)
                    .shimmer()
            }
        }
        .padding()
    }
}

struct SkeletonCardView: View {
    var body: some View {
        VStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.3))
                .frame(height: 300)
                .shimmer()
            
            HStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 100, height: 40)
                
                Spacer()
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 100, height: 40)
            }
        }
        .padding()
    }
}

struct AnimatedCheckmark: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.keepGreen)
                .frame(width: 80, height: 80)
                .scaleEffect(isAnimating ? 1 : 0)
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isAnimating)
            
            Image(systemName: "checkmark")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.white)
                .scaleEffect(isAnimating ? 1 : 0)
                .animation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.1), value: isAnimating)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct AnimatedXMark: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.destructiveRed)
                .frame(width: 80, height: 80)
                .scaleEffect(isAnimating ? 1 : 0)
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isAnimating)
            
            Image(systemName: "xmark")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.white)
                .scaleEffect(isAnimating ? 1 : 0)
                .animation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.1), value: isAnimating)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct PulsingDot: View {
    @State private var isPulsing = false
    
    var color: Color = .accentColor
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 12, height: 12)
            .scaleEffect(isPulsing ? 1.3 : 1.0)
            .opacity(isPulsing ? 0.5 : 1.0)
            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isPulsing)
            .onAppear {
                isPulsing = true
            }
    }
}

struct WaveLoader: View {
    @State private var animated = false
    
    let bars = 5
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<bars, id: \.self) { index in
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.accentColor)
                    .frame(width: 8, height: 40)
                    .scaleEffect(y: animated ? 0.3 : 1.0, anchor: .bottom)
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.1),
                        value: animated
                    )
            }
        }
        .onAppear {
            animated = true
        }
    }
}