import Foundation

struct ProductAPI: Codable {
    let id: String?
    let name: String?
    let image: String?
    let imageFrontSmall: String?
    let imageFront: String?
    let countries: String?
    let categories_tags: [String]?
        
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name = "product_name"
        case imageFrontSmall = "image_front_small_url"
        case imageFront = "image_front_url"
        case image = "image_url"
        case countries = "countries"
        case categories_tags = "categories_tags"
    }
    
    var bestImage: String?{
        return imageFrontSmall ?? imageFront ?? image
    }
}

struct ProductSearchResult: Codable {
    let count: Int?
    let page: Int?
    let pageCount: Int?
    let pageSize: Int?
    let products: [ProductAPI]

    enum CodingKeys: String, CodingKey {
        case count
        case page
        case pageCount = "page_count"
        case pageSize = "page_size"
        case products
    }
}
