import Foundation
import CoreGraphics
import simd

/// One-Euro filter for stable but responsive landmark smoothing.
final class OneEuroFilter {
    private var minCutoff: Double
    private var beta: Double
    private var dCutoff: Double
    private var xPrev: Double?
    private var dxPrev: Double = 0
    private var tPrev: TimeInterval?

    init(minCutoff: Double = 1.2, beta: Double = 0.045, dCutoff: Double = 1.0) {
        self.minCutoff = minCutoff
        self.beta = beta
        self.dCutoff = dCutoff
    }

    func filter(_ x: Double, timestamp: TimeInterval) -> Double {
        guard let tPrev, let xPrev else {
            self.tPrev = timestamp
            self.xPrev = x
            return x
        }

        let dt = max(timestamp - tPrev, 1e-3)
        let dx = (x - xPrev) / dt
        let edx = lowPass(value: dx, previous: dxPrev, cutoff: dCutoff, dt: dt)
        dxPrev = edx

        let cutoff = minCutoff + beta * abs(edx)
        let result = lowPass(value: x, previous: xPrev, cutoff: cutoff, dt: dt)
        self.xPrev = result
        self.tPrev = timestamp
        return result
    }

    func reset() {
        xPrev = nil
        dxPrev = 0
        tPrev = nil
    }

    private func lowPass(value: Double, previous: Double, cutoff: Double, dt: Double) -> Double {
        let tau = 1.0 / (2 * Double.pi * cutoff)
        let alpha = 1.0 / (1.0 + tau / dt)
        return alpha * value + (1 - alpha) * previous
    }
}

final class Vector3Filter {
    private let fx = OneEuroFilter()
    private let fy = OneEuroFilter()
    private let fz = OneEuroFilter()

    func filter(_ v: SIMD3<Float>, timestamp: TimeInterval) -> SIMD3<Float> {
        SIMD3(
            Float(fx.filter(Double(v.x), timestamp: timestamp)),
            Float(fy.filter(Double(v.y), timestamp: timestamp)),
            Float(fz.filter(Double(v.z), timestamp: timestamp))
        )
    }

    func reset() {
        fx.reset(); fy.reset(); fz.reset()
    }
}

struct FingerPose {
    var anchor: SIMD3<Float>
    var direction: SIMD3<Float>
    var normal: SIMD3<Float>
    var radius: Float
    var confidence: Float
}
