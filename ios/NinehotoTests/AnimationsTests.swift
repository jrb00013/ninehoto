import XCTest
import SwiftUI
@testable import Ninehoto

final class AnimationTests: XCTestCase {

    func testSwipeAnimationModifierDirectionLeft() {
        let modifier = SwipeAnimationModifier(direction: .left, progress: 0.5)
        XCTAssertNotNil(modifier)
    }

    func testSwipeAnimationModifierDirectionRight() {
        let modifier = SwipeAnimationModifier(direction: .right, progress: 0.5)
        XCTAssertNotNil(modifier)
    }

    func testViewExtensionSwipeAnimation() {
        let view = Text("Test")
        let modifiedView = view.swipeAnimation(direction: .left, progress: 0.5)
        XCTAssertNotNil(modifiedView)
    }

    func testScaleOnPressModifier() {
        let modifier = ScaleOnPressModifier()
        XCTAssertNotNil(modifier)
    }

    func testViewExtensionScaleOnPress() {
        let view = Text("Test")
        let modifiedView = view.scaleOnPress()
        XCTAssertNotNil(modifiedView)
    }

    func testPulseModifier() {
        let modifier = PulseModifier()
        XCTAssertNotNil(modifier)
    }

    func testViewExtensionPulse() {
        let view = Text("Test")
        let modifiedView = view.pulse()
        XCTAssertNotNil(modifiedView)
    }

    func testShimmerModifier() {
        let modifier = ShimmerModifier()
        XCTAssertNotNil(modifier)
    }

    func testViewExtensionShimmer() {
        let view = Text("Test")
        let modifiedView = view.shimmer()
        XCTAssertNotNil(modifiedView)
    }

    func testShakeModifier() {
        let modifier = ShakeModifier(shakes: 3, duration: 0.5)
        XCTAssertNotNil(modifier)
    }

    func testViewExtensionShake() {
        let view = Text("Test")
        let modifiedView = view.shake(times: 3, duration: 0.5)
        XCTAssertNotNil(modifiedView)
    }

    func testFadeInModifier() {
        let modifier = FadeInModifier(delay: 0.5)
        XCTAssertNotNil(modifier)
    }

    func testViewExtensionFadeIn() {
        let view = Text("Test")
        let modifiedView = view.fadeIn(delay: 0.5)
        XCTAssertNotNil(modifiedView)
    }

    func testSlideInModifierLeading() {
        let modifier = SlideInModifier(edge: .leading, delay: 0)
        XCTAssertNotNil(modifier)
    }

    func testSlideInModifierTrailing() {
        let modifier = SlideInModifier(edge: .trailing, delay: 0)
        XCTAssertNotNil(modifier)
    }

    func testViewExtensionSlideInLeading() {
        let view = Text("Test")
        let modifiedView = view.slideIn(from: .leading, delay: 0)
        XCTAssertNotNil(modifiedView)
    }

    func testViewExtensionSlideInTrailing() {
        let view = Text("Test")
        let modifiedView = view.slideIn(from: .trailing, delay: 0)
        XCTAssertNotNil(modifiedView)
    }

    func testBounceModifier() {
        let modifier = BounceModifier()
        XCTAssertNotNil(modifier)
    }

    func testViewExtensionBounceOnAppear() {
        let view = Text("Test")
        let modifiedView = view.bounceOnAppear()
        XCTAssertNotNil(modifiedView)
    }

    func testRotation3DModifier() {
        let modifier = Rotation3DModifier(degrees: 45)
        XCTAssertNotNil(modifier)
    }

    func testViewExtensionRotation3D() {
        let view = Text("Test")
        let modifiedView = view.rotation3D(degrees: 45)
        XCTAssertNotNil(modifiedView)
    }

    func testCardTransitionModifier() {
        let modifier = CardTransitionModifier(isActive: true, direction: .left)
        XCTAssertNotNil(modifier)
    }

    func testViewExtensionCardTransition() {
        let view = Text("Test")
        let modifiedView = view.modifier(CardTransitionModifier(isActive: true, direction: .left))
        XCTAssertNotNil(modifiedView)
    }
}