import UIKit
import FirebaseDatabase
import FirebaseAuth

class HistoricalController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var scCategoria: UISegmentedControl!
    @IBOutlet weak var tvProducto: UITableView!
    @IBOutlet weak var txtNombreProducto: UITextField!
    @IBOutlet weak var viewEmptyState: UIView!
    
    private var items: [ProductHistory] = []
    private var filteredItems: [ProductHistory] = []
    private var sectionLetters: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fontSegmentedControl()
        scCategoria.selectedSegmentIndex = 1
        applyFilters()
        
        tvProducto.dataSource = self
        tvProducto.delegate = self
        tvProducto.showsVerticalScrollIndicator = false
        tvProducto.backgroundColor = .white
        
        loadHistory()
        txtNombreProducto.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    // MARK: - Estado vacío para ver mensaje
    private func updateEmptyState() {
        let isFilteredItemsEmpty = filteredItems.isEmpty
        tvProducto.isHidden = isFilteredItemsEmpty
        viewEmptyState.isHidden = !isFilteredItemsEmpty
    }
    
    // MARK: Filtro de segmented control y text field
    private func applyFilters(searchText: String = "") {
        var tempItems: [ProductHistory]
        switch scCategoria.selectedSegmentIndex {
        case 0: // Alimentos
            tempItems = items.filter { $0.category == "Alimentos" }
        case 2: // Animales
            tempItems = items.filter { $0.category == "Animales" }
        default: // TODO
            tempItems = items
        }
        
        if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let lowerSearch = searchText.lowercased()
            tempItems = tempItems.filter { $0.name.lowercased().contains(lowerSearch) }
        }
        
        filteredItems = tempItems
        buildSections()
        tvProducto.reloadData()
        updateEmptyState()
    }

    
    // MARK: Crear una lista ordenada de las letras iniciales únicas
    private func buildSections() {
        sectionLetters = Array(Set(
            filteredItems.map { String($0.name.prefix(1)).uppercased() }
        )).sorted()
    }
    
    // MARK: Cargar Historial
    private func loadHistory() {
        HistoryService.shared.fetchHistory { data in
            self.items = data
            self.filteredItems = data
            self.buildSections()

            DispatchQueue.main.async {
                self.tvProducto.reloadData()
                self.updateEmptyState()
            }
        }
    }
    
    // MARK: Funcionamiento de la vista
    @IBAction func textFieldDidChange(_ sender: UITextField) {
        applyFilters(searchText: txtNombreProducto.text ?? "")
    }
    
    @IBAction func scCategoriaChanged(_ sender: UISegmentedControl) {
        applyFilters(searchText: txtNombreProducto.text ?? "")
    }
    
    @IBAction func btnEliminar(_ sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint.zero, to: tvProducto)
        guard let indexPath = tvProducto.indexPathForRow(at: buttonPosition) else { return }
        
        let letter = sectionLetters[indexPath.section]
        let productsInSection = filteredItems.filter { $0.name.prefix(1).uppercased() == letter }
        let product = productsInSection[indexPath.row]
        
        if let indexInItems = items.firstIndex(where: { $0.barcode == product.barcode }) {
            items.remove(at: indexInItems)
        }
        
        filteredItems.removeAll { $0.barcode == product.barcode }
        
        buildSections()
        tvProducto.reloadData()
        updateEmptyState()
        
        let ref = Database.database().reference()
        if let userId = Auth.auth().currentUser?.uid {
            ref.child("Users/\(userId)/history/\(product.barcode)").removeValue { error, _ in
                if let error = error {
                    print("Error al eliminar de Firebase: \(error)")
                } else {
                    print("Producto eliminado correctamente de Firebase")
                }
            }
        }
    }
    
    // MARK: Diseño de scCategoria
    func fontSegmentedControl() {
        let font = UIFont(name: "Poppins-ExtraBold", size: 16.0)!
        let atributosNormal: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.lightGray
        ]
        
        let atributosSeleccionado: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.darkGray
        ]
        
        scCategoria.setTitleTextAttributes(atributosNormal, for: .normal)
        scCategoria.setTitleTextAttributes(atributosSeleccionado, for: .selected)
    }
    
    // MARK: - Selección de celda para ver detalle
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let letter = sectionLetters[indexPath.section]
        let productsInSection = filteredItems.filter {
            $0.name.prefix(1).uppercased() == letter
        }
        
        guard indexPath.row < productsInSection.count else { return }
        let product = productsInSection[indexPath.row]
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailVC = storyboard.instantiateViewController(withIdentifier: "ProductDetailController") as? ProductDetailController {
            detailVC.productCodeToFetch = product.barcode
            detailVC.modalPresentationStyle = .fullScreen
            self.present(detailVC, animated: true)
        }
    }
    
    // MARK: - TABLEVIEW secciones
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionLetters.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionLetters[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let letter = sectionLetters[section]
        let products = filteredItems.filter {
            $0.name.prefix(1).uppercased() == letter
        }
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productoCell", for: indexPath) as! ProductHistoryCell
        let letter = sectionLetters[indexPath.section]
        let products = filteredItems.filter {
            $0.name.prefix(1).uppercased() == letter
        }
        let product = products[indexPath.row]
        cell.lblNombreProducto.text = product.name
        if let url = URL(string: product.imageUrl) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data {
                    DispatchQueue.main.async {
                        cell.imgProducto.image = UIImage(data: data)
                    }
                }
            }.resume()
        } else {
            cell.imgProducto.image = UIImage(named: "placeholder")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 65
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 70))
        header.backgroundColor = .clear

        let squareView = UIView(frame: CGRect(x: 20, y: 10, width: tableView.frame.width - 40, height: 50))

        let grisClaro = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
        squareView.backgroundColor = grisClaro
        squareView.layer.cornerRadius = 25
        squareView.layer.masksToBounds = true

        let letter = sectionLetters[section]

        let label = UILabel(frame: squareView.bounds)
        label.text = letter
        label.textAlignment = .center
        label.font = UIFont(name: "Poppins-ExtraBold", size: 20)
        label.textColor = .darkGray

        squareView.addSubview(label)
        header.addSubview(squareView)

        return header
    }
}
