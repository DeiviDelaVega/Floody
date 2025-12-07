import UIKit
import FirebaseAuth

class ProductDetailController: UIViewController {
    @IBOutlet weak var imgProduct: UIImageView!
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblQuantity: UILabel!
    
    @IBOutlet weak var lblEnergy: UILabel!
    @IBOutlet weak var lblSugar: UILabel!
    @IBOutlet weak var lblCarbs: UILabel!
    @IBOutlet weak var lblProteins: UILabel!
    @IBOutlet weak var lblFat: UILabel!
    @IBOutlet weak var lblSatFat: UILabel!
    @IBOutlet weak var lblSodium: UILabel!
    
    @IBOutlet weak var lblGluten: UILabel!
    @IBOutlet weak var lblOrigin: UILabel!
    
    @IBOutlet weak var btnSave: UIButton!
    
    var productCodeToFetch: String?
        
        // Variable auxiliar para mantener el objeto completo
        private var currentProduct: Product?

        override func viewDidLoad() {
            super.viewDidLoad()
            
            lblName.text = "Cargando..."
            cleanLabels()
            
            // Verificar estado inicial del botón guardar
            if let code = productCodeToFetch {
                checkIfSaved(code: code)
                loadProductData(code: code)
            } else {
                // Fallback prueba
                loadProductData(code: "8410111211202")
            }
        }
        
        func cleanLabels() {
            lblEnergy.text = "-"; lblSugar.text = "-"; lblCarbs.text = "-"
            lblProteins.text = "-"; lblFat.text = "-"; lblSatFat.text = "-"
            lblSodium.text = "-"; lblGluten.text = "-"; lblOrigin.text = "-"
        }
        
        // Verificar si ya está guardado para pintar el icono correcto
        func checkIfSaved(code: String) {
            SavedService.shared.isProductSaved(barcode: code) { [weak self] isSaved in
                self?.updateSaveButtonIcon(isSaved: isSaved)
            }
        }
        
        func updateSaveButtonIcon(isSaved: Bool) {
            let iconName = isSaved ? "bookmark.fill" : "bookmark" // Usa nombres SF Symbols
            let image = UIImage(systemName: iconName)
            DispatchQueue.main.async {
                self.btnSave.setImage(image, for: .normal)
                // Opcional: Cambiar color si quieres
                self.btnSave.tintColor = isSaved ? .systemYellow : .darkGray
            }
        }

        func loadProductData(code: String) {
            let country = UserDefaults.standard.string(forKey: "selectedCountry") ?? "Estados Unidos"
            
            ProductService.shared.fetchProduct(code: code, country: country) { [weak self] product in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    if let product = product {
                        self.currentProduct = product // Guardamos referencia
                        self.populateUI(with: product)
                        self.saveToHistoryLogic(product: product)
                    } else {
                        self.lblName.text = "Producto no encontrado"
                    }
                }
            }
        }
        
        func populateUI(with product: Product) {
            lblName.text = product.name
            lblCategory.text = product.brand
            lblOrigin.text = product.countries
            
            lblEnergy.text = product.calories
            lblSugar.text = product.sugar
            lblCarbs.text = product.carbohydrates
            lblProteins.text = product.proteins
            lblFat.text = product.totalFat
            lblSatFat.text = product.saturatedFat
            lblSodium.text = product.sodium
            lblGluten.text = product.hasGluten
            
            // Carga de imagen
            if product.imageName.hasPrefix("http"), let url = URL(string: product.imageName) {
                URLSession.shared.dataTask(with: url) { data, _, _ in
                    if let data = data {
                        DispatchQueue.main.async { self.imgProduct.image = UIImage(data: data) }
                    }
                }.resume()
            } else {
                self.imgProduct.image = UIImage(named: product.imageName)
            }
        }
        
        func saveToHistoryLogic(product: Product) {
            let imageURL = product.imageName.hasPrefix("http") ? product.imageName : ""
            let historyItem = ProductHistory(
                barcode: product.code,
                name: product.name,
                imageUrl: imageURL,
                category: product.category
            )
            HistoryService.shared.saveToHistory(product: historyItem)
        }

    @IBAction func btnBackTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnSaved(_ sender: UIButton) {
        guard let product = currentProduct else { return }
                
                // Feedback háptico (vibración ligera)
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                
                SavedService.shared.toggleSavedProduct(product: product) { [weak self] isNowSaved in
                    self?.updateSaveButtonIcon(isSaved: isNowSaved)
                }
    }
}
