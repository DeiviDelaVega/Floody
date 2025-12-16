import UIKit

class ProductCell: UITableViewCell {
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var countriesLabel: UILabel!
    @IBOutlet weak var favoriteBtn: UIButton!
    
    var onFavoriteTapped: (() -> Void)?
    var imageURL:String? 
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
            print("✅ ProductCell cargada")
            print("➡️ imageView frame:", productImageView.frame)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        productImageView.image = UIImage(named: "atun_img")
        imageURL = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func updateSaveButtonIcon(isSaved: Bool) {
        let iconName = isSaved ? "btnSavedComplete" : "wishlist"
        let image = UIImage(named: iconName)
        DispatchQueue.main.async {
            self.favoriteBtn.setImage(image, for: .normal)
            self.favoriteBtn.tintColor = isSaved ? .systemYellow : .darkGray
        }
    }
     
    @IBAction func btnFavorite(_ sender: UIButton) {
        onFavoriteTapped?()
    }
}
