//
//  FireStoreManager.swift
//  SnackCheck
//
//  Created by ELİF ÇAĞIL on 1.05.2025.
//

import Foundation

class FirestoreManager{
    var tempList: [Product] = []
    
    
    //MARK: -PersonalFetch
    
    func FetchPersonel(completion: @escaping ([PersonalModel]) -> Void) {
        
    }
    
    //MARK: -CategoriesFunc
    
    func FetchCategories(completion: @escaping ([Category]) -> Void) {
        
    }
    
    //MARK: -ProductsFunc
    
    func fetchProductByBarcode(_ barcode: String, completion: @escaping (Product?) -> Void) {
        guard let getURL = URL(string: "http://localhost:5050/api/products/\(barcode)") else {
            print("❌ Geçersiz GET URL")
            completion(nil)
            return
        }

        var getRequest = URLRequest(url: getURL)
        getRequest.httpMethod = "GET"

        URLSession.shared.dataTask(with: getRequest) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 404 {
                // 🔁 Ürün bulunamadı → POST ile ekle
                print("⚠️ Ürün bulunamadı, POST ile ekleniyor...")

                guard let postURL = URL(string: "http://localhost:5050/api/products/\(barcode)") else {
                    print("❌ Geçersiz POST URL")
                    completion(nil)
                    return
                }

                var postRequest = URLRequest(url: postURL)
                postRequest.httpMethod = "POST"

                URLSession.shared.dataTask(with: postRequest) { [self] _, postResponse, postError in
                    if let postError = postError {
                        print("❌ POST hatası: \(postError.localizedDescription)")
                        completion(nil)
                        return
                    }

                    print("✅ Ürün başarıyla eklendi, tekrar GET yapılıyor...")

                    // ✅ POST sonrası tekrar GET yap
                    fetchProductByBarcode(barcode, completion: completion)

                }.resume()

                return
            }

            if let error = error {
                print("❌ Hata: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("❌ Veri gelmedi")
                completion(nil)
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    let product = Product(
                        product_id: json["id"] as? String ?? "",
                        product_name: json["name"] as? String ?? "",
                        product_brand: json["brands"] as? String ?? "",
                        product_image: json["image_url"] as? String ?? "",
                        category: json["categories"] as? String ?? "",
                        ingeridents: json["ingredients_text"] as? String ?? "",
                        food_values: json["nutriments"] as? [String: Any] ?? [:],
                        isFavorites: false,
                        barcode: json["code"] as? String ?? ""
                    )
                    completion(product)
                } else {
                    print("❌ JSON format hatası")
                    completion(nil)
                }
            } catch {
                print("❌ JSON parse hatası: \(error)")
                completion(nil)
            }

        }.resume()
    }


    
    func fetchProductsByCategory(_ category: String, completion: @escaping ([Product])-> Void) {
        
    }
    
    //MARK: -UserFunc
    
    func createUser(name:String,surname:String, email:String, password:String,completion:@escaping (Result<Void,Error>)->(Void)){
        
    }
    
    
    func loginUser(email:String, password:String,completion:@escaping(Result<Void,Error>)->(Void)){
        
        
    }
    
    func logOutUser(completion:@escaping (Result <Void ,Error>) -> Void){
        
    }
    
    func deleteUser(completion: @escaping (Result<Void,Error>) -> Void){
        
    }
    
    func currenUserInfo(completion: @escaping (Result<User,Error>) -> (Void)){
        
        
    }
    //MARK: -FavoritesFunc
    
    func fetchFavorites(completion:@escaping ([Product])-> Void){
        
    }
    func updateFavorite(product_id:String,favorite:Bool){
        
        
    }
}
