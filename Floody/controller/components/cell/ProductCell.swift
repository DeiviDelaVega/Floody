//
//  ProductCell.swift
//  Floody
//
//  Created by David Barbaran on 29/11/25.
//

import UIKit

class ProductCell: UITableViewCell {
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var countriesLabel: UILabel!
    @IBOutlet weak var favoriteBtn: UIButton!
    

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
