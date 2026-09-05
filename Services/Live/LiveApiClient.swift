import Foundation
import ClerkKit

/// Thin, read-only client for the two endpoints wired so far (GET /runs, GET /runs/{id}) —
/// mirrors frontend/src/services/apiClient.ts's shape (one function per contract endpoint,
/// typed against wire DTOs), not the full contract. Points at the deployed backend directly
/// (mobile-ios has no local-dev env-var mechanism like frontend/'s .env.local yet).
enum LiveApiClient {
    static let baseURL = URL(string: "https://hoopin-backend.alex-wang3322.workers.dev/v1")!

    enum ApiError: Error {
        case server(status: Int, code: String, message: String)
        case transport(Error)
        case decoding(Error)
    }

    private static func authorizedRequest(path: String, query: [URLQueryItem] = []) async -> URLRequest {
        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
        if !query.isEmpty { components.queryItems = query }
        var request = URLRequest(url: components.url!)

        // Public GET on runs is allowed signed-out (API_CONTRACT.md §5) — omit Authorization
        // entirely rather than send a request doomed to fail if there's no session.
        if let token = try? await Clerk.shared.session?.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }

    private static func send<T: Decodable>(_ request: URLRequest, as type: T.Type) async throws -> T {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw ApiError.transport(error)
        }

        guard let http = response as? HTTPURLResponse else {
            throw ApiError.transport(URLError(.badServerResponse))
        }

        guard (200..<300).contains(http.statusCode) else {
            if let wireError = try? JSONDecoder().decode(WireApiError.self, from: data) {
                throw ApiError.server(status: http.statusCode, code: wireError.error.code, message: wireError.error.message)
            }
            throw ApiError.server(status: http.statusCode, code: "UNKNOWN", message: "Request failed.")
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw ApiError.decoding(error)
        }
    }

    static func getRuns(city: String? = nil, format: String? = nil) async throws -> [WireRunSummary] {
        var query: [URLQueryItem] = []
        if let city { query.append(URLQueryItem(name: "city", value: city)) }
        if let format { query.append(URLQueryItem(name: "format", value: format)) }
        let request = await authorizedRequest(path: "runs", query: query)
        let page = try await send(request, as: WireCursorPage<WireRunSummary>.self)
        return page.items
    }

    static func getRun(id: String) async throws -> WireRunDetail {
        let request = await authorizedRequest(path: "runs/\(id)")
        return try await send(request, as: WireRunDetail.self)
    }
}
