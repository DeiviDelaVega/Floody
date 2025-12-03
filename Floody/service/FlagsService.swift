import Foundation

class FlagsService {

    static let shared = FlagsService()
    private var flags: [String: String] = [:]

    private init() {
        loadLocalFlags()
    }

    private func loadLocalFlags() {
        if let url = Bundle.main.url(forResource: "CountriesFlags", withExtension: "json"),
           let data = try? Data(contentsOf: url) {
            flags = (try? JSONDecoder().decode([String: String].self, from: data)) ?? [:]
        }
    }

    func flagURL(for country: String) -> String? {
        return flags[country]
    }
}
