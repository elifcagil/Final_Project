//
//  UrunDetayViewController.swift
//  SnackCheckKategoriler
//
//  Created by ELİF ÇAĞIL on 11.03.2025.
//

import UIKit
class ProductButtonDetailViewController: UIViewController {
    
    //MARK: -Properties
    
    var viewModel: ProductButtonDetailViewModel!
    @IBOutlet var productbrandLabel: UILabel!
    @IBOutlet var productNameLabel: UILabel!
    @IBOutlet var prodcutImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let product = viewModel.product{
            productbrandLabel.text = product.product_brand
            productNameLabel.text = product.product_name
            if let urlString = product.product_image,
               let url = URL(string: urlString) {
                downloadImage(from: url) { [weak self] image in
                    DispatchQueue.main.async {
                        self?.prodcutImageView.image = image
                    }
                }
            } else {
                prodcutImageView.image = UIImage(systemName: "photo") // fallback
            }
        }
    }
    private func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                print("❌ Görsel indirilemedi: \(error?.localizedDescription ?? "bilinmiyor")")
                completion(nil)
            }
        }.resume()
    }
    
    //MARK: -IBActionFunc
    
    @IBAction func ingeridentsButton(_ sender: Any) {
        performSegue(withIdentifier: "ingeridents", sender: viewModel.product)
        
    }
    
    @IBAction func analizeButton(_ sender: Any) {
        performSegue(withIdentifier: "analize", sender: viewModel.product)
    }
    @IBAction func allergenButton(_ sender: Any) {
        performSegue(withIdentifier: "alergen", sender: viewModel.product)
    }
    @IBAction func foodValuesButton(_ sender: Any) {
        performSegue(withIdentifier: "foodValue", sender: viewModel.product)
    }
    
    
    //MARK: -HelperMethods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let product = sender as? Product{
            let togoVC = segue.destination as! ProductDetailViewController
            let ViewModel = ProductDetailViewModel()
            ViewModel.product = product
            togoVC.viewModel = ViewModel
            
            switch segue.identifier {
            case "ingeridents":
                
                ViewModel.buttonName = "İçindekiler"
                ViewModel.context = product.ingeridents
                
            case "analize" :
                ViewModel.buttonName = "Analiz"
                ViewModel.context = product.aiComment //burası productdetail viewmodelden gelicek viewmodel firestoremanagerden çekicek
                
            case "alergen" :
                ViewModel.buttonName = "Alerjen Uyarısı"
                ViewModel.context = product.analize//burası productdetail viewmodelden gelicek viewmodel firestoremanagerden çekicek
                
            case "foodValue" :
                ViewModel.buttonName = "Besin Değerleri"
                ViewModel.context = "\(product.product_name!) ürünün besin değerleri aşağıdaki gibidir."
                togoVC.loadViewIfNeeded() //daha diğer syafanın viewıv yüklenmediği için buradan erişitğimizden önce onun yüklenmesini sağlarız daha sonra stackview e erişim isteriz.
                togoVC.stackviewAllpage.isHidden = false
                togoVC.stackViewFoodValue.isHidden = false
            default:
                break
            }
        }
    }
}
