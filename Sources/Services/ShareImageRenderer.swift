import SwiftUI

enum ShareImageRenderer {
    @MainActor
    static func render(image: UIImage, text: String) -> UIImage? {
        let view = ShareCardView(image: image, text: text)
        let renderer = ImageRenderer(content: view)
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage
    }
}

struct ShareCardView: View {
    let image: UIImage
    let text: String

    var body: some View {
        ZStack(alignment: .bottom) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 1024, height: 1024)
                .clipped()

            VStack(spacing: 8) {
                Text(text)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(radius: 6)
                Text(String(localized: "share_hashtag"))
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.9))
            }
            .padding(.bottom, 40)
        }
        .frame(width: 1024, height: 1024)
        .background(.black)
    }
}
