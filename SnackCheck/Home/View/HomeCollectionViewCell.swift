//
//  AnaSayfaCollectionViewCell.swift
//  SnackCheckKategoriler
//
//  Created by ELİF ÇAĞIL on 17.03.2025.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell {
    
    //MARK: -Properties
    var onTapFavorite: ((String?) -> Void)?
    var product: Product?
    
    @IBOutlet var productImageView: UIImageView!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet var productBrandLabel: UILabel!
    @IBOutlet var productNameLabel: UILabel!
    @IBAction func addFavoritesButton(_ sender: UIButton) {
        
        onTapFavorite?(product?.product_id)
    }
    
    
    //MARK: -HelperMethods
    
    func configuration(_ product: Product) {
        self.product = product
        
        // ✅ RESİM - URL üzerinden yükle
        if let urlString = product.product_image,
           let url = URL(string: urlString) {
            downloadImage(from: url) { [weak self] image in
                DispatchQueue.main.async {
                    self?.productImageView.image = image
                }
            }
        } else {
            productImageView.image = UIImage(systemName: "photo") // fallback
        }

        // ⭐ FAVORİ butonu
        let image = product.isFavorites == true ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
        favoriteButton.setImage(image, for: .normal)

        // 🏷️ LABEL'lar
        productNameLabel.text = product.product_name
        productBrandLabel.text = product.product_brand

        // Çerçeve
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 0.5
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

}
