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
            let product = productList.first(where: { $0.product_id == productId})
        else { return }
        
        product.isFavorites?.toggle()
        firestoreManager.updateFavorite(product_id: productId,favorite: product.isFavorites ?? false)
        
        onFavoriteChanged?()
    }
    
    func FetchAllProduct(){
//        firestoreManager.fetchProductListFromAPI{ [weak self] products in
//            self?.productList = products
//            self?.allProductList = products
//            self?.onFetched?(products)
//            
//        }
    }
    
    func searchFunc(searchedWord: String) {
        // Önce boşluğu kontrol et
        guard !searchedWord.isEmpty else {
            productList = allProductList
            onFetched?(productList)
            return
        }

        firestoreManager.fetchProductByBarcode(searchedWord) { [weak self] product in
            DispatchQueue.main.async {
                if let product = product {
                    self?.productList = [product] // sadece bir ürün gösterilecek
                } else {
                    self?.productList = [] // sonuç yok
                }
                self?.onFetched?(self?.productList ?? [])
            }
        }
    }


}

