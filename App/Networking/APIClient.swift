import Foundation

enum APIError: Error, LocalizedError {
    case endpointUnavailable(String)
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .endpointUnavailable(let reason):
            return reason
        case .invalidResponse:
            return "The server returned an invalid response."
        }
    }
}

struct EmptyRequest: Codable {}
struct EmptyResponse: Codable {}

final class APIClient {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func send<Request: Encodable, Response: Decodable>(
        _ request: Request,
        to endpoint: URL,
        method: String = "POST"
    ) async throws -> Response {
        var urlRequest = URLRequest(url: endpoint)
        urlRequest.httpMethod = method
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)

        let (data, response) = try await session.data(for: urlRequest)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw APIError.invalidResponse
        }
        return try JSONDecoder().decode(Response.self, from: data)
    }
}
