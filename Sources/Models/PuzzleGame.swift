import UIKit
import Observation

@MainActor
@Observable
final class PuzzleGame {
    var slots: [TileSlot] = []
    var gridSize: Int = 3
    var moves: Int = 0
    var elapsed: TimeInterval = 0
    var isSolved: Bool = false
    var isShuffling: Bool = false
    var originalImage: UIImage?
    var displayImage: UIImage?

    private var timerTask: Task<Void, Never>?

    var emptyIndex: Int {
        slots.firstIndex(where: { $0.tile == nil }) ?? 0
    }

    func start(image: UIImage, gridSize: Int, filter: ImageFilter) {
        stopTimer()
        self.gridSize = gridSize
        self.moves = 0
        self.elapsed = 0
        self.isSolved = false

        originalImage = image
        displayImage = ImageProcessing.applyFilter(image: image, filter: filter)

        let pieces = ImageProcessing.splitImage(image: displayImage ?? image, grid: gridSize)
        var tiles: [TileSlot] = pieces.enumerated().map { index, image in
            TileSlot(id: index, tile: Tile(id: UUID(), correctIndex: index, image: image))
        }

        // Remove last tile to create empty slot.
        if !tiles.isEmpty {
            tiles[tiles.count - 1].tile = nil
        }

        slots = tiles
        shuffle(steps: gridSize * gridSize * 12)
        startTimer()
    }

    func shuffle(steps: Int) {
        guard !slots.isEmpty else { return }
        // Shuffle via valid moves to keep the puzzle solvable.
        isShuffling = true
        for _ in 0..<steps {
            let neighbors = neighborIndices(of: emptyIndex)
            if let index = neighbors.randomElement() {
                swapTiles(at: index, emptyIndex)
            }
        }
        moves = 0
        elapsed = 0
        isSolved = false
        isShuffling = false
    }

    func canMove(index: Int) -> Bool {
        neighborIndices(of: emptyIndex).contains(index)
    }

    func moveTile(at index: Int) {
        guard !isSolved else { return }
        guard canMove(index: index) else { return }
        swapTiles(at: index, emptyIndex)
        moves += 1
        checkSolved()
    }

    func checkSolved() {
        guard !slots.isEmpty else { return }
        let lastIndex = slots.count - 1
        for slot in slots {
            if slot.id == lastIndex {
                if slot.tile != nil { return }
            } else {
                guard let tile = slot.tile, tile.correctIndex == slot.id else { return }
            }
        }
        isSolved = true
        stopTimer()
    }

    func stopTimer() {
        timerTask?.cancel()
        timerTask = nil
    }

    private func startTimer() {
        timerTask?.cancel()
        timerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                await MainActor.run {
                    if !self.isSolved { self.elapsed += 1 }
                }
            }
        }
    }

    private func neighborIndices(of index: Int) -> [Int] {
        let row = index / gridSize
        let col = index % gridSize
        var indices: [Int] = []
        if row > 0 { indices.append(index - gridSize) }
        if row < gridSize - 1 { indices.append(index + gridSize) }
        if col > 0 { indices.append(index - 1) }
        if col < gridSize - 1 { indices.append(index + 1) }
        return indices
    }

    private func swapTiles(at first: Int, _ second: Int) {
        let temp = slots[first].tile
        slots[first].tile = slots[second].tile
        slots[second].tile = temp
    }
}
