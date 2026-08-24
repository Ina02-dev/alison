import SceneKit
import UIKit

enum RingEntityFactory {
    static func makeRing(for product: RingProduct, metal: MetalFinish) -> SCNNode {
        let root = SCNNode()
        root.name = "ringRoot"

        let band = makeBand(thickness: product.bandThickness, metal: metal)
        band.name = "band"
        root.addChildNode(band)

        if product.hasStone {
            switch product.style {
            case .solitaire:
                root.addChildNode(makeRoundStone(color: product.stoneColor, scale: product.stoneScale, metal: metal))
            case .emerald:
                root.addChildNode(makeEmeraldStone(color: product.stoneColor, scale: product.stoneScale, metal: metal))
            case .halo:
                root.addChildNode(makeHaloStone(color: product.stoneColor, scale: product.stoneScale, metal: metal))
            case .band:
                break
            }
        }

        // Invisible depth occluder — hides the back half of the ring behind the finger.
        let occluder = makeFingerOccluder()
        occluder.name = "fingerOccluder"
        root.addChildNode(occluder)

        return root
    }

    static func applyMetal(_ metal: MetalFinish, to root: SCNNode) {
        root.enumerateChildNodes { node, _ in
            guard node.name == "band" || node.name == "prong" || node.name == "haloRim" else { return }
            node.geometry?.firstMaterial = metalMaterial(metal)
        }
    }

    // MARK: - Parts

    private static func makeBand(thickness: CGFloat, metal: MetalFinish) -> SCNNode {
        // Ring sits in XY plane; finger goes through Z.
        let torus = SCNTorus(ringRadius: 1.0, pipeRadius: 0.085 * thickness)
        torus.ringSegmentCount = 96
        torus.pipeSegmentCount = 36
        torus.firstMaterial = metalMaterial(metal)

        let node = SCNNode(geometry: torus)
        node.eulerAngles.x = Float.pi / 2
        return node
    }

    private static func makeRoundStone(color: UIColor, scale: CGFloat, metal: MetalFinish) -> SCNNode {
        let group = SCNNode()
        group.name = "stoneGroup"

        let gem = SCNNode(geometry: brilliantApprox(color: color))
        gem.name = "stone"
        gem.position = SCNVector3(0, 1.08, 0)
        gem.scale = SCNVector3(Float(0.28 * scale), Float(0.22 * scale), Float(0.28 * scale))
        group.addChildNode(gem)

        let setting = SCNCylinder(radius: 0.12 * scale, height: 0.08)
        setting.firstMaterial = metalMaterial(metal)
        let settingNode = SCNNode(geometry: setting)
        settingNode.name = "prong"
        settingNode.position = SCNVector3(0, 0.98, 0)
        group.addChildNode(settingNode)

        for i in 0..<4 {
            let prong = SCNCylinder(radius: 0.018, height: 0.22)
            prong.firstMaterial = metalMaterial(metal)
            let p = SCNNode(geometry: prong)
            p.name = "prong"
            let angle = Float(i) * (.pi / 2) + .pi / 4
            p.position = SCNVector3(cos(angle) * 0.14, 1.05, sin(angle) * 0.14)
            p.eulerAngles.x = 0.35
            group.addChildNode(p)
        }

        return group
    }

    private static func makeEmeraldStone(color: UIColor, scale: CGFloat, metal: MetalFinish) -> SCNNode {
        let group = SCNNode()
        group.name = "stoneGroup"

        let box = SCNBox(width: 0.38 * scale, height: 0.22 * scale, length: 0.28 * scale, chamferRadius: 0.02)
        box.firstMaterial = gemMaterial(color: color, roughness: 0.08)
        let gem = SCNNode(geometry: box)
        gem.name = "stone"
        gem.position = SCNVector3(0, 1.1, 0)
        group.addChildNode(gem)

        let bezel = SCNBox(width: 0.44 * scale, height: 0.06, length: 0.34 * scale, chamferRadius: 0.01)
        bezel.firstMaterial = metalMaterial(metal)
        let bezelNode = SCNNode(geometry: bezel)
        bezelNode.name = "prong"
        bezelNode.position = SCNVector3(0, 0.98, 0)
        group.addChildNode(bezelNode)

        return group
    }

    private static func makeHaloStone(color: UIColor, scale: CGFloat, metal: MetalFinish) -> SCNNode {
        let group = SCNNode()
        group.name = "stoneGroup"

        let center = SCNNode(geometry: brilliantApprox(color: color))
        center.name = "stone"
        center.position = SCNVector3(0, 1.1, 0)
        center.scale = SCNVector3(Float(0.22 * scale), Float(0.18 * scale), Float(0.22 * scale))
        group.addChildNode(center)

        let rim = SCNTorus(ringRadius: 0.22 * scale, pipeRadius: 0.035)
        rim.firstMaterial = metalMaterial(metal)
        let rimNode = SCNNode(geometry: rim)
        rimNode.name = "haloRim"
        rimNode.position = SCNVector3(0, 1.05, 0)
        rimNode.eulerAngles.x = .pi / 2
        group.addChildNode(rimNode)

        for i in 0..<10 {
            let mini = SCNSphere(radius: 0.035 * scale)
            mini.firstMaterial = gemMaterial(color: UIColor(white: 0.95, alpha: 1), roughness: 0.05)
            let n = SCNNode(geometry: mini)
            n.name = "stone"
            let a = Float(i) / 10.0 * (.pi * 2)
            n.position = SCNVector3(cos(a) * 0.22 * Float(scale), 1.08, sin(a) * 0.22 * Float(scale))
            group.addChildNode(n)
        }

        return group
    }

    private static func makeFingerOccluder() -> SCNNode {
        // Slightly larger than finger radius estimate; writes depth only.
        let cylinder = SCNCylinder(radius: 0.92, height: 2.4)
        let mat = SCNMaterial()
        mat.colorBufferWriteMask = []
        mat.writesToDepthBuffer = true
        mat.readsFromDepthBuffer = true
        mat.lightingModel = .constant
        mat.diffuse.contents = UIColor.black
        cylinder.firstMaterial = mat

        let node = SCNNode(geometry: cylinder)
        node.renderingOrder = -10
        // Finger axis is Z in ring local space after orientation; cylinder default is Y.
        node.eulerAngles.x = .pi / 2
        return node
    }

    // MARK: - Materials

    static func metalMaterial(_ finish: MetalFinish) -> SCNMaterial {
        let mat = SCNMaterial()
        mat.lightingModel = .physicallyBased
        mat.diffuse.contents = finish.baseColor
        mat.metalness.contents = 1.0
        mat.roughness.contents = finish == .platinum || finish == .whiteGold ? 0.22 : 0.28
        mat.selfIllumination.contents = finish.baseColor.withAlphaComponent(0.05)
        return mat
    }

    static func gemMaterial(color: UIColor, roughness: CGFloat) -> SCNMaterial {
        let mat = SCNMaterial()
        mat.lightingModel = .physicallyBased
        mat.diffuse.contents = color
        mat.metalness.contents = 0.05
        mat.roughness.contents = roughness
        mat.transparencyMode = .dualLayer
        mat.isDoubleSided = true
        mat.transparency = 0.72
        mat.fresnelExponent = 1.8
        mat.selfIllumination.contents = color.withAlphaComponent(0.35)
        return mat
    }

    private static func brilliantApprox(color: UIColor) -> SCNGeometry {
        // Pyramid + inverted pyramid approximates a brilliant cut.
        let top = SCNPyramid(width: 1, height: 0.7, length: 1)
        top.firstMaterial = gemMaterial(color: color, roughness: 0.04)
        // Combined via node tree instead; return sphere fallback for simple geometry attach.
        let sphere = SCNSphere(radius: 0.5)
        sphere.segmentCount = 48
        sphere.firstMaterial = gemMaterial(color: color, roughness: 0.04)
        return sphere
    }
}
