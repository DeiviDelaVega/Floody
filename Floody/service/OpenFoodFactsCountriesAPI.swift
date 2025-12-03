import Foundation

class OpenFoodFactsCountriesAPI {
    static let shared = OpenFoodFactsCountriesAPI()

    private init() {}

    func fetchCountries(completion: @escaping ([String]) -> Void) {
        let urlString = "https://world.openfoodfacts.org/countries.json"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let tags = json["tags"] as? [[String: Any]] {

                    let countries = tags.compactMap { $0["name"] as? String }
                    completion(countries)
                }
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }.resume()
    }
}
