import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

enum ImageProcessing {
    static func applyFilter(image: UIImage, filter: ImageFilter) -> UIImage {
        switch filter {
        case .none:
            return image
        case .mono, .sepia:
            break
        }

        guard let ciImage = CIImage(image: image) else { return image }
        let context = CIContext()

        let output: CIImage?
        switch filter {
        case .mono:
            let filter = CIFilter.photoEffectMono()
            filter.inputImage = ciImage
            output = filter.outputImage
        case .sepia:
            let filter = CIFilter.sepiaTone()
            filter.intensity = 0.9
            filter.inputImage = ciImage
            output = filter.outputImage
        case .none:
            output = ciImage
        }

        guard let result = output, let cgImage = context.createCGImage(result, from: result.extent) else {
            return image
        }

        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }

    static func splitImage(image: UIImage, grid: Int) -> [UIImage] {
        let cropped = squareCrop(image: image)
        guard let cgImage = cropped.cgImage else { return [] }

        let width = cgImage.width
        let height = cgImage.height
        let tileWidth = width / grid
        let tileHeight = height / grid

        var pieces: [UIImage] = []
        pieces.reserveCapacity(grid * grid)

        for row in 0..<grid {
            for col in 0..<grid {
                let rect = CGRect(
                    x: col * tileWidth,
                    y: row * tileHeight,
                    width: tileWidth,
                    height: tileHeight
                )
                if let tileCg = cgImage.cropping(to: rect) {
                    let tile = UIImage(cgImage: tileCg, scale: image.scale, orientation: image.imageOrientation)
                    pieces.append(tile)
                }
            }
        }

        return pieces
    }

    static func squareCrop(image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else { return image }
        // Center-crop to square to avoid stretching when building the grid.
        let width = cgImage.width
        let height = cgImage.height
        let side = min(width, height)
        let x = (width - side) / 2
        let y = (height - side) / 2
        let rect = CGRect(x: x, y: y, width: side, height: side)
        guard let cropped = cgImage.cropping(to: rect) else { return image }
        return UIImage(cgImage: cropped, scale: image.scale, orientation: image.imageOrientation)
    }
}
