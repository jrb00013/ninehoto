import SwiftUI

struct ComponentsShowcaseView: View {
    var body: some View {
        NavigationView {
            List {
                Section("Animations") {
                    NavigationLink("Swipe Card") { SwipeCardShowcase() }
                    NavigationLink("Animations") { AnimationShowcase() }
                }
                
                Section("Loaders") {
                    NavigationLink("Loading Overlay") { LoadingOverlayShowcase() }
                    NavigationLink("Skeleton") { SkeletonShowcase() }
                }
                
                Section("Indicators") {
                    NavigationLink("Progress") { ProgressShowcase() }
                }
                
                Section("Results") {
                    NavigationLink("Success/Error") { ResultShowcase() }
                }
            }
            .navigationTitle("Components")
        }
    }
}

struct SwipeCardShowcase: View {
    @State private var offset: CGSize = .zero
    
    var body: some View {
        VStack {
            Text("Swipe card demo")
                .font(.title2)
            
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.accentColor)
                .frame(width: 300, height: 400)
                .offset(offset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            offset = value.translation
                        }
                        .onEnded { value in
                            withAnimation(.spring()) {
                                offset = .zero
                            }
                        }
                )
        }
    }
}

struct AnimationShowcase: View {
    var body: some View {
        VStack(spacing: 30) {
            Text("Animation Demo").font(.title2)
            
            Text("Pulse").bounceOnAppear()
            Text("Fade In").fadeIn(delay: 0.2)
            Text("Slide In").slideIn(from: .leading, delay: 0.3)
            Text("Shake").shake(times: 2, duration: 0.3)
        }
        .padding()
    }
}

struct LoadingOverlayShowcase: View {
    @State private var showLoading = false
    
    var body: some View {
        VStack(spacing: 20) {
            Button("Show Loading") {
                showLoading = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showLoading = false
                }
            }
            
            WaveLoader()
            
            ShimmerLoadingView()
        }
        .overlay(showLoading ? LoadingOverlayView(message: "Loading...") : nil)
    }
}

struct SkeletonShowcase: View {
    var body: some View {
        ScrollView {
            SkeletonCardView()
            SkeletonCardView()
        }
    }
}

struct ProgressShowcase: View {
    @State private var progress: Double = 0
    
    var body: some View {
        VStack(spacing: 20) {
            ProgressView(value: progress)
                .padding()
            
            Button("Increase Progress") {
                progress = min(progress + 0.1, 1.0)
            }
            
            HStack(spacing: 10) {
                ForEach(0..<3, id: \.self) { _ in
                    PulsingDot()
                }
            }
        }
    }
}

struct ResultShowcase: View {
    var body: some View {
        VStack(spacing: 30) {
            AnimatedCheckmark()
            AnimatedXMark()
        }
    }
}