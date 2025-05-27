//
//  FireStoreManager.swift
//  SnackCheck
//
//  Created by ELİF ÇAĞIL on 1.05.2025.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

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
        guard let getURL = URL(string: "http://localhost:3000/api/products/\(barcode)") else {
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

                guard let postURL = URL(string: "http://localhost:3000/api/products/\(barcode)") else {
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
        
        guard let url = URL(string: "http://localhost:3000/api/auth/register") else {
                   completion(.failure(NSError(domain: "Geçersiz URL", code: -1)))
                   return
               }
               
               let requestBody: [String: Any] = [
                   "firstName": name,
                   "lastName": surname,
                   "email": email,
                   "password": password
               ]
               
               var request = URLRequest(url: url)
               request.httpMethod = "POST"
               request.setValue("application/json", forHTTPHeaderField: "Content-Type")
               
               do {
                   request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
               } catch {
                   completion(.failure(error))
                   return
               }
               
               URLSession.shared.dataTask(with: request) { data, response, error in
                   
                   // 1. Hata varsa
                   if let error = error {
                       completion(.failure(error))
                       return
                   }
                   
                   // 2. Geçerli response kontrolü
                   guard let httpResponse = response as? HTTPURLResponse else {
                       completion(.failure(NSError(domain: "Geçersiz yanıt", code: -2)))
                       return
                   }
                   
                   // 3. Status kodu kontrol
                   guard (200...299).contains(httpResponse.statusCode) else {
                       let statusError = NSError(domain: "Sunucu hatası", code: httpResponse.statusCode)
                       completion(.failure(statusError))
                       return
                   }
                   
                   // 4. JSON çözümleme
                   guard let data = data else {
                       completion(.failure(NSError(domain: "Boş veri", code: -3)))
                       return
                   }
                   
                   do {
                       let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                       
                       if let _ = json?["uid"] as? String {
                           completion(.success(()))
                       } else if let errorMessage = json?["error"] as? String {
                           let backendError = NSError(domain: errorMessage, code: -4)
                           completion(.failure(backendError))
                       } else {
                           let unknownError = NSError(domain: "Bilinmeyen hata", code: -5)
                           completion(.failure(unknownError))
                       }
                   } catch {
                       completion(.failure(error))
                   }
                   
               }.resume()
           }
    
       
    let db = Firestore.firestore()
    
    func loginUser(email:String, password:String,completion:@escaping(Result<Void,Error>)->(Void)){
        
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                   if let error = error {
                       print("kullanıcı girişi yapılamadı")
                       completion(.failure(error))
                       return
                   }
                   guard let uid = authResult?.user.uid else {
                       completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey:"kullanıcı id sine erişilemedi"])))

                       return
                   }
                   
                   let userRef = self.db.collection("users").document(uid)
                   userRef.getDocument { document , error in
                       if let error = error {
                           try? Auth.auth().signOut()
                           completion(.failure(error))
                           return
                       }
                       guard let document = document,document.exists else {
                           try? Auth.auth().signOut()
                           completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey:"kullanıcı firestorede bulunamadı"])))
                           return
                       }
                       
                       completion(.success(()))
                   }
                   
               }
              
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
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
