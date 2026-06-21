import Foundation

enum RecipeError: Error {
    case fileNotFound
    case decodingFailed
}

extension RecipeError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .fileNotFound: "Recipe data could not be found."
        case .decodingFailed: "Recipe data appears to be corrupted."
        }
    }
}
