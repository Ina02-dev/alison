import SwiftUI

struct CatalogView: View {
    private let products = RingProduct.catalog
    @State private var selected: RingProduct?
    @State private var appear = false

    var body: some View {
        NavigationStack {
            ZStack {
                background

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        header
                            .padding(.top, 28)
                            .padding(.horizontal, 24)

                        Text("Available for Try-On")
                            .font(AlisonTheme.caption)
                            .tracking(1.6)
                            .foregroundStyle(AlisonTheme.steel)
                            .padding(.horizontal, 24)
                            .padding(.top, 36)
                            .padding(.bottom, 16)

                        LazyVStack(spacing: 28) {
                            ForEach(Array(products.enumerated()), id: \.element.id) { index, product in
                                ProductRow(product: product) {
                                    selected = product
                                }
                                .opacity(appear ? 1 : 0)
                                .offset(y: appear ? 0 : 24)
                                .animation(.easeOut(duration: 0.55).delay(0.08 * Double(index)), value: appear)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 48)
                    }
                }
            }
            .navigationBarHidden(true)
            .fullScreenCover(item: $selected) { product in
                TryOnView(initialProduct: product)
            }
            .onAppear {
                appear = true
            }
        }
    }

    private var background: some View {
        ZStack {
            AlisonTheme.ink
            RadialGradient(
                colors: [
                    Color(red: 0.18, green: 0.15, blue: 0.11).opacity(0.9),
                    AlisonTheme.ink
                ],
                center: .topTrailing,
                startRadius: 20,
                endRadius: 520
            )
            .ignoresSafeArea()

            // Soft grain-like vignette
            LinearGradient(
                colors: [.clear, AlisonTheme.ink.opacity(0.55)],
                startPoint: .center,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("ALISON")
                .font(.system(size: 14, weight: .semibold, design: .default))
                .tracking(6)
                .foregroundStyle(AlisonTheme.champagne)

            Text("Try the ring\non your hand.")
                .font(AlisonTheme.display)
                .foregroundStyle(AlisonTheme.mist)
                .lineSpacing(2)

            Text("Live AR · metal reflections · finger tracking")
                .font(AlisonTheme.body)
                .foregroundStyle(AlisonTheme.steel)
                .padding(.top, 4)
        }
    }
}

private struct ProductRow: View {
    let product: RingProduct
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 14) {
                Image(product.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 280)
                    .clipped()
                    .overlay(alignment: .bottom) {
                        LinearGradient(
                            colors: [.clear, AlisonTheme.ink.opacity(0.75)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 120)
                    }

                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(product.name)
                            .font(AlisonTheme.displaySmall)
                            .foregroundStyle(AlisonTheme.mist)
                        Text(product.subtitle)
                            .font(AlisonTheme.caption)
                            .foregroundStyle(AlisonTheme.steel)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 8) {
                        Text(product.price)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(AlisonTheme.champagne)
                        Text("TRY ON")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(1.4)
                            .foregroundStyle(AlisonTheme.ink)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(AlisonTheme.mist)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .buttonStyle(.plain)
    }
}
