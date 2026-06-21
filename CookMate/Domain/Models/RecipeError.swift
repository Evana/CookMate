import Foundation

enum RecipeError: Error {
    case fileNotFound
    case decodingFailed
    case networkError
    case unexpectedStatusCode(Int)
}

extension RecipeError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .fileNotFound:                   "Recipe data could not be found."
        case .decodingFailed:                 "Recipe data appears to be corrupted."
        case .networkError:                   "A network error occurred. Please try again."
        case .unexpectedStatusCode(let code): "The server returned an unexpected response (\(code))."
        }
    }
}
