import Foundation
import FirebaseDatabase
import FirebaseAuth

class SavedService {
    static let shared = SavedService()
    private init() {}
    
    private var ref: DatabaseReference {
        Database.database().reference()
    }
    
    private var userId: String? {
        return Auth.auth().currentUser?.uid
    }
    
    // MARK: - Guardar / Borrar (Toggle)
    
    func toggleSavedProduct(product: Product, completion: @escaping (Bool) -> Void) {
        guard let uid = userId, !product.code.isEmpty else {
            completion(false)
            return
        }
        
        let path = "Users/\(uid)/saved/\(product.code)"
        let productRef = ref.child(path)
        
        productRef.observeSingleEvent(of: .value) { [weak self] snapshot in
            if snapshot.exists() {
                // Si ya existe, lo BORRAMOS (Desmarcar)
                productRef.removeValue { error, _ in
                    completion(false) // Retorna false (no guardado)
                }
            } else {
                // Si no existe, lo GUARDAMOS
                let values: [String: Any] = [
                    "name": product.name,
                    "imageUrl": product.imageName, // Asegúrate de guardar la URL si es http
                    "countries": product.countries,
                    "brand": product.brand,
                    "timestamp": ServerValue.timestamp()
                ]
                productRef.setValue(values) { error, _ in
                    completion(true) // Retorna true (guardado)
                }
            }
        }
    }
    
    // MARK: - Verificar estado (para el icono)
    func isProductSaved(barcode: String, completion: @escaping (Bool) -> Void) {
        guard let uid = userId else { completion(false); return }
        
        ref.child("Users/\(uid)/saved/\(barcode)").observeSingleEvent(of: .value) { snapshot in
            completion(snapshot.exists())
        }
    }
    
    // MARK: - Obtener todos los guardados
    func fetchSavedProducts(completion: @escaping ([Product]) -> Void) {
        guard let uid = userId else { completion([]); return }
        
        ref.child("Users/\(uid)/saved").observe(.value) { snapshot in
            var savedList: [Product] = []
            
            for child in snapshot.children {
                if let snap = child as? DataSnapshot,
                   let dict = snap.value as? [String: Any] {
                    
                    var prod = Product()
                    prod.code = snap.key // El código es la llave
                    prod.name = dict["name"] as? String ?? "Desconocido"
                    prod.imageName = dict["imageUrl"] as? String ?? "no_image"
                    prod.countries = dict["countries"] as? String ?? "-"
                    prod.brand = dict["brand"] as? String ?? "-"
                    
                    savedList.append(prod)
                }
            }
            // Ordenar por nombre (opcional)
            savedList.sort { $0.name < $1.name }
            
            DispatchQueue.main.async {
                completion(savedList)
            }
        }
    }
}
