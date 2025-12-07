import UIKit

class ProductHistoryCell: UITableViewCell {
    @IBOutlet weak var imgProducto: UIImageView!
    @IBOutlet weak var lblNombreProducto: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
