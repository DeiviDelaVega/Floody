import UIKit

class ProductCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var ivProduct: UIImageView!
    @IBOutlet weak var lblNameProduct: UILabel!
    @IBOutlet weak var lblOriginProduct: UILabel!

    
    @IBOutlet weak var btnSaved: UIButton!
    
    var onSaveTapped: (() -> Void)?
        
        override func awakeFromNib() {
            super.awakeFromNib()
            setupButtonStyle()
        }
        
        func setupButtonStyle() {
         
            let iconName = "bookmark.fill" //bookmark-2
            let config = UIImage.SymbolConfiguration(pointSize: 10, weight: .bold, scale: .large)
            let image = UIImage(systemName: iconName, withConfiguration: config)
            
            btnSaved.setImage(image, for: .normal)
            btnSaved.tintColor = .systemYellow
        }
        
   
    @IBAction func btnSavedAction(_ sender: UIButton) {
        onSaveTapped?()
    }
 
}
