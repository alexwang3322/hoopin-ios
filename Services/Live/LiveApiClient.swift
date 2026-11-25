import Foundation
import ClerkKit

/// Thin client for the endpoints wired so far —
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

    private static func authenticatedRequest(path: String, userId: String) async throws -> URLRequest {
        guard let session = await Clerk.shared.session, session.user?.id == userId,
              let token = try await session.getToken() else {
            throw ApiError.server(status: 401, code: "SESSION_CHANGED", message: "Please sign in again.")
        }
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
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

    static func getUser(id: String) async throws -> WireUserSummary {
        let request = URLRequest(url: baseURL.appendingPathComponent("users/\(id)"))
        return try await send(request, as: WireUserSummary.self)
    }

    static func getMe(userId: String) async throws -> WireAccountProfile {
        let request = try await authenticatedRequest(path: "me", userId: userId)
        return try await send(request, as: WireAccountProfile.self)
    }

    static func updateMe(_ body: WireUpdateAccountRequest, userId: String) async throws -> WireAccountProfile {
        var request = try await authenticatedRequest(path: "me", userId: userId)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        return try await send(request, as: WireAccountProfile.self)
    }

    static func getMyRequests() async throws -> [WireJoinRequestWithRun] {
        var items: [WireJoinRequestWithRun] = []
        var cursor: String?
        repeat {
            let query = cursor.map { [URLQueryItem(name: "cursor", value: $0)] } ?? []
            let request = await authorizedRequest(path: "me/requests", query: query)
            let page = try await send(request, as: WireCursorPage<WireJoinRequestWithRun>.self)
            items.append(contentsOf: page.items)
            cursor = page.nextCursor
        } while cursor != nil
        return items
    }

    static func getHosting() async throws -> [WireRunSummary] {
        var items: [WireRunSummary] = []
        var cursor: String?
        repeat {
            let query = cursor.map { [URLQueryItem(name: "cursor", value: $0)] } ?? []
            let request = await authorizedRequest(path: "me/hosting", query: query)
            let page = try await send(request, as: WireCursorPage<WireRunSummary>.self)
            items.append(contentsOf: page.items)
            cursor = page.nextCursor
        } while cursor != nil
        return items
    }

    static func createRun(_ body: WireCreateRunRequest) async throws -> WireRunDetail {
        var request = await authorizedRequest(path: "runs")
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        return try await send(request, as: WireRunDetail.self)
    }

    static func updateRun(id: String, body: WireCreateRunRequest) async throws -> WireRunDetail {
        var request = await authorizedRequest(path: "runs/\(id)")
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        return try await send(request, as: WireRunDetail.self)
    }

    static func cancelRun(id: String, userId: String) async throws -> WireRunDetail {
        var request = try await authenticatedRequest(path: "runs/\(id)/cancel", userId: userId)
        request.httpMethod = "POST"
        return try await send(request, as: WireRunDetail.self)
    }
}
