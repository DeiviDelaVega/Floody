import Foundation

extension Product {
    init(api: ProductAPI) {
        self.init(
            code: api.id ?? "",
            name: api.name ?? "Sin nombre",
            countries: api.countries ?? "No especificado",
            imageName: api.bestImage ?? "no_image",
            brand: "Sin marca",
            calories: "-",
            sugar: "-",
            carbohydrates: "-",
            proteins: "-",
            totalFat: "-",
            saturatedFat: "-",
            sodium: "-",
            hasGluten: "Desconocido",
            category: api.categories_tags?.joined(separator: ", ") ?? "General"
        )
    }
}
