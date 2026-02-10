import Foundation

enum ImageFilter: String, CaseIterable, Identifiable, Codable {
    case none
    case mono
    case sepia

    var id: String { rawValue }

    var displayKey: String {
        switch self {
        case .none: return "filter_none"
        case .mono: return "filter_mono"
        case .sepia: return "filter_sepia"
        }
    }
}
