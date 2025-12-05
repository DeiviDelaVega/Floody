//
//  SearchViewController.swift
//  Floody
//
//  Created by David Barbaran on 28/11/25.
//

import UIKit

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
                  withIdentifier: "productRow",
                  for: indexPath
              ) as! ProductCell

              let product = products[indexPath.row]

              cell.nameLabel.text = product.name
              cell.countriesLabel.text = "Países de venta: \(product.countries)"
              cell.productImageView.image = UIImage(named: product.imageName)

              return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailVC = storyboard.instantiateViewController(withIdentifier: "ProductDetailController") as? ProductDetailController {
            detailVC.productCodeToFetch = "8410111211202"
            detailVC.modalPresentationStyle = .fullScreen
            self.present(detailVC, animated: true)

        }

    }
    
    @IBOutlet weak var tableProduct: UITableView!
    
    var products: [Product] = [
        Product(
            name: "Atún Campomar",
            countries: "Perú, Chile",
            imageName: "atun_img"
        ),
        Product(
            name: "Arroz Costeño",
            countries: "Perú",
            imageName: "atun_img"
        ),
        Product(
            name: "Aceite Primor",
            countries: "Perú, Colombia",
            imageName: "atun_img"
        ),
        Product(
            name: "Leche Gloria",
            countries: "Perú, Ecuador",
            imageName: "atun_img"
        ),
        Product(
            name: "Galletas Oreo",
            countries: "Perú, Argentina",
            imageName: "atun_img"
        )
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableProduct.dataSource = self
        tableProduct.delegate = self
        tableProduct.rowHeight = UITableView.automaticDimension
    }
    
    
    @IBAction func verMasTapped(_ sender: UIButton) {
        
        let nuevosProductos: [Product] = [
               Product(name: "Fideos Don Vittorio", countries: "Perú", imageName: "fideos"),
               Product(name: "Azúcar Rubia", countries: "Perú", imageName: "azucar")
           ]

           let startIndex = products.count
           products.append(contentsOf: nuevosProductos)

           let indexPaths = (startIndex..<products.count).map {
               IndexPath(row: $0, section: 0)
           }

           tableProduct.insertRows(at: indexPaths, with: .fade)
    }
    
    @IBAction func filtroTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "FilterViewController") as! FilterViewController
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true)
    }
}
