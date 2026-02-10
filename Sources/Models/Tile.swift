import UIKit

struct Tile: Identifiable, Equatable {
    let id: UUID
    let correctIndex: Int
    let image: UIImage
}

struct TileSlot: Identifiable, Equatable {
    let id: Int
    var tile: Tile?
}
