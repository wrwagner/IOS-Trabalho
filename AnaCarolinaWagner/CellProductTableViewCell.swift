//
//  CellProductTableViewCell.swift
//  AnaCarolinaWagner
//
//  Created by Wagner Rodrigues on 02/09/2018.
//  Copyright © 2018 ComprasUSA. All rights reserved.
//

import UIKit

class CellProductTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var imageViewProduct: UIImageView!
    @IBOutlet private weak var labelName: UILabel!
    @IBOutlet private weak var labelPrice: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func prepare(with product: Product) {
        labelName.text = product.name ?? ""
        labelPrice.text = String(product.price) ?? "0"
        if let image = product.image as? UIImage {
            imageViewProduct.image = image
        } else {
            imageViewProduct.image = UIImage(named: "noCover")
        }
    }

}
