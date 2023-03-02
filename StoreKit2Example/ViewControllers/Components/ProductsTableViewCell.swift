//
//  ProductsTableViewCell.swift
//  StoreKit2Example
//
//  Created by Leo Ho on 2023/3/2.
//

import UIKit

class ProductsTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var lbProduct: UILabel!
    @IBOutlet weak var btnPurchase: UIButton!
    
    // MARK: - Variables
    
    static let identifier = "ProductsTableViewCell"
    
    weak var delegate: ProductTableViewCellDelegate?
    
    // MARK: - LifeCycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - UI Settings
    
    func setInit(productName: String,
                 productPrice: String,
                 delegate: ProductTableViewCellDelegate) {
        lbProduct.text = "\(productName) (\(productPrice))"
        
        btnPurchase.setTitle("購買", for: .normal)
        
        self.delegate = delegate
    }
    
    // MARK: - IBAction
    
    @IBAction func btnPurchaseClicked(_ sender: UIButton) {
        delegate?.btnPurchaseClicked()
    }
}

// MARK: - Extensions



// MARK: - Protocol

protocol ProductTableViewCellDelegate: NSObjectProtocol {
    
    func btnPurchaseClicked()
}
