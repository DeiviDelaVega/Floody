import UIKit

class CountryCell: UITableViewCell {
    @IBOutlet weak var imgFlag: UIImageView!
    @IBOutlet weak var lblCountry: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(with country: Country) {
        lblCountry.text = country.translatedName
        imgFlag.image = nil
        
        if let url = URL(string: country.flagURL) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data {
                    DispatchQueue.main.async {
                        self.imgFlag.image = UIImage(data: data)
                    }
                }
            }.resume()
        }
    }
}
