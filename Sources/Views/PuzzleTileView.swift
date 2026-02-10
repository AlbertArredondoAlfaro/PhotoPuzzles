import SwiftUI

struct PuzzleTileView: View {
    let slot: TileSlot
    let isMovable: Bool

    var body: some View {
        ZStack {
            if let tile = slot.tile {
                Image(uiImage: tile.image)
                    .resizable()
                    .scaledToFill()
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(isMovable ? .white.opacity(0.9) : .white.opacity(0.4), lineWidth: isMovable ? 2 : 1)
                    )
                    .clipShape(.rect(cornerRadius: 6))
            } else {
                Color.clear
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(.white.opacity(0.1), lineWidth: 1)
                    )
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .shadow(color: .black.opacity(isMovable ? 0.2 : 0.05), radius: 4, x: 0, y: 2)
    }
}
