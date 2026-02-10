import SwiftUI

struct ConfettiView: View {
    private let colors: [Color] = [.red, .yellow, .green, .blue, .orange, .pink]
    private let pieces = 24

    @State private var animate = false

    var body: some View {
        ZStack {
            ForEach(0..<pieces, id: \.self) { index in
                Circle()
                    .fill(colors[index % colors.count])
                    .frame(width: 10, height: 10)
                    .offset(x: xOffset(for: index), y: animate ? 120 : -20)
                    .opacity(animate ? 0.1 : 1)
                    .animation(.easeOut(duration: 1.2).delay(Double(index) * 0.02), value: animate)
            }
        }
        .onAppear {
            animate = true
        }
    }

    private func xOffset(for index: Int) -> CGFloat {
        let spread: CGFloat = 140
        let step = spread / CGFloat(pieces / 2)
        let pos = CGFloat(index - pieces / 2) * step
        return pos
    }
}
