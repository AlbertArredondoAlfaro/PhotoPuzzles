import SwiftUI
import PhotosUI

struct ContentView: View {
    @Environment(UserSettings.self) private var settings
    @Environment(StoreManager.self) private var store
    @Environment(AdMobManager.self) private var ads

    @State private var selectedItem: PhotosPickerItem?
    @State private var isCameraPresented = false
    @State private var activeGame: GameConfig?
    @State private var showLimitAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var isLoadingPhoto = false
    @State private var showCameraUnavailable = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    header
                    actionButtons
                    settingsCard
                    statsCard
                    paywallCard
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 32)
            }
            .background(
                LinearGradient(colors: [.blue.opacity(0.2), .cyan.opacity(0.1)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            )
            .navigationTitle("")
            .toolbar { }
            .sheet(item: $activeGame) { config in
                PuzzleView(config: config)
            }
            .sheet(isPresented: $isCameraPresented) {
                CameraPicker { image in
                    handleSelectedImage(image)
                } onError: { message in
                    errorMessage = message
                    showErrorAlert = true
                }
            }
            .alert(String(localized: "limit_reached_title"), isPresented: $showLimitAlert) {
                Button(String(localized: "limit_watch_ad")) {
                    ads.showRewarded {
                        settings.addBonusPlay()
                    }
                }
                Button(String(localized: "limit_upgrade")) {
                    Task { await buyRemoveAds() }
                }
                Button(String(localized: "puzzle_close"), role: .cancel) {}
            } message: {
                Text(String(localized: "limit_reached_message"))
            }
            .alert(String(localized: "alert_error_title"), isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage.isEmpty ? String(localized: "alert_error_message") : errorMessage)
            }
            .alert(String(localized: "camera_unavailable"), isPresented: $showCameraUnavailable) {
                Button(String(localized: "puzzle_close"), role: .cancel) {}
            }
            .task {
                await store.loadProducts()
            }
        }
        .overlay(alignment: .bottom) {
            if !store.isAdsRemoved {
                BannerAdView()
                    .frame(height: 50)
            }
        }
        .onChange(of: selectedItem) { _, newItem in
            guard let newItem else { return }
            Task {
                isLoadingPhoto = true
                defer { isLoadingPhoto = false }
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    handleSelectedImage(image)
                } else {
                    errorMessage = String(localized: "alert_error_message")
                    showErrorAlert = true
                }
            }
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text(String(localized: "app_title"))
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)

            Text(String(localized: "app_subtitle"))
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                Label(String(localized: "menu_choose_photo"), systemImage: "photo.on.rectangle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoadingPhoto)

            Button {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    isCameraPresented = true
                } else {
                    showCameraUnavailable = true
                }
            } label: {
                Label(String(localized: "menu_take_photo"), systemImage: "camera")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            Button {
                startDailyGame()
            } label: {
                Label(String(localized: "menu_daily_puzzle"), systemImage: "calendar")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
    }

    private var settingsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "difficulty"))
                .font(.headline)

            Picker(String(localized: "difficulty"), selection: Binding(
                get: { settings.difficulty },
                set: { settings.difficulty = $0 }
            )) {
                ForEach(Difficulty.allCases) { difficulty in
                    Text(String(localized: .init(difficulty.displayKey))).tag(difficulty)
                }
            }
            .pickerStyle(.segmented)

            Text(String(localized: "filter"))
                .font(.headline)

            Picker(String(localized: "filter"), selection: Binding(
                get: { settings.filter },
                set: { settings.filter = $0 }
            )) {
                ForEach(ImageFilter.allCases) { filter in
                    Text(String(localized: .init(filter.displayKey))).tag(filter)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var statsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(String(localized: "stats_best_time")): \(bestTimeText())")
                .font(.subheadline)
            Text("\(String(localized: "stats_best_moves")): \(bestMovesText())")
                .font(.subheadline)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var paywallCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            if store.isAdsRemoved {
                Text(String(localized: "iap_thanks"))
                    .font(.headline)
            } else {
                Text(String(localized: "iap_remove_ads"))
                    .font(.headline)
                Button(String(localized: "iap_buy")) {
                    Task { await buyRemoveAds() }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func handleSelectedImage(_ image: UIImage) {
        guard settings.canStartPuzzle(isUnlimited: store.hasUnlimited) else {
            showLimitAlert = true
            return
        }
        settings.registerPuzzleStart(isUnlimited: store.hasUnlimited)
        let config = GameConfig(image: image, difficulty: settings.difficulty, filter: settings.filter, isDaily: false, dailyInfo: nil)
        activeGame = config
    }

    private func startDailyGame() {
        guard let daily = DailyPuzzleService.dailyImage(),
              let image = DailyPuzzleService.imageForDaily(daily) else {
            errorMessage = String(localized: "alert_error_message")
            showErrorAlert = true
            return
        }
        guard settings.canStartPuzzle(isUnlimited: store.hasUnlimited) else {
            showLimitAlert = true
            return
        }
        settings.registerPuzzleStart(isUnlimited: store.hasUnlimited)
        let config = GameConfig(image: image, difficulty: settings.difficulty, filter: settings.filter, isDaily: true, dailyInfo: daily)
        activeGame = config
    }

    private func bestTimeText() -> String {
        if let time = ScoreStore.bestTime(for: settings.difficulty) {
            return TimeFormatter.clockString(from: time)
        }
        return "--"
    }

    private func bestMovesText() -> String {
        if let moves = ScoreStore.bestMoves(for: settings.difficulty) {
            return "\(moves)"
        }
        return "--"
    }

    private func buyRemoveAds() async {
        guard let product = store.products.first(where: { $0.id == "photopuzzle.remove_ads_unlimited" }) else { return }
        _ = await store.purchase(product)
    }
}
