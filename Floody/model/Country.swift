import UIKit

struct Country {
    let name: String
    let flagURL: String
}

extension Country {
    static let allowedCountries: [String] = [
        "Peru",
        "United States",
        "Spain",
        "France",
        "Canada",
        "Japan",
        "China",
        "Brazil",
        "Mexico",
        "Italy"
    ]
    
    var translatedName: String {
        let translations: [String: String] = [
            "Peru": "Perú",
            "United States": "Estados Unidos",
            "Spain": "España",
            "France": "Francia",
            "Canada": "Canadá",
            "Japan": "Japón",
            "China": "China",
            "Brazil": "Brasil",
            "Mexico": "México",
            "Italy": "Italia"
        ]
        return translations[name] ?? name
    }
}
