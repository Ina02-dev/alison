import Foundation
import SwiftUI
import Vision
import UIKit

enum MetalFinish: String, CaseIterable, Identifiable {
    case yellowGold = "Gold"
    case whiteGold = "White Gold"
    case roseGold = "Rose Gold"
    case platinum = "Platinum"

    var id: String { rawValue }

    var baseColor: UIColor {
        switch self {
        case .yellowGold: return UIColor(red: 0.83, green: 0.65, blue: 0.28, alpha: 1)
        case .whiteGold: return UIColor(red: 0.86, green: 0.87, blue: 0.90, alpha: 1)
        case .roseGold: return UIColor(red: 0.86, green: 0.55, blue: 0.48, alpha: 1)
        case .platinum: return UIColor(red: 0.78, green: 0.80, blue: 0.84, alpha: 1)
        }
    }
}

enum FingerChoice: String, CaseIterable, Identifiable {
    case index = "Index"
    case middle = "Middle"
    case ring = "Ring"
    case little = "Pinky"

    var id: String { rawValue }

    var tip: VNHumanHandPoseObservation.JointName { switch self {
        case .index: return .indexTip
        case .middle: return .middleTip
        case .ring: return .ringTip
        case .little: return .littleTip
    }}

    var dip: VNHumanHandPoseObservation.JointName { switch self {
        case .index: return .indexDIP
        case .middle: return .middleDIP
        case .ring: return .ringDIP
        case .little: return .littleDIP
    }}

    var pip: VNHumanHandPoseObservation.JointName { switch self {
        case .index: return .indexPIP
        case .middle: return .middlePIP
        case .ring: return .ringPIP
        case .little: return .littlePIP
    }}

    var mcp: VNHumanHandPoseObservation.JointName { switch self {
        case .index: return .indexMCP
        case .middle: return .middleMCP
        case .ring: return .ringMCP
        case .little: return .littleMCP
    }}
}

enum RingStyle: String {
    case solitaire
    case emerald
    case halo
    case band
}

struct RingProduct: Identifiable {
    let id: String
    let name: String
    let subtitle: String
    let price: String
    let imageName: String
    let style: RingStyle
    let defaultMetal: MetalFinish
    let hasStone: Bool
    let stoneColor: UIColor
    let bandThickness: CGFloat
    let stoneScale: CGFloat

    static let catalog: [RingProduct] = [
        RingProduct(
            id: "solitaire-gold",
            name: "Solitaire",
            subtitle: "1.0ct brilliant cut · yellow gold",
            price: "€2,490",
            imageName: "RingSolitaire",
            style: .solitaire,
            defaultMetal: .yellowGold,
            hasStone: true,
            stoneColor: UIColor(red: 0.92, green: 0.95, blue: 1.0, alpha: 1),
            bandThickness: 0.85,
            stoneScale: 1.0
        ),
        RingProduct(
            id: "emerald-halo",
            name: "Emerald Halo",
            subtitle: "Emerald cut · white gold halo",
            price: "€3,180",
            imageName: "RingEmerald",
            style: .emerald,
            defaultMetal: .whiteGold,
            hasStone: true,
            stoneColor: UIColor(red: 0.12, green: 0.55, blue: 0.38, alpha: 1),
            bandThickness: 0.9,
            stoneScale: 1.05
        ),
        RingProduct(
            id: "halo-rose",
            name: "Diamond Halo",
            subtitle: "Round brilliant · rose gold",
            price: "€2,870",
            imageName: "RingHalo",
            style: .halo,
            defaultMetal: .roseGold,
            hasStone: true,
            stoneColor: UIColor(red: 0.94, green: 0.96, blue: 1.0, alpha: 1),
            bandThickness: 0.8,
            stoneScale: 0.95
        ),
        RingProduct(
            id: "classic-band",
            name: "Classic Band",
            subtitle: "Polished platinum wedding band",
            price: "€890",
            imageName: "RingBand",
            style: .band,
            defaultMetal: .platinum,
            hasStone: false,
            stoneColor: .clear,
            bandThickness: 1.15,
            stoneScale: 0
        )
    ]
}
