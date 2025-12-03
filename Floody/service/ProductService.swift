import Foundation

final class ProductService {

    static let shared = ProductService()

    private init() {}

    func fetchProduct(code: String, completion: @escaping (Product?) -> Void) {

        let urlString = "https://world.openfoodfacts.org/api/v0/product/\(code).json"
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
