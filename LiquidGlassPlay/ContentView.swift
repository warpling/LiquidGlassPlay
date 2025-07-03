import SwiftUI

/// Tap the button to open a sheet that starts at a **half‑height** detent (50 %)
/// and can expand to full screen. The sheet uses iOS 26’s “Liquid Glass”
/// material with a subtle purple tint so you can evaluate translucency against
/// the random shapes behind it.
struct ContentView: View {
    // MARK: – State
    @State private var showSheet = false
    @State private var shapes = ShapeSpec.make(count: 30)

    // MARK: – Body
    var body: some View {
        ZStack {
            // colourful background shapes
            GeometryReader { geo in
                ForEach(shapes) { spec in
                    spec.shape
                        .fill(spec.color)
                        .frame(width: spec.size.width, height: spec.size.height)
                        .rotationEffect(.degrees(spec.rotation))
                        .position(x: geo.size.width  * spec.pos.x,
                                  y: geo.size.height * spec.pos.y)
                        .opacity(0.85)
                }
            }
            .ignoresSafeArea()
            
            ZStack {}
                .frame(width: 50, height: 50)
                .glassEffect(.regular.tint(.purple.opacity(1)), in: RoundedRectangle(cornerSize: CGSize(width: 16, height: 16)))

            // launcher button
            VStack {
                Spacer()
                Button("Show sheet") { showSheet = true }
                    .buttonStyle(.borderedProminent)
                    .padding(.bottom, 48)
            }
        }
        .sheet(isPresented: $showSheet) {
            SheetView()
                .presentationDetents([.fraction(0.5), .fraction(1)])
                .scrollContentBackground(.hidden)
                .glassEffect(isEnabled: false)
//                .presentationBackground(
//                    .red.opacity(0.2)
//                    .glassEffect(.regular)
//                )
        }
        .scrollContentBackground(.hidden)
        .onAppear() {
            showSheet = true
        }
    }
}

// MARK: – Sheet content ------------------------------------------------------
private struct SheetView: View {
    var body: some View {
        ScrollView {
            Text(lorem)
                .padding()
        }
//        .scrollContentBackground(.hidden)   // still needed for Lists
    }

    private let lorem =
    """
    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed non risus.
    Suspendisse lectus tortor, dignissim sit amet, adipiscing nec, ultricies
    sed, dolor. Cras elementum ultrices diam. Maecenas ligula massa, varius a,
    semper congue, euismod non, mi…
    """
}

// MARK: – Random‑shape helper ----------------------------------------------
private struct ShapeSpec: Identifiable {
    enum Kind: CaseIterable { case circle, capsule, rounded }

    let id = UUID()
    let kind: Kind
    let size: CGSize
    let pos: CGPoint     // 0…1 relative position
    let rotation: Double
    let color: Color

    var shape: some Shape {
        switch kind {
        case .circle:  AnyShape(Circle())
        case .capsule: AnyShape(Capsule())
        case .rounded: AnyShape(RoundedRectangle(cornerRadius: size.height * 0.3,
                                                style: .continuous))
        }
    }

    static func make(count: Int) -> [ShapeSpec] {
        (0..<count).map { _ in
            let kind  = Kind.allCases.randomElement()!
            let side  = CGFloat.random(in: 40...120)
            let size  = kind == .capsule ? CGSize(width: side, height: side/2)
                                         : CGSize(width: side, height: side)
            return ShapeSpec(
                kind: kind,
                size: size,
                pos: .init(x: CGFloat.random(in: 0...1), y: CGFloat.random(in: 0...1)),
                rotation: .random(in: 0...360),
                color: Color(hue: .random(in: 0...1),
                             saturation: 0.65,
                             brightness: 0.9)
            )
        }
    }
}

// MARK: – AnyShape type‑eraser ---------------------------------------------
struct AnyShape: Shape {
    private let _path: (CGRect) -> Path
    init<S: Shape>(_ wrapped: S) { _path = { wrapped.path(in: $0) } }
    func path(in rect: CGRect) -> Path { _path(rect) }
}
