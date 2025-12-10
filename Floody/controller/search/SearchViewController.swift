import UIKit
import Lottie

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var lblSearch: UITextField!
    @IBOutlet weak var tableProduct: UITableView!
    
    // View Loading
    @IBOutlet weak var uvEstado: UIView!
    @IBOutlet weak var ivEstado: UIImageView!
    @IBOutlet weak var lblEstado: UILabel!
    
    @IBOutlet weak var viewLoading: UIView!
    @IBOutlet weak var btnVerMas: UIButton!
    
    // View No Disponible
    @IBOutlet weak var lblDisponibilidad: UILabel!
    @IBOutlet weak var ivMundo: UIImageView!
    @IBOutlet weak var btnVerPorMundo: UIButton!
    @IBOutlet weak var viewDisponibilidad: UIView!
    
    var selectedCountry: String? {
        return UserDefaults.standard.string(forKey: "selectedCountry")
    }
    var buscarEnTodoElMundo = false
    
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
        
        viewDisponibilidad.isHidden = true
        btnVerMas.isHidden = true
        btnVerPorMundo.isHidden = true
        
        mostrarEstadoInicial()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.bringSubviewToFront(uvEstado)
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if displayedProducts.isEmpty && mensajeTemporal !=  nil { return 1 }
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
    
    // MARK: FUNCIONES
    
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
        mensajeTemporal = nil
        displayedProducts.removeAll()
        
        tableProduct.isHidden = true
        uvEstado.isHidden = false
        ocultarNoDisponiblePais()
        
        lblEstado.text = "¡REALICE UNA BÚSQUEDA!"
        ivEstado.isHidden = false
        
        loadingAnimation?.removeFromSuperview()
    }
    
    func mostrarEstadoCarga() {
        
        mensajeTemporal = nil
        
        tableProduct.isHidden = true
        uvEstado.isHidden = false
        ocultarNoDisponiblePais()
        
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
    
    func ocultarEstadoCarga() {
        uvEstado.isHidden = true
        tableProduct.isHidden = false
        
        loadingAnimation?.stop()
        loadingAnimation?.removeFromSuperview()
        loadingAnimation = nil
    }
    
    func mostrarResultado()
    {
        viewDisponibilidad.isHidden = true
        uvEstado.isHidden = true
        
        tableProduct.isHidden = false
        tableProduct.superview?.bringSubviewToFront(tableProduct)
        
        if displayedProducts.count >= 10 {
            tableProduct.isHidden = false
        } else {
            btnVerMas.isHidden = true
        }
    }
    
    func mostrarMensaje(_ mensaje: String)
    {
        mensajeTemporal = mensaje
        self.displayedProducts.removeAll()
        
        tableProduct.isHidden = false
        uvEstado.isHidden = true
        viewDisponibilidad.isHidden = true
        
        tableProduct.reloadData()
        tableProduct.superview?.bringSubviewToFront(tableProduct)
        
        btnVerMas.isHidden = true
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
    
    func mostrarNoDisponiblePais() {
        tableProduct.isHidden = true
        uvEstado.isHidden = true
        btnVerMas.isHidden = true

        viewDisponibilidad.isHidden = false
        btnVerPorMundo.isHidden = false
        
        loadingAnimation?.stop()
        loadingAnimation?.removeFromSuperview()
        loadingAnimation = nil
    }

    func ocultarNoDisponiblePais() {
        viewDisponibilidad.isHidden = true
        btnVerMas.isHidden = false
        btnVerPorMundo.isHidden = true
    }
    
    func buscarPro(nombre: String) {

        let pais = buscarEnTodoElMundo ? nil : selectedCountry

        ProductService.shared.searchProducts(
            query: nombre,
            page: currentPage,
            tipo: selectedTipoFiltro,
            country: pais
        ) { products in

            DispatchQueue.main.async {

                // ✅ RESETEAR AL TERMINAR LA BÚSQUEDA
                let fueBusquedaGlobal = self.buscarEnTodoElMundo
                self.buscarEnTodoElMundo = false

                // Caso1. No hay productos en este pais
                if self.currentPage == 1 && products.isEmpty && !fueBusquedaGlobal {
                    self.mostrarNoDisponiblePais()
                    return
                }

                // Caso2. No hay producto en el mundo
                if self.currentPage == 1 && products.isEmpty && fueBusquedaGlobal {
                    self.mostrarMensaje("Producto no encontrado")
                    self.btnVerMas.isHidden = true
                    return
                }

                // Caso3. Si hay productos
                self.ocultarEstadoCarga()

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
    
    func setEstadoNoDisponible() {
        tableProduct.isHidden = true
        uvEstado.isHidden = true
        btnVerMas.isHidden = true

        viewDisponibilidad.isHidden = false
        btnVerPorMundo.isHidden = false
    }

    // MARK: Botones de la View
    
    @IBAction func verMasTapped(_ sender: UIButton) {
        guard !isLoadingMore else { return }
        guard !currentQuery.isEmpty else { return }

        isLoadingMore = true
        currentPage += 1

        let pais = buscarEnTodoElMundo ? nil : selectedCountry

        ProductService.shared.searchProducts(
            query: currentQuery,
            page: currentPage,
            tipo: selectedTipoFiltro,
            country: pais
        ) { products in

            DispatchQueue.main.async {

                self.isLoadingMore = false

                if products.isEmpty {
                    self.btnVerMas.isHidden = true
                    return
                } else {
                    self.btnVerMas.isHidden = false
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

        buscarEnTodoElMundo = false
        
        currentQuery = text
        currentPage = 1
        
        mensajeTemporal = nil
        displayedProducts.removeAll()

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
    
    @IBAction func btnBuscarTodoMundo(_ sender: Any) {
        guard let text = lblSearch.text, !text.isEmpty else { return }
        
        buscarEnTodoElMundo = true
        currentQuery = text
        currentPage = 1
        
        mensajeTemporal = nil
        displayedProducts.removeAll()
        
        mostrarEstadoCarga()
        buscarPro(nombre: text)
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

// Original Taste – Coca-Cola – 1 l
