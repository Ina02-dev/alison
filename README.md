# Alison — iOS AR Ring Try-On

Native **iPhone-only** app: choose a ring, open the camera, and see it placed on your finger in real time.

## Stack

- SwiftUI catalog
- AVFoundation camera
- Vision `VNDetectHumanHandPoseRequest` finger landmarks
- SceneKit PBR metals + depth occluder (ring goes *around* the finger, not a sticker)
- One-Euro filter for stable tracking

## Open & run (me Xcode)

1. Install **Xcode 15+** from the Mac App Store
2. Open `Alison/Alison.xcodeproj`
3. Select your **Team** under Signing & Capabilities
4. Plug in an iPhone (hand pose needs a real device — Simulator is weak for camera/Vision)
5. Run on device, allow Camera + Photos

## TestFlight pa Xcode lokal

Përdor **Codemagic**. Udhëzuesi: [`CODEMAGIC.md`](CODEMAGIC.md)

- Bundle ID: `al.alison.app`
- Workflow: **Alison TestFlight**

## In the try-on screen

- Switch rings without closing the camera
- Finger: Index / Middle / Ring / Pinky
- Metal: Gold / White Gold / Rose Gold / Platinum
- Capture saves a screenshot to Photos

## Catalog

Four starter rings with studio product shots:

- Solitaire (yellow gold)
- Emerald Halo
- Diamond Halo (rose gold)
- Classic Band (platinum)

## Next realism upgrades

- Replace procedural meshes with real `.usdz` CAD from your jeweler
- LiDAR occlusion on Pro models
- Exact mm sizing + ring size picker
