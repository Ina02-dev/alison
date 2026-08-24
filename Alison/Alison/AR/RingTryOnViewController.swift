import UIKit
import AVFoundation
import SceneKit
import SwiftUI
import simd

final class RingTryOnViewController: UIViewController {
    var product: RingProduct!
    var metal: MetalFinish = .yellowGold
    var finger: FingerChoice = .ring

    var onHandDetectedChange: ((Bool) -> Void)?
    var onCapture: ((UIImage) -> Void)?

    private let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let sessionQueue = DispatchQueue(label: "alison.camera")
    private let poseEngine = HandPoseEngine()

    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var sceneView: SCNView!
    private var ringNode: SCNNode!
    private var cameraNode: SCNNode!
    private var lightNode: SCNNode!
    private var ambientNode: SCNNode!

    private var currentProduct: RingProduct!
    private var isSessionRunning = false
    private var ringVisible = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        currentProduct = product
        metal = product.defaultMetal
        setupScene()
        setupCamera()
        poseEngine.delegate = self
        poseEngine.selectedFinger = finger
        rebuildRing()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
        sceneView?.frame = view.bounds
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startSession()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopSession()
    }

    // MARK: - Public controls

    func updateProduct(_ product: RingProduct) {
        self.product = product
        currentProduct = product
        metal = product.defaultMetal
        rebuildRing()
    }

    func updateMetal(_ metal: MetalFinish) {
        self.metal = metal
        RingEntityFactory.applyMetal(metal, to: ringNode)
    }

    func updateFinger(_ finger: FingerChoice) {
        self.finger = finger
        poseEngine.selectedFinger = finger
        poseEngine.resetFilters()
    }

    func capturePhoto() {
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds, format: format)
        let image = renderer.image { ctx in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
        onCapture?(image)
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }

    // MARK: - Setup

    private func setupCamera() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(previewLayer, at: 0)

        sessionQueue.async { [weak self] in
            self?.configureSession()
        }
    }

    private func configureSession() {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .high

        guard
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
                ?? AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let input = try? AVCaptureDeviceInput(device: device)
        else {
            captureSession.commitConfiguration()
            return
        }

        poseEngine.isMirrored = device.position == .front

        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }

        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }

        if let connection = videoOutput.connection(with: .video) {
            if connection.isVideoOrientationSupported {
                connection.videoOrientation = .portrait
            }
            if connection.isVideoMirroringSupported {
                connection.isVideoMirrored = device.position == .front
            }
        }

        captureSession.commitConfiguration()
    }

    private func setupScene() {
        sceneView = SCNView(frame: view.bounds)
        sceneView.backgroundColor = .clear
        sceneView.isPlaying = true
        sceneView.autoenablesDefaultLighting = false
        sceneView.antialiasingMode = .multisampling4X
        sceneView.preferredFramesPerSecond = 60
        view.addSubview(sceneView)

        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.pointOfView = nil

        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.fieldOfView = 60
        cameraNode.camera?.zNear = 0.01
        cameraNode.camera?.zFar = 100
        cameraNode.position = SCNVector3(0, 0, 0)
        scene.rootNode.addChildNode(cameraNode)
        sceneView.pointOfView = cameraNode

        ambientNode = SCNNode()
        ambientNode.light = SCNLight()
        ambientNode.light?.type = .ambient
        ambientNode.light?.intensity = 400
        ambientNode.light?.color = UIColor(white: 0.85, alpha: 1)
        scene.rootNode.addChildNode(ambientNode)

        lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .directional
        lightNode.light?.intensity = 900
        lightNode.light?.castsShadow = true
        lightNode.light?.color = UIColor(red: 1, green: 0.97, blue: 0.93, alpha: 1)
        lightNode.eulerAngles = SCNVector3(-0.9, 0.6, 0)
        scene.rootNode.addChildNode(lightNode)

        let fill = SCNNode()
        fill.light = SCNLight()
        fill.light?.type = .directional
        fill.light?.intensity = 450
        fill.light?.color = UIColor(red: 0.75, green: 0.82, blue: 1.0, alpha: 1)
        fill.eulerAngles = SCNVector3(-0.3, -0.9, 0)
        scene.rootNode.addChildNode(fill)

        // Soft environment for metal reflections
        scene.lightingEnvironment.contents = UIColor(white: 0.35, alpha: 1)
        scene.lightingEnvironment.intensity = 1.4

        ringNode = SCNNode()
        scene.rootNode.addChildNode(ringNode)
        ringNode.isHidden = true
    }

    private func rebuildRing() {
        ringNode.childNodes.forEach { $0.removeFromParentNode() }
        let built = RingEntityFactory.makeRing(for: currentProduct, metal: metal)
        ringNode.addChildNode(built)
    }

    private func startSession() {
        sessionQueue.async { [weak self] in
            guard let self, !self.isSessionRunning else { return }
            self.captureSession.startRunning()
            self.isSessionRunning = true
        }
    }

    private func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self, self.isSessionRunning else { return }
            self.captureSession.stopRunning()
            self.isSessionRunning = false
        }
    }

    private func apply(pose: FingerPose) {
        let zAxis = simd_normalize(pose.direction)
        var yAxis = simd_normalize(pose.normal)
        let xAxis = simd_normalize(simd_cross(yAxis, zAxis))
        yAxis = simd_normalize(simd_cross(zAxis, xAxis))

        let scale = pose.radius
        var transform = matrix_identity_float4x4
        transform.columns.0 = SIMD4<Float>(xAxis.x * scale, xAxis.y * scale, xAxis.z * scale, 0)
        transform.columns.1 = SIMD4<Float>(yAxis.x * scale, yAxis.y * scale, yAxis.z * scale, 0)
        transform.columns.2 = SIMD4<Float>(zAxis.x * scale, zAxis.y * scale, zAxis.z * scale, 0)
        transform.columns.3 = SIMD4<Float>(pose.anchor.x, pose.anchor.y, pose.anchor.z, 1)

        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.04
        ringNode.simdTransform = transform
        ringNode.isHidden = false
        SCNTransaction.commit()
        ringVisible = true
    }
}

extension RingTryOnViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        poseEngine.process(sampleBuffer: sampleBuffer, orientation: .up)
    }
}

extension RingTryOnViewController: HandPoseEngineDelegate {
    func handPoseEngine(_ engine: HandPoseEngine, didUpdate pose: FingerPose?) {
        guard let pose else {
            ringNode.isHidden = true
            ringVisible = false
            return
        }
        apply(pose: pose)
    }

    func handPoseEngine(_ engine: HandPoseEngine, handDetected: Bool) {
        onHandDetectedChange?(handDetected)
    }
}

// MARK: - SwiftUI bridge

struct RingTryOnRepresentable: UIViewControllerRepresentable {
    let product: RingProduct
    @Binding var metal: MetalFinish
    @Binding var finger: FingerChoice
    @Binding var catalogIndex: Int
    var captureTrigger: Int
    var onHandDetectedChange: (Bool) -> Void
    var onCapture: (UIImage) -> Void

    func makeUIViewController(context: Context) -> RingTryOnViewController {
        let vc = RingTryOnViewController()
        vc.product = product
        vc.metal = metal
        vc.finger = finger
        vc.onHandDetectedChange = onHandDetectedChange
        vc.onCapture = onCapture
        context.coordinator.controller = vc
        return vc
    }

    func updateUIViewController(_ uiViewController: RingTryOnViewController, context: Context) {
        let products = RingProduct.catalog
        let selected = products[min(max(catalogIndex, 0), products.count - 1)]
        if uiViewController.product.id != selected.id {
            uiViewController.updateProduct(selected)
        }
        if uiViewController.metal != metal {
            uiViewController.updateMetal(metal)
        }
        if uiViewController.finger != finger {
            uiViewController.updateFinger(finger)
        }
        if context.coordinator.lastCaptureTrigger != captureTrigger {
            context.coordinator.lastCaptureTrigger = captureTrigger
            uiViewController.capturePhoto()
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator {
        var controller: RingTryOnViewController?
        var lastCaptureTrigger = 0
    }
}
