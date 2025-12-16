import UIKit

class SavedController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var tvProductSaved: UICollectionView!
    
    var savedList: [Product] = []

        override func viewDidLoad() {
            super.viewDidLoad()
            tvProductSaved.delegate = self
            tvProductSaved.dataSource = self
            
            loadSavedProducts()
        }
        
        func loadSavedProducts() {
            // Escucha cambios en tiempo real
            SavedService.shared.fetchSavedProducts { [weak self] products in
                self?.savedList = products
                self?.tvProductSaved.reloadData()
            }
        }

        // MARK: - CollectionView Data Source
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return savedList.count
        }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productCell", for: indexPath) as! ProductCollectionCell
            
            let product = savedList[indexPath.row]
            
            cell.lblNameProduct.text = product.name
            cell.lblOriginProduct.text = product.countries
            cell.onSaveTapped = { [weak self] in
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                SavedService.shared.toggleSavedProduct(product: product) { _ in
                    print("Producto eliminado de guardados: \(product.name)")
                }
            }
            
            cell.ivProduct.image = UIImage(named: "no_image")
            if product.imageName.hasPrefix("http"), let url = URL(string: product.imageName) {
                URLSession.shared.dataTask(with: url) { data, _, _ in
                    if let data = data {
                        DispatchQueue.main.async { cell.ivProduct.image = UIImage(data: data) }
                    }
                }.resume()
            } else {
                 cell.ivProduct.image = UIImage(named: product.imageName)
            }
            
            return cell
        }
        
        // MARK: - Navegación al Detalle
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let product = savedList[indexPath.row]
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let detailVC = storyboard.instantiateViewController(withIdentifier: "ProductDetailController") as? ProductDetailController {
                
                // Pasamos el código para que el detalle vuelva a cargar la info completa
                detailVC.productCodeToFetch = product.code
                detailVC.modalPresentationStyle = .fullScreen
                self.present(detailVC, animated: true)
            }
        }

        // MARK: - Layout (Tus medidas originales)
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: 15, left: 15, bottom: 10, right: 15)
        }

        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: 110, height: 170)
        }
    
    
   
}
