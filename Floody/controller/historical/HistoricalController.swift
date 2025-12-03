import UIKit

class HistoricalController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var scCategoria: UISegmentedControl!
    @IBOutlet weak var tvProducto: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fontSegmentedControl()
            
        tvProducto.dataSource = self
        tvProducto.delegate = self
        tvProducto.backgroundColor = .white
    }

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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productoCell", for: indexPath)
        
        cell.backgroundColor = .white
        
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
        header.backgroundColor = .clear

        let squareView = UIView(frame: CGRect(x: 20, y: 5, width: tableView.frame.width - 40, height: 40))

        let grisClaro = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
        squareView.backgroundColor = grisClaro
        
        squareView.layer.cornerRadius = 20
        squareView.layer.masksToBounds = true

        let label = UILabel(frame: squareView.bounds)
        // label.text = letra
        label.textAlignment = .center
        label.font = UIFont(name: "Poppins-ExtraBold", size: 18)
        label.textColor = .darkGray

        squareView.addSubview(label)
        header.addSubview(squareView)

        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // Ya que numberOfSections devuelve 0, esto no se ejecutara pero va ser importante para que el header tenga una altura
        return 50
    }
}
