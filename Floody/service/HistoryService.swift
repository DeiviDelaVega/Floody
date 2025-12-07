import Foundation
import FirebaseDatabase
import FirebaseAuth

class HistoryService {
    static let shared = HistoryService()
    private init() {}
    
    private var ref: DatabaseReference {
        Database.database().reference()
    }
    
    private var userId: String {
        return Auth.auth().currentUser?.uid ?? "unknown"
    }
    
    // MARK: Guarda SOLO en historial
    func saveToHistory(product: ProductHistory) {
        let path = "Users/\(userId)/history/\(product.barcode)"
        
        let values: [String: Any] = [
            "name": product.name,
            "imageUrl": product.imageUrl,
            "category": product.category
        ]
        
        ref.child(path).setValue(values)
    }
    
    // MARK: Obtener historial
    func fetchHistory(completion: @escaping ([ProductHistory]) -> Void) {
        ref.child("Users/\(userId)/history")
            .observe(.value) { snapshot in
                
                var result: [ProductHistory] = []
                
                for child in snapshot.children {
                    if let snap = child as? DataSnapshot,
                       let dict = snap.value as? [String: Any],
                       let name = dict["name"] as? String,
                       let imageUrl = dict["imageUrl"] as? String,
                       let category = dict["category"] as? String {
                        
                        result.append(
                            ProductHistory(
                                barcode: snap.key,
                                name: name,
                                imageUrl: imageUrl,
                                category: category
                            )
                        )
                    }
                }
                
                result.sort { $0.name.lowercased() < $1.name.lowercased() }
                DispatchQueue.main.async {
                    completion(result)
                }
            }
    }
}
