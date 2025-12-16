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
    
    init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            count = try? container.decode(Int.self, forKey: .count)
            
            // page puede ser Int o String
            if let p = try? container.decode(Int.self, forKey: .page) {
                page = p
            } else if let pStr = try? container.decode(String.self, forKey: .page), let p = Int(pStr) {
                page = p
            } else {
                page = nil
            }

            if let pc = try? container.decode(Int.self, forKey: .pageCount) {
                pageCount = pc
            } else if let pcStr = try? container.decode(String.self, forKey: .pageCount), let pc = Int(pcStr) {
                pageCount = pc
            } else {
                pageCount = nil
            }

            if let ps = try? container.decode(Int.self, forKey: .pageSize) {
                pageSize = ps
            } else if let psStr = try? container.decode(String.self, forKey: .pageSize), let ps = Int(psStr) {
                pageSize = ps
            } else {
                pageSize = nil
            }

            products = (try? container.decode([ProductAPI].self, forKey: .products)) ?? []
        }
}
