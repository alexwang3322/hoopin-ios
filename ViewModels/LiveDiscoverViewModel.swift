import Foundation
import Observation

/// Owns Discover's real-data fetch — one per screen's data needs, matching frontend's
/// hooks/useRuns.ts pattern (each screen owns its own fetch state; the server is the source of
/// truth, nothing shared/cached globally the way RunStore's mock data is).
@Observable
final class LiveDiscoverViewModel {
    var runs: [LiveRun] = []
    var isLoading = false
    var errorMessage: String?
    private var requestGeneration = UUID()

    func load(city: City, format: RunFormat?) async {
        let generation = UUID()
        requestGeneration = generation
        isLoading = true
        errorMessage = nil
        do {
            let wireRuns = try await LiveApiClient.getRuns(city: city.rawValue, format: format?.rawValue)
            guard !Task.isCancelled, requestGeneration == generation else { return }
            runs = wireRuns.map(LiveMappers.toLiveRun)
        } catch {
            guard !Task.isCancelled, requestGeneration == generation else { return }
            errorMessage = "Couldn't load runs. Pull to refresh to try again."
        }
        isLoading = false
    }
}
