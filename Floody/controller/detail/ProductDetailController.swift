
import UIKit

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
    
    // Variable para recibir el código desde Search o Scanner
    var productCodeToFetch: String?
     
    override func viewDidLoad() {
        super.viewDidLoad()
         
        // Estado inicial de UI
        lblName.text = "Cargando..."
        cleanLabels()
         
        // Verificamos si nos pasaron un código
        if let code = productCodeToFetch {
            print("Detalle cargando código: \(code)")
            loadProductData(code: code)
        } else {
            // Fallback por seguridad
            print("Modo Prueba: No llegó código, usando default")
            loadProductData(code: "8410111211202")
        }
    }
     
    func cleanLabels() {
        lblEnergy.text = "-"
        lblSugar.text = "-"
        lblCarbs.text = "-"
        lblProteins.text = "-"
        lblFat.text = "-"
        lblSatFat.text = "-"
        lblSodium.text = "-"
        lblGluten.text = "-"
        lblOrigin.text = "-"
    }
     
    func loadProductData(code: String) {
        // Recuperamos el país seleccionado por el usuario en el inicio
        let country = UserDefaults.standard.string(forKey: "selectedCountry") ?? "Estados Unidos"
         
        ProductService.shared.fetchProduct(code: code, country: country) { [weak self] product in
            guard let self = self else { return }
             
            DispatchQueue.main.async {
                if let product = product {
                    self.populateUI(with: product)
                } else {
                    self.lblName.text = "Producto no encontrado"
                    self.cleanLabels()
                }
            }
        }
    }
     
    func populateUI(with product: Product) {
        // Textos
        lblName.text = product.name
        lblCategory.text = product.brand
        lblOrigin.text = product.countries
         
        // Nutrientes
        lblEnergy.text = product.calories
        lblSugar.text = product.sugar
        lblCarbs.text = product.carbohydrates
        lblProteins.text = product.proteins
        lblFat.text = product.totalFat
        lblSatFat.text = product.saturatedFat
        lblSodium.text = product.sodium
        lblGluten.text = product.hasGluten
         
        if product.imageName.hasPrefix("http") {
             if let url = URL(string: product.imageName) {
                URLSession.shared.dataTask(with: url) { data, _, _ in
                    if let data = data {
                        DispatchQueue.main.async {
                            self.imgProduct.image = UIImage(data: data)
                        }
                    }
                }.resume()
            }
        } else {
            self.imgProduct.image = UIImage(named: product.imageName)
        }
    }
     

    @IBAction func btnBackTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}
