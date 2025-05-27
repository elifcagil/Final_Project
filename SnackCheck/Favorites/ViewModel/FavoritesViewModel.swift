//
//  FavoritesViewModel.swift
//  SnackCheckKategoriler
//
//  Created by ELİF ÇAĞIL on 14.04.2025.
//

import Foundation

class FavoritesViewModel{
    
    //MARK: -Properties
    
    var favoritesList : [Product] = []
    var onFetched : (([Product]) -> Void)?
    var firestoreManaher:FirestoreManager
    
    init(firestoreManager:FirestoreManager){
        self.firestoreManaher = firestoreManager
    }
    
    //MARK: -HelperMethods
    
    func FetchFavorites() {
        firestoreManaher.fetchFavorites { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let favorites):
                        self?.favoritesList = favorites
                        self?.onFetched?(favorites)
                    case .failure(let error):
                        print("❌ Favori ürünler alınamadı: \(error.localizedDescription)")
                    }
                }
            }
    }
    
    func deleteFavorite(item: Product) {
        guard let id = item.product_id else { return }
            guard let barcode = item.barcode else { return }

            if let index = favoritesList.firstIndex(where: { $0.product_id == id }) {
                firestoreManaher.deleteFavorite(barcode: barcode) { [weak self] result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let message):
                            print("✅ Silindi: \(message)")
                            self?.favoritesList.remove(at: index)
                            self?.onFetched?(self?.favoritesList ?? [])
                        case .failure(let error):
                            print("❌ Silme hatası: \(error.localizedDescription)")
                        }
                    }
                }
            }
         }
        
        func addFavorite(productCode: String, completion: @escaping (Result<String, Error>) -> Void) {
            firestoreManaher.updateFavorite(productCode: productCode) { result in
                completion(result)
            }
        }
    
    }

        
        




