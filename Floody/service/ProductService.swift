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
            let countries = productData["countries"] as? String ?? "Mundial"
            let imageURL = productData["image_url"] as? String ?? "no_image"


            let nutriments = productData["nutriments"] as? [String: Any]
            let calories = nutriments?["energy-kcal_100g"].map { "\($0)" } ?? "-"
            let sugar = nutriments?["sugars_100g"].map { "\($0) g" } ?? "-"
            let carbs = nutriments?["carbohydrates_100g"].map { "\($0) g" } ?? "-"
            let proteins = nutriments?["proteins_100g"].map { "\($0) g" } ?? "-"
            let fat = nutriments?["fat_100g"].map { "\($0) g" } ?? "-"
            let satFat = nutriments?["satured_fat_100g"].map { "\($0) g" } ?? "-"
            let sodium = nutriments?["sodium_100g"].map { "\($0) g" } ?? "-"
            let ingredientsText = (productData["ingredients_text"] as? String ?? "").lowercased()
            let hasGluten = ingredientsText.contains("gluten") || ingredientsText.contains("trigo") ? "Contiene Gluten" : "Sin Gluten detectado"


            let product = Product(
                code: code,
                name: name,
                countries: countries,
                imageName: imageURL,
                brand: brand,
                calories: calories,
                sugar: sugar,
                carbohydrates: carbs,
                proteins: proteins,
                totalFat: fat,
                saturatedFat: satFat,
                sodium: sodium,
                hasGluten: hasGluten
            )

            completion(product)

        }.resume()
    }
    
    // MARK: - SearchProduct
   
        func searchProducts(
            query: String,
            page: Int,
            tipo: TipoFiltro,
            completion: @escaping ([ProductAPI]) -> Void
        ) {

            let queryEncoded =
                query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

            var urlString: String

            switch tipo {

            case .alimentos:
                urlString =
                "https://world.openfoodfacts.org/cgi/search.pl?search_terms=\(queryEncoded)&search_simple=1&action=process&json=1&page=\(page)&page_size=10"

            case .animales:
                let categoria = "en:pet-food"
                urlString =
                "https://world.openfoodfacts.org/cgi/search.pl?search_terms=\(queryEncoded)&tagtype_0=categories&tag_contains_0=contains&tag_0=\(categoria)&search_simple=1&action=process&json=1&page=\(page)&page_size=10"
            }

            print("URL FINAL ➜", urlString)

            guard let url = URL(string: urlString) else {
                completion([])
                return
            }

            URLSession.shared.dataTask(with: url) { data, _, error in
                guard let data = data, error == nil else {
                    completion([])
                    return
                }

                do {
                    let result = try JSONDecoder().decode(ProductSearchResult.self, from: data)
                    completion(result.products)
                } catch {
                    print("❌ Error decoding:", error)
                    completion([])
                }
            }.resume()
        }
}


