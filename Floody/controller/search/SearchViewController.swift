import UIKit
import Lottie

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var lblSearch: UITextField!
    @IBOutlet weak var tableProduct: UITableView!
    
    @IBOutlet weak var uvEstado: UIView!
    @IBOutlet weak var ivEstado: UIImageView!
    @IBOutlet weak var lblEstado: UILabel!
    
    var selectedTipoFiltro: TipoFiltro = .alimentos
    
    var loadingAnimation: LottieAnimationView?
    
    var displayedProducts: [ProductAPI] = []
    
    var currentPage: Int = 1
    var currentQuery: String = ""
    
    var mensajeTemporal:String? = nil
    var isLoadingMore = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableProduct.dataSource = self
        tableProduct.delegate = self
        tableProduct.rowHeight = UITableView.automaticDimension
        
        lblSearch.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        
        mostrarEstadoInicial()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if displayedProducts.isEmpty { return 1 }
        return displayedProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if displayedProducts.isEmpty
        {
            let cell = UITableViewCell()
            cell.textLabel?.text = mensajeTemporal ?? "A SEGUNDOS DE MOSTRAR LOS PRODUCTOS"
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = .gray
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "productRow",
                                                 for: indexPath ) as! ProductCell
        let product = displayedProducts[indexPath.row]
        
        cell.nameLabel.text = product.name ?? "Sin nombre"
        cell.countriesLabel.text = "Países de venta: \(product.countries ?? "Desconcido")"
        
        if let imageUrl = product.bestImage, let url = URL(string: imageUrl){
            downloadImage(into: cell.productImageView, from: url)
        } else {
            cell.productImageView.image = UIImage(named:"no_image")
        }
        return cell
    }
    
    func downloadImage(into imageView: UIImageView,
                       from url:URL)
    {
        URLSession.shared.dataTask(with: url){
            data, _, error in
            guard let data = data, error == nil else { return }
            
            DispatchQueue.main.async{
                imageView.image = UIImage(data: data)
            }
        }.resume()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard !displayedProducts.isEmpty else { return }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailVC = storyboard.instantiateViewController(withIdentifier: "ProductDetailController") as? ProductDetailController {
            detailVC.productCodeToFetch = displayedProducts[indexPath.row].id
            detailVC.modalPresentationStyle = .fullScreen
            self.present(detailVC, animated: true)
            
        }
        
    }
    
    func mostrarEstadoInicial()
    {
        tableProduct.isHidden = true
        uvEstado.isHidden = false
        
        lblEstado.text = "¡REALICE UNA BÚSQUEDA!"
        ivEstado.isHidden = false
        loadingAnimation?.removeFromSuperview()
    }
    
    func mostrarEstadoCarga() {
        
        tableProduct.isHidden = true
        uvEstado.isHidden = false
        
        lblEstado.text = "CARGANDO BÚSQUEDA..."
        ivEstado.image = UIImage(named: "searchProd") //añadir
        
        loadingAnimation?.removeFromSuperview()
        
        let animation = LottieAnimationView(name: "loading")
        animation.translatesAutoresizingMaskIntoConstraints = false
        animation.contentMode = .scaleAspectFit
        animation.loopMode = .loop
        
        uvEstado.addSubview(animation)
        
        NSLayoutConstraint.activate([
            animation.centerXAnchor.constraint(equalTo: uvEstado.centerXAnchor),
            animation.centerYAnchor.constraint(equalTo: uvEstado.centerYAnchor),
            animation.widthAnchor.constraint(equalToConstant: 200),
            animation.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        animation.play()
        loadingAnimation = animation
    }
    
    
    func mostrarResultado()
    {
        uvEstado.isHidden = true
        tableProduct.isHidden = false
    }
    
    func ocultarEstadoCarga() {
        uvEstado.isHidden = true
        tableProduct.isHidden = false
        
        loadingAnimation?.stop()
        loadingAnimation?.removeFromSuperview()
        loadingAnimation = nil
    }
    
    func mostrarMensaje(_ mensaje: String)
    {
        mensajeTemporal = mensaje
        self.displayedProducts.removeAll()
        tableProduct.reloadData()
        mostrarResultado()
    }
    
    @objc func textDidChange()
    {
        guard let text = lblSearch.text, !text.isEmpty else {
            
            currentQuery = ""
            currentPage = 1
            displayedProducts.removeAll()
            
            tableProduct.reloadData()
            mostrarEstadoInicial()
            return
        }
    }
    
    func buscarPro(nombre: String) {

        ProductService.shared.searchProducts(
            query: nombre,
            page: currentPage,
            tipo: selectedTipoFiltro
        ) { products in

            DispatchQueue.main.async {

                self.ocultarEstadoCarga()

                if self.currentPage == 1 && products.isEmpty {
                    self.mostrarMensaje("Producto no encontrado")
                    self.ocultarEstadoCarga()
                    return
                }

                if products.isEmpty {
                    print("No hay más productos")
                    return
                }

                if self.currentPage == 1 {
                    self.displayedProducts = products
                } else {
                    self.displayedProducts += products
                }

                self.tableProduct.reloadData()
                self.mostrarResultado()
            }
        }
    }

    
    @IBAction func verMasTapped(_ sender: UIButton) {
        guard !isLoadingMore else { return }
        guard !currentQuery.isEmpty else { return }

        isLoadingMore = true
        currentPage += 1

        ProductService.shared.searchProducts(
            query: currentQuery,
            page: currentPage,
            tipo: selectedTipoFiltro
        ) { products in

            DispatchQueue.main.async {

                self.isLoadingMore = false

                if products.isEmpty {
                    print("No hay más productos")
                    return
                }

                self.displayedProducts += products
                self.tableProduct.reloadData()
            }
        }
    }

    @IBAction func btnLupa(_ sender: UIButton) {
            guard let text = lblSearch.text, !text.isEmpty else {
                mostrarEstadoInicial()
                return
            }

        currentQuery = text
        currentPage = 1
        displayedProducts.removeAll()
        mensajeTemporal = nil

        tableProduct.reloadData()
        mostrarEstadoCarga()
        buscarPro(nombre: text)
    }

    @IBAction func filtroTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "FilterViewController") as! FilterViewController
            vc.modalPresentationStyle = .overFullScreen
        
            vc.delegate = self
            vc.selectedTipo = selectedTipoFiltro
            present(vc, animated: true)
    }
    
}

extension SearchViewController: FilterDelegate {
    func didSelectFilter(_ tipo: TipoFiltro) {

        selectedTipoFiltro = tipo
        currentPage = 1
        displayedProducts.removeAll()

        guard !currentQuery.isEmpty else { return }

        mostrarEstadoCarga()
        buscarPro(nombre: currentQuery)
    }
}

