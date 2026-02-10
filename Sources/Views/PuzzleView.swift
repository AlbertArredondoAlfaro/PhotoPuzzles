import SwiftUI

struct PuzzleView: View {
    let config: GameConfig

    @Environment(AdMobManager.self) private var ads
    @Environment(StoreManager.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var game = PuzzleGame()
    @State private var showShareSheet = false
    @State private var shareImage: UIImage?
    @State private var showHint = false
    @State private var hintTask: Task<Void, Never>?

    private let gridSpacing: CGFloat = 2

    var body: some View {
        VStack(spacing: 16) {
            header
            grid
            actionBar
        }
        .padding(16)
        .background(.black.opacity(0.02))
        .overlay(alignment: .center) {
            if showHint {
                hintOverlay
            }
        }
        .overlay(alignment: .center) {
            if game.isSolved {
                victoryOverlay
            }
        }
        .onAppear {
            game.start(image: config.image, gridSize: config.difficulty.gridSize, filter: config.filter)
        }
        .onChange(of: game.isSolved) { _, solved in
            if solved {
                SoundPlayer.shared.playSound(named: "win", fileExtension: "wav")
                recordScore()
                ads.showInterstitial()
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let shareImage {
                ActivityView(activityItems: [shareImage, shareText()])
            }
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            HStack {
                Button(String(localized: "puzzle_close")) { dismiss() }
                    .buttonStyle(.bordered)

                Spacer()

                Text("\(String(localized: "puzzle_moves")): \(game.moves)")
                    .font(.subheadline)

                Text("\(String(localized: "puzzle_time")): \(TimeFormatter.clockString(from: game.elapsed))")
                    .font(.subheadline)
            }

            if let daily = config.dailyInfo {
                Text(String.localizedStringWithFormat(String(localized: "daily_credit"), daily.title))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var grid: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: gridSpacing), count: game.gridSize)

        return LazyVGrid(columns: columns, spacing: gridSpacing) {
            ForEach(game.slots) { slot in
                Button {
                    game.moveTile(at: slot.id)
                    SoundPlayer.shared.playSound(named: "move", fileExtension: "wav")
                } label: {
                    PuzzleTileView(slot: slot, isMovable: game.canMove(index: slot.id))
                }
                .buttonStyle(.plain)
                .disabled(slot.tile == nil || !game.canMove(index: slot.id))
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .animation(.spring(response: 0.3, dampingFraction: 0.85), value: game.slots)
    }

    private var actionBar: some View {
        HStack(spacing: 12) {
            Button(String(localized: "puzzle_restart")) {
                game.shuffle(steps: game.gridSize * game.gridSize * 12)
            }
            .buttonStyle(.bordered)

            Button(String(localized: "puzzle_hint")) {
                triggerHint()
            }
            .buttonStyle(.bordered)

            if game.isSolved {
                Button(String(localized: "puzzle_share")) {
                    prepareShare()
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    private var hintOverlay: some View {
        Group {
            if let image = game.displayImage ?? game.originalImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding(24)
                    .background(.black.opacity(0.6))
                    .clipShape(.rect(cornerRadius: 16))
                    .transition(.opacity)
            }
        }
    }

    private var victoryOverlay: some View {
        VStack(spacing: 12) {
            ConfettiView()
                .frame(height: 140)

            Text(String.localizedStringWithFormat(String(localized: "puzzle_solved"), TimeFormatter.clockString(from: game.elapsed)))
                .font(.title2.bold())
                .padding(.horizontal, 12)

            Button(String(localized: "puzzle_share")) {
                prepareShare()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }

    private func triggerHint() {
        if store.isAdsRemoved {
            showHintForSeconds(5)
            return
        }
        ads.showRewarded {
            showHintForSeconds(5)
        }
    }

    private func showHintForSeconds(_ seconds: TimeInterval) {
        hintTask?.cancel()
        showHint = true
        hintTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            await MainActor.run {
                withAnimation(.easeOut) {
                    showHint = false
                }
            }
        }
    }

    private func prepareShare() {
        guard let baseImage = game.displayImage ?? game.originalImage else { return }
        let text = String.localizedStringWithFormat(String(localized: "puzzle_solved"), TimeFormatter.clockString(from: game.elapsed))
        Task { @MainActor in
            shareImage = ShareImageRenderer.render(image: baseImage, text: text)
            showShareSheet = shareImage != nil
        }
    }

    private func shareText() -> String {
        let solvedText = String.localizedStringWithFormat(String(localized: "puzzle_solved"), TimeFormatter.clockString(from: game.elapsed))
        return "\(solvedText) \(String(localized: "share_hashtag"))"
    }

    private func recordScore() {
        let result = GameResult(difficulty: config.difficulty, moves: game.moves, elapsed: game.elapsed)
        ScoreStore.record(result: result)
    }
}
