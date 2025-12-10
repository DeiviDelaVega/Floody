import UIKit

class ProductCell: UITableViewCell {
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var countriesLabel: UILabel!
    @IBOutlet weak var favoriteBtn: UIButton!
    
    private var currentProduct: Product?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func updateSaveButtonIcon(isSaved: Bool) {
        let iconName = isSaved ? "bookmark.fill" : "bookmark"
        let image = UIImage(systemName: iconName)
        DispatchQueue.main.async {
            self.favoriteBtn.setImage(image, for: .normal)
            self.favoriteBtn.tintColor = isSaved ? .systemYellow : .darkGray
        }
    }
     
    /*
    @IBAction func btnSaved(_ sender: UIButton) {
        guard let product = currentProduct else { return }
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
            
        SavedService.shared.toggleSavedProduct(product: product) {
            [weak self] isNowSaved in
            self?.updateSaveButtonIcon(isSaved: isNowSaved)
        }
    }*/
}
