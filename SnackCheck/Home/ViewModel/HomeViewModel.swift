//
//  AnaSayfaViewModel.swift
//  SnackCheckKategoriler
//
//  Created by ELİF ÇAĞIL on 14.04.2025.
//

import Foundation


class HomeViewModel{
    
  //MARK: -Properties
    
    var productList : [Product] = []
    var allProductList : [Product] = []
    var onFetched: (([Product]) -> Void)?
    var onFavoriteChanged: (() -> Void)?
    var isSearch = false
    var searchedProduct = [Product]()
    var searchedWord : String = ""
    
    var firestoreManager:FirestoreManager!
    
    init(firestoreManager:FirestoreManager){
        self.firestoreManager = firestoreManager
    }
    
    
    //MARK: -HelperMethods
    
    func favoriteProduct(with productId: String?) {
        guard
            let productId = productId,
            let product = productList.first(where: { $0.product_id == productId}),
                let barcode = product.barcode
        else { return }
        
        product.isFavorites?.toggle()
        if product.isFavorites == true {
               firestoreManager.updateFavorite(productCode: barcode) { result in
                   DispatchQueue.main.async {
                       switch result {
                       case .success(let message):
                           print("🎉 Favorilere eklendi: \(message)")
                       case .failure(let error):
                           print("❌ Favori eklenemedi: \(error.localizedDescription)")
                       }
                   }
               }
           } else {
               // Eğer burada favoriden çıkarma işlemi yapılacaksa, ayrı bir endpoint olabilir (isteğe bağlı)
               print("⭐️ Favoriden çıkarıldı (sunucuya istek atılmadı).")
           }
        
        onFavoriteChanged?()
    }
    
    func FetchAllProduct(){
        firestoreManager.fetchAllProducts{ [weak self] products in
            self?.productList = products
            self?.allProductList = products
            self?.onFetched?(products)
            
        }
    }
    
    func searchFunc(searchedWord: String) {
        // 🔎 Boşluk ve newline temizliği
        let cleanedWord = searchedWord.trimmingCharacters(in: .whitespacesAndNewlines)

        // 🔙 Eğer boşsa tüm ürünleri geri yükle
        guard !cleanedWord.isEmpty else {
            productList = allProductList
            onFetched?(productList)
            return
        }

        // 🔁 Firestore'da var mı kontrol et (ve yoksa ekle → getir)
        firestoreManager.fetchProductByBarcode(cleanedWord) { [weak self] product in
            DispatchQueue.main.async {
                if let product = product {
                    self?.productList = [product] // 🔥 Ürünü sonuçlara ekle
                } else {
                    self?.productList = [] // ❌ Ürün bulunamadı
                }

                // 📢 UI'ya bildir
                self?.onFetched?(self?.productList ?? [])
            }
        }
    }


}

