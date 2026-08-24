import SwiftUI

struct TryOnView: View {
    let initialProduct: RingProduct

    @Environment(\.dismiss) private var dismiss
    @State private var catalogIndex: Int
    @State private var metal: MetalFinish
    @State private var finger: FingerChoice = .ring
    @State private var handDetected = false
    @State private var captureTrigger = 0
    @State private var flashCapture = false
    @State private var showControls = true
    @State private var toast: String?

    init(initialProduct: RingProduct) {
        self.initialProduct = initialProduct
        let idx = RingProduct.catalog.firstIndex(where: { $0.id == initialProduct.id }) ?? 0
        _catalogIndex = State(initialValue: idx)
        _metal = State(initialValue: initialProduct.defaultMetal)
    }

    private var product: RingProduct {
        RingProduct.catalog[catalogIndex]
    }

    var body: some View {
        ZStack {
            RingTryOnRepresentable(
                product: product,
                metal: $metal,
                finger: $finger,
                catalogIndex: $catalogIndex,
                captureTrigger: captureTrigger,
                onHandDetectedChange: { handDetected = $0 },
                onCapture: { _ in
                    withAnimation { toast = "Saved to Photos" }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                        withAnimation { toast = nil }
                    }
                }
            )
            .ignoresSafeArea()

            if flashCapture {
                Color.white.opacity(0.55).ignoresSafeArea()
            }

            VStack(spacing: 0) {
                topBar
                Spacer()
                if showControls {
                    bottomPanel
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }

            if let toast {
                Text(toast)
                    .font(AlisonTheme.caption)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding(.bottom, 120)
                    .frame(maxHeight: .infinity, alignment: .bottom)
            }
        }
        .statusBarHidden(true)
        .onChange(of: catalogIndex) { _, newValue in
            metal = RingProduct.catalog[newValue].defaultMetal
        }
    }

    private var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AlisonTheme.mist)
                    .frame(width: 40, height: 40)
                    .background(.black.opacity(0.35))
                    .clipShape(Circle())
            }

            Spacer()

            VStack(spacing: 4) {
                Text(product.name.uppercased())
                    .font(.system(size: 12, weight: .semibold))
                    .tracking(2)
                    .foregroundStyle(AlisonTheme.mist)
                HStack(spacing: 6) {
                    Circle()
                        .fill(handDetected ? Color.green.opacity(0.9) : Color.orange.opacity(0.85))
                        .frame(width: 6, height: 6)
                    Text(handDetected ? "Hand detected" : "Show your hand")
                        .font(AlisonTheme.caption)
                        .foregroundStyle(AlisonTheme.mist.opacity(0.85))
                }
            }

            Spacer()

            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showControls.toggle()
                }
            } label: {
                Image(systemName: showControls ? "chevron.down" : "slider.horizontal.3")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AlisonTheme.mist)
                    .frame(width: 40, height: 40)
                    .background(.black.opacity(0.35))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 12)
    }

    private var bottomPanel: some View {
        VStack(spacing: 18) {
            ringCarousel

            HStack(spacing: 12) {
                controlChip("Finger") {
                    Menu {
                        ForEach(FingerChoice.allCases) { f in
                            Button(f.rawValue) { finger = f }
                        }
                    } label: {
                        labelChip(finger.rawValue)
                    }
                }

                controlChip("Metal") {
                    Menu {
                        ForEach(MetalFinish.allCases) { m in
                            Button(m.rawValue) { metal = m }
                        }
                    } label: {
                        labelChip(metal.rawValue)
                    }
                }

                Spacer()

                Button {
                    flashCapture = true
                    captureTrigger += 1
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                        flashCapture = false
                    }
                } label: {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AlisonTheme.ink)
                        .frame(width: 56, height: 56)
                        .background(AlisonTheme.mist)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 4)
        }
        .padding(.horizontal, 18)
        .padding(.top, 18)
        .padding(.bottom, 28)
        .background(
            LinearGradient(
                colors: [.clear, .black.opacity(0.72), .black.opacity(0.92)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .bottom)
        )
    }

    private var ringCarousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(RingProduct.catalog.enumerated()), id: \.element.id) { index, item in
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            catalogIndex = index
                        }
                    } label: {
                        VStack(spacing: 8) {
                            Image(item.imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 72, height: 72)
                                .clipped()
                                .overlay {
                                    RoundedRectangle(cornerRadius: 2)
                                        .stroke(
                                            catalogIndex == index ? AlisonTheme.champagne : .clear,
                                            lineWidth: 2
                                        )
                                }
                            Text(item.name)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(
                                    catalogIndex == index ? AlisonTheme.mist : AlisonTheme.steel
                                )
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 2)
        }
    }

    private func controlChip<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.system(size: 9, weight: .bold))
                .tracking(1.2)
                .foregroundStyle(AlisonTheme.steel)
            content()
        }
    }

    private func labelChip(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(AlisonTheme.mist)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(AlisonTheme.soft.opacity(0.9))
            .overlay {
                Rectangle().stroke(AlisonTheme.steel.opacity(0.35), lineWidth: 1)
            }
    }
}
