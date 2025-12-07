import UIKit

class SavedController: UIViewController,
                       UICollectionViewDelegate,
                       UICollectionViewDataSource,UICollectionViewDelegateFlowLayout

{
    @IBOutlet weak var tvProductSaved: UICollectionView!
    
    var lista:[Product] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tvProductSaved.delegate = self
        tvProductSaved.dataSource = self
        
        listado()
        
        tvProductSaved.reloadData()
    }
    
    func listado() {
        lista.append(Product(
            name: "Atún Campomar",
            countries: "Perú, Chile",
            imageName: "atun_img",
            category: "Alimentos"
        ))
        
        lista.append(Product(
            name: "Arroz Costeño",
            countries: "Perú",
            imageName: "arroz_img",
            category: "Alimentos"
        ))
        
        lista.append(Product(
            name: "Aceite Primor",
            countries: "Perú, Colombia",
            imageName: "aceite_img",
            category: "Alimentos"
        ))
        
        lista.append(Product(
            name: "Leche Gloria",
            countries: "Perú, Ecuador",
            imageName: "leche_img",
            category: "Bebidas"
        ))
        
        lista.append(Product(
            name: "Galletas Oreo",
            countries: "Perú, Argentina",
            imageName: "galletas_img",
            category: "Alimentos"
        ))
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lista.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productCell", for: indexPath) as! ProductCollectionCell
        
        let product = lista[indexPath.row]
        
        cell.lblNameProduct.text = product.name
        cell.lblOriginProduct.text = product.countries
        cell.ivProduct.image = UIImage(named: product.imageName)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 15, left: 15, bottom: 10, right: 15)
    }

    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: 110, height: 170)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10//35
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20//25
    }


}
