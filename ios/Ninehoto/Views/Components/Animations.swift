import SwiftUI

struct SwipeAnimationModifier: ViewModifier {
    let direction: SwipeDirection
    let progress: Double
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(direction == .left ? -progress * 30 : progress * 30))
            .offset(x: direction == .left ? -progress * 100 : progress * 100)
            .opacity(1 - progress * 0.5)
    }
}

extension View {
    func swipeAnimation(direction: SwipeDirection, progress: Double) -> some View {
        modifier(SwipeAnimationModifier(direction: direction, progress: progress))
    }
}

struct CardTransitionModifier: ViewModifier {
    let isActive: Bool
    let direction: SwipeDirection
    
    @State private var offset: CGSize = .zero
    
    func body(content: Content) -> some View {
        content
            .offset(offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        offset = value.translation
                    }
                    .onEnded { value in
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            offset = .zero
                        }
                    }
            )
    }
}

struct ScaleOnPressModifier: ViewModifier {
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
            .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
                isPressed = pressing
            }, perform: {})
    }
}

extension View {
    func scaleOnPress() -> some View {
        modifier(ScaleOnPressModifier())
    }
}

struct PulseModifier: ViewModifier {
    @State private var isPulsing = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: isPulsing)
            .onAppear { isPulsing = true }
            .onDisappear { isPulsing = false }
    }
}

extension View {
    func pulse() -> some View {
        modifier(PulseModifier())
    }
}

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .clear,
                            .white.opacity(0.3),
                            .clear
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 2)
                    .offset(x: -geometry.size.width + (geometry.size.width * 2 * phase))
                }
            )
            .mask(content)
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

struct ShakeModifier: ViewModifier {
    @State private var shakeOffset: CGFloat = 0
    
    let shakes: Int
    let duration: Double
    
    func body(content: Content) -> some View {
        content
            .offset(x: shakeOffset)
            .onAppear {
                withAnimation(.linear(duration: duration).repeatCount(shakes * 2, autoreverses: true)) {
                    shakeOffset = 10
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    shakeOffset = 0
                }
            }
    }
}

extension View {
    func shake(times: Int = 3, duration: Double = 0.5) -> some View {
        modifier(ShakeModifier(shakes: times, duration: duration))
    }
}

struct FadeInModifier: ViewModifier {
    @State private var isVisible = false
    
    let delay: Double
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                withAnimation(.easeIn(duration: 0.3).delay(delay)) {
                    isVisible = true
                }
            }
    }
}

extension View {
    func fadeIn(delay: Double = 0) -> some View {
        modifier(FadeInModifier(delay: delay))
    }
}

struct SlideInModifier: ViewModifier {
    @State private var isVisible = false
    
    let edge: Edge
    let delay: Double
    
    func body(content: Content) -> some View {
        content
            .offset(x: isVisible ? 0 : (edge == .leading ? -50 : 50))
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(delay)) {
                    isVisible = true
                }
            }
    }
}

extension View {
    func slideIn(from edge: Edge, delay: Double = 0) -> some View {
        modifier(SlideInModifier(edge: edge, delay: delay))
    }
}

struct BounceModifier: ViewModifier {
    @State private var bounce = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(bounce ? 1.1 : 1.0)
            .onAppear {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5).repeatCount(2, autoreverses: true)) {
                    bounce = true
                }
            }
    }
}

extension View {
    func bounceOnAppear() -> some View {
        modifier(BounceModifier())
    }
}

struct Rotation3DModifier: ViewModifier {
    let degrees: Double
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(.degrees(degrees), axis: (x: 0, y: 1, z: 0))
    }
}

extension View {
    func rotation3D(degrees: Double) -> some View {
        modifier(Rotation3DModifier(degrees: degrees))
    }
}