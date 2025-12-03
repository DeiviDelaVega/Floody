import Foundation

final class ProductService {

    static let shared = ProductService()
    private init() {}

    func fetchProduct(
        code: String,
        country: String,
        completion: @escaping (Product?) -> Void
    ) {

        let regionCode = CountryRegionMapper.map(country)
        let regionURL = "https://\(regionCode).openfoodfacts.org/api/v0/product/\(code).json"

        fetchFromURL(regionURL, code: code) { product in
            if let product = product {
                completion(product)
            } else {
                //Fallback automático a WORLD si no existe en la región
                let worldURL = "https://world.openfoodfacts.org/api/v0/product/\(code).json"

                self.fetchFromURL(worldURL, code: code) { fallbackProduct in
                    completion(fallbackProduct)
                }
            }
        }
    }

    // MARK: - Private helper
    private func fetchFromURL(
        _ urlString: String,
        code: String,
        completion: @escaping (Product?) -> Void
    ) {

        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in

            guard
                error == nil,
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let productData = json["product"] as? [String: Any]
            else {
                completion(nil)
                return
            }

            let name = productData["product_name"] as? String ?? "-"
            let brand = productData["brands"] as? String ?? "-"

            let nutriments = productData["nutriments"] as? [String: Any]
            let calories = nutriments?["energy-kcal_100g"].map { "\($0)" } ?? "-"

            let product = Product(
                code: code,
                name: name,
                brand: brand,
                calories: calories
            )

            completion(product)

        }.resume()
    }
}
