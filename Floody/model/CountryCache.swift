import UIKit

class CountryCache {
    private let key = "cachedCountries"
    
    static let shared = CountryCache()
    
    func save(_ countries: [Country]) {
        let encoded = countries.map { ["name": $0.name, "flagURL": $0.flagURL] }
        UserDefaults.standard.set(encoded, forKey: key)
    }
    
    func load() -> [Country] {
        guard let array = UserDefaults.standard.array(forKey: key) as? [[String: String]] else {
            return []
        }
        
        return array.compactMap { dict in
            guard let name = dict["name"], let flagURL = dict["flagURL"] else { return nil }
            return Country(name: name, flagURL: flagURL)
        }
    }
}
