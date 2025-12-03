struct CountryRegionMapper {
    static func map(_ country: String) -> String {
        switch country {
        case "Perú": return "pe"
        case "Estados Unidos": return "us"
        case "España": return "es"
        case "Francia": return "fr"
        case "Canadá": return "ca"
        case "Japón": return "jp"
        case "China": return "cn"
        case "Brasil": return "br"
        case "México": return "mx"
        case "Italia": return "it"
        default: return "world"
        }
    }
}
