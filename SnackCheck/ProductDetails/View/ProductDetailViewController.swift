//
//  ProductDetailViewController.swift
//  SnackCheckKategoriler
//
//  Created by ELİF ÇAĞIL on 12.04.2025.
//

import UIKit

class ProductDetailViewController: UIViewController {
    
    
    //MARK: -Properties
    
    @IBOutlet weak var enerjiLabel: UILabel!
    @IBOutlet var productBrand: UILabel!
    @IBOutlet weak var proteinLabel: UILabel!
    @IBOutlet weak var fatLabel: UILabel!
    @IBOutlet weak var saturatedFatLabel: UILabel!
    @IBOutlet weak var sugarLabel: UILabel!
    @IBOutlet weak var saltLabel: UILabel!
    @IBOutlet weak var fiberLabel: UILabel!
    @IBOutlet weak var carboLabel: UILabel!
    @IBOutlet var productName: UILabel!
    @IBOutlet weak var ButtonName: UILabel!
    @IBOutlet var contentTF: UITextView!
    @IBOutlet weak var stackViewContent: UIStackView!
    @IBOutlet weak var stackViewFoodTitle: UIStackView!
    @IBOutlet weak var stackViewFoodValue: UIStackView!
    @IBOutlet weak var stackviewAllpage: UIStackView!
    
   var viewModel = ProductDetailViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let Product = viewModel.product {
            productBrand.text = Product.product_brand
            productName.text = Product.product_name
            configure(with: Product)
            
            
            
        }
        ButtonName.text = viewModel.buttonName
        contentTF.text = viewModel.context
        
    }
    
    
    func configure(with product:Product){   //bu viewmodele gidicek mi
        enerjiLabel.text = String(product.energy ?? 0)
        proteinLabel.text = String(product.proteins ?? 0)
        fatLabel.text = String(product.fat ?? 0)
        carboLabel.text = String(product.carbohydrates ?? 0)
        fiberLabel.text = String(product.fiber ?? 0)
        sugarLabel.text = String(product.sugars ?? 0)
        saturatedFatLabel.text = String(product.saturated_fat ?? 0)
        saltLabel.text = String(product.salt ?? 0 )
        
    }


}
