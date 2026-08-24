import AVFoundation
import Vision
import UIKit
import simd

protocol HandPoseEngineDelegate: AnyObject {
    func handPoseEngine(_ engine: HandPoseEngine, didUpdate pose: FingerPose?)
    func handPoseEngine(_ engine: HandPoseEngine, handDetected: Bool)
}

final class HandPoseEngine: NSObject {
    weak var delegate: HandPoseEngineDelegate?

    var selectedFinger: FingerChoice = .ring
    var isMirrored = true

    private let request = VNDetectHumanHandPoseRequest()
    private let positionFilter = Vector3Filter()
    private let directionFilter = Vector3Filter()
    private var lastHandState = false
    private var missCount = 0

    override init() {
        super.init()
        request.maximumHandCount = 1
    }

    func resetFilters() {
        positionFilter.reset()
        directionFilter.reset()
        missCount = 0
    }

    func process(sampleBuffer: CMSampleBuffer, orientation: CGImagePropertyOrientation) {
        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: orientation, options: [:])
        do {
            try handler.perform([request])
            guard let observation = request.results?.first else {
                reportMiss()
                return
            }
            guard let pose = makePose(from: observation, timestamp: CACurrentMediaTime()) else {
                reportMiss()
                return
            }
            missCount = 0
            DispatchQueue.main.async {
                if !self.lastHandState {
                    self.lastHandState = true
                    self.delegate?.handPoseEngine(self, handDetected: true)
                }
                self.delegate?.handPoseEngine(self, didUpdate: pose)
            }
        } catch {
            reportMiss()
        }
    }

    private func reportMiss() {
        missCount += 1
        guard missCount > 8 else { return }
        DispatchQueue.main.async {
            if self.lastHandState {
                self.lastHandState = false
                self.delegate?.handPoseEngine(self, handDetected: false)
            }
            self.delegate?.handPoseEngine(self, didUpdate: nil)
        }
    }

    private func makePose(from observation: VNHumanHandPoseObservation, timestamp: TimeInterval) -> FingerPose? {
        let finger = selectedFinger
        guard
            let mcp = try? observation.recognizedPoint(finger.mcp),
            let pip = try? observation.recognizedPoint(finger.pip),
            let dip = try? observation.recognizedPoint(finger.dip),
            mcp.confidence > 0.45,
            pip.confidence > 0.4
        else { return nil }

        var mcpP = point3(mcp)
        var pipP = point3(pip)
        var dipP = point3(dip)

        if isMirrored {
            mcpP.x = 1 - mcpP.x
            pipP.x = 1 - pipP.x
            dipP.x = 1 - dipP.x
        }

        let anchor2 = mix(mcpP, pipP, t: 0.38)
        let bone = simd_normalize(pipP - mcpP)
        let distal = simd_normalize(dipP - pipP)
        var direction = simd_normalize(bone * 0.7 + distal * 0.3)

        let boneLen = simd_length(pipP - mcpP)
        let radius = max(Float(0.018), boneLen * 0.42)

        let depth = Float(0.55 / max(boneLen, 0.04))
        let clampedDepth = min(max(depth, 0.35), 1.35)

        let worldAnchor = screenToWorld(anchor2, depth: clampedDepth)
        let worldDirEnd = screenToWorld(anchor2 + bone * boneLen, depth: clampedDepth)
        direction = simd_normalize(worldDirEnd - worldAnchor)

        let viewApprox = SIMD3<Float>(0, 0, 1)
        var side = simd_cross(direction, viewApprox)
        if simd_length(side) < 0.2 {
            side = simd_cross(direction, SIMD3<Float>(0, 1, 0))
        }
        side = simd_normalize(side)
        let normal = simd_normalize(simd_cross(side, direction))

        let smoothAnchor = positionFilter.filter(worldAnchor, timestamp: timestamp)
        let smoothDir = simd_normalize(directionFilter.filter(direction, timestamp: timestamp))

        return FingerPose(
            anchor: smoothAnchor,
            direction: smoothDir,
            normal: normal,
            radius: radius * 2.8 + 0.55,
            confidence: min(mcp.confidence, pip.confidence)
        )
    }

    private func point3(_ p: VNRecognizedPoint) -> SIMD3<Float> {
        SIMD3(Float(p.location.x), Float(p.location.y), 0)
    }

    private func screenToWorld(_ p: SIMD3<Float>, depth: Float) -> SIMD3<Float> {
        let x = (p.x - 0.5) * 2.0 * depth * 0.72
        let y = (p.y - 0.5) * 2.0 * depth * 1.15
        let z = -depth
        return SIMD3(x, y, z)
    }

    private func mix(_ a: SIMD3<Float>, _ b: SIMD3<Float>, t: Float) -> SIMD3<Float> {
        a + (b - a) * t
    }
}
